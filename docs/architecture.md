# Architecture

The repository intentionally has two implementation branches around a shared dataset definition.

```mermaid
flowchart TB
    R[2014 B.Tech Project Report] --> C[Shared conceptual specification]
    C --> D[Pre-2014 public dataset\nAT&T / ORL Faces]
    D --> M[Shared dataset metadata]

    M --> MATLAB[MATLAB branch\nfaithful reproduction]
    M --> PYTHON[Python branch\n2026 modernization]

    MATLAB --> MA[Classical PCA / Eigenfaces]
    PYTHON --> PA[Classical PCA / Eigenfaces]

    MA --> MR[MATLAB UI + evaluation]
    PA --> PR[CLI + Streamlit + evaluation]
```

## Core algorithm

Both branches implement the same conceptual sequence:

```mermaid
flowchart LR
    A[Training Images] --> B[Grayscale]
    B --> C[250x250]
    C --> D[Vectorize]
    D --> E[Mean Face]
    E --> F[Center Images]
    F --> G[PCA / Eigenfaces]
    G --> H[Training Projections]

    I[Test Image] --> J[Same Preprocessing]
    J --> K[Test Projection]
    K --> L[Euclidean Distances]
    H --> L
    L --> M{Threshold}
    M -->|within threshold| N[Known Identity]
    M -->|outside threshold| O[Unknown]
```

The Python branch changes the implementation machinery around this core rather than changing the algorithm into a deep-learning system.
