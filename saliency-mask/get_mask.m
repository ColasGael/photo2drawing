% Use the provided structuring elements to perform morphological image
% processing on the raw saliency image
function mask = get_mask(img, se_noise, se_holes)
    % The raw saliencies for each pixel
    s_img = saliency_map(img);
    % binarize
    s_img_t = s_img > graythresh(s_img);    
    % Remove small dots with opening
    dots_removed = imopen(s_img_t, se_noise);
    % Remove holes with closing
    holes_removed = imclose(dots_removed, se_holes);
    mask = holes_removed;
end
