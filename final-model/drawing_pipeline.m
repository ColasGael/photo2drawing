function im_draw = drawing_pipeline(im_rgb, lic_path, kw, gd_thresh, se_size, gamma, level, sigma_color, amplitude, sigma_g)
% 'blending_segment' picture2drawing blending using color reduction from region segmentation
%
% Args:
%   'im_rgb' (3D double array): original image
%   'lic_path' (String): path to the precomputed LIC line sketches
%   'kw' (int): kernel width used in the Line Integral Convolution operation
%   'gd_thresh' (double): threshold for region boundaries detection
% decreasing 'gd_thresh' increases the number of regions and thus the closeness to the initial image
%   'se_size' (int): size of structural element used for Open-Close operation
% decreasing 'se_size' increases the number of regions and thus the closeness to the initial image
%   'gamma' (double): color adjustment parameters
% increasing 'gamma' makes the color less saturated
%   'level' (double): gray level of edges
% 0 = black ; 1 = white
%   'sigma_color' (double): gaussian std for color smoothering
% increasing 'sigma_color' increases the blur
%   'amplitude' (double): importance factor of color gradient information
% 0 = only cluster colors ; 1 = contrast info from grayscale image
%   'sigma_g' (double): gaussian std for color gradient
%
% Returns:
%   'im_draw' (3D double array): processed image

    % grayscale
    im_g = rgb2gray(im_rgb);

    % edges
    sketch = lic_sketch(im_rgb, lic_path, kw);

    % recolorized image
    im_color = segment_color(im_rgb, gd_thresh, se_size, gamma);

    % screen blend mode
    lambda_r = 0.7;
    im_blend = 1 - (1 - (1-lambda_r)*sketch).*(1 - lambda_r*im_color);

    % use smoothered grayscale for color gradient effect
    color_gradient =  amplitude * imgaussfilt(im_g, sigma_g); 
    % center in 0.5
    color_gradient = color_gradient + (0.5 - mean(color_gradient(:)));

    % apply the color gradient information
    im_gc = imgaussfilt(im_blend, sigma_color) .* color_gradient;
    im_draw = im_gc / max(im_gc(:));
end

