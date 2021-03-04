CREATE OR REPLACE PACKAGE               FIN_IBS_OUTSTANDING_BALANCE AS 

  PROCEDURE FIN_IBS_OUTSTANDING_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_IBS_OUTSTANDING_BALANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                         FIN_IBS_OUTSTANDING_BALANCE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	        	Varchar2(3);               -- Input to procedure
	vi_TransactionDate		Varchar2(10);		    	    -- Input to procedure
  --vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_currencyType       VARCHAR2(20);
  vi_rate decimal;
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--(1) CURSOR ExtractData(include Branch_code)
-----------------------------------------------------------------------------
CURSOR ExtractDataMMK (	
			ci_TransactionDate VARCHAR2, 
      ci_currency VARCHAR2,ci_branchCode VARCHAR2)
  IS
  
  
    SELECT    sum(q.Dr_General),sum(q.Cr_General),
              sum(q.Dr_Currency),sum(q.Cr_Currency),
              sum(q.Dr_FCY),sum(q.Cr_FCY),
              sum(q.Dr_Remittance),sum(q.Cr_Remittance),
              sum(q.Dr_Online),sum(q.Cr_Online),
              sum(q.Dr_PO),sum(q.Cr_PO),
              sum(q.Dr_GC),sum(q.Cr_GC),
              q.sol_id  AS "SolId"
              , bct.br_name as "Branch"
    FROM(
          SELECT gstt.sol_id,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_DR_BAL else 0 end as Dr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_CR_BAL else 0 end as Cr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_DR_BAL else 0 end as Dr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_CR_BAL else 0 end as Cr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_DR_BAL else 0 end as Dr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_CR_BAL else 0 end as Cr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_DR_BAL else 0 end as Dr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_CR_BAL else 0 end as Cr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_DR_BAL else 0 end as Dr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_CR_BAL else 0 end as Cr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_DR_BAL else 0 end as Dr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_CR_BAL else 0 end as Cr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_DR_BAL else 0 end as Dr_GC,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_CR_BAL else 0 end as Cr_GC
        
          
          FROM tbaadm.gstt  gstt
          WHERE gstt.bal_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND gstt.CRNCY_CODE = UPPER(ci_currency)
          AND gstt.SOL_ID  LIKE '%' || ci_branchCode || '%'   
          AND gstt.DEL_FLG = 'N'
          AND gstt.GL_SUB_HEAD_CODE in ('60001' ,'60031','60011','60050','60041','60161','60211')
          )q,
          TBAADM.BRANCH_CODE_TABLE bct
      WHERE  bct.MICR_Branch_CODE = SUBSTR(q.sol_id,1,3)  
      AND bct.BANK_CODE = '116'
      AND bct.DEL_FLG = 'N'
      GROUP BY q.sol_id, bct.br_name;

-----------------------------------------------------------------------------
--(2) CURSOR ExtractData(Not Include Branch_code)
-----------------------------------------------------------------------------
CURSOR ExtractDataAll (	
			ci_TransactionDate VARCHAR2, 
      ci_branchCode VARCHAR2)
  IS
  
  
   SELECT    sum(T.Dr_General),sum(T.Cr_General),
              sum(T.Dr_Currency),sum(T.Cr_Currency),
              sum(T.Dr_FCY),sum(T.Cr_FCY),
              sum(T.Dr_Remittance),sum(T.Cr_Remittance),
              sum(T.Dr_Online),sum(T.Cr_Online),
              sum(T.Dr_PO),sum(T.Cr_PO),
              sum(T.Dr_GC),sum(T.Cr_GC),
              T.sol_id  AS "SolId"
              , bct.br_name as "Branch"
    FROM(
     select q.sol_id,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_General
      ELSE q.Dr_General * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_General,
        CASE WHEN q.cur = 'MMK' THEN q.Cr_General
      ELSE q.Cr_General * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_General,
       CASE WHEN q.cur = 'MMK' THEN q.Dr_Currency
      ELSE q.Dr_Currency * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Currency,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Currency
      ELSE q.Cr_Currency * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Currency,
       CASE WHEN q.cur = 'MMK' THEN q.Dr_FCY
      ELSE q.Dr_FCY * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_FCY,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_FCY
      ELSE q.Cr_FCY * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_FCY,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_Remittance
      ELSE q.Dr_Remittance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Remittance,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Remittance
      ELSE q.Cr_Remittance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Remittance,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_Online
      ELSE q.Dr_Online * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Online,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Online
      ELSE q.Cr_Online * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Online,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_PO
      ELSE q.Dr_PO * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_PO,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_PO
      ELSE q.Cr_PO * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_PO,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_GC
      ELSE q.Dr_GC * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_GC,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_GC
      ELSE q.Cr_GC * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_GC
      from 
          (SELECT gstt.sol_id,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_DR_BAL else 0 end as Dr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_CR_BAL else 0 end as Cr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_DR_BAL else 0 end as Dr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_CR_BAL else 0 end as Cr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_DR_BAL else 0 end as Dr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_CR_BAL else 0 end as Cr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_DR_BAL else 0 end as Dr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_CR_BAL else 0 end as Cr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_DR_BAL else 0 end as Dr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_CR_BAL else 0 end as Cr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_DR_BAL else 0 end as Dr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_CR_BAL else 0 end as Cr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_DR_BAL else 0 end as Dr_GC,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_CR_BAL else 0 end as Cr_GC,
          gstt.crncy_code as cur
          
          FROM tbaadm.gstt  gstt
          WHERE gstt.bal_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          --AND gstt.CRNCY_CODE = UPPER('MMK')
          AND gstt.SOL_ID  LIKE '%' || ci_branchCode || '%'   
          AND gstt.DEL_FLG = 'N'
          AND gstt.GL_SUB_HEAD_CODE in ('60001' ,'60031','60011','60050','60041','60161','60211'))q
          )T,
          TBAADM.BRANCH_CODE_TABLE bct
      WHERE  bct.MICR_Branch_CODE = SUBSTR(T.sol_id,1,3)  
      AND bct.BANK_CODE = '116'
      AND bct.DEL_FLG = 'N'
      GROUP BY T.sol_id, bct.br_name;
      
-------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataFCY (	
			ci_TransactionDate VARCHAR2, 
      ci_branchCode VARCHAR2) IS
SELECT    sum(T.Dr_General),sum(T.Cr_General),
              sum(T.Dr_Currency),sum(T.Cr_Currency),
              sum(T.Dr_FCY),sum(T.Cr_FCY),
              sum(T.Dr_Remittance),sum(T.Cr_Remittance),
              sum(T.Dr_Online),sum(T.Cr_Online),
              sum(T.Dr_PO),sum(T.Cr_PO),
              sum(T.Dr_GC),sum(T.Cr_GC),
              T.sol_id  AS "SolId"
              , bct.br_name as "Branch"
    FROM(
     select q.sol_id,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_General
      ELSE q.Dr_General * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_General,
        CASE WHEN q.cur = 'MMK' THEN q.Cr_General
      ELSE q.Cr_General * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_General,
       CASE WHEN q.cur = 'MMK' THEN q.Dr_Currency
      ELSE q.Dr_Currency * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Currency,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Currency
      ELSE q.Cr_Currency * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Currency,
       CASE WHEN q.cur = 'MMK' THEN q.Dr_FCY
      ELSE q.Dr_FCY * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_FCY,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_FCY
      ELSE q.Cr_FCY * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_FCY,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_Remittance
      ELSE q.Dr_Remittance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Remittance,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Remittance
      ELSE q.Cr_Remittance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Remittance,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_Online
      ELSE q.Dr_Online * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_Online,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_Online
      ELSE q.Cr_Online * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_Online,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_PO
      ELSE q.Dr_PO * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_PO,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_PO
      ELSE q.Cr_PO * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_PO,
      CASE WHEN q.cur = 'MMK' THEN q.Dr_GC
      ELSE q.Dr_GC * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Dr_GC,
      CASE WHEN q.cur = 'MMK' THEN q.Cr_GC
      ELSE q.Cr_GC * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK'
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'FOREIGN_CURRENCY'
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cr_GC
      from 
          (SELECT gstt.sol_id,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_DR_BAL else 0 end as Dr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60001'  then gstt.TOT_CR_BAL else 0 end as Cr_General,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_DR_BAL else 0 end as Dr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60031'  then gstt.TOT_CR_BAL else 0 end as Cr_Currency,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_DR_BAL else 0 end as Dr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60011'  then gstt.TOT_CR_BAL else 0 end as Cr_FCY,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_DR_BAL else 0 end as Dr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60050'  then gstt.TOT_CR_BAL else 0 end as Cr_Remittance,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_DR_BAL else 0 end as Dr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60041'  then gstt.TOT_CR_BAL else 0 end as Cr_Online,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_DR_BAL else 0 end as Dr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60161'  then gstt.TOT_CR_BAL else 0 end as Cr_PO,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_DR_BAL else 0 end as Dr_GC,
          case  when GSTT.GL_SUB_HEAD_CODE = '60211'  then gstt.TOT_CR_BAL else 0 end as Cr_GC,
          gstt.crncy_code as cur
          
          FROM tbaadm.gstt  gstt
          WHERE gstt.bal_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND gstt.CRNCY_CODE != UPPER('MMK')
          AND gstt.SOL_ID  LIKE '%' || ci_branchCode || '%'   
          AND gstt.DEL_FLG = 'N'
          AND gstt.GL_SUB_HEAD_CODE in ('60001' ,'60031','60011','60050','60041','60161','60211'))q
          )T,
          TBAADM.BRANCH_CODE_TABLE bct
      WHERE  bct.MICR_Branch_CODE = SUBSTR(T.sol_id,1,3)  
      AND bct.BANK_CODE = '116'
      AND bct.DEL_FLG = 'N'
      GROUP BY T.sol_id, bct.br_name;
      
     


------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_IBS_OUTSTANDING_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_GeneralDr        TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_GeneralCr        TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_CurrencyDr       TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_CurrencyCr       TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_FCYDr            TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_FCYCr            TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_RemittanceDr     TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_RemittanceCr     TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_OnlineDr         TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_OnlineCr         TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_PODr             TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_POCr             TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_GCDr             TBAADM.GSTT.TOT_DR_BAL%TYPE;
      v_GCCr             TBAADM.GSTT.TOT_CR_BAL%TYPE;
      v_Sol              TBAADM.GSTT.SOL_ID%TYPE;
      v_Branch           TBAADM.BRANCH_CODE_TABLE.BR_NAME%TYPE;
      v_BranchName       TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
      v_BankAddress      TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
      v_BankPhone        TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax          TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      
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
    
    vi_TransactionDate  :=  outArr(0);		
    vi_currency         :=  outArr(1);
    vi_currencyType     :=  outArr(2);
    vi_branchCode       :=  outArr(3);
  
  --------------------------------------------------------------------------------------
  
  if( vi_TransactionDate is null or vi_currencyType is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||
		          '-' || '|' || '-' || '|' || '-' || '|' ||
		          '-' || '|' || '-' || '|' || '-' );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  
  ---------------------------------------------------------------------------------------

     IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
----------------------------------------------------------------------------------  
  /* IF vi_branchCode is not null then  ----for each branch code
      IF vi_currencyType not like 'All%' THEN ------------Home Currency 
      --{*/
        IF vi_currencyType not like 'All%' then 
        IF NOT ExtractDataMMK%ISOPEN THEN
        --{
          BEGIN
          --{
            
            OPEN ExtractDataMMK (	
               vi_TransactionDate, vi_currency ,vi_branchCode);
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractDataMMK%ISOPEN THEN
        --{
          FETCH	ExtractDataMMK
          INTO	 v_GeneralDr,v_GeneralCr,v_CurrencyDr,v_CurrencyCr,v_FCYDr,v_FCYCr,
                v_RemittanceDr,v_RemittanceCr,v_OnlineDr,v_OnlineCr,v_PODr,v_POCr,v_GCDr,v_GCCr,
                v_Sol,v_Branch;
          
    
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractDataMMK%NOTFOUND THEN
          --{
            CLOSE ExtractDataMMK;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
   ELSIF vi_currencyType  = 'All Currency' then
        IF NOT ExtractDataAll%ISOPEN THEN
        --{
          BEGIN
          --{
            
            OPEN ExtractDataAll (	
               vi_TransactionDate,vi_branchCode);
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractDataAll%ISOPEN THEN
        --{
          FETCH	ExtractDataAll
          INTO	 v_GeneralDr,v_GeneralCr,v_CurrencyDr,v_CurrencyCr,v_FCYDr,v_FCYCr,
                v_RemittanceDr,v_RemittanceCr,v_OnlineDr,v_OnlineCr,v_PODr,v_POCr,v_GCDr,v_GCCr,
                v_Sol,v_Branch;
          
    
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractDataAll%NOTFOUND THEN
          --{
            CLOSE ExtractDataAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
   ELSE ---All Currency(FCY)
      IF NOT ExtractDataFCY%ISOPEN THEN
        --{
          BEGIN
          --{
            
            OPEN ExtractDataFCY (	
               vi_TransactionDate,vi_branchCode);
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractDataFCY%ISOPEN THEN
        --{
          FETCH	ExtractDataFCY
          INTO	 v_GeneralDr,v_GeneralCr,v_CurrencyDr,v_CurrencyCr,v_FCYDr,v_FCYCr,
                v_RemittanceDr,v_RemittanceCr,v_OnlineDr,v_OnlineCr,v_PODr,v_POCr,v_GCDr,v_GCCr,
                v_Sol,v_Branch;
          
    
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractDataFCY%NOTFOUND THEN
          --{
            CLOSE ExtractDataFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
   END IF;
      

--------------------------------------------------------------------------------
IF vi_currencyType = 'Home Currency' then
 IF (upper(vi_currency) = 'MMK') then vi_rate := 1;  
             ELSE SELECT  VAR_CRNCY_UNITS into vi_rate
                   FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(vi_currency) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                  and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                                  where module_name = 'FOREIGN_CURRENCY' 
                                  and variable_name = 'RATE_CODE');
             END IF;
ELSIF vi_currencyType = 'Source Currency' then
    vi_rate := 1;
ELSE
   vi_rate := 1;
END IF;
--------------------------------------------------------------------------------
    BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
    IF vi_branchCode is not null then 
      select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
         END IF;
    END;
  
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_GeneralDr     		|| '|' ||
					v_GeneralCr	        || '|' ||
					v_CurrencyDr      	|| '|' ||
          v_CurrencyCr 			  || '|' ||
          v_FCYDr    		      || '|' ||
          v_FCYCr    			    || '|' ||
          v_RemittanceDr     	|| '|' ||
					v_RemittanceCr	    || '|' ||
					v_OnlineDr        	|| '|' ||
          v_OnlineCr 			    || '|' ||
          v_PODr    		      || '|' ||
          v_POCr    			    || '|' ||
          v_GCDr      	      || '|' ||
          v_GCCr 			        || '|' ||
          v_Sol    		        || '|' ||
          v_Branch    			  || '|' ||
          v_BranchName      	|| '|' ||
          v_BankAddress 			|| '|' ||
          v_BankPhone    		  || '|' ||
          v_BankFax    			  
				 );
  
			dbms_output.put_line(out_rec);
  END FIN_IBS_OUTSTANDING_BALANCE;

END FIN_IBS_OUTSTANDING_BALANCE;
/
