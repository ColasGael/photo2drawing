function plot_vector_field(im_gray, vec, scale = 5)
% 'plot_vector_field' quiver plot of vector field over image
%
% Args:
%   'im_gray' (2D double array): grayscale image
%   'vec' (H * W * 2 double array): vector field
%   'scale' (double): quiver plot scale


[H, W] = size(im_gray);
X = linspace(0.5, W - 0.5, W);
Y = linspace(0.5, H - 0.5, H);
[X, Y] = meshgrid(X, Y);

cla;
clf;
colormap gray;
imagesc(im_gray);
hold on;
quiver(X, Y, vec(:, :, 2), vec(:, :, 1), scale);

end

