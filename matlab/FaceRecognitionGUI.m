function FaceRecognitionGUI
%FACERECOGNITIONGUI Graphical user interface for the Eigenface system.
%
% The controls intentionally mirror the workflow shown in the original
% report: training database -> test database -> test image number -> output.

    handles = struct();
    handles.TrainDatabasePath = '';
    handles.TestDatabasePath = '';
    handles.TestImagePath = '';
    handles.Model = [];
    handles.LastResult = [];

    screen = get(0, 'ScreenSize');
    width = 760;
    height = 520;
    left = max(20, (screen(3)-width)/2);
    bottom = max(40, (screen(4)-height)/2);

    handles.Figure = figure( ...
        'Name', 'PCA-Based Face Recognition System', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Resize', 'off', ...
        'Position', [left bottom width height], ...
        'Color', [0.94 0.94 0.94]);

    uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'PCA-Based Face Recognition System', ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'Position', [150 465 460 35], ...
        'BackgroundColor', [0.94 0.94 0.94]);

    handles.TrainText = uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'Training database: not selected', ...
        'HorizontalAlignment', 'left', ...
        'Position', [35 410 500 30]);

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Select Training Database', ...
        'FontSize', 11, ...
        'Position', [555 405 170 40], ...
        'Callback', @selectTraining);

    handles.TestText = uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'Test database: not selected', ...
        'HorizontalAlignment', 'left', ...
        'Position', [35 350 500 30]);

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Select Test Database', ...
        'FontSize', 11, ...
        'Position', [555 345 170 40], ...
        'Callback', @selectTest);

    uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'Test image number:', ...
        'HorizontalAlignment', 'left', ...
        'Position', [35 290 180 30]);

    handles.ImageNumber = uicontrol(handles.Figure, 'Style', 'edit', ...
        'String', '1', ...
        'BackgroundColor', 'white', ...
        'Position', [210 292 100 28]);

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Train && Recognize', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'Position', [555 280 170 45], ...
        'Callback', @trainRecognize);

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Show Eigenfaces', ...
        'Position', [555 220 170 40], ...
        'Callback', @showEigenfacesCallback);

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Evaluate Test Set', ...
        'Position', [555 165 170 40], ...
        'Callback', @evaluateCallback);

    handles.Status = uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'Status: Ready', ...
        'HorizontalAlignment', 'left', ...
        'Position', [35 215 480 40], ...
        'BackgroundColor', [0.94 0.94 0.94]);

    handles.Result = uicontrol(handles.Figure, 'Style', 'text', ...
        'String', 'Result will appear here.', ...
        'FontSize', 12, ...
        'HorizontalAlignment', 'left', ...
        'Position', [35 90 480 100], ...
        'BackgroundColor', 'white');

    uicontrol(handles.Figure, 'Style', 'pushbutton', ...
        'String', 'Exit', ...
        'Position', [555 80 170 40], ...
        'Callback', @(~,~) close(handles.Figure));

    guidata(handles.Figure, handles);


    function selectTraining(~, ~)
        handles = guidata(handles.Figure);
        folder = uigetdir(pwd, 'Select training database');
        if isequal(folder, 0), return; end
        handles.TrainDatabasePath = folder;
        set(handles.TrainText, 'String', ['Training database: ' folder]);
        set(handles.Status, 'String', 'Status: Training database selected.');
        guidata(handles.Figure, handles);
    end


    function selectTest(~, ~)
        handles = guidata(handles.Figure);
        folder = uigetdir(pwd, 'Select test database');
        if isequal(folder, 0), return; end
        handles.TestDatabasePath = folder;
        set(handles.TestText, 'String', ['Test database: ' folder]);
        set(handles.Status, 'String', 'Status: Test database selected.');
        guidata(handles.Figure, handles);
    end


    function trainRecognize(~, ~)
        handles = guidata(handles.Figure);

        if isempty(handles.TrainDatabasePath) || isempty(handles.TestDatabasePath)
            errordlg('Please select both training and test databases.', 'Missing Input');
            return;
        end

        testNumber = str2double(get(handles.ImageNumber, 'String'));
        if isnan(testNumber)
            errordlg('Enter a numeric test image number.', 'Invalid Input');
            return;
        end

        handles.Status = handles.Status; %#ok<NASGU>
        set(handles.Status, 'String', 'Status: Training PCA/Eigenface model...');
        drawnow;

        try
            T = CreateDatabase(handles.TrainDatabasePath);
            [m, A, Eigenfaces, Model] = EigenfaceCore(T);
            handles.Model = Model;

            testPath = findNthImage(handles.TestDatabasePath, testNumber);
            if isempty(testPath)
                error('Requested test image was not found.');
            end

            [OutputName, Euc_dist, idx, Recognized] = Recognition( ...
                testPath, m, A, Eigenfaces, handles.TrainDatabasePath);

            figure('Name', 'Test Image', 'NumberTitle', 'off');
            imshow(imread(testPath));
            title('Test Image');

            if Recognized
                matchedPath = fullfile(handles.TrainDatabasePath, OutputName);
                figure('Name', 'Equivalent Image', 'NumberTitle', 'off');
                imshow(imread(matchedPath));
                title(['Equivalent Image: ' OutputName]);

                resultText = sprintf(['Recognized identity / image: %s\n' ...
                    'Training image index: %d\n' ...
                    'Minimum squared distance: %.4f'], ...
                    OutputName, idx, min(Euc_dist));
            else
                resultText = sprintf(['UNKNOWN FACE\n' ...
                    'Nearest training image: %d\n' ...
                    'Minimum squared distance: %.4f'], ...
                    idx, min(Euc_dist));
            end

            set(handles.Result, 'String', resultText);
            set(handles.Status, 'String', 'Status: Recognition complete.');
        catch ME
            errordlg(ME.message, 'Recognition Error');
            set(handles.Status, 'String', 'Status: Error.');
        end

        guidata(handles.Figure, handles);
    end


    function showEigenfacesCallback(~, ~)
        handles = guidata(handles.Figure);
        if isempty(handles.Model)
            errordlg('Train the model first.', 'No Model');
            return;
        end
        showEigenfaces(handles.Model.Eigenfaces, handles.Model.ImageSize);
    end


    function evaluateCallback(~, ~)
        handles = guidata(handles.Figure);
        if isempty(handles.TrainDatabasePath) || isempty(handles.TestDatabasePath)
            errordlg('Select both training and test databases.', 'Missing Input');
            return;
        end

        set(handles.Status, 'String', 'Status: Evaluating test set...');
        drawnow;

        try
            T = CreateDatabase(handles.TrainDatabasePath);
            [m, A, Eigenfaces] = EigenfaceCore(T);
            results = evaluateModel( ...
                handles.TestDatabasePath, handles.TrainDatabasePath, ...
                m, A, Eigenfaces);

            msgbox(sprintf(['Test images: %d\n' ...
                'Recognized correctly: %d\n' ...
                'Rejected as unknown: %d\n' ...
                'Accuracy: %.2f%%'], ...
                results.Total, results.Correct, results.Rejected, ...
                results.Accuracy*100), ...
                'Evaluation');
            set(handles.Status, 'String', 'Status: Evaluation complete.');
        catch ME
            errordlg(ME.message, 'Evaluation Error');
            set(handles.Status, 'String', 'Status: Error.');
        end
    end
end


function pathOut = findNthImage(folder, number)
    files = listImageFilesRecursive(folder);
    if number < 1 || number > numel(files)
        pathOut = '';
    else
        pathOut = files{number};
    end
end
