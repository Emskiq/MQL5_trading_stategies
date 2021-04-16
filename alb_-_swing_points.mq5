//+------------------------------------------------------------------+
//|                                           alb - swing points.mq5 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers   1
#property indicator_plots     1

//
//
//
//
//

#property indicator_label1  "Swing points"
#property indicator_type1   DRAW_LINE
#property indicator_color1  OrangeRed
#property indicator_style1  STYLE_SOLID

//
//
//
//
//

double SwpBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,SwpBuffer,INDICATOR_DATA); ArraySetAsSeries(SwpBuffer,true);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetString(INDICATOR_SHORTNAME,"Swing points");
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{

   //
   //
   //
   //
   //

      int limit = rates_total-prev_calculated;
         if (prev_calculated > 0) limit++;
         if (prev_calculated ==0) limit-=5;
         if (!ArrayGetAsSeries(high)) ArraySetAsSeries(high,true);
         if (!ArrayGetAsSeries(low))  ArraySetAsSeries(low ,true);

   //
   //
   //
   //
   //
           
      for (int i=limit; i>=0; i--)
      {
         SwpBuffer[i] = 0;
            if (low[i+3] <low[i+4]  && low[i+2] <low[i+3]  && high[i+1]>high[i+2] && high[i]>high[i+1]) SwpBuffer[i] = -1;
            if (high[i+3]>high[i+4] && high[i+2]>high[i+3] && low[i+1] <low[i+2]  && low[i] < low[i+1]) SwpBuffer[i] =  1;
   }
   
   //
   //
   //
   //
   //

   return(rates_total);
}
