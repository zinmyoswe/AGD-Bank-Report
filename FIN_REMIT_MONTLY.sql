CREATE OR REPLACE PACKAGE               FIN_REMIT_MONTLY AS 

  

   PROCEDURE FIN_REMIT_MONTLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_REMIT_MONTLY;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                    FIN_REMIT_MONTLY AS

-------------------------------------------------------------------------------------
--updated by Yin Win Phyu   (23.3.2017)
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(200);              -- Input to procedure
	--vi_other_bank		Varchar2(30);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractData(ci_TranDate Varchar2 )
IS
  select sol.sol_id as "SOL ID",
      sol.sol_desc as "BRanch Name",
      KKBZ.KBZZ_Drawing_id as "KBZ Drawing Count",
      KKBZ.KBZZ_Encash_id as "KBZ Encash Count",
      KKBZ.KBZZ_Drawing_amt as "KBZ Drawing Amount",
      KKBZ.KBZZ_Encash_amt as "KBZ Encash Amount",
      KKBZ.AYA_Drawing_id as "AYA Drawing Count",
      KKBZ.AYA_Encash_id as "AYA Encash Count",
      KKBZ.AYA_Drawing_amt as "AYA Drawing Amount",
      KKBZ.AYA_Encash_amt as "AYA Enacash Amount",
      KKBZ.GTB_Drawing_id as "GTB Drawing Count",
      KKBZ.GTB_Encash_id as "GTB Encash Count",
      KKBZ.GTB_Drawing_amt as "GTB Drawing Amount",
      KKBZ.GTB_Encash_amt as "GTB Encash Amount",
      KKBZ.MWD_Drawing_id as "MWD Drawing Count",
      KKBZ.MWD_Encash_id as "MWD Encash Count",
      KKBZ.MWD_Drawing_amt as "MWD Drawing Amount",
      KKBZ.MWD_Encash_amt as "MWD Enacash Amount",
      KKBZ.CB_Drawing_id as "CB Drawing Count",
      KKBZ.CB_Encash_id as "CB Encash Count",
      KKBZ.CB_Drawing_amt as "CB Drawing Amount",
      KKBZ.CB_Encash_amt as "CB Enacash Amount",
      KKBZ.SMIDB_Drawing_id as "SMIDB Drawing Count",
      KKBZ.SMIDB_Encash_id as "SMIDB Encash Count",
      KKBZ.SMIDB_Drawing_amt as "SMIDB Drawing Amount",
      KKBZ.SMIDB_Encash_amt as "SMIDB Enacash Amount",
      KKBZ.RDB_Drawing_id as "RDB Drawing Count",
      KKBZ.RDB_Encash_id as "RDB Encash Count",
      KKBZ.RDB_Drawing_amt as "RDB Drawing Amount",
      KKBZ.RDB_Encash_amt as "RDB Enacash Amount",
      KKBZ.CHDB_Drawing_id as "CHDB Drawing Count",
      KKBZ.CHDB_Encash_id as "CHDB Encash Count",
      KKBZ.CHDB_Drawing_amt as "CHDB Drawing Amount",
      KKBZ.CHDB_Encash_amt as "CHDB Enacash Amount",
      KKBZ.Innwa_Drawing_id as "Innwa Drawing Count",
      KKBZ.Innwa_Encash_id as "Innwa Encash Count",
      KKBZ.Innwa_Drawing_amt as "Innwa Drawing Amount",
      KKBZ.Innwa_Encash_amt as "Innwa Enacash Amount",
      KKBZ.Shwe_Drawing_id as "Shwe Drawing Count",
      KKBZ.Shwe_Encash_id as "Shwe Encash Count",
      KKBZ.Shwe_Drawing_amt as "Shwe Drawing Amount",
      KKBZ.Shwe_Encash_amt as "Shwe Enacash Amount",
      KKBZ.MABL_Drawing_id as "MABL Drawing Count",
      KKBZ.MABL_Encash_id as "MABL Encash Count",
      KKBZ.MABL_Drawing_amt as "MABL Drawing Amount",
      KKBZ.MABL_Encash_amt as "MABL Enacash Amount",
      KKBZ.MayM_Drawing_id as "MayM Drawing Count",
      KKBZ.MayM_Encash_id as "MayM Encash Count",
      KKBZ.MayM_Drawing_amt as "MayM Drawing Amount",
      KKBZ.MayM_Encash_amt as "MayM Enacash Amount",
      KKBZ.MayS_Drawing_id as "MayS Drawing Count",
      KKBZ.MayS_Encash_id as "MayS Encash Count",
      KKBZ.MayS_Drawing_amt as "MayS Drawing Amount",
      KKBZ.MayS_Encash_amt as "MayS Enacash Amount",
      KKBZ.UOB_Drawing_id as "UOB Drawing Count",
      KKBZ.UOB_Encash_id as "UOB Encash Count",
      KKBZ.UOB_Drawing_amt as "UOB Drawing Amount",
      KKBZ.UOB_Encash_amt as "UOB Enacash Amount",
      KKBZ.DBS_Drawing_id as "DBS Drawing Count",
      KKBZ.DBS_Encash_id as "DBS Encash Count",
      KKBZ.DBS_Drawing_amt as "DBS Drawing Amount",
      KKBZ.DBS_Encash_amt as "DBS Enacash Amount",
      KKBZ.BKK_Drawing_id as "BKK Drawing Count",
      KKBZ.BKK_Encash_id as "BKK Encash Count",
      KKBZ.BKK_Drawing_amt as "BKK Drawing Amount",
      KKBZ.BKK_Encash_amt as "BKK Enacash Amount",
      KKBZ.OCBC_Drawing_id as "OCBC Drawing Count",
      KKBZ.OCBC_Encash_id as "OCBC Encash Count",
      KKBZ.OCBC_Drawing_amt as "OCBC Drawing Amount",
      KKBZ.OCBC_Encash_amt as "OCBC Enacash Amount",
      KKBZ.SIAM_Drawing_id as "SIAM Drawing Count",
      KKBZ.SIAM_Encash_id as "SIAM Encash Count",
      KKBZ.SIAM_Drawing_amt as "SIAM Drawing Amount",
      KKBZ.SIAM_Encash_amt as "SIAM Enacash Amount",
      KKBZ.AGD_Drawing_id as "AGD Drawing Count",
      KKBZ.AGD_Encash_id as "AGD Encash Count",
      KKBZ.AGD_Drawing_amt as "AGD Drawing Amount",
      KKBZ.AGD_Encash_amt as "AGD Enacash Amount",
      AGD_Encash_Outstanding.Encash_id as "AGD Encash Outstanding Count",
      AGD_Encash_Outstanding.Encash_Amount as "AGD Encash Outstanding Amount",
      AGD_Encash_Withdrawal.Encash_id as "AGD Encash Withdrawal Count",
      AGD_Encash_Withdrawal.Encash_Amount as "AGD Encash Withdrawal Amount"
from
(select sol.sol_id,sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      ) sol
left join
(select 
      count(q.KBZZ_Drawing_id) as KBZZ_Drawing_id,
      count(q.KBZZ_Encash_id) as KBZZ_Encash_id,
      count(q.AYA_Drawing_id) as AYA_Drawing_id,
      count(q.AYA_Encash_id) as AYA_Encash_id,
       count(q.GTB_Drawing_id) as GTB_Drawing_id,
      count(q.GTB_Encash_id) as GTB_Encash_id,
      count(q.MWD_Drawing_id) as MWD_Drawing_id,
      count(q.MWD_Encash_id) as MWD_Encash_id,
      count(q.CB_Drawing_id) as CB_Drawing_id,
      count(q.CB_Encash_id) as CB_Encash_id,
      count(q.SMIDB_Drawing_id) as SMIDB_Drawing_id,
      count(q.SMIDB_Encash_id) as SMIDB_Encash_id,
      count(q.RDB_Drawing_id) as RDB_Drawing_id,
      count(q.RDB_Encash_id) as RDB_Encash_id,
      count(q.CHDB_Drawing_id) as CHDB_Drawing_id,
      count(q.CHDB_Encash_id) as CHDB_Encash_id,
      count(q.Innwa_Drawing_id) as Innwa_Drawing_id,
      count(q.Innwa_Encash_id) as Innwa_Encash_id,
      count(q.Shwe_Drawing_id) as Shwe_Drawing_id,
      count(q.Shwe_Encash_id) as Shwe_Encash_id,
      count(q.MABL_Drawing_id) as MABL_Drawing_id,
      count(q.MABL_Encash_id) as MABL_Encash_id,
      count(q.MayM_Drawing_id) as MayM_Drawing_id,
      count(q.MayM_Encash_id) as MayM_Encash_id,
      count(q.MayS_Drawing_id) as MayS_Drawing_id,
      count(q.MayS_Encash_id) as MayS_Encash_id,
      count(q.UOB_Drawing_id) as UOB_Drawing_id,
      count(q.UOB_Encash_id) as UOB_Encash_id,
      count(q.DBS_Drawing_id) as DBS_Drawing_id,
      count(q.DBS_Encash_id) as DBS_Encash_id,
      count(q.BKK_Drawing_id) as BKK_Drawing_id,
      count(q.BKK_Encash_id) as BKK_Encash_id,
      count(q.OCBC_Drawing_id) as OCBC_Drawing_id,
      count(q.OCBC_Encash_id) as OCBC_Encash_id,
      count(q.SIAM_Drawing_id) as SIAM_Drawing_id,
      count(q.SIAM_Encash_id) as SIAM_Encash_id,
      count(q.AGD_Drawing_id) as AGD_Drawing_id,
      count(q.AGD_Encash_id) as AGD_Encash_id,
      q.dth_init_sol_id ,
      sum(q.KBZZ_Drawing_amt) as KBZZ_Drawing_amt ,
      sum(q.KBZZ_Encash_amt) as KBZZ_Encash_amt,
      sum(q.AYA_Drawing_amt) as AYA_Drawing_amt,
      sum(q.AYA_Encash_amt) as AYA_Encash_amt,
      sum(q.GTB_Drawing_amt) as GTB_Drawing_amt,
      sum(q.GTB_Encash_amt) as GTB_Encash_amt,
      sum(q.MWD_Drawing_amt) as MWD_Drawing_amt,
      sum(q.MWD_Encash_amt) as MWD_Encash_amt,
      sum(q.CB_Drawing_amt) as CB_Drawing_amt,
      sum(q.CB_Encash_amt) as CB_Encash_amt,
      sum(q.SMIDB_Drawing_amt) as SMIDB_Drawing_amt,
      sum(q.SMIDB_Encash_amt) as SMIDB_Encash_amt,
      sum(q.RDB_Drawing_amt) as RDB_Drawing_amt,
      sum(q.RDB_Encash_amt) as RDB_Encash_amt,
      sum(q.CHDB_Drawing_amt) as CHDB_Drawing_amt,
      sum(q.CHDB_Encash_amt) as CHDB_Encash_amt,
      sum(q.Innwa_Drawing_amt) as Innwa_Drawing_amt,
      sum(q.Innwa_Encash_amt) as Innwa_Encash_amt,
      sum(q.Shwe_Drawing_amt) as Shwe_Drawing_amt,
      sum(q.Shwe_Encash_amt) as Shwe_Encash_amt,
      sum(q.MABL_Drawing_amt) as MABL_Drawing_amt,
      sum(q.MABL_Encash_amt) as MABL_Encash_amt,
      sum(q.MayM_Drawing_amt) as MayM_Drawing_amt,
      sum(q.MayM_Encash_amt) as MayM_Encash_amt,
      sum(q.MayS_Drawing_amt) as MayS_Drawing_amt,
      sum(q.MayS_Encash_amt) as MayS_Encash_amt,
      sum(q.UOB_Drawing_amt) as UOB_Drawing_amt,
      sum(q.UOB_Encash_amt) as UOB_Encash_amt,
      sum(q.DBS_Drawing_amt) as DBS_Drawing_amt,
      sum(q.DBS_Encash_amt) as DBS_Encash_amt,
      sum(q.BKK_Drawing_amt) as BKK_Drawing_amt,
      sum(q.BKK_Encash_amt) as BKK_Encash_amt,
      sum(q.OCBC_Drawing_amt) as OCBC_Drawing_amt,
      sum(q.OCBC_Encash_amt) as OCBC_Encash_amt,
      sum(q.SIAM_Drawing_amt) as SIAM_Drawing_amt,
      sum(q.SIAM_Encash_amt) as SIAM_Encash_amt,
      sum(q.AGD_Drawing_amt) as AGD_Drawing_amt,
      sum(q.AGD_Encash_amt) as AGD_Encash_amt
      from
      ( select 
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '109' then ctd.tran_id else '' end as KBZZ_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '109' then ctd.tran_id else '' end as KBZZ_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '117' then ctd.tran_id else '' end as AYA_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '117' then ctd.tran_id else '' end as AYA_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '112' then ctd.tran_id else '' end as GTB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '112' then ctd.tran_id else '' end as GTB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '104' then ctd.tran_id else '' end as MWD_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '104' then ctd.tran_id else '' end as MWD_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '115' then ctd.tran_id else '' end as CB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '115' then ctd.tran_id else '' end as CB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '111' then ctd.tran_id else '' end as SMIDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '111' then ctd.tran_id else '' end as SMIDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '113' then ctd.tran_id else '' end as RDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '113' then ctd.tran_id else '' end as RDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '121' then ctd.tran_id else '' end as CHDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '121' then ctd.tran_id else '' end as CHDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '114' then ctd.tran_id else '' end as Innwa_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '114' then ctd.tran_id else '' end as Innwa_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '123' then ctd.tran_id else '' end as Shwe_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '123' then ctd.tran_id else '' end as Shwe_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '118' then ctd.tran_id else '' end as MABL_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '118' then ctd.tran_id else '' end as MABL_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'MY02' then ctd.tran_id else '' end as MayM_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'MY02' then ctd.tran_id else '' end as MayM_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'MY01' then ctd.tran_id else '' end as MayS_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'MY01' then ctd.tran_id else '' end as MayS_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'UO01' then ctd.tran_id else '' end as UOB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'UO01' then ctd.tran_id else '' end as UOB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'DB01' then ctd.tran_id else '' end as DBS_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'DB01' then ctd.tran_id else '' end as DBS_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'BK03' then ctd.tran_id else '' end as BKK_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'BK03' then ctd.tran_id else '' end as BKK_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'OC01' then ctd.tran_id else '' end as OCBC_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'OC01' then ctd.tran_id else '' end as OCBC_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'SC03' then ctd.tran_id else '' end as SIAM_Drawing_id,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'SC03' then ctd.tran_id else '' end as SIAM_Encash_id,
      case when ctd.rpt_code ='REMIT' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '116' then ctd.tran_id else '' end as AGD_Drawing_id,
      case when ctd.rpt_code ='REMIT' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '116' then ctd.tran_id else '' end as AGD_Encash_id,
      ctd.dth_init_sol_id ,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '109' then ctd.tran_amt else 0 end as KBZZ_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '109' then ctd.tran_amt else 0 end as KBZZ_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '117' then ctd.tran_amt else 0 end as AYA_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '117' then ctd.tran_amt else 0 end as AYA_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '112' then ctd.tran_amt else 0 end as GTB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '112' then ctd.tran_amt else 0 end as GTB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '104' then ctd.tran_amt else 0 end as MWD_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '104' then ctd.tran_amt else 0 end as MWD_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '115' then ctd.tran_amt else 0 end as CB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '115' then ctd.tran_amt else 0 end as CB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '111' then ctd.tran_amt else 0 end as SMIDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '111' then ctd.tran_amt else 0 end as SMIDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '113' then ctd.tran_amt else 0 end as RDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '113' then ctd.tran_amt else 0 end as RDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '121' then ctd.tran_amt else 0 end as CHDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '121' then ctd.tran_amt else 0 end as CHDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '114' then ctd.tran_amt else 0 end as Innwa_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '114' then ctd.tran_amt else 0 end as Innwa_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '123' then ctd.tran_amt else 0 end as Shwe_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '123' then ctd.tran_amt else 0 end as Shwe_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '118' then ctd.tran_amt else 0 end as MABL_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '118' then ctd.tran_amt else 0 end as MABL_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'MY02' then ctd.tran_amt else 0 end as MayM_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'MY02' then ctd.tran_amt else 0 end as MayM_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'MY01' then ctd.tran_amt else 0 end as MayS_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'MY01' then ctd.tran_amt else 0 end as MayS_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'UO01' then ctd.tran_amt else 0 end as UOB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'UO01' then ctd.tran_amt else 0 end as UOB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'DB01' then ctd.tran_amt else 0 end as DBS_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'DB01' then ctd.tran_amt else 0 end as DBS_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'BK03' then ctd.tran_amt else 0 end as BKK_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'BK03' then ctd.tran_amt else 0 end as BKK_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'OC01' then ctd.tran_amt else 0 end as OCBC_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'OC01' then ctd.tran_amt else 0 end as OCBC_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.tran_sub_type = 'RI' and ctd.bank_code = 'SC03' then ctd.tran_amt else 0 end as SIAM_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = 'SC03' then ctd.tran_amt else 0 end as SIAM_Encash_amt,
      case when ctd.rpt_code ='REMIT' and ctd.tran_sub_type = 'RI' and ctd.bank_code = '116' then ctd.tran_amt else 0 end as AGD_Drawing_amt,
      case when ctd.rpt_code ='REMIT' and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI') and ctd.bank_code = '116' then ctd.tran_amt else 0 end as AGD_Encash_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
    ctd.tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and ctd.tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' ) 
    and ctd.dth_init_sol_id !='20300'
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and atd.cont_tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )  )
    --order by sol.br_open_date
union all
select 
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '109' then ctd.tran_id else '' end as KBZZ_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '109' then ctd.tran_id else '' end as KBZZ_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '117' then ctd.tran_id else '' end as AYA_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '117' then ctd.tran_id else '' end as AYA_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '112' then ctd.tran_id else '' end as GTB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '112' then ctd.tran_id else '' end as GTB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '104' then ctd.tran_id else '' end as MWD_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '104' then ctd.tran_id else '' end as MWD_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '115' then ctd.tran_id else '' end as CB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '115' then ctd.tran_id else '' end as CB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '111' then ctd.tran_id else '' end as SMIDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '111' then ctd.tran_id else '' end as SMIDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '113' then ctd.tran_id else '' end as RDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '113' then ctd.tran_id else '' end as RDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '121' then ctd.tran_id else '' end as CHDB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '121' then ctd.tran_id else '' end as CHDB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '114' then ctd.tran_id else '' end as Innwa_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '114' then ctd.tran_id else '' end as Innwa_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '123' then ctd.tran_id else '' end as Shwe_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '123' then ctd.tran_id else '' end as Shwe_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '118' then ctd.tran_id else '' end as MABL_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '118' then ctd.tran_id else '' end as MABL_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'MY02' then ctd.tran_id else '' end as MayM_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'MY02' then ctd.tran_id else '' end as MayM_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'MY01' then ctd.tran_id else '' end as MayS_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'MY01' then ctd.tran_id else '' end as MayS_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'UO01' then ctd.tran_id else '' end as UOB_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'UO01' then ctd.tran_id else '' end as UOB_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'DB01' then ctd.tran_id else '' end as DBS_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'DB01' then ctd.tran_id else '' end as DBS_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'BK03' then ctd.tran_id else '' end as BKK_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'BK03' then ctd.tran_id else '' end as BKK_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'OC01' then ctd.tran_id else '' end as OCBC_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'OC01' then ctd.tran_id else '' end as OCBC_Encash_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'SC03' then ctd.tran_id else '' end as SIAM_Drawing_id,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'SC03' then ctd.tran_id else '' end as SIAM_Encash_id,
      case when ctd.rpt_code ='REMIT' and ctd.part_tran_type ='C' and ctd.bank_code = '116' then ctd.tran_id else '' end as AGD_Drawing_id,
      case when ctd.rpt_code ='REMIT' and ctd.part_tran_type ='D' and ctd.bank_code = '116' then ctd.tran_id else '' end as AGD_Encash_id,
      ctd.dth_init_sol_id ,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '109' then ctd.tran_amt else 0 end as KBZZ_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '109'then ctd.tran_amt else 0 end as KBZZ_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '117' then ctd.tran_amt else 0 end as AYA_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '117'then ctd.tran_amt else 0 end as AYA_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '112' then ctd.tran_amt else 0 end as GTB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '112'then ctd.tran_amt else 0 end as GTB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '104' then ctd.tran_amt else 0 end as MWD_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '104'then ctd.tran_amt else 0 end as MWD_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '115' then ctd.tran_amt else 0 end as CB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '115'then ctd.tran_amt else 0 end as CB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '111' then ctd.tran_amt else 0 end as SMIDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '111'then ctd.tran_amt else 0 end as SMIDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '113' then ctd.tran_amt else 0 end as RDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '113'then ctd.tran_amt else 0 end as RDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '121' then ctd.tran_amt else 0 end as CHDB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '121'then ctd.tran_amt else 0 end as CHDB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '114' then ctd.tran_amt else 0 end as Innwa_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '114'then ctd.tran_amt else 0 end as Innwa_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '123' then ctd.tran_amt else 0 end as Shwe_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '123'then ctd.tran_amt else 0 end as Shwe_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = '118' then ctd.tran_amt else 0 end as MABL_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = '118'then ctd.tran_amt else 0 end as MABL_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'MY02' then ctd.tran_amt else 0 end as MayM_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'MY02'then ctd.tran_amt else 0 end as MayM_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'MY01' then ctd.tran_amt else 0 end as MayS_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'MY01'then ctd.tran_amt else 0 end as MayS_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'UO01' then ctd.tran_amt else 0 end as UOB_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'UO01'then ctd.tran_amt else 0 end as UOB_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'DB01' then ctd.tran_amt else 0 end as DBS_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'DB01'then ctd.tran_amt else 0 end as DBS_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'BK03' then ctd.tran_amt else 0 end as BKK_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'BK03'then ctd.tran_amt else 0 end as BKK_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'OC01' then ctd.tran_amt else 0 end as OCBC_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'OC01'then ctd.tran_amt else 0 end as OCBC_Encash_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='C' and ctd.bank_code = 'SC03' then ctd.tran_amt else 0 end as SIAM_Drawing_amt,
      case when ctd.rpt_code ='IBREM' and ctd.part_tran_type ='D' and ctd.bank_code = 'SC03'then ctd.tran_amt else 0 end as SIAM_Encash_amt,
      case when ctd.rpt_code ='REMIT' and ctd.part_tran_type ='C' and ctd.bank_code = '116' then ctd.tran_amt else 0 end as AGD_Drawing_amt,
      case when ctd.rpt_code ='REMIT' and ctd.part_tran_type ='D' and ctd.bank_code = '116'then ctd.tran_amt else 0 end as AGD_Encash_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
     ctd.tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and ctd.tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )
    and ctd.dth_init_sol_id ='20300'
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and atd.cont_tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' ) )
    )q
  group by q.dth_init_sol_id
  order by q.dth_init_sol_id) KKBZ
  on sol.sol_id = KKBZ.dth_init_sol_id
left join
(select count(q.Encash_id) as Encash_id,
      q.dth_init_sol_id ,
      sum(q.Encash_amt) as Encash_Amount
    from
    (select 
      case when ctd.rpt_code ='REMIT' and ctd.tran_sub_type = 'RI' and ctd.dth_init_sol_id !='20300' then ctd.tran_id 
      when ctd.rpt_code ='REMIT' and ctd.part_tran_type='D' and ctd.dth_init_sol_id ='20300'then ctd.tran_id else '' end as Encash_id,
      ctd.dth_init_sol_id ,
      case when ctd.rpt_code ='REMIT' and ctd.tran_sub_type = 'RI' and ctd.dth_init_sol_id !='20300' then ctd.tran_amt 
      when ctd.rpt_code ='REMIT' and ctd.part_tran_type='D' and ctd.dth_init_sol_id ='20300'then ctd.tran_amt else 0 end as Encash_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
   ctd.tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and ctd.tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )
    and ctd.bank_code = '116'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
   and atd.cont_tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )  )
    and (TRIM(ctd.TRAN_ID),ctd.Tran_date) NOT IN(SELECT TRIM(T.TRAN_ID),t.Tran_date
                                                      FROM TBAADM.TCT T
                                                      WHERE ENTITY_CRE_FLG = 'Y' 
                                                      AND DEL_FLG = 'N'
                                                      and t.tran_date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
                                                      and t.tran_date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )))q
  group by q.dth_init_sol_id) AGD_Encash_Outstanding
  on AGD_Encash_Outstanding.dth_init_sol_id = sol.sol_id
left join
  (select count(q.Encash_id) as Encash_id,
      q.sol_id ,
      sum(q.Encash_amt) as Encash_Amount
    from
    (SELECT TCT.CONTRA_TRAN_ID AS Encash_id,
            TCT.sol_id,
              TCT.AMT_OFFSET AS Encash_amt
       FROM TBAADM.TCT TCT , custom.custom_CTH_DTH_VIEW CTH
       WHERE TCT.ENTITY_CRE_FLG = 'Y'
       AND TCT.DEL_FLG = 'N'
       AND trim(TCT.CONTRA_TRAN_ID)= trim(CTH.TRAN_ID)
       and TCT.CONTRA_TRAN_DATE > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
       AND TCT.CONTRA_TRAN_DATE <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )
       and tct.contra_tran_date = cth.tran_date
       and tct.sol_id = CTH.init_sol_id 
       AND (trim(TCT.CONTRA_TRAN_ID),TCT.contra_tran_date)  in (select trim(TRAN_ID),Tran_date
                                                 from TBAADM.CTD_DTD_ACLI_VIEW
                                                 where Tran_Date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
                                                 and Tran_Date  <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )
                                                 and tran_sub_type not in( 'NR','BI')
                                                 and part_tran_type = 'D'
                                                 and bank_code ='116'
                                                 and DEL_FLG = 'N' 
                                                 and PSTD_FLG = 'Y')
         AND (trim(TCT.TRAN_ID),TCT.tran_date,trim(tct.part_tran_srl_num)  )
       in (select trim(cdav.TRAN_ID),cdav.Tran_date,trim(cdav.part_tran_srl_num)
                                                 from TBAADM.CTD_DTD_ACLI_VIEW cdav
                                                 where --cdav.rpt_code in ( 'REMIT')
                                                 --and tran_sub_type in('PI')
                                                  --and  
                                                  bank_code is not null
                                                 and  branch_code is not null
                                                 and Tran_Date > ADD_MONTHS(TO_DATE(ci_TranDate,'dd-MM-yyyy' ),'-1')
                                                 and Tran_Date <= TO_DATE(ci_TranDate,'dd-MM-yyyy' )
                                                 and bank_code ='116'
                                                 and cdav.DEL_FLG = 'N' 
                                                 and cdav.PSTD_FLG = 'Y'))q
  group by q.sol_id) AGD_Encash_Withdrawal 
  on AGD_Encash_Withdrawal.sol_id = sol.sol_id
  order by sol.sol_desc;

  PROCEDURE FIN_REMIT_MONTLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_KKBZ_sol_id  tbaadm.sol.sol_id%type;
    v_KKBZ_BR_name tbaadm.sol.sol_desc%type;
    v_KBBZ_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_KBBZ_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_KKBZdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_KKBZEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AYA_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AYA_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AYAdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AYAEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_GTB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_GTB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_GTBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_GTBEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MWD_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MWD_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MWDdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MWDEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_CB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_CB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_CBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_CBEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_SMIDB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_SMIDB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_SMIDBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_SMIDEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_RDB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_RDB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_RDBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_RDBEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_CHDB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
     v_CHDB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_CHDBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_CHDBEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_Innwa_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_Innwa_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_Innwadrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_InnwaEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
     v_Shwe_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
     v_Shwe_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_Shwedrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_ShweEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
     v_MABL_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
     v_MABL_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MABLdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MABLEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
     v_MayM_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
     v_MayM_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MayMdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MayMEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MayS_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MayS_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_MaySdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_MaySEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_UOB_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_UOB_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_UOBdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_UOBEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_DBS_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_DBS_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_DBSdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_DBSEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_BKK_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_BKK_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_BKKdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_BKKEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_OCBC_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_OCBC_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_OCBCdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_OCBCEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_SIAM_Drawing_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_SIAM_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_SIAMdrawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_SIAMEncash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AGD_Drawing_Count CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AGD_Encash_Count   CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AGD_drawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AGD_Encash_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AGD_EncashOutstanding_Count CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AGD_EncashOutstanding_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_AGD_EncashWithdrawal_Count CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_AGD_EncashWithdrawal_amt  CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
     
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
     vi_TranDate := outArr(0);
     --vi_other_bank := outArr(1);
    ------------------------------------------------------------------------------------------
    
    if( vi_TranDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 
                     || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
                     0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' || 0 || '|' || 0|| '|' || 0 || '|' || 0|| '|' || 0|| '|' || 0);
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    ---------------------------------------------------------------------------------
    
    
     IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData (vi_TranDate );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  v_KKBZ_sol_id  , v_KKBZ_BR_name , v_KBBZ_Drawing_Count ,v_KBBZ_Encash_Count , v_KKBZdrawing_amt ,v_KKBZEncash_amt , 
               v_AYA_Drawing_Count  ,v_AYA_Encash_Count   ,v_AYAdrawing_amt ,v_AYAEncash_amt  ,
               v_GTB_Drawing_Count ,v_GTB_Encash_Count   ,v_GTBdrawing_amt ,v_GTBEncash_amt  ,
               v_MWD_Drawing_Count, v_MWD_Encash_Count   ,v_MWDdrawing_amt ,v_MWDEncash_amt  ,
               v_CB_Drawing_Count ,v_CB_Encash_Count,v_CBdrawing_amt ,v_CBEncash_amt  ,
               v_SMIDB_Drawing_Count,v_SMIDB_Encash_Count   ,v_SMIDBdrawing_amt ,v_SMIDEncash_amt  ,
               v_RDB_Drawing_Count      ,v_RDB_Encash_Count   ,v_RDBdrawing_amt ,v_RDBEncash_amt  ,
               v_CHDB_Drawing_Count      ,v_CHDB_Encash_Count   ,v_CHDBdrawing_amt ,v_CHDBEncash_amt  ,
               v_Innwa_Drawing_Count      ,v_Innwa_Encash_Count   ,v_Innwadrawing_amt ,v_InnwaEncash_amt  ,
               v_Shwe_Drawing_Count      ,v_Shwe_Encash_Count   ,v_Shwedrawing_amt ,v_ShweEncash_amt  ,
               v_MABL_Drawing_Count      ,v_MABL_Encash_Count   ,v_MABLdrawing_amt ,v_MABLEncash_amt ,
               v_MayM_Drawing_Count      ,v_MayM_Encash_Count   ,v_MayMdrawing_amt ,v_MayMEncash_amt  ,
               v_MayS_Drawing_Count      ,v_MayS_Encash_Count   ,v_MaySdrawing_amt ,v_MaySEncash_amt  ,
               v_UOB_Drawing_Count      ,v_UOB_Encash_Count   ,v_UOBdrawing_amt ,v_UOBEncash_amt  ,
               v_DBS_Drawing_Count      ,v_DBS_Encash_Count   ,v_DBSdrawing_amt ,v_DBSEncash_amt  ,
               v_BKK_Drawing_Count      ,v_BKK_Encash_Count   ,v_BKKdrawing_amt ,v_BKKEncash_amt  ,
               v_OCBC_Drawing_Count      ,v_OCBC_Encash_Count   ,v_OCBCdrawing_amt ,v_OCBCEncash_amt  ,
               v_SIAM_Drawing_Count      ,v_SIAM_Encash_Count   ,v_SIAMdrawing_amt ,v_SIAMEncash_amt ,
               v_AGD_Drawing_Count , v_AGD_Encash_Count, v_AGD_drawing_amt ,v_AGD_Encash_amt,
               v_AGD_EncashOutstanding_Count ,v_AGD_EncashOutstanding_amt,
               v_AGD_EncashWithdrawal_Count, v_AGD_EncashWithdrawal_amt ;
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
        
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (    
                    v_KKBZ_sol_id  || '|' ||
                    v_KKBZ_BR_name || '|' ||
                     v_KBBZ_Drawing_Count || '|' ||
                     v_KBBZ_Encash_Count || '|' ||
                    v_KKBZdrawing_amt || '|' ||
                    v_KKBZEncash_amt || '|' ||
               v_AYA_Drawing_Count  || '|' ||
               v_AYA_Encash_Count || '|' ||
               v_AYAdrawing_amt || '|' ||
               v_AYAEncash_amt  || '|' ||
               v_GTB_Drawing_Count || '|' ||
               v_GTB_Encash_Count || '|' ||
               v_GTBdrawing_amt || '|' ||
               v_GTBEncash_amt || '|' ||
               v_MWD_Drawing_Count|| '|' ||
               v_MWD_Encash_Count || '|' ||
               v_MWDdrawing_amt || '|' ||
               v_MWDEncash_amt  || '|' ||
               v_CB_Drawing_Count || '|' ||
               v_CB_Encash_Count || '|' ||
               v_CBdrawing_amt || '|' ||
               v_CBEncash_amt  || '|' ||
              v_SMIDB_Drawing_Count|| '|' ||
              v_SMIDB_Encash_Count || '|' ||
               v_SMIDBdrawing_amt || '|' ||
               v_SMIDEncash_amt  || '|' ||
              v_RDB_Drawing_Count || '|' ||
              v_RDB_Encash_Count || '|' ||
               v_RDBdrawing_amt || '|' ||
               v_RDBEncash_amt  || '|' ||
                v_CHDB_Drawing_Count || '|' ||
                v_CHDB_Encash_Count || '|' ||
               v_CHDBdrawing_amt || '|' ||
               v_CHDBEncash_amt  || '|' ||
               v_Innwa_Drawing_Count || '|' ||
               v_Innwa_Encash_Count || '|' ||
               v_Innwadrawing_amt || '|' ||
               v_InnwaEncash_amt  || '|' ||
               v_Shwe_Drawing_Count || '|' ||
               v_Shwe_Encash_Count || '|' ||
               v_Shwedrawing_amt || '|' ||
               v_ShweEncash_amt || '|' ||
               v_MABL_Drawing_Count|| '|' ||
               v_MABL_Encash_Count || '|' ||
               v_MABLdrawing_amt || '|' ||
               v_MABLEncash_amt || '|' ||
               v_MayM_Drawing_Count || '|' ||
               v_MayM_Encash_Count || '|' ||
               v_MayMdrawing_amt || '|' ||
               v_MayMEncash_amt  || '|' ||
               v_MayS_Drawing_Count|| '|' ||
               v_MayS_Encash_Count || '|' ||
               v_MaySdrawing_amt || '|' ||
               v_MaySEncash_amt  || '|' ||
               v_UOB_Drawing_Count|| '|' ||
               v_UOB_Encash_Count|| '|' ||
               v_UOBdrawing_amt || '|' ||
               v_UOBEncash_amt  || '|' ||
               v_DBS_Drawing_Count || '|' ||
               v_DBS_Encash_Count|| '|' ||
               v_DBSdrawing_amt || '|' ||
               v_DBSEncash_amt  || '|' ||
               v_BKK_Drawing_Count|| '|' ||
               v_BKK_Encash_Count || '|' ||
               v_BKKdrawing_amt || '|' ||
               v_BKKEncash_amt || '|' ||
               v_OCBC_Drawing_Count|| '|' ||
               v_OCBC_Encash_Count|| '|' ||
               v_OCBCdrawing_amt || '|' ||
               v_OCBCEncash_amt  || '|' ||
               v_SIAM_Drawing_Count|| '|' ||
               v_SIAM_Encash_Count|| '|' ||
               v_SIAMdrawing_amt || '|' ||
               v_SIAMEncash_amt || '|' ||
               v_AGD_Drawing_Count || '|' ||
               v_AGD_Encash_Count|| '|' ||
               v_AGD_drawing_amt || '|' ||
               v_AGD_Encash_amt|| '|' ||
               v_AGD_EncashOutstanding_Count || '|' ||
               v_AGD_EncashOutstanding_amt|| '|' ||
               v_AGD_EncashWithdrawal_Count|| '|' ||
               v_AGD_EncashWithdrawal_amt
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_REMIT_MONTLY;

END FIN_REMIT_MONTLY;
/
