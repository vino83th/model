
   proc sort data=orion.usorders04 out=usorders04;
     by Customer_ID Order_Type;
   run;

   data discount1 discount2 discount3;
      set usorders04;
      by Customer_ID Order_Type;
      if first.Order_Type=1 then TotSales=0;
      TotSales+(Quantity*Total_Retail_Price);
      if last.Order_Type=1 and TotSales >= 100 then 
         do;
            if Order_Type=1 then output discount1;
            else if Order_Type=2 then output discount2;
            else if Order_Type=3 then output discount3;
         end;
      keep Customer_ID Customer_Name TotSales;
      format TotSales dollar11.2;
   run;

   title 'Customers Spending $100 or more in Retail Orders';
   proc print data=discount1 noobs;
   run;
   title;

   title 'Customers Spending $100 or more in Catalog Orders';
   proc print data=discount2 noobs;
   run;
   title;

   title 'Customers Spending $100 or more in Internet Orders';
   proc print data=discount3 noobs;
   run;
   title;







