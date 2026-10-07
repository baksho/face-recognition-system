function showEigenfaces(Eigenfaces, ImageSize, NumberToShow)
%SHOWEIGENFACES Display the leading Eigenfaces.

    if nargin < 3
        NumberToShow = min(16, size(Eigenfaces,2));
    end

    NumberToShow = min(NumberToShow, size(Eigenfaces,2));

    figure('Name', 'Eigenfaces', 'NumberTitle', 'off');

    rows = ceil(sqrt(NumberToShow));
    cols = ceil(NumberToShow / rows);

    for i = 1:NumberToShow
        subplot(rows, cols, i);

        face = reshape(Eigenfaces(:,i), ImageSize(2), ImageSize(1))';
        face = mat2gray(face);

        imshow(face);
        title(sprintf('Eigenface %d', i));
    end
end
