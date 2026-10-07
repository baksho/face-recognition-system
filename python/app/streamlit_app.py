from pathlib import Path
import sys
import streamlit as st
ROOT=Path(__file__).resolve().parents[2]; sys.path.insert(0,str(ROOT/"python"/"src"))
from eigenface.dataset import load_manifest
from eigenface.model import EigenfaceRecognizer
st.set_page_config(page_title="Eigenface Face Recognition",layout="wide")
st.title("Eigenface Face Recognition")
st.caption("Modern Python reproduction of the 2014 MATLAB PCA/Eigenface project")
model_path=st.sidebar.text_input("Model path","python/models/eigenface.joblib")
manifest_path=st.sidebar.text_input("Manifest path","data/metadata/dataset.csv")
try:
    model=EigenfaceRecognizer.load(ROOT/model_path); manifest=load_manifest(ROOT/manifest_path)
except Exception as exc:
    st.error(f"Could not load model or manifest: {exc}"); st.info("Train the model first. See python/README.md."); st.stop()
uploaded=st.file_uploader("Upload a face image",type=["jpg","jpeg","png","pgm","bmp"])
if uploaded:
    col1,col2=st.columns(2)
    with col1: st.image(uploaded,caption="Query image",width="stretch")
    result=model.predict(uploaded.getvalue())
    with col2:
        st.subheader("Prediction"); st.metric("Identity",result.identity or "UNKNOWN"); st.metric("Distance",f"{result.distance:.4f}"); st.metric("Threshold",f"{result.threshold:.4f}"); st.write("Status:","Recognized" if result.recognized else "Rejected as unknown")
        if result.matched_filename: st.write("Nearest training image:",result.matched_filename)
st.divider(); st.subheader("Dataset"); st.dataframe(manifest.groupby(["split","subject"]).size().reset_index(name="images"),width="stretch")
