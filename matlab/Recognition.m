function [OutputName, Euc_dist, RecognizedIndex, Recognized] = Recognition( ...
    TestImage, m, A, Eigenfaces, TrainDatabasePath, Threshold)
%RECOGNITION Recognize a test face using Euclidean distance in eigenspace.
%
% This retains the interface and behavior of the original Recognition.m
% while adding proper image preprocessing and optional unknown rejection.

    if nargin < 6
        Threshold = [];
    end

    ProjectedImages = Eigenfaces' * A;

    InputProjection = projectImage(TestImage, m, Eigenfaces);

    Euc_dist = zeros(1, size(ProjectedImages, 2));

    for i = 1:size(ProjectedImages, 2)
        Euc_dist(i) = norm(InputProjection - ProjectedImages(:, i))^2;
    end

    [Euc_dist_min, RecognizedIndex] = min(Euc_dist);

    files = listImageFilesLocal(TrainDatabasePath);

    if isempty(files)
        error('No training images found.');
    end

    if RecognizedIndex > numel(files)
        error('Training image index exceeds directory contents.');
    end

    OutputName = relativeImagePath(TrainDatabasePath, files{RecognizedIndex});

    if isempty(Threshold)
        % A conservative data-dependent threshold based on training
        % nearest-neighbour distances.
        threshold = estimateRecognitionThreshold(ProjectedImages);
    else
        threshold = Threshold;
    end

    Recognized = Euc_dist_min <= threshold;

    if ~Recognized
        OutputName = 'UNKNOWN';
    end

    fprintf('Minimum squared Euclidean distance: %.6f\n', Euc_dist_min);
    fprintf('Recognition threshold: %.6f\n', threshold);
    fprintf('Recognized index: %d\n', RecognizedIndex);
end


function threshold = estimateRecognitionThreshold(P)
    if size(P,2) < 2
        threshold = inf;
        return;
    end

    distances = inf(1, size(P,2));

    for i = 1:size(P,2)
        d = sum(bsxfun(@minus, P, P(:,i)).^2, 1);
        d(i) = inf;
        distances(i) = min(d);
    end

    med = median(distances);
    madValue = median(abs(distances - med));
    threshold = max([med + 4*max(madValue, eps), 1.5*med]);
end


function files = listImageFilesLocal(folder)
    files = listImageFilesRecursive(folder);
end

function relativePath = relativeImagePath(root, absolutePath)
    prefix = [root filesep];
    if strncmp(absolutePath, prefix, length(prefix))
        relativePath = absolutePath(length(prefix)+1:end);
    else
        relativePath = absolutePath;
    end
end
