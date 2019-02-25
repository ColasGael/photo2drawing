function [labels, label_counts] = label_regions(im, num_regions)
% 'extract_region_vector_field' perform region-aware vector field extraction
%
% Args:
%   'im' (3D double array): original image
%   'num_regions' (int): number of regions to retain
%
% Returns:
%   'labels' (2D int array): pixel region labels
%   'label_counts' (int array): frequency of region labels

im = double(im);
[H, W, C] = size(im);

% compute adjacent pixel merging costs
[J, I] = meshgrid(1:W, 1:H);
h_cost = sum((im(:, 1:end-1, :) - im(:, 2:end, :)) .^ 2, 3) .^ 0.5;
h_indices = (I(:, 1:W-1) - 1) * W + J(:, 1:W-1);
v_cost = sum((im(1:end-1, :, :) - im(2:end, :, :)) .^ 2, 3) .^ 0.5;
v_indices = (I(1:end-1, :) - 1) * W + J(1:end-1, :);
edge_costs = [ h_cost(:); v_cost(:) ];
edge_indices = [ h_indices(:); v_indices(:) ];

% union-find data structure
p = 1:H*W;
rank = zeros(1, H*W);

% process edges in increasing order of cost
[costs, indices] = sort(edge_costs);
components = H*W;
for i = 1:length(edge_costs)
  if (components <= num_regions) break end

  e = indices(i);
  px = edge_indices(e);
  if e <= H * (W - 1)
    py = px + 1;
  else
    py = px + W;
  end

  % path compression
  c = [px];
  while (p(c(end)) != c(end)) c(end + 1) = p(c(end)); end
  for x = c
    p(x) = c(end);
  end

  % path compression
  c = [py];
  while (p(c(end)) != c(end)) c(end + 1) = p(c(end)); end
  for x = c
    p(x) = c(end);
  end

  % merge clusters
  px = p(px);
  py = p(py);
  if px ~= py
    if (rank(px) > rank(py)) [px, py] = deal(py, px); end
    if (rank(px) == rank(py)) rank(py) += 1; end
    p(px) = py;
    components = components - 1;
  end
end

% path compression
for px = 1:H*W
  c = [px];
  while (p(c(end)) != c(end)) c(end + 1) = p(c(end)); end
  for x = c
    p(x) = c(end);
  end
end

% label pixels
labels = zeros(H, W);
comps = unique(p);
for i = 1:H
  for j = 1:W
    labels(i, j) = lookup(comps, p((i - 1) * W + j));
  end
end
label_counts = histc(labels(:), 1:length(comps));

end
