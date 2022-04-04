#!/usr/bin/env bash

PROJECT_NAME=test

docker run \
       --name $PROJECT_NAME \
       --rm \
       --gpus all \
       --user $(id -u):$(id -g) \
       -it \
       $PROJECT_NAME
