CREATE OR REPLACE PACKAGE                      FIN_CBM_DC_POSITION AS 

 PROCEDURE FIN_CBM_DC_POSITION (	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
END FIN_CBM_DC_POSITION;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                        FIN_CBM_DC_POSITION AS



-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currencyType	   	Varchar2(30);              -- Input to procedure
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure


    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractDataMMK (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
 select q.bal_date,
        sum(q.Dr_Naypyitaw)/1000000,sum(q.Cr_Naypyitaw)/1000000,
        sum(q.Dr_Yangon)/1000000,sum(q.Cr_Yangon)/1000000,
        sum(q.Dr_Mandalay)/1000000,sum(q.Cr_Mandalay)/1000000,
        sum(q.Dr_Other)/1000000,sum(q.Cr_Other)/1000000                          
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where    gstt.bal_date =(select  bal_date   
            from(
              select bal_date
              from tbaadm.gstt gstt
              where gstt.bal_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              order by bal_date desc) where rownum =1)
             --gstt.bal_date >=  TO_DATE( CAST ( '11-4-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        and gstt.crncy_code = Upper('mmk' )
        and coa.cur =upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
        group by q.bal_date
        --) T
        --group by T.tran_date

union all
select q.bal_date,
        sum(q.Dr_Naypyitaw)/1000000,sum(q.Cr_Naypyitaw)/1000000,
        sum(q.Dr_Yangon)/1000000,sum(q.Cr_Yangon)/1000000,
        sum(q.Dr_Mandalay)/1000000,sum(q.Cr_Mandalay)/1000000,
        sum(q.Dr_Other)/1000000,sum(q.Cr_Other)/1000000                          
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where    /*gstt.bal_date =(select  bal_date   
            from(
              select bal_date
              from tbaadm.gstt gstt
              where gstt.bal_date < TO_DATE( CAST ( '11-4-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              order by bal_date desc) where rownum =1)*/
             gstt.bal_date >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        and gstt.crncy_code = Upper('mmk' )
        and coa.cur =upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
        group by q.bal_date;
        --) T
        --group by T.tran_date;

--------------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataAll (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
 select T.bal_date,
        sum(T.Dr_Naypyitaw)/1000000,sum(T.Cr_Naypyitaw)/1000000,
        sum(T.Dr_Yangon)/1000000,sum(T.Cr_Yangon)/1000000,
        sum(T.Dr_Mandalay)/1000000,sum(T.Cr_Mandalay)/1000000,
        sum(T.Dr_Other)/1000000,sum(T.Cr_Other)/1000000
  from ( select  q.bal_date,q.cur,
  CASE WHEN q.cur = 'MMK' THEN q.Dr_Naypyitaw
  ELSE q.Dr_Naypyitaw * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Naypyitaw,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Naypyitaw 
  ELSE q.Cr_Naypyitaw * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Naypyitaw,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Yangon
  ELSE q.Dr_Yangon * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Yangon, 
    CASE WHEN q.cur = 'MMK' THEN q.Cr_Yangon 
  ELSE q.Cr_Yangon * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Yangon , 
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Mandalay
  ELSE q.Dr_Mandalay * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Mandalay,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Mandalay 
  ELSE q.Cr_Mandalay * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Mandalay ,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Other
  ELSE q.Dr_Other * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Other,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Other 
  ELSE q.Cr_Other * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Other 
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other,
         gstt.crncy_code  as cur
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where    gstt.bal_date =(select  bal_date   
            from(
              select bal_date
              from tbaadm.gstt gstt
              where gstt.bal_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              order by bal_date desc) where rownum =1)
             --gstt.bal_date >=  TO_DATE( CAST ( '11-4-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        --and gstt.crncy_code = Upper('mmk' )
        --and coa.cur =upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
      --group by q.bal_date
      ) T
      group by T.bal_date
union all
select T.bal_date,
        sum(T.Dr_Naypyitaw)/1000000,sum(T.Cr_Naypyitaw)/1000000,
        sum(T.Dr_Yangon)/1000000,sum(T.Cr_Yangon)/1000000,
        sum(T.Dr_Mandalay)/1000000,sum(T.Cr_Mandalay)/1000000,
        sum(T.Dr_Other)/1000000,sum(T.Cr_Other)/1000000
from( select  q.bal_date,q.cur,
  CASE WHEN q.cur = 'MMK' THEN q.Dr_Naypyitaw
  ELSE q.Dr_Naypyitaw * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Naypyitaw,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Naypyitaw 
  ELSE q.Cr_Naypyitaw * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Naypyitaw,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Yangon
  ELSE q.Dr_Yangon * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Yangon, 
    CASE WHEN q.cur = 'MMK' THEN q.Cr_Yangon 
  ELSE q.Cr_Yangon * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Yangon , 
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Mandalay
  ELSE q.Dr_Mandalay * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Mandalay,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Mandalay 
  ELSE q.Cr_Mandalay * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Mandalay ,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Other
  ELSE q.Dr_Other * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Other,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Other 
  ELSE q.Cr_Other * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Other 
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other,
         gstt.crncy_code  as cur
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where    /*gstt.bal_date =(select  bal_date   
            from(
              select bal_date
              from tbaadm.gstt gstt
              where gstt.bal_date < TO_DATE( CAST ( '11-4-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              order by bal_date desc) where rownum =1)*/
             gstt.bal_date >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        --and gstt.crncy_code = Upper('mmk' )
        --and coa.cur =upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
        --group by q.bal_date
        ) T
        group by T.bal_date;
----------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataAllFCY (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
 select T.bal_date,
        sum(T.Dr_Naypyitaw)/1000000,sum(T.Cr_Naypyitaw)/1000000,
        sum(T.Dr_Yangon)/1000000,sum(T.Cr_Yangon)/1000000,
        sum(T.Dr_Mandalay)/1000000,sum(T.Cr_Mandalay)/1000000,
        sum(T.Dr_Other)/1000000,sum(T.Cr_Other)/1000000
from(select  q.bal_date,q.cur,
  CASE WHEN q.cur = 'MMK' THEN q.Dr_Naypyitaw
  ELSE q.Dr_Naypyitaw * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Naypyitaw,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Naypyitaw 
  ELSE q.Cr_Naypyitaw * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Naypyitaw,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Yangon
  ELSE q.Dr_Yangon * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Yangon, 
    CASE WHEN q.cur = 'MMK' THEN q.Cr_Yangon 
  ELSE q.Cr_Yangon * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Yangon , 
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Mandalay
  ELSE q.Dr_Mandalay * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Mandalay,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Mandalay 
  ELSE q.Cr_Mandalay * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Mandalay ,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Other
  ELSE q.Dr_Other * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Other,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Other 
  ELSE q.Cr_Other * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Other 
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other,
         gstt.crncy_code  as cur
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where    gstt.bal_date =(select  bal_date   
            from(
              select bal_date
              from tbaadm.gstt gstt
              where gstt.bal_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              order by bal_date desc) where rownum =1)
             --gstt.bal_date >=  TO_DATE( CAST ( '11-4-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        and gstt.crncy_code != Upper('mmk' )
        and coa.cur !=upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
      --group by q.tran_date
      ) T
      group by T.bal_date

union all
select T.bal_date,
        sum(T.Dr_Naypyitaw)/1000000,sum(T.Cr_Naypyitaw)/1000000,
        sum(T.Dr_Yangon)/1000000,sum(T.Cr_Yangon)/1000000,
        sum(T.Dr_Mandalay)/1000000,sum(T.Cr_Mandalay)/1000000,
        sum(T.Dr_Other)/1000000,sum(T.Cr_Other)/1000000
from(select  q.bal_date,q.cur,
  CASE WHEN q.cur = 'MMK' THEN q.Dr_Naypyitaw
  ELSE q.Dr_Naypyitaw * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Naypyitaw,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Naypyitaw 
  ELSE q.Cr_Naypyitaw * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Naypyitaw,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Yangon
  ELSE q.Dr_Yangon * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Yangon, 
    CASE WHEN q.cur = 'MMK' THEN q.Cr_Yangon 
  ELSE q.Cr_Yangon * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Yangon , 
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Mandalay
  ELSE q.Dr_Mandalay * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Mandalay,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Mandalay 
  ELSE q.Cr_Mandalay * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Mandalay ,
   CASE WHEN q.cur = 'MMK' THEN q.Dr_Other
  ELSE q.Dr_Other * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Dr_Other,
  CASE WHEN q.cur = 'MMK' THEN q.Cr_Other 
  ELSE q.Cr_Other * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cr_Other 
 from  (select  gstt.bal_date,
         case  when  sol.State_Code = '015' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Naypyitaw,
         case when  sol.STATE_CODE = '015'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Naypyitaw,
        case  when  sol.State_Code = '012' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Yangon,
         case when  sol.STATE_CODE = '012'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Yangon,
         case  when  sol.State_Code = '009' then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Mandalay,
         case when  sol.STATE_CODE = '009'  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Mandalay,
         case  when  sol.State_Code not in ('012','009','015') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as Dr_Other,
         case when  sol.STATE_CODE not in ('012','009','015')  then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as Cr_Other,
         gstt.crncy_code  as cur
         from     tbaadm.gstt gstt, custom.coa_mp coa, TBAADM.SERVICE_OUTLET_TABLE sol
         where   gstt.bal_date >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         and      gstt.bal_date <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and coa.gl_sub_head_code = gstt.gl_sub_head_code
        and coa.cur = gstt.crncy_code 
        and coa.group_code in ('A21','A23','A24','A25','A26','A27','A28')
        and gstt.crncy_code != Upper('mmk' )
        and coa.cur !=upper('MMK')
        and gstt.del_flg ='N'
        and gstt.bank_id ='01'
        and sol.bank_id ='01'
        and gstt.sol_id = sol.sol_id
        order by gstt.sol_id)q
        --group by q.tran_date
        ) T 
        group by T.bal_date;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_CBM_DC_POSITION (	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
 
 
  
    v_Debit_Naypyitaw TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Credit_Naypyitaw TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Debit_Yangon TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Credit_Yangon TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Debit_Mandalay TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Credit_Mandalay TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Debit_Other TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_Credit_Other TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_TranDate TBAADM.CTD_DTD_ACLI_VIEW.tran_date%type;
    
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
    
     vi_startDate :=  outArr(0);			
     vi_endDate   :=  outArr(1);
     vi_currencyType  := outArr(2);
  
  --------------------------------------------------------------------------------------------------
  
  if( vi_startDate is null or vi_endDate is null or  vi_currencyType is null   ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0  || '|' || 0 );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  
  --------------------------------------------------------------------------------------------------
   
        IF vi_currencyType ='MMK' then
            --{
        IF NOT ExtractDataMMK%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataMMK(	
          vi_startDate, vi_endDate
         );
          --}
          END;
    
        --}
        END IF;
    
        IF ExtractDataMMK%ISOPEN THEN
        --{
          FETCH	ExtractDataMMK
          INTO	 v_TranDate,
               v_Debit_Naypyitaw,v_Credit_Naypyitaw,v_Debit_Yangon,v_Credit_Yangon,v_Debit_Mandalay,v_Credit_Mandalay,
              v_Debit_Other,v_Credit_Other ;
          
  
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
     --} 

     ELSIF vi_currencyType ='All Currency' then
          --{
        IF NOT ExtractDataAll%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataAll(	
          vi_startDate, vi_endDate
         );
          --}
          END;
    
        --}
        END IF;
    
        IF ExtractDataAll%ISOPEN THEN
        --{
          FETCH	ExtractDataAll
          INTO	 v_TranDate,
               v_Debit_Naypyitaw,v_Credit_Naypyitaw,v_Debit_Yangon,v_Credit_Yangon,v_Debit_Mandalay,v_Credit_Mandalay,
              v_Debit_Other,v_Credit_Other ;
          
  
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
     --} 
     ELSE
        --{
        IF NOT ExtractDataAllFCY%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataAllFCY(	
          vi_startDate, vi_endDate
         );
          --}
          END;
    
        --}
        END IF;
    
        IF ExtractDataAllFCY%ISOPEN THEN
        --{
          FETCH	ExtractDataAllFCY
          INTO	 v_TranDate,
               v_Debit_Naypyitaw,v_Credit_Naypyitaw,v_Debit_Yangon,v_Credit_Yangon,v_Debit_Mandalay,v_Credit_Mandalay,
              v_Debit_Other,v_Credit_Other ;
          
  
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractDataAllFCY%NOTFOUND THEN
          --{
            CLOSE ExtractDataAllFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
     --}
     END IF;
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
				
           trim(to_char(to_date(v_TranDate,'dd-MM-yy'), 'dd-MM-yyyy')  )    			|| '|' ||
          v_Debit_Naypyitaw    			|| '|' ||
          v_Credit_Naypyitaw    		|| '|' ||
					v_Debit_Yangon	          || '|' ||
          v_Credit_Yangon           || '|' ||
          v_Debit_Mandalay          || '|' ||
          v_Credit_Mandalay         || '|' ||
          v_Debit_Other             || '|' ||
          v_Credit_Other
         );
  
			dbms_output.put_line(out_rec);
  END FIN_CBM_DC_POSITION;

END FIN_CBM_DC_POSITION;
/
