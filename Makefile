default: build

fetch:
	mkdir -p contents/data
	s3cmd sync --no-preserve s3://whiting-aquarium-h2osw/contents/data/ contents/data/

build:  fetch
	cat Dockerfile-base Dockerfile-h2o-sw > Dockerfile
	docker build -t whiting/h2o-sw-training -f Dockerfile .

buildclean: fetch
	cat Dockerfile-base Dockerfile-h2o-sw > Dockerfile
	docker build --no-cache -t whiting/h2o-sw-training -f Dockerfile .

mli: 	
	cat Dockerfile-base Dockerfile-mli > Dockerfile
	docker build -t whiting/h2o-sw-mli -f Dockerfile .

coursework: fetch
	cat Dockerfile-base Dockerfile-coursework > Dockerfile
	docker build -t whiting/h2o-sw-coursework -f Dockerfile .

check:  fetch
	docker build -t whiting/h2o-sw-check -f Dockerfile-2.7 .

run:
	docker run --init --rm -u h2o:h2o -p 4040:4040 -p 8787:8787 -p 8888:8888 -p 8080:8080 -p 54321-54399:54321-54399 whiting/h2o-sw-training

all: build coursework mli

## for correcting data issues in development
update_data:
	s3cmd sync --no-preserve contents/data/ s3://whiting-aquarium-h2osw/contents/data/ 

dev_mac:
	docker run --init --rm -u h2o:h2o -v /Users/dwhiting/github/davidwhiting/aquarium_h2o3_sw/contents:/home/h2o/dev/ -p 4040:4040 -p 8080:8080 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 whiting/h2o-sw-training

dev:
	docker run --init --rm -u h2o:h2o -v /home/ubuntu/aquarium_h2o3_sw/contents:/home/h2o/dev/ -p 4040:4040 -p 8080:8080 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 whiting/h2o-sw-training

save:
	docker save whiting/h2o-sw-training | gzip -c > h2o-sw-training.gz
