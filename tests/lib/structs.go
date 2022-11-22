package lib

// data structures used

import (
	"os"
)

// TestBed is used as a configuration for the testrunner.
type TestBed struct {
	// the running flavour
	Flavour string
	// the image to use
	Image string
	// the testbed directory of the flavour
	FlavourTestbed string
	// the image platform to use
	Platform string
	// the goss binary
	Goss os.File
	// the path to the test root
	RootPath string
	// number of seconds goss_wait should wait at most
	MaxWait int
}

// Feature describes a CloudControl feature.
type Feature struct {
	// the name of the feature
	Name string
	// the pathname inside <root>/feature
	PathName string
	// the full path to the feature
	FullPath string
	// the path to the feature inside the CloudControl container
	InsidePathRoot string
}

// TestFailure describes how a feature test failed.
type TestFailure struct {
	// the feature that was tested
	Feature Feature
	// the error returned
	ErrorMessage string
	// how many seconds the test took
	ElapsedSeconds int
}
