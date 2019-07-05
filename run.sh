#!/bin/bash

#
# Note:  This run script is meant to be run inside the docker container.
#

# set -x
set -e

if [ "x$1" != "x" ]; then
    d=$1
    cd $d
    shift
    exec "$@"
fi

logdir=/log/`date "+%Y%m%d-%H%M%S"`
mkdir -p "$logdir"

echo "-------------------------"
echo "Welcome to H2O Training  "
echo "-------------------------"
echo ""
echo "- Connect to Jupyter notebook on port 8888 (password: h2o)"
echo "- Connect to RStudio on port 8787 (username/password: h2o/h2o)"

source /home/h2o/.local/miniconda3/bin/activate h2o

(cd /home/h2o && \
 jupyter --paths >> "$logdir"/jupyter.log && \
 nohup jupyter notebook --ip='0.0.0.0' --no-browser --allow-root >> "$logdir"/jupyter.log 2>&1 &)

(cd /home/h2o && \
 sudo rstudio-server start >> "$logdir"/rstudio-server.log)

# 10 years
sleep 3650d
