function [output_data] = read_bounding_box_image_to_datastore(image_file, image_box_map)
    % % function [outputData] = readImagesIntoDatastoreBB(imageFile, imageNames, boundingBox)
    % This helper function defines the ReadFCN function for image datastores
    % related to the CUB_200_2011 dataset.
    % It takes a file name of an image file as input.
    % We also provide a map from the file name to the related bounding box.
    % Authors: Roland Goecke and James Ireland
    % Date created: 02/05/22
    % Date last updated: 17/04/23
   
    % Read image file
    if isfile(image_file)
        output_data = imread(image_file);
    else
        disp(image_file)
    end
   
    % Check if image is RGB or grayscal
    if size(output_data, 3) < 3
        output_data = cat(3, output_data, output_data, output_data);
    end
   
    file_name = split(image_file, "/");
    file_name = split(file_name, "\");
    x_y_width_height_Bounding_Box = image_box_map(file_name{end});
   
    x = x_y_width_height_Bounding_Box(1);
    y = x_y_width_height_Bounding_Box(2);
    width = x_y_width_height_Bounding_Box(3);
    height = x_y_width_height_Bounding_Box(4);
   
    if x > size(output_data, 2) | y > size(output_data, 1)  
            disp("error")
            disp([index, x, y, width, height])
    else
        output_data = imcrop(output_data, [x, y, width, height]);
    end
     
end