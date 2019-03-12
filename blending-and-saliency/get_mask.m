function mask = get_mask(img, se1_size, se2_size, thresh)
    se_noise = get_SE(se1_size,1);
    se_holes = get_SE(se2_size,1.5);
    mask = apply_SE(img, se_noise, se_holes, thresh);
    rlabelled = bwlabel(mask);
    regions = max(max(rlabelled));

    MIN_REGION_SIZE = size(img,1)*size(img,2)/16;

    for i=1:regions
        num = sum(sum(rlabelled == i));
        if num < MIN_REGION_SIZE
            rlabelled = rlabelled - rlabelled.*(rlabelled == i);
        end
    end
    
    leftovers = unique(rlabelled);
    new_labels = 1;
    for i=2:size(leftovers,1)
        rlabelled(rlabelled == leftovers(i)) = new_labels;
        new_labels = new_labels + 1;
    end
    
    mask = rlabelled > 0;
end
