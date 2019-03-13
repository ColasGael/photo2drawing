% Compute the distance in lab space between quantized rgb values
% using the provided rgb_vals and the quantized values rgb_quant1 and
% rgb_quant2
function dist = Lab_dist(rgb_quant1, rgb_quant2, rgb_vals)
    lab1 = rgb2lab([rgb_vals(rgb_quant1(1)), rgb_vals(rgb_quant1(2)), rgb_vals(rgb_quant1(3))]);
    lab2 = rgb2lab([rgb_vals(rgb_quant2(1)), rgb_vals(rgb_quant2(2)), rgb_vals(rgb_quant2(3))]);
    dist = norm(lab1-lab2);
end