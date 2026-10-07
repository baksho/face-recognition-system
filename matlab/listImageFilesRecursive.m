function files = listImageFilesRecursive(folder)
%LISTIMAGEFILESRECURSIVE Recursively list supported image files.
% Compatible with older MATLAB releases such as MATLAB 2011a.

    extensions = {'.jpg','.jpeg','.png','.bmp','.pgm','.tif','.tiff'};
    files = {};

    entries = dir(folder);
    for i = 1:numel(entries)
        name = entries(i).name;
        if entries(i).isdir
            if ~strcmp(name, '.') && ~strcmp(name, '..')
                child = listImageFilesRecursive(fullfile(folder, name));
                files = [files child]; %#ok<AGROW>
            end
        else
            [~,~,ext] = fileparts(name);
            if any(strcmpi(ext, extensions))
                files{end+1} = fullfile(folder, name); %#ok<AGROW>
            end
        end
    end

    files = sort(files);
end
