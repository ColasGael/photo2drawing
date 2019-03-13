# photo2drawing
by Gael Colas, Hubert Teo and Andrew Deng, Stanford University students.

Goal : Automatic generation of pencil color drawings from color photos.

This is our final project for EE368 "Digital Image Processing" class at Stanford.

To achieve this image translation task with build a pipeline. The pipeline is composed of 3 components: get a line sketch, get a colorization and blend/ apply the colors over the line sketch.
To get more details about our 'photo2drawing' pipeline, please refer to our final report 'ee368_final-report' located at the root.

## Code structure
Folder 'saliency-mask': experiment on using saliency maps to select regions of interest.

Folder 'line-integral-convolution': Python code to compute Line Integral Convolution.

Folder 'baseline': gathers code for our 'baseline' pipeline.
 - line sketch generation: Canny Edge Detector
 - color generation: Clustering in the LAB-space
 
Folder 'segment': modification of our baseline to select colors based on Region Segmentation.
 - line sketch generation: Canny Edge Detector
 - color generation: mean colors of extracted regions (Region Segmentation)

Folder 'final-model': final 'photo2drawing' pipeline.
 - line sketch generation: Line Integral COnvolution
 - color generation: mean colors of extracted regions (Region Segmentation)

For these 3 pipelines, you can find the core code (.m files). 
We also provided interactive notebooks that shows intermediate outputs of the pipelines.
 
Folder 'images': gathers our different method's output result on our test set
 - subfolder 'raw': our test set images (sample data)
 - subfolder 'baseline': outputs of the 'baseline' pipeline. 
 - subfolder 'segment': outputs of the 'segment' pipeline.
 - subfolder 'saliency-map': saliency map outputs on the test images.
 - subfolder 'lic': line integral convolution on the test images.
 - subfolder 'final-model': outputs of the 'final-model' pipeline.
 - subfolder 'ps_<filter_name>': outputs of applying Adobe Photoshop filter <filter_name> on the test images. (To allow for quality comparison)

## Run code

For an image imported in Matlab as an RGB image: 'im\_rgb = im2double(imread('<im_path>'))'

For each of the 3 pipelines (see overhead description), you can run the pipeline on it in 2 different ways:
 - apply pipeline with tuned hyperparameters
Syntax: '<pipeline_name>\_hp(im_rgb)'
 - launch a GUI for real-time customization along predefined modification axes
Syntax: 'gui_<pipeline_name>(im_path)'
 
 
