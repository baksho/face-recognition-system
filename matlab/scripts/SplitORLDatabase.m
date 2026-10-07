function SplitORLDatabase
%SPLITORLDATABASE Create physical train/test directories from ORL.
%
% First 7 images of each subject -> train
% Last 3 images of each subject -> test
%
% This mirrors the 100-image project configuration used by
% BuildProjectDatabase.

    sourceRoot = uigetdir(pwd, 'Select extracted ORL database');
    if isequal(sourceRoot, 0), return; end

    outputRoot = uigetdir(pwd, 'Select output directory');
    if isequal(outputRoot, 0), return; end

    trainRoot = fullfile(outputRoot, 'TrainDatabase');
    testRoot = fullfile(outputRoot, 'TestDatabase');

    if ~exist(trainRoot, 'dir'), mkdir(trainRoot); end
    if ~exist(testRoot, 'dir'), mkdir(testRoot); end

    for person = 1:10
        subjectDir = fullfile(sourceRoot, sprintf('s%d', person));
        trainPerson = fullfile(trainRoot, sprintf('s%d', person));
        testPerson = fullfile(testRoot, sprintf('s%d', person));

        if ~exist(trainPerson, 'dir'), mkdir(trainPerson); end
        if ~exist(testPerson, 'dir'), mkdir(testPerson); end

        for imageNo = 1:10
            source = fullfile(subjectDir, sprintf('%d.pgm', imageNo));

            if imageNo <= 7
                destination = fullfile(trainPerson, sprintf('%d.pgm', imageNo));
            else
                destination = fullfile(testPerson, sprintf('%d.pgm', imageNo));
            end

            copyfile(source, destination);
        end
    end

    fprintf('Created:\n%s\n%s\n', trainRoot, testRoot);
end
