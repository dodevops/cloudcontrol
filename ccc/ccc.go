// CloudControlCenter - CloudControl Installation manager
package main

import (
	"fmt"
	markdown "github.com/MichaelMure/go-term-markdown"
	"github.com/gin-gonic/gin"
	"gopkg.in/yaml.v2"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"nullprogram.com/x/optparse"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// All installation steps that need to be carried out
var steps []string

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

// A regexp extracting the feature name from the path
var featureIdentifier = regexp.MustCompile("/home/cloudcontrol/feature-installers/([^/]+)/feature.yaml")

// A regexp cutting of characters used for sorting special features (like shells) higher up
var sortingRegexp = regexp.MustCompile("_(.+)")

// Simple handler to handle fatal errors
func fatal(err error) {
    _, _ = fmt.Fprintf(os.Stderr, "%s: %s\n", os.Args[0], err)
    if _, exists := os.LookupEnv("CONTINUE_ON_ERROR"); ! exists {
        os.Exit(1)
    }
}

// ConsoleWriter used to capture console output
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
	Path          string
	Title         string
	Description   string
	Configuration []string
}

// Install CloudControl flavour and all features
func cccInitialization() {

	currentStep++

	consoleWriter := new(ConsoleWriter)

	log.Println("Setting bash as default shell")

	file, err := os.Create("/home/cloudcontrol/.shell")

	if err != nil {
		fatal(err)
	}

	if _, err := file.WriteString("bash"); err != nil {
		fatal(err)
	}

	if err := file.Close(); err != nil {
		fatal(err)
	}

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

	for _, step := range steps[1:] {
		currentStep++

		stepOutput = ""
		stepTitle = features[step].Title
		log.Printf("Installing feature %s\n", stepTitle)

		stepDescription = features[step].Description

		var args []string

		if value, exists := os.LookupEnv(fmt.Sprintf("DEBUG_%s", step)); exists && value == "yes" {
			args = append(args, "-x")
		}

		args = append(args, fmt.Sprintf("%s/install.sh", features[step].Path))

		cmd := exec.Command("bash", args...)
		cmd.Stderr = consoleWriter
		cmd.Stdout = consoleWriter
		if err := cmd.Start(); err != nil {
			fatal(err)
		}

		if err := cmd.Wait(); err != nil {
			fatal(err)
		}
	}

	file, err = os.Create("/home/cloudcontrol/initialization.done")

	if err != nil {
		fatal(err)
	}

	_ = file.Close()

	log.Println("Finished initialization")
	log.Println("Please run the following to enter CloudControl")
	log.Println("docker-compose exec cli /usr/local/bin/cloudcontrol run")

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

	// Check with features are enabled

	features = make(map[string]FeatureYaml)

	featureFiles, err := filepath.Glob("/home/cloudcontrol/feature-installers/*/feature.yaml")

	if err != nil {
		fatal(err)
	}

	// Support specifying features using the FEATURES env variable

	if value, exists := os.LookupEnv("FEATURES"); exists {
		for _, configuredFeature := range strings.Split(value, " ") {
			var configuredVersion = ""
			if strings.Contains(configuredFeature, ":") {
				configuredVersion = strings.Split(configuredFeature, ":")[1]
				configuredFeature = strings.Split(configuredFeature, ":")[0]
			}
			_ = os.Setenv(fmt.Sprintf("USE_%s", configuredFeature), "yes")
			if configuredVersion != "" {
				_ = os.Setenv(fmt.Sprintf("%s_VERSION", strings.ToUpper(configuredFeature)), configuredVersion)
			}
		}
	}

	for _, feature := range featureFiles {
		if featureIdentifier.MatchString(feature) {
			matches := featureIdentifier.FindStringSubmatch(feature)
			featureName := matches[1]
			featureDir := matches[1]

			if sortingRegexp.MatchString(featureName) {
				featureName = sortingRegexp.FindStringSubmatch(featureName)[1]
			}

			if value, exists := os.LookupEnv(fmt.Sprintf("USE_%s", featureName)); exists && value == "yes" {
				var featureYaml FeatureYaml
				featureFile, err := ioutil.ReadFile(feature)

				if err != nil {
					fatal(err)
				}

				if err := yaml.Unmarshal(featureFile, &featureYaml); err != nil {
					fatal(err)
				}
				featureYaml.Path = filepath.Dir(feature)
				features[featureDir] = featureYaml
				steps = append(steps, featureDir)
			}
		}
	}

	sort.Strings(steps)
	steps = append([]string{"flavour"}, steps...)

	if status == "INIT" {
		go cccInitialization()
	}

	// Create gin file.
	f, _ := os.Create("/tmp/gin.log")
	gin.DefaultWriter = io.MultiWriter(f)

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

	type Mfa struct {
		Code string `form:"code" json:"code" xml:"code" binding:"required"`
	}

	api.POST("/mfa", func(c *gin.Context) {
		var json Mfa
		if err := c.ShouldBindJSON(&json); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		file, err := os.Create("/tmp/mfa")
		if err != nil {
			fatal(err)
		}
		if _, err := file.WriteString(json.Code); err != nil {
			fatal(err)
		}
		if err := file.Close(); err != nil {
			fatal(err)
		}

	})

	if err := router.Run(fmt.Sprintf(":%s", port)); err != nil {
		fatal(err)
	}
}
