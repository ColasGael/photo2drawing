% Quantize an RGB image into a number of levels provided by quant_factor
function [quantized, quant_vals] = rgbquantize(rgbimage,quant_factor)
    quantized = floor(im2double(rgbimage)*0.99 * (quant_factor)) + 1;
    quant_vals = (double(0:(quant_factor-1)) + 0.5)*(256/quant_factor);
end