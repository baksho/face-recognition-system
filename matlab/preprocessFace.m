function vector = preprocessFace(imageInput)
%PREPROCESSFACE Convert an image to the project's canonical representation.
%
% Output: 250*250 column vector of double grayscale intensities.

    if ischar(imageInput)
        img = imread(imageInput);
    else
        img = imageInput;
    end

    if ndims(img) == 3
        img = rgb2gray(img);
    end

    img = imresize(img, [250 250], 'bilinear');
    img = double(img);

    vector = reshape(img', 250*250, 1);
end
