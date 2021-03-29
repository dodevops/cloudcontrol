# CloudControl host script

## Introduction

This is a ncurses based application that allows quick
switching between multiple CloudControl configurations,
reinit them or switch to the CCC ui.

## Prerequisites

The script docker-compose, usual shell commands 
(like find, sed, etc.) and the dialog package.

On Linux distributions, install dialog using your distribution's
package manager.

On macOS, use e.g. [brew](https://brew.sh) to install 
dialog using:

    brew install dialog

On Windows, using WSL2 is recommended and install the dialog
package using the package manager of the selected Linux
distribution for WSL.

Additionally, the script expects a directory
structure like this:

* CloudControl root
  * firstcloudcontrolcontext
    * docker-compose.yaml
    * init.sh
  * secondcloudcontrolcontext
    * docker-compose.yaml
    * init.sh

## Usage

Copy the file into a path that is in your local PATH and
set the correct CloudControl root path in line 4. (The default
is ~/Documents/cloud) 

Afterwards simply run `cloudcontrol` to show the UI.
