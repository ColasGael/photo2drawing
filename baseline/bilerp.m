function result = bilerp(f, x, normalize = 1)
% 'bilerp' bilinear interpolation
%
% Args:
%   'f' (H * W * D double array): sample grid
%   'x' (1 * 2 double array): point coordinate in [0, H] * [0, W]
%   'normalize' (int): 0 = don't normalize, 1 = normalize
%
% Returns:
%   'result' (1 * D double array): resulting bilinear sample

% compute sample coordinates
[H, W, D] = size(f);
u = floor(x(1) - 0.5) + 1;
v = floor(x(2) - 0.5) + 1;
fu = x(1) - 0.5 - (u - 1);
fv = x(2) - 0.5 - (v - 1);

% clamp samples
up = max(min(u + 1, H), 1);
vp = max(min(v + 1, W), 1);
u = max(min(u, H), 1);
v = max(min(v, W), 1);

% bilinear interpolation
f1 = f(u, v, :) * (1 - fv) + f(u, vp, :) * fv;
f2 = f(up, v, :) * (1 - fv) + f(up, vp, :) * fv;
result = reshape(f1 * (1 - fu) + f2 * fu, 1, D);

% normalize result if necessary
if normalize == 1
  result = result / (sum(result .^ 2) ^ 0.5 + 1e-2);
end

end
