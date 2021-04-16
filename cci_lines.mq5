//video: https://www.youtube.com/watch?v=yrqd15Ph-tw

#include<Trade\Trade.mqh>
CTrade  trade;

double CCIUnder200[4]={0,1,0,0};
string CCILineDirection="";
string ChartLineDirection="";
int candleCounter=0;
string signal="";
string signalSAR="";
double LastBuySignal;
double LastBuyEntry;
double CurrentSAR;

MqlRates CCIPrices[3];   
bool ChangeInData=false;

void OnTick(){
   
   //namirame kupi prodai cenite
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true);
   int PriceData=CopyRates(_Symbol,_Period,0,300,PriceInfo);

   
   double myCCIArray[];
   int CCIDeff=iCCI(_Symbol,_Period,14,PRICE_CLOSE);
   ArraySetAsSeries(myCCIArray,true);
   CopyBuffer(CCIDeff,0,0,6,myCCIArray);
   float CCIValue=myCCIArray[1];
   
   //array for the 14 Average True Range
   double ATFArr[];
   int AverageTrueRangeDef=iATR(_Symbol,_Period,14);
   ArraySetAsSeries(ATFArr,true);
   CopyBuffer(AverageTrueRangeDef,0,0,3,ATFArr);
   double AverageTrueRangeVal=NormalizeDouble(ATFArr[1],5);
   
   if(myCCIArray[3]<-200){
      
      bool ToSkip=false;
      double LowestCCIValue=myCCIArray[ArrayMinimum(myCCIArray,0,WHOLE_ARRAY)];
      
      if(LowestCCIValue==myCCIArray[0]||LowestCCIValue==myCCIArray[1]||
         LowestCCIValue==myCCIArray[2]||LowestCCIValue==myCCIArray[4]||
         LowestCCIValue==myCCIArray[5])ToSkip=true;          
      
      else if(LowestCCIValue==myCCIArray[3])ToSkip=false;
      
      if(ToSkip==false){
         arrayPush(LowestCCIValue);
         MqlPush(PriceInfo[3]);
         ChangeInData=true;
      }
       
   }
   
   //the candle counter, drawing lines       
   if(CCIUnder200[0]!=0&&CCIUnder200[1]!=0){      
      DrawCCILine();
      DrawChartLine();
      if(ChangeInData==true){
         Print("****Candle Counter: ",candleCounter); //for betwwen old and new cci line
         candleCounter=0;
         ChangeInData=false;
         DrawTrendLine(PriceInfo);
      }
      candleCounter++;
   }
   if(CCIUnder200[0]!=0&&CCIUnder200[1]==0){          //for the begiining of the counter
      candleCounter++;
   }
   
   
   double CurrentTrendLineValue=ObjectGetValueByTime(_Symbol,"TrendLine",TimeCurrent(),0);
   
   if((PriceInfo[1].open>CurrentTrendLineValue&&PriceInfo[1].close<CurrentTrendLineValue)
      ||(PriceInfo[1].open<CurrentTrendLineValue&&PriceInfo[1].close>CurrentTrendLineValue)){
      Print("****===  BreakThrough");
      if(CCILineDirection=="up"&&ChartLineDirection=="down"){
         signal="buy";
         Print("bum lelele");
      }
      else signal="";
   }
   
   //ChekSAR();
   
      if(signal=="buy"&&PositionsTotal()<1){
      
         int LowestCandle=GetTheLowestCandle(20);
         double SLPrice=PriceInfo[LowestCandle].low-AverageTrueRangeVal;
         double TPPrice=CalculateRRR(SLPrice,true);
      
         signal="";
         trade.Buy(0.20,NULL,Ask,0,TPPrice,NULL);         
      }
    
   //CheckSARBuyTrailingStop(CurrentSAR);
   
   if(PositionsTotal()==1)signal="";
   
   
   Comment("CCIUnder200[0]: ",CCIUnder200[0],"\n",
           "CCIUnder200[0] ",CCIUnder200[1],"\n"
           "CCILineDirection: ",CCILineDirection,"\n",
           "ChartLineDireciton: ",ChartLineDirection,"\n"
           "ChangeIndata: ",ChangeInData,"\n"
           "CandleCounter: ",candleCounter,"\n",
           "Sigal: ",signal,"\n",
           "Sigal_SAR: ",signalSAR,"\n");
           
}
double CheckLowestCCI(double &CCIArr[]){
   //ArraySetAsSeries(CCIArr,true);
   double LowestValue=ArrayMinimum(CCIArr,0,WHOLE_ARRAY);
   
   return LowestValue;
}
void arrayPush(double dataToPush){
    
    int count=ArrayResize(CCIUnder200,ArraySize(CCIUnder200)+1);
    
    CCIUnder200[ArraySize(CCIUnder200)-1]=CCIUnder200[0];
    CCIUnder200[0]=dataToPush;
    CCIUnder200[1]=CCIUnder200[ArraySize(CCIUnder200)-1];
    
    count=ArrayResize(CCIUnder200,ArraySize(CCIUnder200)-1);
}
void MqlPush(MqlRates &Candle){
   int count=ArrayResize(CCIPrices,ArraySize(CCIPrices)+1);
   
   CCIPrices[ArraySize(CCIPrices)-1]=CCIPrices[0];
   CCIPrices[0]=Candle;
   CCIPrices[1]=CCIPrices[ArraySize(CCIPrices)-1];
   
   count=ArrayResize(CCIPrices,ArraySize(CCIPrices)-1);
}
void DrawCCILine(){
   
      ObjectDelete(_Symbol,"CCILine");
    
      ObjectCreate(_Symbol,"CCILine",OBJ_TREND,1,CCIPrices[1].time,CCIUnder200[1],CCIPrices[0].time,CCIUnder200[0]);
    
      ObjectSetInteger(_Symbol,"CCILine",OBJPROP_COLOR,clrBlue);
    
      //dali da e punktirana ili solid(toest ne prekysnata)
      ObjectSetInteger(_Symbol,"CCILine",OBJPROP_STYLE,STYLE_SOLID);
    
      ObjectSetInteger(_Symbol,"CCILine",OBJPROP_WIDTH,2);
    
      ObjectSetInteger(_Symbol,"CCILine",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(_Symbol,"CCILine",OBJPROP_RAY_RIGHT,false);
      
      if(CCIUnder200[0]>CCIUnder200[1])CCILineDirection="up";
      else CCILineDirection="down";
      
}
void DrawChartLine(){
      
      
      ObjectDelete(_Symbol,"ChartLine");
    
      ObjectCreate(_Symbol,"ChartLine",OBJ_TREND,0,CCIPrices[1].time,CCIPrices[1].close-10*_Point,CCIPrices[0].time,CCIPrices[0].close-10*_Point);
    
      ObjectSetInteger(_Symbol,"ChartLine",OBJPROP_COLOR,clrGreenYellow);
    
      //dali da e punktirana ili solid(toest ne prekysnata)
      ObjectSetInteger(_Symbol,"ChartLine",OBJPROP_STYLE,STYLE_SOLID);
    
      ObjectSetInteger(_Symbol,"ChartLine",OBJPROP_WIDTH,2);
    
      ObjectSetInteger(_Symbol,"ChartLine",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(_Symbol,"ChartLine",OBJPROP_RAY_RIGHT,false);
      
      if(CCIPrices[0].close<CCIPrices[1].close)ChartLineDirection="down";
      else ChartLineDirection="up";
}

void DrawTrendLine(MqlRates &PriceInfo[]){
   
   int frame=0;

   if(candleCounter<=20)frame=50;
   else frame=candleCounter+30;
      
   int HighestCandle=GetTheHighestCandle(frame);
   int LowestCandle=GetTheLowestCandle(frame);
   
   int tempFrame=frame;   
   
   datetime time1=PriceInfo[HighestCandle].time;
   double price1=PriceInfo[HighestCandle].high+10*_Point;
   datetime time2=PriceInfo[LowestCandle].time;
   double price2=PriceInfo[LowestCandle].high+10*_Point;
   
   while(time2<time1){
      
      if(time2>time1)break;
      tempFrame--;
      LowestCandle=GetTheLowestCandle(tempFrame);
      time2=PriceInfo[LowestCandle].time;
      price2=PriceInfo[LowestCandle].high+10*_Point;
      
   }
   
   ObjectDelete(_Symbol,"TrendLine");
   
   ObjectCreate(_Symbol,"TrendLine",OBJ_TREND,0,time1,price1,time2,price2);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_COLOR,clrBlue);
    
   //dali da e punktirana ili solid(toest ne prekysnata)
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_STYLE,STYLE_SOLID);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_WIDTH,2);
    
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(_Symbol,"TrendLine",OBJPROP_RAY_RIGHT,true);
   
   
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

void ChekSAR(){
     MqlRates PriceArr[];
    
     ArraySetAsSeries(PriceArr,true);
     //Kopirame dannite v array-q
     int Data1=CopyRates(Symbol(),Period(),0,10,PriceArr);
     
     double mySARArray[];
     
     int SARDef=iSAR(Symbol(),_Period,0.02,0.2);
     
     ArraySetAsSeries(mySARArray,true);
     
     CopyBuffer(SARDef,0,0,3,mySARArray);
     
     double LastSARValue=NormalizeDouble(mySARArray[0],5);
     CurrentSAR=LastSARValue;
     
     if(signal==""){
        if(LastSARValue<PriceArr[0].low)signalSAR="buy";
        
        if(LastSARValue>PriceArr[0].high)signalSAR="sell";
     }
     else if(signal=="sell"){
        if(LastSARValue<PriceArr[0].low)
        {
            signalSAR="buy";
            LastBuySignal=PriceArr[0].close;
        }
     }
     else if(signalSAR=="buy"){
        if(LastSARValue>PriceArr[0].high)
        {
           signalSAR="sell";
           //LastSellSignal=LastSARValue;
        }
     }
}
void CheckSARBuyTrailingStop(double SARValue){
   
   //proverqqme vsichki pozicii
   for(int i=PositionsTotal()-1;i>=0;i--){
   
      string symbol=PositionGetSymbol(i);
      
      if(_Symbol==symbol){
         
         ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
         
         double CurrentStopLoss=PositionGetDouble(POSITION_SL);
         
         if(SARValue>LastBuyEntry){
            if(CurrentStopLoss<SARValue){
               trade.PositionModify(PositionTicket,SARValue,0);
            }
         }
      } 
   }

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