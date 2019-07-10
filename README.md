# The *aquarium\_h2o3\_sw* repository

## I. Introduction
This repository contains course contents and DockerFiles for building 

```
David Whiting's Introduction to H2O-3 and Sparkling Water
``` 

trainings. 

>Most of the original content and tutorials were built by the excellent data scientists and engineers at H2O. My main contribution has been in organizing and polishing their work, to fit my instructional style.
>
>In the end, I am solely responsible for any mistakes or misstatements in the course materials.
>
>  David Whiting 

## II. Building the Docker

The docker build process is in the standard `Dockerfile`. The data need to be downloaded separately, which will automatically happen if using the `Makefile` with either the

```
> make fetch
```
or

```
> make build
```
commands.

`Dockerfile` creates the system and loads the appropriate versions of H2O-3, Spark, Sparkling Water, etc., then adds the contents and the finishing touches on the image. The data thus have to be added before the docker image is created.

If there are data errors or updates that need to occur, that can happen via the

```
> make update_data
```
command. This is intended to fix the data within the repository, then sync those changes automatically to s3. Note that data are not saved in the github site.


### Dockerfile

All of the versioning information is set at the top of the `Dockerfile` file. The variable `$BASE` is the baseline path within the `/home/h2o` user folder where miniconda, spark, and sparkling water will be installed. Its default is set as

```
ARG BASE=/home/h2o/bin
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
Once more, this should be the only place you need to set these values. 

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


## III. Course Contents

### A. H2O-3 Contents

### B. Sparkling Water Contents

