function mask = appply_SE(img, se_noise, se_holes,thresh)
    s_img = saliency_map(img);
    otsu = graythresh(img);
    region_thresh = min(max(otsu + thresh,0),1);
    s_img_t = s_img > region_thresh;    
    dots_removed = imopen(s_img_t, se_noise);
    holes_removed = imclose(dots_removed, se_holes);
    mask = holes_removed;
end
