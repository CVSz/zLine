import torch
import torch.nn as nn


class OrderBookNet(nn.Module):
    """LSTM model over order-book microstructure features.

    Expected input shape: (batch, seq_len, 20)
    """

    def __init__(self, input_size: int = 20, hidden_size: int = 64, output_size: int = 3) -> None:
        super().__init__()
        self.lstm = nn.LSTM(input_size=input_size, hidden_size=hidden_size, batch_first=True)
        self.head = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Linear(32, output_size),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out, _ = self.lstm(x)
        last_step = out[:, -1, :]
        return self.head(last_step)
