from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence
import joblib
import numpy as np
from sklearn.decomposition import PCA
from sklearn.metrics import pairwise_distances
from .config import PreprocessingConfig
from .preprocessing import FacePreprocessor

@dataclass(frozen=True)
class Prediction:
    identity: str | None
    distance: float
    threshold: float
    recognized: bool
    matched_index: int
    matched_filename: str | None = None

class EigenfaceRecognizer:
    """PCA/Eigenface recognizer with rejection and modern model persistence."""
    def __init__(self, preprocessing=None, n_components: int | float = 0.95, threshold_multiplier: float = 1.5):
        self.preprocessing = preprocessing or PreprocessingConfig()
        self.preprocessor = FacePreprocessor(self.preprocessing)
        self.n_components = n_components
        self.threshold_multiplier = threshold_multiplier
        self.pca = None
        self.projections_ = None
        self.labels_ = None
        self.filenames_ = None
        self.threshold_ = None
    @property
    def fitted(self):
        return self.pca is not None and self.projections_ is not None and self.labels_ is not None
    def fit(self, X: np.ndarray, labels: Sequence[str], filenames: Sequence[str] | None = None):
        X = np.asarray(X, dtype=np.float32)
        if X.ndim != 2 or X.shape[1] != self.preprocessing.n_features:
            raise ValueError(f"X must have shape (n_samples, {self.preprocessing.n_features}).")
        if len(X) != len(labels): raise ValueError("X and labels must contain the same number of samples.")
        if len(X) < 2: raise ValueError("At least two training images are required.")
        self.pca = PCA(n_components=self.n_components, svd_solver="auto", whiten=False, random_state=42)
        self.projections_ = self.pca.fit_transform(X)
        self.labels_ = np.asarray(labels, dtype=str)
        self.filenames_ = np.asarray(filenames if filenames is not None else [""] * len(X), dtype=str)
        self.threshold_ = self._estimate_rejection_threshold()
        return self
    def _estimate_rejection_threshold(self):
        distances = pairwise_distances(self.projections_)
        np.fill_diagonal(distances, np.inf)
        nearest = distances.min(axis=1)
        median = float(np.median(nearest))
        mad = float(np.median(np.abs(nearest - median)))
        robust_scale = max(mad, median * 0.10, 1e-8)
        return float(max(median * self.threshold_multiplier, median + 4.0 * robust_scale))
    def transform(self, source):
        self._require_fitted()
        vector = source.astype(np.float32).reshape(-1) if isinstance(source, np.ndarray) else self.preprocessor.transform(source)
        if vector.size != self.preprocessing.n_features: raise ValueError("Input image has the wrong number of pixels.")
        return self.pca.transform(vector.reshape(1, -1))[0]
    def predict(self, source, threshold=None):
        self._require_fitted()
        query = self.transform(source)
        distances = np.linalg.norm(self.projections_ - query, axis=1)
        index = int(np.argmin(distances))
        distance = float(distances[index])
        limit = float(self.threshold_ if threshold is None else threshold)
        recognized = distance <= limit
        return Prediction(str(self.labels_[index]) if recognized else None, distance, limit, recognized, index, str(self.filenames_[index]) if self.filenames_ is not None else None)
    def save(self, path):
        self._require_fitted()
        path = Path(path); path.parent.mkdir(parents=True, exist_ok=True); joblib.dump(self, path)
    @classmethod
    def load(cls, path):
        model = joblib.load(path)
        if not isinstance(model, cls): raise TypeError("Saved file does not contain an EigenfaceRecognizer.")
        return model
    def _require_fitted(self):
        if not self.fitted: raise RuntimeError("Model is not fitted. Train it or load a saved model.")
