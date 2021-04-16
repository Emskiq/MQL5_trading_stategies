
double CCIUnder200[4]={120,1,0,0};
string CCIS="";
int i=3;
void OnTick(){
   
   MqlRates PriceInfo[];
   
   ArraySetAsSeries(PriceInfo,true);
   
   int PriceData=CopyRates(_Symbol,_Period,0,300,PriceInfo);
   
   int frame=110;
      
   int HighestCandle=GetTheHighestCandle(frame);
   int LowestCandle=GetTheLowestCandle(frame);
   
   int tempFrame=frame;   
   
   datetime time1=PriceInfo[HighestCandle].time;
   double price1=PriceInfo[HighestCandle].high;
   datetime time2=PriceInfo[LowestCandle].time;
   double price2=PriceInfo[LowestCandle].high;
   string emski="";
   
   if(time2<time1)emski="predi highest";
   else emski="sled highest";
   
   
   
   ObjectDelete(_Symbol,"TrendLine");
   
   ObjectCreate(_Symbol,"TrendLine",OBJ_TREND,0,time1,price1,time2,price2);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_COLOR,clrBlue);
    
   //dali da e punktirana ili solid(toest ne prekysnata)
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_STYLE,STYLE_SOLID);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_WIDTH,2);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_RIGHT,true);
   
   Comment(emski);
   
   
}
void arrayPush(double dataToPush){
    
    int count=ArrayResize(CCIUnder200,ArraySize(CCIUnder200)+1);
    
    CCIUnder200[ArraySize(CCIUnder200)-1]=CCIUnder200[0];
    CCIUnder200[0]=dataToPush;
    CCIUnder200[1]=CCIUnder200[ArraySize(CCIUnder200)-1];
    
    //count=ArrayResize(CCIUnder200,ArraySize(CCIUnder200)-1);
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