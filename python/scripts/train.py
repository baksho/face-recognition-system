from pathlib import Path
import sys
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "python" / "src"))

from eigenface.dataset import load_manifest
from eigenface.model import EigenfaceRecognizer
from eigenface.preprocessing import FacePreprocessor

if __name__ == "__main__":
    manifest = load_manifest(ROOT / "data" / "metadata" / "dataset.csv")
    train = manifest[manifest["split"] == "train"]
    pre = FacePreprocessor()
    X = np.vstack([pre.transform(path) for path in train["path"]])
    model = EigenfaceRecognizer(n_components=0.95).fit(X, train["subject"].tolist(), train["path"].tolist())
    output = ROOT / "python" / "models" / "eigenface.joblib"
    model.save(output)
    print(f"Training images: {len(train)}")
    print(f"PCA components: {model.pca.n_components_}")
    print(f"Threshold: {model.threshold_:.6f}")
    print(f"Saved: {output}")
