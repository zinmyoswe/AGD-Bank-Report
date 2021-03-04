CREATE OR REPLACE PACKAGE        FIN_DAILY_POSITION_CASH1 AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_DAILY_POSITION_CASH1(	inp_str      IN  VARCHAR2,
  out_retCode  OUT NUMBER,
  out_rec      OUT VARCHAR2 );

END FIN_DAILY_POSITION_CASH1;
/


CREATE OR REPLACE PACKAGE BODY               FIN_DAILY_POSITION_CASH1 AS
/******************************************************************************
 NAME:       FIN_DAILY_POSITION_CASH
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_tranDate       VARCHAR2(10);               -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_DAILY_POSITION_CASH CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_tranDate VARCHAR2)
IS  
 SELECT SOT.SOL_ID, SOT.SOL_DESC
  , NVL(SUM(T.VaultLimit),0) AS VaultLimit
  , NVL(SUM(T.CashInHand),0) AS CashInHand
  , NVL(SUM(T.CashInHandATM),0) AS CashInHandATM
  , NVL(SUM(T.CashInHandFECounter),0) AS CashInHandFECounter
  --, NVL(SUM(T.tCashInHandFCY),0) AS CashInHandFCY
  , SUM(0) AS CashInHandTotal
  , NVL(SUM(T.tAcWithCBM),0) AS AcWithCBM
  , NVL(SUM(T.DepositCBM),0) AS DepositCBM
  , NVL(SUM(T.AcWithMEB),0) AS AcWithMEB
  , NVL(SUM(T.tAcWithMICBMFTB),0) AS AcWithMICBMFTB
  , NVL(SUM(T.AcWithOtherBank),0) AS AcWithOtherBank
  , SUM(0) AS GrandTotal,
  NVL(SUM(T.FCY_USD),0),
NVL(SUM(T.FCY_EUR),0),
  NVL(SUM(T.FCY_JPY),0),
 NVL(SUM(T.FCY_SGD),0),
  NVL(SUM(T.FCY_THB),0),
  NVL(SUM(T.FCY_INR),0),
  NVL(SUM(T.FCY_MYR),0)
  FROM TBAADM.SERVICE_OUTLET_TABLE SOT LEFT JOIN
  (
  SELECT SOL_ID, CRNCY_CODE, 0 as VaultLimit, NVL(CashInHand,0) AS CashInHand, NVL(CashInHandATM,0) AS CashInHandATM
  , 0 AS CashInHandFECounter--,-- NVL(CashInHandFCY,0) AS CashInHandFCY
  , NVL(AcWithCBM,0) AS AcWithCBM
  , NVL(DepositCBM,0) AS DepositCBM, NVL(AcWithMEB,0) AS AcWithMEB
  , NVL(AcWithMICB,0) + NVL(AcWithMFTB,0) AS AcWithMFTBMICB
  , NVL(AcWithKBZ,0) + NVL(AcWithMWD,0) + NVL(AcWithGTB,0) + NVL(AcWithMCB,0)
  + NVL(AcWithAYA,0) + NVL(AcWithINNWA,0) + NVL(AcWithCB,0) + NVL(AcWithMAB,0)
  + NVL(AcWithSMID,0) + NVL(AcWithRDB,0) + NVL(AcWithCHD,0) + NVL(AcWithUAB,0)
  + NVL(AcWithSHWE,0) + NVL(AcWithSBTYY,0) AS AcWithOtherBank
  ,
  CASE WHEN CRNCY_CODE = 'USD' THEN NVL(CashInHandFCY,0) else 0 end as FCY_USD,
  CASE WHEN CRNCY_CODE = 'EUR' THEN NVL(CashInHandFCY,0) else 0 end as FCY_EUR,
  CASE WHEN CRNCY_CODE = 'JPY' THEN NVL(CashInHandFCY,0) else 0 end as FCY_JPY,
  CASE WHEN CRNCY_CODE = 'SGD' THEN NVL(CashInHandFCY,0) else 0 end as FCY_SGD,
  CASE WHEN CRNCY_CODE = 'THB' THEN NVL(CashInHandFCY,0) else 0 end as FCY_THB,
  CASE WHEN CRNCY_CODE = 'INR' THEN NVL(CashInHandFCY,0) else 0 end as FCY_INR,
  CASE WHEN CRNCY_CODE = 'MYR' THEN NVL(CashInHandFCY,0) else 0 end as FCY_MYR,
                       
  CASE WHEN CRNCY_CODE = 'MMK' THEN NVL(AcWithCBM,0)
  ELSE NVL(AcWithCBM,0) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS tAcWithCBM,
   CASE WHEN CRNCY_CODE = 'MMK' THEN NVL(AcWithMICB,0)
  ELSE NVL(AcWithMICB,0) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS tAcWithMICBMFTB
  FROM
  (SELECT CASE WHEN SUM(gstt.TOT_CR_BAL) > SUM(gstt.TOT_DR_BAL) 
  THEN SUM(gstt.TOT_CR_BAL) - SUM(gstt.TOT_DR_BAL) 
  ELSE SUM(gstt.TOT_DR_BAL) - SUM(gstt.TOT_CR_BAL) END AS total,
  gstt.SOL_ID,
  gstt.CRNCY_CODE,
  fpt.DESCRIPTION
  FROM tbaadm.gstt gstt
  INNER JOIN CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE fpt ON gstt.GL_SUB_HEAD_CODE = fpt.VARIABLE_VALUE 
  AND fpt.DESCRIPTION IS NOT NULL
  WHERE gstt.BAL_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy') 
  AND   gstt.END_BAL_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy') 
  AND  gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
  AND fpt.DESCRIPTION IN('Cash in Hand (Vault)','Cash in Hand (Foreign Currency)','Cash At ATM'
  ,'A/C With CBM','A/C With CBM Deposit','A/C With MEB','A/C With MICB','A/C With MFTB'
  ,'A/C With KBZ','A/C With MWD','A/C With GTB','A/C With MCB','A/C With AYA','A/C With Innwa'
  ,'A/C With CB','A/C With MAB','A/C With SMID','A/C With RDB','A/C With CHD','A/C With UAB'
  ,'A/C With SHWE','A/C With SBTYY')
  AND fpt.BANK_ID = '01'
  AND fpt.MODULE_NAME = 'REPORT'
  AND fpt.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  GROUP BY gstt.SOL_ID,gstt.CRNCY_CODE, fpt.DESCRIPTION)
  PIVOT (SUM(NVL(TOTAL,0)) FOR (DESCRIPTION) 
  IN ('Cash in Hand (Vault)' AS CashInHand, 'Cash in Hand (Foreign Currency)' AS CashInHandFCY
  , 'Cash At ATM' AS CashInHandATM, 'A/C With CBM' AS AcWithCBM, 'A/C With CBM Deposit' AS DepositCBM
  , 'A/C With MEB' AS AcWithMEB, 'A/C With MICB' AS AcWithMICB, 'A/C With MFTB' AS AcWithMFTB
  , 'A/C With KBZ' AS AcWithKBZ, 'A/C With MWD' AS AcWithMWD, 'A/C With GTB' AS AcWithGTB, 'A/C With MCB' AS AcWithMCB
  , 'A/C With AYA' AS AcWithAYA,'A/C With Innwa' AS AcWithINNWA, 'A/C With CB' AS AcWithCB,'A/C With MAB' AS AcWithMAB
  , 'A/C With SMID' AS AcWithSMID, 'A/C With RDB' AS AcWithRDB, 'A/C With CHD' AS AcWithCHD, 'A/C With UAB' AS AcWithUAB
  , 'A/C With SHWE' AS AcWithSHWE, 'A/C With SBTYY' AS AcWithSBTYY
  ))
  )T ON SOT.SOL_ID = T.SOL_ID
  WHERE SOT.DEL_FLG ='N' 
  GROUP BY SOT.SOL_ID, SOT.SOL_DESC--, T.CashInHand
  ORDER BY SOL_ID;

  PROCEDURE FIN_DAILY_POSITION_CASH1(	inp_str      IN  VARCHAR2,
  out_retCode  OUT NUMBER,
  out_rec      OUT VARCHAR2 ) AS
  v_solID TBAADM.SERVICE_OUTLET_TABLE.SOL_ID%type;
  v_solDesc TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%type;
  v_vaultLimit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHand TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandATM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandFECounter TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandFCY TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_USD TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_MYR TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_JPY TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_EUR TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_SGD TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_THB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FCY_INR TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  USD_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  MYR_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  JPY_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  EUR_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  SGD_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  THB_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  INR_Rate TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandTotal TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithCBM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_depAuctionCBM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithMEB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithMICBMFTB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithOB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_grandTotal TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_BranchName tbaadm.sol.sol_desc%type;
  v_BankAddress varchar(200);
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  
  BEGIN
    -- TODO: Implementation required for PROCEDURE FIN_DAILY_POSITION_CASH.FIN_DAILY_POSITION_CASH
    ------------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
  ------------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);    
  ------------------------------------------------------------------------------
		-- Parsing the i/ps from the string
	------------------------------------------------------------------------------
    
    vi_tranDate    :=  outArr(0);
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_tranDate);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO  v_solID, v_solDesc, v_vaultLimit, v_cashInHand, v_cashInHandATM,
            v_cashInHandFECounter, v_cashInHandTotal, v_acwithCBM,
            v_depAuctionCBM, v_acwithMEB, v_acwithMICBMFTB, v_acwithOB, v_grandTotal,
             v_FCY_USD,v_FCY_EUR,  v_FCY_JPY,v_FCY_SGD,  v_FCY_THB,  v_FCY_INR,  v_FCY_MYR;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
       
    SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into    v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = '10100' AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
    
    end;
    
    begin
    select VAR_CRNCY_UNITS into USD_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'USD'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        USD_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into MYR_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'MYR'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MYR_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into JPY_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'JPY'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        JPY_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into SGD_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'SGD'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SGD_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into EUR_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'EUR'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EUR_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into THB_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'THB'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        THB_Rate := 0;
   END;
   
   begin
    select VAR_CRNCY_UNITS into INR_Rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= 'INR'
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INR_Rate := 0;
   END;
   --------------------------------------------------------
  
   IF v_vaultLimit IS NULL OR v_vaultLimit = '' THEN
   v_vaultLimit  := 0 ;
  end IF;
   IF v_cashInHand IS NULL OR v_cashInHand = '' THEN
   v_cashInHand  := 0 ;
  end IF;
  
   IF v_cashInHandATM IS NULL OR v_cashInHandATM = '' THEN
   v_cashInHandATM  := 0 ;
  end IF;
  
   IF v_cashInHandFCY IS NULL OR v_cashInHandFCY = '' THEN
   v_cashInHandFCY  := 0 ;
  end IF;
  
   IF v_acwithCBM IS NULL OR v_acwithCBM = '' THEN
   v_acwithCBM  := 0 ;
  end IF;
  
   IF v_depAuctionCBM IS NULL OR v_depAuctionCBM = '' THEN
   v_depAuctionCBM  := 0 ;
  end IF;
  
   IF v_acwithMEB IS NULL OR v_acwithMEB = '' THEN
   v_acwithMEB  := 0 ;
  end IF;
  
   IF v_acwithMICBMFTB IS NULL OR v_acwithMICBMFTB = '' THEN
   v_acwithMICBMFTB  := 0 ;
  end IF;
  
   IF v_acwithOB IS NULL OR v_acwithOB = '' THEN
   v_acwithOB  := 0 ;
  end IF;
  
   IF v_grandTotal IS NULL OR v_grandTotal = '' THEN
   v_grandTotal  := 0 ;
  end IF;
  
   IF v_FCY_USD IS NULL OR v_FCY_USD = '' THEN
   v_FCY_USD  := 0 ;
  end IF;
  
   IF v_FCY_EUR IS NULL OR v_FCY_EUR = '' THEN
   v_FCY_EUR  := 0 ;
  end IF;
  
   IF v_FCY_JPY IS NULL OR v_FCY_JPY = '' THEN
   v_FCY_JPY  := 0 ;
  end IF;
  
   IF v_FCY_SGD IS NULL OR v_FCY_SGD = '' THEN
   v_FCY_SGD  := 0 ;
  end IF;
  
  
   IF v_FCY_THB IS NULL OR v_FCY_THB = '' THEN
   v_FCY_THB  := 0 ;
  end IF;
  
   IF v_FCY_INR IS NULL OR v_FCY_INR = '' THEN
   v_FCY_INR  := 0 ;
  end IF;
  
   IF v_FCY_MYR IS NULL OR v_FCY_MYR = '' THEN
   v_FCY_MYR  := 0 ;
  end IF;
  
   IF USD_Rate IS NULL OR USD_Rate = '' THEN
   USD_Rate  := 0 ;
  end IF;
  
   IF EUR_Rate IS NULL OR EUR_Rate = '' THEN
   EUR_Rate  := 0 ;
  end IF;
  
   IF JPY_Rate IS NULL OR JPY_Rate = '' THEN
   JPY_Rate  := 0 ;
  end IF;
  
   IF THB_Rate IS NULL OR THB_Rate = '' THEN
   THB_Rate  := 0 ;
  end IF;
  
   IF INR_Rate IS NULL OR INR_Rate = '' THEN
   INR_Rate  := 0 ;
  end IF;
  
   IF MYR_Rate IS NULL OR MYR_Rate = '' THEN
   MYR_Rate  := 0 ;
  end IF;
  
   IF SGD_Rate IS NULL OR SGD_Rate = '' THEN
   SGD_Rate  := 0 ;
  end IF;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(
                v_solID               || '|' || 
                v_solDesc             || '|' ||
                v_vaultLimit          || '|' ||
                v_cashInHand          || '|' ||
                v_cashInHandATM       || '|' ||
                v_cashInHandFECounter || '|' ||
                v_cashInHandFCY       || '|' ||
                v_cashInHandTotal     || '|' ||
                v_acwithCBM           || '|' ||
                v_depAuctionCBM       || '|' ||
                v_acwithMEB           || '|' ||
                v_acwithMICBMFTB      || '|' ||
                v_acwithOB            || '|' ||
                v_grandTotal          || '|' ||
                v_BranchName          || '|' ||
                v_BankAddress         || '|' ||
                v_BankPhone           || '|' ||
                v_BankFax || '|' ||
                v_FCY_USD || '|' || 
                v_FCY_EUR || '|' || 
                v_FCY_JPY || '|' || 
                v_FCY_SGD || '|' ||
                v_FCY_THB || '|' ||
                v_FCY_INR || '|' ||
                v_FCY_MYR || '|' ||
                USD_Rate || '|' || 
                EUR_Rate || '|' || 
                JPY_Rate || '|' || 
                THB_Rate || '|' ||
                INR_Rate || '|' ||
                MYR_Rate || '|' ||
                SGD_Rate);
  
			dbms_output.put_line(out_rec);
  END FIN_DAILY_POSITION_CASH1;

END FIN_DAILY_POSITION_CASH1;
/
