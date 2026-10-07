function results = evaluateModel(TestDatabasePath, TrainDatabasePath, m, A, Eigenfaces)
%EVALUATEMODEL Evaluate recognition over a labelled test directory.
%
% Expected layout:
%   TestDatabasePath/
%       s1/*.pgm
%       s2/*.pgm
%       ...

    personDirs = dir(TestDatabasePath);
    personDirs = personDirs([personDirs.isdir]);
    personDirs = personDirs(~ismember({personDirs.name}, {'.','..'}));

    total = 0;
    correct = 0;
    rejected = 0;

    for p = 1:numel(personDirs)
        expectedLabel = personDirs(p).name;
        personPath = fullfile(TestDatabasePath, expectedLabel);
        files = listImages(personPath);

        for i = 1:numel(files)
            testPath = fullfile(personPath, files{i});
            [~, ~, ~, recognized] = Recognition( ...
                testPath, m, A, Eigenfaces, TrainDatabasePath);

            total = total + 1;

            if recognized
                % The training folder is expected to use the same
                % subject-folder convention. Determine the matched file's
                % subject by searching the training directories.
                [~, matchedLabel] = findMatchedLabel( ...
                    TrainDatabasePath, testPath, m, A, Eigenfaces);

                if strcmp(matchedLabel, expectedLabel)
                    correct = correct + 1;
                end
            else
                rejected = rejected + 1;
            end
        end
    end

    results = struct();
    results.Total = total;
    results.Correct = correct;
    results.Rejected = rejected;
    results.Accuracy = correct / max(total,1);
end


function [matchedFile, matchedLabel] = findMatchedLabel( ...
    TrainDatabasePath, testPath, m, A, Eigenfaces)

    [matchedFile, ~, idx, recognized] = Recognition( ...
        testPath, m, A, Eigenfaces, TrainDatabasePath);

    matchedLabel = '';

    if ~recognized || strcmp(matchedFile, 'UNKNOWN')
        return;
    end

    dirs = dir(TrainDatabasePath);
    dirs = dirs([dirs.isdir]);
    dirs = dirs(~ismember({dirs.name}, {'.','..'}));

    remaining = idx;
    for d = 1:numel(dirs)
        files = listImages(fullfile(TrainDatabasePath, dirs(d).name));
        if remaining <= numel(files)
            matchedLabel = dirs(d).name;
            return;
        end
        remaining = remaining - numel(files);
    end
end


function files = listImages(folder)
    extensions = {'*.jpg','*.JPG','*.jpeg','*.JPEG', ...
                  '*.png','*.PNG','*.bmp','*.BMP', ...
                  '*.pgm','*.PGM'};

    files = {};
    for k = 1:numel(extensions)
        d = dir(fullfile(folder, extensions{k}));
        for i = 1:numel(d)
            if ~d(i).isdir
                files{end+1} = d(i).name; %#ok<AGROW>
            end
        end
    end

    files = sort(files);
end
