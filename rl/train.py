import json
import os
import random

import numpy as np
import torch

from agent import Agent


def step_environment(state, action):
    drift = random.uniform(-0.02, 0.02)
    pnl = drift if action == 0 else (drift * 1.2 if action == 1 else -drift * 1.2)
    trade_count = 1 if action != 0 else 0
    reward = pnl - (0.001 * trade_count)
    next_state = [s + random.uniform(-0.05, 0.05) for s in state]
    done = random.random() < 0.02
    return next_state, reward, done


def main() -> None:
    state_dim = int(os.environ.get("RL_STATE_DIM", "12"))
    episodes = int(os.environ.get("RL_EPISODES", "50"))
    steps = int(os.environ.get("RL_STEPS", "300"))

    agent = Agent(state_dim)

    for episode in range(episodes):
        state = np.random.normal(0, 1, state_dim).tolist()
        losses = []

        for step in range(steps):
            action = agent.act(state)
            next_state, reward, done = step_environment(state, action)
            agent.remember((state, action, reward, next_state if not done else None))
            loss = agent.train()
            if loss is not None:
                losses.append(loss)

            if step % 100 == 0:
                agent.sync_target()

            state = next_state
            if done:
                break

        if agent.epsilon > 0.01:
            agent.epsilon *= 0.995

        print(json.dumps({"episode": episode + 1, "loss": np.mean(losses) if losses else None}))

    os.makedirs("rl", exist_ok=True)
    torch.save(agent.model.state_dict(), "rl/model.pt")


if __name__ == "__main__":
    main()
