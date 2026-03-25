import random
from collections import deque

import numpy as np
import torch
from torch import nn

from model import DQN


class Agent:
    def __init__(
        self,
        state_dim: int,
        lr: float = 1e-3,
        gamma: float = 0.99,
        epsilon: float = 1.0,
        epsilon_min: float = 0.05,
        epsilon_decay: float = 0.995,
        target_sync_steps: int = 100,
    ) -> None:
        self.model = DQN(state_dim)
        self.target = DQN(state_dim)
        self.target.load_state_dict(self.model.state_dict())
        self.target.eval()

        self.memory = deque(maxlen=10_000)
        self.gamma = gamma
        self.epsilon = epsilon
        self.epsilon_min = epsilon_min
        self.epsilon_decay = epsilon_decay
        self.target_sync_steps = target_sync_steps
        self.training_steps = 0

        self.optimizer = torch.optim.Adam(self.model.parameters(), lr=lr)
        self.loss_fn = nn.MSELoss()

    def act(self, state):
        if random.random() < self.epsilon:
            return random.randint(0, 2)

        with torch.no_grad():
            state_t = torch.tensor(state, dtype=torch.float32)
            q_values = self.model(state_t)
            return int(torch.argmax(q_values).item())

    def remember(self, exp):
        self.memory.append(exp)

    def train(self, batch_size: int = 32):
        if len(self.memory) < batch_size:
            return None

        batch = random.sample(self.memory, batch_size)
        states, actions, rewards, next_states = zip(*batch)

        states_t = torch.tensor(np.asarray(states), dtype=torch.float32)
        actions_t = torch.tensor(actions, dtype=torch.int64).unsqueeze(1)
        rewards_t = torch.tensor(rewards, dtype=torch.float32)

        current_q = self.model(states_t).gather(1, actions_t).squeeze(1)

        next_q = torch.zeros(batch_size, dtype=torch.float32)
        non_terminal_idx = [i for i, ns in enumerate(next_states) if ns is not None]
        if non_terminal_idx:
            next_state_t = torch.tensor(
                np.asarray([next_states[i] for i in non_terminal_idx]), dtype=torch.float32
            )
            with torch.no_grad():
                next_q_vals = self.target(next_state_t).max(dim=1).values
            next_q[non_terminal_idx] = next_q_vals

        target_q = rewards_t + (self.gamma * next_q)
        loss = self.loss_fn(current_q, target_q)

        self.optimizer.zero_grad()
        loss.backward()
        self.optimizer.step()

        self.training_steps += 1
        if self.training_steps % self.target_sync_steps == 0:
            self.sync_target()

        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)
        return float(loss.item())

    def sync_target(self):
        self.target.load_state_dict(self.model.state_dict())
