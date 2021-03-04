CREATE OR REPLACE PACKAGE               FIN_STATEMENT_DEPOSIT_WITHDRAW AS 

   PROCEDURE FIN_STATEMENT_DEPOSIT_WITHDRAW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_STATEMENT_DEPOSIT_WITHDRAW;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                        FIN_STATEMENT_DEPOSIT_WITHDRAW AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  Vi_Beforedate   Varchar2(10);
  
  Vi_Trandate      Varchar2(15);
  Vi_Withdrawusd   Number(20,2);
  Vi_Depositusd    Number(20,2);
  Vi_Totalusd      Number(20,2);
  
  Vi_Withdraweur   Number(20,2);
  Vi_Depositeur    Number(20,2);
  Vi_Totaleur     Number(20,2);
  
  Vi_Withdrawthb   Number(20,2);
  Vi_Depositthb    Number(20,2);
  Vi_Totalthb     Number(20,2);
  
  Vi_Withdrawjpy   Number(20,2);
  Vi_Depositjpy    Number(20,2);
  Vi_Totaljpy     Number(20,2);
  
  Vi_Withdrawinr   Number(20,2);
  Vi_Depositinr    Number(20,2);
  Vi_Totalinr     Number(20,2);
  
  Vi_Withdrawmyr   Number(20,2);
  Vi_Depositmyr    Number(20,2);
  Vi_Totalmyr     Number(20,2);
  
  Vi_Withdrawsgd   Number(20,2);
  Vi_Depositsgd    Number(20,2);
  vi_totalsgd      Number(20,2);
  
        temp_Totalusd Number(20,2); 
        temp_Totaleur  Number(20,2);  
        temp_Totalthb Number(20,2);
        temp_Totaljpy Number(20,2);
        temp_Totalinr Number(20,2);
        temp_Totalmyr Number(20,2);  
        temp_totalsgd Number(20,2);
        
        weekends varchar2(20);
  
  vi_id  Number(20);


CURSOR ExtractData IS
Select * 
From  Custom.Cust_Stat_Dep_With_List
;--order by trandate;


---------------------------------Function for Call---------------------------------------
 FUNCTION GetByDate(ci_TranDate VARCHAR2, ci_id VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_TranDate;
  BEGIN
     BEGIN
     Select s.tran_date,
       Sum(S.Withdrawusd),
       Sum(S.Depositusd),
       Sum(S.Withdraweur),
       Sum(S.Depositeur),
       Sum(S.Withdrawthb),
       Sum(S.Depositthb),
       Sum(S.Withdrawjpy),
       Sum(S.Depositjpy),
       Sum(S.Withdrawinr),
       Sum(S.Depositinr),
       Sum(S.Withdrawmyr),
       Sum(S.Depositmyr),
        Sum(S.WithdrawSGD),
       Sum(S.Depositsgd),
        Sum(S.Depositusd)- Sum(S.Withdrawusd) As Totalusd,
         Sum(S.Depositeur)-Sum(S.Withdraweur) As Totaleur,
         Sum(S.Depositthb)-Sum(S.Withdrawthb) As Totalthb,
         Sum(S.Depositjpy)-Sum(S.Withdrawjpy) As Totaljpy,
         Sum(S.Depositinr)-Sum(S.Withdrawinr) As Totalinr,
         Sum(S.Depositmyr)-Sum(S.Withdrawmyr) As Totalmyr,
         Sum(S.Depositsgd)-Sum(S.WithdrawSGD) as totalsgd
       Into 
         Vi_Trandate, Vi_Withdrawusd, Vi_Depositusd,Vi_Withdraweur,Vi_Depositeur,Vi_Withdrawthb,Vi_Depositthb,
        Vi_Withdrawjpy, Vi_Depositjpy, Vi_Withdrawinr, Vi_Depositinr, Vi_Withdrawmyr, Vi_Depositmyr, Vi_Withdrawsgd, Vi_Depositsgd
      , vi_totalUSD ,Vi_Totaleur ,Vi_Totalthb, Vi_Totaljpy ,Vi_Totalinr,Vi_Totalmyr  ,vi_totalsgd 
from (
  Select T.Tran_Date,
          Case When T.Cur = 'USD' Then T.Dr_Amt Else 0 End As Withdrawusd,
         Case When T.Cur = 'USD' Then T.Cr_Amt Else 0 End As Depositusd,
         Case When T.Cur = 'EUR' Then T.Dr_Amt Else 0 End As Withdraweur,
         Case When T.Cur = 'EUR' Then T.Cr_Amt Else 0 End As Depositeur,
         Case When T.Cur = 'THB' Then T.Dr_Amt Else 0 End As Withdrawthb,
         Case When T.Cur = 'THB' Then T.Cr_Amt Else 0 End As Depositthb,
         Case When T.Cur = 'JPY' Then T.Dr_Amt Else 0 End As Withdrawjpy,
         Case When T.Cur = 'JPY' Then T.Cr_Amt Else 0 End As Depositjpy,
         Case When T.Cur = 'INR' Then T.Dr_Amt Else 0 End As Withdrawinr,
         Case When T.Cur = 'INR' Then T.Cr_Amt Else 0 End As Depositinr,
         Case When T.Cur = 'MYR' Then T.Dr_Amt Else 0 End As Withdrawmyr,
         Case When T.Cur = 'MYR' Then T.Cr_Amt Else 0 End As Depositmyr,
         Case When T.Cur = 'SGD' Then T.Dr_Amt Else 0 End As Withdrawsgd,
         Case When t.Cur = 'SGD' Then t.Cr_Amt Else 0 End As DepositSGD
  from (
    select ci_TranDate as tran_date,
            sum(gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) as DR_amt,
            sum(gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) as CR_amt,coa.cur
            from tbaadm.gstt,custom.coa_mp coa
            where coa.gl_sub_head_code = gstt.gl_sub_head_code
            And Coa.Cur = Gstt.Crncy_Code 
            And Coa.Group_Code In ('L11','L21')
            and gstt.sol_id like   '%' || '20300' || '%'
            And Gstt.Del_Flg = 'N' 
            And Gstt.Bank_Id = '01'
            And Gstt.Bal_Date = To_Date( Ci_Trandate, 'dd-Mon-yy'  )
            --And Gstt.end_Bal_Date >= To_Date( ci_TranDate, 'dd-Mon-yy'  )
            Group By Coa.Group_Code,Coa.Description,Coa.Cur
      )T
    )S
    Group By S.Tran_Date;
  EXCEPTION
      When No_Data_Found Then
       Vi_Trandate    := ci_TranDate;
       Vi_Withdrawusd := 0.0; 
       Vi_Depositusd  := 0.0;
       Vi_Withdraweur := 0.0;
       Vi_Depositeur  := 0.0;
       Vi_Withdrawthb := 0.0;
       Vi_Depositthb  := 0.0;
       Vi_Withdrawjpy := 0.0; 
       Vi_Depositjpy  := 0.0;
        Vi_Withdrawinr:= 0.0; 
        Vi_Depositinr := 0.0; 
        Vi_Withdrawmyr:= 0.0; 
        Vi_Depositmyr := 0.0; 
        Vi_Withdrawsgd:= 0.0;
        Vi_Depositsgd := 0.0;
         Vi_Totalusd := 0.0;  
        Vi_Totaleur  := 0.0;  
        Vi_Totalthb := 0.0; 
        Vi_Totaljpy := 0.0;
        Vi_Totalinr := 0.0; 
        Vi_Totalmyr := 0.0;  
        vi_totalsgd := 0.0;
    End;
   if ci_id >0 then
     Begin
     --dbms_output.put_line(ci_id);
       Select    Totalusd,Totaleur,Totalthb,Totaljpy,Totalinr,Totalmyr,Totalsgd
       into   temp_totalUSD ,temp_Totaleur ,temp_Totalthb, temp_Totaljpy ,temp_Totalinr,temp_Totalmyr  ,temp_totalsgd 
       From    Custom.Cust_Stat_Dep_With_List 
       Where  Id = Ci_Id-1;
      EXCEPTION
      When No_Data_Found Then
        temp_totalUSD := 0.00;
        temp_Totaleur := 0.00;
        temp_Totalthb := 0.00;
        temp_Totaljpy := 0.00;
        temp_Totalinr := 0.00;
        temp_Totalmyr := 0.00;
        temp_totalsgd := 0.00;
     End;
    Else 
        temp_totalUSD := 0.00;
        temp_Totaleur := 0.00;
        temp_Totalthb := 0.00;
        temp_Totaljpy := 0.00;
        temp_Totalinr := 0.00;
        Temp_Totalmyr := 0.00;
        Temp_Totalsgd := 0.00;
  End If;
  
        Vi_Totalusd   := Temp_Totalusd + Vi_Depositusd - Vi_Withdrawusd;
        Vi_Totaleur   := Temp_Totaleur + Vi_Depositeur - Vi_Withdraweur;
        Vi_Totalthb   := Temp_Totalthb + Vi_Depositthb - Vi_Withdrawthb;
        Vi_Totaljpy   := Temp_Totaljpy + Vi_Depositjpy - Vi_Withdrawjpy;
        Vi_Totalinr   := Temp_Totalinr + Vi_Depositinr - Vi_Withdrawinr;
        Vi_Totalmyr   := Temp_Totalmyr + Vi_Depositmyr - Vi_Withdrawmyr;
        Vi_Totalsgd   := Temp_Totalsgd + Vi_Depositsgd - Vi_Withdrawsgd;
        dbms_output.put_line(vi_id);
  Insert Into Custom.Cust_Stat_Dep_With_List 
  Values (Vi_Trandate,  Vi_Withdrawusd ,
        Vi_Depositusd, 
        Vi_Withdraweur ,
        Vi_Depositeur ,
        Vi_Withdrawthb ,
        Vi_Depositthb  ,
        Vi_Withdrawjpy , 
        Vi_Depositjpy  ,
        Vi_Withdrawinr ,
        Vi_Depositinr ,
        Vi_Withdrawmyr ,
        Vi_Depositmyr ,
        Vi_Withdrawsgd,
        Vi_Depositsgd ,Ci_Id,
        Vi_Totalusd ,  
        Vi_Totaleur ,   
        Vi_Totalthb , 
        Vi_Totaljpy ,
        Vi_Totalinr ,  
        Vi_Totalmyr ,  
        vi_totalsgd );
  Return V_Returnvalue; 
END GetByDate;
    
--------------------------------------------------------------------------------
---------------------------------Function for Call---------------------------------------
 FUNCTION GetTrailData(ci_TranDate VARCHAR2, ci_id VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_TranDate;
  BEGIN
     BEGIN
     Select s.tran_date,
        0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
       0.00,
        Sum(S.Depositusd)- Sum(S.Withdrawusd) As Totalusd,
         Sum(S.Depositeur)-Sum(S.Withdraweur) As Totaleur,
         Sum(S.Depositthb)-Sum(S.Withdrawthb) As Totalthb,
         Sum(S.Depositjpy)-Sum(S.Withdrawjpy) As Totaljpy,
         Sum(S.Depositinr)-Sum(S.Withdrawinr) As Totalinr,
         Sum(S.Depositmyr)-Sum(S.Withdrawmyr) As Totalmyr,
         Sum(S.Depositsgd)-Sum(S.WithdrawSGD) as totalsgd
       Into 
         Vi_Trandate, Vi_Withdrawusd, Vi_Depositusd,Vi_Withdraweur,Vi_Depositeur,Vi_Withdrawthb,Vi_Depositthb,
        Vi_Withdrawjpy, Vi_Depositjpy, Vi_Withdrawinr, Vi_Depositinr, Vi_Withdrawmyr, Vi_Depositmyr, Vi_Withdrawsgd, Vi_Depositsgd
      , vi_totalUSD ,Vi_Totaleur ,Vi_Totalthb, Vi_Totaljpy ,Vi_Totalinr,Vi_Totalmyr  ,vi_totalsgd 
from (
  Select T.Tran_Date,
          Case When T.Cur = 'USD' Then T.Dr_Amt Else 0 End As Withdrawusd,
         Case When T.Cur = 'USD' Then T.Cr_Amt Else 0 End As Depositusd,
         Case When T.Cur = 'EUR' Then T.Dr_Amt Else 0 End As Withdraweur,
         Case When T.Cur = 'EUR' Then T.Cr_Amt Else 0 End As Depositeur,
         Case When T.Cur = 'THB' Then T.Dr_Amt Else 0 End As Withdrawthb,
         Case When T.Cur = 'THB' Then T.Cr_Amt Else 0 End As Depositthb,
         Case When T.Cur = 'JPY' Then T.Dr_Amt Else 0 End As Withdrawjpy,
         Case When T.Cur = 'JPY' Then T.Cr_Amt Else 0 End As Depositjpy,
         Case When T.Cur = 'INR' Then T.Dr_Amt Else 0 End As Withdrawinr,
         Case When T.Cur = 'INR' Then T.Cr_Amt Else 0 End As Depositinr,
         Case When T.Cur = 'MYR' Then T.Dr_Amt Else 0 End As Withdrawmyr,
         Case When T.Cur = 'MYR' Then T.Cr_Amt Else 0 End As Depositmyr,
         Case When T.Cur = 'SGD' Then T.Dr_Amt Else 0 End As Withdrawsgd,
         Case When t.Cur = 'SGD' Then t.Cr_Amt Else 0 End As DepositSGD
  from (
    select ci_TranDate as tran_date,
            Gstt.Tot_Dr_Bal as DR_amt,
            Gstt.Tot_Cr_Bal as CR_amt,coa.cur
            from tbaadm.gstt,custom.coa_mp coa
            where coa.gl_sub_head_code = gstt.gl_sub_head_code
            And Coa.Cur = Gstt.Crncy_Code 
            And Coa.Group_Code In ('L11','L21')
            and gstt.sol_id like   '%' || '20300' || '%'
            And Gstt.Del_Flg = 'N' 
            And Gstt.Bank_Id = '01'
            And Gstt.Bal_Date <= To_Date( Ci_Trandate, 'dd-Mon-yy'  )
            And Gstt.End_Bal_Date >= To_Date( Ci_Trandate, 'dd-Mon-yy'  )
           -- Group By Coa.Group_Code,Coa.Description,Coa.Cur
      )T
    )S
    Group By S.Tran_Date;
  EXCEPTION
      When No_Data_Found Then
       Vi_Trandate    := ci_TranDate;
       Vi_Withdrawusd := 0.0; 
       Vi_Depositusd  := 0.0;
       Vi_Withdraweur := 0.0;
       Vi_Depositeur  := 0.0;
       Vi_Withdrawthb := 0.0;
       Vi_Depositthb  := 0.0;
       Vi_Withdrawjpy := 0.0; 
       Vi_Depositjpy  := 0.0;
        Vi_Withdrawinr:= 0.0; 
        Vi_Depositinr := 0.0; 
        Vi_Withdrawmyr:= 0.0; 
        Vi_Depositmyr := 0.0; 
        Vi_Withdrawsgd:= 0.0;
        Vi_Depositsgd := 0.0;
         Vi_Totalusd := 0.0;  
        Vi_Totaleur  := 0.0;  
        Vi_Totalthb := 0.0; 
        Vi_Totaljpy := 0.0;
        Vi_Totalinr := 0.0; 
        Vi_Totalmyr := 0.0;  
        vi_totalsgd := 0.0;
    End;
  
        temp_totalUSD := 0.00;
        temp_Totaleur := 0.00;
        temp_Totalthb := 0.00;
        temp_Totaljpy := 0.00;
        temp_Totalinr := 0.00;
        Temp_Totalmyr := 0.00;
        Temp_Totalsgd := 0.00;
        
        dbms_output.put_line(vi_id);
        
  Insert Into Custom.Cust_Stat_Dep_With_List 
  Values (Vi_Trandate,  Vi_Withdrawusd ,
        Vi_Depositusd, 
        Vi_Withdraweur ,
        Vi_Depositeur ,
        Vi_Withdrawthb ,
        Vi_Depositthb  ,
        Vi_Withdrawjpy , 
        Vi_Depositjpy  ,
        Vi_Withdrawinr ,
        Vi_Depositinr ,
        Vi_Withdrawmyr ,
        Vi_Depositmyr ,
        Vi_Withdrawsgd,
        Vi_Depositsgd ,Ci_Id,
        Vi_Totalusd ,  
        Vi_Totaleur ,   
        Vi_Totalthb , 
        Vi_Totaljpy ,
        Vi_Totalinr ,  
        Vi_Totalmyr ,  
        vi_totalsgd );
  Return V_Returnvalue; 
END GetTrailData;

  
  PROCEDURE FIN_STATEMENT_DEPOSIT_WITHDRAW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
       --USD , EUR,THB,JPY,INR,MYR,SGD
       v_OpenCloseDate  CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.Tran_date%type;
       v_DepositUSD     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlUSD  CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositEUR     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlEUR   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositTHB     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlTHB   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositJPY     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlJPY   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositINR     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlINR   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositMYR     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_WithdrawlMYR   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_DepositSGD     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       V_Withdrawlsgd   Custom.Custom_Ctd_Dtd_Acli_View.Tran_Amt%Type;
       
       V_Totalusd    Number(20,2);
       V_Totaleur    Number(20,2);
       V_Totalthb    Number(20,2);
       V_Totaljpy    Number(20,2);
       V_Totalinr    Number(20,2);
       V_Totalmyr    Number(20,2);
       v_totalsgd    Number(20,2);
       
       v_id     Number(20);
       V_Branchname Tbaadm.Branch_Code_Table.Br_Name%Type;
       Test_Date     Number;
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
 
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);			

    
    -----------------------------------------------------------------------------------------------
    
    if( vi_startDate is null or vi_endDate is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||'-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  End If;
   Vi_Id := 0;
   BEGIN 
      select TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) - TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )+ 1 as aa
      into CountDate
      from dual;
    END;
    
    DELETE FROM CUSTOM.Cust_Stat_Dep_With_List;
  
    ------------------------Function call FOR get daily amount--------------------------
 
   FOR CC IN 0 .. CountDate   --30-1
   LOOP 
   --dbms_output.put_line(vi_startDate);
      select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1 +CC
      into TEMPCountDate
      From Dual;
      
      --  Vi_Id  := Cc ;
        
        Select To_Char(To_Date( Tempcountdate, 'dd-Mon-yy'  )-1, 'd')  Into Weekends
        From Dual; 
      If Vi_Id = 0 Then
          Out_Put := Gettraildata(Tempcountdate,Vi_Id);
          Vi_Id :=  vi_id +1;
      Else
           Begin
          If Weekends = 6 Or Weekends = 7 Then
            Dbms_Output.Put_Line(Weekends);
          Else
           Out_Put := Getbydate(Tempcountdate,Vi_Id);
           Vi_Id :=  vi_id +1;
          End If;
      END;
      end if;
      
     
      --dbms_output.put_line(TEMPCountDate);
  End Loop;
  
    
--------------------------------------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData;	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			Fetch	Extractdata
			Into	V_Openclosedate ,  
              V_Withdrawlusd ,
               v_DepositUSD ,
              V_Withdrawleur , 
               v_DepositEUR , 
              V_Withdrawlthb , 
               v_DepositTHB ,
              V_Withdrawljpy ,
               v_DepositJPY ,
              V_Withdrawlinr, 
               v_DepositINR,
              V_Withdrawlmyr, 
               V_Depositmyr, 
              V_Withdrawlsgd, 
              V_Depositsgd ,
              V_Id,
               V_Totalusd ,  
               V_Totaleur ,   
               V_Totalthb , 
               V_Totaljpy ,
               V_Totalinr ,  
               V_Totalmyr ,  
               v_totalsgd   ;


			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
          
       
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
  BEGIN
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      Where
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;  
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
              v_OpenCloseDate    || '|' ||
              v_DepositUSD       || '|' ||
              v_WithdrawlUSD     || '|' ||
              v_DepositEUR       || '|' ||
              v_WithdrawlEUR     || '|' ||
              v_DepositTHB       || '|' ||
              v_WithdrawlTHB     || '|' ||
              v_DepositJPY       || '|' ||
              v_WithdrawlJPY     || '|' ||
              v_DepositINR       || '|' ||
              v_WithdrawlINR     || '|' ||
              v_DepositMYR       || '|' ||
              v_WithdrawlMYR     || '|' ||
              v_DepositSGD       || '|' ||
              V_Withdrawlsgd     || '|' ||
              V_Branchname       || '|' ||
               V_Totalusd        || '|' || 
               V_Totaleur        || '|' ||
               V_Totalthb        || '|' ||
               V_Totaljpy        || '|' ||
               V_Totalinr         || '|' ||
               V_Totalmyr        || '|' ||
               v_totalsgd 
            );
  
			dbms_output.put_line(out_rec);
  END FIN_STATEMENT_DEPOSIT_WITHDRAW;

END FIN_STATEMENT_DEPOSIT_WITHDRAW;
/
