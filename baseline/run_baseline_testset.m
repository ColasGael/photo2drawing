%% Run the Baseline and the Color from Region Segmentation on the sample test set

% test set image directory
test_dir = '../images/raw';


% get the image filenames
test_info  = dir( fullfile(test_dir, '*.jpg') );
test_filenames = fullfile(test_dir, {test_info.name});

% save filenames
baseline_dir = '../images/baseline';
baseline_filenames = fullfile(baseline_dir, {test_info.name});

for i=1 : length(test_filenames)
    % import the images
    test_image = im2double(imread(test_filenames{i}));
    % compute the drawing results
    test_drawing_baseline = blending_baseline_hp(test_image);
    % save the results
    imwrite(test_drawing_baseline, baseline_filenames{i});
end
