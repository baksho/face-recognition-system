from pathlib import Path
import argparse
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "python" / "src"))
from eigenface.model import EigenfaceRecognizer

parser = argparse.ArgumentParser()
parser.add_argument("image")
parser.add_argument("--model", default=str(ROOT / "python" / "models" / "eigenface.joblib"))
args = parser.parse_args()
result = EigenfaceRecognizer.load(args.model).predict(args.image)
print(f"identity: {result.identity or 'UNKNOWN'}")
print(f"distance: {result.distance:.6f}")
print(f"threshold: {result.threshold:.6f}")
print(f"status: {'recognized' if result.recognized else 'rejected'}")
print(f"matched image: {result.matched_filename or 'N/A'}")
