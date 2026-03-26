import test from "node:test";
import assert from "node:assert/strict";
import { checkRisk, getRiskState, resetRisk } from "./manager.js";

test("checkRisk allows trading when realized pnl is above loss threshold", () => {
  process.env.MAX_DAILY_LOSS = "-500";
  resetRisk();

  const first = checkRisk({ pnl: 150 });
  const second = checkRisk({ pnl: -100 });

  assert.equal(first.allowed, true);
  assert.equal(second.allowed, true);
  assert.equal(getRiskState().realizedPnl, 50);
});

test("checkRisk halts trading when max daily loss is reached", () => {
  process.env.MAX_DAILY_LOSS = "-100";
  resetRisk();

  const decision = checkRisk({ pnl: -120 });

  assert.equal(decision.allowed, false);
  assert.equal(decision.reason, "max_daily_loss_reached");
  assert.equal(decision.state.realizedPnl, -120);
});
