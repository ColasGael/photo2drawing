function smap = saliency_map(input_img)
    [m,n,c] = size(input_img);

    quant_factor = 12;
    lab_img = rgb2lab(input_img);
    % Quantize in RGB space
    [rgb_quant, rgb_vals] = rgbquantize(input_img,quant_factor);
    % Form color hist
    [nzero_colors, nzero_freqs] = color_hist(rgb_quant,quant_factor);
    lab_nzero_colors = rgb2lab(nzero_colors);
    nonzeros = size(nzero_colors,1);
    % Form index dict
    color_dict = zeros(quant_factor,quant_factor,quant_factor);
    for i=1:nonzeros
        colordict(nzero_colors(i,1), nzero_colors(i,2),nzero_colors(i,3)) = i;
    end

    saliences = zeros(nonzeros,1);
    for i=1:nonzeros
        % = sub2ind(size(saliences), nzero_colors(i,1), nzero_colors(i,2), nzero_colors(i,3));
        for j = 1:nonzeros
            saliences(i) = saliences(i) + norm(lab_nzero_colors(i,:) - lab_nzero_colors(j,:))*nzero_freqs(j);
        end
    end
    saliences = normalize(saliences,'range');

    salience_map = zeros(m,n);
    for i=1:m
        for j=1:n
            salience_map(i,j) = saliences(  colordict(rgb_quant(i,j,1), rgb_quant(i,j,2), rgb_quant(i,j,3)) );
        end
    end
    smap = salience_map;
end