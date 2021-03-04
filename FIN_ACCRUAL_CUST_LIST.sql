CREATE OR REPLACE PACKAGE FIN_ACCRUAL_CUST_LIST AS 


  PROCEDURE FIN_ACCRUAL_CUST_LIST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 
END FIN_ACCRUAL_CUST_LIST;
/


CREATE OR REPLACE PACKAGE BODY                             FIN_ACCRUAL_CUST_LIST AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
   -- select * from tbaadm.chat;
                     -- select * from tbaadm.lafht
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	--vi_currency	   	Varchar2(3);              -- Input to procedure
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(10);		    	    -- Input to procedure
 -- vi_SchemeCode   Varchar2(6);              -- Input to procedure
  Vi_Foracid      Varchar2(20);             -- Input to procedure
  
  V_Trandate    Varchar2(20);
  V_Accnum      Varchar2(20);
  V_Accname     Varchar2(50);
  V_Value_Date_Bal    Number(20,2);
  V_Interest          Number(20,2);
  v_opacid            Varchar2(50);
  
  Cursor Extractdataforresult Is
Select  *  From Custom.CUST_ACCRUAL_ACCOUNT Aa; --ORDER BY Aa."TranDate";
  
 
---------------------------------Function Saving--------------------------------------
 FUNCTION Saving(ci_TranDate VARCHAR2,ci_foracid VARCHAR2)
  RETURN VARCHAR2 AS
   V_Returnvalue Varchar2(50) := ci_TranDate;
  BEGIN 
     Begin
        SELECT
         To_Date( Ci_Trandate,'dd-Mon-yy') As Trandate,
          --GAM.FORACID as "Account_ID" ,
         -- GAM.ACCT_NAME as "Account_Name" , 
           Nvl((Select Tran_Date_Bal From Tbaadm.Eab Eab
           Where Eab.Eod_Date <= To_Date( Ci_Trandate,'dd-Mon-yy')
           And   Eab.End_Eod_Date >= To_Date( ci_TranDate,'dd-Mon-yy')
           And   Acid =Gam.Acid ),0) As Value_Date_Bal,     
          Round((Idt.Interest_Amount/((Idt.End_Date - Idt.Start_Date)+1)),8) As Accuredcr 
         -- '-' As Opacid
          Into 
          v_TranDate ,  v_Value_Date_Bal , v_Interest
           
      FROM
         TBAADM.GAM GAM,
         tbaadm.idt idt
      WHERE
         idt.start_date <= tO_DATE( ci_TranDate,'dd-Mon-yy')
         and idt.end_date >= tO_DATE( ci_TranDate,'dd-Mon-yy')
         And Idt.Entity_Id = Gam.Acid
         and gam.foracid = ci_foracid
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         And ( Idt.Interest_Amount > 0 );
     
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       V_Trandate   := Ci_Trandate;
       V_Accnum := '-';
       V_Accname := '-';
       V_Value_Date_Bal := 0.00;
       V_Interest := 0.00;
       v_opacid := '-';
    End;
  Insert Into Custom.CUST_ACCRUAL_ACCOUNT 
  VALUES (V_Trandate, V_Value_Date_Bal, V_Interest);
  RETURN v_returnValue; 
End Saving;
  
  
  ---------------------------------Function TermDeposit--------------------------------------
 FUNCTION TermDeposit(ci_TranDate VARCHAR2,ci_foracid VARCHAR2)
  RETURN VARCHAR2 AS
   V_Returnvalue Varchar2(50) := ci_TranDate;
  BEGIN 
     Begin
         SELECT
         To_Date( Ci_Trandate,'dd-Mon-yy') As Trandate,
         --Gam.Foracid As "Account_ID" ,
         --GAM.ACCT_NAME as "Account_Name" , 
          NVL((SELECT tRAN_DATE_bAL FROM TBAADM.EAB EAB
           WHERE EAB.EOD_DATE <= tO_DATE( ci_TranDate,'dd-Mon-yy')
           AND   EAB.END_EOD_DATE >= tO_DATE(ci_TranDate,'dd-Mon-yy')
           And   Acid =Gam.Acid ),0) As Aa,  
         Round((Idt.Interest_Amount/((Idt.End_Date - Idt.Start_Date)+1)),8) As Accuredcr-- ,  
       -- '-' as opacid
        Into 
          v_TranDate ,  v_Value_Date_Bal , v_Interest
        
      FROM
         TBAADM.IDT IDT , 
         TBAADM.GAM GAM ,
         tbaadm.tam tam
      WHERE
         IDT.ENTITY_ID = GAM.ACID 
         and tam.acid = gam.acid
         AND idt.START_DATE <= tO_DATE( ci_TranDate,'dd-Mon-yy')
         And Idt.End_Date >= To_Date( ci_TranDate,'dd-Mon-yy')
         and gam.foracid = ci_foracid
         and GAM.DEL_FLG = 'N' 
         --and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         and ( idt.INTEREST_AMOUNT > 0 )
;
     
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       V_Trandate   := Ci_Trandate;
       V_Value_Date_Bal := 0.00;
       V_Interest := 0.00;
    End;
  Insert Into Custom.CUST_ACCRUAL_ACCOUNT 
  VALUES (V_Trandate,V_Value_Date_Bal, V_Interest);
  Return V_Returnvalue; 
End TermDeposit;

---------------------------------Function loan--------------------------------------
 FUNCTION Loan(ci_TranDate VARCHAR2,ci_foracid VARCHAR2)
  RETURN VARCHAR2 AS
   V_Returnvalue Varchar2(50) := ci_TranDate;
  BEGIN 
     Begin
     Select T.aa,
            T.Bb,
            Sum(T.Accuredcr)
                Into 
          v_TranDate ,  v_Value_Date_Bal , v_Interest
     from (
      Select
          tO_DATE( ci_TranDate,'dd-Mon-yy') as aa,
           NVL((SELECT tRAN_DATE_bAL FROM TBAADM.EAB EAB
           WHERE EAB.EOD_DATE <= tO_DATE( ci_TranDate,'dd-Mon-yy')
           And   Eab.End_Eod_Date >= To_Date( Ci_Trandate,'dd-Mon-yy')
           AND   ACID =GAM.ACID ),0) AS bb,   
         Round((Idt.Interest_Amount/((Idt.End_Date - Idt.Start_Date)+1)),8) As Accuredcr 
         --(select op_acid from tbaadm.lam where acid = GAM.ACID ) as opacid
      
      FROM
         TBAADM.EIT EIT , 
         TBAADM.GAM GAM ,
         TBAADM.IDT IDT
      WHERE
         EIT.ENTITY_ID = GAM.ACID 
         AND IDT.ENTITY_ID = GAM.ACID
         AND idt.START_DATE <= tO_DATE( ci_TranDate,'dd-Mon-yy')
         And Idt.End_Date >= To_Date( Ci_Trandate,'dd-Mon-yy')
         and gam.foracid = ci_foracid
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and ( idt.INTEREST_AMOUNT > 0 )
         And Gam.Bank_Id = '01'
         )T
         group by t.aa,t.bb;
     
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       V_Trandate   := Ci_Trandate;
       V_Value_Date_Bal := 0.00;
       V_Interest := 0.00;
    End;
  Insert Into Custom.CUST_ACCRUAL_ACCOUNT 
  VALUES (V_Trandate, V_Value_Date_Bal, V_Interest);
  Return V_Returnvalue; 
End Loan;


  PROCEDURE FIN_ACCRUAL_CUST_LIST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      VO_Accountid   Tbaadm.General_Acct_Mast_Table.Foracid%Type;
      VO_Accountname Tbaadm.General_Acct_Mast_Table.Acct_Name%Type;
      VO_Valuedatebal Tbaadm.Eab.Value_Date_Bal%Type;
      VO_Tranamount  Custom.Custom_Ctd_Dtd_Acli_View.Tran_Amt%Type;
      vO_tranDate    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE%TYPE;
      V_Subtitle    Varchar2(200);
      vO_opacid      TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      vi_Rate       tbaadm.eit.interest_rate%type;
      
      out_put Varchar2(60);
      Countdate Number := 0;
      TEMPCountDate varchar2(20);
      
  BEGIN
    -------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
        -------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
     vi_foracid   :=outArr(0);
    vi_startDate  :=outArr(1);		
    vi_endDate    :=outArr(2);		
   -- vi_SchemeType	:=outArr(3);
    --vi_SchemeCode :=outArr(4);
    --vi_currency   :=outArr(5);
    
    Begin
      SELECT  eit.interest_rate,gam.schm_type,gam.foracid, gam.ACCT_NAME   INTO vi_Rate, vi_SchemeType,Vo_Accountid,Vo_Accountname
      FROM    tbaadm.gam gam, tbaadm.eit eit
      WHERE   gam.acid = eit.entity_id 
      AND     gam.foracid = vi_foracid;
      EXCEPTION
      When No_Data_Found Then
       Vi_Rate   := 0.00;
       Vi_Schemetype := '-';
       Vo_Accountid := '-';
       Vo_Accountname := '-';
    End;

    BEGIN 
      select TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) - TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )+ 1 as aa
      into CountDate
      From Dual;
    END;
    
    Begin
        Select (Select Foracid
                From Tbaadm.Gam Aa
                WHERE AA.ACID = LAM.Op_Acid) Into Vo_Opacid
        From   Tbaadm.Lam Lam,Tbaadm.Gam Gam
        Where   Gam.Acid = Lam.Acid
        AND     GAM.FORACID = vi_foracid;
         EXCEPTION
        When No_Data_Found Then
       Vo_Opacid := '-';
    END;
    
    DELETE FROM CUSTOM.CUST_ACCRUAL_ACCOUNT;
    IF UPPER(vi_SchemeType) = 'SBA' or UPPER(vi_SchemeType)='TDA'  THEN
     --{
     V_Subtitle := 'ACCRUAL PAYABLE FOR ACCOUNT';  
        IF UPPER(vi_SchemeType) = 'SBA' THEN
          FOR CC IN 0 .. CountDate-1
           LOOP 
           --dbms_output.put_line(vi_startDate);
              select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) +CC
              into TEMPCountDate
              From Dual;
             	dbms_output.put_line(TEMPCountDate);
              Begin
               out_put := Saving(TEMPCountDate,vi_foracid);
              End;
             --dbms_output.put_line(TEMPCountDate)
           End Loop;
        Else
          FOR CC IN 0 .. CountDate-1
           LOOP 
           --dbms_output.put_line(vi_startDate);
              select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) +CC
              into TEMPCountDate
              from dual;
             
              Begin
               Out_Put := TermDeposit(Tempcountdate,Vi_Foracid);
              End;
                --dbms_output.put_line(TEMPCountDate)
           End Loop;
        END IF;
     
      -----------FOR Receivable ----------
   ELSE
     v_subTitle := 'ACCRUAL RECEIVABLE FOR ACCOUNT';  
      FOR CC IN 0 .. CountDate-1
           LOOP 
           --dbms_output.put_line(vi_startDate);
              select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) +CC
              into TEMPCountDate
              from dual;
             
              Begin
               Out_Put := Loan(Tempcountdate,Vi_Foracid);
              End;
                --dbms_output.put_line(TEMPCountDate)
       End Loop;
     

    --}  
   END IF;  
  
   IF NOT ExtractDataForResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForResult ;
			--}
			END;

		--}
		END IF;
    IF ExtractDataForResult%ISOPEN Then
   
     -- dobal := dobal + OpeningAmount;
      FETCH	ExtractDataForResult INTO	Vo_Trandate,Vo_Valuedatebal,vO_tranAmount;
     	------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataForResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataForResult;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
  

  
    Out_Rec:=	(
					Vo_Trandate          || '|' ||  
					Vo_Accountid      	  || '|' ||
          Vo_Accountname       || '|' ||
          Vo_Valuedatebal      || '|' ||
					vO_tranAmount	      || '|' ||
					v_subTitle          || '|' ||
          Vi_Rate             || '|' ||
          vO_opacid            || '|' ||
          vi_SchemeType);
  
			dbms_output.put_line(out_rec);
  END FIN_ACCRUAL_CUST_LIST;

END FIN_ACCRUAL_CUST_LIST;
/
