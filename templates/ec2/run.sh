#!/bin/sh

if nvidia-smi | grep -o "failed";
then
  echo "Starting CPU only"
  DOCKER=docker
else
  echo "Starting GPU"
  DOCKER=nvidia-docker
fi

$DOCKER run \
    --init \
    --rm \
    -p 4040:4040 \
    -p 8787:8787 \
    -p 8888:8888 \
    -p 54321-54399:54321-54399 \
    -u h2o:h2o \
    whiting/h2o-sw-training &
