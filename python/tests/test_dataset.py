from PIL import Image
from eigenface.dataset import build_manifest, DatasetConfig

def test_manifest_builder(tmp_path):
    root=tmp_path/"att_faces"
    for subject in (1,2):
        d=root/f"s{subject}"; d.mkdir(parents=True)
        for i in range(1,4): Image.new("L",(12,12),i*20).save(d/f"{i}.png")
    frame=build_manifest(root,tmp_path/"manifest.csv",DatasetConfig(train_end=2,total_per_subject=3,subjects=(1,2)))
    assert len(frame)==6; assert (frame["split"]=="train").sum()==4
