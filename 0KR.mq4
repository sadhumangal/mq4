//+------------------------------------------------------------------+
//|                                        Candle Reverse Indicator  |
//|              Show candle reverse signal of 4H on all period chart|
//+------------------------------------------------------------------+
#property copyright "michael"
#property link      "michaelitg@outlook.com"

#property indicator_chart_window
//---- indicator parameters
//extern int TrendRange = 6;
extern int Cal = 300;       //how many candles to calculate
extern int timeframeNN = 60; //PERIOD_4H;
//--- indicator parameters
extern int InpFastEMA=12;   // Fast EMA Period
extern int InpSlowEMA=26;   // Slow EMA Period
extern int InpSignalSMA=9;  // Signal SMA Period
extern int TrendEMAN = 5;   //EMA for trend limit
//--- indicator buffers
double    ExtMacdBuffer[1000];
double    ExtSignalBuffer[1000];

int space = 20;    //space to draw icon on candle 
int ExtDepth=12;
int ExtDeviation=5;
int ExtBackstep=3;
//---- indicator buffers
double BufferZig[];
double zigpoint[4];
datetime zigtime[4];
datetime alerttime = 0;
datetime alerttime2 = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if( Period() < 60) Cal = 500;
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, BufferZig);
   if( Period() == 5){ InpFastEMA *=5; InpSlowEMA *= 5; InpSignalSMA *= 5;}
   
   return(0);
  }
  
int deinit()
{
   for( int i = 0; i <= Cal; i++)
   {
      ObjectDelete(0, "ArrowKR"+i);
      ObjectDelete(0, "LineKR"+i);
      ObjectDelete(0, "KRTrend"+i);
      ObjectDelete(0, "MACDKR"+i);
   }

   return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
deinit();

if( Period() > 240) return(0);
int i, t = 0;
double s = space * Point;
BufferZig[Cal] = 0;
int lastsignal = -1;
int timeframe = Period();
if( timeframeNN > 0 && Period() < 240) timeframe = timeframeNN;

for( i = Cal-1; i >= 0; i--) 
{
BufferZig[i] = BufferZig[i+1];
//locate ii_prev to the nearest trend bar
int ii = iBarShift(Symbol(), timeframe, Time[i]);
int ii_prev = ii + 1;
do{
   if( BufferZig[i] > 0 && iOpen(Symbol(), timeframe, ii_prev) < iClose(Symbol(), timeframe, ii_prev) ) break;
   if( BufferZig[i] < 0 && iOpen(Symbol(), timeframe, ii_prev) > iClose(Symbol(), timeframe, ii_prev) ) break;
   ii_prev = ii_prev+1;
}while(ii_prev < Cal);
{
   {
      if( ( iOpen(Symbol(), timeframe, ii+1) > iClose(Symbol(), timeframe, ii+1) && iOpen(Symbol(), timeframe, ii) <= iClose(Symbol(), timeframe, ii+1)+1 && iClose(Symbol(), timeframe, ii) > iOpen(Symbol(), timeframe, ii+1) ) 
          || (BufferZig[i+1] < 0 && iClose(Symbol(), timeframe, ii) > iOpen(Symbol(), timeframe, ii_prev)) ) //MathAbs(BufferZig[i+1]) )  )
      {
         t++;
         BufferZig[i] = iOpen(Symbol(), timeframe, ii);
         //if( StringFind(TimeToStr(Time[i]), "2014.04.01 02") != -1 && i == 0) Print("Find i=",i,"t0-t1=",TimeToStr(zigtime[1]),"-",TimeToStr(zigtime[0]),"p0-p1",zigpoint[1],"-",zigpoint[0],"K1=",Open[i+1],"-",Close[i+1],"K0=",Open[0],"-",Close[0],"BufferZig=",BufferZig[i],"tr=",tr,"h-l=",high1-low1,"@",TimeToStr(Time[i]));
         //break;
      }
   }
   //else
   {
      if( (iOpen(Symbol(), timeframe, ii+1) < iClose(Symbol(), timeframe, ii+1) && iOpen(Symbol(), timeframe, ii) >= iClose(Symbol(), timeframe, ii+1)-1 && iClose(Symbol(), timeframe, ii) < iOpen(Symbol(), timeframe, ii+1) )
         || ( iClose(Symbol(), timeframe, ii) < iOpen(Symbol(), timeframe, ii_prev)) ) //BufferZig[i+1] ) )
      {  t++;
         BufferZig[i] = -iOpen(Symbol(), timeframe, ii);
         //if( StringFind(TimeToStr(Time[i]), "2014.04.01 02") != -1 && i == 0) Print("Find i=",i,"t0-t1=",TimeToStr(zigtime[1]),"-",TimeToStr(zigtime[0]),"p0-p1",zigpoint[1],"-",zigpoint[0],"K1=",Open[i+1],"-",Close[i+1],"K0=",Open[0],"-",Close[0],"BufferZig=",BufferZig[i],"tr=",tr,"h-l=",high1-low1,"@",TimeToStr(Time[i]));
         //break;
      }
   }
   //if( StringFind(TimeToStr(Time[i]), "2016.09.22") != -1 && Symbol() == "US30" ) Print("i=",i,"buffer[i]=",BufferZig[i],"buffer[i+1]=",BufferZig[i+1],"i+1=",Open[i+1],"-",Close[i+1],"Ki=",Open[0],"-",Close[0],"@",TimeToStr(Time[i]));
   if( BufferZig[i] > 0)
   {
         if( BufferZig[i+1] < 0)
         {
         lastsignal = i;
         ObjectCreate("ArrowKR"+i, OBJ_ARROW, 0, Time[i], Low[i]); //OBJ_ARROW_UP
         ObjectSet("ArrowKR"+i,OBJPROP_ARROWCODE,108);
         ObjectSet("ArrowKR"+i, OBJPROP_COLOR, Lime);
         ObjectSet("ArrowKR"+i, OBJPROP_WIDTH, 3);
         if( i == 0 && TimeCurrent() - alerttime > Period()*60/2 ){
            SendNotification("0KR - Bullish reverse on "+Symbol()+" TF:"+Period()+"Bid="+Bid);
            alerttime = TimeCurrent();
         }
         }
   }
   else
   {
         if( BufferZig[i+1] > 0){
         lastsignal = -i;
         ObjectCreate("ArrowKR"+i, OBJ_ARROW, 0, Time[i], High[i]+2*s);//OBJ_ARROW_DOWN
         ObjectSet("ArrowKR"+i,OBJPROP_ARROWCODE,108);
         ObjectSet("ArrowKR"+i, OBJPROP_COLOR, Red);
         ObjectSet("ArrowKR"+i, OBJPROP_WIDTH, 3);
         if( i == 0 && TimeCurrent() - alerttime > Period()*60/2 ){
            SendNotification("0KR - Bearish reverse on "+Symbol()+" TF:"+Period()+"Bid="+Bid);
            alerttime = TimeCurrent();
         }
         }
   }
}
}
if( Period() > 15 && Period() <= 60) createTrendLine(lastsignal);

//==================MACD
//--- macd counted in the 1-st buffer
   for(i=0; i<Cal; i++)
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(Cal,0,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
   int cause;
   string causestring[3] = {"顶底形态","穿过零轴","穿过信号线"};
   for( i = 1; i < Cal-1; i++)
   {
   cause = 0;
   if( (ExtMacdBuffer[i] > TrendEMAN && ExtMacdBuffer[i+1] < ExtMacdBuffer[i] && ExtMacdBuffer[i-1] < ExtMacdBuffer[i]) ||
       (ExtMacdBuffer[i-1] < 0 && ExtMacdBuffer[i] < 0 && ExtMacdBuffer[i+1] > 0) ||
       (ExtMacdBuffer[i] > TrendEMAN && ExtMacdBuffer[i-1] < ExtSignalBuffer[i+7] && ExtMacdBuffer[i] < ExtSignalBuffer[i+8] && ExtMacdBuffer[i+1] > ExtSignalBuffer[i+9]))
   {
         ObjectCreate("MACDKR"+i, OBJ_ARROW, 0, Time[i], High[i]+2*s);//OBJ_ARROW_DOWN
         ObjectSet("MACDKR"+i,OBJPROP_ARROWCODE,242);
         ObjectSet("MACDKR"+i, OBJPROP_COLOR, Red);
         ObjectSet("MACDKR"+i, OBJPROP_WIDTH, 3);
         if(ExtMacdBuffer[i-1] < 0 && ExtMacdBuffer[i] < 0 && ExtMacdBuffer[i+1] > 0) cause = 1;
         else if(ExtMacdBuffer[i-1] < ExtSignalBuffer[i+7] && ExtMacdBuffer[i] < ExtSignalBuffer[i+8] && ExtMacdBuffer[i+1] > ExtSignalBuffer[i+9]) cause = 2;
         ObjectSetString(0, "MACDKR"+i, OBJPROP_TEXT, causestring[cause]);
         if( i == 1 && TimeCurrent() - alerttime2 > Period()*60/2 ){
            SendNotification("0KR - Bearish MACD reverse on "+Symbol()+" TF:"+Period()+causestring[cause]+"Bid="+Bid);
            alerttime2 = TimeCurrent();
         }
   }
   if( (ExtMacdBuffer[i] < -TrendEMAN && ExtMacdBuffer[i+1] > ExtMacdBuffer[i] && ExtMacdBuffer[i-1] > ExtMacdBuffer[i]) ||
       (ExtMacdBuffer[i-1] > 0 && ExtMacdBuffer[i] > 0 && ExtMacdBuffer[i+1] < 0) ||
       (ExtMacdBuffer[i] < -TrendEMAN && ExtMacdBuffer[i-1] > ExtSignalBuffer[i+7] && ExtMacdBuffer[i] > ExtSignalBuffer[i+8] && ExtMacdBuffer[i+1] < ExtSignalBuffer[i+9]))
   {
         ObjectCreate("MACDKR"+i, OBJ_ARROW, 0, Time[i], Low[i]); //OBJ_ARROW_UP
         ObjectSet("MACDKR"+i,OBJPROP_ARROWCODE,241);
         ObjectSet("MACDKR"+i, OBJPROP_COLOR, Blue);
         ObjectSet("MACDKR"+i, OBJPROP_WIDTH, 3);
         if(ExtMacdBuffer[i-1] > 0 && ExtMacdBuffer[i] > 0 && ExtMacdBuffer[i+1] < 0) cause = 1;
         else if(ExtMacdBuffer[i-1] > ExtSignalBuffer[i+7] && ExtMacdBuffer[i] > ExtSignalBuffer[i+8] && ExtMacdBuffer[i+1] < ExtSignalBuffer[i+9]) cause = 2;
         ObjectSetString(0, "MACDKR"+i, OBJPROP_TEXT, causestring[cause]);
         if( i == 1 && TimeCurrent() - alerttime2 > Period()*60/2 ){
            SendNotification("0KR - Bullish MACD reverse on "+Symbol()+" TF:"+Period()+causestring[cause]+"Bid="+Bid);
            alerttime2 = TimeCurrent();
         }
   }
   }
   //Comment("0KR signal",ExtMacdBuffer[0],"sig=",ExtSignalBuffer[8],"-",ExtMacdBuffer[1],"sig=",ExtSignalBuffer[9],"+",ExtMacdBuffer[2],"sig=",ExtSignalBuffer[10]);
/*
   int space= 10;
   if( Bid >=5000) space = 20;
   if( Bid > 10000) space = 40;
   int hline = MathCeil(Bid / 10) * 10;
   for( i = 0; i < 5; i++)
   {
   ObjectCreate("KRTrend"+(i*2+2),OBJ_HLINE,0,Time[0], hline - i*space);
   ObjectSet("KRTrend"+(i*2+2), OBJPROP_COLOR, Blue);
   ObjectSet("KRTrend"+(i*2+2), OBJPROP_WIDTH, 1);
   if( i > 0)
   {
      ObjectCreate("KRTrend"+(i*2+3),OBJ_HLINE,0,Time[0], hline + i*space);
      ObjectSet("KRTrend"+(i*2+3), OBJPROP_COLOR, Red);
      ObjectSet("KRTrend"+(i*2+3), OBJPROP_WIDTH, 1);
   }
   }
*/
/*
   string aaa = TimeToStr(Time[0]);
   if( BufferZig[0] == 1 && StringFind(aaa, "2014.05.19 21") != -1 )
      Print("---------zigzag Singal: BufferZig[0]=",BufferZig[0],"Close[0]=",Close[0],"high1=",high1,"high2=",high2);
*/
//Comment("0KR get total ",t," signals.");
return 0;
}

//+------------------------------------------------------------------+
//| Simple moving average on price array                             |
//+------------------------------------------------------------------+
int SimpleMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,
                     const int period,const double& price[],double& buffer[])
  {
   int i,limit;
//--- check for data
   if(period<=1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);
   if(as_series_price)  ArraySetAsSeries(price,false);
   if(as_series_buffer) ArraySetAsSeries(buffer,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0) // first calculation
     {
      limit=period+begin;
      //--- set empty value for first bars
      for(i=0;i<limit-1;i++) buffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=period;
      buffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total;i++)
      buffer[i]=buffer[i-1]+(price[i]-price[i-period])/period;
//--- restore as_series flags
   if(as_series_price)  ArraySetAsSeries(price,true);
   if(as_series_buffer) ArraySetAsSeries(buffer,true);
//---
    return(rates_total);
  }
  
void createTrendLine(int s)
{
int point1,point2,k;
if(s > 0)
{
   point1 = s;
   while(Low[point1+1] < Low[point1] || Low[point1+2] < Low[point1+1])
   {
      point1++;
   }
   point2 = 0;
   //Algorithm1: 
   //for( int k = 0; k < s; k++)
      //if( Low[k] < Low[point2]) point2 = k;
   //ObjectCreate("KRTrend",OBJ_TREND,0,Time[point1],Low[point1],Time[point2],Low[point2]);   
   //Algorithm2:
   //double mean = 0;
   //for( k = 0; k < s; k++)
   //   mean += Low[k];
   //mean = mean / s;
   //Algorithm3
   int t = s/2;
   while( Low[t-1] < Low[t]) t--;
   while( Low[t+1] < Low[t]) t++;
   //if( Symbol() == "GER30") Print("t=",t,Time[t],Low[t],Time[t-1],Low[t-1]);
   ObjectCreate("KRTrend",OBJ_TREND,0,Time[point1],Low[point1],Time[t],Low[t]); //mean);
   k = Lime;
}
else
{
   s= -s;
   point1 = s;
   while(High[point1+1] > High[point1]) point1++;
   point2 = 0;
   t = s/2;
   while( High[t-1] > High[t]) t--;
   while( High[t+1] > High[t]) t++;
   point2 = t;
   ObjectCreate("KRTrend1",OBJ_TREND,0,Time[point1],High[point1],Time[point2],High[point2]);
   k = Red;
}
   ObjectSet("KRTrend1", OBJPROP_COLOR, k);
   ObjectSet("KRTrend1", OBJPROP_WIDTH, 3);
   


}