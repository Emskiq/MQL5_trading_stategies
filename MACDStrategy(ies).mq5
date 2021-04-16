//video: https://www.youtube.com/watch?v=nmffSjdZbWQ&ab_channel=TRADINGRUSH + my own prozreniq za trading with other indicators  

#include<Trade\Trade.mqh>
CTrade  trade;
bool MACDCounted=false;
string signalRSI="";
string signal="";

void OnTick(){
   
   //namirame kupi-prodai cenite
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   string signalMACD="";
   
   //arr for the candles (looking back 30 candles)
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true);
   int PriceData=CopyRates(_Symbol,_Period,0,30,PriceInfo);
   
   //MACD oscilator for crossing up and down
   double MACDPriceArr[];
   int MacDDef=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE); 
   ArraySetAsSeries(MACDPriceArr,true);
   CopyBuffer(MacDDef,0,0,30,MACDPriceArr);
   
   if(MACDPriceArr[2]<0&&MACDPriceArr[1]>0)signalMACD="cross up";
   else if(MACDPriceArr[2]>0&&MACDPriceArr[1]<0)signalMACD="cross down";
   else signalMACD="";
   
   //set the EMA for 100 candles
   double EMA200[];
   int EMA200Def=iMA(_Symbol,_Period,200,0,MODE_EMA,PRICE_CLOSE);
   CopyBuffer(EMA200Def,0,0,30,EMA200);
   
   //set the EMA for 20 candles
   //double EMA20[];
   //int EMA20Def=iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE);
   //CopyBuffer(EMA20Def,0,0,30,EMA20);
   
   //array for the 14 Average True Range
   double ATFArr[];
   int AverageTrueRangeDef=iATR(_Symbol,_Period,14);
   ArraySetAsSeries(ATFArr,true);
   CopyBuffer(AverageTrueRangeDef,0,0,30,ATFArr);
   
   //check whether we are in RSIUpTrend or RSIDownTrend
   string RSITrend=CheckRSI();
   string EMATrend=CheckEMA(EMA200,PriceInfo);
   
   if(!MACDCounted&&signalMACD=="cross up"){
      Print("Macd cross up");
      MACDCounted=true;
      if(EMATrend=="up trend"){
         Print("rosa dgd she si 100 pyti po bogat ot tehnite det jiveqt na trkata v ogormna kyshta i q izdyrjat u holandiq");
         signal="buy";
      }
   }
   else if(!MACDCounted&&signalMACD=="cross down"){
      Print("Macd cross down");
      MACDCounted=true;
      if(EMATrend=="down trend"){
         Print("rosa dgd she si 100 pyti po bogat ot tehnite det jiveqt na trkata v ogormna kyshta i q izdyrjat u holandiq");
         signal="sell";
      }
   }
   else if(MACDCounted&&signalMACD=="")MACDCounted=false;
   
   if(signal=="buy"&&PositionsTotal()<1){
      int LowestCandle=GetTheLowestCandle(15);
      double SLPrice=PriceInfo[LowestCandle].low-ATFArr[LowestCandle];
      double TPPrice=CalculateRRR(SLPrice,true);
      
      signal="";
      trade.Buy(0.60,NULL,Ask,SLPrice,TPPrice,NULL);
   }
   if(signal=="sell"&&PositionsTotal()<1){
      int HighestCandle=GetTheHighestCandle(15);
      double SLPrice=PriceInfo[HighestCandle].high+ATFArr[HighestCandle];
      double TPPrice=CalculateRRR(SLPrice,false);
      
      signal="";
      trade.Sell(0.60,NULL,Bid,SLPrice,TPPrice,NULL);
   }
   
   Comment("RSI trend: ",RSITrend,"\n",
           "EMA trend: ",EMATrend,"\n");
}
string CheckRSI(){
   
   string RSITrend="";
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
   
   if(myRSIValue>70)signalRSI="overbought";
   else if(myRSIValue<30) signalRSI="oversold";
   else signalRSI="";
   
   int CountForTrend=0;
   
   for(int count=1;count<=10;count++){
      if(MyRSIArr[count]>=50)CountForTrend++;
      else CountForTrend--;
   }
   if(CountForTrend>=10)RSITrend="up trend";
   else if(CountForTrend<=-10)RSITrend="down trend";
   else RSITrend="";
   
   return RSITrend;   
}
string CheckEMA(double &EMA100[],MqlRates &Prices[]){
   
   string EMATrend="";
   int tempCount=0;
   
   for(int count=1;count<=7;count++){
      
      if(EMA100[count]<Prices[count].low)tempCount++;
      else if(EMA100[count]>Prices[count].high)tempCount--;
      
   }
   if(tempCount>=7)EMATrend="up trend";
   else if(tempCount<=-7)EMATrend="down trend";
   else EMATrend="";
   
   return EMATrend;
}
double CalculateRRR(double SLPrice,bool BuyingQuestionMark){

   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);    
   
   double TPPrice=0;
   if(BuyingQuestionMark){
      
      TPPrice=Ask+1.5*(Ask-SLPrice);
   }
   else {
      
      TPPrice=Bid-1.5*(SLPrice-Bid);
   }    
   return TPPrice;
}
int GetTheHighestCandle(int candles){
   int HighestCandle;
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,candles+1,High);
   HighestCandle=ArrayMaximum(High,0,WHOLE_ARRAY);
   
   return HighestCandle;
}
int GetTheLowestCandle(int candles){
   int LowestCandle;
   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,candles+1,Low);
   LowestCandle=ArrayMinimum(Low,0,WHOLE_ARRAY);
   
   return LowestCandle;
}