from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "python" / "src"))

from eigenface.dataset import build_manifest

if __name__ == "__main__":
    dataset_root = ROOT / "data" / "raw" / "att_faces"
    output = ROOT / "data" / "metadata" / "dataset.csv"
    frame = build_manifest(dataset_root, output)
    print(f"Created {len(frame)} dataset records at {output}")
