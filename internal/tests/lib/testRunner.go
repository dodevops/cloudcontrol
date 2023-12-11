package lib

import (
	"bytes"
	"cloudcontroltools/internal/tests/lib/container"
	"errors"
	"fmt"
	"github.com/MakeNowJust/heredoc"
	"github.com/docker/docker/pkg/fileutils"
	cp "github.com/otiai10/copy"
	"github.com/sirupsen/logrus"
	"github.com/thoas/go-funk"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

// main test runner code

const GossWait = `
file:
    /home/cloudcontrol/initialization.done:
        exists: true
`

// TestFeature tests a specific feature.
func TestFeature(feature Feature, testBed TestBed, containerAdapter container.AdapterBase, cleanup bool) error {
	var testSuites []string
	if testSuitesGlob, err := filepath.Glob(filepath.Join(feature.FullPath, "goss*")); err != nil {
		return fmt.Errorf("error searching for testsuites in %s: %w", feature.FullPath, err)
	} else {
		testSuites = funk.Map(testSuitesGlob, func(entry string) string {
			return filepath.Join(testBed.RootPath, entry)
		}).([]string)
	}

	newLineRegExp := regexp.MustCompile("\r?\n")
	emptyLineRegExp := regexp.MustCompile(`^\s*$`)

	for _, testSuite := range testSuites {
		logrus.Debugf("Testing suite at %s", testSuite)

		// using an anonymous function to make sure the container and temp directory are
		// removed when the function exists
		containerErr := func() error {
			var testDir string

			var hasProblems = false
			var willFail = false
			var failPattern = ".*"
			var mightFail = false
			var mightFailDescription = ""

			if _, err := os.Stat(filepath.Join(testSuite, ".will-fail")); err == nil {
				willFail = true
				logrus.Debug("Found .will-fail file, test will fail.")
				if tmp, err := os.ReadFile(filepath.Join(testSuite, ".will-fail")); err != nil {
					return fmt.Errorf("loading the contents of %s failed: %w", filepath.Join(testSuite, ".will-fail"), err)
				} else {
					failPattern = strings.TrimSuffix(string(tmp), "\n")
				}
			}

			if _, err := os.Stat(filepath.Join(testSuite, ".might-fail")); err == nil {
				mightFail = true
				logrus.Debug("Found .might-fail file, test might fail.")
				if tmp, err := os.ReadFile(filepath.Join(testSuite, ".might-fail")); err != nil {
					return fmt.Errorf("loading the contents of %s failed: %w", filepath.Join(testSuite, ".might-fail"), err)
				} else {
					mightFailDescription = strings.TrimSuffix(string(tmp), "\n")
				}
			}

			if tempReturn, err := os.MkdirTemp("", "cctest-*"); err != nil {
				return fmt.Errorf("error creating temporary directory for testbed: %w", err)
			} else {
				testDir = tempReturn
			}
			if err := os.Chmod(testDir, 0777); err != nil {
				return fmt.Errorf("error chmodding temporary directory to 0777: %w", err)
			}
			defer func() {
				if err := os.RemoveAll(testDir); err != nil {
					panic(fmt.Errorf("can not remove temporary directory: %w", err))
				}
			}()
			logrus.Debugf("Preparing test suite in %s", testDir)

			logrus.Debugf("Copying goss from %s", testBed.Goss.Name())
			if _, err := fileutils.CopyFile(testBed.Goss.Name(), filepath.Join(testDir, "goss")); err != nil {
				return fmt.Errorf("can not copy goss executable: %w", err)
			}
			if err := os.Chmod(filepath.Join(testDir, "goss"), 0755); err != nil {
				return fmt.Errorf("can not make goss executable: %w", err)
			}

			logrus.Debugf("Copying goss.yaml from %s", testSuite)
			if _, err := fileutils.CopyFile(
				filepath.Join(testSuite, "goss.yaml"),
				filepath.Join(testDir, "goss.yaml"),
			); err != nil && !willFail && !mightFail {
				return fmt.Errorf("can not copy goss.yaml: %w", err)
			}

			logrus.Debugf("Creating goss_wait.yaml")
			if err := os.WriteFile(
				filepath.Join(testDir, "goss_wait.yaml"),
				[]byte(GossWait),
				0444,
			); err != nil {
				return fmt.Errorf("can not write goss.yaml: %w", err)
			}

			envs := []string{
				fmt.Sprintf("FLAVOUR=%s", testBed.Flavour),
				fmt.Sprintf("USE_%s=yes", feature.Name),
			}

			for _, envFile := range []string{
				filepath.Join(testSuite, ".env"),
				filepath.Join(testSuite, fmt.Sprintf(".env.%s", testBed.Flavour)),
				filepath.Join(testBed.FlavourTestbed, ".env"),
			} {
				if _, err := os.Stat(envFile); err == nil {
					if envContent, err := os.ReadFile(envFile); err != nil {
						return fmt.Errorf("can not read env file %s: %w", envFile, err)
					} else {
						envs = append(envs, newLineRegExp.Split(string(envContent), -1)...)
					}
				}
			}

			binds := []container.Bind{
				{
					Source: testDir,
					Target: "/goss",
				},
				{
					Source: testSuite,
					Target: "/goss-sup",
				},
				{
					Source: testBed.FlavourTestbed,
					Target: "/flavour",
				},
			}

			var containerId string

			if startedContainerId, err := containerAdapter.StartContainer(
				testBed.Image,
				funk.FilterString(envs, func(value string) bool {
					return !emptyLineRegExp.Match([]byte(value))
				}),
				binds,
				testBed.Platform,
			); err != nil {
				hasProblems = true
				return fmt.Errorf("error starting container: %w", err)
			} else {
				logrus.Debugf("Started container %s", startedContainerId)
				containerId = startedContainerId
			}

			// deferring the removal of the container
			defer func() {
				if cleanup || !hasProblems {
					logrus.Debugf("Stopping container %s", containerId)
					if err := containerAdapter.StopContainer(containerId); err != nil {
						panic(fmt.Errorf("can not stop goss container: %w", err))
					} else {
						logrus.Debugf("Stopped container with id %s", containerId)
					}
				} else {
					logrus.Debugf("Not stopping container because cleanup was disabled and problems exist.")
				}
			}()

			logrus.Debug("Waiting for goss_wait")
			if waitOutput, err := containerAdapter.RunCommand(
				containerId,
				[]string{
					"sh",
					"-c",
					fmt.Sprintf("/goss/goss -g /goss/goss_wait.yaml validate -r %ds -s 1s", testBed.MaxWait),
				},
			); err != nil {
				var runCommandError *container.RunCommandError
				switch {
				case errors.As(err, &runCommandError):
					if mightFail {
						logrus.Warnf("Waiting for Goss in %s failed with %s, but it might fail because: \n%s", testSuite, err.Error(), mightFailDescription)
					} else if !willFail {
						hasProblems = true
						return &GossError{
							returnCode: runCommandError.ReturnCode,
							logOutput: fmt.Sprintf(
								"Command output:\n%s\n\nContainer output:\n%s\n%s",
								runCommandError.CommandOutput,
								runCommandError.ContainerOutput,
								runCommandError.Error(),
							),
						}
					} else if found, err := regexp.Match(
						failPattern,
						[]byte(fmt.Sprintf("%s%s", runCommandError.CommandOutput, runCommandError.ContainerOutput)),
					); err != nil || !found {
						hasProblems = true
						return &GossError{
							returnCode: 0,
							logOutput: fmt.Sprintf(
								"Container failed but the pattern %s was not found in the logs:\n%s\n\n%s\n%s",
								failPattern,
								runCommandError.CommandOutput,
								runCommandError.ContainerOutput,
								runCommandError.Error(),
							),
						}
					}
				default:
					if !willFail && !mightFail {
						return err
					}
				}
			} else if err == nil && willFail {
				hasProblems = true
				return &GossError{
					returnCode: 0,
					logOutput:  fmt.Sprintf("Container was created successfully when it shouldn't have been: %s", waitOutput),
				}
			}

			logrus.Debug("Running goss")
			if _, err := containerAdapter.RunCommand(
				containerId,
				[]string{
					"/goss/goss",
					"-g",
					"/goss/goss.yaml",
					"validate",
					"--color",
					"--format",
					"documentation",
				},
			); err != nil {
				if mightFail {
					logrus.Warnf("Testing %s failed with %s, but it might fail because: \n%s", testSuite, err.Error(), mightFailDescription)
				} else if !willFail {
					hasProblems = true
					var runCommandError *container.RunCommandError
					switch {
					case errors.As(err, &runCommandError):
						return &GossError{
							returnCode: runCommandError.ReturnCode,
							logOutput: fmt.Sprintf(
								"Command output:\n%s\n\nContainer output:\n%s",
								runCommandError.CommandOutput,
								runCommandError.ContainerOutput,
							),
						}
					default:
						if !willFail && !mightFail {
							return err
						}
					}
				}
			} else if err == nil && willFail {
				hasProblems = true
				return &GossError{
					returnCode: 0,
					logOutput:  "Container was created successfully when it shouldn't have been.",
				}
			}
			return nil
		}()
		if containerErr != nil {
			return containerErr
		}
	}
	return nil
}

// IntegrationTests tests all features together.
func IntegrationTests(features []Feature, testBed TestBed, containerAdapter container.AdapterBase) error {
	var testDir string

	if tempReturn, err := os.MkdirTemp("", "cctest-*"); err != nil {
		return fmt.Errorf("error creating temporary directory for testbed: %w", err)
	} else {
		testDir = tempReturn
	}
	if err := os.Chmod(testDir, 0777); err != nil {
		return fmt.Errorf("error chmodding temporary directory to 0777: %w", err)
	}
	defer func() {
		if err := os.RemoveAll(testDir); err != nil {
			panic(fmt.Errorf("can not remove temporary directory: %w", err))
		}
	}()
	logrus.Debugf("Preparing test suite in %s", testDir)

	if err := os.Mkdir(filepath.Join(testDir, "sup"), 0777); err != nil {
		return fmt.Errorf("error creating supplemental directory: %w", err)
	}

	newLineRegExp := regexp.MustCompile("\r?\n")
	emptyLineRegExp := regexp.MustCompile(`^\s*$`)

	var testSuiteInsidePaths []string

	envs := []string{
		fmt.Sprintf("FLAVOUR=%s", testBed.Flavour),
	}

	for _, feature := range features {
		if testSuites, err := filepath.Glob(filepath.Join(feature.FullPath, "goss*")); err != nil {
			return fmt.Errorf("error searching for testsuites in %s: %w", feature.FullPath, err)
		} else {
			for _, testSuite := range testSuites {
				if _, err := os.Stat(filepath.Join(testSuite, ".ignore-integration")); err == nil {
					logrus.Infof("Test %s for feature %s is ignored for integration testing", filepath.Base(testSuite), feature.Name)
					continue
				}
				if _, err := os.Stat(filepath.Join(testSuite, ".will-fail")); err == nil {
					logrus.Infof(
						"Test %s for feature %s is ignored for integration testing, because it will fail",
						filepath.Base(testSuite),
						feature.Name,
					)
					continue
				}
				if _, err := os.Stat(filepath.Join(testSuite, ".might-fail")); err == nil {
					logrus.Infof(
						"Test %s for feature %s is ignored for integration testing, because it might fail",
						filepath.Base(testSuite),
						feature.Name,
					)
					continue
				}
				envs = append(envs, fmt.Sprintf("USE_%s=yes", feature.Name))

				for _, envFile := range []string{
					filepath.Join(testSuite, ".env"),
					filepath.Join(testSuite, fmt.Sprintf(".env.%s", testBed.Flavour)),
					filepath.Join(testBed.FlavourTestbed, ".env"),
				} {
					if _, err := os.Stat(envFile); err == nil {
						if envContent, err := os.ReadFile(envFile); err != nil {
							return fmt.Errorf("can not read env file %s: %w", envFile, err)
						} else {
							envs = append(envs, newLineRegExp.Split(string(envContent), -1)...)
						}
					}
				}

				if err := cp.Copy(testSuite, filepath.Join(testDir, "sup"), cp.Options{
					Sync: true,
				}); err != nil {
					return fmt.Errorf("can not copy supplemental data for test of feature %s: %w", feature.Name, err)
				}

				testSuiteInsidePaths = append(
					testSuiteInsidePaths,
					fmt.Sprintf("%s/%s/goss.yaml", feature.InsidePathRoot, filepath.Base(testSuite)),
				)
			}
		}
	}

	logrus.Debugf("Copying goss from %s", testBed.Goss.Name())
	if _, err := fileutils.CopyFile(testBed.Goss.Name(), filepath.Join(testDir, "goss")); err != nil {
		return fmt.Errorf("can not copy goss executable: %w", err)
	}
	if err := os.Chmod(filepath.Join(testDir, "goss"), 0755); err != nil {
		return fmt.Errorf("can not make goss executable: %w", err)
	}

	logrus.Debug("Creating goss.yaml")
	gossYAMLTemplate := template.New("goss.yaml")
	if _, err := gossYAMLTemplate.Parse(heredoc.Doc(`
		gossfile:
		{{- range .Features }}
            {{ . }}: {}
		{{ end }}
	`)); err != nil {
		return fmt.Errorf("can not create goss.yaml template: %w", err)
	}
	var gossYAMLContent bytes.Buffer
	type gossYAMLContentData struct {
		Features []string
	}
	if err := gossYAMLTemplate.Execute(&gossYAMLContent, gossYAMLContentData{
		Features: testSuiteInsidePaths,
	}); err != nil {
		return fmt.Errorf("can not execute goss.yaml template: %w", err)
	}
	if err := os.WriteFile(
		filepath.Join(testDir, "goss.yaml"),
		gossYAMLContent.Bytes(),
		0444,
	); err != nil {
		return fmt.Errorf("can not create goss.yaml: %w", err)
	}

	logrus.Debugf("Creating goss_wait.yaml")
	if err := os.WriteFile(
		filepath.Join(testDir, "goss_wait.yaml"),
		[]byte(GossWait),
		0444,
	); err != nil {
		return fmt.Errorf("can not write goss.yaml: %w", err)
	}

	binds := []container.Bind{
		{
			Source: testDir,
			Target: "/goss",
		},
		{
			Source: filepath.Join(testDir, "sup"),
			Target: "/goss-sup",
		},
		{
			Source: testBed.FlavourTestbed,
			Target: "/flavour",
		},
	}

	var containerId string

	if startedContainerId, err := containerAdapter.StartContainer(
		testBed.Image,
		funk.FilterString(envs, func(value string) bool {
			return !emptyLineRegExp.Match([]byte(value))
		}),
		binds,
		testBed.Platform,
	); err != nil {
		return fmt.Errorf("error starting container: %w", err)
	} else {
		containerId = startedContainerId
	}

	// deferring the removal of the container
	defer func() {
		if err := containerAdapter.StopContainer(containerId); err != nil {
			panic(fmt.Errorf("can not stop goss container: %w", err))
		}
	}()

	logrus.Debug("Waiting for goss_wait")
	if _, err := containerAdapter.RunCommand(
		containerId,
		[]string{
			"sh",
			"-c",
			fmt.Sprintf("/goss/goss -g /goss/goss_wait.yaml validate -r %ds -s 1s", testBed.MaxWait),
		},
	); err != nil {
		var runCommandError *container.RunCommandError
		switch {
		case errors.As(err, &runCommandError):
			return &GossError{
				returnCode: runCommandError.ReturnCode,
				logOutput: fmt.Sprintf(
					"Command output:\n%s\n\nContainer output:\n%s",
					runCommandError.CommandOutput,
					runCommandError.ContainerOutput,
				),
			}
		default:
			return err
		}
	}

	logrus.Debug("Running goss")
	if _, err := containerAdapter.RunCommand(
		containerId,
		[]string{
			"/goss/goss",
			"-g",
			"/goss/goss.yaml",
			"validate",
			"--color",
			"--format",
			"documentation",
		},
	); err != nil {
		var runCommandError *container.RunCommandError
		switch {
		case errors.As(err, &runCommandError):
			return &GossError{
				returnCode: runCommandError.ReturnCode,
				logOutput: fmt.Sprintf(
					"Command output:\n%s\n\nContainer output:\n%s",
					runCommandError.CommandOutput,
					runCommandError.ContainerOutput,
				),
			}
		default:
			return err
		}
	}
	return nil
}
