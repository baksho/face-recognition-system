function testEigenfacePipeline
%TESTEIGENFACEPIPELINE Basic self-contained numerical pipeline test.

    rng(42);

    imageSize = [250 250];
    nPixels = prod(imageSize);
    nPeople = 3;
    nPerPerson = 4;

    X = zeros(nPixels, nPeople*nPerPerson);

    labels = cell(nPeople*nPerPerson, 1);
    index = 0;

    for person = 1:nPeople
        base = zeros(imageSize);
        base(60*person:60*person+40, 80:170) = 80*person;

        for j = 1:nPerPerson
            index = index + 1;
            noise = randn(imageSize) * 2;
            X(:,index) = reshape(base + noise, [], 1);
            labels{index} = sprintf('person_%d', person);
        end
    end

    [m, A, Eigenfaces, Model] = EigenfaceCore(X, 5); %#ok<ASGLU>

    assert(size(m,1) == nPixels);
    assert(size(A,2) == size(X,2));
    assert(size(Eigenfaces,1) == nPixels);
    assert(Model.ImageSize(1) == 250);

    Omega = projectImage(X(:,1), m, Eigenfaces);
    assert(numel(Omega) == size(Eigenfaces,2));

    tempImage = [tempname '.mat'];
    saveModel(Model, tempImage);
    loaded = loadModel(tempImage);
    delete(tempImage);

    assert(isequal(size(loaded.Eigenfaces), size(Model.Eigenfaces)));

    fprintf('All Eigenface pipeline tests passed.\n');
end
