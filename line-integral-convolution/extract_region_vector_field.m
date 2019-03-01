function vec = extract_region_vector_field(im_gray, labels, label_counts, preblur_sigma = 1, preblur_size = 7, var_threshold = 0.5)
% 'extract_region_vector_field' perform region-aware vector field extraction
%
% Args:
%   'im_gray' (2D double array): grayscale image
%   'labels' (2D int array): pixel region labels
%   'label_counts' (int array): frequency of region labels
%   'preblur_sigma' (double): pre-blur gaussian kernel sigma
%   'preblur_size' (int): width of pre-blur gaussian kernel
%   'var_threshold' (double): vector variance threshold for equal-vector region
%
% Returns:
%   'vec' (H * W * 2 double array): vector field

% pre-blur image before taking sobel gradient
[H, W] = size(im_gray);
im_blur = imfilter(im_gray, fspecial('gaussian', [preblur_size preblur_size], preblur_sigma));
[gradX, gradY] = imgradientxy(im_blur, 'sobel');

% rotate by 90 deg: (x, y) -> (-y, x)
vec = double(cat(3, gradX, -gradY)) / 255.0;

% fix x component to be positive
vec = vec .* (1 - 2 * (vec(:, :, 2) < 0));

% compute region means and variances
mean_vec = zeros(length(label_counts), 2);
var_vec = zeros(length(label_counts), 1);
for i = 1:H
  for j = 1:W
    mean_vec(labels(i, j), :) += reshape(vec(i, j, :), 1, 2);
  end
end
for i = 1:length(label_counts)
  mean_vec(i, :) /= label_counts(i);
end
for i = 1:H
  for j = 1:W
    l = labels(i, j);
    var_vec(l) += sum((reshape(vec(i, j, :), 1, 2) - mean_vec(l, :)) .^ 2);
  end
end
for i = 1:length(label_counts)
  var_vec(i) /= label_counts(i);
end

% snap low-variance regions to mean vector
for i = 1:H
  for j = 1:W
    l = labels(i, j);
    if var_vec(l) <= var_threshold
      vec(i, j, :) = mean_vec(l, :);
    end
  end
end

% normalize vectors
vec = vec ./ (sum(vec .^ 2, 3) .^ 0.5 + 1e-2);

end
