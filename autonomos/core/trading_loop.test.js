import test from "node:test";
import assert from "node:assert/strict";
import { tradingLoop } from "./trading_loop.js";

test("tradingLoop stops live execution when risk manager blocks trading", async () => {
  process.env.MAX_DAILY_LOSS = "0";
  process.env.LIVE_TRADING = "false";

  const marketData = [
    { price: 100, rsi: 25, macd: 1, time: 1 },
    { price: 101, rsi: 80, macd: -1, time: 2 },
    { price: 102, rsi: 35, macd: 1, time: 3 },
  ];

  const result = await tradingLoop(marketData, {
    validationTarget: 9000,
    liveWindow: 3,
    quantity: 1,
    resetRiskState: true,
  });

  assert.equal(result.approved, true);
  assert.equal(result.haltedByRisk, true);
  assert.equal(result.haltReason, "max_daily_loss_reached");
  assert.equal(result.executions.length, 1);
});
