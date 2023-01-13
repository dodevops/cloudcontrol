// CloudControl feature test runnner
// Using Goss https://github.com/goss-org/goss

package main

import (
	"bytes"
	"fmt"
	"github.com/MakeNowJust/heredoc"
	"github.com/akamensky/argparse"
	"github.com/sirupsen/logrus"
	"github.com/thoas/go-funk"
	"math"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"tests/lib"
	"tests/lib/container"
	"text/template"
	"time"
)

// test root path (exepected one level above the test binary).
var rootPath string

// cache of flavours.
var flavours []string

// cache of features.
var features []lib.Feature

// Load flavours from the flavour directory.
func getFlavours() []string {
	if flavours == nil {
		flavoursGlob, err := filepath.Glob(filepath.Join(rootPath, "flavour", "*"))

		if err != nil {
			logrus.Warn("Error loading flavours: ", err)
			return []string{}
		}

		correctPathRegexp := regexp.MustCompile("^[^.]")

		flavours = funk.FilterString(
			funk.Map(
				flavoursGlob,
				func(flavourDir string) string {
					return filepath.Base(flavourDir)
				},
			).([]string),
			func(value string) bool {
				return correctPathRegexp.Match([]byte(value))
			},
		)
	}
	return flavours
}

// Load features from the feature directory and transform them.
func getFeatures() []lib.Feature {
	if features == nil {
		featuresGlob, err := filepath.Glob(filepath.Join(rootPath, "feature", "*"))

		if err != nil {
			logrus.Warn("Error loading flavours: ", err)
			return []lib.Feature{}
		}

		correctPathRegexp := regexp.MustCompile("^[^.]")
		sanitizeNameRegexp := regexp.MustCompile("^_?(.+)")

		features = funk.Map(
			funk.FilterString(
				featuresGlob,
				func(value string) bool {
					if correctPathRegexp.Match([]byte(filepath.Dir(value))) {
						if testDirs, err := filepath.Glob(filepath.Join(value, "goss*")); err != nil {
							panic(fmt.Sprintf("Can not look for test suite directories: %s", err.Error()))
						} else {
							if len(testDirs) == 0 {
								return false
							}
							for _, dir := range testDirs {
								if gossYaml, err := filepath.Glob(filepath.Join(dir, "goss.yaml")); err != nil {
									panic(fmt.Sprintf("Can not look for goss.yaml in %s: %s", dir, err))
								} else {
									return len(gossYaml) > 0
								}
							}
							return false
						}
					}
					return false
				},
			),
			func(featureDir string) lib.Feature {
				return lib.Feature{
					Name:           sanitizeNameRegexp.FindStringSubmatch(filepath.Base(featureDir))[1],
					PathName:       filepath.Dir(featureDir),
					FullPath:       featureDir,
					InsidePathRoot: fmt.Sprintf("/home/cloudcontrol/feature-installers/%s", filepath.Base(featureDir)),
				}
			},
		).([]lib.Feature)
	}
	return features
}

func main() {
	if ex, err := os.Executable(); err == nil {
		rootPath = filepath.Join(filepath.Dir(ex), "..")
	} else {
		panic(err)
	}

	parser := argparse.NewParser("test-features", "Test CloudControl features")
	flavour := parser.String("f", "flavour", &argparse.Options{Required: true, Help: "Flavour to test"})
	image := parser.String("i", "image", &argparse.Options{Required: true, Help: "Image to test"})
	platform := parser.String(
		"p",
		"platform",
		&argparse.Options{Required: true, Help: "Platform (os/arch(/variant)) to use"},
	)
	flavourTestbed := parser.String("t", "testbed", &argparse.Options{
		Required: true,
		Help:     "Path with flavour supplemental files",
	})
	goss := parser.File("g", "goss", os.O_RDONLY, 0755, &argparse.Options{Required: true, Help: "Path to the goss binary"})
	includeFeatures := parser.List("n", "include", &argparse.Options{Help: "Only include these features when testing"})
	excludeFeatures := parser.List("e", "exclude", &argparse.Options{Help: "Exclude these features when testing"})
	skipIntegrationTest := parser.Flag("s", "skip-integration", &argparse.Options{
		Help:    "Skip integration test at the end",
		Default: false,
	})
	maxWait := parser.Int("w", "wait", &argparse.Options{
		Help:    "Maximum number of seconds goss_wait should wait",
		Default: 240,
	})
	logLevel := parser.String("l", "loglevel", &argparse.Options{
		Help:    "Loglevel to use",
		Default: "error",
	})

	err := parser.Parse(os.Args)
	if err != nil {
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	if loggerLevel, err := logrus.ParseLevel(*logLevel); err != nil {
		logrus.Errorf("%s is not a valid log level", *logLevel)
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	} else {
		logrus.SetLevel(loggerLevel)
	}

	logrus.SetFormatter(&logrus.TextFormatter{
		DisableColors: false,
		FullTimestamp: true,
	})

	if !funk.Contains(getFlavours(), *flavour) {
		logrus.Errorf("%s is not a valid flavour", *flavour)
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	stat, err := os.Stat(*flavourTestbed)

	if err != nil {
		logrus.Errorf("Can not get information about %s", *flavourTestbed)
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	if !stat.IsDir() {
		logrus.Errorf("%s has to point to a directory", *flavourTestbed)
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	containerAdapter := container.DockerAdapter{}

	if err := containerAdapter.FindImage(*image, *platform); err != nil {
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	for _, includeFeature := range *includeFeatures {
		if !funk.Contains(getFeatures(), func(feature lib.Feature) bool {
			return feature.Name == includeFeature
		}) {
			logrus.Errorf("%s is not a known feature", includeFeature)
			fmt.Print(parser.Usage(err))
			os.Exit(1)
		}
	}

	for _, excludeFeature := range *excludeFeatures {
		if !funk.Contains(getFeatures(), func(feature lib.Feature) bool {
			return feature.Name == excludeFeature
		}) {
			logrus.Errorf("%s is not a known feature", excludeFeature)
			fmt.Print(parser.Usage(err))
			os.Exit(1)
		}
	}

	featuresToTest := funk.Filter(
		funk.Filter(
			getFeatures(),
			func(feature lib.Feature) bool {
				return len(*includeFeatures) == 0 || funk.Contains(*includeFeatures, feature.Name)
			},
		).([]lib.Feature),
		func(feature lib.Feature) bool {
			return !funk.Contains(*excludeFeatures, feature.Name)
		},
	).([]lib.Feature)

	sort.Slice(featuresToTest, func(i, j int) bool {
		return featuresToTest[i].Name < featuresToTest[j].Name
	})

	var featuresWithFailures []lib.TestFailure

	testBed := lib.TestBed{
		Flavour:        *flavour,
		Image:          *image,
		FlavourTestbed: *flavourTestbed,
		Goss:           *goss,
		Platform:       *platform,
		MaxWait:        *maxWait,
		RootPath:       rootPath,
	}

	var timer = time.Now()

	for _, feature := range featuresToTest {
		var featureTimer = time.Now()
		if err := lib.TestFeature(feature, testBed, containerAdapter); err != nil {
			logrus.Warnf(
				"❌  %s (%s) ⏱  %ds :\n\n%s\n",
				feature.Name,
				feature.FullPath,
				int(math.Round(time.Since(featureTimer).Seconds())),
				err,
			)
			featuresWithFailures = append(featuresWithFailures, lib.TestFailure{
				Feature:        feature,
				ErrorMessage:   err.Error(),
				ElapsedSeconds: int(math.Round(time.Since(featureTimer).Seconds())),
			})
		} else {
			logrus.Infof(
				"✅  %s (%s) ⏱  %ds",
				feature.Name,
				feature.FullPath,
				int(math.Round(time.Since(featureTimer).Seconds())),
			)
		}
	}

	if len(featuresWithFailures) > 0 {
		failureTemplate := template.New("testFailures")
		if _, err := failureTemplate.Parse(heredoc.Doc(`
			❌  The following tests didn't succeed (⏱  {{ .Timer }}s):
			{{ range .Tests }}
			* {{ .Feature.Name }} ({{ .Feature.FullPath }}) (⏱ {{ .ElapsedSeconds }}s)
			{{- end }}

			Not running integration suite.

		`)); err != nil {
			panic(fmt.Sprintf("Can not parse failure template: %s", err.Error()))
		}

		type templateData struct {
			Timer int
			Tests []lib.TestFailure
		}

		var templateOutput bytes.Buffer
		if err := failureTemplate.Execute(&templateOutput, templateData{
			Tests: featuresWithFailures,
			Timer: int(math.Round(time.Since(timer).Seconds())),
		}); err != nil {
			panic(fmt.Sprintf("Can not run failure template: %s", err.Error()))
		}

		logrus.Error(templateOutput.String())
	} else if !*skipIntegrationTest {
		logrus.Debugf("Running integration tests")
		var integrationTimer = time.Now()
		if err := lib.IntegrationTests(featuresToTest, testBed, containerAdapter); err != nil {
			logrus.Errorf(
				"❌  integration suite ⏱  %ds :\n\n%s\n",
				int(math.Round(time.Since(integrationTimer).Seconds())),
				err,
			)
			os.Exit(1)
		} else {
			logrus.Infof(
				"✅  integration suite ⏱  %ds",
				int(math.Round(time.Since(integrationTimer).Seconds())),
			)
		}
	}

	logrus.Infof("⏱  Finished running tests in %ds", int(math.Round(time.Since(timer).Seconds())))
}
