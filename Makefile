
buildprefix:
	docker build -t whiting/h2o-sw-prefix -f Dockerfile-prefix .

build:
        docker build -t whiting/training-h2o-sw -f Dockerfile .


run:
	docker run --init --rm -u h2o:h2o -p 4040:4040 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 whiting/h2o-training

save:
	docker save whiting/h2o-training | gzip -c > h2o-training.gz

