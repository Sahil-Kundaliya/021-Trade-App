# 021 Trade

A Flutter trading demo with live mock prices, watchlists, simulated orders, and a local wallet. No backend and no extra setup.

Instruments used throughout the app:

`RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, `AXISBANK`

The app also includes futures and options on the same underlyings.

---

## Run

**Requires:** Flutter stable, Dart SDK `^3.12.1`

```bash
flutter pub get
flutter run
```

That is all. Market data, wallet, orders, holdings, and watchlists are stored locally on the device.

## APK & Demo

- **Download APK:** [Install the latest Android build](https://drive.google.com/file/d/1Kg5U3wnjkfFpkhGEKWOys7y8pZdrmp4D/view?usp=sharing)
- **Watch walkthrough:** [View the app explanation video](https://drive.google.com/file/d/1WYYi6jXwR9lKFPFJwBtkC0_5vBflK9vH/view?usp=sharing)

---

## Features

### Live prices

A native mock feed is the single price source for the whole app. Quotes update about once per second. Each row shows LTP, change, and change %. Green means up, red means down. Prices stay current after leaving a screen and coming back.

### Dashboard

Home screen with live **NIFTY 50**, **BANK NIFTY**, and **SENSEX** chips, a portfolio snapshot, auto-rotating featured banners, a market heat map (NSE/BSE), a movers screener (equity, futures, options), and market news. Tap a stock to open its details.

### Watchlist

Create, rename, delete, and reorder multiple lists (max 5). Default cannot be deleted. Add or remove stocks from the fund sheet bookmark. Drag to reorder rows. Each row shows symbol, LTP, change, and %. Empty lists show an empty state. Watchlists persist after restart.

### Search

Search by symbol or name. Filter by All, Equity, Futures, or Options. Results show live LTP. Tap a result to open fund details.

### Fund details

Bottom sheet with live quote, Buy/Sell, bookmark into a watchlist, candlestick chart (1D / 1M / 3M), market stats, depth, margin, recent activity, and company profile. Equities also show derivatives shortcuts. Futures and options show contract details and an option chain.

### Buy / Sell ticket

Opens pre-filled from a fund, watchlist, or holding. Choose side, quantity, product, and order type (Market, Limit, SL, SL-M). Live LTP and order value update while the form is open. Buy checks wallet balance. Sell checks quantity held. Invalid quantity or prices are blocked inline. Market orders execute at LTP at submit. Success shows confirmation; failure offers add-funds or sell-available.

### Order Book

Open and closed orders with status badges. Tap a row for details (qty, filled, prices, product). Open orders can be cancelled. Order history persists after restart.

### Portfolio / Holdings

List of holdings with quantity, avg cost, live LTP, current value, and P&L (₹ and %). Summary at the top: invested, current value, total P&L. Sort by P&L, symbol, or current value (default P&L descending). Sort order updates as prices move. Tabs for Equity, Futures, and Options. Tap a row to trade. A holding is added or updated on buy, and removed when sold to zero. Empty state when nothing is held. Holdings persist after restart.

### Add Funds

Local demo wallet. Starting balance is ₹0. Enter an amount or use quick chips (+₹500, +₹1,000, +₹2,500, +₹5,000). Max ₹10,000 per add. Choose a demo bank (HDFC, ICICI, Axis). Confirmation shows the new balance. Add Bank is demo-only. Balance persists after restart.

### Profile

Account header, available funds shortcut, Order Book, order preferences (default side, type, product), price display preferences, theme (system / light / dark), privacy mode (hides balances and quantities), notifications, app info, and licence / regulatory information. Some account, security, and legal rows are display-only in this demo.

### Offline and persistence

Internet-required screens show an offline state with retry. Watchlists, wallet, orders, holdings, theme, privacy, and preferences survive app restart.
