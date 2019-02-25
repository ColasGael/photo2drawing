function vec_field = extract_vector_field(im)

im_gray = rgb2gray(im);
[H, W] = size(im_gray);
im_blur = imfilter(im_gray, fspecial('gaussian', [15 15], 2));
[gradX, gradY] = imgradientxy(im_blur, 'sobel');
grad = cat(3, gradY, gradX);
% normalize gradient
grad = grad ./ (sum(grad .^ 2, 3) .^ 0.5 + 1e-2);
grad = grad .* (1 - 2 * (grad(:, :, 2) < 0));
vec_field = grad;

end
