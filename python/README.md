# Python Implementation

This folder contains the **2026 Python reproduction and modernization** of the original MATLAB PCA/Eigenface project.

It is intentionally **not** a line-by-line translation of the MATLAB code.

The original algorithm remains PCA/Eigenfaces, but the surrounding implementation is redesigned using contemporary Python software-engineering practices.

## What changed compared with the MATLAB project?

### 1. Modern project structure

The code uses a standard Python package layout:

```text
python/
├── src/eigenface/
├── scripts/
├── app/
├── tests/
├── pyproject.toml
└── requirements.txt
```

### 2. scikit-learn PCA

The MATLAB implementation explicitly works through the Eigenface/PCA mathematics. The Python implementation uses `sklearn.decomposition.PCA`, which provides a well-tested numerical implementation while retaining the same underlying dimensionality-reduction concept.

### 3. Configurable preprocessing

The original project fixed preprocessing around grayscale 250×250 images. The Python implementation retains that default but makes the dimensions and normalization explicit configuration parameters.

### 4. Vectorized recognition

Distance calculations are performed with NumPy rather than repeatedly growing arrays inside loops.

### 5. Model persistence

A trained recognizer can be saved and loaded as a model artifact using `joblib`.

### 6. Dataset manifests

The dataset is represented by a CSV manifest containing:

- subject
- image number
- train/test split
- source path

This makes experiments reproducible and keeps dataset definition separate from model code.

### 7. Unknown-face rejection

A nearest-neighbour classifier will always return some identity unless an explicit rejection mechanism exists. The Python implementation therefore estimates a rejection threshold from nearest-neighbour distances within the training projections.

### 8. Automated evaluation

The Python implementation reports:

- total test samples
- correct predictions
- rejected/unknown predictions
- accuracy
- confusion matrix

### 9. Automated tests

The repository contains unit tests for preprocessing, dataset manifests, model training, prediction and model persistence.

### 10. Modern UI

A Streamlit interface provides browser-based image upload and recognition. This is deliberately a Python-era replacement for the classic MATLAB desktop interaction, not a claim that it existed in 2014.

### 11. Optional webcam integration

OpenCV can be added for webcam-based face detection. The recognition model remains PCA/Eigenface; the webcam layer is only responsible for acquiring and locating face regions.

---

## Installation

From the repository root:

```bash
python -m venv .venv
```

Activate the environment and install:

```bash
pip install -r python/requirements.txt
pip install -e python
```

For development:

```bash
pip install -r python/requirements-dev.txt
```

---

## Prepare the dataset

Download the AT&T Database of Faces from the official source and extract it under:

```text
data/raw/att_faces/
```

Generate the shared manifest:

```bash
python python/scripts/build_manifest.py
```

The default configuration selects `s1`–`s10` and splits images 1–7 into training and 8–10 into testing.

---

## Train

```bash
python python/scripts/train.py
```

The default model is written to:

```text
python/models/eigenface.joblib
```

The Python implementation keeps enough PCA components to explain 95% of the training variance by default. The number can be changed from the command line.

---

## Recognize one image

```bash
python python/scripts/recognize.py path/to/query.pgm
```

The output contains:

- predicted identity
- projected-space distance
- rejection threshold
- recognized/rejected status
- nearest training image

---

## Evaluate

```bash
python python/scripts/evaluate.py
```

This evaluates the test split and prints the confusion matrix.

Do not compare an accuracy number from this branch with the historical project as though they were identical experiments unless the dataset, split, preprocessing and thresholding configuration are also identical.

---

## Streamlit UI

After training:

```bash
streamlit run python/app/streamlit_app.py
```

The UI allows a face image to be uploaded and displays the predicted identity, distance, threshold and nearest training image.

---

## Conceptual relationship to the MATLAB version

```text
MATLAB 2014                         Python 2026
────────────                         ───────────
CreateDatabase.m          ↔         dataset manifest + loader
EigenfaceCore.m           ↔         sklearn PCA
Recognition.m             ↔         EigenfaceRecognizer.predict()
Euclidean distance        ↔         vectorized NumPy distance
MATLAB figures            ↔         Streamlit UI
Manual workflow           ↔         CLI + scripted pipeline
Project database          ↔         CSV manifest + model artifact
```

The **algorithmic identity** is preserved. The implementation technology and engineering practices are intentionally modernized.

---

## Scope

This remains a classical Eigenface system. It is not intended to represent the current state of the art in face recognition.

The modernization is primarily about reproducibility, software architecture, evaluation, usability and maintainability, not about replacing Eigenfaces with a deep model.
