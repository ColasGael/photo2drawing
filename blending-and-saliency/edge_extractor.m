function edges_d = edge_extractor(im_rgb, thresh, k)
% 'edge_extractor' Extract the edges from an RGB image
%
% Args:
%   'im_rgb' (3D double array): image to extract the edges from
%   'thresh' (double): threshold for edge extraction
% increasing 'thresh' decreases the amount of edge detected
%   'k' (int): size of the dilatation structuring element
% increasing 'k' increases the width of the edges
%
% Returns:
%   'edges' (2D bool array): the location of the edges
    
    if size(im_rgb, 3) > 1
        % grayscale version
        im_g = rgb2gray(im_rgb);
    else
        im_g = im_rgb
    end

    % edge extraction
    edges =  edge3(im_g, 'approxcanny', thresh);

    % edge dilatation
    SE = ones(k,k);
    edges_d = imdilate(edges, SE);
end

