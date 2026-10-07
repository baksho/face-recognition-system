function Omega = projectImage(imageInput, MeanFace, Eigenfaces)
%PROJECTIMAGE Project a face into Eigenface space.

    Gamma = preprocessFace(imageInput);
    Omega = Eigenfaces' * (Gamma - MeanFace);
end
