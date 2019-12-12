#!/usr/bin/env bash

rm -rf tools &>/dev/null
cp -r ../tools .
docker build . -t cloudcontrol-azure:latest
