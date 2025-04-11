package internal

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"os"
	"os/exec"
)

// An MFACode represents an MFA code provided to the respective API endpoint
type MFACode struct {
	Code string `form:"code" json:"code" xml:"code" binding:"required"`
}

// The APIRouter is the main gin router for CCC
type APIRouter struct {
	backend *Backend
}

// NewAPIRouter creates a new API router with the provided backend
func NewAPIRouter(backend *Backend) APIRouter {
	return APIRouter{backend: backend}
}

// GetStatus returns the current CCC status
func (a APIRouter) GetStatus(context *gin.Context) {
	switch context.Request.Header.Get("Accept") {
	case "text/plain":
		context.String(http.StatusOK, a.backend.Status)
	default:
		context.JSON(http.StatusOK, gin.H{
			"status": a.backend.Status,
		})
	}
}

// GetSteps returns the configured CCC steps
func (a APIRouter) GetSteps(context *gin.Context) {
	context.JSON(http.StatusOK, gin.H{
		"steps": a.backend.Steps,
	})
}

// GetCurrentStep returns the step that is installed currently
func (a APIRouter) GetCurrentStep(context *gin.Context) {
	context.JSON(http.StatusOK, gin.H{
		"currentStep": a.backend.CurrentStep,
		"output":      a.backend.StepOutput,
		"title":       a.backend.StepTitle,
		"description": a.backend.StepDescription,
	})
}

// GetFeatures returns the features configured in the CCC backend
func (a APIRouter) GetFeatures(context *gin.Context) {
	switch context.Request.Header.Get("Accept") {
	case "text/plain":
		output := ""
		for feature, featureInfo := range a.backend.Features {
			output += fmt.Sprintf("# %-4s%s\n%s\n\n\n", featureInfo.Descriptor.Icon, featureInfo.Descriptor.Title, featureInfo.Descriptor.Description)
			motdFile := fmt.Sprintf("/home/cloudcontrol/feature-installers/%s/motd.sh", feature)
			if _, err := os.Stat(motdFile); err == nil {
				if motdFileContent, err := exec.Command("bash", motdFile).Output(); err == nil {
					output += string(motdFileContent) + "\n\n"
				}
			}
		}
		context.String(http.StatusOK, output)
	default:
		features := make(map[string]YamlDescriptor)
		for featureName, feature := range a.backend.Features {
			features[featureName] = feature.Descriptor
		}
		context.JSON(http.StatusOK, features)
	}
}

// PostMFA retrieves an MFA code and stores it in the backend
func (a APIRouter) PostMFA(context *gin.Context) {
	var json MFACode
	if err := context.ShouldBindJSON(&json); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	a.backend.SetMFA("/tmp/mfa", json.Code, false)
}

// PostGoogleAuth retrieves a Google MFA code and stores it in the backend
func (a APIRouter) PostGoogleAuth(context *gin.Context) {
	var json MFACode
	if err := context.ShouldBindJSON(&json); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	a.backend.SetMFA("/tmp/gcloud_auth", json.Code, true)
}

// RegisterAPI registers the required API endpoints with gin
func RegisterAPI(backend *Backend, api *gin.RouterGroup) {
	apiRouter := NewAPIRouter(backend)

	api.GET("/status", apiRouter.GetStatus)
	api.GET("/steps", apiRouter.GetSteps)
	api.GET("/steps/current", apiRouter.GetCurrentStep)
	api.GET("/features", apiRouter.GetFeatures)

	api.POST("/mfa", apiRouter.PostMFA)
	api.POST("/googleAuth", apiRouter.PostGoogleAuth)
}
