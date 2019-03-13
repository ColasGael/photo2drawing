% Read in a test images
img = imread('test_img.jpg');

% Form structuring elements for morphological image processing to eliminate
% small regions and close holes
se_noise = get_SE(4,1);
se_holes = get_SE(16,0.5);

% Get the mask processed using these structuring elements
mask = get_mask(img, se_noise, se_holes);

% Label contiguous regions
rlabelled = bwlabel(mask);
regions = max(max(rlabelled));

% Set a minimum region size to eliminate small regions
MIN_REGION_SIZE = 2000;

% Eliminate all small regions and decrease region labels as necessary
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

% Show regions shaded in different shades of gray
imshow(rlabelled/max(max(rlabelled)))
