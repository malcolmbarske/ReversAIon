//+------------------------------------------------------------------+
//|                     ReversAIon Scalper EA                        |
//|     Optimized for M5 Crypto & FX Scalping with Low Risk         |
//|     Strategy: BB+RSI+ADX + ATR-Based SL/TP + Trailing Stop      |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>

// Indicator Modes (for buffer indexing)
#define MODE_MAIN 0
#define MODE_UPPER 1
#define MODE_LOWER 2

input ENUM_TIMEFRAMES Timeframe      = PERIOD_M5;
input double RiskPercent             = 0.5;
input double ATR_Multiplier_SL       = 1.5;
input double ATR_Multiplier_TP       = 2.5;
input double ADX_MaxThreshold        = 20.0;
input double RSI_BuyThreshold        = 30.0;
input double RSI_SellThreshold       = 70.0;
input bool   UseTrailingStop         = true;
input double TrailingATRMultiplier   = 1.0;
input double SpreadLimitMultiplier   = 0.25; // ATR-based max spread

// Trading hours filter (optional)
input int TradingHourStart           = 8;   // 08:00 server time
input int TradingHourEnd             = 20;  // 20:00 server time

CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("ReversAIon Scalper initialized on ", _Symbol);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsTradingTime()) return;

   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   double atr = GetATR(14);
   if(spread > atr * SpreadLimitMultiplier)
      return;

   int signal = 0;
   double sl = 0, tp = 0;

   if(GenerateSignal(signal, sl, tp))
   {
      double entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double lot = CalculateLot(entry, sl);
      if(lot <= 0) return;

      string comment = (signal == 1 ? "ReversAIon Buy" : "ReversAIon Sell");

      if(signal == 1)
      {
         if(trade.Buy(lot, _Symbol, entry, sl, tp, comment))
            Print("Buy executed: ", entry);
      }
      else if(signal == -1)
      {
         if(trade.Sell(lot, _Symbol, entry, sl, tp, comment))
            Print("Sell executed: ", entry);
      }
   }
}
//+------------------------------------------------------------------+
//| Generate Signal                                                  |
//+------------------------------------------------------------------+
bool GenerateSignal(int &signal, double &sl, double &tp)
{
   // Indicator handles
   static int bb_handle = iBands(_Symbol, Timeframe, 20, 2.0, 0, PRICE_CLOSE);
   static int rsi_handle = iRSI(_Symbol, Timeframe, 7, PRICE_CLOSE);
   static int adx_handle = iADX(_Symbol, Timeframe, 7);
   static int atr_handle = iATR(_Symbol, Timeframe, 14);

   if(bb_handle == INVALID_HANDLE || rsi_handle == INVALID_HANDLE || adx_handle == INVALID_HANDLE)
      return false;

   double upper[], lower[], rsi[], adx[], close[], open[];

   if(CopyBuffer(bb_handle, MODE_UPPER, 1, 1, upper) <= 0) return false;
   if(CopyBuffer(bb_handle, MODE_LOWER, 1, 1, lower) <= 0) return false;
   if(CopyBuffer(rsi_handle, 0, 1, 1, rsi) <= 0) return false;
   if(CopyBuffer(adx_handle, MODE_MAIN, 1, 1, adx) <= 0) return false;
   if(CopyClose(_Symbol, Timeframe, 1, 1, close) <= 0) return false;
   if(CopyOpen(_Symbol, Timeframe, 1, 1, open) <= 0) return false;

   double price = close[0];
   double atr = GetATR(14);
   if(atr == 0) return false;

   // Buy signal
   if(price <= lower[0] && rsi[0] < RSI_BuyThreshold && adx[0] < ADX_MaxThreshold && price > open[0])
   {
      signal = 1;
      sl = price - ATR_Multiplier_SL * atr;
      tp = price + ATR_Multiplier_TP * atr;
      return true;
   }

   // Sell signal
   if(price >= upper[0] && rsi[0] > RSI_SellThreshold && adx[0] < ADX_MaxThreshold && price < open[0])
   {
      signal = -1;
      sl = price + ATR_Multiplier_SL * atr;
      tp = price - ATR_Multiplier_TP * atr;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Get ATR                                                          |
//+------------------------------------------------------------------+
double GetATR(int period)
{
   int atr_handle = iATR(_Symbol, Timeframe, period);
   double buffer[];
   if(CopyBuffer(atr_handle, 0, 1, 1, buffer) <= 0)
      return 0;
   return buffer[0];
}
//+------------------------------------------------------------------+
//| Calculate lot size with risk control                             |
//+------------------------------------------------------------------+
double CalculateLot(double entry, double sl_price)
{
   double risk_amount = AccountBalance() * (RiskPercent / 100.0);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double sl_distance = MathAbs(entry - sl_price);
   if(tick_value == 0 || tick_size == 0 || sl_distance == 0)
      return 0;

   double sl_value_per_lot = sl_distance / tick_size * tick_value;
   double lots = risk_amount / sl_value_per_lot;

   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lots = MathMax(min_lot, MathMin(lots, max_lot));
   lots = NormalizeDouble(lots, 2);
   return lots;
}

//+------------------------------------------------------------------+
//| Check if we are within trading hours                             |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
   MqlDateTime time_struct;
   TimeToStruct(TimeCurrent(), time_struct);
   return (time_struct.hour >= TradingHourStart && time_struct.hour < TradingHourEnd);
}

//+------------------------------------------------------------------+
//| Trailing stop logic (to be implemented if needed)                |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   // Optional: Add trailing logic if desired
   // Could use current price vs entry and adjust SL dynamically
}
