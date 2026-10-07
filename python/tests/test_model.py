import numpy as np
from eigenface.model import EigenfaceRecognizer
from eigenface.config import PreprocessingConfig

def test_fit_predict_and_roundtrip(tmp_path):
    config=PreprocessingConfig(width=8,height=8); rng=np.random.default_rng(42); alice=rng.normal(.15,.01,(5,64)); bob=rng.normal(.80,.01,(5,64)); X=np.vstack([alice,bob])
    model=EigenfaceRecognizer(config,n_components=.95).fit(X,["alice"]*5+["bob"]*5); assert model.predict(alice[0]).identity=="alice"
    path=tmp_path/"model.joblib"; model.save(path); assert EigenfaceRecognizer.load(path).predict(alice[0]).identity=="alice"
