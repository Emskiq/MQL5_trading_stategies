//video: https://www.youtube.com/watch?v=xFNpN1W3-ag&list=WL&index=11&t=0s

#include<Trade\Trade.mqh>
CTrade  trade;

bool SwingHighCounted=false, SwingLowCounted=false;
bool BounceCounted=false;
int candleCounter=11;
bool WaitingForBounceUp=false;
bool WaitingForBounceDown=false;

bool BreakedUpperResLevel=false;
bool TouchedUpperResLevel=false;
bool WaitingForBuySignal=false;
bool BuyEntry=false;

bool BreakedLowerResLevel=false;
bool TouchedLowerResLevel=false;
bool WaitingForSellSignal=false;
bool SellEntry=false;

void OnTick(){
    
    double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
    double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    string CandleState; //boolish ili bearish
    string signal="";
    
    MqlRates PriceInfo[];
    ArraySetAsSeries(PriceInfo,true);
    int PriceData=CopyRates(_Symbol,_Period,0,300,PriceInfo); 
    
    
    double EMAArray[];
    ArraySetAsSeries(EMAArray,true);
    int EMADeff=iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE);
    CopyBuffer(EMADeff,0,0,100,EMAArray);
    double EMAValue=EMAArray[0];
    
    double ATFArr[];
    int AverageTrueRangeDef=iATR(_Symbol,_Period,14);
    ArraySetAsSeries(ATFArr,true);
    CopyBuffer(AverageTrueRangeDef,0,0,3,ATFArr);
    double AverageTrueRangeVal=NormalizeDouble(ATFArr[1],5);
    
    
    if(IsBoolish(PriceInfo[1])==true)CandleState="boolish";
    else if(IsBoolish(PriceInfo[1])==false)CandleState="bearish";
    
    
    string EMAState=EMAPosition(PriceInfo[2],EMAArray[2]);
    string isSwing=IsSwing(PriceInfo,EMAState);
    string IsBounceOfEMA=IsBounceOfEMA(PriceInfo,EMAArray,EMAState);
    
    if(isSwing=="swing high"&&SwingHighCounted==false&&WaitingForBounceUp==false){
      
      Print(isSwing," IN CANDLE TIME: ",PriceInfo[3].time);
      DrawUpSuportLine(PriceInfo[3]);
      WaitingForBounceUp=true;
      //WaitingForBounceDown=false;
      SwingHighCounted=true;
      
    }
    else if(isSwing=="swing low"&&SwingLowCounted==false&&WaitingForBounceDown==false){
      
      Print(isSwing," IN CANDLE TIME: ",PriceInfo[3].time);
      DrawDownSuportLine(PriceInfo[3]);
      //WaitingForBounceUp=false;
      WaitingForBounceDown=true;
      SwingLowCounted=true;
      
    }
    else if(isSwing=="no swing"){
      SwingLowCounted=false;
      SwingHighCounted=false;
    }
    
    static datetime TimeStampLastCheck;
    datetime TimeStampCurrentCandle=PriceInfo[0].time;
    static bool WatingForBreakRes=false;
    
    //
    // Buy signal calculation 
    //
    
    if(WaitingForBounceUp==true){
      
      if(TimeStampCurrentCandle!=TimeStampLastCheck){
        TimeStampLastCheck=TimeStampCurrentCandle;
        candleCounter--;
      }
      if(candleCounter==0){
        candleCounter=11;
        WaitingForBounceUp=false;
        WatingForBreakRes=false;
        BreakedUpperResLevel=false;
        WaitingForBuySignal=false;
        TouchedUpperResLevel=false;
        BuyEntry=false;
        signal="";
        BounceCounted=false;
        ObjectDelete(_Symbol,"UP SuportLine");
        ObjectDelete(_Symbol,"Down SuportLine");
      }
    
      if(IsBounceOfEMA=="bounce up"&&BounceCounted==false){
         Print(IsBounceOfEMA," IN CANDLE TIME(buuummm): ",PriceInfo[3].time);
         BounceCounted=true;
         candleCounter=13;
         WatingForBreakRes=true;
      }
      
      if(WatingForBreakRes&&!BreakedUpperResLevel){
         bool IsBreakRes=BreakUpperResistance(PriceInfo);
         if(IsBreakRes){
            Print("Break Up Res level at candle.time: ",PriceInfo[2].time);
            candleCounter=25;
            BreakedUpperResLevel=true;
         }
      }
      if(BreakedUpperResLevel){
         TouchedUpperResLevel=TouchingUperrResLevel(PriceInfo,EMAArray);
         WatingForBreakRes=false;
      }
      if(TouchedUpperResLevel){
         WaitingForBuySignal=true;
         Print("Touch in candle time: ",PriceInfo[1].time);
         TouchedUpperResLevel=false;
         BreakedUpperResLevel=false;
         candleCounter=5;
      }
      if(WaitingForBuySignal){
         BuyEntry=IsHammer(PriceInfo[1]);
         if(BuyEntry){
            WaitingForBuySignal=false;
            signal="buy";
            BuyEntry=false;
            Print("Buy entry at candle time: ",PriceInfo[1].time);
         }
      }
    }
    
    //
    // Sell signal calculation 
    //
    
    if(WaitingForBounceDown==true){
     
      if(TimeStampCurrentCandle!=TimeStampLastCheck){
        TimeStampLastCheck=TimeStampCurrentCandle;
        candleCounter--;
      }
      if(candleCounter==0){
        candleCounter=11;
        WaitingForBounceDown=false;
        WatingForBreakRes=false;
        BreakedLowerResLevel=false;
        WaitingForSellSignal=false;
        TouchedLowerResLevel=false;
        SellEntry=false;
        signal="";
        BounceCounted=false;
        ObjectDelete(_Symbol,"UP SuportLine");
        ObjectDelete(_Symbol,"Down SuportLine");
      }
    
      if(IsBounceOfEMA=="bounce down"&&BounceCounted==false){
         Print(IsBounceOfEMA," IN CANDLE TIME(buuummm): ",PriceInfo[3].time);
         BounceCounted=true;
         candleCounter=13;
         WatingForBreakRes=true;
      }
      
      if(WatingForBreakRes&&!BreakedLowerResLevel){
         bool IsBreakRes=BreakLowerResistance(PriceInfo);
         if(IsBreakRes){
            Print("Break Lower Res level at candle.time: ",PriceInfo[2].time);
            candleCounter=25;
            BreakedLowerResLevel=true;
         }
      }
      if(BreakedLowerResLevel){
         TouchedLowerResLevel=TouchingLowerResLevel(PriceInfo,EMAArray);
         WatingForBreakRes=false;
      }
      if(TouchedLowerResLevel){
         WaitingForSellSignal=true;
         Print("Touch in candle time: ",PriceInfo[1].time);
         TouchedLowerResLevel=false;
         BreakedLowerResLevel=false;
         candleCounter=5;
      }
      if(WaitingForSellSignal){
         SellEntry=IsShootingStar(PriceInfo[1]);
         
         if(SellEntry){
            WaitingForSellSignal=false;
            signal="sell";
            SellEntry=false;
            Print("Sell entry at candle time: ",PriceInfo[1].time);
         }
      }
      
    }
    
    if(signal=="buy"&&LongPositionsTotal()<1){
      int LowestCandle=GetTheLowestCandle(7);
      double SLPrice=PriceInfo[LowestCandle].low-AverageTrueRangeVal;
      double TPPrice=CalculateRRR(SLPrice,true);
      
      signal="";
      trade.Buy(0.10,NULL,Ask,SLPrice,TPPrice,NULL);         
   }
   
   if(signal=="sell"&&ShortPositionsTotal()<1){
      int HighestCandle=GetTheHighestCandle(7);
      double SLPrice=PriceInfo[HighestCandle].high+AverageTrueRangeVal;
      double TPPrice=CalculateRRR(SLPrice,false);
      
      signal="";
      trade.Sell(0.10,NULL,Bid,SLPrice,TPPrice,NULL);         
   }
    
    Comment("The previous candle was ",CandleState,"\n",
            "Swing high counted: ", SwingHighCounted,"\n",
            "Swing low counted: ", SwingLowCounted,"\n",
            "Waiting for bounce up: ", WaitingForBounceUp,"\n",
            "Waiting for bounce down: ", WaitingForBounceDown,"\n",
            "Waiting for break res: ", WatingForBreakRes,"\n",
            "Postion of EMA: ", EMAState,"\n",
            "Waiting For Buy Signal: ", WaitingForBuySignal,"\n",
            "Candle counter: ", candleCounter,"\n");
            
 
}
bool IsBoolish(MqlRates &Candle){
   bool isBoolish=false;
   if(Candle.close>=Candle.open)isBoolish=true;
   return isBoolish;
}
string IsSwing(MqlRates &Prices[],string EMAState){
   string swing="no swing";
   
   if(IsBoolish(Prices[5])&&IsBoolish(Prices[4])&&IsBoolish(Prices[2])==false&&IsBoolish(Prices[1])==false){ 
         
         if(Prices[3].high>=Prices[2].high&&Prices[2].high>=Prices[1].high&&EMAState=="below")swing="swing high";
   
   }
   
   else if(!IsBoolish(Prices[5])&&!IsBoolish(Prices[4])&&IsBoolish(Prices[2])&&IsBoolish(Prices[1])){ 
         
         if(Prices[3].low<=Prices[2].low&&Prices[2].low<=Prices[1].low&&EMAState=="above")swing="swing low";
   
   }
   return swing;
}
string EMAPosition(MqlRates &candle,double EMAValue){
   string IsBelow="";
   
   if(candle.low+3*_Point>EMAValue)IsBelow="below";
   else IsBelow="above";
   
   return IsBelow;
   
}
void DrawUpSuportLine(MqlRates &Candle){

   ObjectDelete(_Symbol,"UP SuportLine");
   
   ObjectCreate(_Symbol,"UP SuportLine",OBJ_HLINE,0,0,Candle.close);
   
   ObjectSetInteger(_Symbol,"UP SuportLine",OBJPROP_WIDTH,2); 
   ObjectSetInteger(_Symbol,"UP SuportLine",OBJPROP_COLOR,clrBlue); 
   
}
void DrawDownSuportLine(MqlRates &Candle){

   ObjectDelete(_Symbol,"Down SuportLine");
   
   ObjectCreate(_Symbol,"Down SuportLine",OBJ_HLINE,0,0,Candle.close);
   
   ObjectSetInteger(_Symbol,"Down SuportLine",OBJPROP_WIDTH,2); 
   ObjectSetInteger(_Symbol,"Down SuportLine",OBJPROP_COLOR,clrBlue); 
   
}
string IsBounceOfEMA(MqlRates &PriceArr[],double &EMAValues[],string EMAPos){
   
   string bounce="no bounce";
   
   for(int i=1;i<=5;i++){
      EMAValues[i]=NormalizeDouble(EMAValues[i],_Digits);
   }
   
   if(EMAPos=="below"){
      
      if(PriceArr[1].low>EMAValues[1]&&PriceArr[2].low>=EMAValues[2]&&PriceArr[3].low<=EMAValues[3]
         &&PriceArr[4].low<=EMAValues[4]&&PriceArr[5].low>EMAValues[5]) bounce="bounce up";
         
      else if(PriceArr[1].low>EMAValues[1]&&PriceArr[2].low>EMAValues[2]&&PriceArr[3].low<=EMAValues[3]
              &&PriceArr[4].low>=EMAValues[4]&&PriceArr[5].low>EMAValues[5]) bounce="bounce up";
              
      else bounce="no bounce";
     
   }
   if(EMAPos=="above"){
      
      if(PriceArr[1].high<EMAValues[1]&&PriceArr[2].high<=EMAValues[2]&&PriceArr[3].high>=EMAValues[3]
         &&PriceArr[4].high>=EMAValues[4]&&PriceArr[5].high<EMAValues[5]) bounce="bounce down";
      
      else if(PriceArr[1].high<EMAValues[1]&&PriceArr[2].high<=EMAValues[2]&&PriceArr[3].high>=EMAValues[3]
              &&PriceArr[4].high<=EMAValues[4]&&PriceArr[5].high<EMAValues[5]) bounce="bounce down";
      
      else bounce="bounce";
      
   }
   
   
   return bounce;
}
bool IsShootingStar(MqlRates &candle){
   
   double DifferenceBetweenHighAndLow=candle.high-candle.low;
   
   double OneThird=DifferenceBetweenHighAndLow/3;
   
   if((OneThird+candle.low)>=candle.open&&(OneThird+candle.low)>=candle.close)return true;
   else return false;
   
}
bool IsHammer(MqlRates &candle){
   
   double DifferenceBetweenHighAndLow=candle.high-candle.low;
   
   double OneThird=DifferenceBetweenHighAndLow/3;
   
   if((candle.high-OneThird)<=candle.open&&(candle.high-OneThird)<=candle.close)return true;
   else return false;
   
}
bool BreakUpperResistance(MqlRates &candles[]){

   bool result=false;
   double ResPrice=ObjectGetDouble(_Symbol,"UP SuportLine",OBJPROP_PRICE,0);
   
   if(candles[2].high>=ResPrice&&candles[1].open>ResPrice&&candles[0].open>ResPrice)result=true;
   else result=false;
   
   return result;
   
}
bool BreakLowerResistance(MqlRates &candles[]){

   bool result=false;
   double ResPrice=ObjectGetDouble(_Symbol,"Down SuportLine",OBJPROP_PRICE,0);
   
   if(candles[2].low<=ResPrice&&candles[1].open<ResPrice&&candles[0].open<ResPrice)result=true;
   else result=false;
   
   return result;
   
}
bool TouchingUperrResLevel(MqlRates &candles[],double &EMAArray[]){
   bool result=false;
   
   if(candles[1].low<=EMAArray[1])result=true;
   else result=false;
   
   return result;
}
bool TouchingLowerResLevel(MqlRates &candles[],double &EMAArray[]){
   bool result=false;
   
   if(candles[1].high>=EMAArray[1])result=true;
   else result=false;
   
   return result;
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
int LongPositionsTotal(){
   int NumberOfBuyPos=0;
      
   for(int i=0;i<PositionsTotal();i++){
      string CurrencyPair=PositionGetSymbol(i); 
         
      int PositionsType=PositionGetInteger(POSITION_TYPE);
         
      if(Symbol()==CurrencyPair){
         if(PositionsType==POSITION_TYPE_BUY){
            NumberOfBuyPos++;  
         }
      }
   }
   return NumberOfBuyPos;
   
}
int ShortPositionsTotal(){
   
   int NumberOfSellPos=0;
      
   for(int i=0;i<PositionsTotal();i++){
      string CurrencyPair=PositionGetSymbol(i); 
         
      int PositionsType=PositionGetInteger(POSITION_TYPE);
         
      if(Symbol()==CurrencyPair){
         if(PositionsType==POSITION_TYPE_SELL){
            NumberOfSellPos++;  
         }
      }
   }
   return NumberOfSellPos;
   
}