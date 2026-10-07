function DownloadORL
%DOWNLOADORL Open the official AT&T/Cambridge database page.
%
% The third-party dataset is not redistributed by this repository.

url = 'https://cam-orl.co.uk/facedatabase.html';
web(url, '-browser');
fprintf('Download att_faces.zip from the official database page.\n');
fprintf('%s\n', url);
