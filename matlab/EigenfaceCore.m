function [m, A, Eigenfaces, Model] = EigenfaceCore(T, NumberOfEigenfaces)
%EIGENFACECORE Train an Eigenface/PCA model.
%
%   [m,A,Eigenfaces,Model] = EigenfaceCore(T)
%
% T is a matrix whose columns are vectorized training faces.
%
% The compact covariance approach follows the mathematics in the original
% report: L = A' * A is used instead of directly constructing A * A'.

    if nargin < 2
        NumberOfEigenfaces = [];
    end

    T = double(T);

    m = mean(T, 2);
    A = bsxfun(@minus, T, m);

    L = A' * A;
    [V, D] = eig(L);

    eigenvalues = real(diag(D));
    [eigenvalues, order] = sort(eigenvalues, 'descend');
    V = real(V(:, order));

    keep = eigenvalues > max(eigenvalues) * 1e-10;
    eigenvalues = eigenvalues(keep);
    V = V(:, keep);

    Eigenfaces = A * V;

    % Normalize each eigenface.
    for i = 1:size(Eigenfaces, 2)
        n = norm(Eigenfaces(:, i));
        if n > eps
            Eigenfaces(:, i) = Eigenfaces(:, i) / n;
        end
    end

    if ~isempty(NumberOfEigenfaces)
        NumberOfEigenfaces = min(NumberOfEigenfaces, size(Eigenfaces, 2));
        Eigenfaces = Eigenfaces(:, 1:NumberOfEigenfaces);
        eigenvalues = eigenvalues(1:NumberOfEigenfaces);
    end

    Model = struct();
    Model.MeanFace = m;
    Model.Eigenfaces = Eigenfaces;
    Model.Eigenvalues = eigenvalues;
    Model.ImageSize = [250 250];
    Model.NumberOfTrainingImages = size(T, 2);
end
