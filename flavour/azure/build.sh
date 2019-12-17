#!/usr/bin/env bash

rm -rf feature &>/dev/null
cp -r ../../feature .
cp ../../featureinstaller.sh .

docker build . -t cloudcontrol-azure:latest
