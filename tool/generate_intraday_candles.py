#!/usr/bin/env python3
"""Inject exchange-aware 1-minute OHLC candles and extra RELIANCE option contracts."""

from __future__ import annotations

import copy
import hashlib
import json
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATASET = ROOT / "packages/foundation/core_data/assets/mock/trading_mock_dataset.json"
IST = timezone(timedelta(hours=5, minutes=30))
START = datetime(2026, 8, 23, 9, 15, tzinfo=IST)
CANDLE_COUNT = 75


def stable_seed(value: str) -> int:
    digest = hashlib.sha256(value.encode("utf-8")).digest()
    return int.from_bytes(digest[:8], "little") % (2**32)


def round_tick(value: float, tick: float) -> float:
    size = max(tick, 0.01)
    return round(round(value / size) * size, 2)


def generate_candles(
    *,
    open_px: float,
    high: float,
    low: float,
    close: float,
    tick: float,
    seed: int,
) -> list[dict]:
    rng = random.Random(seed)
    span = max(high - low, tick * 4)
    prices: list[float] = []
    for index in range(CANDLE_COUNT - 1):
        target = open_px + (close - open_px) * (index / max(CANDLE_COUNT - 1, 1))
        noise = rng.uniform(-1, 1) * span * 0.07
        prices.append(min(high, max(low, target + noise)))
    prices.append(close)
    if CANDLE_COUNT > 12:
        prices[CANDLE_COUNT // 4] = high
        prices[(CANDLE_COUNT * 3) // 4] = low

    candles: list[dict] = []
    previous = open_px
    for index, close_px in enumerate(prices):
        opened = previous
        wick_up = rng.choice([0, 0, tick, tick * 2])
        wick_down = rng.choice([0, 0, tick, tick * 2])
        high_px = min(high, max(opened, close_px) + wick_up)
        low_px = max(low, min(opened, close_px) - wick_down)
        high_px = max(high_px, opened, close_px)
        low_px = min(low_px, opened, close_px)
        candles.append(
            {
                "startedAt": (START + timedelta(minutes=index)).isoformat(),
                "open": round_tick(opened, tick),
                "high": round_tick(high_px, tick),
                "low": round_tick(low_px, tick),
                "close": round_tick(close_px, tick),
            }
        )
        previous = close_px
    return candles


def shift_depth(depth: dict, delta: float, tick: float) -> dict:
    cloned = copy.deepcopy(depth)
    for side in ("bids", "asks"):
        for level in cloned.get(side, []):
            level["price"] = round_tick(level["price"] + delta, tick)
    return cloned


def extra_reliance_options(template: dict) -> list[dict]:
    spot = 1316.0
    specs = [
        (1280.0, "CE", 48.4, 51.1, 186400, 18.6),
        (1280.0, "PE", 4.35, 5.1, 94200, 19.8),
        (1300.0, "CE", 28.6, 31.2, 154800, 19.1),
        (1300.0, "PE", 9.85, 11.4, 121300, 20.2),
        (1320.0, "PE", 18.4, 21.6, 138900, 20.8),
        (1340.0, "CE", 11.25, 13.8, 110700, 21.4),
        (1340.0, "PE", 32.7, 36.1, 98000, 21.1),
        (1360.0, "CE", 6.15, 7.8, 76400, 22.0),
        (1360.0, "PE", 48.9, 53.2, 81200, 21.7),
    ]
    options: list[dict] = []
    for strike, option_type, ltp, previous, open_interest, iv in specs:
        option = copy.deepcopy(template)
        option_id = f"RELIANCE_OPT_{int(strike)}_{option_type}_20260825"
        change = round(ltp - previous, 2)
        option.update(
            {
                "id": option_id,
                "symbol": f"RELIANCE {int(strike)} {option_type}",
                "strikePrice": strike,
                "optionType": option_type,
                "ltp": ltp,
                "previousClose": previous,
                "change": change,
                "changePercent": round(change / previous * 100, 2),
                "open": round(previous + change * 0.2, 2),
                "high": round(max(ltp, previous) + abs(change) * 0.35, 2),
                "low": round(min(ltp, previous) - abs(change) * 0.25, 2),
                "openInterest": open_interest,
                "impliedVolatility": iv,
                "volume": max(1200, int(open_interest / 40)),
                "marketDepth": shift_depth(
                    template["marketDepth"],
                    ltp - template["ltp"],
                    float(template["tickSize"]),
                ),
                "tags": ["F&O", "Call" if option_type == "CE" else "Put"],
            }
        )
        intrinsic = max(spot - strike, 0) if option_type == "CE" else max(strike - spot, 0)
        option["recentActivity"] = [
            {
                "id": f"{option_id}_activity_1",
                "type": "trade",
                "title": f"Quoted {int(strike)} {option_type}",
                "description": f"Intrinsic {intrinsic:.2f}",
                "timestamp": "2026-08-21T11:12:00+05:30",
            },
            {
                "id": f"{option_id}_activity_2",
                "type": "watchlist",
                "title": "Added to F&O scan",
                "description": "Reliance Industries",
                "timestamp": "2026-08-20T14:05:00+05:30",
            },
        ]
        options.append(option)
    return options


def main() -> None:
    payload = json.loads(DATASET.read_text())
    funds: list[dict] = payload["funds"]
    template = next(
        fund for fund in funds if fund["id"] == "RELIANCE_OPT_1320_CE_20260825"
    )
    existing_ids = {fund["id"] for fund in funds}
    for option in extra_reliance_options(template):
        if option["id"] not in existing_ids:
            funds.append(option)
            existing_ids.add(option["id"])

    for fund in funds:
        tick = float(fund.get("tickSize") or 0.05)
        fund["intradayCandles"] = generate_candles(
            open_px=float(fund["open"]),
            high=float(fund["high"]),
            low=float(fund["low"]),
            close=float(fund["ltp"]),
            tick=tick,
            seed=stable_seed(fund["id"]),
        )

    for listing in payload.get("marketListings", []):
        tick = float(listing.get("tickSize") or 0.05)
        listing["intradayCandles"] = generate_candles(
            open_px=float(listing["open"]),
            high=float(listing["high"]),
            low=float(listing["low"]),
            close=float(listing["ltp"]),
            tick=tick,
            seed=stable_seed(f"{listing['fundId']}:{listing['exchange']}"),
        )

    counts = payload.setdefault("metadata", {}).setdefault("counts", {})
    counts["funds"] = len(funds)
    counts["equity"] = sum(1 for fund in funds if fund["instrumentType"] == "EQUITY")
    counts["future"] = sum(1 for fund in funds if fund["instrumentType"] == "FUTURE")
    counts["options"] = sum(1 for fund in funds if fund["instrumentType"] == "OPTION")
    DATASET.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"Wrote {DATASET} with {len(funds)} funds.")


if __name__ == "__main__":
    main()
