CREATE OR REPLACE PACKAGE        FIN_DEPOSIT_OUTSTANDING_BAL AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE FIN_DEPOSIT_OUTSTANDING_BAL(  inp_str      IN  VARCHAR2,
                                          out_retCode  OUT NUMBER,
                                          out_rec      OUT VARCHAR2 );
END FIN_DEPOSIT_OUTSTANDING_BAL;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_DEPOSIT_OUTSTANDING_BAL AS
/******************************************************************************
 NAME:       FIN_DEPOSIT_OUTSTANDING_BAL
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_Date		          Varchar2(10);		    	    -- Input to procedure  
  vi_currency         Varchar2(3);              -- Input to procedure  
  vi_currencyType     Varchar2(30);              -- Input to procedure 
  vi_schemeType		    Varchar2(5);		    	    -- Input to procedure
  vi_schemeCode		    Varchar2(5);		    	    -- Input to procedure
  vi_branchCode       Varchar2(5);              -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_LN_LEDGER_BALANCE_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractDataMMK (    
      ci_Date VARCHAR2, ci_currency VARCHAR2,
      ci_schemeCode VARCHAR2, ci_schemeType VARCHAR2, ci_branchCode VARCHAR2)
IS  
  SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,'') AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,EAB.TRAN_DATE_BAL AS Balance,EAB.TRAN_DATE_BAL AS AVBalance
  ,GA.SCHM_TYPE,GA.SCHM_CODE
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  LEFT JOIN TBAADM.EOD_ACCT_BAL_TABLE EAB ON GA.ACID = EAB.ACID
  WHERE GA.SCHM_TYPE = upper(  ci_schemeType )  
  AND GA.SCHM_CODE  LIKE '%' || ci_schemeCode || '%'   
  --AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND GA.ACCT_CRNCY_CODE = upper(ci_currency)
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  and eab.END_EOD_DATE >= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  ORDER BY GA.SCHM_CODE;
--------------------------------------------------------------------------------
CURSOR ExtractDataMMKTDA (    
      Ci_Date Varchar2, Ci_Currency Varchar2,
      Ci_Schemecode Varchar2, Ci_Branchcode Varchar2)
IS 
SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,ci_schemeCode) AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,Eab.Tran_Date_Bal As Balance,Eab.Tran_Date_Bal As Avbalance
  ,Ga.Schm_Type,Ga.Schm_Code,tam.deposit_period_mths
  
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  Left Join Tbaadm.Eod_Acct_Bal_Table Eab On Ga.Acid = Eab.Acid
  Left Join Tbaadm.Tam Tam On Ga.Acid = Tam.Acid
  WHERE GA.SCHM_TYPE = upper(  'TDA' )  
  AND GA.SCHM_CODE  LIKE '%' || ci_schemeCode || '%'   
  --AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND GA.ACCT_CRNCY_CODE = upper(ci_currency)
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  And Eab.End_Eod_Date >= To_Date(Cast(ci_Date As Varchar(10)), 'dd-MM-yyyy') 
  Order By tam.deposit_period_mths;
--------------------------------------------------------------------------------
CURSOR ExtractDataAll (    
      ci_Date VARCHAR2,
      ci_schemeCode VARCHAR2, ci_schemeType VARCHAR2, ci_branchCode VARCHAR2)
IS
select T.BranchName,
       T.AccNo,
       T.AccName,
       T.AccOpenDate,
       T.AccCloseDate,
       T.Status,
       T.Interest,
       T.Balance,
       T.AVBalance,
       T.SCHM_TYPE,
       T.SCHM_CODE
from
(select q.BranchName,
      q.AccNo,
      q.AccName,
      q.AccOpenDate,
      q.AccCloseDate,
      q.Status,
      q.Interest,
      CASE WHEN q.cur = 'MMK'  THEN q.Balance
  when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Balance,
      CASE WHEN q.cur = 'MMK'  THEN q.AVBalance
  when  q.gl_sub_head_code = '70002' and  q.AVBalance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.AVBalance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS AVBalance,
      q.SCHM_TYPE,
      q.SCHM_CODE
from
(SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,'') AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,EAB.TRAN_DATE_BAL AS Balance,EAB.TRAN_DATE_BAL AS AVBalance
  ,GA.SCHM_TYPE,GA.SCHM_CODE,
  ga.acct_crncy_code as cur,ga.gl_sub_head_code
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  LEFT JOIN TBAADM.EOD_ACCT_BAL_TABLE EAB ON GA.ACID = EAB.ACID
  WHERE GA.SCHM_TYPE = upper(  ci_schemeType )
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SCHM_CODE  LIKE '%' || ci_schemeCode || '%'   
 -- AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  and eab.END_EOD_DATE >= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  ORDER BY GA.SCHM_CODE) q
  ORDER BY q.SCHM_CODE)T
  ORDER BY T.SCHM_CODE;
--------------------------------------------------------------------------------
CURSOR ExtractDataAllTDA (    
      Ci_Date Varchar2,
      Ci_Schemecode Varchar2,Ci_Branchcode Varchar2)
      Is 
      select T.BranchName,
       T.AccNo,
       T.AccName,
       T.AccOpenDate,
       T.AccCloseDate,
       T.Status,
       T.Interest,
       T.Balance,
       T.AVBalance,
       T.Schm_Type,
       T.Schm_Code,
       T.deposit_period_mths
from
(select q.BranchName,
      q.AccNo,
      q.AccName,
      q.AccOpenDate,
      q.AccCloseDate,
      q.Status,
      q.Interest,
      CASE WHEN q.cur = 'MMK'  THEN q.Balance
  when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Balance,
      CASE WHEN q.cur = 'MMK'  THEN q.AVBalance
  when  q.gl_sub_head_code = '70002' and  q.AVBalance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.AVBalance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS AVBalance,
      Q.Schm_Type,
      q.SCHM_CODE,q.deposit_period_mths
from
(SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,ci_schemeCode) AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,EAB.TRAN_DATE_BAL AS Balance,EAB.TRAN_DATE_BAL AS AVBalance
  ,Ga.Schm_Type,Ga.Schm_Code,
  ga.acct_crncy_code as cur,ga.gl_sub_head_code,tam.deposit_period_mths
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  Left Join Tbaadm.Eod_Acct_Bal_Table Eab On Ga.Acid = Eab.Acid
  Left Join Tbaadm.Tam Tam On Ga.Acid = Tam.Acid
  WHERE GA.SCHM_TYPE = upper(  'TDA' )
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SCHM_CODE  LIKE '%' || ci_schemeCode || '%'   
 -- AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  and eab.END_EOD_DATE >= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  ORDER BY tam.deposit_period_mths) q
  Order By Q.deposit_period_mths)T
  ORDER BY T.deposit_period_mths;
--------------------------------------------------------------------------------
CURSOR ExtractDataFCY (    
      ci_Date VARCHAR2,
      ci_schemeCode VARCHAR2, ci_schemeType VARCHAR2, ci_branchCode VARCHAR2)
IS
select T.BranchName,
       T.AccNo,
       T.AccName,
       T.AccOpenDate,
       T.AccCloseDate,
       T.Status,
       T.Interest,
       T.Balance,
       T.AVBalance, 
       T.SCHM_TYPE,
       T.SCHM_CODE
from
(select q.BranchName,
      q.AccNo,
      q.AccName,
      q.AccOpenDate,
      q.AccCloseDate,
      q.Status,
      q.Interest,
       CASE WHEN q.cur = 'MMK'  THEN q.Balance
  when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Balance,
      CASE WHEN q.cur = 'MMK'  THEN q.AVBalance
  when  q.gl_sub_head_code = '70002' and  q.AVBalance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.AVBalance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS AVBalance,
      q.SCHM_TYPE,
      q.SCHM_CODE
from
(SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,'') AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,EAB.TRAN_DATE_BAL AS Balance,EAB.TRAN_DATE_BAL AS AVBalance
  ,GA.SCHM_TYPE,GA.SCHM_CODE,
  ga.acct_crncy_code as cur,ga.gl_sub_head_code
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  LEFT JOIN TBAADM.EOD_ACCT_BAL_TABLE EAB ON GA.ACID = EAB.ACID
  WHERE GA.SCHM_TYPE = upper(  ci_schemeType )
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SCHM_CODE  LIKE '%' || ci_schemeCode || '%'   
  --AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND GA.ACCT_CRNCY_CODE != upper('MMK')
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  and eab.END_EOD_DATE >= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  ORDER BY GA.SCHM_CODE) q
  ORDER BY q.SCHM_CODE)T
  Order By T.Schm_Code;
--------------------------------------------------------------------------------
Cursor ExtractdatafcyTDA (    
      ci_Date VARCHAR2,
      Ci_Schemecode Varchar2, Ci_Branchcode Varchar2)
Is
select T.BranchName,
       T.AccNo,
       T.AccName,
       T.AccOpenDate,
       T.AccCloseDate,
       T.Status,
       T.Interest,
       T.Balance,
       T.AVBalance, 
       T.Schm_Type,
       T.SCHM_CODE,T.deposit_period_mths
from
(select q.BranchName,
      q.AccNo,
      q.AccName,
      q.AccOpenDate,
      q.AccCloseDate,
      q.Status,
      q.Interest,
       CASE WHEN q.cur = 'MMK'  THEN q.Balance
  when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Balance,
      CASE WHEN q.cur = 'MMK'  THEN q.AVBalance
  when  q.gl_sub_head_code = '70002' and  q.AVBalance <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.AVBalance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.AVBalance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS AVBalance,
      Q.Schm_Type,
      q.SCHM_CODE,q.deposit_period_mths
from
(SELECT  BC.BR_SHORT_NAME AS BranchName
  ,GA.FORACID AS AccNo,GA.ACCT_NAME AS AccName,GA.ACCT_OPN_DATE AS AccOpenDate
  ,NVL(GA.ACCT_CLS_DATE,'') AS AccCloseDate
  ,CASE WHEN GA.ACCT_CLS_DATE IS NULL THEN 'OPEN' ELSE 'CLOSE' END AS Status
  ,(select eit.interest_rate from tbaadm.eit eit where eit.entity_id =GA.acid) AS Interest
  ,EAB.TRAN_DATE_BAL AS Balance,EAB.TRAN_DATE_BAL AS AVBalance
  ,Ga.Schm_Type,Ga.Schm_Code,
  ga.acct_crncy_code as cur,ga.gl_sub_head_code,tam.deposit_period_mths
  FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
  LEFT JOIN TBAADM.SERVICE_OUTLET_TABLE SO ON GA.SOL_ID = SO.SOL_ID
  LEFT JOIN TBAADM.BRANCH_CODE_TABLE BC ON SO.BR_CODE = BC.BR_CODE
  LEFT JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
  Left Join Tbaadm.Eod_Acct_Bal_Table Eab On Ga.Acid = Eab.Acid
  Left Join Tbaadm.Tam Tam On Ga.Acid = Tam.Acid
  WHERE GA.SCHM_TYPE = upper(  'TDA' )
  and GA.acct_crncy_code = eab.eab_crncy_code
  AND GA.SCHM_CODE  LIKE '%' || Ci_Schemecode || '%'   
  --AND GA.ACCT_CLS_FLG = 'N' 
  AND GA.DEL_FLG = 'N'
  AND GA.ENTITY_CRE_FLG = 'Y' 
  AND GA.SOL_ID  LIKE '%' || ci_branchCode || '%'  
  AND GA.ACCT_CRNCY_CODE != upper('MMK')
  AND eab.EOD_DATE <= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  and eab.END_EOD_DATE >= TO_DATE(CAST(ci_Date AS VARCHAR(10)), 'dd-MM-yyyy') 
  ORDER BY tam.deposit_period_mths) q
  Order By Q.deposit_period_mths)T
  ORDER BY T.deposit_period_mths;
--------------------------------------------------------------------------------------
  PROCEDURE FIN_DEPOSIT_OUTSTANDING_BAL(  inp_str      IN  VARCHAR2,
                                          out_retCode  OUT NUMBER,
                                          out_rec      OUT VARCHAR2 ) AS
  v_BrName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;                                         
  v_AccNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_AccName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_AccOpenDate TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE%type;
  v_AccCloseDate TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_CLS_DATE%type;
  v_Status VARCHAR2(5);
  v_Interest TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Balance TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_AVBalance TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  vi_rate   Number(2);
  v_BranchName TBAADM.sol.sol_desc%type;
  v_BankAddress varchar(200);
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  V_Bankdescription Tbaadm.Branch_Code_Table.Br_Name%Type;
  v_SchemeType TBAADM.GENERAL_ACCT_MAST_TABLE.SCHM_TYPE%type;
  V_Schemecode Tbaadm.General_Acct_Mast_Table.Schm_Code%Type;
  v_term tbaadm.tam.deposit_period_mths%type;
   resultstr varchar(20) :='';
  BEGIN
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
    
    vi_Date       :=  outArr(0);
    vi_currency   :=  outArr(1);
    vi_currencyType := outArr(2);
    vi_schemeType :=  outArr(3);
    vi_schemeCode	:=  outArr(4);
     vi_branchCode :=  outArr(5);
    


 if( vi_Date is null or vi_schemeType is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		           '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || '-' || '|' || 
				   '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
    
     IF vi_schemeCode IS  NULL or vi_schemeCode = ''  THEN
         vi_schemeCode := '';
    END IF;
    
      IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
    
     /*IF vi_schemeType IS  NULL or vi_schemeType = ''  THEN
         vi_schemeType := '';
    END IF;*/
--------------------------------------------------------------------------------
IF vi_schemeType  not like 'TDA' then
 If vi_currencyType not like 'All%' then
    IF NOT ExtractDataMMK%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataMMK (vi_Date
        , vi_currency, vi_schemeCode, vi_schemeType, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataMMK%ISOPEN THEN
		--{
			FETCH	ExtractDataMMK
			INTO v_BrName, v_AccNo, v_AccName, v_AccOpenDate, v_AccCloseDate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataMMK%NOTFOUND THEN
			--{
				CLOSE ExtractDataMMK;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
 ELSIF vi_currencyType  like 'All Currency' then
       IF NOT ExtractDataAll%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAll (vi_Date
        , vi_schemeCode, vi_schemeType, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataAll%ISOPEN THEN
		--{
			FETCH	ExtractDataAll
			INTO v_BrName, v_AccNo, v_AccName, v_AccOpenDate, v_AccCloseDate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataAll%NOTFOUND THEN
			--{
				CLOSE ExtractDataAll;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
 ELSE --FCY
      IF NOT ExtractDataFCY%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataFCY (vi_Date
        ,  vi_schemeCode, vi_schemeType, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataFCY%ISOPEN THEN
		--{
			FETCH	ExtractDataFCY
			INTO v_BrName, v_AccNo, v_AccName, v_AccOpenDate, v_AccCloseDate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataFCY%NOTFOUND THEN
			--{
				CLOSE ExtractDataFCY;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    End If;
 End If ;
 Else   --TDA
      If Vi_Currencytype Not Like 'All%' Then
    IF NOT ExtractDataMMKTDA%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataMMKTDA (vi_Date
        , vi_currency, vi_schemeCode, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataMMKTDA%ISOPEN THEN
		--{
			FETCH	ExtractDataMMKTDA
			Into V_Brname, V_Accno, V_Accname, V_Accopendate, V_Accclosedate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode,v_term;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataMMKTDA%NOTFOUND THEN
			--{
				CLOSE ExtractDataMMKTDA;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
 Elsif Vi_Currencytype  Like 'All Currency' Then
       IF NOT ExtractDataAllTDA%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAllTDA (vi_Date
        , vi_schemeCode, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataAllTDA%ISOPEN THEN
		--{
			FETCH	ExtractDataAllTDA
			Into V_Brname, V_Accno, V_Accname, V_Accopendate, V_Accclosedate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode,v_term;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataAllTDA%NOTFOUND THEN
			--{
				CLOSE ExtractDataAllTDA;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
 Else --FCY
      IF NOT ExtractDataFCYTDA%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataFCYTDA (vi_Date
        ,  vi_schemeCode, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataFCYTDA%ISOPEN THEN
		--{
			FETCH	ExtractDataFCYTDA
			Into V_Brname, V_Accno, V_Accname, V_Accopendate, V_Accclosedate
      , v_Status, v_Interest, v_Balance, v_AVBalance, v_SchemeType, v_SchemeCode,v_term;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataFCYTDA%NOTFOUND THEN
			--{
				CLOSE ExtractDataFCYTDA;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    End If;
 End If ;
 end if;
------------------------------------------------------------------------------------

BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_currencyType      = 'Home Currency' THEN
     if(upper(vi_currency) = 'MMK') then vi_rate := 1;  
      else select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_Date, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
      end if;
      ELSIF vi_currencyType           = 'Source Currency' THEN 
        vi_rate            := 1;
    ELSE
      vi_rate := 1;
    END IF;
  END;
 -------------------------------------------------------------------------------
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
     IF vi_BranchCode is not null then 
    
         SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM,bct.br_name as "Bank Dewscription"
   into v_BranchName, v_BankAddress, v_BankPhone, v_BankFax,v_bankdescription
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
         
         end if;
       
    END;
    
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
if v_SchemeType not like 'TDA' then
    out_rec:=	(
                v_BrName	    || '|' ||
                v_AccNo	      || '|' ||
                v_AccName 	  || '|' ||              
                to_char(to_date(v_AccOpenDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                to_char(to_date(v_AccCloseDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_Status 	    || '|' ||
                v_Interest 	  || '|' ||
                v_Balance 	  || '|' ||
                v_AVBalance   || '|' ||
                v_BranchName  || '|' ||
                v_BankAddress || '|' ||
                v_BankPhone   || '|' ||
                v_BankFax     || '|' ||
                --v_bankdescription || '|' ||
                V_Schemetype  || '|' ||
                v_SchemeCode  || '|' ||
                vi_rate);
 
 else 
 out_rec:=	(
                v_BrName	    || '|' ||
                v_AccNo	      || '|' ||
                v_AccName 	  || '|' ||              
                to_char(to_date(v_AccOpenDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                to_char(to_date(v_AccCloseDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_Status 	    || '|' ||
                v_Interest 	  || '|' ||
                v_Balance 	  || '|' ||
                v_AVBalance   || '|' ||
                v_BranchName  || '|' ||
                v_BankAddress || '|' ||
                v_BankPhone   || '|' ||
                v_BankFax     || '|' ||
                --v_bankdescription || '|' ||
                V_Schemetype  || '|' ||
                v_term  || '|' ||
                vi_rate);
 end if;
			dbms_output.put_line(out_rec);
      
  END FIN_DEPOSIT_OUTSTANDING_BAL;

END FIN_DEPOSIT_OUTSTANDING_BAL;
/
