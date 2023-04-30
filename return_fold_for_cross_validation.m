function [training_combined_datastore, validation_combined_datastore, test_combined_datastore, training_image_datastore, ...
    validation_image_datastore, testing_image_datastore, class_names] = ...
    return_fold_for_cross_validation(fold_number, fold_1_datastore, fold_2_datastore, fold_3_datastore, fold_4_datastore, ...
    fold_5_datastore, folder_path, images_text_folder_path, target_size)
    
    % As per the assignment description, we set up different trainig,
    % validation and test fold combinations by assigning the folds differently
    % for each of the five runs in the fivefold cross-validation.
    if fold_number == 1
        % Run 1: Folds 1-3 for training, Fold 4 for validation, Fold 5 for test 
        training_image_datastore = imageDatastore(cat(1, fold_1_datastore.Files, ...
                                             fold_2_datastore.Files, fold_3_datastore.Files));
        training_image_datastore.Labels = cat(1, fold_1_datastore.Labels, fold_2_datastore.Labels, ...
                                     fold_3_datastore.Labels);
        validation_image_datastore = fold_4_datastore;
        testing_image_datastore = fold_5_datastore;
    elseif fold_number == 2
        % Run 2: Parts 2-4 for training, Part 5 for validation, Part 1 for test 
        training_image_datastore = imageDatastore(cat(1, fold_2_datastore.Files, ...
                                             fold_3_datastore.Files, fold_4_datastore.Files));
        training_image_datastore.Labels = cat(1, fold_2_datastore.Labels, fold_3_datastore.Labels, ...
                                     fold_4_datastore.Labels);
        validation_image_datastore = fold_5_datastore;
        testing_image_datastore = fold_1_datastore;
    elseif fold_number == 3
        % Run 3: Parts 3-5 for training, Part 1 for validation, Part 2 for test 
        training_image_datastore = imageDatastore(cat(1, fold_3_datastore.Files, ...
                                             fold_4_datastore.Files, fold_5_datastore.Files));
        training_image_datastore.Labels = cat(1, fold_3_datastore.Labels, fold_4_datastore.Labels, ...
                                     fold_5_datastore.Labels);
        validation_image_datastore = fold_1_datastore;
        testing_image_datastore = fold_2_datastore;
    elseif fold_number == 4  
        % Run 4: Parts 4, 5, and 1 for training, Part 2 for validation, Part 3 for test 
        training_image_datastore = imageDatastore(cat(1, fold_4_datastore.Files, ...
                                             fold_5_datastore.Files, fold_1_datastore.Files));
        training_image_datastore.Labels = cat(1, fold_4_datastore.Labels, fold_5_datastore.Labels, ...
                                     fold_1_datastore.Labels);
        validation_image_datastore = fold_2_datastore;
        testing_image_datastore = fold_3_datastore;
    elseif fold_number == 5
        %Run 5: Parts 5, 1, and 2 for training, Part 3 for validation, Part 4 for test
        training_image_datastore = imageDatastore(cat(1, fold_5_datastore.Files, ...
                                             fold_1_datastore.Files, fold_2_datastore.Files));
        training_image_datastore.Labels = cat(1, fold_5_datastore.Labels, fold_1_datastore.Labels, ...
                                     fold_2_datastore.Labels);
        validation_image_datastore = fold_3_datastore;
        testing_image_datastore = fold_4_datastore;
    end
    
    % Get training, validation and testing image file names
    training_image_names = training_image_datastore.Files;
    validation_image_names = validation_image_datastore.Files;
    testing_image_names = testing_image_datastore.Files;
    
    % Read class info from the relevant text files - may not required
    class_names = readtable(folder_path + "classes.txt", ...
        'ReadVariableNames', false);
    class_names.Properties.VariableNames = {'index', 'className'};
    
    image_class_labels = readtable(folder_path + "image_class_labels.txt", ...
        'ReadVariableNames', false);
    image_class_labels.Properties.VariableNames = {'index', 'classLabel'};
    
    % Read bounding box information from bounding_boxes.txt. for cropping.
    % The format is: image index, x-coordinate top-left corner, 
    % y-coordinate top-left corner, width, height.
    bounding_boxes = readtable(folder_path + "bounding_boxes.txt", ... 
        'ReadVariableNames', false);
    bounding_boxes.Properties.VariableNames = {'index', 'x', 'y', 'w', 'h'};
    
    % Map bounding box information to the respective image file name
    train_image_box_map = return_mapping(training_image_names, bounding_boxes, ...
        images_text_folder_path);
    val_image_box_map = return_mapping(validation_image_names, bounding_boxes, ...
        images_text_folder_path);
    test_image_box_map = return_mapping(testing_image_names, bounding_boxes, ...
        images_text_folder_path);
    
    % Crop images to the bounding box area while reading in the image data
    training_image_datastore.ReadFcn = @(file_name) ...
        read_bounding_box_image_to_datastore(file_name, train_image_box_map);
    validation_image_datastore.ReadFcn = @(file_name) ...
        read_bounding_box_image_to_datastore(file_name, val_image_box_map);
    testing_image_datastore.ReadFcn = @(file_name) ...
        read_bounding_box_image_to_datastore(file_name, test_image_box_map);
    
    % Combine transformed datastores and labels 
    training_labels = arrayDatastore(training_image_datastore.Labels);
    validation_labels = arrayDatastore(validation_image_datastore.Labels);
    testing_labels = arrayDatastore(testing_image_datastore.Labels);
    
    training_combined_datastore = combine(training_image_datastore, training_labels);
    validation_combined_datastore = combine(validation_image_datastore, validation_labels);
    test_combined_datastore = combine(testing_image_datastore, testing_labels);
    
    % Resize all images to a common width and height
    training_combined_datastore = transform(training_combined_datastore, @(x) preprocess_image(x, target_size));
    validation_combined_datastore = transform(validation_combined_datastore, @(x) preprocess_image(x, target_size));
    test_combined_datastore = transform(test_combined_datastore, @(x) preprocess_image(x, target_size));
    
    %% Helper function for resizing images in transform
    function data_out = preprocess_image(data, target_size)
        try
            data_out{1} = imresize(data{1}, target_size(1:2)); % Resize images
            transform_flip = randomAffine2d('XReflection', true);
            rout = affineOutputView(target_size, transform_flip);
            data_out{1} = imwarp(data_out{1}, transform_flip, 'OutputView', rout);
            data_out{2} = data{2};  % Keep labels as they are
        catch e
            % This is solely for debugging
            disp(e) 
        end
    end
    
    %% Helper function mapping image names to bounding boxes and vice versa
    function image_box_map = return_mapping(ImageNames, boundingBoxes, images_text_folder_path)
        mapping = readlines(images_text_folder_path);
        image_box_map = containers.Map;
        for i = 1:size(ImageNames, 1) 
            %fn = ImageNames{i};
            fn = split(ImageNames{i}, ["/", "\"]); % WinOS/MacOS/Linux
            ix = find(contains(mapping, fn{end}));
            image_box_map(fn{end}) = [boundingBoxes{ix, 2:5}];
        end
    end

end
