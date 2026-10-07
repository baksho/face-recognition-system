function saveModel(Model, filename)
%SAVEMODEL Save Eigenface model to a MAT file.
    if nargin < 2
        filename = 'EigenfaceModel.mat';
    end
    save(filename, 'Model', '-mat');
end
