// CloudControlCenter - CloudControl Installation manager
package main

import (
	"fmt"
	markdown "github.com/MichaelMure/go-term-markdown"
	"github.com/francoispqt/lists/slices"
	"github.com/gin-gonic/gin"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"log"
	"net/http"
	"nullprogram.com/x/optparse"
	"os"
	"os/exec"
	"regexp"
)

// All installation steps that need to be carried out
var steps = []string{"flavour"}

// A map of all features
var features map[string]FeatureYaml

// The current step in the (un-)installation
var currentStep = 0

// The console output of the current step
var stepOutput = ""

// The overall CloudControl status
var status = "INIT"

// Title of the current step
var stepTitle = "Flavour"

// Description of the current step
var stepDescription = "Installing flavour"

// Simple handler to handle fatal errors
func fatal(err error) {
	fmt.Fprintf(os.Stderr, "%s: %s\n", os.Args[0], err)
	os.Exit(1)
}

// Console writer to capture console output
type ConsoleWriter struct{}

// Write the console output of the current step to the stepOutput variable
func (ConsoleWriter) Write(p []byte) (n int, err error) {
	newOutput := string(p)
	stepOutput += newOutput
	log.Print(newOutput)
	return len(p), nil
}

// Feature yaml interface

type FeatureYaml struct {
	Title         string
	Description   string
	Configuration []string
}

// Install CloudControl flavour and all features
func cccInitialization() {

	currentStep++

	consoleWriter := new(ConsoleWriter)

	log.Println("Starting flavour initialization")

	cmd := exec.Command("bash", "/home/cloudcontrol/bin/flavourinit.sh")
	cmd.Stderr = consoleWriter
	cmd.Stdout = consoleWriter
	if err := cmd.Start(); err != nil {
		fatal(err)
	}

	if err := cmd.Wait(); err != nil {
		fatal(err)
	}

	log.Println("Flavour initialization finished")

	for _, step := range slices.StringSlice(steps).Filter(func(k int, v string) bool {
		return v != "flavour"
	}) {
		currentStep++

		log.Printf("Installing feature %s\n", step)

		stepOutput = ""
		stepTitle = features[step].Title
		stepDescription = features[step].Description

		cmd := exec.Command("bash", fmt.Sprintf("/home/cloudcontrol/feature-installers/%s/install.sh", step))
		cmd.Stderr = consoleWriter
		cmd.Stdout = consoleWriter
		if err := cmd.Start(); err != nil {
			fatal(err)
		}

		if err := cmd.Wait(); err != nil {
			fatal(err)
		}
	}

	file, err := os.Create("/home/cloudcontrol/initialization.done")

	if err != nil {
		fatal(err)
	}

	_ = file.Close()

	log.Println("Finished initialization")

	status = "INITIALIZED"
}

// API-Server startup
func main() {

	options := []optparse.Option{
		{"port", 'P', optparse.KindOptional},
	}

	var port = "8080"

	results, _, err := optparse.Parse(options, os.Args)

	if err != nil {
		fatal(err)
	}

	for _, result := range results {
		switch result.Long {
		case "port":
			port = result.Optarg
		}
	}

	if _, err := os.Stat("/home/cloudcontrol/initialization.done"); !os.IsNotExist(err) {
		status = "INITIALIZED"
	}

	featureRe := regexp.MustCompile("USE_([^=]+)")

	for _, env := range os.Environ() {
		if featureRe.MatchString(env) {
			matches := featureRe.FindStringSubmatch(env)
			steps = append(steps, matches[1])
		}
	}

	// Build feature slice

	features = make(map[string]FeatureYaml)

	for _, step := range slices.StringSlice(steps).Filter(func(k int, v string) bool {
		return v != "flavour"
	}) {
		var feature FeatureYaml
		featureFile, err := ioutil.ReadFile(fmt.Sprintf("/home/cloudcontrol/feature-installers/%s/feature.yaml", step))

		if err != nil {
			fatal(err)
		}

		if err := yaml.Unmarshal(featureFile, &feature); err != nil {
			fatal(err)
		}
		features[step] = feature
	}

	if status == "INIT" {
		go cccInitialization()
	}

	router := gin.Default()

	router.GET("/", func(context *gin.Context) {
		context.Redirect(http.StatusFound, "/client")
	})

	router.Static("/client", "./client")

	api := router.Group("/api")
	api.GET("/status", func(context *gin.Context) {
		switch context.Request.Header.Get("Accept") {
		case "text/plain":
			context.String(http.StatusOK, status)
		default:
			context.JSON(http.StatusOK, gin.H{
				"status": status,
			})
		}
	})
	api.GET("/steps", func(context *gin.Context) {
		context.JSON(http.StatusOK, gin.H{
			"steps": steps,
		})
	})
	api.GET("/steps/current", func(context *gin.Context) {
		context.JSON(http.StatusOK, gin.H{
			"currentStep": currentStep,
			"output":      stepOutput,
			"title":       stepTitle,
			"description": stepDescription,
		})
	})
	api.GET("/features", func(context *gin.Context) {
		switch context.Request.Header.Get("Accept") {
		case "text/plain":
			output := ""
			for feature, featureInfo := range features {
				output += fmt.Sprintf("# %s\n\n", featureInfo.Title)
				output += fmt.Sprintf("%s\n\n", featureInfo.Description)
				motdFile := fmt.Sprintf("/home/cloudcontrol/feature-installers/%s/motd.sh", feature)
				if _, err := os.Stat(motdFile); err == nil {
					if commandOutput, err := exec.Command("bash", motdFile).Output(); err == nil {
						output += string(commandOutput) + "\n\n"
					}
				}
			}
			context.String(http.StatusOK, string(markdown.Render(output, 80, 0)))
		default:
			context.JSON(http.StatusOK, features)
		}
	})

	if err := router.Run(fmt.Sprintf(":%s", port)); err != nil {
		fatal(err)
	}
}
