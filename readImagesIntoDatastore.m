% makes sure everything is rgb
function [outputData] = readImagesIntoDatastore(imageFile)
    outputData = imread(imageFile);
    if size(outputData, 3) < 3
        outputData = cat(3, outputData, outputData, outputData);
    end

end