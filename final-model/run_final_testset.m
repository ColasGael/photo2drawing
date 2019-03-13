%% Run the Baseline and the Color from Region Segmentation on the sample test set

% test set image directory
test_dir = '../images/raw';
lic_dir = '../images/lic';

% get the image filenames
test_info  = dir( fullfile(test_dir, '*.jpg') );
test_filenames = fullfile(test_dir, {test_info.name});
% get the path to the precomputed LIC line sketches
lic_paths = fullfile(lic_dir, {test_info.name}); 

% save filenames
segment_dir = '../images/final-model';
segment_filenames = fullfile(segment_dir, {test_info.name});

for i=1 : length(test_filenames)
    % import the images
    test_image = im2double(imread(test_filenames{i}));
    % compute the drawing results
    test_drawing_segment = drawing_pipeline_hp(test_image, lic_paths{i});
    % save the results
    imwrite(test_drawing_segment, segment_filenames{i});
end
