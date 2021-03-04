CREATE OR REPLACE PACKAGE FIN_INC_DEC_DEPOSIT_LOAN AS 

  PROCEDURE FIN_INC_DEC_DEPOSIT_LOAN(	inp_str      IN VARCHAR2,
                                      out_retCode  OUT NUMBER,
                                      out_rec      OUT VARCHAR2 );

END FIN_INC_DEC_DEPOSIT_LOAN;
/


CREATE OR REPLACE PACKAGE BODY               FIN_INC_DEC_DEPOSIT_LOAN
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
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  --------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_tranDate    VARCHAR2(10);         -- Input to procedure
  vi_tranType    VARCHAR2(50);         -- Input to procedure
  vi_AccountType VARCHAR2(20);         -- Input to procedure
  v_description varchar2(20);
  --------------------------------------------------------------------------------
  -- CURSOR declaration FIN_INC_DEC_DEPOSIT_LOAN CURSOR
  --------------------------------------------------------------------------------
   v_odDate Varchar2(10);
  --------------------------------------------------------------------------------
  -- CURSOR ExtractData
  --------------------------------------------------------------------------------
  CURSOR ExtractDataDeposit (ci_tranDate VARCHAR2,ci_odDate VARCHAR2)
  IS
   SELECT T.SOL_ID,
        SOT.SOL_DESC,
       SUM(T.BFAccountNumber) AS BFAccountNumber,
       SUM(T.BDAmount) as BDAmount,
       SUM(T.AccountNumber) as AccountNumber,
       SUM(T.Amount) as Amount,
       SUM(T.AccountNumber)-SUM(T.BFAccountNumber) as DiffBFAccount,
       SUM(T.Amount)-SUM(T.BDAmount) as DiffAccount
    FROM (
         SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
       SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
       SELECT GAM.SOL_ID,
       COUNT(*)*-1 AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
       AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'Y'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
    /*  UNION ALL
    
    SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
          UNION ALL
          
         SELECT Q.SOL_ID,
                 SUM(Q.BFAccountNumber)  AS BFAccountNumber,
                 SUM(Q.BDAmount) AS BDAmount,
                 SUM(Q.AccountNumber) as AccountNumber,
                 SUM(Q.Amount) AS Amount
          FROM (
                  SELECT  gstt.SOL_ID,
                          0 AS BFAccountNumber,
                         -- Sum(EAB.TRAN_DATE_BAL) AS BDAmount,
                          CASE WHEN  Gstt.Crncy_Code = 'MMK' THEN (Gstt.tot_cr_bal-Gstt.tot_dr_bal) 
                           ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal)  * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(Gstt.Crncy_Code) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(Gstt.Crncy_Code)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),0) END   as BDAmount,
                          0 as AccountNumber,
                          0 AS Amount
                         
                   from         
                   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  where
                    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
                  --   And Gstt.Sol_Id=Gsh.Sol_Id
                    -- And Gsh.Crncy_Code = Coa.Cur
                     And coa.cur = Gstt.Crncy_Code
                    -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
                     and gstt.BAL_DATE <= TO_DATE( ci_odDate, 'dd-MM-yyyy' )
                     And Gstt.End_Bal_Date >= To_Date(ci_odDate, 'dd-MM-yyyy' )
                     And    Coa.Group_Code In ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
                    -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
                     and gstt.DEL_FLG = 'N'
                     And Gstt.Bank_Id = '01'
                    
                 
                 
                )Q
          GROUP BY Q.SOL_ID
          
          
          UNION ALL
          
          SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date < TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
       SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
        SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*)*-1 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_cls_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'Y'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
     /* UNION ALL
    
    SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_type in ('CAA','TDA','SBA')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
          
          UNION ALL
          
          SELECT Q.SOL_ID,
           SUM(Q.BFAccountNumber) AS BFAccountNumber,
           SUM(Q.BDAmount) AS BDAmount,
           SUM(Q.AccountNumber)as AccountNumber,
           SUM(Q.Amount) AS Amount
          FROM (
                  SELECT gstt.SOL_ID,
                          0 AS BFAccountNumber,
                          0 AS BDAmount,
                          0 as AccountNumber,
                         -- Sum(EAB.TRAN_DATE_BAL) AS Amount
                          CASE WHEN Gstt.Crncy_Code = 'MMK' THEN (Gstt.tot_cr_bal-Gstt.tot_dr_bal) 
                          ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal)  * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(Gstt.Crncy_Code) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS Amount
                         
                   from         
                   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  Where
                    gstt.gl_sub_head_code = coa.gl_sub_head_code
                    -- and gstt.sol_id=gsh.sol_id
                    -- And Gsh.Crncy_Code = Coa.Cur
                    -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
                     and gstt.BAL_DATE <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
                     And Gstt.End_Bal_Date >= To_Date(ci_tranDate, 'dd-MM-yyyy' )
                     And    Coa.Group_Code In ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
                    -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
                     and gstt.DEL_FLG = 'N'
                     and gstt.BANK_ID = '01'
                     And coa.cur = Gstt.Crncy_Code
                  
                )Q
          GROUP BY Q.SOL_ID
         )T, TBAADM.SERVICE_OUTLET_TABLE SOT
    where SOT.SOL_ID = T.SOL_ID
    GROUP BY T.SOL_ID,SOT.SOL_DESC
    ORDER BY T.SOL_ID
    ;
    
    -- For Product cursor
     CURSOR ExtractDataDepositProduct (ci_tranDate VARCHAR2,ci_odDate VARCHAR2,ci_AccountType VARCHAR2,ci_description VARCHAR2)
  IS
   SELECT T.SOL_ID,
        SOT.SOL_DESC,
       SUM(T.BFAccountNumber) AS BFAccountNumber,
       SUM(T.BDAmount) as BDAmount,
       SUM(T.AccountNumber) as AccountNumber,
       SUM(T.Amount) as Amount,
       SUM(T.AccountNumber)-SUM(T.BFAccountNumber) as DiffBFAccount,
       SUM(T.Amount)-SUM(T.BDAmount) as DiffAccount
    FROM (
         SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
       SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
       SELECT GAM.SOL_ID,
      COUNT(*)*-1 AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
     AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
     AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'Y'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
     /* UNION ALL
    
    SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
          UNION ALL
          
         SELECT Q.SOL_ID,
                 SUM(Q.BFAccountNumber)  AS BFAccountNumber,
                 SUM(Q.BDAmount) AS BDAmount,
                 SUM(Q.AccountNumber) as AccountNumber,
                 SUM(Q.Amount) AS Amount
          FROM (
                  SELECT  gstt.SOL_ID,
                          0 AS BFAccountNumber,
                         -- Sum(EAB.TRAN_DATE_BAL) AS BDAmount,
                          CASE WHEN  Gstt.Crncy_Code = 'MMK' THEN (Gstt.tot_cr_bal-Gstt.tot_dr_bal) 
                           ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal)  * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(Gstt.Crncy_Code) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(Gstt.Crncy_Code)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),0) END   as BDAmount,
                          0 as AccountNumber,
                          0 AS Amount
                         
                   from         
                   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  where
                    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
                  --   And Gstt.Sol_Id=Gsh.Sol_Id
                    -- And Gsh.Crncy_Code = Coa.Cur
                     And coa.cur = Gstt.Crncy_Code
                     and coa.description like ci_description||'%'
                    -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
                     and gstt.BAL_DATE <= TO_DATE( ci_odDate, 'dd-MM-yyyy' )
                     And Gstt.End_Bal_Date >= To_Date(ci_odDate, 'dd-MM-yyyy' )
                     And    Coa.Group_Code In ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
                    -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
                     and gstt.DEL_FLG = 'N'
                     And Gstt.Bank_Id = '01'
                    
                 
                 
                )Q
          GROUP BY Q.SOL_ID
          
          
          UNION ALL
          
          SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date < TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all 
      
       SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all 
      
        SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*)*-1 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
     AND    GAM.acct_cls_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     and     EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     and    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
     AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
     AND    GAM.ACCT_CLS_FLG = 'Y'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
     /* UNION ALL
    
    SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
          
          UNION ALL
          
          SELECT Q.SOL_ID,
           SUM(Q.BFAccountNumber) AS BFAccountNumber,
           SUM(Q.BDAmount) AS BDAmount,
           SUM(Q.AccountNumber)as AccountNumber,
           SUM(Q.Amount) AS Amount
          FROM (
                  SELECT gstt.SOL_ID,
                          0 AS BFAccountNumber,
                          0 AS BDAmount,
                          0 as AccountNumber,
                         -- Sum(EAB.TRAN_DATE_BAL) AS Amount
                          CASE WHEN Gstt.Crncy_Code = 'MMK' THEN (Gstt.tot_cr_bal-Gstt.tot_dr_bal) 
                          ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal)  * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(Gstt.Crncy_Code) and r.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS Amount
                         
                   from         
                   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  Where
                    gstt.gl_sub_head_code = coa.gl_sub_head_code
                    -- and gstt.sol_id=gsh.sol_id
                    -- And Gsh.Crncy_Code = Coa.Cur
                    -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
                    and coa.description like ci_description||'%'
                     and gstt.BAL_DATE <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
                     And Gstt.End_Bal_Date >= To_Date(ci_tranDate, 'dd-MM-yyyy' )
                     And    Coa.Group_Code In ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
                    -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
                     and gstt.DEL_FLG = 'N'
                     and gstt.BANK_ID = '01'
                     And coa.cur = Gstt.Crncy_Code
                  
                )Q
          GROUP BY Q.SOL_ID
         )T, TBAADM.SERVICE_OUTLET_TABLE SOT
    where SOT.SOL_ID = T.SOL_ID
    GROUP BY T.SOL_ID,SOT.SOL_DESC
    ORDER BY T.SOL_ID
    ;
    
    
  CURSOR ExtractDataLoan (ci_tranDate VARCHAR2,ci_odDate VARCHAR2)
  IS
    SELECT T.SOL_ID,
        SOT.SOL_DESC,
       SUM(T.BFAccountNumber) AS BFAccountNumber,
      abs(SUM(T.BDAmount)) as BDAmount,
       SUM(T.AccountNumber) as AccountNumber,
       abs(SUM(T.Amount)) as Amount,
      SUM(T.AccountNumber)-SUM(T.BFAccountNumber) as DiffBFAccount,
     abs(SUM(T.Amount))- abs(SUM(T.BDAmount)) as DiffAccount
FROM (
     SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
       AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
      SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
       AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
      SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_cls_date >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
      SELECT GAM.SOL_ID,
      COUNT(*)*-1 AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
       AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
     /* UNION ALL
    
    SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
        
      UNION ALL
      
     SELECT Q.SOL_ID,
             SUM(Q.BFAccountNumber)  AS BFAccountNumber,
             SUM(Q.BDAmount) AS BDAmount,
             SUM(Q.AccountNumber) as AccountNumber,
             SUM(Q.Amount) AS Amount
      FROM (
              SELECT  Gstt.SOL_ID,
                      0 AS BFAccountNumber,
                       Case When Gstt.Crncy_Code = 'MMK' Then Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal
                       ELSE (Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gstt.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS BDAmount,
                      0 as AccountNumber,
                      0 AS Amount
                     
              from         
               TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
             where
              gstt.gl_sub_head_code = coa.gl_sub_head_code
               and gstt.BAL_DATE <= TO_DATE( ci_odDate, 'dd-MM-yyyy' )
               And Gstt.End_Bal_Date >= To_Date(ci_odDate, 'dd-MM-yyyy' )
               And    Coa.Group_Code In ('A21','A23','A24','A25','A26')
              -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
               and gstt.DEL_FLG = 'N'
               and gstt.BANK_ID = '01'
               and  coa.cur = gstt.crncy_code
            
             
              
             
            
            )Q
      GROUP BY Q.SOL_ID
      
      
      UNION ALL
      
      SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_opn_date < TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
       SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_opn_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
       SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*)*-1 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_cls_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      /*UNION ALL
    
    SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_type in ('LAA','CAA')
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
    group by gam.sol_id*/
      
      UNION ALL
      
      SELECT Q.SOL_ID,
       SUM(Q.BFAccountNumber) AS BFAccountNumber,
       SUM(Q.BDAmount) AS BDAmount,
       SUM(Q.AccountNumber)as AccountNumber,
       SUM(Q.Amount) AS Amount
      FROM (
             SELECT Gstt.SOL_ID,
                      0 AS BFAccountNumber,
                      0 AS BDAmount,
                      0 As Accountnumber,
                      Case When Gstt.Crncy_Code = 'MMK' Then Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal
                      ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(gstt.crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) End As Amount
            from         
             TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
            where
              gstt.gl_sub_head_code = coa.gl_sub_head_code
               and gstt.BAL_DATE <= TO_DATE(ci_tranDate, 'dd-MM-yyyy' )
               And Gstt.End_Bal_Date >= To_Date( ci_tranDate, 'dd-MM-yyyy' )
               And    Coa.Group_Code In ('A21','A23','A24','A25','A26')
              -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
               and gstt.DEL_FLG = 'N'
               and gstt.BANK_ID = '01'
               and coa.cur = gstt.crncy_code
           
              
              
            )Q
      GROUP BY Q.SOL_ID
     )T ,TBAADM.SERVICE_OUTLET_TABLE SOT
where SOT.SOL_ID = T.SOL_ID
GROUP BY T.SOL_ID,SOT.SOL_DESC
ORDER BY T.SOL_ID
;

CURSOR ExtractDataLoanProduct (ci_tranDate VARCHAR2,ci_odDate VARCHAR2,ci_AccountType VARCHAR2,ci_description VARCHAR2)
  IS
    SELECT T.SOL_ID,
        SOT.SOL_DESC,
       SUM(T.BFAccountNumber) AS BFAccountNumber,
      abs(SUM(T.BDAmount)) as BDAmount,
       SUM(T.AccountNumber) as AccountNumber,
       abs(SUM(T.Amount)) as Amount,
      SUM(T.AccountNumber)-SUM(T.BFAccountNumber) as DiffBFAccount,
     abs(SUM(T.Amount))- abs(SUM(T.BDAmount)) as DiffAccount
FROM (
     SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
       AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
     SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
       AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
      SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
        AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')-3
                                       )
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      --AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
     /* 
      UNION ALL
    
    SELECT GAM.SOL_ID,
       COUNT(*) AS BFAccountNumber,
       0 AS BDAmount,
       0 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_odDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
     group by gam.sol_id*/
        
      UNION ALL
      
     SELECT Q.SOL_ID,
             SUM(Q.BFAccountNumber)  AS BFAccountNumber,
             SUM(Q.BDAmount) AS BDAmount,
             SUM(Q.AccountNumber) as AccountNumber,
             SUM(Q.Amount) AS Amount
      FROM (
              SELECT  Gstt.SOL_ID,
                      0 AS BFAccountNumber,
                       Case When Gstt.Crncy_Code = 'MMK' Then Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal
                       ELSE (Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(gstt.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_odDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS BDAmount,
                      0 as AccountNumber,
                      0 AS Amount
                     
              from         
               TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
             where
              gstt.gl_sub_head_code = coa.gl_sub_head_code
               and gstt.BAL_DATE <= TO_DATE( ci_odDate, 'dd-MM-yyyy' )
               And Gstt.End_Bal_Date >= To_Date(ci_odDate, 'dd-MM-yyyy' )
               And    Coa.Group_Code In ('A21','A23','A24','A25','A26')
               and coa.description like  ci_description ||'%'
              -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
               and gstt.DEL_FLG = 'N'
               and gstt.BANK_ID = '01'
               and  coa.cur = gstt.crncy_code
            
             
              
             
            
            )Q
      GROUP BY Q.SOL_ID
      
      
      UNION ALL
      
      SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date < TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      union all
      
        SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
      
      union all
      
       SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
        COUNT(*)*-1 as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     eab.acid = gam.acid
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_cls_date = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
     -- AND    GAM.ACCT_CLS_FLG = 'N'
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      group by gam.sol_id
    /*  UNION ALL
    
    SELECT GAM.SOL_ID,
       0 AS BFAccountNumber,
       0 AS BDAmount,
       COUNT(*) as AccountNumber,
       0 AS Amount
      FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
      WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
      AND    COA.CUR = gam.acct_crncy_code
      and     schm_code like '%'||ci_AccountType||'%'
      AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
      AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
      AND    GAM.ACCT_CLS_FLG = 'N'
      and    gam.clr_bal_amt <> 0
      AND    GAM.BANK_ID = '01'
      AND    GAM.ENTITY_CRE_FLG = 'Y'
      and    gam.acid  not in ( select acid
                                from tbaadm.eab e
                                where     e.EOD_DATE <= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_tranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                )
    group by gam.sol_id*/
      
      UNION ALL
      
      SELECT Q.SOL_ID,
       SUM(Q.BFAccountNumber) AS BFAccountNumber,
       SUM(Q.BDAmount) AS BDAmount,
       SUM(Q.AccountNumber)as AccountNumber,
       SUM(Q.Amount) AS Amount
      FROM (
             SELECT Gstt.SOL_ID,
                      0 AS BFAccountNumber,
                      0 AS BDAmount,
                      0 As Accountnumber,
                      Case When Gstt.Crncy_Code = 'MMK' Then Gstt.Tot_Cr_Bal-Gstt.Tot_Dr_Bal
                      ELSE (Gstt.tot_cr_bal-Gstt.tot_dr_bal) * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(gstt.crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) End As Amount
            from         
             TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
            where
              gstt.gl_sub_head_code = coa.gl_sub_head_code
               and gstt.BAL_DATE <= TO_DATE(ci_tranDate, 'dd-MM-yyyy' )
               And Gstt.End_Bal_Date >= To_Date( ci_tranDate, 'dd-MM-yyyy' )
               And    Coa.Group_Code In ('A21','A23','A24','A25','A26')
              -- and (gstt.tot_cr_bal <> 0 or gstt.tot_dr_bal <> 0)
              and coa.description like  ci_description ||'%'
               and gstt.DEL_FLG = 'N'
               and gstt.BANK_ID = '01'
               and coa.cur = gstt.crncy_code
           
              
              
            )Q
      GROUP BY Q.SOL_ID
     )T ,TBAADM.SERVICE_OUTLET_TABLE SOT
where SOT.SOL_ID = T.SOL_ID
GROUP BY T.SOL_ID,SOT.SOL_DESC
ORDER BY T.SOL_ID
;
PROCEDURE FIN_INC_DEC_DEPOSIT_LOAN(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_solID TBAADM.SERVICE_OUTLET_TABLE.SOL_ID%type;
  v_Open_Date      TBAADM.SERVICE_OUTLET_TABLE.br_open_date%TYPE;
  v_solDesc TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%type;
  v_openAcCount NUMBER(20);
  v_openAcAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_curAcCount NUMBER(20);
  v_curAcAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_difAcCount NUMBER(20);
  v_difAcAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
 
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
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
  vi_tranType   := outArr(1);
  vi_AccountType := outArr(2);
  
  if vi_AccountType is null then
        vi_AccountType := 'NO';
  elsif vi_AccountType like 'Regular Saving' then
        vi_AccountType := 'SAREG';
        v_description := 'Saving';
  elsif vi_AccountType like 'Special Saving' then
        vi_AccountType := 'SASPL';
        v_description := 'Special';
  elsif vi_AccountType like 'Current' then
        vi_AccountType := 'AG%C%';
        v_description := 'Current';
  elsif vi_AccountType like 'Fixed' then
        vi_AccountType := 'AGDFD';
        v_description := 'Fixed';
  elsif vi_AccountType like 'Normal Loan' then
        vi_AccountType := 'AGDNL';
        v_description := 'Loans';
  elsif vi_AccountType like 'Staff Loan' then
        vi_AccountType := 'AGSS1';
        v_description := 'Staff';
  elsif vi_AccountType like 'Hire Purchase' then
        vi_AccountType := 'AG%HP%';
        v_description := 'Hire';
  elsif vi_AccountType like 'Overdraft' then
        vi_AccountType := 'AGDOD';
        v_description := 'Overdraft';
  else 
      vi_AccountType := 'NO';
 end if;
  dbms_output.put_line(vi_AccountType);
  dbms_output.put_line(v_description);
  
  begin
  select to_char(max(ctd.tran_date) , 'dd-MM-yyyy') into v_odDate
    from  CUSTOM.custom_ctd_dtd_acli_view  ctd
    where ctd.tran_date <= tO_DATE( vi_tranDate,'dd-MM-yyyy')-1
    and  ctd.tran_date >= tO_DATE( vi_tranDate,'dd-MM-yyyy')-10;
  end;
  -----------------------------------------------------------------------
   if( vi_tranDate is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  
		           0 || '|' || 0 || '|' || 0 || '|' || '-'  || '|' || '-' || '|' || '-' || '|' || '-'  || '|' || '-'    );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
     
  ------------------------------------------------------------------------
  IF  vi_AccountType like 'NO'  then
    IF vi_tranType like 'Loan%' THEN
      IF NOT ExtractDataLoan%ISOPEN THEN --ExtractDataLoan ExtractDataDeposit
        --{
        BEGIN
          --{--
          dbms_output.put_line(v_odDate);
          OPEN ExtractDataLoan (vi_tranDate,v_odDate);
          --}
        END;
        --}
      END IF;
      IF ExtractDataLoan%ISOPEN THEN
        --{
        dbms_output.put_line('Loan');
        FETCH ExtractDataLoan
        INTO v_solID,
          v_solDesc,
          v_openAcCount,
          v_openAcAmount,
          v_curAcCount,
          v_curAcAmount,
          v_difAcCount,
          v_difAcAmount;
        ------------------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------------------
        IF ExtractDataLoan%NOTFOUND THEN
          --{
          CLOSE ExtractDataLoan;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
    ELSE
      IF NOT ExtractDataDeposit%ISOPEN THEN
        --{
        dbms_output.put_line('Deposit');
        BEGIN
          --{
         
          OPEN ExtractDataDeposit (vi_tranDate,v_odDate);
          --}
        END;
        --}
      END IF;
      IF ExtractDataDeposit%ISOPEN THEN
        --{
        FETCH ExtractDataDeposit
        INTO v_solID,
          v_solDesc,
          v_openAcCount,
          v_openAcAmount,
          v_curAcCount,
          v_curAcAmount,
          v_difAcCount,
          v_difAcAmount;
        ------------------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------------------
        IF ExtractDataDeposit%NOTFOUND THEN
          --{
          CLOSE ExtractDataDeposit;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
    END IF;
  ELSE
       IF vi_tranType like 'Loan%' THEN
      IF NOT ExtractDataLoanProduct%ISOPEN THEN --ExtractDataLoan ExtractDataDeposit
        --{
        BEGIN
          --{--
          --
          dbms_output.put_line('Loan Product');
          OPEN ExtractDataLoanProduct (vi_tranDate,v_odDate,vi_AccountType,v_description);
          --}
        END;
        --}
      END IF;
      IF ExtractDataLoanProduct%ISOPEN THEN
        --{
        FETCH ExtractDataLoanProduct
        INTO v_solID,
          v_solDesc,
          v_openAcCount,
          v_openAcAmount,
          v_curAcCount,
          v_curAcAmount,
          v_difAcCount,
          v_difAcAmount;
        ------------------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------------------
        IF ExtractDataLoanProduct%NOTFOUND THEN
          --{
          CLOSE ExtractDataLoanProduct;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
    ELSE
      IF NOT ExtractDataDepositProduct%ISOPEN THEN
        --{
        BEGIN
          --{
         dbms_output.put_line('Deposit Product');
          OPEN ExtractDataDepositProduct (vi_tranDate,v_odDate,vi_AccountType,v_description);
          --}
        END;
        --}
      END IF;
      IF ExtractDataDepositProduct%ISOPEN THEN
        --{
        FETCH ExtractDataDepositProduct
        INTO v_solID,
          v_solDesc,
          v_openAcCount,
          v_openAcAmount,
          v_curAcCount,
          v_curAcAmount,
          v_difAcCount,
          v_difAcAmount;
        ------------------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------------------
        IF ExtractDataDepositProduct%NOTFOUND THEN
          --{
          CLOSE ExtractDataDepositProduct;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
    END IF;
  END IF;
   dbms_output.put_line('exit Product');
  BEGIN
    -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
    -------------------------------------------------------------------------------
    SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
      BRANCH_CODE_TABLE.BR_ADDR_1          AS "Bank_Address",
      BRANCH_CODE_TABLE.PHONE_NUM          AS "Bank_Phone",
      BRANCH_CODE_TABLE.FAX_NUM            AS "Bank_Fax"
    INTO v_BranchName,
      v_BankAddress,
      v_BankPhone,
      v_BankFax
    FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
      TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = '20300'
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
  END;
  --------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  --------------------------------------------------------------------------------
  out_rec:= ( v_solID || '|' ||  
          v_solDesc || '|' || 
          v_openAcCount || '|' ||
          v_openAcAmount || '|' || 
          v_curAcCount || '|' || 
          v_curAcAmount || '|' || 
          v_difAcCount || '|' || 
          v_difAcAmount || '|' || 
          v_BranchName || '|' || 
          v_BankAddress || '|' ||
          v_BankPhone || '|' ||
          v_BankFax || '|' || 
          TO_CHAR(to_date(v_odDate,'dd/MM/yy'), 'dd-MM-yyyy'));
  dbms_output.put_line(out_rec);
END FIN_INC_DEC_DEPOSIT_LOAN;
END FIN_INC_DEC_DEPOSIT_LOAN;
/
