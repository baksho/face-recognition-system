from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "python" / "src"))
from eigenface.dataset import load_manifest
from eigenface.evaluate import evaluate_model
from eigenface.model import EigenfaceRecognizer

if __name__ == "__main__":
    manifest = load_manifest(ROOT / "data" / "metadata" / "dataset.csv")
    test = manifest[manifest["split"] == "test"]
    model = EigenfaceRecognizer.load(ROOT / "python" / "models" / "eigenface.joblib")
    result = evaluate_model(model, test)
    print(f"Total: {result['total']}")
    print(f"Correct: {result['correct']}")
    print(f"Rejected: {result['rejected']}")
    print(f"Accuracy: {result['accuracy']:.4%}")
    print("Confusion matrix:")
    print(result["confusion_matrix"])
