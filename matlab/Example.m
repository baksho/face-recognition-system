function Example
%EXAMPLE Original-style command-line workflow from the B.Tech project.
%
% Select training directory, select test directory, enter test image
% number, train PCA/Eigenfaces, and display the matched image.

    close all;
    clc;

    TrainDatabasePath = uigetdir(pwd, ...
        'Select training database path');

    if isequal(TrainDatabasePath, 0)
        return;
    end

    TestDatabasePath = uigetdir(pwd, ...
        'Select test database path');

    if isequal(TestDatabasePath, 0)
        return;
    end

    prompt = {'Enter test image name (number):'};
    dlg_title = 'Input of PCA-Based Face Recognition System';
    answer = inputdlg(prompt, dlg_title, 1, {'1'});

    if isempty(answer)
        return;
    end

    TestImageName = strtrim(answer{1});
    TestImage = resolveTestImage(TestDatabasePath, TestImageName);

    if isempty(TestImage)
        errordlg('Could not find the requested test image.', 'Input Error');
        return;
    end

    T = CreateDatabase(TrainDatabasePath);
    [m, A, Eigenfaces] = EigenfaceCore(T);

    [OutputName, Euc_dist, ~, Recognized] = Recognition( ...
        TestImage, m, A, Eigenfaces, TrainDatabasePath);

    figure('Name', 'Test Image', 'NumberTitle', 'off');
    imshow(imread(TestImage));
    title('Test Image');

    if Recognized
        selectedPath = fullfile(TrainDatabasePath, OutputName);

        figure('Name', 'Equivalent Image', 'NumberTitle', 'off');
        imshow(imread(selectedPath));
        title(['Equivalent Image: ' OutputName]);

        fprintf('\nMatched image is: %s\n', OutputName);
    else
        fprintf('\nNo sufficiently close face was found.\n');
        fprintf('Nearest candidate was: %s\n', OutputName);
    end

    fprintf('Minimum squared distance: %.6f\n', min(Euc_dist));
end


function pathOut = resolveTestImage(folder, numberOrName)
    pathOut = '';

    candidates = {numberOrName};

    number = str2double(numberOrName);
    if ~isnan(number)
        candidates = { ...
            [numberOrName '.jpg'], ...
            [numberOrName '.JPG'], ...
            [numberOrName '.jpeg'], ...
            [numberOrName '.png'], ...
            [numberOrName '.pgm'], ...
            [numberOrName '.bmp']};
    end

    files = listImageFilesRecursive(folder);
    for i = 1:numel(candidates)
        for j = 1:numel(files)
            [~, name, ext] = fileparts(files{j});
            if strcmpi([name ext], candidates{i})
                pathOut = files{j};
                return;
            end
        end
    end
end
