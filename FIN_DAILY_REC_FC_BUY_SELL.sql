CREATE OR REPLACE PACKAGE        FIN_DAILY_REC_FC_BUY_SELL AS 

  PROCEDURE FIN_DAILY_REC_FC_BUY_SELL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAILY_REC_FC_BUY_SELL;
/


CREATE OR REPLACE PACKAGE BODY                                                  FIN_DAILY_REC_FC_BUY_SELL AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
 -- vi_branchId        varchar2(5);
  limitsize         INTEGER := 200;
  
    
CURSOR ExtractDataByAllBranch (	ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
  select 
  b_usd.usd_date AS CUR_DATE,
  NVL(b_usd.usd_amt,0) AS USD_BUYING, 
  NVL(b_eur.eur_amt,0) AS EUR_BUYING,
  NVL(b_sgd.sgd_amt,0) AS SGD_BUYING,
  NVL(b_thb.thb_amt,0) AS THB_BUYING,
  NVL(b_myr.myr_amt,0) AS MYR_BUYING,
  NVL(b_jpy.jpy_amt,0) AS JPY_BUYING,
  NVL(s_usd.usd_amt,0) AS USD_SELLING,
  NVL(s_eur.eur_amt,0) AS EUR_SELLING,
  NVL(s_sgd.sgd_amt,0) AS SGD_SELLING,
  NVL(s_thb.thb_amt,0) AS THB_SELLING,
  NVL(s_myr.myr_amt,0) AS MYR_SELLING,
  NVL(s_jpy.jpy_amt,0) AS JPY_SELLING 
  from
(SELECT 
  sum(tran_amt) as usd_amt, tran_date as usd_date
From 
  CUSTOM.C_DENOM_CASH_MAINTENANCE  cdcm
WHERE 
  FOREIGN_EXCHANGE = 'B'
  and tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'USD'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_usd
  left join
  (SELECT 
  sum(tran_amt) as usd_amt, tran_date as usd_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
WHERE 
  FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'USD'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_usd
  on b_usd.usd_date = s_usd.usd_date
  LEFT JOIN
  (SELECT 
  sum(tran_amt) as eur_amt, tran_date as eur_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
WHERE 
  FOREIGN_EXCHANGE = 'B'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'EUR'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_eur
  on b_usd.usd_date = b_eur.eur_date
  LEFT JOIN
    (SELECT 
  sum(tran_amt) as eur_amt, tran_date as eur_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'EUR'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_eur
    on b_usd.usd_date = s_eur.eur_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as sgd_amt, tran_date as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'SGD'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_sgd
    on b_usd.usd_date = b_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as sgd_amt, tran_date as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'SGD'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_sgd
    on b_usd.usd_date = s_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as thb_amt, tran_date as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'THB'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_thb
    on b_usd.usd_date = b_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as thb_amt, tran_date as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'THB'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_thb
    on b_usd.usd_date = s_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as jpy_amt, tran_date as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'JPY'
  And Bank_Id = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_jpy
    on b_usd.usd_date = b_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as jpy_amt, tran_date as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'JPY'
  And Bank_Id = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_jpy
    on b_usd.usd_date = s_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as myr_amt, tran_date as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'MYR'
  And Bank_Id = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) b_myr
    on b_usd.usd_date = b_myr.myr_date
    LEFT JOIN
    (SELECT 
  sum(tran_amt) as myr_amt, tran_date as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE cdcm
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  and CDCM.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and CDCM.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND REF_CRNCY_CODE = 'MYR'
  AND BANK_ID = '01'
  And  Trim(cdcm.Tran_Id)  Not In (Select Trim(Atd.Cont_Tran_Id) From Tbaadm.Atd Atd 
  where  atd.cont_tran_date =cdcm.tran_date  )
  --AND SUBSTR(DEBIT_FORACID,1,5) = ci_solId
  group by tran_date) s_myr
    on b_usd.usd_date = s_myr.myr_date
  ORDER BY b_usd.usd_date;

  CURSOR ExtractData IS
  SELECT BAL_DATE, NVL(USD_BUY,0), NVL(EUR_BUY,0), NVL(SGD_BUY,0), NVL(THB_BUY,0), NVL(JPY_BUY,0), NVL(MYR_BUY,0),
 NVL(USD_SELL,0), NVL(EUR_SELL,0), NVL(SGD_SELL,0), NVL(THB_SELL,0), NVL(JPY_SELL,0), NVL(MYR_SELL,0), NVL(USD_OPEN,0), 
  NVL(EUR_OPEN,0), NVL(SGD_OPEN,0), NVL(THB_OPEN,0), NVL(JPY_OPEN,0), NVL(MYR_OPEN,0),
  NVL(USD_CLOSE,0), NVL(EUR_CLOSE,0), NVL(SGD_CLOSE,0), NVL(THB_CLOSE,0), NVL(JPY_CLOSE,0), NVL(MYR_CLOSE,0)
  FROM CUSTOM.CUST_DR_FCY_BS_TEMP_TABLE
  order by BAL_DATE;

FUNCTION GET_OPENING_AMOUNT(currency varchar2, Ci_startDate varchar2) 
  RETURN number AS
  
  v_openingAmt number;
  
  BEGIN
      Begin
             select
                     
                    case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
                    then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
                    else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total
                    into v_openingAmt
              from  tbaadm.gstt gstt, CUSTOM.COA_MP COA
              where gstt.bal_date <= TO_DATE( CAST ( Ci_startDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
              and   gstt.end_bal_date >= TO_DATE( CAST ( Ci_startDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
              and   gstt.GL_SUB_HEAD_CODE = COA.GL_SUB_HEAD_CODE
              AND   GSTT.CRNCY_CODE = COA.CUR
              AND   COA.GROUP_CODE IN ('A02')
              AND GSTT.CRNCY_CODE  LIKE  Upper(currency)
              order by gstt.bal_date;
       EXCEPTION
      WHEN NO_DATA_FOUND THEN
       v_openingAmt   := 0.00;
    END;
   RETURN v_openingAmt;
END GET_OPENING_AMOUNT;


  PROCEDURE FIN_DAILY_REC_FC_BUY_SELL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_date CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_DATE%TYPE;
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
      
      v_openingamountUSD NUMBER := 0;
      v_openingamountEUR NUMBER := 0;
      v_openingamountSGD NUMBER := 0;
      v_openingamountTHB NUMBER := 0;
      v_openingamountJPY NUMBER := 0;
      v_openingamountMYR NUMBER := 0;
      
      v_closingamountUSD NUMBER := 0;
      v_closingamountEUR NUMBER := 0;
      v_closingamountSGD NUMBER := 0;
      v_closingamountTHB NUMBER := 0;
      v_closingamountJPY NUMBER := 0;
      v_closingamountMYR NUMBER := 0;
      
    
      TYPE extractDateTable IS TABLE OF ExtractDataByAllBranch%ROWTYPE INDEX BY BINARY_INTEGER;
      l_extractDateTable extractDateTable;
      
      r_usdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_sgdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_eurBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_thbBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_myrBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_jpyBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_usdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_sgdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_eurSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_thbSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_myrSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_jpySellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      
      r_usdOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_sgdOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_eurOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_thbOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_myrOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_jpyOpen CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_usdClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_sgdClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_eurClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_thbClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_myrClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
      r_jpyClose CUSTOM.C_DENOM_CASH_MAINTENANCE.TRAN_AMT%TYPE;
       CountDate number := 0;
       TEMPCountDate varchar2(20);
      
  BEGIN
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);		
   -- vi_branchId      :=  outArr(2);
    
    -------------------------------------------------------------------------------------------
    
    if( vi_startDate is null or vi_endDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		            0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0
					);
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    ----------------------------------------------------------------------------------------------
    BEGIN 
      select TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) - TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )+ 1 as aa
      into CountDate
      from dual;
    END;
    -----------------------------------------------------------------------------------------------
    
   -- v_openingamountUSD := GET_OPENING_AMOUNT('USD');
   -- v_openingamountEUR := GET_OPENING_AMOUNT('EUR');
    --v_openingamountSGD := GET_OPENING_AMOUNT('SGD');
    --v_openingamountTHB := GET_OPENING_AMOUNT('THB');
   -- v_openingamountJPY := GET_OPENING_AMOUNT('JPY');
   -- v_openingamountMYR := GET_OPENING_AMOUNT('MYR');
    
   -- IF v_openingamountUSD IS NULL THEN v_openingamountUSD := 0;END IF; 
   -- IF v_openingamountEUR IS NULL THEN v_openingamountEUR := 0;END IF;
   -- IF v_openingamountSGD IS NULL THEN v_openingamountSGD := 0;END IF;
    --IF v_openingamountTHB IS NULL THEN v_openingamountTHB := 0;END IF;
   -- IF v_openingamountJPY IS NULL THEN v_openingamountJPY := 0;END IF;
   -- IF v_openingamountMYR IS NULL THEN v_openingamountMYR := 0;END IF;
    
    delete from CUSTOM.CUST_DR_FCY_BS_TEMP_TABLE;
    commit;
    
   

      IF NOT ExtractDataByAllBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataByAllBranch (vi_startDate , vi_endDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataByAllBranch%ISOPEN THEN
		--{
			FETCH	ExtractDataByAllBranch	BULK COLLECT INTO l_extractDateTable LIMIT limitsize;
    FOR x IN 1 .. l_extractDateTable.COUNT
    LOOP
      IF l_extractDateTable(x).USD_BUYING IS NULL THEN 
        v_usdBuyAmt := 0; 
      ELSE v_usdBuyAmt := l_extractDateTable(x).USD_BUYING; 
      END IF;
      IF l_extractDateTable(x).USD_SELLING IS NULL THEN 
        v_usdSellAmt := 0; 
      ELSE v_usdSellAmt := l_extractDateTable(x).USD_Selling; 
      END IF;
      
      IF l_extractDateTable(x).EUR_BUYING IS NULL THEN 
        v_eurBuyAmt := 0; 
      ELSE v_eurBuyAmt := l_extractDateTable(x).EUR_BUYING; 
      END IF;
      IF l_extractDateTable(x).EUR_SELLING IS NULL THEN 
        v_eurSellAmt := 0; 
      ELSE v_eurSellAmt := l_extractDateTable(x).EUR_Selling; 
      END IF;
      
      IF l_extractDateTable(x).SGD_BUYING IS NULL THEN 
        v_sgdBuyAmt := 0; 
      ELSE v_sgdBuyAmt := l_extractDateTable(x).SGD_BUYING; 
      END IF;
      IF l_extractDateTable(x).SGD_SELLING IS NULL THEN 
        v_sgdSellAmt := 0; 
      ELSE v_sgdSellAmt := l_extractDateTable(x).SGD_Selling; 
      END IF;
      
      IF l_extractDateTable(x).THB_BUYING IS NULL THEN 
        v_thbBuyAmt := 0; 
      ELSE v_thbBuyAmt := l_extractDateTable(x).THB_BUYING; 
      END IF;
      IF l_extractDateTable(x).THB_SELLING IS NULL THEN 
        v_thbSellAmt := 0; 
      ELSE v_thbSellAmt := l_extractDateTable(x).THB_Selling; 
      END IF;
      
      IF l_extractDateTable(x).JPY_BUYING IS NULL THEN 
        v_jpyBuyAmt := 0; 
      ELSE v_jpyBuyAmt := l_extractDateTable(x).JPY_BUYING; 
      END IF;
      IF l_extractDateTable(x).JPY_SELLING IS NULL THEN 
        v_jpySellAmt := 0; 
      ELSE v_jpySellAmt := l_extractDateTable(x).JPY_Selling; 
      END IF;
      IF l_extractDateTable(x).JPY_BUYING IS NULL THEN 
        v_jpyBuyAmt := 0; 
      ELSE v_jpyBuyAmt := l_extractDateTable(x).JPY_BUYING; 
      END IF;
      
      IF l_extractDateTable(x).MYR_SELLING IS NULL THEN 
        v_myrSellAmt := 0; 
      ELSE v_myrSellAmt := l_extractDateTable(x).MYR_Selling; 
      END IF;
      
      BEGIN
        select  TO_DATE( CAST ( l_extractDateTable(x).CUR_DATE AS VARCHAR(10) ) , 'dd-Mon-yy' )  -1
        into TEMPCountDate
        from dual;
      END;
      dbms_output.put_line(l_extractDateTable(x).CUR_DATE);
      v_openingamountUSD := GET_OPENING_AMOUNT('USD',TEMPCountDate);
      dbms_output.put_line(v_openingamountUSD);
      v_openingamountEUR := GET_OPENING_AMOUNT('EUR',TEMPCountDate);
      dbms_output.put_line(v_openingamountEUR);
      v_openingamountSGD := GET_OPENING_AMOUNT('SGD',TEMPCountDate);
      dbms_output.put_line(v_openingamountSGD);
      v_openingamountTHB := GET_OPENING_AMOUNT('THB',TEMPCountDate);
      dbms_output.put_line(v_openingamountTHB);
      v_openingamountJPY := GET_OPENING_AMOUNT('JPY',TEMPCountDate);
      dbms_output.put_line(v_openingamountJPY);
      v_openingamountMYR := GET_OPENING_AMOUNT('MYR',TEMPCountDate);
      dbms_output.put_line(v_openingamountMYR);
      
     /* v_closingamountUSD := (v_openingamountUSD + 
      v_usdBuyAmt) - v_usdSellAmt ;
      v_closingamountEUR := (v_openingamountEUR + 
      v_eurBuyAmt) - v_eurSellAmt ;
      v_closingamountSGD := (v_openingamountSGD + 
      v_sgdBuyAmt) - v_sgdSellAmt ;
      v_closingamountTHB := (v_openingamountTHB + 
      v_thbBuyAmt) - v_jpySellAmt ;
      v_closingamountJPY := (v_openingamountJPY + 
      v_jpyBuyAmt) - v_usdSellAmt ;
      v_closingamountMYR := (v_openingamountMYR + 
      v_myrBuyAmt) - l_extractDateTable(x).MYR_SELLING ;*/
      
      v_closingamountUSD := GET_OPENING_AMOUNT('USD',l_extractDateTable(x).CUR_DATE);
      v_closingamountEUR := GET_OPENING_AMOUNT('EUR',l_extractDateTable(x).CUR_DATE);
      v_closingamountSGD := GET_OPENING_AMOUNT('SGD',l_extractDateTable(x).CUR_DATE);
      v_closingamountTHB := GET_OPENING_AMOUNT('THB',l_extractDateTable(x).CUR_DATE);
      v_closingamountJPY := GET_OPENING_AMOUNT('JPY',l_extractDateTable(x).CUR_DATE);
      v_closingamountMYR := GET_OPENING_AMOUNT('MYR',l_extractDateTable(x).CUR_DATE);
      
      insert into CUSTOM.CUST_DR_FCY_BS_TEMP_TABLE 
      values (l_extractDateTable(x).CUR_DATE, v_openingamountUSD, v_openingamountEUR,
      v_openingamountSGD, v_openingamountTHB, v_openingamountJPY, 
      v_openingamountMYR, v_usdBuyAmt, v_eurBuyAmt, v_sgdBuyAmt,
      v_thbBuyAmt, v_jpyBuyAmt, v_myrBuyAmt, v_usdSellAmt, v_eurSellAmt,
      v_sgdSellAmt, v_thbSellAmt, v_jpySellAmt, v_myrSellAmt
      , v_closingamountUSD, v_closingamountEUR, v_closingamountSGD,
      v_closingamountTHB, v_closingamountJPY, v_closingamountMYR);
      commit;
      
     -- v_openingamountUSD := v_closingamountUSD;
    --  v_openingamountEUR := v_closingamountEUR;
     -- v_openingamountSGD := v_closingamountSGD;
    --  v_openingamountTHB := v_closingamountTHB;
     -- v_openingamountJPY := v_closingamountJPY;
     -- v_openingamountMYR := v_closingamountMYR;
    END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataByAllBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataByAllBranch;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractData%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractData ;
            --}
            END;
      
          --}
          END IF;
          
          IF ExtractData%ISOPEN THEN
          --{
            FETCH	ExtractData
            INTO	v_Date, r_usdBuyAmt , r_eurBuyAmt , r_sgdBuyAmt ,
            r_thbBuyAmt ,r_jpyBuyAmt ,r_myrBuyAmt ,
            r_usdSellAmt ,r_eurSellAmt ,r_sgdSellAmt ,r_thbSellAmt ,r_jpySellAmt ,
            r_myrSellAmt ,r_usdOpen ,r_eurOpen ,r_sgdOpen ,r_thbOpen ,
            r_jpyOpen ,r_myrOpen ,r_usdClose ,r_eurClose ,r_sgdClose ,
            r_thbClose ,r_jpyClose ,r_myrClose ;
            
      
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

    out_rec:=	(to_char(to_date(v_Date,'dd/Mon/yy'), 'dd.MM.yyyy')||'|'|| r_usdBuyAmt ||'|'|| r_sgdBuyAmt ||'|'|| 
              r_eurBuyAmt ||'|'||r_thbBuyAmt ||'|'||r_jpyBuyAmt ||'|'||
              r_myrBuyAmt ||'|'||r_usdSellAmt ||'|'||r_sgdSellAmt ||'|'||
              r_eurSellAmt ||'|'||r_thbSellAmt ||'|'||r_jpySellAmt ||'|'||
              r_myrSellAmt ||'|'||r_usdOpen ||'|'||r_sgdOpen ||'|'||
              r_eurOpen ||'|'||r_thbOpen ||'|'||r_jpyOpen ||'|'||
              r_myrOpen ||'|'||r_usdClose ||'|'||r_sgdClose ||'|'||
              r_eurClose ||'|'||r_thbClose ||'|'||r_jpyClose ||'|'||r_myrClose);   
  
			dbms_output.put_line(out_rec);
    
  END FIN_DAILY_REC_FC_BUY_SELL;

END FIN_DAILY_REC_FC_BUY_SELL;
/
