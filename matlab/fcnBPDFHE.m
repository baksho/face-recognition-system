function outputImage = fcnBPDFHE(inputImage, fuzzyMembershipType, parameters)
%FCNBPDFHE Compatibility implementation of the report's fuzzy histogram
%enhancement helper.
%
% The original appendix contains an incomplete/legacy implementation.
% This version provides a stable approximation with triangular or Gaussian
% fuzzy membership while retaining the same public function name.

    if nargin < 2 || isempty(fuzzyMembershipType)
        fuzzyMembershipType = 'triangular';
    end

    if nargin < 3 || isempty(parameters)
        parameters = 5;
    end

    originalClass = class(inputImage);

    if ~ismatrix(inputImage)
        error('Input image must be a 2-D grayscale image.');
    end

    normalized = mat2gray(double(inputImage));

    if strcmpi(fuzzyMembershipType, 'triangular')
        radius = max(1, round(parameters(1)));
        kernel = radius - abs(-radius:radius);
    elseif strcmpi(fuzzyMembershipType, 'gaussian')
        radius = max(1, round(parameters(1)));
        sigma = parameters(min(2,numel(parameters)));
        x = -radius:radius;
        kernel = exp(-(x.^2)/(sigma^2));
    elseif strcmpi(fuzzyMembershipType, 'custom')
        kernel = parameters(:)';
    else
        error('Unsupported membership type.');
    end

    kernel = kernel / sum(kernel);

    % Fuzzy-smoothed histogram.
    image8 = uint8(round(normalized * 255));
    histogramValues = imhist(image8);
    fuzzyHistogram = conv(double(histogramValues), kernel, 'same');

    cdf = cumsum(fuzzyHistogram);
    cdf = cdf / cdf(end);

    output8 = uint8(round(255 * cdf(double(image8)+1)));
    outputImage = cast(output8, originalClass);

    if strcmp(originalClass, 'double') || strcmp(originalClass, 'single')
        outputImage = im2double(output8);
    end
end
