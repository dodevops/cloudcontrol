// CloudControlCenter - CloudControl Installation manager
package main

import (
	"cloudcontroltools/internal"
	"fmt"
	"github.com/akamensky/argparse"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"net/http"
	"os"
)

func main() {
	parser := argparse.NewParser("ccc", "CloudControlCenter")
	port := parser.Int("P", "üprt", &argparse.Options{Help: "Port to run the CCC apiserver on", Default: 8080})
	loglevel := parser.String("l", "loglevel", &argparse.Options{Help: "Loglevel to use", Default: "info"})

	err := parser.Parse(os.Args)
	if err != nil {
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}

	if l, err := logrus.ParseLevel(*loglevel); err != nil {
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	} else {
		logrus.SetLevel(l)
	}

	logrus.Info("Starting CloudControlCenter")

	logrus.Debug("Starting backend")
	backend := internal.NewBackend()
	backend.Run()

	logrus.Debug("Creating API server")
	router := gin.Default()

	router.GET("/", func(context *gin.Context) {
		context.Redirect(http.StatusFound, "/client")
	})

	router.Static("/client", "./client")

	api := router.Group("/api")
	internal.RegisterAPI(&backend, api)

	logrus.Infof("Starting server on port %d", *port)
	if err := router.Run(fmt.Sprintf(":%d", *port)); err != nil {
		fmt.Print(parser.Usage(err))
		os.Exit(1)
	}
}
