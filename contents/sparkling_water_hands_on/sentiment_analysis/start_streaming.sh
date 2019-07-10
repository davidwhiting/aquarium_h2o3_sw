#!/usr/bin/env bash

DATASET="../../data/amazon_reviews/AmazonReviews_Train.csv"
OUTPUT=$(pwd)/"output"
mkdir -p $OUTPUT

i=0
while read l; do
  echo "$l" > $OUTPUT/${i}.csv
  i=$((i+1))
  sleep 1
done <$DATASET

