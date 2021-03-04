
/


CREATE OR REPLACE PACKAGE BODY               FIN_DAILY_POSITION_CASH AS
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
  SELECT SOT.SOL_ID, SOT.SOL_DESC, NVL(SUM(T.VaultLimit),0) AS VaultLimit, NVL(SUM(T.CashInHand),0) AS CashInHand
  , NVL(SUM(T.CashInHandATM),0) AS CashInHandATM, NVL(SUM(T.CashInHandFECounter),0) AS CashInHandFECounter
  , NVL(SUM(T.tCashInHandFCY),0) AS CashInHandFCY, SUM(0) AS CashInHandTotal
  , NVL(SUM(T.tAcWithCBM),0) AS AcWithCBM, NVL(SUM(T.DepositCBM),0) AS DepositCBM
  , NVL(SUM(T.AcWithMEB),0) AS AcWithMEB, NVL(SUM(T.tAcWithMICBMFTB),0) AS AcWithMICBMFTB
  , NVL(SUM(T.AcWithOtherBank),0) AS AcWithOtherBank, SUM(0) AS GrandTotal
  FROM TBAADM.SERVICE_OUTLET_TABLE SOT LEFT JOIN
  (
  SELECT SOL_ID, CRNCY_CODE, 0 as VaultLimit, NVL(CashInHand,0) AS CashInHand, NVL(CashInHandATM,0) AS CashInHandATM
  , 0 AS CashInHandFECounter, NVL(CashInHandFCY,0) AS CashInHandFCY
  , NVL(AcWithCBM,0) AS AcWithCBM
  , NVL(DepositCBM,0) AS DepositCBM, NVL(AcWithMEB,0) AS AcWithMEB
  , NVL(AcWithMICB,0) + NVL(AcWithMFTB,0) AS AcWithMFTBMICB
  , NVL(AcWithKBZ,0) + NVL(AcWithMWD,0) + NVL(AcWithGTB,0) + NVL(AcWithMCB,0)
  + NVL(AcWithAYA,0) + NVL(AcWithINNWA,0) + NVL(AcWithCB,0) + NVL(AcWithMAB,0)
  + NVL(AcWithSMID,0) + NVL(AcWithRDB,0) + NVL(AcWithCHD,0) + NVL(AcWithUAB,0)
  + NVL(AcWithSHWE,0) + NVL(AcWithSBTYY,0) AS AcWithOtherBank
  , CASE CRNCY_CODE WHEN 'USD' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'USD'
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'EUR' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'EUR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'SGD' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'SGD' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'MYR' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'MYR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'THB' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'THB' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'JPY' THEN NVL(CashInHandFCY,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'JPY' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  ELSE  NVL(CashInHandFCY,0) END AS tCashInHandFCY
  
  , CASE CRNCY_CODE WHEN 'USD' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'USD' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'EUR' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'EUR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'SGD' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'SGD' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'MYR' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'MYR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1)
  WHEN 'THB' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'THB' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'JPY' THEN NVL(AcWithCBM,0) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'JPY' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  ELSE  NVL(AcWithCBM,0) END AS tAcWithCBM
  
  , CASE CRNCY_CODE WHEN 'USD' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'USD' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'EUR' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'EUR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'SGD' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'SGD' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'MYR' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'MYR' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1)
  WHEN 'THB' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'THB' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  WHEN 'JPY' THEN (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) * NVL((SELECT VAR_CRNCY_UNITS
  FROM TBAADM.RTL WHERE TRIM(FXD_CRNCY_CODE) = 'JPY' 
  AND TRIM(VAR_CRNCY_CODE) = 'MMK'
  AND RATECODE = (SELECT VARIABLE_VALUE 
  FROM CUSTOM.CUST_GENCUST_PARAM_MAINT 
  WHERE MODULE_NAME = 'FOREIGN_CURRENCY' 
  AND VARIABLE_NAME = 'RATE_CODE')
  AND RTLIST_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND ROWNUM = 1),1) 
  ELSE (NVL(AcWithMICB,0) + NVL(AcWithMFTB,0)) END AS tAcWithMICBMFTB
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
  WHERE gstt.BAL_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy') AND
  gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
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
  GROUP BY SOT.SOL_ID, SOT.SOL_DESC
  ORDER BY SOL_ID;

  PROCEDURE FIN_DAILY_POSITION_CASH(	inp_str      IN  VARCHAR2,
  out_retCode  OUT NUMBER,
  out_rec      OUT VARCHAR2 ) AS
  v_solID TBAADM.SERVICE_OUTLET_TABLE.SOL_ID%type;
  v_solDesc TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%type;
  v_vaultLimit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHand TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandATM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandFECounter TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandFCY TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_cashInHandTotal TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithCBM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_depAuctionCBM TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithMEB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithMICBMFTB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_acwithOB TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_grandTotal TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
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
            v_cashInHandFECounter, v_cashInHandFCY, v_cashInHandTotal, v_acwithCBM,
            v_depAuctionCBM, v_acwithMEB, v_acwithMICBMFTB, v_acwithOB, v_grandTotal;
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
      SELECT 
         BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 AS "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM AS "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM AS "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      FROM
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         AND SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         AND SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         AND SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
    
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
                v_BankFax);
  
			dbms_output.put_line(out_rec);
  END FIN_DAILY_POSITION_CASH;

END FIN_DAILY_POSITION_CASH;
/
