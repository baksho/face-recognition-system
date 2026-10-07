from PIL import Image
from eigenface.preprocessing import FacePreprocessor
from eigenface.config import PreprocessingConfig

def test_preprocessing_shape_and_range():
    vector=FacePreprocessor(PreprocessingConfig(width=10,height=10)).transform(Image.new("RGB",(40,30),(255,0,0)))
    assert vector.shape==(100,); assert vector.min()>=0; assert vector.max()<=1
