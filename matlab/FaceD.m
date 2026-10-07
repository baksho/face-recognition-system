function [binaryImage, croppedImages, boundingBoxes] = FaceD(imagePath)
%FACED Detect/crop skin-colored regions using the legacy project approach.
%
% This is retained as a separate experimental module from the report.
% It is not required for Eigenface recognition.

    if nargin < 1
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', ...
            'Image files'}, 'Select input image');
        if isequal(file,0)
            binaryImage = [];
            croppedImages = {};
            boundingBoxes = [];
            return;
        end
        imagePath = fullfile(path, file);
    end

    rgbInputImage = imread(imagePath);

    % Modern MATLAB equivalent of the older applycform/makecform workflow.
    if ndims(rgbInputImage) ~= 3
        error('FaceD requires an RGB image.');
    end

    labInputImage = rgb2lab(im2double(rgbInputImage));
    L = labInputImage(:,:,1);

    % Local contrast enhancement as a practical replacement for the
    % obsolete BPDFHE implementation in the original MATLAB 2011 code.
    L = adapthisteq(L);

    labOutputImage = labInputImage;
    labOutputImage(:,:,1) = L;

    rgbOutputImage = lab2rgb(labOutputImage);
    img = im2uint8(rgbOutputImage);

    R = double(img(:,:,1));
    G = double(img(:,:,2));
    B = double(img(:,:,3));

    finalImage = (R > 92) & (G > 40) & (B > 20) & ...
                 ((max(cat(3,R,G,B),[],3) - min(cat(3,R,G,B),[],3)) > 15) & ...
                 (abs(R-G) > 15) & (R > G) & (R > B);

    binaryImage = bwareaopen(imfill(finalImage, 'holes'), 1890);

    labeledImage = bwlabel(binaryImage, 8);
    measurements = regionprops(labeledImage, 'BoundingBox');

    numberOfPeople = numel(measurements);
    croppedImages = cell(numberOfPeople,1);
    boundingBoxes = zeros(numberOfPeople,4);

    for k = 1:numberOfPeople
        box = measurements(k).BoundingBox;
        boundingBoxes(k,:) = box;
        croppedImages{k} = imcrop(rgbInputImage, box);
    end

    figure('Name','FaceD Result','NumberTitle','off');
    imshow(rgbInputImage);
    hold on;

    for k = 1:numberOfPeople
        rectangle('Position', measurements(k).BoundingBox, ...
                  'EdgeColor', 'g', 'LineWidth', 2);
    end

    title('Detected regions');
    hold off;
end
