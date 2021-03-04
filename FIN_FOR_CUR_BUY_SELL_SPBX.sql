CREATE OR REPLACE PACKAGE        FIN_FOR_CUR_BUY_SELL_SPBX AS 

  PROCEDURE FIN_FOR_CUR_BUY_SELL_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FOR_CUR_BUY_SELL_SPBX;
 
/


CREATE OR REPLACE PACKAGE BODY                                    FIN_FOR_CUR_BUY_SELL_SPBX AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_solId        varchar2(5);
  
  CURSOR ExtractDataByBranch (	ci_startDate VARCHAR2, ci_endDate VARCHAR2,
  ci_solId VARCHAR2)
  IS
  select 
  b_usd.usd_date AS CUR_DATE,
  b_usd.usd_amt AS USD_BUYING, 
  b_eur.eur_amt AS EUR_BUYING,
  b_sgd.sgd_amt AS SGD_BUYING,
  b_thb.thb_amt AS THB_BUYING,
  b_myr.myr_amt AS MYR_BUYING,
  b_jpy.jpy_amt AS JPY_BUYING,
  s_usd.usd_amt AS USD_SELLING,
  s_eur.eur_amt AS EUR_SELLING,
  s_sgd.sgd_amt AS SGD_SELLING,
  s_thb.thb_amt AS THB_SELLING,
  s_myr.myr_amt AS MYR_SELLING,
  s_jpy.jpy_amt AS JPY_SELLING from
(SELECT 
  sum(CDCM.tran_amt) as usd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as usd_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'USD'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_usd
  left join
  (SELECT 
  sum(CDCM.tran_amt) as usd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as usd_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'USD'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_usd
  on b_usd.usd_date = s_usd.usd_date
  LEFT JOIN
  (SELECT 
  sum(CDCM.tran_amt) as eur_amt, to_char(CDCM.tran_date, 'MON, YYYY') as eur_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'EUR'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_eur
  on b_usd.usd_date = b_eur.eur_date
  LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as eur_amt, to_char(CDCM.tran_date, 'MON, YYYY') as eur_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'EUR'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_eur
    on b_usd.usd_date = s_eur.eur_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as sgd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'SGD'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_sgd
    on b_usd.usd_date = b_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as sgd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'SGD'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_sgd
    on b_usd.usd_date = s_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as thb_amt, to_char(CDCM.tran_date, 'MON, YYYY') as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'THB'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_thb
    on b_usd.usd_date = b_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as thb_amt, to_char(CDCM.tran_date, 'MON, YYYY') as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'THB'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_thb
    on b_usd.usd_date = s_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as jpy_amt, to_char(CDCM.tran_date, 'MON, YYYY') as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'JPY'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_jpy
    on b_usd.usd_date = b_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as jpy_amt, to_char(CDCM.tran_date, 'MON, YYYY') as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'JPY'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_jpy
    on b_usd.usd_date = s_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as myr_amt, to_char(CDCM.tran_date, 'MON, YYYY') as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'MYR'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_myr
    on b_usd.usd_date = b_myr.myr_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as myr_amt, to_char(CDCM.tran_date, 'MON, YYYY') as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'MYR'
  AND CDCM.BANK_ID = '01'
  AND GAM.SOL_ID = ci_solId   
  AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_myr
    on b_usd.usd_date = s_myr.myr_date;
    
    CURSOR ExtractData (	ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
  select 
  b_usd.usd_date AS CUR_DATE,
  b_usd.usd_amt AS USD_BUYING, 
  b_eur.eur_amt AS EUR_BUYING,
  b_sgd.sgd_amt AS SGD_BUYING,
  b_thb.thb_amt AS THB_BUYING,
  b_myr.myr_amt AS MYR_BUYING,
  b_jpy.jpy_amt AS JPY_BUYING,
  s_usd.usd_amt AS USD_SELLING,
  s_eur.eur_amt AS EUR_SELLING,
  s_sgd.sgd_amt AS SGD_SELLING,
  s_thb.thb_amt AS THB_SELLING,
  s_myr.myr_amt AS MYR_SELLING,
  s_jpy.jpy_amt AS JPY_SELLING from
(SELECT 
  sum(CDCM.tran_amt) as usd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as usd_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'USD'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_usd
  left join
  (SELECT 
  sum(CDCM.tran_amt) as usd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as usd_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'USD'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_usd
  on b_usd.usd_date = s_usd.usd_date
  LEFT JOIN
  (SELECT 
  sum(CDCM.tran_amt) as eur_amt, to_char(CDCM.tran_date, 'MON, YYYY') as eur_date
FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
WHERE 
  FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'EUR'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_eur
  on b_usd.usd_date = b_eur.eur_date
  LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as eur_amt, to_char(CDCM.tran_date, 'MON, YYYY') as eur_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'EUR'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_eur
    on b_usd.usd_date = s_eur.eur_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as sgd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'SGD'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_sgd
    on b_usd.usd_date = b_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as sgd_amt, to_char(CDCM.tran_date, 'MON, YYYY') as sgd_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'SGD'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_sgd
    on b_usd.usd_date = s_sgd.sgd_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as thb_amt, to_char(CDCM.tran_date, 'MON, YYYY') as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'THB'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_thb
    on b_usd.usd_date = b_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as thb_amt, to_char(CDCM.tran_date, 'MON, YYYY') as thb_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'THB'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_thb
    on b_usd.usd_date = s_thb.thb_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as jpy_amt, to_char(CDCM.tran_date, 'MON, YYYY') as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'JPY'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_jpy
    on b_usd.usd_date = b_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as jpy_amt, to_char(CDCM.tran_date, 'MON, YYYY') as jpy_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'JPY'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_jpy
    on b_usd.usd_date = s_jpy.jpy_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as myr_amt, to_char(CDCM.tran_date, 'MON, YYYY') as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'B'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'MYR'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) b_myr
    on b_usd.usd_date = b_myr.myr_date
    LEFT JOIN
    (SELECT 
  sum(CDCM.tran_amt) as myr_amt, to_char(CDCM.tran_date, 'MON, YYYY') as myr_date
  FROM 
  CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
  WHERE 
    FOREIGN_EXCHANGE = 'S'
  AND CDCM.tran_date between to_date((to_char(to_date(cast
      (ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')),'MM-YYYY') AND
      LAST_DAY(TO_DATE(ci_endDate,'DD-MM-YYYY'))
  AND CDCM.REF_CRNCY_CODE = 'MYR'
  AND CDCM.BANK_ID = '01'
  --AND GAM.SOL_ID = ci_solId   AND CDCM.DEBIT_FORACID =  GAM.FORACID
  group by to_char(CDCM.tran_date, 'MON, YYYY')) s_myr
    on b_usd.usd_date = s_myr.myr_date;

  PROCEDURE FIN_FOR_CUR_BUY_SELL_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_date varchar2(20);
      v_usdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_sgdBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_eurBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_thbBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_myrBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_jpyBuyAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_usdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_sgdSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_eurSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_thbSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_myrSellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      v_jpySellAmt CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
      
  BEGIN
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);		
    vi_solId      :=  outArr(2);
 
 ------------------------------------------------------------------------------------
 
 if( vi_startDate is null or vi_endDate is null or vi_solId is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 
		            
                   0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||  0  || '|' ||  0  || '|' ||
		          
				   0 || '|' || 0 || '|' || 0 );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 --------------------------------------------------------------------------------------
 
    
    IF vi_solId is not null then
    IF NOT ExtractDataByBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataByBranch (vi_startDate , vi_endDate, vi_solId);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataByBranch%ISOPEN THEN
		--{
			FETCH	ExtractDataByBranch
			INTO	v_date,v_usdBuyAmt,
            v_sgdBuyAmt,v_eurBuyAmt,v_thbBuyAmt,v_myrBuyAmt,v_jpyBuyAmt,
            v_usdSellAmt,v_sgdSellAmt,v_eurSellAmt,v_thbSellAmt,
            v_myrSellAmt,v_jpySellAmt;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataByBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataByBranch;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    ELSE
      IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_startDate , vi_endDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_date,v_usdBuyAmt,
            v_sgdBuyAmt,v_eurBuyAmt,v_thbBuyAmt,v_myrBuyAmt,v_jpyBuyAmt,
            v_usdSellAmt,v_sgdSellAmt,v_eurSellAmt,v_thbSellAmt,
            v_myrSellAmt,v_jpySellAmt;
      

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
    END IF;
    
    out_rec:=	(v_date||'|'||v_usdBuyAmt||'|'||
              v_sgdBuyAmt||'|'||v_eurBuyAmt||'|'||
              v_thbBuyAmt||'|'||v_myrBuyAmt||'|'||
              v_jpyBuyAmt||'|'||v_usdSellAmt||'|'||
              v_sgdSellAmt||'|'||v_eurSellAmt||'|'||
              v_thbSellAmt||'|'||
              v_myrSellAmt||'|'||v_jpySellAmt);
  
			dbms_output.put_line(out_rec);
    
  END FIN_FOR_CUR_BUY_SELL_SPBX;

END FIN_FOR_CUR_BUY_SELL_SPBX;
/
