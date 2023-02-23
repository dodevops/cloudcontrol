package container

import "fmt"

type ImageNotFoundError struct {
	image string
}

func (e ImageNotFoundError) Error() string {
	return fmt.Sprintf("Image %s not found locally or remote.", e.image)
}

type RunCommandError struct {
	// the return code
	ReturnCode int
	// stdout and stderr of the command
	CommandOutput string
	// stdout and stderr of the container
	ContainerOutput string
	// wrapped error if other non-command error happened
	Err error
}

func (e *RunCommandError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("Error executing command in container: %s", e.Err)
	} else {
		return fmt.Sprintf("Error running command (%d):\n%s\n\n%s", e.ReturnCode, e.CommandOutput, e.ContainerOutput)
	}
}

type Bind struct {
	Source string
	Target string
}

type AdapterBase interface {
	// FindImage tries to find a local or remote image or returns an error. It expects the image name and the
	// platform as its parameters.
	FindImage(string, string) error
	// StartContainer starts a new container.
	// The parameters are the image name, a list of environment variables (KEY=VALUE), a list of container
	// bind mount configurations and the platform string.
	// It returns the id of the container.
	StartContainer(string, []string, []Bind, string) (string, error)
	// StopContainer stops the given container id
	StopContainer(string) error
	// RunCommand runs the given command (second parameter) in the container identified by the specified containerid
	// (first parameter). Returns the stdout on success or an error with all details on failure
	RunCommand(string, []string) (string, error)
}
