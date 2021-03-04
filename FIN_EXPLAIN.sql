CREATE OR REPLACE PACKAGE                              FIN_EXPLAIN AS 

   PROCEDURE FIN_EXPLAIN(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_EXPLAIN;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                              FIN_EXPLAIN AS
---------------------------------------------------------
--Update User - Saung Hnin Oo
--Update Date - 23-3-2017
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_tranDate		Varchar2(10);		    	    -- Input to procedure
  vi_type Varchar2(50);		    	    -- Input to procedure
  vi_currency	   	Varchar2(3);               -- Input to procedure
  vi_branchcode  Varchar2(5);           -- Input to procedure
  vi_currencyType Varchar2(20); 
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData_LoanWithMMK (ci_tranDate VARCHAR2,ci_currency VARCHAR2,ci_branchCode VARCHAR2)  IS
  select 
  sum(q.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(q.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(q.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(q.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(q.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(q.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  q.name,
  q.sol_desc,
   q.foracid ,
  q.industry_type
  from
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  cim.name,
  sol.sol_desc,
  gam.foracid ,
  gac.industry_type
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  crmuser.accounts cim,
  TBAADM.SERVICE_OUTLET_TABLE sol,
  TBAADM.GAC gac
  where 
  gam.acid = cdav.acid
  and gam.acid = gac.acid
  and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and cdav.TRAN_CRNCY_CODE= Upper(ci_currency )
  and gam.SOL_ID like '%' || ci_branchCode || '%'
  and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
 and (gam.schm_type like 'LAA'
  or gam.schm_code like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q
  group by q.sol_desc,q.name,q.foracid,q.industry_type
  order by q.sol_desc,q.foracid;
  --------------------for Business type
--select * from tbaadm.cid where acid not like '!';
--select * from tbaadm.scmt;
--select * from tbaadm.sip;
  ---------------------------------------------
CURSOR ExtractData_LoanWithAll (ci_tranDate VARCHAR2,ci_branchCode VARCHAR2)  IS
  select 
  sum(T.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(T.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(T.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(T.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(T.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(T.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  T.name,
  T.sol_desc,T.foracid,T.industry_type
  from
  (select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Dr_Amt 
      ELSE q.Clearing_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Cr_Amt 
      ELSE q.Clearing_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Cr_Amt,
    q.name,
    q.sol_desc,q.foracid,q.industry_type
  from 
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  cim.name,
  sol.sol_desc,
  gam.acct_crncy_code as cur,
  gam.foracid,
  gac.industry_type
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  crmuser.accounts cim,
  TBAADM.SERVICE_OUTLET_TABLE sol,
  TBAADM.gac gac
  
  where 
  gam.acid = cdav.acid
  and gam.acid = gac.acid
  and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST (ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  --and cdav.TRAN_CRNCY_CODE= Upper(ci_currency )
  and gam.SOL_ID like '%' || ci_branchCode || '%'
   and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and (gam.schm_type like 'LAA'
  or gam.schm_code like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q)T
  group by T.sol_desc,T.name,T.foracid,T.industry_type
  order by T.sol_desc,T.foracid; 
  ---------------------------------------------
CURSOR ExtractData_LoanWithAllFCY (ci_tranDate VARCHAR2,ci_branchCode VARCHAR2)  IS
  select 
  sum(T.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(T.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(T.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(T.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(T.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(T.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  T.name,
  T.sol_desc,
  T.foracid,
  T.industry_type
  from
  (select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Dr_Amt 
      ELSE q.Clearing_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Cr_Amt 
      ELSE q.Clearing_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Cr_Amt,
    q.name,
    q.sol_desc,
    q.foracid,
  q.industry_type
  from 
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  cim.name,
  sol.sol_desc,
  gam.acct_crncy_code as cur,
  gam.foracid,
  gac.industry_type
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  crmuser.accounts cim,
  TBAADM.SERVICE_OUTLET_TABLE sol,
  TBAADM.gac
  where 
  gam.acid = cdav.acid
  and gam.acid = gac.acid
  and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and cdav.TRAN_CRNCY_CODE != Upper('MMK')
  and gam.SOL_ID like '%' || ci_branchCode || '%'
  and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and (gam.schm_type like 'LAA'
  or gam.schm_code like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q)T
  group by T.sol_desc,T.name,T.foracid,
  T.industry_type
  order by T.sol_desc,T.foracid;  
  
----------------------------------------------------------------------------------------------------------------------------
  
  CURSOR ExtractData_DepositWithMMK (ci_tranDate VARCHAR2,ci_currency VARCHAR2,ci_branchCode VARCHAR2)  IS
select
 sum(q.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(q.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(q.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(q.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(q.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(q.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  q.name,
  q.sol_desc,
   q.foracid
  from
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  gam.acct_name as name,
  sol.sol_desc,
   gam.foracid
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  TBAADM.SERVICE_OUTLET_TABLE sol
  where 
  gam.acid = cdav.acid
 -- and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and cdav.TRAN_CRNCY_CODE= Upper(ci_currency )
  and gam.SOL_ID like '%' || ci_branchCode || '%'
  and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and (gam.schm_type not like 'LAA'
  or gam.schm_code not like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q
  group by q.sol_desc,q.name, q.foracid
  order by q.sol_desc, q.foracid;
-------------------------
CURSOR ExtractData_DepositWithAll (ci_tranDate VARCHAR2,ci_branchCode VARCHAR2)  IS
select 
  sum(T.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(T.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(T.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(T.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(T.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(T.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  T.name,
  T.sol_desc,
   T.foracid,
  T.industry_type
  from
  (select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Dr_Amt 
      ELSE q.Clearing_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Cr_Amt 
      ELSE q.Clearing_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Cr_Amt,
    q.name,
    q.sol_desc, q.foracid,
  q.industry_type
  from 
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  gam.acct_name as name,
  sol.sol_desc,
  gam.acct_crncy_code as cur,
   gam.foracid,
  gac.industry_type
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  TBAADM.SERVICE_OUTLET_TABLE sol,
  TBAADM.gac gac
  where 
  gam.acid = cdav.acid
   and gam.acid = gac.acid
  --and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  --and cdav.TRAN_CRNCY_CODE= Upper(ci_currency )
  and gam.SOL_ID like '%' || ci_branchCode || '%'
  and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and (gam.schm_type not like 'LAA'
  or gam.schm_code not like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q )T
  group by T.sol_desc,T.name, T.foracid,
  T.industry_type
  order by T.sol_desc,T.foracid;     
-------------------------
CURSOR ExtractData_DepositWithAllFCY (ci_tranDate VARCHAR2,ci_branchCode VARCHAR2)  IS
select 
  sum(T.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
  sum(T.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
  sum(T.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
  sum(T.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt,
  sum(T.Clearing_Dr_Amt)/1000000 as Clearing_Dr_Amt,
  sum(T.Clearing_Cr_Amt)/1000000 as Clearing_Cr_Amt,
  T.name,
  T.sol_desc,
   T.foracid,
  T.industry_type
  from
  (select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Cash_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Dr_Amt 
      ELSE q.Clearing_Dr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Clearing_Cr_Amt 
      ELSE q.Clearing_Cr_Amt * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS Clearing_Cr_Amt,
    q.name,
    q.sol_desc,
    q.foracid,
  q.industry_type
  from 
  (select 
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Transfer_Dr_Amt,
  case  cdav.Tran_type when 'T' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Transfer_Cr_Amt,                                 
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Cash_Dr_Amt,
  case  cdav.Tran_type when 'C' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Cash_Cr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end end as Clearing_Dr_Amt,
  case  cdav.Tran_type when 'L' then 
        case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end end as Clearing_Cr_Amt,
  cim.name,
  sol.sol_desc,
  gam.acct_crncy_code as cur,
   gam.foracid,
  gac.industry_type
  from 
  tbaadm.general_acct_mast_table gam,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
  crmuser.accounts cim,
  TBAADM.SERVICE_OUTLET_TABLE sol,
  TBAADM.gac gac
  where 
  gam.acid = cdav.acid
   and gam.acid = gac.acid
  and gam.cif_id = cim.orgkey
  and gam.sol_id = sol.sol_id
  and cdav.tran_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and cdav.TRAN_CRNCY_CODE != Upper('MMK')
  and gam.SOL_ID like '%' || ci_branchCode || '%'
  and cdav.TRAN_AMT >= 90000000
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and (gam.schm_type not like 'LAA'
  or gam.schm_code not like 'AGDOD')
  and gam.sol_id = cdav.sol_id
  ) q )T
  group by T.sol_desc,T.name, T.foracid,
  T.industry_type
  order by T.sol_desc,T.foracid;   
   
   
   --------------------------------------------------------
PROCEDURE FIN_EXPLAIN(	inp_str IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    Transfer_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Transfer_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Cash_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Cash_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Clearing_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Clearing_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    Customer_Name crmuser.accounts.name%type;
    Branch_Name TBAADM.SERVICE_OUTLET_TABLE.sol_desc%type;
     v_foracid tbaadm.general_acct_mast_table.foracid%type;
    v_industry_type  TBAADM.gac.industry_type%type;
    vi_rate tbaadm.RTL.VAR_CRNCY_UNITS%type;
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
    
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
    
    vi_tranDate  :=  outArr(0);
    vi_type  :=  outArr(1);
    vi_currency := outArr(2);
    vi_currencyType := outArr(3);
    vi_branchcode := outArr(4);
  
  ---------------------------------------------------------------------------
  if( vi_tranDate is null or vi_type is null or vi_currencyType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || '-' );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  ---------------------------------------------------------------------
  
  
  If vi_branchcode is null or vi_branchcode = '' then
     vi_branchcode := '';
  end If;
---------------------------------------------------------------------------------    
      IF vi_type like 'Loan%' then
    If vi_currencyType not like 'All%' then 
    IF NOT ExtractData_LoanWithMMK%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_LoanWithMMK (vi_tranDate,vi_currency,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_LoanWithMMK%ISOPEN Then
		--{
      Fetch ExtractData_LoanWithMMK into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid,v_industry_type;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_LoanWithMMK%NOTFOUND THEN
			--{
				CLOSE ExtractData_LoanWithMMK;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    
    ELSIf vi_currencyType like 'All Currency' then
    IF NOT ExtractData_LoanWithAll%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_LoanWithAll (vi_tranDate,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_LoanWithAll%ISOPEN Then
		--{
      Fetch ExtractData_LoanWithAll into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid,v_industry_type;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_LoanWithAll%NOTFOUND THEN
			--{
				CLOSE ExtractData_LoanWithAll;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    ELSE --for All FCY
    IF NOT ExtractData_LoanWithAllFCY%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_LoanWithAllFCY (vi_tranDate,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_LoanWithAllFCY%ISOPEN Then
		--{
      Fetch ExtractData_LoanWithAllFCY into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid,v_industry_type;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_LoanWithAllFCY%NOTFOUND THEN
			--{
				CLOSE ExtractData_LoanWithAllFCY;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    end if; -- currencytype
   
    ---------------------------
   ELSE --Deposit
    If vi_currencyType not like 'All%' then 
    IF NOT ExtractData_DepositWithMMK%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_DepositWithMMK (vi_tranDate,vi_currency,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_DepositWithMMK%ISOPEN Then
		--{
      Fetch ExtractData_DepositWithMMK into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_DepositWithMMK%NOTFOUND THEN
			--{
				CLOSE ExtractData_DepositWithMMK;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
  ELSIF vi_currencyType like 'All Currency' then 
    IF NOT ExtractData_DepositWithAll%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_DepositWithAll (vi_tranDate,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_DepositWithAll%ISOPEN Then
		--{
      Fetch ExtractData_DepositWithAll into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid,v_industry_type;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_DepositWithAll%NOTFOUND THEN
			--{
				CLOSE ExtractData_DepositWithAll;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
  
  ELSE --for All FCY
  IF NOT ExtractData_DepositWithAllFCY%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_DepositWithAllFCY (vi_tranDate,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_DepositWithAllFCY%ISOPEN Then
		--{
      Fetch ExtractData_DepositWithAllFCY into Transfer_Dr_Amt,Transfer_Cr_Amt,
      Cash_Dr_Amt,Cash_Cr_Amt,
      Clearing_Dr_Amt,Clearing_Cr_Amt,
      Customer_Name,Branch_Name,v_foracid,v_industry_type;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_DepositWithAllFCY%NOTFOUND THEN
			--{
				CLOSE ExtractData_DepositWithAllFCY;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
  end If;--currencytype
    END IF;--vi_type
--------------------------------------------------------------------------------------

BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_currencyType  = 'Home Currency' THEN
                if upper(vi_currency) = 'MMK' THEN vi_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF vi_currencyType = 'Source Currency' THEN
                   if upper(vi_currency) = 'MMK' THEN vi_rate := 1 ;
                   ELSE
                      vi_rate := 1;
                  end if;
              ELSE
                  vi_rate := 1;
              END IF;
  end;
------------------------------------------------------------------------------------------
 /*    BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
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
         SERVICE_OUTLET_TABLE.SOL_ID = v_sol_id
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
         
  END;*/
    
 
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	Transfer_Dr_Amt || '|' || Transfer_Cr_Amt || '|' ||
      Cash_Dr_Amt || '|' || Cash_Cr_Amt || '|' ||
      Clearing_Dr_Amt || '|' ||Clearing_Cr_Amt || '|' ||
      Customer_Name || '|' || Branch_Name || '|' ||v_foracid || '|' || v_industry_type || '|' ||
      vi_rate;
    
  END FIN_EXPLAIN;

END FIN_EXPLAIN;
/
