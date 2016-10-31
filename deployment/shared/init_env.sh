#!/usr/bin/env bash

cp -r $credentials ./
# Jenkins will inject an env var called "credentials"
# which points to a randomly generated path that contains the keys