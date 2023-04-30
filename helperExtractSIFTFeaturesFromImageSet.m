function [outputFeatures, setLabels] = helperExtractSIFTFeaturesFromImageSet(imds,  num_of_features, maxFeatureLimit)
    % Extract SIFT features from an imageDatastore.
%     numAttributes = 6; from lab james
    FeatureSize = num_of_features * maxFeatureLimit;
    setLabels = imds.Labels;
    numImages = numel(imds.Files);
    outputFeatures  = zeros(numImages,FeatureSize,'single');

    % Process each image and extract features
    for j = 1:numImages
        img = readimage(imds, j);
        img = im2gray(img);

        % Apply pre-processing steps
        %img = imbinarize(img); 
        
        points = detectSIFTFeatures(img);  
        [features, valid_points] = extractFeatures(img, points);
        points = valid_points.selectStrongest(maxFeatureLimit);

        if ~isempty(points) 
            for p = 0:length(points)-1  
                l = points(p+1).Location; 
                outputFeatures(j, (p*num_of_features)+1) = l(1);
                outputFeatures(j, (p*num_of_features)+2) = l(2);
                outputFeatures(j, (p*num_of_features)+3) = points(p+1).Scale;  
                outputFeatures(j, (p*num_of_features)+4) = points(p+1).Octave;
                outputFeatures(j, (p*num_of_features)+5) = points(p+1).Orientation;
                outputFeatures(j, (p*num_of_features)+6) = points(p+1).Metric;
            end 
        end
    end

end % end of function