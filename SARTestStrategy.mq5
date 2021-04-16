#include<Trade\Trade.mqh>
CTrade  trade;

string signal="";
double LastBuyPrice, LastSellPrice;
double LastSellSignal, LastBuySignal;

void OnTick(){

    //za tolko kupuash
    double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   //za tolko Prodaaash
    double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
    
    //funkciq koqta ni dava signali za SAR: buy/sell
    ChekSAR();
    
    
    if(signal=="sell"&&PositionsTotal()<1){
    //kupuame pyrvo che sled kato se smeni posokata na trenda 
      trade.Sell(
                     0.10, // how much
                     NULL, // current symbol
                     Bid,  // buy price
                     0, // Stop Loss
                     Bid-200*_Point, // Take Profit
                     NULL  // Comment
                  );
      LastSellPrice=Bid;
    }
    
    if(signal=="buy"&&(LastSellPrice>(LastBuySignal+20*_Point))&&PositionsTotal()==1){
      CloseAllSellPos();
    }
    
}

void ChekSAR(){
     MqlRates PriceArr[];
    
     ArraySetAsSeries(PriceArr,true);
     //Kopirame dannite v array-q
     int Data=CopyRates(Symbol(),Period(),0,3,PriceArr);
     
     double mySARArray[];
     
     int SARDef=iSAR(Symbol(),_Period,0.02,0.2);
     
     ArraySetAsSeries(mySARArray,true);
     
     CopyBuffer(SARDef,0,0,3,mySARArray);
     
     double LastSARValue=NormalizeDouble(mySARArray[1],5);
     if(signal==""){
        if(LastSARValue<PriceArr[1].low)signal="buy";
        
        if(LastSARValue>PriceArr[1].high)signal="sell";
     }
     else if(signal=="sell"){
        if(LastSARValue<PriceArr[1].low)
        {
            signal="buy";
            LastBuySignal=PriceArr[1].close;
        }
     }
     else if(signal=="buy"){
        if(LastSARValue>PriceArr[1].high)
        {
           signal="sell";
           //LastSellSignal=LastSARValue;
        }
     }
}

void CloseAllBuyPos(){
   
   for(int i=PositionsTotal()-1;i>=0;i--){
      int ticket=PositionGetTicket(i);
      
      //razbirame dali e buy/sell
      int PositionsType=PositionGetInteger(POSITION_TYPE);
      
      if(PositionsType==POSITION_TYPE_BUY){
         trade.PositionClose(ticket);
      }
   }
}

void CloseAllSellPos(){
   
   for(int i=PositionsTotal()-1;i>=0;i--){
      int ticket=PositionGetTicket(i);
      
      //razbirame dali e buy/sell
      int PositionsType=PositionGetInteger(POSITION_TYPE);
      
      if(PositionsType==POSITION_TYPE_SELL){
         trade.PositionClose(ticket);
      }
   }
}