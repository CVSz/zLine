import WebSocket from "ws";

const DEFAULT_CONFIG = {
  symbol: "BTCUSDT",
  minSpread: 5,
  takerFeeBps: 6,
};

export class LatencyArbEngine {
  constructor(config = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.prices = {};
    this.sockets = {};
  }

  connect(name, url, subscribeMessage) {
    const ws = new WebSocket(url);
    this.sockets[name] = ws;

    ws.on("open", () => {
      if (subscribeMessage) {
        ws.send(JSON.stringify(subscribeMessage));
      }
    });

    ws.on("message", (data) => {
      try {
        const msg = JSON.parse(data.toString());
        const quote = this.normalize(name, msg);
        if (!quote) return;

        this.prices[name] = quote;
        const arb = this.checkArb();
        if (arb) {
          console.log("⚡ ARB OPPORTUNITY", JSON.stringify(arb));
        }
      } catch {
        // Ignore malformed exchange payloads.
      }
    });

    ws.on("close", () => {
      setTimeout(() => this.connect(name, url, subscribeMessage), 1_000);
    });

    return ws;
  }

  normalize(exchange, msg) {
    if (exchange === "binance") {
      if (!msg.b || !msg.a) return null;
      return { bid: Number(msg.b), ask: Number(msg.a), ts: Date.now() };
    }

    if (exchange === "bybit") {
      const row = msg?.data?.[0] ?? msg?.data;
      if (!row?.b || !row?.a) return null;
      return { bid: Number(row.b), ask: Number(row.a), ts: Date.now() };
    }

    if (exchange === "okx") {
      const row = msg?.data?.[0];
      if (!row?.bidPx || !row?.askPx) return null;
      return { bid: Number(row.bidPx), ask: Number(row.askPx), ts: Date.now() };
    }

    return null;
  }

  checkArb() {
    const exchanges = Object.keys(this.prices);
    if (exchanges.length < 2) return null;

    let best = null;
    for (const sellEx of exchanges) {
      for (const buyEx of exchanges) {
        if (sellEx === buyEx) continue;

        const sell = this.prices[sellEx];
        const buy = this.prices[buyEx];
        const gross = sell.bid - buy.ask;
        const feeCost = ((sell.bid + buy.ask) * this.config.takerFeeBps) / 10_000;
        const net = gross - feeCost;

        if (net > this.config.minSpread && (!best || net > best.netSpread)) {
          best = {
            sell: sellEx,
            buy: buyEx,
            sellPx: sell.bid,
            buyPx: buy.ask,
            grossSpread: Number(gross.toFixed(4)),
            netSpread: Number(net.toFixed(4)),
          };
        }
      }
    }

    return best;
  }

  close() {
    Object.values(this.sockets).forEach((socket) => socket.close());
  }
}

export function createDefaultEngine(config = {}) {
  const engine = new LatencyArbEngine(config);

  engine.connect("binance", "wss://stream.binance.com:9443/ws/btcusdt@bookTicker");
  engine.connect("bybit", "wss://stream.bybit.com/v5/public/spot", {
    op: "subscribe",
    args: ["tickers.BTCUSDT"],
  });
  engine.connect("okx", "wss://ws.okx.com:8443/ws/v5/public", {
    op: "subscribe",
    args: [{ channel: "tickers", instId: "BTC-USDT" }],
  });

  return engine;
}
