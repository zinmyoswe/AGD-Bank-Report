CREATE OR REPLACE PACKAGE               FIN_JOURNAL_ENTRIES_LISTING AS 

 PROCEDURE FIN_JOURNAL_ENTRIES_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_JOURNAL_ENTRIES_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_JOURNAL_ENTRIES_LISTING
AS
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_currencyType VARCHAR2(30);      -- Input to procedure
  vi_currency     VARCHAR2(3);
  vi_StartDate    VARCHAR2(10); -- Input to procedure
  vi_EndDate      VARCHAR2(10); -- Input to procedure
  vi_branchCode   VARCHAR2(5);  -- Input to procedure
  --vi_TransactionType    varchar2(20);
  vi_ChannelType  VARCHAR2(30);
  vi_TranType     VARCHAR2(10);
  vi_PartTranType VARCHAR2(10);
  vi_rate         DECIMAL;
  vi_ATMType      VARCHAR2(10);
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --(1) CURSOR ExtractDataCoreWithoutHOWithMMK
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreWithoutHOMMK ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 , ci_CurrencyCode VARCHAR2 )
  IS
    SELECT DISTINCT CTD.TRAN_ID AS TranID,
      GAM.foracid      AS AccountNo,
      gsh.gl_sub_head_desc      AS Description,
      GAM.ACCT_NAME             AS AcctName,
      CTD.TRAN_PARTICULAR       AS Description,
      CTD.ENTRY_USER_ID         AS TellerName,
      CTD.TRAN_PARTICULAR_CODE      AS TType,
      CTD.PART_TRAN_TYPE        AS PartTranType,
      CTD.TRAN_TYPE             AS TranType,
      CTD.TRAN_AMT              AS TranAmt,
      sol.abbr_br_name          AS BranchName,
      CTD.TRAN_DATE             AS TranDate
      --case  when Upper(ci_Currency) = 'MMK'  then CTD.TRAN_AMT  else 0 end as MMKAmt,
      -- case  when Upper(ci_Currency) = 'USD'  then CTD.TRAN_AMT * vi_rate else 0 end as MMKAmt
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gam.sol_id           = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    And Ctd.Tran_Date       <= To_Date( Cast ( Ci_Enddate As   Varchar(10) ) , 'dd-MM-yyyy')
    AND CTD.Tran_CRNCY_CODE   = UPPER(ci_CurrencyCode)
    AND GAM.acct_crncy_code  = UPPER(ci_CurrencyCode)
    AND gsh.crncy_code       = UPPER(ci_CurrencyCode)
    AND CTD.PSTD_FLG         = 'Y'
    AND CTD.SOL_ID        like   '%' || ci_BranchCode || '%'
   -- AND gsh.SOL_ID         like  '%' || ci_BranchCode || '%'
   -- And Gam.Sol_Id         Like  '%' || Ci_Branchcode || '%'
    --And Sol.Sol_Id        Like   '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG          = 'N'
    AND GAM.bank_id          = '01'
    AND gsh.bank_id          = '01'
    AND CTD.bank_id          = '01'
    And Sol.Bank_Id          = '01'
    --AND GAM.acct_cls_flg     = 'N'
    --AND CTD.TRAN_TYPE        = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
      --AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%'
    AND (CTD.tran_id,CTD.tran_date) NOT IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE (DCC_ID  = 'BWY'
      OR DCC_ID      = 'EFT')
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      )
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID;
  ---------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --(2) CURSOR ExtractDataCoreWithoutHOWithAll
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreWithoutHOAll ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2  )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      
      from(
      select DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      Case When Q.Cur = 'MMK' Then Q.Tran_Amt 
      ELSE q.TRAN_AMT * NVL((SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      
      from(
      select DISTINCT CTD.TRAN_ID,GAM.foracid ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
      
      --case  when Upper(ci_Currency) = 'MMK'  then CTD.TRAN_AMT  else 0 end as MMKAmt,
      -- case  when Upper(ci_Currency) = 'USD'  then CTD.TRAN_AMT * vi_rate else 0 end as MMKAmt
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gam.sol_id           = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE       <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND    CTD.ref_CRNCY_CODE = UPPER('mmk')
      --and GAM.acct_crncy_code = UPPER('mmk')
      --and gsh.crncy_code = UPPER('mmk')
    AND CTD.PSTD_FLG        = 'Y'
    And Ctd.Sol_Id          Like '%' || Ci_Branchcode || '%'
  --  And Gsh.Sol_Id          Like '%' || Ci_Branchcode || '%'
   -- AND gam.sol_id         like '%' || ci_BranchCode || '%'
   -- And Sol.Sol_Id          Like '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG         = 'N'
    AND GAM.bank_id         = '01'
    AND gsh.bank_id         = '01'
    AND CTD.bank_id         = '01'
    And Sol.Bank_Id         = '01'
   -- AND GAM.acct_cls_flg    = 'N'
    --AND CTD.TRAN_TYPE       = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
      --AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%'
    AND (CTD.tran_id,CTD.tran_date) NOT IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE (DCC_ID  = 'BWY'
      OR DCC_ID      = 'EFT')
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      )
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  ------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  --(3) CURSOR ExtractDataCoreWithoutHOWithAllFCY
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreWithoutHO_FCY ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2  )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      from(
      select DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      from(
      select DISTINCT CTD.TRAN_ID,GAM.foracid ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
      --case  when Upper(ci_Currency) = 'MMK'  then CTD.TRAN_AMT  else 0 end as MMKAmt,
      -- case  when Upper(ci_Currency) = 'USD'  then CTD.TRAN_AMT * vi_rate else 0 end as MMKAmt
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gsh.sol_id           = gam.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    And Ctd.Tran_Date       <= To_Date( Cast ( Ci_Enddate As   Varchar(10) ) , 'dd-MM-yyyy')
    And Ctd.Tran_Crncy_Code  != Upper('mmk')
    And Gam.Acct_Crncy_Code  != Upper('mmk')
    AND gsh.crncy_code       != UPPER('mmk')
    AND CTD.PSTD_FLG         = 'Y'
    AND CTD.SOL_ID           like '%' || ci_BranchCode || '%'
   -- And Gsh.Sol_Id           Like '%' || Ci_Branchcode || '%'
   -- And Gam.Sol_Id          Like '%' || Ci_Branchcode || '%'
   -- And Sol.Sol_Id           Like '%' || Ci_Branchcode || '%'
  --  AND CTD.dth_init_sol_id  like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG          = 'N'
    AND GAM.bank_id          = '01'
    AND gsh.bank_id          = '01'
    AND CTD.bank_id          = '01'
    And Sol.Bank_Id          = '01'
   -- AND GAM.acct_cls_flg     = 'N'
    --AND CTD.TRAN_TYPE        = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
      --AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%'
    AND (CTD.tran_id,CTD.tran_date) NOT IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE (DCC_ID  = 'BWY'
      OR DCC_ID      = 'EFT')
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      )
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  -----------------------------------------------------------------------------
  --(4) CURSOR ExtractDataCoreAllWithoutHOWithMMK
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreAllWithoutHOMMK ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_CurrencyCode VARCHAR2)
  IS
    SELECT DISTINCT CTD.TRAN_ID AS TranID,
      GAM.foracid      AS AccountNo,
      gsh.gl_sub_head_desc      AS Description,
      GAM.ACCT_NAME             AS AcctName,
      CTD.TRAN_PARTICULAR       AS Description,
      CTD.ENTRY_USER_ID         AS TellerName,
      CTD.TRAN_PARTICULAR_CODE  AS TType,
      CTD.PART_TRAN_TYPE        AS PartTranType,
      CTD.TRAN_TYPE             AS TranType,
      CTD.TRAN_AMT              AS TranAmt,
      sol.abbr_br_name          AS BranchName,
      CTD.TRAN_DATE             AS TranDate
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gam.sol_id           = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE       <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND CTD.TRAN_CRNCY_CODE  = UPPER(ci_CurrencyCode)
    AND GAM.acct_crncy_code  = UPPER(ci_CurrencyCode)
    AND gsh.crncy_code       = UPPER(ci_CurrencyCode)
    AND CTD.PSTD_FLG         = 'Y'
    AND CTD.SOL_ID           like '%' || ci_BranchCode || '%'
    --And Gsh.Sol_Id           Like '%' || Ci_Branchcode || '%'
    --And Gam.Sol_Id          Like '%' || Ci_Branchcode || '%'
   -- And Sol.Sol_Id           Like '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id  like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG          = 'N'
    AND GAM.bank_id          = '01'
    AND gsh.bank_id          = '01'
    AND CTD.bank_id          = '01'
    And Sol.Bank_Id          = '01'
   -- AND GAM.acct_cls_flg     = 'N'
      --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
      (SELECT DISTINCT(trim(CONT_TRAN_ID)),
        CONT_TRAN_DATE
      FROM tbaadm.atd
      WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      AND REVERSAL_FLG      = 'O'
      )
    --AND    CTD.TRAN_PARTICULAR_CODE = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3)))
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID;
  -----------------------------------------------------------------------------
  --(5) CURSOR ExtractDataCoreAllWithoutHOWithAll
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreAllWithoutHOAll ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE  AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      from(
      select DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      from(
      select DISTINCT CTD.TRAN_ID,GAM.foracid ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and  gam.sol_id          = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE       <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND    CTD.TRAN_CRNCY_CODE = UPPER('mmk')
      --and GAM.acct_crncy_code = UPPER('mmk')
      --and gsh.crncy_code = UPPER('mmk')
    AND CTD.PSTD_FLG        = 'Y'
    AND CTD.SOL_ID          like '%' || ci_BranchCode || '%'
  --  And Gsh.Sol_Id          Like '%' || Ci_Branchcode || '%'
  --  And Gam.Sol_Id          Like '%' || Ci_Branchcode || '%'
  --  And Sol.Sol_Id          Like '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG         = 'N'
    AND GAM.bank_id         = '01'
    AND gsh.bank_id         = '01'
    AND CTD.bank_id         = '01'
    And Sol.Bank_Id         = '01'
    --AND GAM.acct_cls_flg    = 'N'
      --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
      (SELECT DISTINCT(trim(CONT_TRAN_ID)),
        CONT_TRAN_DATE
      FROM tbaadm.atd
      WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      AND REVERSAL_FLG      = 'O'
      )
    --AND    CTD.TRAN_PARTICULAR_CODE = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3)))
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  -----------------------------------------------------------------------------
  --(6) CURSOR ExtractDataCoreAllWithoutHOWithAllFCY
  -----------------------------------------------------------------------------
  CURSOR ExtractCoreAllWithoutHO_FCY ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE  AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      from(
      select DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      from(
      select DISTINCT CTD.TRAN_ID,GAM.foracid ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gam.sol_id           = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE       <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND CTD.TRAN_CRNCY_CODE != UPPER('mmk')
    AND GAM.acct_crncy_code != UPPER('mmk')
    AND gsh.crncy_code      != UPPER('mmk')
    AND CTD.PSTD_FLG         = 'Y'
    And Ctd.Sol_Id           Like '%' || Ci_Branchcode || '%'
   -- AND gsh.SOL_ID           like '%' || ci_BranchCode || '%'
   --AND gam.sol_id           like '%' || ci_BranchCode || '%'
   -- And Sol.Sol_Id           Like '%' || Ci_Branchcode || '%'
    --AND CTD.dth_init_sol_id  like '%' || ci_BranchCode || '%'
    AND CTD.DEL_FLG          = 'N'
    AND GAM.bank_id          = '01'
    AND gsh.bank_id          = '01'
    AND CTD.bank_id          = '01'
    And Sol.Bank_Id          = '01'
    --AND GAM.acct_cls_flg     = 'N'
      --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
      --AND CTD.PART_TRAN_TYPE = 'C'
    AND (CTD.tran_id,CTD.tran_date) NOT IN
      (SELECT DISTINCT(CONT_TRAN_ID),
        CONT_TRAN_DATE
      FROM tbaadm.atd
      WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      AND REVERSAL_FLG      = 'O'
      )
    --AND    CTD.TRAN_PARTICULAR_CODE = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3)))
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  -----------------------------------------------------------------------------
  --(7) CURSOR ExtractDataEBankingWithoutHOWithMMK
  -----------------------------------------------------------------------------
  CURSOR ExtractEBankingWithoutHOMMK ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2, ci_CurrencyCode VARCHAR2)
  IS
     SELECT distinct CTD.TRAN_ID AS TranID,
      GAM.foracid      AS AccountNo,
      gsh.gl_sub_head_desc      AS Description,
      GAM.ACCT_NAME             AS AcctName,
      CTD.TRAN_PARTICULAR       AS Description,
      CTD.ENTRY_USER_ID         AS TellerName,
      CTD.TRAN_PARTICULAR_CODE      AS TType,
      CTD.PART_TRAN_TYPE        AS PartTranType,
      CTD.TRAN_TYPE             AS TranType,
      CTD.TRAN_AMT              AS TranAmt,
      sol.abbr_br_name          AS BranchName,
      CTD.TRAN_DATE             AS TranDate
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    Where Ctd.Acid                     = Gam.Acid  
    AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    And Ctd.Gl_Sub_Head_Code         = Gsh.Gl_Sub_Head_Code 
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    And Ctd.Tran_Crncy_Code          = Upper(Ci_Currencycode) 
    And Gam.Acct_Crncy_Code  = Upper(Ci_Currencycode) 
    AND gsh.crncy_code               = UPPER(Ci_Currencycode)
    AND CTD.PSTD_FLG                 = 'Y'  
    AND (CTD.SOL_ID   like '%' || ci_BranchCode || '%' or  CTD.SOL_ID   = '10100') 
    And Gsh.Sol_Id                   = Ctd.Sol_Id   
    AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    And Ctd.Del_Flg                  = 'N' 
    AND GAM.bank_id                  = '01'
    And Gsh.Bank_Id                  = '01'  
    AND CTD.bank_id                  = '01'
    And Sol.Bank_Id                  = '01' 
    --AND GAM.acct_cls_flg             = 'N'
    and ctd.entry_user_id = 'FIVUSR'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(TRAN_ID),
        TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav
      WHERE cdav.sol_id like '%' || ci_BranchCode || '%'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and cdav.entry_user_id = 'FIVUSR'
      )      --  group by ctd.tran_id,ctd.sol_id
  --ORDER BY ctd.tran_date,CTD.TRAN_ID
  
  union
  
  SELECT distinct CTD.TRAN_ID AS TranID,
      GAM.foracid      AS AccountNo,
      gsh.gl_sub_head_desc      AS Description,
      GAM.ACCT_NAME             AS AcctName,
      CTD.TRAN_PARTICULAR       AS Description,
      CTD.ENTRY_USER_ID         AS TellerName,
      CTD.TRAN_PARTICULAR_CODE      AS TType,
      CTD.PART_TRAN_TYPE        AS PartTranType,
      CTD.TRAN_TYPE             AS TranType,
      CTD.TRAN_AMT              AS TranAmt,
      sol.abbr_br_name          AS BranchName,
      CTD.TRAN_DATE             AS TranDate
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    Where Ctd.Acid                     = Gam.Acid  
    AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    And Ctd.Gl_Sub_Head_Code         = Gsh.Gl_Sub_Head_Code 
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    And Ctd.Tran_Crncy_Code          = Upper(Ci_Currencycode) 
    And Gam.Acct_Crncy_Code  = Upper(Ci_Currencycode) 
    AND gsh.crncy_code               = UPPER(Ci_Currencycode)
    AND CTD.PSTD_FLG                 = 'Y'  
    AND(CTD.SOL_ID   like '%' || ci_BranchCode || '%' or  CTD.SOL_ID   = '10100')  
    And Gsh.Sol_Id                   = Ctd.Sol_Id   
    AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    AND CTD.DEL_FLG                  = 'N' AND GAM.bank_id                  = '01'
    And Gsh.Bank_Id                  = '01'  And Ctd.Bank_Id                  = '01'
    AND sol.bank_id                  = '01'-- AND GAM.acct_cls_flg             = 'N'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(cdav.TRAN_ID),
        cdav.TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav,tbaadm.rtt
      WHERE cdav.sol_id like '%' || ci_BranchCode || '%'
      AND cdav.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND cdav.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and trim(cdav.tran_id )= trim(rtt.tran_id)
      and rtt.DCC_ID   = 'BWY'
      --and cdav.entry_user_id = 'FIVUSR'
      )   
   ;  
  -----------------------------------------------------------------------------
  --(8) CURSOR ExtractDataEBankingWithoutHOWithAll
  -----------------------------------------------------------------------------
  CURSOR ExtractEBankingWithoutHOAll ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 )
  IS
    select DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
from
(select  DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
from
(SELECT distinct CTD.TRAN_ID ,
      GAM.foracid      ,
      gsh.gl_sub_head_desc      ,
      GAM.ACCT_NAME            ,
      CTD.TRAN_PARTICULAR      ,
      CTD.ENTRY_USER_ID         ,
      CTD.TRAN_PARTICULAR_CODE      ,
      CTD.PART_TRAN_TYPE        ,
      CTD.TRAN_TYPE             ,
      CTD.TRAN_AMT              ,
      sol.abbr_br_name          ,
      CTD.TRAN_DATE             ,
      CTD.ref_crncy_code as cur
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    Where Ctd.Acid                     = Gam.Acid  
    AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    And Ctd.Gl_Sub_Head_Code         = Gsh.Gl_Sub_Head_Code 
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    --AND CTD.TRAN_CRNCY_CODE          = UPPER(ci_CurrencyCode) AND GAM.acct_crncy_code  = UPPER(ci_CurrencyCode) AND gsh.crncy_code               = UPPER('MMK')
    AND CTD.PSTD_FLG                 = 'Y'  
    AND (CTD.SOL_ID   like '%' || ci_branchCode || '%' or  CTD.SOL_ID   = '10100') 
    And Gsh.Sol_Id                   = Ctd.Sol_Id   
    AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    AND CTD.DEL_FLG                  = 'N' AND GAM.bank_id                  = '01'
    And Gsh.Bank_Id                  = '01'  And Ctd.Bank_Id                  = '01'
    AND sol.bank_id                  = '01' --AND GAM.acct_cls_flg             = 'N'
    and ctd.entry_user_id = 'FIVUSR'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( '27-2-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(TRAN_ID),
        TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav
      WHERE cdav.sol_id like '%' || ci_branchCode || '%'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and cdav.entry_user_id = 'FIVUSR'
      ) 
      ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID )q 
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID) T
     
  union
  select DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
from
  
 ( select  DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
from
  (SELECT distinct CTD.TRAN_ID ,
      GAM.foracid      ,
      gsh.gl_sub_head_desc     ,
      GAM.ACCT_NAME            ,
      CTD.TRAN_PARTICULAR       ,
      CTD.ENTRY_USER_ID         ,
      CTD.TRAN_PARTICULAR_CODE    ,
      CTD.PART_TRAN_TYPE       ,
      CTD.TRAN_TYPE            ,
      CTD.TRAN_AMT              ,
      sol.abbr_br_name         ,
      CTD.TRAN_DATE             ,
      CTD.ref_crncy_code as cur
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    WHERE CTD.ACID                     = GAM.ACID  AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    AND CTD.gl_sub_head_code         = gsh.gl_sub_head_code AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    --AND CTD.TRAN_CRNCY_CODE          = UPPER(ci_CurrencyCode) AND GAM.acct_crncy_code  = UPPER(ci_CurrencyCode) AND gsh.crncy_code               = UPPER('MMK')
    AND CTD.PSTD_FLG                 = 'Y'  
    AND(CTD.SOL_ID   like '%' || ci_branchCode || '%' or  CTD.SOL_ID   = '10100')  
    AND gsh.SOL_ID                   = CTD.SOL_ID   AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    AND CTD.DEL_FLG                  = 'N' AND GAM.bank_id                  = '01'
    And Gsh.Bank_Id                  = '01'  And Ctd.Bank_Id                  = '01'
    AND sol.bank_id                  = '01'-- AND GAM.acct_cls_flg             = 'N'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( '27-2-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(cdav.TRAN_ID),
        cdav.TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav,tbaadm.rtt
      WHERE cdav.sol_id like '%' || ci_branchCode || '%'
      AND cdav.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND cdav.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and trim(cdav.tran_id )= trim(rtt.tran_id)
      and rtt.DCC_ID   = 'BWY'
      --and cdav.entry_user_id = 'FIVUSR'
      ) ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID )q 
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
    
   ;
  -----------------------------------------------------------------------------
  --(9) CURSOR ExtractDataEBankingWithoutHOWithAllFCY
  -----------------------------------------------------------------------------
  CURSOR ExtractEBankingWithoutHO_FCY ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 )
  IS
   select DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
from
(select  DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
from
(SELECT distinct CTD.TRAN_ID ,
      GAM.foracid      ,
      gsh.gl_sub_head_desc      ,
      GAM.ACCT_NAME            ,
      CTD.TRAN_PARTICULAR      ,
      CTD.ENTRY_USER_ID         ,
      CTD.TRAN_PARTICULAR_CODE      ,
      CTD.PART_TRAN_TYPE        ,
      CTD.TRAN_TYPE             ,
      CTD.TRAN_AMT              ,
      sol.abbr_br_name          ,
      CTD.TRAN_DATE             ,
      CTD.ref_crncy_code as cur
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    Where Ctd.Acid                     = Gam.Acid  
    AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    And Ctd.Gl_Sub_Head_Code         = Gsh.Gl_Sub_Head_Code 
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    And Ctd.Tran_Crncy_Code          != Upper('MMK') 
    And Gam.Acct_Crncy_Code  != Upper('MMK') 
    AND gsh.crncy_code               != UPPER('MMK')
    AND CTD.PSTD_FLG                 = 'Y'  
    AND (CTD.SOL_ID   like '%' || ci_branchCode || '%' or  CTD.SOL_ID   = '10100') 
    And Gsh.Sol_Id                   = Ctd.Sol_Id   
    AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    AND CTD.DEL_FLG                  = 'N' AND GAM.bank_id                  = '01'
    And Gsh.Bank_Id                  = '01'  And Ctd.Bank_Id                  = '01'
    AND sol.bank_id                  = '01'-- AND GAM.acct_cls_flg             = 'N'
    and ctd.entry_user_id = 'FIVUSR'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( '27-2-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(TRAN_ID),
        TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav
      WHERE cdav.sol_id like '%' || ci_branchCode || '%'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and cdav.entry_user_id = 'FIVUSR'
      ) 
      ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID )q 
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID) T
     
  union
  select DISTINCT T.TRAN_ID AS TranID,
      T.foracid      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
from
  
 ( select  DISTINCT q.TRAN_ID,q.foracid,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
from
  (SELECT distinct CTD.TRAN_ID ,
      GAM.foracid      ,
      gsh.gl_sub_head_desc     ,
      GAM.ACCT_NAME            ,
      CTD.TRAN_PARTICULAR       ,
      CTD.ENTRY_USER_ID         ,
      CTD.TRAN_PARTICULAR_CODE    ,
      CTD.PART_TRAN_TYPE       ,
      CTD.TRAN_TYPE            ,
      CTD.TRAN_AMT              ,
      sol.abbr_br_name         ,
      CTD.TRAN_DATE             ,
      CTD.ref_crncy_code as cur
     -- count(ctd.tran_id),ctd.tran_id,ctd.sol_id
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,  TBAADM.GAM GAM,  tbaadm.sol sol,  tbaadm.gsh gsh
    WHERE CTD.ACID                     = GAM.ACID  AND GAM.sol_id  = sol.sol_id --AND CTD.sol_id                   = sol.sol_id
    AND CTD.gl_sub_head_code         = gsh.gl_sub_head_code AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND CTD.TRAN_CRNCY_CODE          != UPPER('MMK') AND GAM.acct_crncy_code  != UPPER('MMK') AND gsh.crncy_code               != UPPER('MMK')
    AND CTD.PSTD_FLG                 = 'Y'  
    AND(CTD.SOL_ID   like '%' || ci_branchCode || '%' or  CTD.SOL_ID   = '10100')  
    AND gsh.SOL_ID                   = CTD.SOL_ID   AND gam.sol_id                   = CTD.SOL_ID 
    and sol.sol_id =CTD.SOL_ID
    AND CTD.DEL_FLG                  = 'N' AND GAM.bank_id                  = '01'
    AND gsh.bank_id                  = '01'  AND CTD.bank_id                  = '01'
    AND sol.bank_id                  = '01' AND GAM.acct_cls_flg             = 'N'
    AND (trim(CTD.tran_id),CTD.tran_date) NOT IN (SELECT DISTINCT(trim(CONT_TRAN_ID)), CONT_TRAN_DATE  FROM tbaadm.atd  WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( '27-2-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    AND (trim(CTD.tran_id),CTD.tran_date) IN
      (SELECT distinct trim(cdav.TRAN_ID),
        cdav.TRAN_DATE
      FROM TBAADM.ctd_dtd_acli_view cdav,tbaadm.rtt
      WHERE cdav.sol_id like '%' || ci_branchCode || '%'
      AND cdav.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND cdav.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      and trim(cdav.tran_id )= trim(rtt.tran_id)
      and rtt.DCC_ID   = 'BWY'
      --and cdav.entry_user_id = 'FIVUSR'
      ) ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID )q 
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
    
   ;
  -----------------------------------------------------------------------------
  --(10) CURSOR ExtractDataATMBankingWithoutHOWithMMK
  -----------------------------------------------------------------------------
  CURSOR ExtractATMBankingWithoutHOMMK ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_CurrencyCode VARCHAR2 )
  IS
    SELECT DISTINCT CTD.TRAN_ID AS TranID,
      GAM.Gl_sub_head_code      AS AccountNo,
      gsh.gl_sub_head_desc      AS Description,
      GAM.ACCT_NAME             AS AcctName,
      CTD.TRAN_PARTICULAR       AS Description,
      CTD.ENTRY_USER_ID         AS TellerName,
      TRAN_PARTICULAR_CODE      AS TType,
      CTD.PART_TRAN_TYPE        AS PartTranType,
      CTD.TRAN_TYPE             AS TranType,
      CTD.TRAN_AMT              AS TranAmt,
      sol.abbr_br_name          AS BranchName,
      CTD.TRAN_DATE             AS TranDate
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID                 =CTD.DTH_INIT_SOL_ID
     CTD.ACID                     = GAM.ACID
    AND GAM.sol_id                   = sol.sol_id
    And Ctd.Sol_Id                   = Sol.Sol_Id
    and gam.sol_id                  = gsh.sol_id
    AND CTD.gl_sub_head_code         = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND CTD.TRAN_CRNCY_CODE          = UPPER(ci_CurrencyCode)
    AND GAM.acct_crncy_code          = UPPER(ci_CurrencyCode)
    AND gsh.crncy_code               = UPPER(ci_CurrencyCode)
    AND CTD.PSTD_FLG                 = 'Y'
    AND CTD.SOL_ID                   like '%' || ci_branchCode || '%'
   -- And Gsh.Sol_Id                   Like '%' || Ci_Branchcode || '%'
   -- AND gam.sol_id                   like '%' || ci_branchCode || '%'
   -- And Sol.Sol_Id                   Like '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id          like '%' || ci_branchCode || '%'
    AND CTD.DEL_FLG                  = 'N'
    AND GAM.bank_id                  = '01'
    AND gsh.bank_id                  = '01'
    AND CTD.bank_id                  = '01'
    And Sol.Bank_Id                  = '01'
    --AND GAM.acct_cls_flg             = 'N'
    AND (CTD.tran_id,CTD.tran_date) IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE DCC_ID   = 'EFT'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND CMD        = ci_ATMType
      )
    --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
    --AND CTD.PART_TRAN_TYPE = 'C'
    -- AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%_'
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID;
  -----------------------------------------------------------------------------
  --(11) CURSOR ExtractDataATMBankingWithoutHOWithAll
  -----------------------------------------------------------------------------
  CURSOR ExtractATMBankingWithoutHOAll ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2  )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.Gl_sub_head_code      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      from(
      select DISTINCT q.TRAN_ID,q.Gl_sub_head_code,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      from(
      select DISTINCT CTD.TRAN_ID,GAM.Gl_sub_head_code ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID         =CTD.DTH_INIT_SOL_ID
     CTD.ACID             = GAM.ACID
    AND GAM.sol_id           = sol.sol_id
    And Ctd.Sol_Id           = Sol.Sol_Id
    and gam.sol_id          = gsh.sol_id
    AND CTD.gl_sub_head_code = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code = gam.gl_sub_head_code
    AND CTD.TRAN_DATE       >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE       <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND    CTD.TRAN_CRNCY_CODE = UPPER('mmk')
      --and GAM.acct_crncy_code = UPPER('mmk')
      --and gsh.crncy_code = UPPER('mmk')
    AND CTD.PSTD_FLG                 = 'Y'
    And Ctd.Sol_Id                   Like '%' || Ci_Branchcode || '%'
    --AND gsh.SOL_ID                   like '%' || ci_branchCode || '%'
   -- And Gam.Sol_Id                   Like '%' || Ci_Branchcode || '%'
    --And Sol.Sol_Id                   Like '%' || Ci_Branchcode || '%'
   -- AND CTD.dth_init_sol_id          like '%' || ci_branchCode || '%'
    AND CTD.DEL_FLG                  = 'N'
    AND GAM.bank_id                  = '01'
    AND gsh.bank_id                  = '01'
    AND CTD.bank_id                  = '01'
    And Sol.Bank_Id                  = '01'
    --AND GAM.acct_cls_flg             = 'N'
    AND (CTD.tran_id,CTD.tran_date) IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE DCC_ID   = 'EFT'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND CMD        = ci_ATMType
      )
    --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
    --AND CTD.PART_TRAN_TYPE = 'C'
    -- AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%_'
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  -----------------------------------------------------------------------------
  --(12) CURSOR ExtractDataATMBankingWithoutHOWithAllFCY
  -----------------------------------------------------------------------------
  CURSOR ExtractATMBankingWithoutHO_FCY ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2  )
  IS
    SELECT DISTINCT T.TRAN_ID AS TranID,
      T.Gl_sub_head_code      AS AccountNo,
      T.gl_sub_head_desc      AS Description,
      T.ACCT_NAME             AS AcctName,
      T.TRAN_PARTICULAR       AS Description,
      T.ENTRY_USER_ID         AS TellerName,
      T.TRAN_PARTICULAR_CODE      AS TType,
      T.PART_TRAN_TYPE        AS PartTranType,
      T.TRAN_TYPE             AS TranType,
      T.TRAN_AMT              AS TranAmt,
      T.abbr_br_name          AS BranchName,
      T.TRAN_DATE             AS TranDate
      from(
      select DISTINCT q.TRAN_ID,q.Gl_sub_head_code,q.gl_sub_head_desc,q.ACCT_NAME,q.TRAN_PARTICULAR,q.ENTRY_USER_ID,q.TRAN_PARTICULAR_CODE,
            q.PART_TRAN_TYPE,q.TRAN_TYPE,
      CASE WHEN q.cur = 'MMK' THEN q.TRAN_AMT 
      ELSE q.TRAN_AMT * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      From Tbaadm.Rth A
                                                                      where a.Rtlist_date = TO_DATE( CAST (  q.TRAN_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                            ),1) END AS TRAN_AMT,
      q.abbr_br_name,q.TRAN_DATE
      from(
      select DISTINCT CTD.TRAN_ID,GAM.Gl_sub_head_code ,gsh.gl_sub_head_desc,
      GAM.ACCT_NAME ,CTD.TRAN_PARTICULAR ,CTD.ENTRY_USER_ID ,CTD.TRAN_PARTICULAR_CODE,
      CTD.PART_TRAN_TYPE ,CTD.TRAN_TYPE,CTD.TRAN_AMT  ,sol.abbr_br_name ,CTD.TRAN_DATE,
      CTD.ref_crncy_code as cur
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,
      TBAADM.GAM GAM,
      tbaadm.sol sol,
      Tbaadm.Gsh Gsh
    WHERE --CTD.SOL_ID                 =CTD.DTH_INIT_SOL_ID
     CTD.ACID                     = GAM.ACID
    AND GAM.sol_id                   = sol.sol_id
    And Ctd.Sol_Id                   = Sol.Sol_Id
    and gam.sol_id                  = gsh.sol_id
    AND CTD.gl_sub_head_code         = gsh.gl_sub_head_code
    AND gsh.gl_sub_head_code         = gam.gl_sub_head_code
    AND CTD.TRAN_DATE               >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CTD.TRAN_DATE               <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND CTD.TRAN_CRNCY_CODE         != UPPER('mmk')
    AND GAM.acct_crncy_code         != UPPER('mmk')
    AND gsh.crncy_code              != UPPER('mmk')
    AND CTD.PSTD_FLG                 = 'Y'
    And Ctd.Sol_Id                  Like '%' || Ci_Branchcode || '%'
    --AND gsh.SOL_ID                   = ci_BranchCode
   -- AND gam.sol_id                   = ci_BranchCode
    --AND sol.sol_id                   = ci_BranchCode
    --AND CTD.dth_init_sol_id          = ci_BranchCode
    AND CTD.DEL_FLG                  = 'N'
    AND GAM.bank_id                  = '01'
    AND gsh.bank_id                  = '01'
    AND CTD.bank_id                  = '01'
    And Sol.Bank_Id                  = '01'
   -- AND GAM.acct_cls_flg             = 'N'
    AND (CTD.tran_id,CTD.tran_date) IN
      (SELECT TRAN_ID,
        TRAN_DATE
      FROM TBAADM.RTT
      WHERE DCC_ID   = 'EFT'
      AND TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
      --AND CMD        = ci_ATMType
      )
    --AND    CTD.TRAN_TYPE = Upper(ci_TranType) ---
    --AND CTD.PART_TRAN_TYPE = 'C'
    -- AND    CTD.TRAN_PARTICULAR_CODE like ci_TransactionType || '%_'
  AND (trim(CTD.tran_id),CTD.tran_date) NOT IN
    (SELECT DISTINCT(trim(CONT_TRAN_ID)),
      CONT_TRAN_DATE
    FROM tbaadm.atd
    WHERE CONT_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND CONT_TRAN_DATE   <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy')
    AND REVERSAL_FLG      = 'O'
    )
    --AND    sot.SOL_ID = CTD.SOL_ID
    --AND    sot.BR_CODE = bct.BR_CODE
    --or CTD.TRAN_PARTICULAR_CODE LIKE 'TRW%'-- c   trw d
  ORDER BY CTD.TRAN_DATE,
    CTD.TRAN_ID)q
    ORDER BY q.TRAN_DATE,
    q.TRAN_ID)T
     ORDER BY T.TRAN_DATE,
    T.TRAN_ID;
  
  ----------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIN_JOURNAL_ENTRIES_LISTING(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_TranID TBAADM.CTD_DTD_ACLI_VIEW.TRAN_ID%TYPE;
  v_gl_code TBAADM.GAM.foracid%TYPE;
  v_description tbaadm.gsh.gl_sub_head_desc%type;
  v_AccName TBAADM.GAM.ACCT_NAME%TYPE;
  v_TranParticular TBAADM.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
  v_TellerName TBAADM.CTD_DTD_ACLI_VIEW.ENTRY_USER_ID%TYPE;
  v_TType TBAADM.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_CODE%TYPE;
  v_PartTranType TBAADM.CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE%TYPE;
  v_TranType TBAADM.CTD_DTD_ACLI_VIEW.TRAN_TYPE%TYPE;
  v_TranAmt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE;
  v_BankName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_branchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_bankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  v_TranDate TBAADM.CTD_DTD_ACLI_VIEW.TRAN_Date%TYPE;
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
  vi_StartDate    := outArr(0);
  vi_EndDate      := outArr(1);
  vi_currencyType := outArr(2);
  vi_currency     := outArr(3);
  --vi_TransactionType := outArr(3);
  vi_ChannelType := outArr(4);
  vi_branchCode  := outArr(5);
  
  
  ----------------------------------------------------------------------------------------
  if( vi_StartDate is null or vi_EndDate is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		          '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
				  0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
				  '-' || '|' || '-' || '|' || 0 || '|' || '-' ); 
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  
  
  
  
  ------------------------------------------------------------------------------------------------
  
 /* 
  BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_currencyType      = 'Home Currency' THEN
      IF(upper(vi_currency) = 'MMK') THEN
        vi_rate            := 1;
      ELSE
        SELECT VAR_CRNCY_UNITS
        INTO vi_rate
        FROM tbaadm.RTL e
        WHERE TRIM(FXD_CRNCY_CODE) = upper(vi_currency)
        AND TRIM(VAR_CRNCY_CODE)   = 'MMK'
        AND RATECODE               =
          (SELECT variable_value
          FROM custom.CUST_GENCUST_PARAM_MAINT
          WHERE module_name = 'FOREIGN_CURRENCY'
          AND variable_name = 'RATE_CODE'
          )
        AND rownum = 1
        ORDER BY rtlist_date DESC;
      END IF;
      ELSIF vi_currencyType           = 'Source Currency' THEN
          IF(upper(vi_currency) = 'MMK') THEN
        vi_rate            := 1;
      ELSE
        SELECT VAR_CRNCY_UNITS
        INTO vi_rate
        FROM tbaadm.RTL e
        WHERE TRIM(FXD_CRNCY_CODE) = upper(vi_currency)
        AND TRIM(VAR_CRNCY_CODE)   = 'MMK'
        AND RATECODE               =
          (SELECT variable_value
          FROM custom.CUST_GENCUST_PARAM_MAINT
          WHERE module_name = 'FOREIGN_CURRENCY'
          AND variable_name = 'RATE_CODE'
          )
        AND rownum = 1
        ORDER BY rtlist_date DESC;
      END IF;
    ELSE
      vi_rate := 1;
    END IF;
  END;*/
      ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    if vi_currencyType = 'Home Currency' then
      if(upper(vi_currency) = 'MMK') then vi_rate := 1;  
      else select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(v_TranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
      end if;
    else 
     Vi_Rate := 1;
    end if;
  ------------------------------------------------------------------------------------------------------------
  IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
  
  
    IF vi_ChannelType LIKE 'Core Banking%' THEN
      IF vi_currencyType NOT LIKE 'All%' THEN
        /*
        BWY - Ebanking
        EFT - Atm
        Core (not in BWY,EFT  )
        Core all
        begin
        IF vi_TransactionType like 'Deposit%' then
        vi_TransactionType := 'CHD';
        vi_TranType        := 'C';
        vi_PartTranType    := 'C';
        ELSIF vi_TransactionType like 'Withdrawal%' then
        vi_TransactionType := 'CHW';
        vi_TranType       := 'C';
        vi_PartTranType    := 'D';
        ELSIF vi_TransactionType like 'Transfer%' then
        vi_TransactionType := 'TR';
        vi_TranType        := 'T';
        vi_PartTranType    := 'D';
        ELSE
        vi_TransactionType := 'TRWCHDCHWTRD';
        END IF;
        END;*/
        -- IF vi_TransactionType NOT like 'TRWCHDCHWTRD' THEN
        --{
        IF NOT ExtractCoreWithoutHOMMK%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreWithoutHOMMK ( vi_StartDate , vi_EndDate , vi_branchCode, vi_currency );
            --}
          END;
          --}
        END IF;
        IF ExtractCoreWithoutHOMMK%ISOPEN THEN
          --{
          FETCH ExtractCoreWithoutHOMMK
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreWithoutHOMMK%NOTFOUND THEN
            --{
            CLOSE ExtractCoreWithoutHOMMK;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
        --}
      ELSIF vi_currencyType = 'All Currency' THEN
        IF NOT ExtractCoreWithoutHOAll%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreWithoutHOAll ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractCoreWithoutHOAll%ISOPEN THEN
          --{
          FETCH ExtractCoreWithoutHOAll
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreWithoutHOAll%NOTFOUND THEN
            --{
            CLOSE ExtractCoreWithoutHOAll;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
        --}
      ELSE ---alL fcy
        IF NOT ExtractCoreWithoutHO_FCY%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreWithoutHO_FCY ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractCoreWithoutHO_FCY%ISOPEN THEN
          --{
          FETCH ExtractCoreWithoutHO_FCY
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreWithoutHO_FCY%NOTFOUND THEN
            --{
            CLOSE ExtractCoreWithoutHO_FCY;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      END IF;--CURRENCY TYPE
      -------------------------------------------------------------------------------------------------------------------------------------------
    ELSIF vi_ChannelType LIKE 'All%' THEN
      IF vi_currencyType NOT LIKE 'All%'THEN
        IF NOT ExtractCoreAllWithoutHOMMK%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreAllWithoutHOMMK ( vi_StartDate , vi_EndDate , vi_branchCode, vi_currency );
            --}
          END;
          --}
        END IF;
        IF ExtractCoreAllWithoutHOMMK%ISOPEN THEN
          --{
          FETCH ExtractCoreAllWithoutHOMMK
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreAllWithoutHOMMK%NOTFOUND THEN
            --{
            CLOSE ExtractCoreAllWithoutHOMMK;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
        --}
      ELSIF vi_currencyType = 'All Currency' THEN
        IF NOT ExtractCoreAllWithoutHOAll%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreAllWithoutHOAll ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractCoreAllWithoutHOAll%ISOPEN THEN
          --{
          FETCH ExtractCoreAllWithoutHOAll
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreAllWithoutHOAll%NOTFOUND THEN
            --{
            CLOSE ExtractCoreAllWithoutHOAll;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      ELSE --aLL fcy
        IF NOT ExtractCoreAllWithoutHO_FCY%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractCoreAllWithoutHO_FCY ( vi_StartDate , vi_EndDate , vi_branchCode);
            --}
          END;
          --}
        END IF;
        IF ExtractCoreAllWithoutHO_FCY%ISOPEN THEN
          --{
          FETCH ExtractCoreAllWithoutHO_FCY
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractCoreAllWithoutHO_FCY%NOTFOUND THEN
            --{
            CLOSE ExtractCoreAllWithoutHO_FCY;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      END IF;--CURRENCY TYPE
      ----------------------------------------------------------------------------------------------------
    ELSIF vi_ChannelType LIKE 'EBanking%' THEN
      IF vi_currencyType NOT LIKE 'All%' THEN
        IF NOT ExtractEBankingWithoutHOMMK%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractEBankingWithoutHOMMK ( vi_StartDate , vi_EndDate , vi_branchCode, vi_currency );
            --}
          END;
          --}
        END IF;
        IF ExtractEBankingWithoutHOMMK%ISOPEN THEN
          --{
          FETCH ExtractEBankingWithoutHOMMK
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractEBankingWithoutHOMMK%NOTFOUND THEN
            --{
            CLOSE ExtractEBankingWithoutHOMMK;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      ELSIF vi_currencyType = 'All Currency' THEN
        IF NOT ExtractEBankingWithoutHOAll%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractEBankingWithoutHOAll ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractEBankingWithoutHOAll%ISOPEN THEN
          --{
          FETCH ExtractEBankingWithoutHOAll
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractEBankingWithoutHOAll%NOTFOUND THEN
            --{
            CLOSE ExtractEBankingWithoutHOAll;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      ELSE--FOR ALL FCY
        IF NOT ExtractEBankingWithoutHO_FCY%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractEBankingWithoutHO_FCY ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractEBankingWithoutHO_FCY%ISOPEN THEN
          --{
          FETCH ExtractEBankingWithoutHO_FCY
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractEBankingWithoutHO_FCY%NOTFOUND THEN
            --{
            CLOSE ExtractEBankingWithoutHO_FCY;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      END IF;--CURRENCY TYPE
      -------------------------------------------------------------------------------------------------------------
    ELSE -- FOR ATM BANKING
      IF vi_currencyType NOT LIKE 'All%' THEN
        /* IF vi_TransactionType like 'Withdrawal%' then
        vi_ATMType := 'CWD';
        ELSIF vi_TransactionType like 'Transfer%' then
        vi_ATMType  := 'TFR';
        ELSE
        dbms_output.put_line(vi_ATMType);
        END IF;*/
        IF NOT ExtractATMBankingWithoutHOMMK%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractATMBankingWithoutHOMMK ( vi_StartDate , vi_EndDate , vi_branchCode , vi_currency );
            --}
          END;
          --}
        END IF;
        IF ExtractATMBankingWithoutHOMMK%ISOPEN THEN
          --{
          FETCH ExtractATMBankingWithoutHOMMK
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractATMBankingWithoutHOMMK%NOTFOUND THEN
            --{
            CLOSE ExtractATMBankingWithoutHOMMK;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      ELSIF vi_currencyType = 'All Currency' THEN
        IF NOT ExtractATMBankingWithoutHOAll%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractATMBankingWithoutHOAll ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractATMBankingWithoutHOAll%ISOPEN THEN
          --{
          FETCH ExtractATMBankingWithoutHOAll
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractATMBankingWithoutHOAll%NOTFOUND THEN
            --{
            CLOSE ExtractATMBankingWithoutHOAll;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      ELSE --FOR FCY 
        IF NOT ExtractATMBankingWithoutHO_FCY%ISOPEN THEN
          --{
          BEGIN
            --{
            OPEN ExtractATMBankingWithoutHO_FCY ( vi_StartDate , vi_EndDate , vi_branchCode );
            --}
          END;
          --}
        END IF;
        IF ExtractATMBankingWithoutHO_FCY%ISOPEN THEN
          --{
          FETCH ExtractATMBankingWithoutHO_FCY
          INTO v_TranID,
            v_gl_code,
            v_description,
            v_AccName,
            v_TranParticular,
            v_TellerName,
            v_TType,
            v_PartTranType ,
            v_TranType,
            v_TranAmt,
            v_BankName,
            v_TranDate ;
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractATMBankingWithoutHO_FCY%NOTFOUND THEN
            --{
            CLOSE ExtractATMBankingWithoutHO_FCY;
            out_retCode:= 1;
            RETURN;
            --}
          END IF;
          --}
        END IF;
      END IF;--CURRENCY TYPE
    END IF;--CHANNEL TYPE
   
  ---------------------------------------------------------------------------------------------------------------------------
  BEGIN
    -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
    -------------------------------------------------------------------------------
    if vi_branchCode is not null then
    SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
      BRANCH_CODE_TABLE.BR_ADDR_1          AS "Bank_Address",
      BRANCH_CODE_TABLE.PHONE_NUM          AS "Bank_Phone",
      BRANCH_CODE_TABLE.FAX_NUM            AS "Bank_Fax"
    INTO v_branchName,
      v_bankAddress,
      v_bankPhone,
      v_bankFax
    FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
      TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
    end if;
  END;
  out_rec:= ( v_TranID || '|' || trim(v_gl_code) || '|' || v_description || '|' || v_AccName || '|' || v_TranParticular || '|' || v_TellerName || '|' || v_TType || '|' || v_PartTranType || '|' || v_TranType || '|' || v_TranAmt || '|' || v_branchName || '|' || v_bankAddress || '|' || v_bankPhone || '|' || v_bankFax || '|' || v_BankName || '|' || vi_rate || '|' || trim(TO_CHAR(to_date(v_TranDate,'dd/Mon/yy'), 'dd-MM-yyyy') ) );
  dbms_output.put_line(out_rec);
END FIN_JOURNAL_ENTRIES_LISTING;
END FIN_JOURNAL_ENTRIES_LISTING;
/
