
# 🤖 ReversAIon Scalper EA (MQL5)

A high-probability, low-risk scalping Expert Advisor for MetaTrader 5, optimized for **M5 timeframes** on **BTCUSD, ETHUSD, and major Forex pairs**.

---

## 🧠 Strategy Summary

- **Mean Reversion** with:
  - Bollinger Band breakouts
  - RSI + ADX filters
  - Candlestick confirmation
- **ATR-based Stop Loss & Take Profit**
- Optional **Trailing Stop** using ATR
- **Spread filter** to avoid volatile conditions
- Time filter to restrict to best trading hours

---

## ⚙️ Default Settings

| Parameter              | Value         |
|------------------------|---------------|
| Timeframe              | M5            |
| RiskPercent            | 0.5%          |
| ATR_Multiplier_SL      | 1.5           |
| ATR_Multiplier_TP      | 2.5           |
| ADX_MaxThreshold       | 20            |
| RSI_BuyThreshold       | 30            |
| RSI_SellThreshold      | 70            |
| UseTrailingStop        | `true`        |
| TrailingATRMultiplier  | 1.0           |
| SpreadLimitMultiplier  | 0.25 (of ATR) |
| Trading Hours          | 08:00–20:00   |

---

## 📁 Files Included

| File                              | Description                                    |
|-----------------------------------|------------------------------------------------|
| `ReversAIon_Scalper.mq5`         | Full source code of the EA                     |
| `ReversAIon_BTCUSD_M5.set`       | Strategy Tester input config                   |
| `ReversAIon_BTCUSD_Backtest.ini` | Preset backtest config (BTCUSD M5, last 3 mo.) |
| `README.md`                      | This file                                      |

---

## 🧪 How to Backtest

1. Open **MetaTrader 5**
2. Go to `Strategy Tester` (Ctrl+R)
3. Select:
   - Expert: `ReversAIon_Scalper`
   - Symbol: `BTCUSD`
   - Period: `M5`
   - Model: `Every tick based on real ticks`
4. Load inputs from: `ReversAIon_BTCUSD_M5.set`
5. (Optional) Load preset: `ReversAIon_BTCUSD_Backtest.ini`

---

## 📈 Recommended Symbols

- `BTCUSD` (M5)
- `ETHUSD` (M5 or M15)
- `EURUSD`, `GBPUSD`, `XAUUSD` (M5–M15)

---

## ✅ Optimization Tips

You can optimize:
- RSI thresholds
- ATR SL/TP multipliers
- Trailing stop settings
- Session times (based on volatility)

---

## 🔐 Notes

- **No license validation** enabled during testing
- Developed for **prop-firm-friendly risk**
- Future versions may include:
  - Licensing
  - Telegram alerts
  - Live equity tracking

---

> © 2025 Malcolm Barske / ReversAIon Project
