function BuildProjectDatabase
%BUILDPROJECTDATABASE Build the 100-image MATLAB project database.
%
% Uses the first ten subjects and all ten images per subject from the
% pre-2014 AT&T/ORL database. The images are stored as 250x250 vectors.
%
% The resulting MAT file is data/FaceDatabase.mat.

    root = fileparts(fileparts(mfilename('fullpath')));
    outputFile = fullfile(root, 'data', 'FaceDatabase.mat');

    sourceRoot = uigetdir(pwd, ...
        'Select extracted AT&T/ORL face database (contains s1, s2, ...)');

    if isequal(sourceRoot, 0)
        return;
    end

    people = 10;
    imagesPerPerson = 10;

    vectors = [];
    labels = {};
    filenames = {};
    sourcePaths = {};
    originalSizes = zeros(people*imagesPerPerson, 2);
    counter = 0;

    for person = 1:people
        subjectDir = fullfile(sourceRoot, sprintf('s%d', person));
        if ~exist(subjectDir, 'dir')
            error('Missing subject directory: %s', subjectDir);
        end

        for imageNo = 1:imagesPerPerson
            imagePath = fullfile(subjectDir, sprintf('%d.pgm', imageNo));

            if ~exist(imagePath, 'file')
                error('Missing image: %s', imagePath);
            end

            original = imread(imagePath);
            counter = counter + 1;

            vectors(:, counter) = preprocessFace(original); %#ok<AGROW>
            labels{counter,1} = sprintf('s%d', person); %#ok<AGROW>
            filenames{counter,1} = sprintf('%d.pgm', imageNo); %#ok<AGROW>
            sourcePaths{counter,1} = imagePath; %#ok<AGROW>
            originalSizes(counter,:) = [size(original,1), size(original,2)];
        end
    end

    % Reproduce a conventional train/test split while keeping all 100 images
    % in the database. Images 1-7 are training and 8-10 are testing.
    split = cell(counter,1);
    for i = 1:counter
        imageNo = str2double(regexprep(filenames{i}, '\.pgm$', ''));
        if imageNo <= 7
            split{i} = 'train';
        else
            split{i} = 'test';
        end
    end

    Database = struct();
    Database.ProjectName = 'Face Recognition System Using MATLAB';
    Database.Dataset = 'AT&T/ORL Database of Faces';
    Database.DatasetSelection = 'Subjects s1-s10, images 1-10';
    Database.ImageSize = [250 250];
    Database.NumImages = counter;
    Database.NumPeople = people;
    Database.ImagesPerPerson = imagesPerPerson;
    Database.Vectors = vectors;
    Database.Labels = labels;
    Database.Filenames = filenames;
    Database.SourcePaths = sourcePaths;
    Database.OriginalSizes = originalSizes;
    Database.Split = split;
    Database.Created = datestr(now);

    if ~exist(fileparts(outputFile), 'dir')
        mkdir(fileparts(outputFile));
    end

    save(outputFile, 'Database', '-mat');

    fprintf('\nDatabase created successfully.\n');
    fprintf('Images: %d\n', Database.NumImages);
    fprintf('People: %d\n', Database.NumPeople);
    fprintf('Training images: %d\n', sum(strcmp(Database.Split, 'train')));
    fprintf('Test images: %d\n', sum(strcmp(Database.Split, 'test')));
    fprintf('Saved to: %s\n', outputFile);
end
