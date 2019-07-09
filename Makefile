default: build


build: 
	docker build -t whiting/h2o-sw-training -f Dockerfile .

run:
	docker run --init --rm -u h2o:h2o -p 4040:4040 -p 8787:8787 -p 8888:8888 -p 54321-54399:54321-54399 whiting/h2o-sw-training

save:
	docker save whiting/h2o-sw-training | gzip -c > h2o-sw-training.gz


## for initially loading data from s3
fetch:
	mkdir -p contents/data
	s3cmd sync s3://whiting-aquarium-h2osw/contents/data/ contents/data/

## for correcting data issues in development
update_data:
	s3cmd sync contents/data/ s3://whiting-aquarium-h2osw/contents/data/ 