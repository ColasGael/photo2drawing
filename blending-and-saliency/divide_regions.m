function regions = divide_regions(img, se_noise_size, se_holes_size, min_region_size)

se_noise = get_SE(se_noise_size,1);
se_holes = get_SE(se_holes_size,0.5);
mask = get_mask(img, se_noise, se_holes);
rlabelled = bwlabel(mask);
regions = max(max(rlabelled));


for i=1:regions
    num = sum(sum(rlabelled == i));
    if num < min_region_size
        rlabelled = rlabelled - rlabelled.*(rlabelled == i);
    end
end
leftovers = unique(rlabelled);
new_labels = 1;
for i=2:size(leftovers,1)
    rlabelled(rlabelled == leftovers(i)) = new_labels;
    new_labels = new_labels + 1;
end

regions = rlabelled > 0
end