function result = line_integral_convolution(im_noise, vec, R = 30, KW = 5)
% 'line_integral_convolution' perform FastLIC
%
% Args:
%   'im_noise' (2D double array): noise image
%   'vec' (H * W * 2 double array): vector field
%   'R' (int): radius of LIC field line
%   'KW' (int): convolution kernel radius of LIC filter
%
% Returns:
%   'result' (2D double array): LIC result

% field line length: R forward and R backward
L = 2 * R;

% image space is a rectangle of size [0, H] * [0, W]
im_noise = double(im_noise);
[H, W] = size(im_noise);

% set up ODE where gradients are given by bilinearly interpolating vec
% and normalizing to unit length
opt = odeset('reltol', 1e-1, 'abstol', 1e-1);
df = @(t, y) bilerp(vec, y);

% set up convolution kernel (constant for now)
K = ones(1, 2 * KW + 1) / (2 * KW + 1);

% sample field lines and convolve along them
num_hits = zeros(H, W);
result = zeros(H, W);
for pi = 1:1:H
  for pj = 1:1:W
    if num_hits(pi, pj) > 0
      continue
    end
    disp(["sampling field line at pixel " num2str(pi) " " num2str(pj)]);

    line_s = zeros(L + 1, 2);
    line_s(R + 1, :) = [pi - 0.5, pj - 0.5];

    % integrate forward and backward to get field line samples
    [t, y] = ode45(df, 0:R, line_s(R+1, :), opt);
    line_s(R+2:end, :) = y(2:end, :);
    [t, y] = ode45(df, -(0:R), line_s(R+1, :), opt);
    line_s(1:R, :) = flipud(y(2:end, :));

    % sample noise at equal intervals along field line
    samples = zeros(1, L + 1);
    for i = 1:L+1
      samples(i) = bilerp(im_noise, line_s(i, :), 0);
    end

    % compute convolution with kernel
    samples_conv = imfilter(samples, K, 'conv');

    % update pixels along field line
    line_si = ceil(line_s(:, 1));
    line_sj = ceil(line_s(:, 2));
    ok = 1 <= line_si & line_si <= H & 1 <= line_sj & line_sj <= W;
    for i = 1+KW:L+1-KW
      if ok(i)
        num_hits(line_si(i), line_sj(i)) += 1;
        result(line_si(i), line_sj(i)) += samples_conv(i);
      end
    end
  end
end

% take the average sample at each pixel
result = result ./ num_hits;

end
