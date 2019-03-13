function im_color = segment_color(im_rgb, gd_thresh, se_size, gamma)
% 'segment_color' Apply region segmentation to reduce the number of colors of an RGB image
%
% Args:
%   'im_rgb' (3D double array): color image to process
%   'gd_thresh' (double): threshold for region boundaries detection
% decreasing 'gd_thresh' increases the number of regions and thus the closeness to the initial image
%   'se_size' (int): size of structural element used for Open-Close operation
% decreasing 'se_size' increases the number of regions and thus the closeness to the initial image
%   'gamma' (double): color adjustment parameters
% increasing 'gamma' makes the color less saturated
%
% Returns:
%   'im_color' (3D double array): recolorized image

    % hyperparameters
    min_edge = 50; % smallest size of edge allowed

    % grayscale image
    im_g = rgb2gray(im_rgb);

    % smooth the image into very distinct regions
    se = strel('disk', se_size); % structural element
        % opening by reconstruction
    im_e = imerode(im_g, se);
    im_obr = imreconstruct(im_e, im_g);
        % closing by reconstruction
    im_obr_d = imdilate(im_obr, se);
    im_ocbr = imreconstruct(imcomplement(im_obr_d), imcomplement(im_obr));
    im_ocbr = imcomplement(im_ocbr);

    % extract the boundaries of the regions
    gmag = imgradient(im_ocbr) > gd_thresh;
    % filtrate small edges
    gmag = bwareaopen(gmag, min_edge);

    % label the regions delimited by the boundaries
    [pieces_labeled, n_pieces] = bwlabel(1 - gmag);    

    % display the distinct regions found
    regions = labeloverlay(im_ocbr,pieces_labeled);

    % convert to LAB coordinates
    im = rgb2lab(im_rgb);
    
    % color each region with its mean value
    result = 0.5 * im .* gmag;
    for i=1 : n_pieces
        % region mask
        mask = pieces_labeled == i;
        % compute the mean color value of the region
        n_pixel = sum(mask(:));
        mean_color = sum(reshape(im .* mask, [], 3) ,1)/n_pixel;
        % adjust the color
        [~, i] = max(mean_color);
        mean_color(i) = mean_color(i).^gamma;

        result = result + repmat(mask, 1, 1, 3) .* reshape(mean_color, 1,1,3);
    end
    
    % get back to the RGB space
    im_color = lab2rgb(result);
    % normalize
    im_color = im_color/max(im_color(:));
end

