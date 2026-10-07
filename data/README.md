# Shared Data

This directory contains data-related material shared by the MATLAB and Python implementations.

## Dataset

The reproduction uses the pre-2014 AT&T Database of Faces (formerly the ORL Database of Faces).

Official source:

https://cam-orl.co.uk/facedatabase.html

The repository does **not** redistribute the face images. Download the dataset from the official source and place the extracted directory under:

```text
raw/att_faces/
├── s1/
├── s2/
├── ...
└── s40/
```

Only `s1` through `s10` are required for the default 100-image reproduction.

## Shared metadata

`metadata/dataset.csv` is generated from the raw dataset. It records the subject, image number, split and source path so that both implementations can work from the same dataset definition.

The default split is:

- images 1–7: training
- images 8–10: testing

This split is a reproducibility choice for this repository, not a claim about the split used in the original 2014 project.
