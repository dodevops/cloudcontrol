package lib

// code for static errors.

import "fmt"

// GossError is returned when goss has returned an error.
type GossError struct {
	// the goss return code
	returnCode int
	// the log output
	logOutput string
}

func (e *GossError) Error() string {
	return fmt.Sprintf("goss returned an error (%d): %s", e.returnCode, e.logOutput)
}

// GossWaitError is returned when goss has returned an error.
type GossWaitError struct {
	// the log output
	logOutput string
}

func (e *GossWaitError) Error() string {
	return fmt.Sprintf("goss wait never returned: %s", e.logOutput)
}
