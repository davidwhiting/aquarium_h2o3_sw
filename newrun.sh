#!/bin/bash

docker run --init --rm \
	-u h2o:h2o \
	-v /home/ubuntu/contents/data:/home/h2o/data \
	-v /home/ubuntu/contents/sparkling_waters_hands_on:/home/h2o/sparkling_water_hands_on \
	-v /home/ubuntu/contents/h2o-3_hands_on:/home/h2o/h2o-3_hands_on \
	-p 4040:4040 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 \
	test

