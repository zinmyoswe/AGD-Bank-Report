CREATE OR REPLACE PACKAGE               FIN_BRANCH_DL_CASHHAND_COND AS 

PROCEDURE FIN_BRANCH_DL_CASHHAND_COND(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BRANCH_DL_CASHHAND_COND;
 
/


CREATE OR REPLACE PACKAGE BODY FIN_BRANCH_DL_CASHHAND_COND
AS
  /******************************************************************************
  NAME:       FIN_INC_DEC_DEPOSIT_LOAN
  PURPOSE:
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ---------------------------------------
  1.0        11/29/2016      Administrator       1. Created this package body.
  ******************************************************************************/
  --------------------------------------------------------------------------------
  
  --Update User- Saung Hnin OO
  --Date -15-5-2017
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  --------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_tranDate VARCHAR2(10);         -- Input to procedure

  --------------------------------------------------------------------------------
  -- CURSOR declaration FIN_INC_DEC_DEPOSIT_LOAN CURSOR
  --------------------------------------------------------------------------------
  
  --------------------------------------------------------------------------------
  -- CURSOR ExtractData
  --------------------------------------------------------------------------------
  CURSOR ExtractData (ci_tranDate VARCHAR2)
  IS
  SELECT T.SOL_ID,
        SOT.SOL_DESC,
       SOT.br_open_date,
       SUM(T.CurrentCount) AS CurrentCount,
       SUM(T.CurrenctAmount) as CurrenctAmount,
         SUM(T.SavingCount) AS SavingCount,
      SUM(T.SavingAmount) as SavingAmount,
       SUM(T.SpecialCount) AS SpecialCount,
      SUM(T.SpecialAmount) as SpecialAmount,
       SUM(T.FixedCount) AS FixedCount,
      SUM(T.FixedAmount) as FixedAmount,
       SUM(T.LoanCount) AS LoanCount,
      SUM(T.LoanAmount) as LoanAmount,
      SUM(T.ODCount) AS ODCount,
      SUM(T.ODAmount) as ODAmount,
      SUM(T.HPCount) AS HPCount,
      SUM(T.HPAmount) as HPAmount,
       SUM(T.StaffCount) AS StaffCount,
      SUM(T.StaffAmount) as StaffAmount,  
       SUM(T.CIHMMK) AS CIHMMK
     
      
    FROM (
      SELECT GAM.SOL_ID,
             COUNT(*) AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
           
             
             FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and    ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
   AND coa.group_code in ('L11','L21','L22')
      AND    GAM.del_flg = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id

          UNION ALL
             
    SELECT GAM.SOL_ID,
             COUNT(*) AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
              0 as CIHMMK
     FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and    ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
  AND coa.group_code in ('L11','L21','L22')
--      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.del_flg = 'N'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
          
         SELECT Q.SOL_ID,
                 SUM(Q.CurrentCount)  AS CurrentCount,
                 SUM(Q.CurrentAmount) AS CurrentAmount,
                   0 as SavingCount,
                                 0 AS SavingAmount,
                                 0 AS SpecialCount,
                                 0 as SpecialAmount,
                                 0 as FixedCount,
                                 0 as FixedAmount,    
                                 0 AS LoanCount,
                                 0 as LoanAmount,
                                 0 as ODCount,
                                 0 as ODAmount,
                                 0 as HPCount,
                                 0 AS HPAmount,
                                 0 AS StaffCount,
                                 0 AS StaffAmount,
                                 0 as CIHMMK
                              
                 
          FROM (SELECT  gstt.SOL_ID,
                                0 AS CurrentCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS CurrentAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L11','L21','L22')

                       
                       
                      )Q
                GROUP BY Q.SOL_ID
          
   Union all
         
          
           SELECT GAM.SOL_ID,
           0 AS CurrentCount,
             0 AS CurrenctAmount,
               COUNT(*) as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
            
             
                FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and      ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND coa.group_code in  ('L13','L24')
   --   AND    GAM.ACCT_CLS_FLG = 'N'
   AND    GAM.del_flg = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
       
    UNION ALL
    
      SELECT GAM.SOL_ID,
           0 AS CurrentCount,
             0 AS CurrenctAmount,
               COUNT(*) as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
            
     FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND coa.group_code in  ('L13','L24')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
     AND    GAM.del_flg = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
          
         SELECT Q.SOL_ID,
       
                                  0  AS CurrentCount,
                                0 AS CurrentAmount,
                        SUM(Q.SavingCount)  as SavingCount,
                       SUM(Q.SavingAmount)          AS SavingAmount,
                                 0 AS SpecialCount,
                                 0 as SpecialAmount,
                                 0 as FixedCount,
                                 0 as FixedAmount,    
                                 0 AS LoanCount,
                                 0 as LoanAmount,
                                 0 as ODCount,
                                 0 as ODAmount,
                                 0 as HPCount,
                                 0 AS HPAmount,
                                 0 AS StaffCount,
                                 0 AS StaffAmount,
                                 0 as CIHMMK
                               
                 
          FROM (
                        SELECT  gstt.SOL_ID,
                                0 AS SavingCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS SavingAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in  ('L13','L24')

                       
                       
                      )Q
                GROUP BY Q.SOL_ID
                
                
                Union all
         
          
           SELECT GAM.SOL_ID,
           0 AS CurrentCount,
             0 AS CurrenctAmount,
               0 as SavingCount,
             0 AS SavingAmount,
             COUNT(*) AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
          
             
             FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      AND    GAM.del_flg = 'N'
      and     ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND coa.group_code in ('L15')
    --  AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
       
    UNION ALL
    
      SELECT GAM.SOL_ID,
           0 AS CurrentCount,
             0 AS CurrenctAmount,
               0 as SavingCount,
             0 AS SavingAmount,
             COUNT(*) AS SpecialCount,
             0 as SpecialAmount,
             0 as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
          
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
      AND    GAM.del_flg = 'N'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND coa.group_code in ('L15')
    --  AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
          
         SELECT Q.SOL_ID,
       
                                  0  AS CurrentCount,
                                0 AS CurrentAmount,
                       0  as SavingCount,
                           0     AS SavingAmount,
                          SUM(Q.SpecialCount)         AS SpecialCount,
                          SUM(Q.SpecialAmount)        as SpecialAmount,
                                 0 as FixedCount,
                                 0 as FixedAmount,    
                                 0 AS LoanCount,
                                 0 as LoanAmount,
                                 0 as ODCount,
                                 0 as ODAmount,
                                 0 as HPCount,
                                 0 AS HPAmount,
                                 0 AS StaffCount,
                                 0 AS StaffAmount,
                                 0 as CIHMMK
                                 
                 
          FROM (
                        SELECT  gstt.SOL_ID,
                                0 AS SpecialCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS SpecialAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L15')

                       
                      )Q
                GROUP BY Q.SOL_ID
          union all

 SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            COUNT(*) as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
          
               FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
        and     ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
      AND    GAM.del_flg = 'N'
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
  AND coa.group_code in ('L17','L26')
 --     AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id

          UNION ALL
          
            SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            COUNT(*) as FixedCount,
             0 as FixedAmount,    
             0 AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
        FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and      ( schm_type in ('CAA','TDA','SBA')
      and schm_code <> 'AGDOD')
      AND    GAM.del_flg = 'N'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND coa.group_code in ('L17','L26')
  --    AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
          
         SELECT Q.SOL_ID,
               0  AS CurrentCount,
               0 AS CurrentAmount,
                   0 as SavingCount,
                                 0 AS SavingAmount,
                                 0 AS SpecialCount,
                                 0 as SpecialAmount,
                   SUM(Q.FixedCount) as FixedCount,
                   SUM(Q.FixedAmount) as FixedAmount,    
                                 0 AS LoanCount,
                                 0 as LoanAmount,
                                 0 as ODCount,
                                 0 as ODAmount,
                                 0 as HPCount,
                                 0 AS HPAmount,
                                 0 AS StaffCount,
                                 0 AS StaffAmount,
                                 0 as CIHMMK
                               
                 
          FROM (  SELECT  gstt.SOL_ID,
                                0 AS FixedCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS FixedAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L17','L26')

                      )Q
                GROUP BY Q.SOL_ID
 
 union all 
 
  SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
             COUNT(*) AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
             
             
                FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and  (   schm_type in ('LAA') or schm_code like 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
   AND coa.group_code in ('A21')
   AND    GAM.del_flg = 'N'
 --     AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
            
      union all      
               
                 SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
             COUNT(*) AS LoanCount,
             0 as LoanAmount,
             0 as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
     FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
       and      (   schm_type in ('LAA') or schm_code like 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND coa.group_code in ('A21')
  --    AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.del_flg = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
     
         SELECT Q.SOL_ID,
               0  AS CurrentCount,
               0 AS CurrentAmount,
                   0 as SavingCount,
                                 0 AS SavingAmount,
                                 0 AS SpecialCount,
                                 0 as SpecialAmount,
                  0 as FixedCount,
                0 as FixedAmount,    
                               SUM(Q.LoanCount) AS LoanCount,
                                SUM(Q.LoanAmount) as LoanAmount,
                                 0 as ODCount,
                                 0 as ODAmount,
                                 0 as HPCount,
                                 0 AS HPAmount,
                                 0 AS StaffCount,
                                 0 AS StaffAmount,
                                 0 as CIHMMK
                               
                 
          FROM (
                     SELECT  gstt.SOL_ID,
                                0 AS LoanCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS LoanAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A21')
                       
                       
                       
                       
                      )Q
                GROUP BY Q.SOL_ID

 union all 
 
 SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
           COUNT(*) as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
          
             
              FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
    and     (   schm_type in ('LAA') or schm_code like 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND coa.group_code in ('A23')
    AND    GAM.del_flg = 'N'
   --   AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
            union all 
   
     SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
           COUNT(*) as ODCount,
             0 as ODAmount,
             0 as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
     FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
     and    (   schm_type in ('LAA') or schm_code like 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
       AND coa.group_code in ('A23')
  --    AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.del_flg = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     union all 
   
         SELECT Q.SOL_ID,
                 0  AS CurrentCount,
                 0 AS CurrentAmount,
                 0 as SavingCount,
                 0 AS SavingAmount,
                 0 AS SpecialCount,
                 0 as SpecialAmount,
               0 as FixedCount,
                0 as FixedAmount,    
                          0     AS LoanCount,
                         0 as LoanAmount,
                         SUM(Q.ODCount)  as ODCount,
                          SUM(Q.ODAmount) as ODAmount,
                          0 as HPCount,
                          0 AS HPAmount,
                          0 AS StaffCount,
                          0 AS StaffAmount,
                          0 as CIHMMK
                         
                 
          FROM (
                        SELECT  gstt.SOL_ID,
                                0 AS ODCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS ODAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A23')
                       
                       
                       
                      )Q
                GROUP BY Q.SOL_ID


 
                 union all

 SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
         0 as ODCount,
             0 as ODAmount,
       COUNT(*) as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
            
             
              FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
       and     (   schm_type in ('LAA') or schm_code like 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
   AND coa.group_code in ('A24')
   AND    GAM.del_flg = 'N'
  --    AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
            union all 
   
     SELECT  GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
         0 as ODCount,
             0 as ODAmount,
       COUNT(*) as HPCount,
             0 AS HPAmount,
             0 AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
        FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
         and     (   schm_type in ('LAA') or schm_code like 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND coa.group_code in ('A24')
    AND    GAM.del_flg = 'N'
   --   AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     
     union all 
     
         SELECT Q.SOL_ID,
           0  AS CurrentCount,
           0 AS CurrentAmount,
           0 as SavingCount,
           0 AS SavingAmount,
           0 AS SpecialCount,
           0 as SpecialAmount,
           0 as FixedCount,
           0 as FixedAmount,    
           0     AS LoanCount,
           0 as LoanAmount,
           0  as ODCount,
           0 as ODAmount,
           SUM(Q.HPCount) as HPCount,
           SUM(Q.HPAmount)             AS HPAmount,
           0   AS StaffCount,
           0     AS StaffAmount,
           0 as CIHMMK
        
          FROM (
                        SELECT  gstt.SOL_ID,
                                0 AS HPCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS HPAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A24')
                       
                       
                      )Q
                GROUP BY Q.SOL_ID    
                
                union all
                
                 SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
         0 as ODCount,
             0 as ODAmount,
     0 as HPCount,
             0 AS HPAmount,
              COUNT(*) AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
           
             
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
       and    (   schm_type in ('LAA') or schm_code like 'AGDOD')
     -- AND    GAM.acct_opn_date = TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
    AND    COA.GROUP_CODE IN ('A25')
  --    AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.del_flg = 'N'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
            
            union all 
   
      SELECT GAM.SOL_ID,
            0 AS CurrentCount,
             0 AS CurrenctAmount,
             0 as SavingCount,
             0 AS SavingAmount,
             0 AS SpecialCount,
             0 as SpecialAmount,
            0 as FixedCount,
             0 as FixedAmount,    
         0 AS LoanCount,
             0 as LoanAmount,
         0 as ODCount,
             0 as ODAmount,
     0 as HPCount,
             0 AS HPAmount,
              COUNT(*) AS StaffCount,
             0 AS StaffAmount,
             0 as CIHMMK
        FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
     and     (   schm_type in ('LAA') or schm_code like 'AGDOD')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND coa.group_code in ('A25')
    --  AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.del_flg = 'N'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id
     
     union all 
   
         SELECT Q.SOL_ID,
           0  AS CurrentCount,
           0 AS CurrentAmount,
           0 as SavingCount,
           0 AS SavingAmount,
           0 AS SpecialCount,
           0 as SpecialAmount,
           0 as FixedCount,
           0 as FixedAmount,    
           0     AS LoanCount,
           0 as LoanAmount,
           0  as ODCount,
           0 as ODAmount,
         0 as HPCount,
          0             AS HPAmount,
          SUM(Q.StaffCount)   AS StaffCount,
          SUM(Q.StaffAmount)    AS StaffAmount,
           0 as CIHMMK
          
                 
          FROM (
                        SELECT  gstt.SOL_ID,
                                0 AS StaffCount,
                                CASE WHEN coa.cur = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                                ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(coa.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS StaffAmount
                               
                               
                  FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A25')
                      )Q
                GROUP BY Q.SOL_ID    
                
                
       union all 
              
               SELECT Q.SOL_ID,
                0  AS CurrentCount,
                0 AS CurrentAmount,
                0 as SavingCount,
                0 AS SavingAmount,
                0 AS SpecialCount,
                0 as SpecialAmount,
                0 as FixedCount,
                0 as FixedAmount,    
                0 AS LoanCount,
                0 as LoanAmount,
                0 as ODCount,
                0 as ODAmount,
                0 as HPCount,
                0 AS HPAmount,
                 0 AS StaffCount,
                  0 AS StaffAmount,
                                  SUM(Q.CIHMMK)  as CIHMMK
                                  
                 
          FROM (
                        SELECT  GAM.SOL_ID,
                               
                                CASE WHEN gam.acct_crncy_code = 'MMK' THEN EAB.TRAN_DATE_BAL
                                ELSE EAB.TRAN_DATE_BAL * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(gam.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS CIHMMK
                               
                               
                        FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                        WHERE  EAB.ACID = GAM.ACID
                        AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                        AND    COA.CUR = gam.acct_crncy_code
                        and    gam.acct_crncy_code = eab.eab_crncy_code
                     
                        AND coa.group_code in ('A01','A02','A03')
                        --AND    GAM.acct_opn_date <= TO_DATE(CAST('24-04-2017' AS VARCHAR(10)), 'dd-MM-yyyy') 
                        AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                        AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                        --AND    GAM.ACCT_CLS_FLG = 'N'
                        AND    GAM.BANK_ID = '01'
                        AND    GAM.del_flg = 'N'
                        AND    GAM.ENTITY_CRE_FLG = 'Y'
                       
                       
                      )Q
                      
                  GROUP BY Q.SOL_ID
                  
         )T, TBAADM.SERVICE_OUTLET_TABLE SOT
    where SOT.SOL_ID = T.SOL_ID
    GROUP BY T.SOL_ID,SOT.SOL_DESC,SOT.br_open_date
    ORDER BY T.SOL_ID,SOT.br_open_date
    ;
    
PROCEDURE FIN_BRANCH_DL_CASHHAND_COND(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_solID TBAADM.SERVICE_OUTLET_TABLE.SOL_ID%type;
  v_solDesc TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%type;
   v_Open_Date      TBAADM.SERVICE_OUTLET_TABLE.br_open_date%TYPE;
  v_CurrentCount NUMBER(20);
  v_CurrenctAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_SavingCount NUMBER(20);
  v_SavingAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_SpecialCount NUMBER(20);
  v_SpecialAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_FixedCount NUMBER(20);
  v_FixedAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
    v_LoanCount NUMBER(20);
  v_LoanAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_ODCount NUMBER(20);
  v_ODAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_HPCount NUMBER(20);
  v_HPAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_StaffCount NUMBER(20);
  v_StaffAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_CIHMMK TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  
 
 
BEGIN
  -- TODO: Implementation required for PROCEDURE FIN_INC_DEC_DEPOSIT_LOAN.FIN_INC_DEC_DEPOSIT_LOAN
  ------------------------------------------------------------------------------
  -- Out Ret code is the code which controls
  -- the while loop,it can have values 0,1
  -- 0 - The while loop is being executed
  -- 1 - Exit
  ------------------------------------------------------------------------------
  out_retCode := 0;
  out_rec     := NULL;
  tbaadm.basp0099.formInputArr(inp_str, outArr);
  ------------------------------------------------------------------------------
  -- Parsing the i/ps from the string
  ------------------------------------------------------------------------------
  vi_tranDate   := outArr(0);
 
  
  
 
 
  ------------------------------------------------------------------------
  
 
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_tranDate  );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{

			FETCH	ExtractData
			INTO	  v_solID, 
 
  v_solDesc ,
   v_Open_Date    ,  
  v_CurrentCount ,
  v_CurrenctAmount ,
  v_SavingCount,
  v_SavingAmount ,
  v_SpecialCount,
  v_SpecialAmount ,
  v_FixedCount,
  v_FixedAmount ,
    v_LoanCount ,
  v_LoanAmount ,
  v_ODCount,
  v_ODAmount ,
  v_HPCount,
  v_HPAmount ,
  v_StaffCount,
  v_StaffAmount ,
  v_CIHMMK;
  

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
 
  --------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  --------------------------------------------------------------------------------
  out_rec:= ( v_solID  || '|' || 
  v_solDesc   || '|' || 
  v_CurrentCount   || '|' || 
  v_CurrenctAmount  || '|' || 
  v_savingcount  || '|' || 
  v_SavingAmount  || '|' || 
  v_SpecialCount || '|' || 
  v_SpecialAmount  || '|' || 
  v_FixedCount || '|' || 
  v_FixedAmount  || '|' ||
    v_LoanCount || '|' ||
  v_LoanAmount || '|' ||
  v_ODCount  || '|' ||
  v_ODAmount || '|' ||
  v_HPCount || '|' ||
  v_HPAmount || '|' ||
  v_StaffCount || '|' ||
  v_StaffAmount || '|' ||
  v_CIHMMK 
  );
         
  dbms_output.put_line(out_rec);
END FIN_BRANCH_DL_CASHHAND_COND;
END FIN_BRANCH_DL_CASHHAND_COND;
/
