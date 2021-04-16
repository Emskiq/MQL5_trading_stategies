//video: https://www.youtube.com/watch?v=PJXaNf9bn_Q&list=WL&index=2&t=0s

#include<Trade\Trade.mqh>
CTrade  trade;

bool SignalCounted=false;
string signalSAR="";
string PositionEMA20="";

void OnTick(){
   
   //namirame kupi prodai cenite
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); 
   string signal="";
   string signalMACD="";
   
   //array for the candles/prices
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true);
   int PriceData=CopyRates(_Symbol,_Period,0,300,PriceInfo); 
   
   //array for the 20 EMA
   double EMAArray20[];
   ArraySetAsSeries(EMAArray20,true);
   int EMADeff20=iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE);
   CopyBuffer(EMADeff20,0,0,100,EMAArray20);
   double EMAValue=EMAArray20[1];
   
   //array for the 20 EMA
   double EMAArray50[];
   ArraySetAsSeries(EMAArray50,true);
   int EMADeff50=iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE);
   CopyBuffer(EMADeff50,0,0,100,EMAArray50);
   CheckEMA20AndEMA50(EMAArray20,EMAArray50);
   
   //array for the 14 Average True Range
   double ATFArr[];
   int AverageTrueRangeDef=iATR(_Symbol,_Period,14);
   ArraySetAsSeries(ATFArr,true);
   CopyBuffer(AverageTrueRangeDef,0,0,3,ATFArr);
   double AverageTrueRangeVal=NormalizeDouble(ATFArr[1],5);
   
   //praim i parabolic SAR indicator
   CheckSAR();
   
   //proame MACD oscilator
   //double MyPriceArr[];
   //int MacDDef=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE); 
   //CopyBuffer(MacDDef,0,0,3,MyPriceArr);
   //float MacDValue=(MyPriceArr[1]);
   //if(MacDValue>0)signalMACD="sell";
   //if(MacDValue<0)signalMACD="buy";
   
   
   
   
   //puskame dali ima crosing i kakyv e po tochno
   string CrossedEMA=IsCrossedEMAWithCandle(PriceInfo,EMAArray20);
   bool PreviousCandleIsBoolish=IsBoolish(PriceInfo[2]);
   
   //logikata za buy trade
   if(CrossedEMA=="cross"&&PreviousCandleIsBoolish){
      if(PriceInfo[2].close>EMAArray20[2]){
         if(IsBoolish(PriceInfo[1])&&PriceInfo[1].close>PriceInfo[2].high){
            signal="buy";
            SignalCounted=true;
         }
         else SignalCounted=false;
      }
      else SignalCounted=false;
   }
   //logikata za sell trade
   if(CrossedEMA=="cross"&&!PreviousCandleIsBoolish){
      if(PriceInfo[2].close<EMAArray20[2]){
         if(!IsBoolish(PriceInfo[1])&&PriceInfo[1].close<PriceInfo[2].low){
            signal="sell";
            SignalCounted=true;
         }
         else SignalCounted=false;
      }
      else SignalCounted=false;
   }
   
   
   if(signal=="buy"&&PositionEMA20=="above the 50"&&signalSAR=="buy"&&LongPositionsTotal()<1){
      int LowestCandle=GetTheLowestCandle(5);
      double SLPrice=PriceInfo[LowestCandle].low-AverageTrueRangeVal;
      double TPPrice=CalculateRRR(SLPrice,true);
      
      signal="";
      trade.Buy(0.20,NULL,Ask,0,TPPrice,NULL);
   }
   
   if(signal=="sell"&&PositionEMA20=="below the 50"&&signalSAR=="sell"&&ShortPositionsTotal()<1){
      int HighestCandle=GetTheHighestCandle(5);
      double SLPrice=PriceInfo[HighestCandle].high+AverageTrueRangeVal;
      double TPPrice=CalculateRRR(SLPrice,false);
      
      signal="";
      trade.Sell(0.20,NULL,Bid,0,TPPrice,NULL);
   }
   
   Comment("Crosing: ",CrossedEMA,"\n",
           "SignalSAR: ",signalSAR,"\n",
           "Position of the 20EMA: ",PositionEMA20);
   
}
//funkciq za crosvane ne 20kata EMA s Candle (she kaje dali e boolish ili bearish)
string IsCrossedEMAWithCandle(MqlRates &PriceInfo[],double &EMAArray[]){
   string crosing="";
   if(PriceInfo[2].low<EMAArray[2]&&PriceInfo[2].high>EMAArray[2])crosing="cross";
   
   return crosing;
}
//qsna e taq funckiq
bool IsBoolish(MqlRates &Candle){
   bool isBoolish=false;
   if(Candle.close>=Candle.open)isBoolish=true;
   return isBoolish;
}
//i teq dvete funkcii sushto sa qsni
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
double CalculateRRR(double SLPrice,bool BuyingQuestionMark){

   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);    
   
   double TPPrice=0;
   if(BuyingQuestionMark){
      
      TPPrice=Ask+1.3*(Ask-SLPrice);
   }
   else {
      
      TPPrice=Bid-1.3*(SLPrice-Bid);
   }    
   return TPPrice;
}
void CheckSAR(){
     MqlRates PriceArr[];
    
     ArraySetAsSeries(PriceArr,true);
     //Kopirame dannite v array-q
     int Data=CopyRates(Symbol(),Period(),0,3,PriceArr);
     
     double mySARArray[];
     
     int SARDef=iSAR(Symbol(),_Period,0.02,0.2);
     
     ArraySetAsSeries(mySARArray,true);
     
     CopyBuffer(SARDef,0,0,3,mySARArray);
     
     double LastSARValue=NormalizeDouble(mySARArray[1],5);
     if(signalSAR==""){
        if(LastSARValue<PriceArr[1].low)signalSAR="buy";
        
        if(LastSARValue>PriceArr[1].high)signalSAR="sell";
     }
     else if(signalSAR=="sell"){
        if(LastSARValue<PriceArr[1].low)
        {
            signalSAR="buy";
            //LastBuySignal=PriceArr[1].close;
        }
     }
     else if(signalSAR=="buy"){
        if(LastSARValue>PriceArr[1].high)
        {
           signalSAR="sell";
           //LastSellSignal=LastSARValue;
        }
     }
}
void CheckEMA20AndEMA50(double &EMAArray20[],double &EMAArray50[]){
   
   int countBelow=0;
   int countAbove=0;
   
   for(int i=5;i>=0;i--){
      if(EMAArray20[i]-0.000033>EMAArray50[i])countAbove++;
      if(EMAArray20[i]+0.000033<EMAArray50[i])countBelow++;
   }
   
   if(countAbove==6)PositionEMA20="above the 50";
   else if(countBelow==6)PositionEMA20="below the 50";
   else PositionEMA20="none for the moment";
   
}