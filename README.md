# The *aquarium\_h2o3\_sw* repository

## I. Introduction
This repository contains course contents and DockerFiles for building 

```
David Whiting's Introduction to H2O-3 and Sparkling Water
``` 

trainings. 

>
Most of the original content and tutorials were built by the excellent data scientists and engineers at H2O. My main contribution has been in organizing and polishing their work, to fit my instructional style.
>
In the end, I am solely responsible for any mistakes or misstatements in the course materials.
>
>  David Whiting 

## II. Building the Docker

The docker build process is in two steps: `Dockerfile-prep` and `Dockerfile`. `Dockerfile-prep` creates the system and loads the appropriate versions of H2O-3, Spark, Sparkling Water, etc. `Dockerfile` then adds the contents and the finishing touches on the image. The reason for making this two-stage is that contents get updated much more frequently than the software. The time to build an entire system is greatly shortened by this two-stage process, with the first part prebuilt.

### A. Dockerfile-prep

All of the versioning information is set at the top of the `Dockerfile-prep` file. The variable `$BASE` is the baseline path within the `/home/h2o` user folder where miniconda, spark, and sparkling water will be installed. Its default is set as

```
ARG BASE=/home/h2o/.local
```
Feel free to change that to anything you would like.

#### 1. Updating versions

The rest of the version variables are collected in one place:

```
ARG RSTUDIO_VERSION=1.2.1335

ARG CONDA_PYTHON_H2O=3.6
ARG CONDA_PYTHON_PYSPARKLING=2.7

ARG H2O_BRANCH_NAME=yates
ARG H2O_MAJOR_VERSION=3.24.0
ARG H2O_BUILD_NUMBER=5

ARG SPARK_VERSION=2.4.3
ARG SPARK_HADOOP_VERSION=2.7

ARG SPARKLING_WATER_BRANCH_NUMBER=2.4
ARG SPARKLING_WATER_BUILD_NUMBER=13

# file found at $SPARK_HOME/python/lib/
ARG PY4J_VERSION=0.10.7
```
Once more, this should be the only place you need to set these values. If everything goes well, you can then type from the command line

```
> make prep
```

to build the prep image.

#### 2. Template files

The files

```
run.sh
pyspark/00-pyspark-setup.py
pyspark/kernel.json
```

all have components that rely upon the versioning. The `Dockerfile-prep` file copies these into the appropriate places in the image, then replaces placeholders with the appropriate variable numbers. If there are any issues with the docker image ultimately not running, this is the first place I would check.

#### 3. PY4J file

In the updating versions section above, there is a file whose value can not easily be determined directly by the docker. The file 

```
ARG PY4J=py4j-${PY4J_VERSION}-src.zip
```
is found in `$SPARK_HOME/python/lib/` and its version number should not change frequently. However, it is required to use pysparkling and might be the culprit if things are not working well.

### B. Dockerfile

The ultimate Dockerfile copies the course contents to the prep image and sets up the final entrypoint and exposes the right ports. Build it using

```
> make build
```

## III. Course Contents

### A. H2O-3 Contents

### B. Sparkling Water Contents

