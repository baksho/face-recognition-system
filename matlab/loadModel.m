function Model = loadModel(filename)
%LOADMODEL Load an Eigenface model from a MAT file.
    if nargin < 1
        filename = 'EigenfaceModel.mat';
    end
    data = load(filename, '-mat');
    if ~isfield(data, 'Model')
        error('File does not contain an Eigenface Model.');
    end
    Model = data.Model;
end
