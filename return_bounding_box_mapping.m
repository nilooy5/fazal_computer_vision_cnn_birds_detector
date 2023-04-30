function image_box_map = return_bounding_box_mapping(image_names, bounding_boxes)
    image_box_map = containers.Map;
    for i = 1:size(image_names, 1)
        file_name = image_names{i,2}{1};
        file_name = split(file_name, "\");
        file_name = split(file_name, "/");
        image_box_map(file_name{end}) = [bounding_boxes{image_names{i,1}, 2:5}];
    end
end