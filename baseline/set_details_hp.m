function hp_out = set_details_hp(hp, lambda_d)
% 'set_details_hp' set the GUI hyperparameters according to the 'details axis'
%
% Args:
%   'hp' (Struct): structure gathering all the hyperparameters as its fields
%   'lambda_d' (double): value on the 'details axis'
% 1 = lots of details ; 0 = few details
%
% Returns:
%   'hp_out' (Struct): structure gathering all the modified hyperparameters as its fields

    %% Edge detection
    % edge detection threshold
    hp.thresh = 0.3*(1-lambda_d)+0.15;
    % size of dilatation structuring element
    hp.k = round(2*lambda_d)+1; 
    %% Color for clustering
    % number of output colors
    hp.n_cluster = round(5*lambda_d)+1; 
    % color adjustement
    hp.gamma = 1-0.5*lambda_d; 
    %% Blending
    % importance of color gradient
    hp.amplitude = lambda_d; 
    
    hp_out = hp;
end
