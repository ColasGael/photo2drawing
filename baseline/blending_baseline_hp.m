function im_draw = blending_baseline_hp(im_rgb, hp)
% 'blending_baseline_hp' is a wrapper for 'blending_baseline'
%
% Args:
%   'im_rgb' (3D double array): original image
%   'hp' (Struct): structure gathering all the hyperparameters as its fields
%
% Returns:
%   'im_draw' (3D double array): processed image

    % retrieve the hyperparameters
    thresh = hp.thresh; % threshold for edge detection
    k = hp.k; % size of dilatation structuring element
    n_cluster = hp.n_cluster; % number of output colors
    gamma = hp.gamma; % color adjustement
    isLAB = hp.isLAB; % space in which to perform the clustering

    level = hp.level; % color of edges
    sigma_color = hp.sigma_color; % std for color smoothering
    amplitude = hp.amplitude; % importance of color gradient
    sigma_g = hp.sigma_g; % std for color gradient
    
    im_draw = blending_baseline(im_rgb, thresh, k, n_cluster, gamma, isLAB, level, sigma_color, amplitude, sigma_g);
end
