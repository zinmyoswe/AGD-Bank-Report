CREATE OR REPLACE PACKAGE        FIN_FCY_BUY_SELL_FP AS 

  PROCEDURE FIN_FCY_BUY_SELL_FP(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_FCY_BUY_SELL_FP;
/


CREATE OR REPLACE PACKAGE BODY                      FIN_FCY_BUY_SELL_FP AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchId        varchar2(5);
  limitsize         INTEGER := 200;
  CIHDate         VARCHAR2(20);
  CIHCALCULATE    NUMBER(20,2);
  CIHGL           VARCHAR2(50);
  
--------------------------------------------------------------------------------  
  CURSOR ExtractDataBuyAllBranch(ci_startDate varchar2, ci_endDate varchar2) IS 
  SELECT 
    sum(CDCM.ref_amt) as BUYING_AMT, CDCM.tran_date as bal_date,
    CDCM.ref_crncy_code AS CURRENCY
  FROM 
    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
    and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
  And Cdcm.Bank_Id = '01'
  And  Trim(CDCM.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =CDCM.tran_date  )
  --AND GAM.SOL_ID = ci_branchId
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by CDCM.tran_date,
  CDCM.ref_crncy_code;
-------------------------------------------------------------------------------- 
  CURSOR ExtractDataSellAllBranch(ci_startDate varchar2, ci_endDate varchar2) IS
  SELECT 
  sum(CDCM.ref_amt) as SELLING_AMT, CDCM.tran_date as bal_date,
  CDCM.ref_crncy_code AS CURRENCY
  FROM 
    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
  AND CDCM.BANK_ID = '01'
  And  Trim(Cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =CDCM.tran_date  )
  --AND GAM.SOL_ID = ci_branchId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by CDCM.tran_date,
  CDCM.ref_crncy_code;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  CURSOR ExtractAllDataFromAcc(ci_startDate varchar2, ci_endDate varchar2) IS
  select
    gstt.bal_date, 
    case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
    then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
    else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total,  
    gstt.CRNCY_CODE AS CURRENCY, gstt.GL_SUB_HEAD_CODE AS GL_SUB_HEAD_CODE
    from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE RPT
    where tbaadm.gstt.bal_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and tbaadm.gstt.bal_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and gstt.GL_SUB_HEAD_CODE = RPT.VARIABLE_VALUE
    and RPT.VARIABLE_NAME in ('SUSPENSE_AC_20011', 'CASH_MMK_PAA_10101', 'CASH_IN_HAND_10103')
    AND RPT.BANK_ID = '01'
    AND RPT.MODULE_NAME = 'REPORT'
    AND RPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    GROUP BY gstt.CRNCY_CODE, gstt.bal_date,gstt.GL_SUB_HEAD_CODE
    order by gstt.bal_date;

  CURSOR ExtractData IS
  SELECT cashInHandVault.bal_date,
         NVL( cashInHandVault.amt,0) AS CASH_IN_HAND_VAULT,
          NVL( USD_BUY.amt,0) AS BUY_USD,
          NVL( SGD_BUY.amt,0) AS BUY_EUR,
         NVL( EUR_BUY.amt,0) AS BUY_SGD,
          NVL( THB_BUY.amt,0) AS BUY_THB,
          NVL( JPY_BUY.amt,0) AS BUY_JPY,
         NVL(  MYR_BUY.amt,0) AS BUY_MYR,
          NVL( USD_SELL.amt,0) AS SELL_USD,
          NVL( EUR_SELL.amt,0) AS SELL_EUR,
          NVL( SGD_SELL.amt,0) AS SELL_SGD,
          NVL( THB_SELL.amt,0) AS SELL_THB,
           NVL( JPY_SELL.amt,0) AS SELL_JPY,
         NVL(  MYR_SELL.amt,0) AS SELL_MYR,
          NVL( fbInHand.amt,0) AS FB_IN_HAND
from 
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'A02'
  group by bal_date
  order by bal_date) cashInHandVault
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'USD'
  group by bal_date
  order by bal_date) USD_BUY on cashInHandVault.bal_date = USD_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'EUR'
  group by bal_date
  order by bal_date) EUR_BUY on cashInHandVault.bal_date = EUR_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'SGD'
  group by bal_date
  order by bal_date) SGD_BUY on cashInHandVault.bal_date = SGD_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'THB'
  group by bal_date
  order by bal_date) THB_BUY on cashInHandVault.bal_date = THB_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'JPY'
  group by bal_date
  order by bal_date) JPY_BUY on cashInHandVault.bal_date = JPY_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'BUY'
  AND CURRENCY = 'MYR'
  group by bal_date
  order by bal_date) MYR_BUY on cashInHandVault.bal_date = MYR_BUY.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'USD'
  group by bal_date
  order by bal_date) USD_SELL on cashInHandVault.bal_date = USD_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'EUR'
  group by bal_date
  order by bal_date) EUR_SELL on cashInHandVault.bal_date = EUR_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'SGD'
  group by bal_date
  order by bal_date) SGD_SELL on cashInHandVault.bal_date = SGD_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'THB'
  group by bal_date
  order by bal_date) THB_SELL on cashInHandVault.bal_date = THB_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'JPY'
  group by bal_date
  order by bal_date) JPY_SELL on cashInHandVault.bal_date = JPY_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'SELL'
  AND CURRENCY = 'MYR'
  group by bal_date
  order by bal_date) MYR_SELL on cashInHandVault.bal_date = MYR_SELL.bal_date
left join
  (select BAL_DATE, sum(BALANCE) AS amt
  from CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE
  where GROUP_CODE = 'A05'
  group by bal_date
  Order By Bal_Date) Fbinhand On Cashinhandvault.Bal_Date = Fbinhand.Bal_Date
  order by Fbinhand.Bal_Date
  ;
  
  
--------------------------------------------------------------------------------
FUNCTION CIH(ci_currency VARCHAR2,ci_TranDate VARCHAR2,GLCODE1 VARCHAR2, GLCODE2 VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := GLCODE1;
  BEGIN
     BEGIN
      Select Ci_Trandate As Gg,
        abs(SUM(T.TOTAL)) AS TOTAL,
        GLCODE1 AS GLSUBCODE
        INTO CIHDate, CIHCALCULATE, CIHGL
      FROM (
          select q.bal_date AS BAL_DATE,
                  CASE WHEN  q.CURRENCY = 'MMK' THEN q.total
                   ELSE q.total * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(q.CURRENCY) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(q.CURRENCY)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),1) END   as TOTAL,
                  q.GL_SUB_HEAD_CODE AS GL_SUB_HEAD_CODE
          from (
             select
                    Gstt.Bal_Date, 
                    --Case When Sum(Gstt.Tot_Cr_Bal) > Sum(Gstt.Tot_Dr_Bal) 
                    --then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
                    --else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total, 
                    sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) as total,
                    gstt.CRNCY_CODE AS CURRENCY, 
                    gstt.GL_SUB_HEAD_CODE AS GL_SUB_HEAD_CODE
         
              from  tbaadm.gstt gstt, CUSTOM.COA_MP COA
              where gstt.bal_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
              and   gstt.end_bal_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
              and   gstt.GL_SUB_HEAD_CODE = COA.GL_SUB_HEAD_CODE
              AND   GSTT.CRNCY_CODE = COA.CUR
              AND   COA.GROUP_CODE IN (GLCODE1,GLCODE2)
              AND GSTT.CRNCY_CODE NOT LIKE  ci_currency
              GROUP BY gstt.CRNCY_CODE, gstt.bal_date,gstt.GL_SUB_HEAD_CODE
              order by gstt.bal_date
              )q
        )T
      GROUP BY ci_TranDate,GLCODE1
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       CIHDate   := ci_TranDate;
       CIHCalculate := 0.0;
       CIHGL := GLCODE1;
    END;
  INSERT INTO CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE  
  VALUES  (CIHDate, CIHCalculate, CIHGL, null);
  RETURN v_returnValue; 
END CIH;

--------------------------------------------------------------------------------


  PROCEDURE FIN_FCY_BUY_SELL_FP(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
   
      
      TYPE allDataBuyTable IS TABLE OF ExtractDataBuyAllBranch%ROWTYPE INDEX BY BINARY_INTEGER;
      l_allDataBuyTable allDataBuyTable;
--------------------------------------------------------------------------------    
      
      TYPE allDataSellTable IS TABLE OF ExtractDataSellAllBranch%ROWTYPE INDEX BY BINARY_INTEGER;
      l_allDataSellTable allDataSellTable;
--------------------------------------------------------------------------------      
      
      TYPE extractAllAccData IS TABLE OF ExtractAllDataFromAcc%ROWTYPE INDEX BY BINARY_INTEGER;
      l_extractAllAccData extractAllAccData;
      
      v_buying number := 0;
      v_selling number := 0;
      
      v_balDate CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_date%type;
      v_usdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_sgdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_eurBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_thbBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_myrBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_jpyBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_usdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_sgdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_eurSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_thbSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_myrSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      v_jpySellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      out_put Varchar2(60);
      CountDate number := 0;
      TEMPCountDate varchar2(20);
      v_suspense number := 0;
      v_cashInHand number := 0;
      v_foreignBankInHand number := 0;
      
      v_rate number := 1;
      v_calculateCurAmt number := 0;
      
  BEGIN
    
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);		

    
    BEGIN 
      select TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) - TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )+ 1 as aa
      into CountDate
      from dual;
    END;
    
    DELETE FROM CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE;

      IF NOT ExtractDataBuyAllBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataBuyAllBranch (vi_startDate , vi_endDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataBuyAllBranch%ISOPEN THEN
		--{
    FETCH	ExtractDataBuyAllBranch	BULK COLLECT INTO l_allDataBuyTable LIMIT limitsize;
    FOR x IN 1 .. l_allDataBuyTable.COUNT
    LOOP
      begin
          if (l_allDataBuyTable(x).CURRENCY = 'MMK') THEN v_rate := 1;
          v_calculateCurAmt := l_allDataBuyTable(x).BUYING_AMT * v_rate;
          else 
            v_calculateCurAmt := l_allDataBuyTable(x).BUYING_AMT * v_rate;
          end if;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_rate := 1;
            v_calculateCurAmt := l_allDataBuyTable(x).BUYING_AMT * v_rate;
        end;
        insert into CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE 
        values (l_allDataBuyTable(x).bal_date, v_calculateCurAmt, 'BUY',
        l_allDataBuyTable(x).CURRENCY);
        commit;
    END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataBuyAllBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataBuyAllBranch;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
--------------------------------------------------------------------------------
     IF NOT ExtractDataSellAllBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataSellAllBranch (vi_startDate , vi_endDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataSellAllBranch%ISOPEN THEN
		--{
    FETCH	ExtractDataSellAllBranch	BULK COLLECT INTO l_allDataSellTable LIMIT limitsize;
    FOR x IN 1 .. l_allDataSellTable.COUNT
    LOOP
      begin
          if (l_allDataSellTable(x).CURRENCY = 'MMK') THEN v_rate := 1;
          v_calculateCurAmt := l_allDataSellTable(x).SELLING_AMT * v_rate;
          else 
            v_calculateCurAmt := l_allDataSellTable(x).SELLING_AMT * v_rate;
          end if;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_rate := 1;
            v_calculateCurAmt := l_allDataSellTable(x).SELLING_AMT * v_rate;
        end;
        insert into CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE 
        values (l_allDataSellTable(x).bal_date, v_calculateCurAmt, 'SELL',
        l_allDataSellTable(x).CURRENCY);
        commit;
    END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataSellAllBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataSellAllBranch;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    /*
--------------------------------------------------------------------------------
     IF NOT ExtractAllDataFromAcc%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractAllDataFromAcc (vi_startDate , vi_endDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractAllDataFromAcc%ISOPEN THEN
		--{
    FETCH	ExtractAllDataFromAcc	BULK COLLECT INTO l_extractAllAccData LIMIT limitsize;
    FOR x IN 1 .. l_extractAllAccData.COUNT
    LOOP
      begin
          if (l_extractAllAccData(x).CURRENCY = 'MMK') THEN v_rate := 1;
          v_calculateCurAmt := l_extractAllAccData(x).total * v_rate;
          else 
          SELECT  VAR_CRNCY_UNITS into v_rate
          FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = l_extractAllAccData(x).CURRENCY 
          and TRIM(VAR_CRNCY_CODE) = 'MMK' 
          and RATECODE = (select variable_value 
          from custom.CUST_GENCUST_PARAM_MAINT 
          where module_name = 'FOREIGN_CURRENCY' 
          and variable_name = 'RATE_CODE')
          and rownum =1
          order by rtlist_date desc;
            v_calculateCurAmt := l_extractAllAccData(x).total * v_rate;
          end if;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_rate := 1;
            v_calculateCurAmt := l_extractAllAccData(x).total * v_rate;
        end;
        insert into CUSTOM.CUST_FCY_BS_FP_TEMP_TABLE 
        values (l_extractAllAccData(x).bal_date, v_calculateCurAmt,
        l_extractAllAccData(x).GL_SUB_HEAD_CODE,
        null);
        commit;
    END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractAllDataFromAcc%NOTFOUND THEN
			--{
				CLOSE ExtractAllDataFromAcc;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
 */
 
 ------------------------Function call FOR CIH FOREIGN--------------------------
 
 FOR CC IN 0 .. CountDate-1
   LOOP 
   --dbms_output.put_line(vi_startDate);
      select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) +CC
      into TEMPCountDate
      from dual;
     
      BEGIN
       out_put := CIH('NOTMMK',TEMPCountDate,'A02','NOTHING');
      END;
      --dbms_output.put_line(TEMPCountDate);
  END LOOP;
 
-------------------------------------------------------------------------------
 
------------------------Function call FOR Foreign Bank FCY--------------------------
 
 FOR DD IN 0 .. CountDate-1
   LOOP 
   --dbms_output.put_line(vi_startDate);
      select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) +DD
      into TEMPCountDate
      from dual;
     
      BEGIN
       out_put := CIH('MMK',TEMPCountDate,'A05','A06');
      END;
      --dbms_output.put_line(TEMPCountDate);
  END LOOP;
 
------------------------------------------------------------------------------- 
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
			FETCH	ExtractData
			INTO	v_balDate , v_cashInHand, v_usdBuyAmt ,v_sgdBuyAmt ,v_eurBuyAmt ,
      v_thbBuyAmt , v_myrBuyAmt ,v_jpyBuyAmt ,v_usdSellAmt ,v_eurSellAmt ,
      v_sgdSellAmt ,v_thbSellAmt ,v_myrSellAmt ,v_jpySellAmt , 
      V_Foreignbankinhand;

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
    
    out_rec:=	(v_balDate || '|' || v_cashInHand/1000000|| '|' || v_usdBuyAmt/1000000 || '|' ||
    v_sgdBuyAmt/1000000 || '|' ||v_eurBuyAmt/1000000 || '|' ||v_thbBuyAmt/1000000 || '|' || 
    v_myrBuyAmt/1000000 || '|' ||v_jpyBuyAmt/1000000 || '|' ||v_usdSellAmt/1000000 || '|' ||
    v_sgdSellAmt/1000000 || '|' ||v_eurSellAmt/1000000 || '|' ||v_thbSellAmt/1000000 || '|' ||
    v_myrSellAmt/1000000 || '|' ||v_jpySellAmt/1000000 || '|' ||v_suspense/1000000|| '|' || 
    v_foreignBankInHand/1000000);
    
    dbms_output.put_line(out_rec);
    
  END FIN_FCY_BUY_SELL_FP;

END FIN_FCY_BUY_SELL_FP;
/
