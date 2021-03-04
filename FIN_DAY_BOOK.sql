CREATE OR REPLACE PACKAGE                                                                                                                                             FIN_DAY_BOOK AS

PROCEDURE FIN_DAY_BOOK(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAY_BOOK;


/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_DAY_BOOK
AS
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_currency     VARCHAR2(3);          -- Input to procedure
  vi_currencyType VARCHAR2(30);         -- Input to procedure
  vi_TranDate     VARCHAR2(10);         -- Input to procedure
  vi_BranchCode   VARCHAR2(5);          -- Input to procedure
  vi_SchemeType   VARCHAR2(3);          -- Input to procedure
  vi_ReversalType VARCHAR2(20);
  vi_SchemeCode   VARCHAR2(10);
  --v_cur_type VARCHAR2(20);
  vi_rate DECIMAL;
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --(1) CURSOR ExtractData Without Reversal Without HO With MMK (for each branch)
  -----------------------------------------------------------------------------
  CURSOR Extract_WO_R_WO_HO_MMK ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2, ci_SchemeType VARCHAR2 , ci_SchemeCode VARCHAR2)
  IS
    SELECT GENERAL_ACCT_MAST_TABLE.SCHM_TYPE AS "Account_Type" ,
      CTD_DTD_ACLI_VIEW.TRAN_AMT             AS "Amount" ,
      GENERAL_ACCT_MAST_TABLE.FORACID        AS "Account No." ,
      general_acct_mast_table.acct_name      AS "Account Name",
      CTD_DTD_ACLI_VIEW.TRAN_TYPE            AS "Tran_Type" ,
      CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE       AS "Part_Tran_Type",
      CTD_DTD_ACLI_VIEW.dth_init_sol_id      AS "Init_Sol_Id"
    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
    AND CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE       = Upper(ci_currency )
    --AND CTD_DTD_ACLI_VIEW.ref_crncy_code        = Upper(ci_currency)
    AND GENERAL_ACCT_MAST_TABLE.acct_crncy_code = Upper(ci_currency )
    AND GENERAL_ACCT_MAST_TABLE.ACID            = CTD_DTD_ACLI_VIEW.ACID
      --and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id       like   '%' || ci_branchCode || '%'
    AND trim(CTD_DTD_ACLI_VIEW.tran_id) NOT IN
      (SELECT trim(CONT_TRAN_ID)
      FROM TBAADM.ATD atd
      WHERE TO_DATE( CAST ( atd.cont_tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) = TO_DATE( CAST (CTD_DTD_ACLI_VIEW.tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      )--and reversal_flg = 'R' )--Without Reversal
  AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
  AND CTD_DTD_ACLI_VIEW.pstd_date IS NOT NULL
  ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID;
  -----------------------------------------------------------------------------
  --(2) CURSOR ExtractData Without_Reversal Without_HO With AllCurrency (for each branch)
  -----------------------------------------------------------------------------
  CURSOR Extract_WO_R_WO_HO_All ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2)
  IS
    SELECT T.SCHM_TYPE AS "Account_Type" ,
      T.TRAN_AMT             AS "Amount" ,
      T.FORACID       AS "Account No." ,
      T.acct_name      AS "Account Name",
      T.TRAN_TYPE            AS "Tran_Type" ,
      T.PART_TRAN_TYPE       AS "Part_Tran_Type",
      T.dth_init_sol_id      AS "Init_Sol_Id"
      from(
      select q.SCHM_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT
                 ELSE q.TRAN_AMT * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS TRAN_AMT,
      q.FORACID,q.acct_name,q.TRAN_TYPE,q.PART_TRAN_TYPE,q.dth_init_sol_id
      from(
      select GENERAL_ACCT_MAST_TABLE.SCHM_TYPE,CTD_DTD_ACLI_VIEW.TRAN_AMT,
            GENERAL_ACCT_MAST_TABLE.FORACID,general_acct_mast_table.acct_name,
            CTD_DTD_ACLI_VIEW.TRAN_TYPE, CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE,
            CTD_DTD_ACLI_VIEW.dth_init_sol_id ,CTD_DTD_ACLI_VIEW.tran_crncy_code as cur

    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
      --and CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE = Upper(ci_currency )
    AND GENERAL_ACCT_MAST_TABLE.ACID = CTD_DTD_ACLI_VIEW.ACID
      --and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id       like   '%' || ci_branchCode || '%'
    AND trim(CTD_DTD_ACLI_VIEW.tran_id) NOT IN
      (SELECT trim(CONT_TRAN_ID)
      FROM TBAADM.ATD atd
      WHERE TO_DATE( CAST ( atd.cont_tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) = TO_DATE( CAST (CTD_DTD_ACLI_VIEW.tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      )--and reversal_flg = 'R' )--Without Reversal
  AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
  AND CTD_DTD_ACLI_VIEW.pstd_date IS NOT NULL
  ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID)q
  ORDER BY q.FORACID )T
   ORDER BY T.FORACID;
  -----------------------------------------------------------------------------
  --(3) CURSOR ExtractData Without_Reversal Without_HO With AllCurrency(FCY) (for each branch)
  -----------------------------------------------------------------------------
  CURSOR Extract_WO_R_WO_HO_FCY ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2)
  IS
    SELECT T.SCHM_TYPE AS "Account_Type" ,
      T.TRAN_AMT             AS "Amount" ,
      T.FORACID        AS "Account No." ,
      T.acct_name      AS "Account Name",
      T.TRAN_TYPE            AS "Tran_Type" ,
      T.PART_TRAN_TYPE       AS "Part_Tran_Type",
      T.dth_init_sol_id      AS "Init_Sol_Id"
      from(
        select q.SCHM_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT
                 ELSE q.TRAN_AMT * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS TRAN_AMT,
      q.FORACID,q.acct_name,q.TRAN_TYPE,q.PART_TRAN_TYPE,q.dth_init_sol_id
      from(
      select GENERAL_ACCT_MAST_TABLE.SCHM_TYPE,CTD_DTD_ACLI_VIEW.TRAN_AMT,
            GENERAL_ACCT_MAST_TABLE.FORACID,general_acct_mast_table.acct_name,
            CTD_DTD_ACLI_VIEW.TRAN_TYPE, CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE,
            CTD_DTD_ACLI_VIEW.dth_init_sol_id ,CTD_DTD_ACLI_VIEW.tran_crncy_code as cur
    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
    AND CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE       != Upper('MMK' )
    --AND CTD_DTD_ACLI_VIEW.ref_crncy_code        != Upper('MMK' )
    AND GENERAL_ACCT_MAST_TABLE.acct_crncy_code != Upper('MMK' )
    AND GENERAL_ACCT_MAST_TABLE.ACID             = CTD_DTD_ACLI_VIEW.ACID
      --and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id       like   '%' || ci_branchCode || '%'
    AND trim(CTD_DTD_ACLI_VIEW.tran_id) NOT IN
      (SELECT trim(CONT_TRAN_ID)
      FROM TBAADM.ATD atd
      WHERE TO_DATE( CAST ( atd.cont_tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) = TO_DATE( CAST (CTD_DTD_ACLI_VIEW.tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      )--and reversal_flg = 'R' )--Without Reversal
  AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
  AND CTD_DTD_ACLI_VIEW.pstd_date IS NOT NULL
  ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID)q
  ORDER BY q.FORACID )T
   ORDER BY T.FORACID;
  --------------------------------------------------------------------------------
  ----------------------------WithReversal----------------------------------------
  --------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --(4) CURSOR ExtractData WithReversal Without_HO With_MMK (for each BranchCode)
  -----------------------------------------------------------------------------
  CURSOR Extract_W_R_WO_HO_MMK ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2, ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2)
  IS
    SELECT GENERAL_ACCT_MAST_TABLE.SCHM_TYPE AS "Account_Type" ,
      CTD_DTD_ACLI_VIEW.TRAN_AMT             AS "Amount" ,
      GENERAL_ACCT_MAST_TABLE.FORACID        AS "Account No." ,
      general_acct_mast_table.acct_name      AS "Account Name",
      CTD_DTD_ACLI_VIEW.TRAN_TYPE            AS "Tran_Type" ,
      CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE       AS "Part_Tran_Type",
      CTD_DTD_ACLI_VIEW.dth_init_sol_id      AS "Init_Sol_Id"
    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
    AND CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE       = Upper(ci_currency )
    --AND CTD_DTD_ACLI_VIEW.ref_crncy_code        = Upper(ci_currency )
    AND GENERAL_ACCT_MAST_TABLE.acct_crncy_code = Upper(ci_currency)
    AND GENERAL_ACCT_MAST_TABLE.ACID            = CTD_DTD_ACLI_VIEW.ACID
      --   and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
    AND CTD_DTD_ACLI_VIEW.pstd_date   IS NOT NULL
    ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID;
  -----------------------------------------------------------------------------
  --(5) CURSOR ExtractData WithReversal Without_HO With_AllCurrency (for each BranchCode)
  -----------------------------------------------------------------------------
  CURSOR Extract_W_R_WO_HO_All ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2)
  IS
    SELECT T.SCHM_TYPE AS "Account_Type" ,
      T.TRAN_AMT             AS "Amount" ,
      T.FORACID        AS "Account No." ,
      T.acct_name      AS "Account Name",
      T.TRAN_TYPE            AS "Tran_Type" ,
      T.PART_TRAN_TYPE       AS "Part_Tran_Type",
      T.dth_init_sol_id      AS "Init_Sol_Id"
      from(
      select q.SCHM_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT
                 ELSE q.TRAN_AMT * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS TRAN_AMT,
      q.FORACID,q.acct_name,q.TRAN_TYPE,q.PART_TRAN_TYPE,q.dth_init_sol_id
      from(
      select GENERAL_ACCT_MAST_TABLE.SCHM_TYPE,CTD_DTD_ACLI_VIEW.TRAN_AMT,
            GENERAL_ACCT_MAST_TABLE.FORACID,general_acct_mast_table.acct_name,
            CTD_DTD_ACLI_VIEW.TRAN_TYPE, CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE,
            CTD_DTD_ACLI_VIEW.dth_init_sol_id ,CTD_DTD_ACLI_VIEW.tran_crncy_code as cur
    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
      --and CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE = Upper(ci_currency )
      --and CTD_DTD_ACLI_VIEW.ref_crncy_code = Upper(ci_currency )
      --and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = Upper(ci_currency)
    AND GENERAL_ACCT_MAST_TABLE.ACID = CTD_DTD_ACLI_VIEW.ACID
      --   and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
    AND CTD_DTD_ACLI_VIEW.pstd_date   IS NOT NULL
    ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID)q
    ORDER BY q.FORACID )T
   ORDER BY T.FORACID;
  -----------------------------------------------------------------------------
  --(6) CURSOR ExtractData WithReversal Without_HO With_AllCurrency(FCY) (for each BranchCode)
  -----------------------------------------------------------------------------
  CURSOR Extract_W_R_WO_HO_FCY ( ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2)
  IS
    SELECT T.SCHM_TYPE AS "Account_Type" ,
      T.TRAN_AMT             AS "Amount" ,
      T.FORACID        AS "Account No." ,
      T.acct_name      AS "Account Name",
      T.TRAN_TYPE            AS "Tran_Type" ,
      T.PART_TRAN_TYPE       AS "Part_Tran_Type",
      T.dth_init_sol_id      AS "Init_Sol_Id"
      from(
      select q.SCHM_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT
                 ELSE q.TRAN_AMT * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS TRAN_AMT,
      q.FORACID,q.acct_name,q.TRAN_TYPE,q.PART_TRAN_TYPE,q.dth_init_sol_id
      from(
      select GENERAL_ACCT_MAST_TABLE.SCHM_TYPE,CTD_DTD_ACLI_VIEW.TRAN_AMT,
            GENERAL_ACCT_MAST_TABLE.FORACID,general_acct_mast_table.acct_name,
            CTD_DTD_ACLI_VIEW.TRAN_TYPE, CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE,
            CTD_DTD_ACLI_VIEW.dth_init_sol_id ,CTD_DTD_ACLI_VIEW.tran_crncy_code as cur
    FROM TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,
      custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW
    WHERE CTD_DTD_ACLI_VIEW.TRAN_DATE     = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
    AND CTD_DTD_ACLI_VIEW.DEL_FLG         = 'N'
    AND GENERAL_ACCT_MAST_TABLE.bank_id   = '01'
    AND CTD_DTD_ACLI_VIEW.bank_id         ='01'
      --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
    AND CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE       != Upper('MMK' )
    --AND CTD_DTD_ACLI_VIEW.ref_crncy_code        != Upper('MMK' )
    AND GENERAL_ACCT_MAST_TABLE.acct_crncy_code != Upper('MMK')
    AND GENERAL_ACCT_MAST_TABLE.ACID             = CTD_DTD_ACLI_VIEW.ACID
      --   and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    AND CTD_DTD_ACLI_VIEW.SOL_ID like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.sol_id like   '%' || ci_branchCode || '%'
    AND GENERAL_ACCT_MAST_TABLE.SCHM_CODE like '%' || UPPER(ci_SchemeCode) || '%'
    AND CTD_DTD_ACLI_VIEW.pstd_date   IS NOT NULL
    ORDER BY GENERAL_ACCT_MAST_TABLE.FORACID)q
    ORDER BY q.FORACID )T
   ORDER BY T.FORACID;
  ------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIN_DAY_BOOK(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_Account_Type TBAADM.GENERAL_ACCT_MAST_TABLE.SCHM_TYPE%type;
  v_Amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_AccountNumber tbaadm.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_AccountName tbaadm.GENERAL_ACCT_MAST_TABLE.acct_name%type;
  v_Tran_Type tbaadm.CTD_DTD_ACLI_VIEW.TRAN_TYPE%type;
  v_Part_Tran_Type tbaadm.CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE%type;
  v_schm_code_desp tbaadm.gsp.schm_desc%type;
   v_BranchName tbaadm.sol.sol_desc%type;
    v_BankAddress varchar(200);
  
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  v_Init_Sol_Id CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.dth_init_sol_id%type;
BEGIN
  -------------------------------------------------------------
  -- Out Ret code is the code which controls
  -- the while loop,it can have values 0,1
  -- 0 - The while loop is being executed
  -- 1 - Exit
  -------------------------------------------------------------
  out_retCode := 0;
  out_rec     := NULL;
  tbaadm.basp0099.formInputArr(inp_str, outArr);
  --------------------------------------
  -- Parsing the i/ps from the string
  --------------------------------------
  vi_TranDate     := outArr(0);
  vi_currencyType := outArr(1);
  vi_currency     := outArr(2);
  vi_SchemeType   := outArr(3);
  vi_SchemeCode   := outArr(4);
  vi_ReversalType := outArr(5);
  vi_BranchCode   := outArr(6);


  IF vi_BranchCode IS  NULL or vi_BranchCode = ''  THEN
  vi_BranchCode := '';
  END IF;

  IF vi_SchemeCode IS NOT NULL OR vi_SchemeCode != '' THEN
    SELECT schm_desc
    INTO v_schm_code_desp
    FROM tbaadm.gsp gsp
    WHERE gsp.schm_code =upper(vi_SchemeCode);
  ELSE
    vi_SchemeCode := '';
  END IF;


----------------------------------------------------------------------------------------------------------
  if( vi_TranDate is null or vi_currencyType is null or vi_SchemeType is null or vi_ReversalType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' ||'|'|| 0);
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;
----------------------------------------------------------------------------------------------------------
  IF vi_ReversalType LIKE 'Without%' THEN
    --{
        IF vi_currencyType NOT LIKE 'All%' THEN
          --{
          IF NOT Extract_WO_R_WO_HO_MMK%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_WO_R_WO_HO_MMK ( vi_TranDate , vi_BranchCode ,vi_currency, vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_WO_R_WO_HO_MMK%ISOPEN THEN
            --{
            FETCH Extract_WO_R_WO_HO_MMK
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_WO_R_WO_HO_MMK%NOTFOUND THEN
              --{
              CLOSE Extract_WO_R_WO_HO_MMK;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        ELSIF vi_currencyType like 'All Currency%' THEN
          IF NOT Extract_WO_R_WO_HO_All%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_WO_R_WO_HO_All ( vi_TranDate , vi_BranchCode , vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_WO_R_WO_HO_All%ISOPEN THEN
            --{
            FETCH Extract_WO_R_WO_HO_All
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_WO_R_WO_HO_All%NOTFOUND THEN
              --{
              CLOSE Extract_WO_R_WO_HO_All;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        ELSE -- for all fcy currency
          IF NOT Extract_WO_R_WO_HO_FCY%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_WO_R_WO_HO_FCY ( vi_TranDate , vi_BranchCode , vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_WO_R_WO_HO_FCY%ISOPEN THEN
            --{
            FETCH Extract_WO_R_WO_HO_FCY
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_WO_R_WO_HO_FCY%NOTFOUND THEN
              --{
              CLOSE Extract_WO_R_WO_HO_FCY;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        END IF;--currencytype
--------------------------------------------------------------------------------------------------------------------
      ELSE -- for With Reversal
        --{
        IF vi_currencyType NOT LIKE 'All%' THEN
          --{
          IF NOT Extract_W_R_WO_HO_MMK%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_W_R_WO_HO_MMK ( vi_TranDate ,vi_BranchCode,vi_currency, vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_W_R_WO_HO_MMK%ISOPEN THEN
            --{
            FETCH Extract_W_R_WO_HO_MMK
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_W_R_WO_HO_MMK%NOTFOUND THEN
              --{
              CLOSE Extract_W_R_WO_HO_MMK;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        ELSIF vi_currencyType like 'All Currency%' THEN
          IF NOT Extract_W_R_WO_HO_All%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_W_R_WO_HO_All ( vi_TranDate ,vi_BranchCode, vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_W_R_WO_HO_All%ISOPEN THEN
            --{
            FETCH Extract_W_R_WO_HO_All
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_W_R_WO_HO_All%NOTFOUND THEN
              --{
              CLOSE Extract_W_R_WO_HO_All;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        ELSE --for AllCurrency(FCY)
          IF NOT Extract_W_R_WO_HO_FCY%ISOPEN THEN
            --{
            BEGIN
              --{
              OPEN Extract_W_R_WO_HO_FCY ( vi_TranDate ,vi_BranchCode, vi_SchemeType,vi_SchemeCode);
              --}
            END;
            --}
          END IF;
          IF Extract_W_R_WO_HO_FCY%ISOPEN THEN
            --{
            FETCH Extract_W_R_WO_HO_FCY
            INTO v_Account_Type,
              v_Amount,
              v_AccountNumber,
              v_AccountName,
              v_Tran_Type,
              v_Part_Tran_Type,
              v_Init_Sol_Id;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF Extract_W_R_WO_HO_FCY%NOTFOUND THEN
              --{
              CLOSE Extract_W_R_WO_HO_FCY;
              out_retCode:= 1;
              RETURN;
              --}
            END IF;
            --}
          END IF;
        END IF;--currencytype
      END IF;--Reversal Type
--------------------------------------------------------------------------------------------------------
    BEGIN
      -------------------------------------------------------------------------------
      -- GET BANK INFORMATION
      -------------------------------------------------------------------------------
    
   
      
      IF vi_BranchCode is not null then
      
      SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into  v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
      END IF;
    END;
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_rate            := 1;
    ELSE
      vi_rate := 1;
    END IF;
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:= ( v_Account_Type || '|' || v_Amount || '|' || v_AccountNumber || '|' || v_AccountName || '|' || v_Tran_Type || '|' || v_Part_Tran_Type || '|' || v_schm_code_desp || '|' || v_BranchName || '|' || v_BankAddress || '|' || v_BankPhone || '|' || v_BankFax || '|' || v_Init_Sol_Id ||'|'|| vi_rate);
    dbms_output.put_line(out_rec);
  END FIN_DAY_BOOK;
END FIN_DAY_BOOK;
/
