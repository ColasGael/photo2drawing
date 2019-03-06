function mask = get_mask(img, se_noise, se_holes)
    s_img = saliency_map(img);
    s_img_t = s_img > graythresh(s_img);    
    dots_removed = imopen(s_img_t, se_noise);
    holes_removed = imclose(dots_removed, se_holes);
    mask = holes_removed;
end
