//https://www.youtube.com/watch?v=510G39RXuPE&ab_channel=ProphetMarket

#include<Trade\Trade.mqh>
CTrade  trade;

string CurrentPosition="";
string TrendlRSI="";
string signalRSI="";
string CurrentTrendDirection="";
bool RSIDownCounted=false;
bool RSIUpCounted=false;
int IndexOfOverboughtStoch=0;
int IndexOfOversoldStoch=0;
string state="";
double LastShortPrice,LastLongPrice;


void OnTick(){

   //get buy and sell prices
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   string signalMACD="";
   string SignalStochastic="";
   string signal="";
   
   //array for the candles
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true);
   int PriceData=CopyRates(_Symbol,_Period,0,300,PriceInfo); 
   
   //array for the 14 Average True Range
   double ATFArr[];
   int AverageTrueRangeDef=iATR(_Symbol,_Period,14);
   ArraySetAsSeries(ATFArr,true);
   CopyBuffer(AverageTrueRangeDef,0,0,10,ATFArr);
   
   //MACD oscilator
   double MACDPriceArr[];
   int MacDDef=iMACD(_Symbol,_Period,8,21,5,PRICE_CLOSE); 
   ArraySetAsSeries(MACDPriceArr,true);
   CopyBuffer(MacDDef,0,0,30,MACDPriceArr);
   
   if(MACDPriceArr[2]<0&&MACDPriceArr[1]>0)signalMACD="cross up";
   else if(MACDPriceArr[2]>0&&MACDPriceArr[1]<0)signalMACD="cross down";
   else signalMACD="";
   
   
   CheckRSI();
   SignalStochastic=CheckStochastic();
   
   if(TrendlRSI=="downtrend"&&RSIDownCounted==false){
      //triggering the short signal
      Print("RSI-Down at candle.time: ",PriceInfo[1].time);
      RSIDownCounted=true;
      RSIUpCounted=false;
      if(SignalStochastic=="overbought"){
         CalculateTrend(PriceInfo);
         Print("Stoch-overbought at candle.time: ",PriceInfo[IndexOfOverboughtStoch].time);
         
         if(CurrentTrendDirection=="down"){
            Print("Trend direction down(veryy good)");
            if(signalMACD=="cross down"){
               Print("Sell in: ",PriceInfo[0].time);
               signal="sell";
            }
         }
      }
      
   }
   else if(TrendlRSI=="uptrend"&&!RSIUpCounted) {
      ////triggering the long signal
      Print("RSI-Up at candle.time: ",PriceInfo[1].time);
      RSIDownCounted=false;
      RSIUpCounted=true;
      if(SignalStochastic=="oversold"){
         CalculateTrend(PriceInfo);
         Print("Stoch-oversold at candle.time: ",PriceInfo[IndexOfOversoldStoch].time);
         
         if(CurrentTrendDirection=="up"){
            Print("Trend direction up(veryy good)");
            if(signalMACD=="cross up"){
               Print("Buy in: ",PriceInfo[0].time);
               signal="buy";
            }
         }
      }
   }
   
   
   if(signal=="sell"&&PositionsTotal()==0){
      //open a short postion
      int HighestCandle=GetTheHighestCandle(10);
      double SLPrice=PriceInfo[HighestCandle].high+ATFArr[HighestCandle];
      double TPPrice=CalculateRRR(SLPrice,false);
      
      signal="";
      trade.Sell(0.20,NULL,Bid,SLPrice,TPPrice,NULL);
      LastShortPrice=Bid;
      state="we are short";
   }
   
   if(PositionsTotal()==1&&state=="we are short"){
      //close the opened short positions
      if(signalRSI=="oversold"&&SignalStochastic=="oversold"&&LastShortPrice>Ask){
         CloseAllSellPos();
      }
   }
   
   if(signal=="buy"&&PositionsTotal()==0){
      //open a long postion
      int LowestCandle=GetTheLowestCandle(10);
      double SLPrice=PriceInfo[LowestCandle].low-ATFArr[LowestCandle];
      double TPPrice=CalculateRRR(SLPrice,true);
      
      signal="";
      trade.Buy(0.20,NULL,Bid,SLPrice,TPPrice,NULL);
      LastLongPrice=Ask;
      state="we are long";
   }
   
   if(PositionsTotal()==1&&state=="we are long"){
      //close the opened long positions
      if(signalRSI=="overbought"&&SignalStochastic=="overbought"&&LastLongPrice<Bid){
         CloseAllBuyPos();
      }
   }
   
   Comment("Trend_RSI: ",TrendlRSI,"\n",
           "State RSI: ",signalRSI,"\n",
           "Signal_Stochastic: ",SignalStochastic,"\n",
           "Signal_MACD: ",signalMACD,"\n",
           "Trend Direction:  ",CurrentTrendDirection,"\n",
           "Last Sell Entry:  ",LastShortPrice,"\n");
   
}
void CheckRSI(){
   
   //defining an rsi
   double MyRSIArr[];
   int myRSIDef=iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   ArraySetAsSeries(MyRSIArr,true);
   CopyBuffer(myRSIDef,0,0,30,MyRSIArr);
   double myRSIValue=NormalizeDouble(MyRSIArr[1],2);
   
   ObjectDelete(_Symbol,"50 RSI Line");
   ObjectCreate(_Symbol,"50 RSI Line",OBJ_HLINE,3,TimeCurrent(),50);
   ObjectSetInteger(_Symbol,"50 RSI Line",OBJPROP_WIDTH,1); 
   ObjectSetInteger(_Symbol,"50 RSI Line",OBJPROP_COLOR,clrGray); 
   
   if(MyRSIArr[1]>=50)TrendlRSI="uptrend";
   else if(MyRSIArr[1]<50)TrendlRSI="downtrend";
   else TrendlRSI="";
   
   if(myRSIValue>70)signalRSI="overbought";
   else if(myRSIValue<30) signalRSI="oversold";
   else signalRSI="";
   
   
}
void CalculateTrend(MqlRates &PriceInfo[]){
   
   //defining an rsi
   double MyRSIArr[];
   int myRSIDef=iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   ArraySetAsSeries(MyRSIArr,true);
   CopyBuffer(myRSIDef,0,0,30,MyRSIArr);
   int tempUp=0;
   int tempDown=0;
   string RSITrend="";
   
   for(int count=15;count>1;count--){
      if(MyRSIArr[count]>50)tempUp++;
      else tempDown++;
   }
   
   if(tempUp>7)RSITrend="up";
   else if(tempDown>7)RSITrend="down";  
   else RSITrend="";
   
   double price1=PriceInfo[1].high;
   double price2=PriceInfo[50].high;
   
   string LookingFORTrend="";
   
   //100*_Point is just for 1M timeframe... for longer timeframes-bigger array)
   if(price1-500*_Point>price2)LookingFORTrend="for up";
   else if(price1+500*_Point<price2) LookingFORTrend="for down";
   else LookingFORTrend="res e batko";
   
   if(RSITrend=="up"&&LookingFORTrend=="for up"){
      CurrentTrendDirection="up";
   }
   else if(RSITrend=="down"&&LookingFORTrend=="for down"){
      CurrentTrendDirection="down";
   }
   
}
string CheckStochastic(){
   
   //defining stochastic
   double kArr[],dArr[];
   ArraySetAsSeries(kArr,true);
   ArraySetAsSeries(dArr,true);
   int StochasticDeff=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,STO_LOWHIGH);
   CopyBuffer(StochasticDeff,0,0,4,kArr);
   CopyBuffer(StochasticDeff,1,0,4,dArr);
   double KValue0=kArr[1];
   double DValue0=dArr[1];
   double KValue1=kArr[2];
   double DValue1=dArr[2];
   double KValue2=kArr[3];
   double DValue2=dArr[3];
   
   string signalStochastic="";
      
   if(KValue0>80&&DValue0>80){
      signalStochastic="overbought";
      IndexOfOverboughtStoch=1;
   }
   else if(KValue0<20&&DValue0<20){
      signalStochastic="oversold";
      IndexOfOversoldStoch=1;
   }
   else if(KValue1>80&&DValue1>80){
      signalStochastic="overbought";
      IndexOfOverboughtStoch=1;
   }
   else if(KValue1<20&&DValue1<20){
      signalStochastic="oversold";
      IndexOfOversoldStoch=1;
   }
   else if(KValue2>80&&DValue2>80){
      signalStochastic="overbought";
      IndexOfOverboughtStoch=1;
   }
   else if(KValue2<20&&DValue2<20){
      signalStochastic="oversold";
      IndexOfOversoldStoch=1;
   }
   
   return signalStochastic;
}
int GetTheHighestCandle(int candles){
   double HighestCandle;
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,candles,High);
   HighestCandle=ArrayMaximum(High,0,WHOLE_ARRAY);
   
   return HighestCandle;
}
int GetTheLowestCandle(int candles){
   double LowestCandle;
   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,candles,Low);
   LowestCandle=ArrayMinimum(Low,0,WHOLE_ARRAY);
   
   return LowestCandle;
}
double CalculateRRR(double SLPrice,bool BuyingQuestionMark){
   
   double TPPrice=0;
   if(BuyingQuestionMark){
      double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      TPPrice=Ask+1.5*(Ask-SLPrice);
      TPPrice=TPPrice-3*_Point;
   }
   else if(!BuyingQuestionMark){
      double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      TPPrice=Bid-1.5*(SLPrice-Bid);
   }    
   return TPPrice;
}
void CloseAllSellPos(){
   
   for(int i=PositionsTotal()-1;i>=0;i--){
      int ticket=PositionGetTicket(i);
      
      //is it buy or sell postion
      int PositionsType=PositionGetInteger(POSITION_TYPE);
      
      if(PositionsType==POSITION_TYPE_SELL){
         trade.PositionClose(ticket);
      }
   }
}
void CloseAllBuyPos(){
   
   for(int i=PositionsTotal()-1;i>=0;i--){
      int ticket=PositionGetTicket(i);
      
      //is it buy or sell postion
      int PositionsType=PositionGetInteger(POSITION_TYPE);
      
      if(PositionsType==POSITION_TYPE_BUY){
         trade.PositionClose(ticket);
      }
   }
}