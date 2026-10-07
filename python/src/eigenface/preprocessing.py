from __future__ import annotations
from io import BytesIO
from pathlib import Path
import numpy as np
from PIL import Image, ImageOps
from .config import PreprocessingConfig

class FacePreprocessor:
    """Convert images to a consistent grayscale vector representation."""
    def __init__(self, config: PreprocessingConfig | None = None):
        self.config = config or PreprocessingConfig()
    def load(self, source: str | Path | bytes | Image.Image) -> Image.Image:
        if isinstance(source, Image.Image): image = source.copy()
        elif isinstance(source, (str, Path)): image = Image.open(source)
        elif isinstance(source, bytes): image = Image.open(BytesIO(source))
        else: raise TypeError(f"Unsupported image source: {type(source)!r}")
        image = ImageOps.exif_transpose(image).convert("L")
        return image.resize((self.config.width, self.config.height), Image.Resampling.LANCZOS)
    def transform(self, source: str | Path | bytes | Image.Image) -> np.ndarray:
        vector = np.asarray(self.load(source), dtype=np.float32).reshape(-1)
        if self.config.normalize: vector /= 255.0
        return vector
