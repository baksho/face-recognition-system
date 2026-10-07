"""Modern Eigenface/PCA face-recognition implementation."""
from .config import PreprocessingConfig
from .model import EigenfaceRecognizer, Prediction
__all__ = ["EigenfaceRecognizer", "Prediction", "PreprocessingConfig"]
