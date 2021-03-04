CREATE OR REPLACE PACKAGE        FIN_DEPOSIT_GP_BY_BRANCH AS 

   PROCEDURE FIN_DEPOSIT_GP_BY_BRANCH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DEPOSIT_GP_BY_BRANCH;
/


CREATE OR REPLACE PACKAGE BODY                                    FIN_DEPOSIT_GP_BY_BRANCH AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_eodDate	     	Varchar2(10);             
  vi_schmType		    Varchar2(3);		    	    -- Input to procedure
  vi_schmCode		     Varchar2(6);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_AccountType   Varchar2(20);		    	    -- Input to procedure
  v_description Varchar2(20);
  --limitsize       INTEGER := 200;
-----------------------------------------------------------------------------
-- CURSOR ExtractData1
-----------------------------------------------------------------------------
CURSOR ExtractData1 (	ci_eodDate VARCHAR2,
  ci_schmType VARCHAR2, ci_schmCode VARCHAR2, ci_branchCode VARCHAR2)
  IS
  select
    a.REF_DESC,
    a.sol_desc,
    --a.sol_id,
    nvl(a.type1Total,0.00),
    nvl(a.countT1,0),
    nvl(b.type2Total,0.00),
    nvl(b.countT2,0),
    nvl(c.type3Total,0.00),
    nvl(c.countT3,0),
    nvl(d.type4Total,0.00),
    nvl(d.countT4,0),
    nvl(e.type5Total,0.00),
    nvl(e.countT5,0),
    nvl(f.type6Total,0.00),
    nvl(f.countT6,0),
    nvl(g.type7Total,0.00),
    nvl(g.countT7,0),
    nvl(h.type8Total,0.00),
    nvl(h.countT8,0)
    from
    (select count(*) as countT1,
        sum(t.type1Total) as type1Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS type1Total,
      sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
     -- ,count(*) as countT1
    from 
      TBAADM.GAM GAM,
      tbaadm.sol sol, 
      TBAADM.RCT rct,
      CUSTOM.custom_ctd_dtd_acli_view ctd
    where 
      ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      and gam.acid = ctd.acid
      and ctd.part_tran_type = 'C'
      AND GAM.del_flg = 'N'
      AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
       AND GAM.SOL_ID like '%' || ci_branchCode || '%'
       AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
      and GAM.ACCT_CLS_FLG = 'N'
      and gam.schm_type not in ('OAB','OAP','OAD')
     -- and gam.acct_crncy_code <>'MMK'
   --   and gam.schm_code not in ('AGDOD')
      --and GAM.SCHM_CODE = ci_schmCode
      and rct.ref_rec_type = '02' 
      and rct.REF_CODE = sol.STATE_CODE
      and sol.sol_id = GAM.SOL_ID 
      and ctd.tran_amt >= 0 
      and ctd.tran_amt < 100000
     )t
     where t.type1Total >= 0 
      and  t.type1Total < 100000
     group by  t.sol_desc , t.ref_desc,t.sol_id) a
      
      left join
      
      (select count(*) as countT2,
        sum(t.type2Total) as type2Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type2Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
                and gam.schm_type not in ('OAB','OAP','OAD')
               -- and gam.acct_crncy_code <>'MMK'
               -- and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 100000  
                and ctd.tran_amt < 500000
               )t
               where t.type2Total >= 100000 
               and  t.type2Total < 500000
               group by  t.sol_desc , t.ref_desc,t.sol_id
      ) b on a.sol_id = b.sol_id
      
      left join
      
      (select count(*) as countT3,
        sum(t.type3Total) as type3Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type3Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
               -- and gam.acct_crncy_code <>'MMK'
                --and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and gam.schm_type not in ('OAB','OAP','OAD')
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 500000  
                and ctd.tran_amt < 1000000
               )t
               where t.type3Total >= 500000 
               and  t.type3Total < 1000000
               group by  t.sol_desc , t.ref_desc,t.sol_id
     ) c on a.sol_id = c.sol_id
      
      left join
      
      (select count(*) as countT4,
        sum(t.type4Total) as type4Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type4Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                 AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
               -- and gam.acct_crncy_code <>'MMK'
                --and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and gam.schm_type not in ('OAB','OAP','OAD')
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 1000000  
                and ctd.tran_amt < 5000000
               )t
               where t.type4Total >= 1000000 
               and  t.type4Total < 5000000
               group by  t.sol_desc , t.ref_desc,t.sol_id
        ) d on a.sol_id = d.sol_id
      
      left join
      
      (select count(*) as countT5,
        sum(t.type5Total) as type5Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type5Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
               -- and gam.acct_crncy_code <>'MMK'
               -- and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and gam.schm_type not in ('OAB','OAP','OAD')
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 5000000 
                and ctd.tran_amt < 10000000
               )t
               where t.type5Total >= 5000000 
               and  t.type5Total < 10000000
               group by  t.sol_desc , t.ref_desc,t.sol_id
          ) e on a.sol_id = e.sol_id
      
      left join
      
      (select count(*) as countT6,
        sum(t.type6Total) as type6Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type6Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                 AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
               -- and gam.acct_crncy_code <>'MMK'
               -- and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and gam.schm_type not in ('OAB','OAP','OAD')
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 10000000 
                and ctd.tran_amt < 50000000
               )t
                where t.type6Total >= 10000000 
               and  t.type6Total < 50000000
               group by  t.sol_desc , t.ref_desc,t.sol_id
          ) f on a.sol_id = f.sol_id
      
        left join
      
      (select count(*) as countT7,
        sum(t.type7Total) as type7Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type7Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                 AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
               -- and gam.acct_crncy_code <>'MMK'
                --and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and gam.schm_type not in ('OAB','OAP','OAD')
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 50000000  
                and ctd.tran_amt < 100000000
               )t
               where t.type7Total >= 50000000 
               and  t.type7Total < 100000000
               group by  t.sol_desc , t.ref_desc,t.sol_id
      ) g on a.sol_id = g.sol_id
      
      left join
      
      (select count(*) as countT8,
        sum(t.type8Total) as type8Total,
       t.sol_desc , t.ref_desc,t.sol_id
     
      from   (select 
        CASE WHEN gam.acct_crncy_code = 'MMK' THEN ctd.tran_amt 
        ELSE ctd.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS type8Total,
                sol.sol_desc, rct.REF_DESC, GAM.SOL_ID
               -- ,count(*) as countT1
              from 
                TBAADM.GAM GAM,
                tbaadm.sol sol, 
                TBAADM.RCT rct,
                CUSTOM.custom_ctd_dtd_acli_view ctd
              where 
                ctd.tran_date = TO_DATE( CAST ( ci_eodDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                and gam.acid = ctd.acid
                and ctd.part_tran_type = 'C'
                AND GAM.del_flg = 'N'
                 AND GAM.SCHM_TYPE like '%' || ci_schmType || '%'
                 AND GAM.SOL_ID like '%' || ci_branchCode || '%'
                 AND GAM.SCHM_CODE  like '%' || ci_schmCode || '%'
                and GAM.ACCT_CLS_FLG = 'N'
                and gam.schm_type not in ('OAB','OAP','OAD')
               -- and gam.acct_crncy_code <>'MMK'
               -- and gam.schm_code not in ('AGDOD')
                --and GAM.SCHM_CODE = ci_schmCode
                and rct.ref_rec_type = '02' 
                and rct.REF_CODE = sol.STATE_CODE
                and sol.sol_id = GAM.SOL_ID 
                and ctd.tran_amt >= 100000000  
                and ctd.tran_amt < 99999999999
               )t
               where t.type8Total >= 100000000 
               and  t.type8Total < 99999999999
               group by  t.sol_desc , t.ref_desc,t.sol_id
          ) h on a.sol_id = h.sol_id;


  PROCEDURE FIN_DEPOSIT_GP_BY_BRANCH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
    -- Type 1  
----------------------------------------------------------------------------------
    v_sol_desc varchar2(100);
    Type1_count Number;
    Type1_amount number(20,2);
    Type2_count Number;
    Type2_amount number(20,2);
    Type3_count Number;
    Type3_amount number(20,2);
    Type4_count Number;
    Type4_amount number(20,2);
    Type5_count Number;
    Type5_amount number(20,2);
    Type6_count Number;
    Type6_amount number(20,2);
    Type7_count Number;
    Type7_amount number(20,2);
    Type8_count Number;
    Type8_amount number(20,2);
     v_state varchar2(100);
    
          
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
    vi_eodDate	  :=outArr(0);		  
    vi_SchmType 	:=outArr(1);	
    vi_schmCode 	:=outArr(2);	
     vi_AccountType :=outArr(3);
     vi_branchCode :=outArr(4);	
    
  
  -------------------------------------------------------------
   		  
if( vi_eodDate is null   ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0|| '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
              0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0);
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

------------------------------------------------------------
If vi_branchCode is null or vi_branchCode ='' then
   vi_branchCode := '';
end if;

  
  if vi_AccountType is null then
        vi_schmCode := '';
        vi_SchmType := '';
  elsif vi_AccountType like 'Regular Saving' then
        vi_schmCode := 'SAREG';
        vi_SchmType := 'Saving';
  elsif vi_AccountType like 'Special Saving' then
        vi_schmCode := 'SASPL';
        vi_SchmType := 'SBA';
  elsif vi_AccountType like 'Current' then
        vi_schmCode := 'AG%C%';
        vi_SchmType := 'CAA';
  elsif vi_AccountType like 'Fixed' then
        vi_schmCode := 'AGDFD';
        vi_SchmType := 'CAA';
  elsif vi_AccountType like 'Normal Loan' then
        vi_schmCode := 'AGDNL';
        vi_SchmType := 'LAA';
  elsif vi_AccountType like 'Staff Loan' then
        vi_schmCode := 'AGSS1';
        vi_SchmType := 'LAA';
  elsif vi_AccountType like 'Hire Purchase' then
        vi_schmCode := 'AG%HP%';
        vi_SchmType := 'LAA';
  elsif vi_AccountType like 'Overdraft' then
        vi_schmCode := 'AGDOD';
        vi_SchmType := 'CAA';
  else  
        vi_schmCode := '';
        vi_SchmType := '';
  end if;
  
  -----------------------------------------------------------
    
    IF NOT ExtractData1%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData1 (	
			vi_eodDate  , vi_SchmType , 
      vi_schmCode , vi_branchCode  );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData1%ISOPEN THEN
		--{
			FETCH	ExtractData1 
			INTO	 v_state,v_sol_desc ,
               Type1_amount, Type1_count ,
              Type2_amount ,Type2_count ,
              Type3_amount ,Type3_count ,
              Type4_amount ,Type4_count ,
             Type5_amount , Type5_count ,
              Type6_amount ,Type6_count ,
             Type7_amount , Type7_count ,
              Type8_amount ,Type8_count ;
      
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData1%NOTFOUND THEN
			--{
				CLOSE ExtractData1;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
----------------------------------------------------------------------------------
  
    out_rec:=	(
              v_sol_desc || '|' ||
              Type1_count || '|' ||
              Type1_amount|| '|' || 
              Type2_count || '|' ||
              Type2_amount || '|' ||
              Type3_count || '|' ||
              Type3_amount || '|' ||
              Type4_count || '|' ||
              Type4_amount || '|' ||
              Type5_count || '|' ||
              Type5_amount || '|' ||
              Type6_count || '|' ||
              Type6_amount || '|' ||
              Type7_count || '|' ||
              Type7_amount || '|' ||
              Type8_count || '|' ||
              Type8_amount || '|' ||
              v_state);
  
			dbms_output.put_line(out_rec);
    
  END FIN_DEPOSIT_GP_BY_BRANCH;

END FIN_DEPOSIT_GP_BY_BRANCH;
/
