from __future__ import annotations
import argparse
import numpy as np
from .dataset import build_manifest, load_manifest
from .evaluate import evaluate_model
from .model import EigenfaceRecognizer

def main():
    parser=argparse.ArgumentParser(description="Modern Eigenface/PCA face recognition"); sub=parser.add_subparsers(dest="command",required=True)
    p=sub.add_parser("manifest"); p.add_argument("dataset_root"); p.add_argument("--output",default="data/metadata/dataset.csv")
    p=sub.add_parser("train"); p.add_argument("manifest"); p.add_argument("--output",default="python/models/eigenface.joblib"); p.add_argument("--components",type=float,default=0.95)
    p=sub.add_parser("recognize"); p.add_argument("image"); p.add_argument("--model",default="python/models/eigenface.joblib")
    p=sub.add_parser("evaluate"); p.add_argument("manifest"); p.add_argument("--model",default="python/models/eigenface.joblib"); p.add_argument("--split",default="test",choices=["train","test"])
    args=parser.parse_args()
    if args.command=="manifest": print(f"Wrote {len(build_manifest(args.dataset_root,args.output))} records to {args.output}"); return
    if args.command=="train":
        from .preprocessing import FacePreprocessor
        frame=load_manifest(args.manifest); train=frame[frame.split=="train"]; pre=FacePreprocessor(); X=np.vstack([pre.transform(p) for p in train.path]); model=EigenfaceRecognizer(n_components=args.components).fit(X,train.subject.tolist(),train.path.tolist()); model.save(args.output)
        print(f"Training images: {len(train)}\nPCA components: {model.pca.n_components_}\nRejection threshold: {model.threshold_:.6f}\nSaved: {args.output}"); return
    if args.command=="recognize":
        result=EigenfaceRecognizer.load(args.model).predict(args.image); print(f"identity: {result.identity or 'UNKNOWN'}\ndistance: {result.distance:.6f}\nthreshold: {result.threshold:.6f}\nstatus: {'recognized' if result.recognized else 'rejected'}\nmatched image: {result.matched_filename or 'N/A'}"); return
    frame=load_manifest(args.manifest); frame=frame[frame.split==args.split]; result=evaluate_model(EigenfaceRecognizer.load(args.model),frame); print(f"Total: {result['total']}\nCorrect: {result['correct']}\nRejected: {result['rejected']}\nAccuracy: {result['accuracy']:.4%}\nConfusion matrix:\n{result['confusion_matrix']}")

if __name__=="__main__": main()
