function im_noise = generate_noise_image(im_gray, labels, label_counts, lambda_1 = 0.7, min_1 = 0, max_1 = 255, lambda_2 = 0.3, min_2 = 0, max_2 = 255)
% 'generate_noise_image' photo2drawing baseline using lic
%
% Args:
%   'im_gray' (2D double array): grayscale image
%   'labels' (2D int array): pixel region labels
%   'label_counts' (int array): frequency of region labels
%   'lambda_1' (double): threshold 1 tuning parameter
%   'min_1' (double): threshold 1 low output value
%   'max_1' (double): threshold 1 high output value
%   'lambda_2' (double): threshold 2 tuning parameter
%   'min_2' (double): threshold 2 low output value
%   'max_2' (double): threshold 2 high output value
%
% Returns:
%   'im_noise' (2D double array): speckle noise

im_gray = double(im_gray) / 255.0;
[H, W] = size(im_gray);
im_noise = zeros(H, W);

% compute region means;
N = length(label_counts);
R = zeros(N, 1);
for i = 1:H
  for j = 1:W
    R(labels(i, j)) += im_gray(i, j);
  end
end
R = R ./ label_counts;

% compute colors if thresholds 1 and 2 are used
T_1 = lambda_1 * (1.0 - im_gray) .^ 2.0;
T_2 = lambda_2 * (1.0 - im_gray) .^ 2.0;
P = rand(H, W);
C_1 = min_1 .* (P <= T_1) + max_1 .* (P > T_1);
C_2 = min_2 .* (P <= T_2) + max_2 .* (P > T_2);

% select pixels to be colored with threshold 1
I = zeros(H, W);
for i = 1:H
  for j = 1:W
    I(i, j) = (im_gray(i, j) <= R(labels(i, j)));
  end
end

% color pixels by the correct threshold
im_noise = C_1 .* I + C_2 .* not(I);

end
