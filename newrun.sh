#!/bin/bash

#H2O_HOME=/home/ubuntu
H2O_HOME=/Users/dwhiting/github/davidwhiting/aquarium_h2o3_sw

docker run --init \
	--rm \
	-u h2o:h2o \
	-v ${H2O_HOME}/contents/:/home/h2o/dev/ \
	-p 4040:4040 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 \
	whiting/h2o-sw-training

#	-v ${H2O_HOME}/contents/sparkling_waters_hands_on:/home/h2o/dev/sparkling_water_hands_on \
#	-v ${H2O_HOME}/contents/h2o-3_hands_on:/home/h2o/dev/h2o-3_hands_on \
#	-v ${H2O_HOME}/contents/h2o-3_hands_on:/home/h2o/dev/develop \
