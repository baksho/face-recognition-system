from dataclasses import dataclass

@dataclass(frozen=True)
class PreprocessingConfig:
    width: int = 250
    height: int = 250
    normalize: bool = True
    @property
    def n_features(self) -> int:
        return self.width * self.height
