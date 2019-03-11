#!/bin/bash

for image in raw/*.jpg; do
  for kw in {1..20}; do
    echo "Processing $image, KW = $kw"
    python ../line-integral-convolution/run_lic.py $image $kw
  done
done
