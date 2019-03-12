function hp_out = set_details_hp(hp, lambda_d)
% 'set_details_hp' set the hyperparameters according to the 'details axis'
%
% Args:
%   'hp' (Struct): structure gathering all the hyperparameters as its fields
%   'lambda_d' (double): value on the 'details axis'
% 1 = lots of details ; 0 = few details
%
% Returns:
%   'hp_out' (Struct): structure gathering all the modified hyperparameters as its fields

    % edge detection threshold
    hp.thresh = 0.3*(1-lambda_d)+0.15;
    % size of dilatation structuring element
    hp.k = round(2*lambda_d)+1; 
    % number of output colors
    hp.n_cluster = round(5*lambda_d)+1; 
    % color adjustement
    hp.gamma = 1-0.5*lambda_d; 
    % importance of color gradient
    hp.amplitude = lambda_d; 
    % se1_size range from 2-6
    hp.se1_size = round(lambda_d*3 + 2);
    %se2_size range from 8-16
    hp.se2_size = round(lambda_d*32+hp.se1_size + 8);
    % threshold range from -0.1 to 0.1
    % will be offset to otsu method
    hp.region_thresh = -(lambda_d*0.2-0.1);
    
    hp_out = hp;
end
