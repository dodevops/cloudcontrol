package internal

import (
	"io"
	"log"
)

// ConsoleWriter used to capture console output
type ConsoleWriter struct {
	backend *Backend
}

var _ io.Writer = ConsoleWriter{}

// NewConsoleWriter Construct a new console writer
func NewConsoleWriter(backend *Backend) ConsoleWriter {
	return ConsoleWriter{
		backend: backend,
	}
}

// Write the console output of the current step to the stepOutput variable
func (c ConsoleWriter) Write(p []byte) (n int, err error) {
	newOutput := string(p)
	c.backend.LogStepOutput(newOutput)
	log.Print(newOutput)
	return len(p), nil
}
