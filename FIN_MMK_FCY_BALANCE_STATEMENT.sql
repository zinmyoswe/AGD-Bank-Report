CREATE OR REPLACE PACKAGE                             FIN_MMK_FCY_BALANCE_STATEMENT AS 

   PROCEDURE FIN_MMK_FCY_BALANCE_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_MMK_FCY_BALANCE_STATEMENT;
/


CREATE OR REPLACE PACKAGE BODY                                                                                FIN_MMK_FCY_BALANCE_STATEMENT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_Date		Varchar2(10);		    	    -- Input to procedure
  vi_user_id  Varchar2(15);               -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
 
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_Date VARCHAR2,   ci_user_id  Varchar2,ci_branchCode VARCHAR2)
  IS
 

select

sum(P.USDopening_amt) AS USDopening_amt,
sum(P.EURopening_amt) AS EURopening_amt,
sum(P.SGDopening_amt) AS SGDopening_amt,
sum(P.THBopening_amt) AS THBopening_amt,
sum(P.MMKopening_amt) AS MMKopening_amt,
sum(P.RCCUsdamt) AS  RCCUsdamt,
sum(P.RCCEURamt) AS RCCEURamt,
sum(P.RCCSGDamt) AS RCCSGDamt,
sum(P.RCCTHBamt) AS RCCTHBamt ,
sum(P.RCCMMKamt) AS RCCMMKamt ,
sum(P.PCUsdamt) AS PCUsdamt,
sum(P.PCEURamt) AS PCEURamt,
sum(P.PCSGDamt) AS PCSGDamt,
sum(P.PCTHBamt) AS PCTHBamt,
sum(P.PCMMKamt) AS PCMMKamt ,
 sum(P.TFUsdamt) AS TFUsdamt,
 sum(P.TFEURamt) AS TFEURamt,
 sum(P.TFSGDamt) AS TFSGDamt, 
 sum(P.TFTHBamt) AS TFTHBamt,
 sum(P.TFMMKamt) AS TFMMKamt,
sum(P.TTUsdamt) AS TTUsdamt,
sum(P.TTEURamt) AS TTEURamt,
sum(P.TTSGDamt) AS TTSGDamt,
sum(P.TTTHBamt) AS TTTHBamt,
sum(P.TTMMKamt)  AS TTMMKamt,
sum(P.CurrentDUSDamt) AS CurrentDUSDamt,
sum(P.CurrentDEURamt) AS CurrentDEURamt,
sum(P.CurrentDSGDamt) AS CurrentDSGDamt,
sum(P.CurrentDTHBamt) AS CurrentDTHBamt,
sum(P.CurrentDMMKamt) AS CurrentDMMKamt ,
sum(P.CurrentWUSDamt) AS CurrentWUSDamt,
sum(P.CurrentWEURamt) AS CurrentWEURamt,
sum(P.CurrentWSGDamt) AS CurrentWSGDamt,
sum(P.CurrentWTHBamt) AS CurrentWTHBamt,
sum(P.CurrentWMMKamt) AS CurrentWMMKamt ,
sum(P.BUSDamt) AS BUSDamt ,
sum(P.BEURamt) AS BEURamt,
sum(P.BSGDamt) AS BSGDamt,
sum(P.BTHBamt) AS BTHBamt,
sum(P.BMMKamt) AS BMMKamt,
sum(P.SUSDamt) AS SUSDamt ,
sum(P.SEURamt)AS SEURamt,
sum(P.SSGDamt) AS SSGDamt,
sum(P.STHBamt) AS STHBamt,
sum(P.SMMKamt) AS SMMKamt

from (
select 
sum(T.USDopening_amt) AS USDopening_amt,
sum(T.EURopening_amt) AS EURopening_amt,
sum(T.SGDopening_amt) AS SGDopening_amt,
sum(T.THBopening_amt) AS THBopening_amt,
sum(T.MMKopening_amt) AS MMKopening_amt,
0 AS  RCCUsdamt,
0 AS RCCEURamt,
0 AS RCCSGDamt,
0 AS RCCTHBamt ,
0 AS RCCMMKamt ,
0 AS PCUsdamt,
0 AS PCEURamt,
0 AS PCSGDamt,
0 AS PCTHBamt,
0 AS PCMMKamt ,
0 AS TFUsdamt,
0 AS TFEURamt,
0 AS TFSGDamt, 
0 AS TFTHBamt,
0 AS TFMMKamt,
0 AS TTUsdamt,
0 AS TTEURamt,
0 AS TTSGDamt,
0 AS TTTHBamt,
0  AS TTMMKamt,
0 AS CurrentDUSDamt,
0 AS CurrentDEURamt,
0 AS CurrentDSGDamt,
0 AS CurrentDTHBamt,
0 AS CurrentDMMKamt ,
0 AS CurrentWUSDamt,
0 AS CurrentWEURamt,
0 AS CurrentWSGDamt,
0 AS CurrentWTHBamt,
0 AS CurrentWMMKamt ,
0 AS BUSDamt ,
0 AS BEURamt,
0 AS BSGDamt,
0 AS BTHBamt,
0 AS BMMKamt,
0 AS SUSDamt ,
0 AS SEURamt,
0 AS SSGDamt,
0 AS STHBamt,
0 AS SMMKamt


from
(select q.cur,
q.USDopening_amt,
q.EURopening_amt ,
q.SGDopening_amt,
q.THBopening_amt,
q.MMKopening_amt


from (SELECT distinct coa.cur as cur,
                (select abs(sum(eab.tran_date_bal)) 
                 from tbaadm.eab
                 where gam.acid = eab.acid
                 and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code = upper('USD')
                 and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code = upper('USD')
                  )) as USDopening_amt,
                  (select abs(sum(eab.tran_date_bal)) 
                 from tbaadm.eab
                 where gam.acid = eab.acid
                 and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code = upper('EUR')
                 and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code = upper('EUR')
                  )) as EURopening_amt,
                  (select abs(sum(eab.tran_date_bal)) 
                 from tbaadm.eab
                 where gam.acid = eab.acid
                 and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code = upper('SGD')
                 and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code = upper('SGD')
                  )) as SGDopening_amt,
                  (select abs(sum(eab.tran_date_bal)) 
                 from tbaadm.eab
                 where gam.acid = eab.acid
                 and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code = upper('THB')
                 and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code = upper('THB')
                  )) as THBopening_amt,
                  (select abs(sum(eab.tran_date_bal)) 
                 from tbaadm.eab
                 where gam.acid = eab.acid
                 and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code = upper('MMK')
                 and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code = upper('MMK')
                  )) as MMKopening_amt
from  
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   /*cdav.tran_date =( select max(cdav.tran_date) 
                     from custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
        where cdav.tran_date < TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
   AND*/ cdav.SOL_ID         like '%' || ci_branchCode || '%'
   and gam.SOL_ID like   '%' || ci_branchCode || '%'
   and cdav.entry_user_id =upper(ci_user_id)
   and coa.gl_sub_head_code ='10101'
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and gam.BANK_ID = '01' 
   and cdav.bank_id ='01'
   and coa.cur  =gam.acct_crncy_code 
   and cdav.tran_crncy_code =coa.cur
   and gam.acid = cdav.acid
   
)q)T

UNION ALL


SELECT 

0 AS USDopening_amt,
0 AS EURopening_amt,
0 AS SGDopening_amt,
0 AS THBopening_amt,
0 AS MMKopening_amt,
sum(T.RCCUsdamt) AS  RCCUsdamt,
sum(T.RCCEURamt) AS RCCEURamt,
sum(T.RCCSGDamt) AS RCCSGDamt,
sum(T.RCCTHBamt) AS RCCTHBamt ,
sum(T.RCCMMKamt) AS RCCMMKamt ,
0 AS PCUsdamt,
0 AS PCEURamt,
0 AS PCSGDamt,
0 AS PCTHBamt,
0 AS PCMMKamt ,

0 AS TFUsdamt,
0 AS TFEURamt,
0 AS TFSGDamt, 
0 AS TFTHBamt,
0 AS TFMMKamt,
0 AS TTUsdamt,
0 AS TTEURamt,
0 AS TTSGDamt,
0 AS TTTHBamt,
0  AS TTMMKamt,
0 AS CurrentDUSDamt,
0 AS CurrentDEURamt,
0 AS CurrentDSGDamt,
0 AS CurrentDTHBamt,
0 AS CurrentDMMKamt ,
0 AS CurrentWUSDamt,
0 AS CurrentWEURamt,
0 AS CurrentWSGDamt,
0 AS CurrentWTHBamt,
0 AS CurrentWMMKamt ,

0 AS BUSDamt ,
0 AS BEURamt,
0 AS BSGDamt,
0 AS BTHBamt,
0 AS BMMKamt,
0 AS SUSDamt ,
0 AS SEURamt,
0 AS SSGDamt,
0 AS STHBamt,
0 AS SMMKamt
from
(select 
q.cur ,
CASE WHEN q.cur = 'USD'  THEN q.tran_amt  END as RCCUsdamt,
CASE WHEN q.cur = 'EUR'  THEN q.tran_amt  END as RCCEURamt ,
CASE WHEN q.cur = 'SGD'  THEN q.tran_amt  END as RCCSGDamt,
CASE WHEN q.cur = 'THB' THEN q.tran_amt  END as RCCTHBamt,
CASE WHEN q.cur = 'MMK'  THEN q.tran_amt  END as RCCMMKamt

from  
(
select sum(tran_amt) as tran_amt ,cdav.tran_crncy_code as cur 
from  CUSTOM.custom_ctd_dtd_acli_view cdav , tbaadm.gam gam 
where 
cdav.acid = gam.acid 
and cdav.sol_id = gam.sol_id 
and cdav.tran_date =TO_DATE( CAST (ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
and cdav.dth_init_sol_id like '%' || ci_branchCode || '%'
and cdav.tran_type = 'C'  
--and cdav.tran_particular_code ='TRW' 
and cdav.part_tran_type ='C' 
and cdav.tran_sub_type ='CT' 
and cdav.tran_particular like '%TO TELLER%' 
and  cdav.part_tran_type ='C' 
and cdav.gl_sub_head_code ='10101'
 and trim(substr(  cdav.tran_particular,(length(  cdav.tran_particular)-7),length(  cdav.tran_particular))) =upper(ci_user_id)
and gam.acct_cls_flg='N'
and gam.del_flg ='N'
and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
group by 
cdav.tran_crncy_code  ,
cdav.ref_amt  ,cdav.gl_sub_head_code  , 
cdav.tran_particular_code  ,
cdav.tran_type , cdav.part_tran_type  ,cdav.tran_sub_type ,cdav.tran_particular

)q)T

UNION ALL



SELECT 

0 AS USDopening_amt,
0 AS EURopening_amt,
0 AS SGDopening_amt,
0 AS THBopening_amt,
0 AS MMKopening_amt,
0 AS  RCCUsdamt,
0 AS RCCEURamt,
0 AS RCCSGDamt,
0 AS RCCTHBamt ,
0 AS RCCMMKamt ,
sum(T.PCUsdamt) AS PCUsdamt,
sum(T.PCEURamt) AS PCEURamt,
sum(T.PCSGDamt) AS PCSGDamt,
sum(T.PCTHBamt) AS PCTHBamt,
sum(T.PCMMKamt) AS PCMMKamt ,

0 AS TFUsdamt,
0 AS TFEURamt,
0 AS TFSGDamt, 
0 AS TFTHBamt,
0 AS TFMMKamt,
0 AS TTUsdamt,
0 AS TTEURamt,
0 AS TTSGDamt,
0 AS TTTHBamt,
0  AS TTMMKamt,
0 AS CurrentDUSDamt,
0 AS CurrentDEURamt,
0 AS CurrentDSGDamt,
0 AS CurrentDTHBamt,
0 AS CurrentDMMKamt ,
0 AS CurrentWUSDamt,
0 AS CurrentWEURamt,
0 AS CurrentWSGDamt,
0 AS CurrentWTHBamt,
0 AS CurrentWMMKamt ,

0 AS BUSDamt ,
0 AS BEURamt,
0 AS BSGDamt,
0 AS BTHBamt,
0 AS BMMKamt,
0 AS SUSDamt ,
0 AS SEURamt,
0 AS SSGDamt,
0 AS STHBamt,
0 AS SMMKamt


from
(select 
q.cur ,
CASE WHEN q.cur = 'USD'  THEN q.tran_amt  END as PCUsdamt,
CASE WHEN q.cur = 'EUR'  THEN q.tran_amt  END as PCEURamt ,
CASE WHEN q.cur = 'SGD'  THEN q.tran_amt  END as PCSGDamt,
CASE WHEN q.cur = 'THB' THEN q.tran_amt  END as PCTHBamt,
CASE WHEN q.cur = 'MMK'  THEN q.tran_amt  END as PCMMKamt

from  
(
select sum(tran_amt) as tran_amt ,cdav.tran_crncy_code as cur
 from CUSTOM.custom_ctd_dtd_acli_view cdav 
 where 
cdav.tran_particular like '%FROM TELLER%' 
and cdav.part_tran_type ='D' 
and cdav.tran_sub_type ='CT' 
--and cdav.tran_particular_code ='TRD' 
and cdav.gl_sub_head_code ='10101'
 and trim(substr(  cdav.tran_particular,(length(  cdav.tran_particular)-7),length(  cdav.tran_particular))) =upper(ci_user_id)
and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
        and cdav.tran_date =TO_DATE( CAST (ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
and cdav.dth_init_sol_id  like '%' || ci_branchCode || '%'
group by 
cdav.tran_crncy_code  

)q)T



 
UNION ALL

SELECT 

0 AS USDopening_amt,
0 AS EURopening_amt,
0 AS SGDopening_amt,
0 AS THBopening_amt,
0 AS MMKopening_amt,
0 AS  RCCUsdamt,
0 AS RCCEURamt,
0 AS RCCSGDamt,
0 AS RCCTHBamt ,
0 AS RCCMMKamt ,
0 AS PCUsdamt,
0 AS PCEURamt,
0 AS PCSGDamt,
0 AS PCTHBamt,
0 AS PCMMKamt ,

 sum(T.TFUsdamt) AS TFUsdamt,
 sum(T.TFEURamt) AS TFEURamt,
 sum(T.TFSGDamt) AS TFSGDamt, 
 sum(T.TFTHBamt) AS TFTHBamt,
 sum(T.TFMMKamt) AS TFMMKamt,
sum(T.TTUsdamt) AS TTUsdamt,
sum(T.TTEURamt) AS TTEURamt,
sum(T.TTSGDamt) AS TTSGDamt,
sum(T.TTTHBamt) AS TTTHBamt,
sum(T.TTMMKamt)  AS TTMMKamt,

sum(T.CurrentDUSDamt) AS CurrentDUSDamt,
sum(T.CurrentDEURamt) AS CurrentDEURamt,
sum(T.CurrentDSGDamt) AS CurrentDSGDamt,
sum(T.CurrentDTHBamt) AS CurrentDTHBamt,
sum(T.CurrentDMMKamt) AS CurrentDMMKamt ,
sum(T.CurrentWUSDamt) AS CurrentWUSDamt,
sum(T.CurrentWEURamt) AS CurrentWEURamt,
sum(T.CurrentWSGDamt) AS CurrentWSGDamt,
sum(T.CurrentWTHBamt) AS CurrentWTHBamt,
sum(T.CurrentWMMKamt) AS CurrentWMMKamt ,


0 AS BUSDamt ,
0 AS BEURamt,
0 AS BSGDamt,
0 AS BTHBamt,
0 AS BMMKamt,
0 AS SUSDamt ,
0 AS SEURamt,
0 AS SSGDamt,
0 AS STHBamt,
0 AS SMMKamt
from
(select 
q.cur ,


CASE WHEN q.cur = 'USD' and q.tran_type = 'C'  and q.tran_particular_code ='CHD'  and q.part_tran_type ='C'  and q.gl_code ='70111' THEN q.tran_amt  END as CurrentDUSDamt,
CASE WHEN q.cur = 'EUR' and q.tran_type = 'C'  and q.tran_particular_code ='CHD'  and q.part_tran_type ='C'  and q.gl_code ='70111' THEN q.tran_amt  END as CurrentDEURamt ,
CASE WHEN q.cur = 'SGD' and q.tran_type = 'C'  and q.tran_particular_code ='CHD'  and q.part_tran_type ='C'   and q.gl_code ='70111' THEN q.tran_amt  END as CurrentDSGDamt,
CASE WHEN q.cur = 'THB' and q.tran_type = 'C'  and q.tran_particular_code ='CHD'  and q.part_tran_type ='C'   and q.gl_code ='70111' THEN q.tran_amt  END as CurrentDTHBamt,
CASE WHEN q.cur = 'MMK' and q.tran_type = 'C'  and q.tran_particular_code ='CHD'  and q.part_tran_type ='C'  and q.gl_code ='70111' THEN q.tran_amt  END as CurrentDMMKamt,
CASE WHEN q.cur = 'USD'  and q.tran_type = 'C'  and q.tran_particular_code ='CHW'  and q.part_tran_type ='D'   and q.gl_code ='70111' THEN q.tran_amt  END as CurrentWUSDamt,
CASE WHEN q.cur = 'EUR'  and q.tran_type = 'C'  and q.tran_particular_code ='CHW'  and q.part_tran_type ='D'  and q.gl_code ='70111'  THEN q.tran_amt  END as CurrentWEURamt ,
CASE WHEN q.cur = 'SGD'  and q.tran_type = 'C'  and q.tran_particular_code ='CHW'  and q.part_tran_type ='D'  and q.gl_code ='70111' THEN q.tran_amt  END as CurrentWSGDamt,
CASE WHEN q.cur = 'THB'  and q.tran_type = 'C'  and q.tran_particular_code ='CHW'  and q.part_tran_type ='D'   and q.gl_code ='70111' THEN q.tran_amt  END as CurrentWTHBamt,
CASE WHEN q.cur ='MMK'  and q.tran_type = 'C'  and q.tran_particular_code ='CHW'  and q.part_tran_type ='D'   and q.gl_code ='70111' THEN q.tran_amt  END as CurrentWMMKamt,


CASE WHEN q.cur = 'USD' and q.tran_type = 'C' and q.tran_sub_type ='NR'   and q.part_tran_type ='C' and q.gl_code ='10105'   THEN q.tran_amt  END as TFUsdamt,
CASE WHEN q.cur = 'EUR' and q.tran_type = 'C' and q.tran_sub_type ='NR'   and q.part_tran_type ='C' and q.gl_code ='10105'    THEN q.tran_amt  END as TFEURamt ,
CASE WHEN q.cur = 'SGD' and q.tran_type = 'C' and q.tran_sub_type ='NR'   and q.part_tran_type ='C' and q.gl_code ='10105'    THEN q.tran_amt  END as TFSGDamt,
CASE WHEN q.cur = 'THB' and q.tran_type = 'C' and q.tran_sub_type ='NR'   and q.part_tran_type ='C' and q.gl_code ='10105'   THEN q.tran_amt  END as TFTHBamt,
CASE WHEN q.cur = 'MMK' and q.tran_type = 'C' and q.tran_sub_type ='NR'   and q.part_tran_type ='C' and q.gl_code ='10105'   THEN q.tran_amt  END as TFMMKamt,
CASE WHEN q.cur = 'USD'  and q.tran_type = 'C'    and q.part_tran_type ='D' and q.gl_code ='10105'  THEN q.tran_amt  END as TTUsdamt,
CASE WHEN q.cur = 'EUR'  and q.tran_type = 'C'    and q.part_tran_type ='D' and q.gl_code ='10105'  THEN q.tran_amt  END as TTEURamt ,
CASE WHEN q.cur = 'SGD'  and q.tran_type = 'C'    and q.part_tran_type ='D' and q.gl_code ='10105' THEN q.tran_amt  END as TTSGDamt,
CASE WHEN q.cur = 'THB'  and q.tran_type = 'C'   and q.part_tran_type ='D' and q.gl_code ='10105' THEN q.tran_amt  END as TTTHBamt,
CASE WHEN q.cur ='MMK'  and q.tran_type = 'C'   and q.part_tran_type ='D' and q.gl_code ='10105' THEN q.tran_amt  END as TTMMKamt 

from  
(
select sum(tran_amt) as tran_amt ,cdav.tran_crncy_code as cur ,
cdav.ref_amt as ref_amt ,cdav.gl_sub_head_code as gl_code , 
cdav.tran_particular_code as tran_particular_code ,
cdav.tran_type as tran_type , cdav.part_tran_type as part_tran_type  ,cdav.tran_sub_type ,cdav.tran_particular
from  CUSTOM.custom_ctd_dtd_acli_view cdav , tbaadm.gam gam 
where 
cdav.acid = gam.acid 
and cdav.sol_id = gam.sol_id 
and cdav.tran_date =TO_DATE( CAST (ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
and cdav.dth_init_sol_id like '%' || ci_branchCode || '%'
 and cdav.entry_user_id =upper(ci_user_id)
and gam.acct_cls_flg='N'
and gam.del_flg ='N'
and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST (ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
group by 
cdav.tran_crncy_code  ,
cdav.ref_amt  ,cdav.gl_sub_head_code  , 
cdav.tran_particular_code  ,
cdav.tran_type , cdav.part_tran_type  ,cdav.tran_sub_type ,cdav.tran_particular

)q)T


 
 
UNION ALL

select 
0 AS USDopening_amt,
0 AS EURopening_amt,
0 AS SGDopening_amt,
0 AS THBopening_amt,
0 AS MMKopening_amt,
0 AS  RCCUsdamt,
0 AS RCCEURamt,
0 AS RCCSGDamt,
0 AS RCCTHBamt ,
0 AS RCCMMKamt ,
0 AS PCUsdamt,
0 AS PCEURamt,
0 AS PCSGDamt,
0 AS PCTHBamt,
0 AS PCMMKamt ,
0 AS TFUsdamt,
0 AS TFEURamt,
0 AS TFSGDamt, 
0 AS TFTHBamt,
0 AS TFMMKamt,
0 AS TTUsdamt,
0 AS TTEURamt,
0 AS TTSGDamt,
0 AS TTTHBamt,
0  AS TTMMKamt,
0 AS CurrentDUSDamt,
0 AS CurrentDEURamt,
0 AS CurrentDSGDamt,
0 AS CurrentDTHBamt,
0 AS CurrentDMMKamt ,
0 AS CurrentWUSDamt,
0 AS CurrentWEURamt,
0 AS CurrentWSGDamt,
0 AS CurrentWTHBamt,
0 AS CurrentWMMKamt ,
sum(T.BUSDamt) AS BUSDamt ,
sum(T.BEURamt) AS BEURamt,
sum(T.BSGDamt) AS BSGDamt,
sum(T.BTHBamt) AS BTHBamt,
sum(T.BMMKamt) AS BMMKamt,
sum(T.SUSDamt) AS SUSDamt ,
sum(T.SEURamt)AS SEURamt,
sum(T.SSGDamt) AS SSGDamt,
sum(T.STHBamt) AS STHBamt,
sum(T.SMMKamt) AS SMMKamt


 
 from
 (select 
q.cur ,
CASE WHEN q.cur = 'USD' and q.status = 'B'  THEN q.tran_amt  END as BUSDamt,
CASE WHEN q.cur = 'EUR'and q.status = 'B'  THEN q.tran_amt  END as BEURamt ,
CASE WHEN q.cur = 'SGD' and q.status = 'B'  THEN q.tran_amt  END as BSGDamt,
CASE WHEN q.cur = 'THB' and q.status = 'B'  THEN q.tran_amt  END as BTHBamt,
CASE WHEN q.cur in('USD','EUR','SGD','THB','MMK') and q.status = 'B'  THEN q.ref_amt  END as BMMKamt,
CASE WHEN q.cur = 'USD' and q.status = 'S'  THEN q.tran_amt  END as SUSDamt,
CASE WHEN q.cur = 'EUR'and q.status = 'S'   THEN q.tran_amt  END as SEURamt ,
CASE WHEN q.cur = 'SGD' and q.status = 'S'  THEN q.tran_amt  END as SSGDamt,
CASE WHEN q.cur = 'THB' and q.status = 'S' THEN q.tran_amt  END as STHBamt,
CASE WHEN q.cur in('USD','EUR','SGD','THB','MMK') and q.status = 'S'  THEN q.ref_amt  END as SMMKamt

from(select  sum(cdcm.tran_amt) as tran_amt , cdcm.foreign_exchange as status ,cdcm.ref_crncy_code as cur,
sum(cdcm.ref_amt) as ref_amt
     
  FROM tbaadm.gam gam, CUSTOM.c_denom_cash_maintenance cdcm
  where gam.foracid= cdcm.debit_foracid 
  and gam.sol_id  like '%' || ci_branchCode || '%'
  and cdcm.teller_id =upper(ci_user_id)
  and cdcm.tran_date =TO_DATE(CAST(ci_Date AS VARCHAR(10)),'dd-MM-yyyy')
  and cdcm.bank_id ='01'
  and gam.bank_id ='01'
  and cdcm.del_flg='N'
  and gam.del_flg='N'
    and trim (cdcm.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  group by cdcm.foreign_exchange,cdcm.ref_crncy_code)q)T)P;
   

   

  
  PROCEDURE FIN_MMK_FCY_BALANCE_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_USDopening_amt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_EURopening_amt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_SGDopening_amt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_THBopening_amt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_MMKopening_amt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_RCCUsdamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_RCCEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_RCCSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_RCCTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_RCCMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_PCUsdamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_PCEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_PCSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type; 
v_PCTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_PCMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TFUsdamt CUSTOM.c_denom_cash_maintenance.tran_amt%type; 
v_TFEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TFSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TFTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TFMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TTUsdamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TTEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TTSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TTTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_TTMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentDUSDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentDEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentDSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentDTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_CurrentDMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentWUSDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_CurrentWEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_CurrentWSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_CurrentWTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_CurrentWMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;

v_BUSDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_BEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_BSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_BTHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_BMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_SUSDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_SEURamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_SSGDamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
 v_STHBamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
v_SMMKamt CUSTOM.c_denom_cash_maintenance.tran_amt%type;
   
    
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
    
   
    vi_Date    :=  outArr(0);	
    vi_user_id  :=  outArr(1);	
     vi_branchCode :=  outArr(2);	
   
 --------------------------------------------------------------------------------------------------------------
 
 /* if( vi_Date is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
         out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
            '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 */
 ------------------------------------------------------------------------------------------------------------------
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_Date , vi_user_id,vi_branchCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_USDopening_amt , v_EURopening_amt,v_SGDopening_amt ,v_THBopening_amt ,
v_MMKopening_amt ,v_RCCUsdamt ,v_RCCEURamt ,v_RCCSGDamt ,v_RCCTHBamt ,
v_RCCMMKamt ,v_PCUsdamt ,v_PCEURamt ,v_PCSGDamt , v_PCTHBamt ,v_PCMMKamt ,
v_TFUsdamt , v_TFEURamt ,v_TFSGDamt ,v_TFTHBamt ,v_TFMMKamt ,v_TTUsdamt ,
v_TTEURamt ,v_TTSGDamt ,v_TTTHBamt ,v_TTMMKamt ,v_CurrentDUSDamt ,v_CurrentDEURamt ,
v_CurrentDSGDamt ,v_CurrentDTHBamt ,v_CurrentDMMKamt ,v_CurrentWUSDamt ,
 v_CurrentWEURamt ,v_CurrentWSGDamt ,v_CurrentWTHBamt ,v_CurrentWMMKamt ,
v_BUSDamt ,v_BEURamt ,v_BSGDamt ,v_BTHBamt , v_BMMKamt ,v_SUSDamt ,
 v_SEURamt , v_SSGDamt ,v_STHBamt ,v_SMMKamt ;
   
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
    -----------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    
    ------------------------------------------------------------
    out_rec:=	(
         v_USDopening_amt   || '|' ||
 v_EURopening_amt   || '|' ||
v_SGDopening_amt   || '|' ||
v_THBopening_amt   || '|' ||
v_MMKopening_amt   || '|' ||
v_RCCUsdamt   || '|' ||
v_RCCEURamt   || '|' ||
v_RCCSGDamt   || '|' ||
v_RCCTHBamt   || '|' ||
v_RCCMMKamt   || '|' ||
v_PCUsdamt   || '|' ||
v_PCEURamt   || '|' ||
v_PCSGDamt   || '|' || 
v_PCTHBamt   || '|' ||
v_PCMMKamt   || '|' ||
v_TFUsdamt   || '|' || 
v_TFEURamt   || '|' ||
v_TFSGDamt   || '|' ||
v_TFTHBamt   || '|' ||
v_TFMMKamt   || '|' ||
v_TTUsdamt   || '|' ||
v_TTEURamt   || '|' ||
v_TTSGDamt   || '|' ||
v_TTTHBamt   || '|' ||
v_TTMMKamt   || '|' ||
v_CurrentDUSDamt   || '|' ||
v_CurrentDEURamt   || '|' ||
v_CurrentDSGDamt   || '|' ||
v_CurrentDTHBamt   || '|' ||
 v_CurrentDMMKamt   || '|' ||
v_CurrentWUSDamt   || '|' ||
 v_CurrentWEURamt   || '|' ||
 v_CurrentWSGDamt   || '|' ||
 v_CurrentWTHBamt   || '|' ||
v_CurrentWMMKamt   || '|' ||

v_BUSDamt   || '|' ||
v_BEURamt   || '|' ||
v_BSGDamt   || '|' ||
v_BTHBamt   || '|' ||
 v_BMMKamt   || '|' ||
v_SUSDamt   || '|' ||
 v_SEURamt   || '|' ||
 v_SSGDamt   || '|' ||
 v_STHBamt   || '|' ||
v_SMMKamt   
    );
  
			dbms_output.put_line(out_rec);
    
  END FIN_MMK_FCY_BALANCE_STATEMENT;

END FIN_MMK_FCY_BALANCE_STATEMENT;
/
