function T = CreateDatabase(TrainDatabasePath)
%CREATEDATABASE Create a training matrix from a directory of face images.
%
%   T = CreateDatabase(TrainDatabasePath)
%
%   Each image is converted to grayscale, resized to 250x250, vectorized
%   column-wise, and stored as one column of T.
%
%   This replaces the fragile sequential-filename assumptions in the
%   original 2014 script while preserving its mathematical behavior.

    if nargin < 1 || ~ischar(TrainDatabasePath)
        error('CreateDatabase requires a training directory path.');
    end

    files = listImageFiles(TrainDatabasePath);
    if isempty(files)
        error('No supported image files found in: %s', TrainDatabasePath);
    end

    firstImage = preprocessFace(fullfile(TrainDatabasePath, files{1}));
    T = zeros(numel(firstImage), numel(files), 'double');

    for i = 1:numel(files)
        imagePath = files{i};
        T(:, i) = preprocessFace(imagePath);
    end

    fprintf('Training images: %d\n', size(T, 2));
    fprintf('Feature dimension: %d\n', size(T, 1));
end


function files = listImageFiles(folder)
    files = listImageFilesRecursive(folder);
end
