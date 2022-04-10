#!/usr/bin/env bash

PROJECT_NAME=test

docker run \
       --name $PROJECT_NAME \
       --rm \
       --gpus all \
       -p 6006:6006 \
       --user $(id -u):$(id -g) \
       -it \
       $PROJECT_NAME
