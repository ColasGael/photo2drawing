function im_color = cluster_color(im_rgb, n_cluster, gamma)
% 'cluster_color' Apply k-means clustering to reduce the number of colors
% of an RGB image
%
% Args:
%   'im_rgb' (3D double array): image to cluster colors from
%   'n_cluster' (int): number (k) of output colors (clusters)
% increasing 'n_cluster' increases the similarity with the original image
%   'gamma' (double): color adjustment parameters
% increasing 'gamma' makes the color less saturated
%
% Returns:
%   'im_color' (3D double array): recolorized image

    % apply k-means clustering
    im_flat = reshape(im_rgb, [], 3);
    [idx, clusters] = kmeans(im_flat, n_cluster);

    idx = repmat(reshape(idx, size(im_rgb, 1), size(im_rgb, 2)), 1, 1, 3);

    % color the pixels with the cluster colors
    im_cluster = zeros(size(im_rgb));
    for k=1 : size(clusters, 1)
        c = reshape(clusters(k,:), 1, 1, 3);
        im_cluster = im_cluster +  (idx == k) .* c;
    end

    % identify the most important channel for each pixel
    max_channel = max(im_cluster, [], 3);

    % adjust the colors
    im_color = (im_cluster == max_channel) .* im_cluster.^gamma + (im_cluster ~= max_channel) .* im_cluster;
end

