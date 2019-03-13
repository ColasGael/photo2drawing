function sketch = lic_sketch(im_rgb, lic_path, kw)
% 'lic_sketch' Compute a line sketch from an RGB image
%
% Args:
%   'im_rgb' (3D double array): image to extract the edges from
%   'lic_path' (String): path to the precomputed LIC line sketches
%   'kw' (int): kernel width used in the Line Integral Convolution operation
%
% Returns:
%   'sketch' (2D bool array): the location of the edges
%
% Remark: this function just call precomputed LIC line sketches
%   This is because we implemented a faster Python script to generate them
    
    % path to the desired LIC line sketch
    sketch_path = char(string(lic_path(1:end-4)) + "_KW-" + string(kw) + ".jpg")
    
    % load the LIC line sketch
    sketch = im2double(imread(sketch_path));
end

