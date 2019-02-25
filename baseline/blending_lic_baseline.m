function [im_sketch, im_draw] = blending_lic_baseline(im_rgb, num_regions = -1, R = 20, KW = 3, n_cluster = 1, gamma = 1.0, level = 0)
% 'blending_lic_baseline' photo2drawing baseline using lic
%
% Args:
%   'im_rgb' (3D double array): original image
%   'num_regions' (int): target number of regions to segment image into
%   'R' (int): radius of LIC field line
%   'KW' (int): convolution kernel radius of LIC filter
%   'n_cluster' (int): number (k) of output colors (clusters)
% increasing 'n_cluster' increases the similarity with the original image
%   'gamma' (double): color adjustment parameters
% increasing 'gamma' makes the color less saturated
%   'level' (double): gray level of edges
% 0 = black ; 1 = white
%
% Returns:
%   'im_draw' (3D double array): processed image

    [H, W, C] = size(im_rgb);

    % grayscale
    im_g = rgb2gray(im_rgb);

    % recolorized image
    im_color = cluster_color(im_rgb, n_cluster, gamma);

    % default to decimating the number of regions
    if num_regions < 0
      num_regions = idivide(uint32(H * W), 10);
    end

    % label regions
    [labels, label_counts] = label_regions(im_rgb, num_regions);

    % extract vector field
    vec = extract_region_vector_field(im_g, labels, label_counts);

    % generate noise image
    im_noise = generate_noise_image(im_g, labels, label_counts) / 255.0;

    % generate pencil sketch
    im_sketch = line_integral_convolution(im_noise, vec, R, KW);

    % add edges in black on image
    im_draw = im_color .* im_sketch + level * (1 - im_sketch);
end

