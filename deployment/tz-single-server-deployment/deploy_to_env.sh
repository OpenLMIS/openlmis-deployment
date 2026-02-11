#!/usr/bin/env sh

export KEEP_OR_WIPE="keep"

../shared/init_env_gh.sh
cat $settings_training > settings.env
../shared/pull_images.sh $1

../shared/restart.sh $1
