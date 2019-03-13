function im_blend = blend_screen(im, im_draw, lambda_r)
    % rescale the lambda_r axis
    lambda_r = (lambda_r < 0.95)*0.7*lambda_r + (lambda_r >= 0.95);
    lambda_r = lambda_r^1.5;

    % screen blend mode
    im_blend = 1 - (1 - (1-lambda_r)*im_draw).*(1 - lambda_r*im);
    % normalization
    im_blend = im_blend / max(im_blend(:));
end