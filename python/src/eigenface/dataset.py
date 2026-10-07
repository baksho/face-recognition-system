from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
import pandas as pd
SUPPORTED_EXTENSIONS = {".pgm", ".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff"}
@dataclass(frozen=True)
class DatasetConfig:
    train_end: int = 7
    total_per_subject: int = 10
    subjects: tuple[int, ...] = tuple(range(1, 11))
def build_manifest(root, output_csv, config=None):
    config = config or DatasetConfig(); root = Path(root); rows=[]
    for subject_id in config.subjects:
        subject=f"s{subject_id}"; subject_dir=root/subject
        if not subject_dir.is_dir(): raise FileNotFoundError(f"Missing subject directory: {subject_dir}")
        for image_no in range(1, config.total_per_subject+1):
            matches=[p for p in subject_dir.glob(f"{image_no}.*") if p.suffix.lower() in SUPPORTED_EXTENSIONS]
            if len(matches)!=1: raise FileNotFoundError(f"Expected one image for {subject}/{image_no}, found {matches}")
            rows.append({"subject":subject,"image_number":image_no,"split":"train" if image_no<=config.train_end else "test","path":str(matches[0].resolve())})
    frame=pd.DataFrame(rows); output_csv=Path(output_csv); output_csv.parent.mkdir(parents=True, exist_ok=True); frame.to_csv(output_csv,index=False); return frame
def load_manifest(path):
    frame=pd.read_csv(path); required={"subject","image_number","split","path"}; missing=required-set(frame.columns)
    if missing: raise ValueError(f"Manifest is missing columns: {sorted(missing)}")
    return frame
