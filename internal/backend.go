package internal

import (
	"fmt"
	"github.com/sirupsen/logrus"
	"gopkg.in/yaml.v3"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Feature describes a feature in the filesystem
type Feature struct {
	descriptor YamlDescriptor
	path       string
}

// The Backend handles the feature installation and monitoring
type Backend struct {
	// Steps stores all installation steps that need to be carried out
	Steps []string

	// Features hold a map of all features
	Features map[string]Feature

	// The CurrentStep in the installation process
	CurrentStep int

	// StepOutput holds the console output of the current step
	StepOutput string

	// Status holds the overall CloudControl status
	Status string

	// StepTitle is the title of the current step that is installed
	StepTitle string

	// StepDescription is the description of the current step that is installed
	StepDescription string
}

// NewBackend constructs a new backend
func NewBackend() Backend {
	status := "INIT"
	if _, err := os.Stat("/home/cloudcontrol/initialization.done"); !os.IsNotExist(err) {
		status = "INITIALIZED"
	}
	return Backend{
		Status:   status,
		Features: make(map[string]Feature),
	}
}

// Simple handler to handle fatal errors
func (backend *Backend) fatal(err error) {
	logrus.Error(err)
	if _, exists := os.LookupEnv("CONTINUE_ON_ERROR"); !exists {
		os.Exit(1)
	}
}

// initialization returns a func for a go function to install CloudControl flavour and all features
func (backend *Backend) initialization() func() {
	return func() {
		backend.CurrentStep++

		consoleWriter := NewConsoleWriter(backend)

		logrus.Debug("Setting bash as default shell")
		file, err := os.Create("/home/cloudcontrol/.shell")
		if err != nil {
			backend.fatal(err)
		}
		if _, err := file.WriteString("bash"); err != nil {
			backend.fatal(err)
		}
		if err := file.Close(); err != nil {
			backend.fatal(err)
		}

		logrus.Info("Starting flavour initialization")

		var args []string

		if value, exists := os.LookupEnv("DEBUG_FLAVOUR"); exists && value == "yes" {
			logrus.Debug("Enabling flavour debug")
			args = append(args, "-x")
		}

		args = append(args, "/home/cloudcontrol/bin/flavourinit.sh")

		cmd := exec.Command("bash", args...)
		cmd.Stderr = consoleWriter
		cmd.Stdout = consoleWriter
		if err := cmd.Start(); err != nil {
			backend.fatal(err)
		}

		if err := cmd.Wait(); err != nil {
			backend.fatal(err)
		}

		logrus.Debug("Flavour initialization finished")

		for _, step := range backend.Steps[1:] {
			backend.CurrentStep++

			backend.StepTitle = backend.Features[step].descriptor.Title
			logrus.Infof("Installing feature %s", backend.StepTitle)

			backend.StepDescription = backend.Features[step].descriptor.Description

			var args []string

			if value, exists := os.LookupEnv(fmt.Sprintf("DEBUG_%s", step)); exists && value == "yes" {
				logrus.Debugf("Enabling feature debug for feature %s", step)
				args = append(args, "-x")
			}

			installationFile := fmt.Sprintf("%s/install.sh", backend.Features[step].path)
			logrus.Debugf("Running %s", installationFile)
			args = append(args, installationFile)

			cmd := exec.Command("bash", args...)
			cmd.Stderr = consoleWriter
			cmd.Stdout = consoleWriter
			if err := cmd.Start(); err != nil {
				backend.fatal(err)
			}

			if err := cmd.Wait(); err != nil {
				backend.fatal(err)
			}

			if backend.Features[step].descriptor.Deprecation != "" {
				logrus.Warnf("Feature %s is deprecated. Storing deprecation notice.", step)
				if f, err := os.OpenFile("/home/cloudcontrol/.deprecation", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644); err != nil {
					backend.fatal(err)
				} else {
					if _, err := f.WriteString(fmt.Sprintf("%s\n\n%s\n\n---", step, backend.Features[step].descriptor.Deprecation)); err != nil {
						backend.fatal(err)
					}
					if err := f.Close(); err != nil {
						backend.fatal(err)
					}
				}
			}
		}

		file, err = os.Create("/home/cloudcontrol/initialization.done")

		if err != nil {
			backend.fatal(err)
		}

		_ = file.Close()

		logrus.Info("Finished initialization")
		logrus.Info("Please run the following to enter CloudControl")
		logrus.Info("docker-compose exec cli /usr/local/bin/cloudcontrol run")

		backend.Status = "INITIALIZED"
	}
}

// Run starts the backend process
func (backend *Backend) Run() {
	backend.readConfiguration()

	if backend.Status == "INIT" {
		logrus.Info("Starting initialization")
		go backend.initialization()()
	}
}

// LogStepOutput stores the output of the current step from the ConsoleWriter
func (backend *Backend) LogStepOutput(output string) {
	logrus.Tracef("Storing step output %s", output)
	backend.StepOutput += output
}

// SetMFA stores an MFA code from the API
func (backend *Backend) SetMFA(mfaFile string, code string, addNewline bool) {
	logrus.Debugf("Storing MFA code to %s", mfaFile)
	file, err := os.Create(mfaFile)
	if err != nil {
		backend.fatal(err)
	}
	if addNewline {
		code = fmt.Sprintf("%s\n", code)
	}
	if _, err := file.WriteString(code); err != nil {
		backend.fatal(err)
	}
	if err := file.Close(); err != nil {
		backend.fatal(err)
	}
}

// readConfiguration reads in the configuration of environment variables and configures the backend
func (backend *Backend) readConfiguration() {
	logrus.Debug("Reading configuration")

	logrus.Debug("Interpreting FEATURES variable")
	if value, exists := os.LookupEnv("FEATURES"); exists {
		for _, configuredFeature := range strings.Split(value, " ") {
			var configuredVersion = ""
			if strings.Contains(configuredFeature, ":") {
				configuredVersion = strings.Split(configuredFeature, ":")[1]
				configuredFeature = strings.Split(configuredFeature, ":")[0]
			}
			logrus.Tracef("Enabling feature using USE_%s=yes", configuredFeature)
			_ = os.Setenv(fmt.Sprintf("USE_%s", configuredFeature), "yes")
			if configuredVersion != "" {
				logrus.Tracef("Setting %s_VERSION to %s", strings.ToUpper(configuredFeature), configuredVersion)
				_ = os.Setenv(fmt.Sprintf("%s_VERSION", strings.ToUpper(configuredFeature)), configuredVersion)
			}
		}
	}

	// A regexp extracting the feature name from the path
	featureIdentifier := regexp.MustCompile("/home/cloudcontrol/feature-installers/([^/]+)/feature.yaml")

	// A regexp cutting of characters used for sorting special features (like shells) higher up
	sortingRegexp := regexp.MustCompile("_(.+)")

	if featureFiles, err := filepath.Glob("/home/cloudcontrol/feature-installers/*/feature.yaml"); err != nil {
		backend.fatal(err)
	} else {
		for _, feature := range featureFiles {
			if featureIdentifier.MatchString(feature) {
				matches := featureIdentifier.FindStringSubmatch(feature)
				featureName := matches[1]
				featureDir := matches[1]

				if sortingRegexp.MatchString(featureName) {
					featureName = sortingRegexp.FindStringSubmatch(featureName)[1]
				}

				logrus.Debugf("Found feature %s in path %s", featureName, feature)

				if value, exists := os.LookupEnv(fmt.Sprintf("USE_%s", featureName)); exists && value == "yes" {
					logrus.Debugf("Activating feature %s", featureName)
					var featureYaml YamlDescriptor
					if featureFile, err := os.ReadFile(feature); err != nil {
						backend.fatal(err)
					} else {
						if err := yaml.Unmarshal(featureFile, &featureYaml); err != nil {
							backend.fatal(err)
						}
						backend.Features[featureDir] = Feature{
							descriptor: featureYaml,
							path:       filepath.Dir(feature),
						}
						logrus.Debugf("Adding feature %s: %v", featureDir, backend.Features[featureDir])
						backend.Steps = append(backend.Steps, featureDir)
					}
				} else {
					logrus.Debug("Feature is not activated.")
				}
			}
		}
	}

	sort.Strings(backend.Steps)

	// Adding flavour to the beginning of all steps
	backend.Steps = append([]string{"flavour"}, backend.Steps...)
}
