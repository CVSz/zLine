function mean(values) {
  if (!values.length) return 0;
  return values.reduce((acc, val) => acc + val, 0) / values.length;
}

function variance(values) {
  if (values.length < 2) return 0;
  const avg = mean(values);
  return values.reduce((acc, val) => acc + (val - avg) ** 2, 0) / values.length;
}

export function optimizePortfolio(returnsByAsset = {}) {
  const entries = Object.entries(returnsByAsset);
  if (!entries.length) return { weights: {}, scores: {} };

  const rawScores = entries.map(([asset, returns]) => {
    const mu = mean(returns);
    const varx = variance(returns);
    const score = varx <= 0 ? 0 : Math.max(mu / varx, 0);
    return [asset, score];
  });

  const totalScore = rawScores.reduce((acc, [, score]) => acc + score, 0);
  const fallbackWeight = 1 / rawScores.length;

  const weights = Object.fromEntries(
    rawScores.map(([asset, score]) => [asset, totalScore > 0 ? score / totalScore : fallbackWeight]),
  );

  return {
    weights,
    scores: Object.fromEntries(rawScores),
  };
}
