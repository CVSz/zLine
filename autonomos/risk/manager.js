let realizedPnl = 0;

function safeNumber(value, fallback = 0) {
  const numeric = Number(value);
  return Number.isFinite(numeric) ? numeric : fallback;
}

function getMaxDailyLoss() {
  return safeNumber(process.env.MAX_DAILY_LOSS, -500);
}

export function checkRisk(trade) {
  const pnl = safeNumber(trade?.pnl, 0);
  realizedPnl += pnl;
  const maxDailyLoss = getMaxDailyLoss();

  if (realizedPnl <= maxDailyLoss) {
    return {
      allowed: false,
      reason: "max_daily_loss_reached",
      state: getRiskState(),
    };
  }

  return {
    allowed: true,
    reason: "ok",
    state: getRiskState(),
  };
}

export function getRiskState() {
  return { realizedPnl, maxDailyLoss: getMaxDailyLoss() };
}

export function resetRisk() {
  realizedPnl = 0;
}
