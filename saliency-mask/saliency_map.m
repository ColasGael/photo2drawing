% Retrieve the saliency map of an input image using LAB space
function smap = saliency_map(input_img)
    [m,n,c] = size(input_img);

    quant_factor = 12;
    lab_img = rgb2lab(input_img);
    % Quantize in RGB space
    [rgb_quant, rgb_vals] = rgbquantize(input_img,quant_factor);
    % Form color histogram for efficiency of computation
    [nzero_colors, nzero_freqs] = color_hist(rgb_quant,quant_factor);
    % Take all the colors present in the image and put them in LAB space
    lab_nzero_colors = rgb2lab(nzero_colors);
    nonzeros = size(nzero_colors,1);
    % Form index dict for all quantized colors that are present in the
    % image
    color_dict = zeros(quant_factor,quant_factor,quant_factor);
    for i=1:nonzeros
        colordict(nzero_colors(i,1), nzero_colors(i,2),nzero_colors(i,3)) = i;
    end
    
    % Compute the color distance between the colors in LAB space
    saliences = zeros(nonzeros,1);
    for i=1:nonzeros
        for j = 1:nonzeros
            saliences(i) = saliences(i) + norm(lab_nzero_colors(i,:) - lab_nzero_colors(j,:))*nzero_freqs(j);
        end
    end
    % Normalize salience values between 0 and 1
    saliences = normalize(saliences,'range');
    
    % Assign each pixel the appropriate salience based on its quantized RGB
    % values
    salience_map = zeros(m,n);
    for i=1:m
        for j=1:n
            salience_map(i,j) = saliences(  colordict(rgb_quant(i,j,1), rgb_quant(i,j,2), rgb_quant(i,j,3)) );
        end
    end
    smap = salience_map;
end