#!/bin/bash

image=$1
for kw in {2..20}; do
echo "Processing $image, KW = $kw"
python3 ../line-integral-convolution/run_lic.py $image $kw
done
