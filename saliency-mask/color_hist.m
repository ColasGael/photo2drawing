% Form the color histogram, return nonzero colors and nonzero frequencies
% in order of descending frequencies
function [ nonzero_colors, nonzero_freqs] = color_hist(input_img, ncolors)
    [m,n,c] = size(input_img);
    chist = zeros(ncolors,ncolors,ncolors);
    for i=1:m
        for j=1:n
            chist(input_img(i,j,1), input_img(i,j,2), input_img(i,j,3)) = ...
                chist(input_img(i,j,1), input_img(i,j,2), input_img(i,j,3))+1;
        end
    end
    nonzeros = find(chist);
    [r, g, b]  = ind2sub(size(chist), nonzeros);
    nonzero_freqs = chist(nonzeros);
    nonzero_colors = [r,g,b];
    
    [nonzero_freqs, inds] = sort(nonzero_freqs, 'descend');
    nonzero_colors = nonzero_colors(inds,:);
end