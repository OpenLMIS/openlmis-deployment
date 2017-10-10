#!/usr/bin/env sh
# this is the same as init_env.sh, however here we're going to ignore
# the .env file, as that'll be sourced from a private repo.

# copy the credentials folder from jenkins
cp -r $credentials ./credentials
