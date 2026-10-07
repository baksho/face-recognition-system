# MATLAB Implementation

This folder contains the **faithful MATLAB-oriented reproduction** of the 2014 B.Tech project.

The original project was developed in **MATLAB 2011a**. The code here intentionally retains the original programming style and interaction model where that is useful for historical fidelity.

## What is preserved

The implementation retains the original PCA/Eigenface pipeline:

```text
Input image
   ↓
Grayscale conversion
   ↓
250 × 250 normalization
   ↓
Vectorization
   ↓
Mean face
   ↓
Mean centering
   ↓
PCA / Eigenfaces
   ↓
Projection
   ↓
Euclidean distance
   ↓
Nearest known face
   ↓
Recognition / unknown rejection
```

The classic MATLAB interaction functions used by the original project are intentionally retained:

- `uigetdir`
- `inputdlg`
- `figure`
- `imshow`

`Example.m` is the closest entry point to the original report's workflow.

`FaceRecognitionGUI.m` is an additional single-window GUI wrapper around the same pipeline. It is an extension rather than a claim that the original 2014 project used this exact window layout.

## Main files

| File | Purpose |
|---|---|
| `Example.m` | Original-style interactive workflow |
| `FaceRecognitionGUI.m` | Extended MATLAB GUI |
| `CreateDatabase.m` | Builds image matrix from a training directory |
| `EigenfaceCore.m` | Computes mean face and Eigenface representation |
| `Recognition.m` | Projects a query image and performs distance-based recognition |
| `preprocessFace.m` | Common grayscale/resize preprocessing |
| `projectImage.m` | Projection helper |
| `evaluateModel.m` | Batch test-set evaluation |
| `showEigenfaces.m` | Visualize learned Eigenfaces |
| `FaceD.m` | Auxiliary image-processing experiment preserved from the report |
| `fcnBPDFHE.m` | Fuzzy histogram enhancement helper preserved from the report |
| `scripts/BuildProjectDatabase.m` | Build the reproducibility dataset database |
| `scripts/SplitORLDatabase.m` | Create training/test directory structure |
| `scripts/DownloadORL.m` | Dataset acquisition helper |

## Dataset reproduction

Download the AT&T Database of Faces and extract it under:

```text
data/raw/att_faces/
```

The default reproduction uses `s1`–`s10`, ten images per subject.

Then run the database-building scripts from MATLAB. The exact commands and parameters are documented in `docs/reproduction.md`.
