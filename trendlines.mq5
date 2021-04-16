#include<Trade\Trade.mqh>
CTrade  trade;


void OnTick(){
    
    int candles=20;
    double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
    double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    
    MqlRates PriceInfo[];
    ArraySetAsSeries(PriceInfo,true);
    //Kopirame dannite v array-q za 3 canlde-a
    int Data=CopyRates(Symbol(),Period(),0,candles,PriceInfo);
    
    int HighestCandle=GetTheHighestCandle(candles), LowestCandle=GetTheLowestCandle(candles);
    string TrendLineDirection="";
    
    datetime time1=PriceInfo[HighestCandle].time;
    double price1=PriceInfo[HighestCandle].high;
    datetime time2=PriceInfo[LowestCandle].time;
    double price2=PriceInfo[LowestCandle].high;
    
    if(PriceInfo[LowestCandle].time<PriceInfo[HighestCandle].time){
      TrendLineDirection="left";
    }
    else if(PriceInfo[LowestCandle].time>PriceInfo[HighestCandle].time){
      TrendLineDirection="right";
      ObjectDelete(_Symbol,"TrendLine");
    
      ObjectCreate(_Symbol,"TrendLine",OBJ_TREND,0,time1,price1,time2,price2);
    
      ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_COLOR,clrBlue);
    
      //dali da e punktirana ili solid(toest ne prekysnata)
      ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_STYLE,STYLE_SOLID);
    
      ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_WIDTH,2);
    
      ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_RIGHT,true);
    }
    
    Comment(TrendLineDirection);
   
}
int GetTheHighestCandle(int candles){
   double HighestCandle;
   double High[];
   ArraySetAsSeries(High,true);
   CopyClose(_Symbol,_Period,0,candles,High);
   HighestCandle=ArrayMaximum(High,0,WHOLE_ARRAY);
   
   return HighestCandle;
}
int GetTheLowestCandle(int candles){
   double LowestCandle;
   double Low[];
   ArraySetAsSeries(Low,true);
   CopyClose(_Symbol,_Period,0,candles,Low);
   LowestCandle=ArrayMinimum(Low,0,WHOLE_ARRAY);
   
   return LowestCandle;
}