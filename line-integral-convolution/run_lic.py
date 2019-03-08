import numpy as np
import cv2 as cv
from lic import *
import os
import sys

KW = 4
if len(sys.argv) > 2:
    KW = int(sys.argv[2])

filepath = os.path.abspath(sys.argv[1])
rawdir, filename = os.path.split(filepath)
imagesdir, _ = os.path.split(rawdir)
outdir = os.path.join(imagesdir, 'lic')
outpath = os.path.join(outdir, filename)

if not os.path.exists(outdir):
    os.makedirs(outdir)
    
img = cv.imread(filepath)
img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
img_lab = cv.cvtColor(img, cv.COLOR_RGB2LAB)
img_gray = cv.cvtColor(img, cv.COLOR_RGB2GRAY)
labels, label_counts = label_regions(img_lab, img_lab.shape[0] * img_lab.shape[1] // 8)
vec = extract_region_vector_field(img_gray, labels, label_counts)
im_noise = generate_noise_image(img_gray, labels, label_counts)
im_sketch = line_integral_convolution(im_noise, vec, KW=KW, use_tqdm=True)

cv.imwrite(outpath, im_sketch)