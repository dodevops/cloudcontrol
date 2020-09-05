package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"nullprogram.com/x/optparse"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"github.com/dchest/uniuri"
)

var steps = []string{"flavour"}
var currentStep = -1
var stepOutput = ""
var status = "INIT"

func Authentication(password string) gin.HandlerFunc {
	return func(context *gin.Context) {
		if context.GetHeader("Authorization") != password {
			context.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "Unauthorized",
			})
		}
	}
}

func fatal(err error) {
	fmt.Fprintf(os.Stderr, "%s: %s\n", os.Args[0], err)
	os.Exit(1)
}

type ConsoleWriter struct{}

func (ConsoleWriter) Write(p []byte) (n int, err error) {
	stepOutput = string(p)
	return 0, nil
}

func cccInitialization() {

	// Start flavour installer

	currentStep++

	consoleWriter := new(ConsoleWriter)

	cmd := exec.Command("bash", "/home/cloudcontrol/bin/flavourinit.sh")
	cmd.Stderr = consoleWriter
	cmd.Stdout = consoleWriter
	flavourErr := cmd.Wait()

	if flavourErr != nil {
		fatal(flavourErr)
	}

	// Install features

	features, featureGlobErr := filepath.Glob("/home/cloudcontrol/feature-installers/*")

	if featureGlobErr != nil {
		fatal(featureGlobErr)
	}

	for _, featureDir := range features {
		feature := filepath.Base(featureDir)
		for _, step := range steps {
			if step == feature {
				currentStep++

				cmd := exec.Command("bash", fmt.Sprintf("%s/feature.sh", featureDir))
				cmd.Stderr = consoleWriter
				cmd.Stdout = consoleWriter
				featureErr := cmd.Wait()

				if featureErr != nil {
					fatal(featureErr)
				}
			}
		}
	}

	status = "INITIALIZED"
}

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

	var password = uniuri.New()

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

	if status == "INIT" {
		go cccInitialization()
	}

	router := gin.Default()
	router.GET("/", func(context *gin.Context) {
		context.Redirect(http.StatusFound, fmt.Sprintf("/client?passphrase=%s", password))
	})
	router.Static("/client", "./client")
	api := router.Group("/api")
	api.Use(Authentication(password))
	api.GET("/status", func(context *gin.Context) {
		context.JSON(http.StatusOK, gin.H{
			"status": status,
		})
	})
	api.GET("/steps", func(context *gin.Context) {
		context.JSON(http.StatusOK, gin.H{
			"steps": steps,
		})
	})
	api.GET("/steps/current", func(context *gin.Context) {
		context.JSON(http.StatusOK, gin.H{
			"currentStep": currentStep,
			"output": stepOutput,
		})
	})
	serverError := router.Run(fmt.Sprintf(":%s", port))
	if serverError != nil {
		fatal(serverError)
	}
}
