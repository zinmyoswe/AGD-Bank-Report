CREATE OR REPLACE PACKAGE        FIN_ACQ_TRANS_REVERSAL_LISTING AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_ACQ_TRANS_REVERSAL_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2  );

END FIN_ACQ_TRANS_REVERSAL_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                      FIN_ACQ_TRANS_REVERSAL_LISTING AS
/******************************************************************************
 NAME:       FIN_ACQ_TRANS_REVERSAL_LISTING
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

  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array
  vi_startDate      VARCHAR2(10);               -- Input to procedure
  vi_endDate        VARCHAR2(10);               -- Input to procedure
  vi_cardType       VARCHAR2(30);               -- Input to procedure
  vi_branchCode     VARCHAR2(5);                -- Input to procedure
  vi_startTime      VARCHAR2(10);               -- Input to procedure
  vi_endTime        VARCHAR2(10);               -- Input to procedure
  vi_exRate         VARCHAR2(10);               -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_ACQ_TRANS_REVERSAL_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractDataByBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_cardType VARCHAR2, ci_branchCode VARCHAR2, ci_startTime VARCHAR2, ci_endTime VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , SUBSTR(NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' '),1,10) AS BINCODE, D.CHANNEL_DEVICE_ID AS TERMINAL_ID
        , DTT.TRAN_ID AS ENTRY_NO, NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ') AS CARD_NUMBER
        , DTT.PSTD_DATE AS DATEPART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , 0.00 AS N10000, 0.00 AS N5000, 0.00 AS N1000, DTT.TRAN_AMT
        , 0.00 AS INCOME--, DTT.CREDIT AS INCOME
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'DBRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      --AND TRUNC(B.PSTD_DATE) BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND B.PSTD_DATE >= TO_DATE(CONCAT(CONCAT(CAST(ci_startDate AS VARCHAR(10)), ' '),ci_startTime),'dd-MM-yyyy HH24:MI:SS') 
      AND B.PSTD_DATE <= TO_DATE(CONCAT(CONCAT(CAST(ci_endDate AS VARCHAR(10)), ' '),ci_endTime),'dd-MM-yyyy HH24:MI:SS')
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' --AND G.ACCT_CLS_FLG = 'N' 
  AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE SOL_ID LIKE '%' || ci_branchCode || '%'
      AND CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBRS'
      AND NVL(FREE_TEXT3,'') LIKE ci_cardType
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  WHERE --(TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') BETWEEN ci_startTime AND ci_endTime) AND
  NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  ORDER BY NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ');

CURSOR ExtractDataAllBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_cardType VARCHAR2, ci_startTime VARCHAR2, ci_endTime VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
      , SUBSTR(NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' '),1,10) AS BINCODE, D.CHANNEL_DEVICE_ID AS TERMINAL_ID
      , DTT.TRAN_ID AS ENTRY_NO, NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ') AS CARD_NUMBER
      , DTT.PSTD_DATE AS DATEPART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
      , 0.00 AS N10000, 0.00 AS N5000, 0.00 AS N1000, DTT.TRAN_AMT, 0.00 AS INCOME--, DTT.CREDIT AS INCOME
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'DBRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      --AND TRUNC(B.PSTD_DATE) BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND B.PSTD_DATE >= TO_DATE(CONCAT(CONCAT(CAST(ci_startDate AS VARCHAR(10)), ' '),ci_startTime),'dd-MM-yyyy HH24:MI:SS') 
      AND B.PSTD_DATE <= TO_DATE(CONCAT(CONCAT(CAST(ci_endDate AS VARCHAR(10)), ' '),ci_endTime),'dd-MM-yyyy HH24:MI:SS')
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' --AND G.ACCT_CLS_FLG = 'N' 
  AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBRS'
      AND NVL(FREE_TEXT3,'') LIKE ci_cardType
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  WHERE --(TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') BETWEEN ci_startTime AND ci_endTime) AND
  NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  ORDER BY NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ');

CURSOR MPUExtractDataByBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, ci_startTime VARCHAR2, ci_endTime VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , SUBSTR(NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' '),1,10) AS BINCODE, D.CHANNEL_DEVICE_ID AS TERMINAL_ID
        , DTT.TRAN_ID AS ENTRY_NO, NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ') AS CARD_NUMBER
        , DTT.PSTD_DATE AS DATEPART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , 0.00 AS N10000, 0.00 AS N5000, 0.00 AS N1000, DTT.TRAN_AMT
        , (((NVL(DTT.TRAN_AMT,0) * 0.002) * 70) / 100) AS INCOME--, DTT.CREDIT AS INCOME
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'DBRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      --AND TRUNC(B.PSTD_DATE) BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND B.PSTD_DATE >= TO_DATE(CONCAT(CONCAT(CAST(ci_startDate AS VARCHAR(10)), ' '),ci_startTime),'dd-MM-yyyy HH24:MI:SS') 
      AND B.PSTD_DATE <= TO_DATE(CONCAT(CONCAT(CAST(ci_endDate AS VARCHAR(10)), ' '),ci_endTime),'dd-MM-yyyy HH24:MI:SS')
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' --AND G.ACCT_CLS_FLG = 'N' 
  AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE SOL_ID LIKE '%' || ci_branchCode || '%'
      AND CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBRS'
      AND NVL(FREE_TEXT3,'') LIKE '%MPU%'
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  WHERE --(TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') BETWEEN ci_startTime AND ci_endTime) AND
  NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  ORDER BY NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ');

CURSOR MPUExtractDataAllBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_startTime VARCHAR2, ci_endTime VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
      , SUBSTR(NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' '),1,10) AS BINCODE, D.CHANNEL_DEVICE_ID AS TERMINAL_ID
      , DTT.TRAN_ID AS ENTRY_NO, NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ') AS CARD_NUMBER
      , DTT.PSTD_DATE AS DATEPART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
      , 0.00 AS N10000, 0.00 AS N5000, 0.00 AS N1000, DTT.TRAN_AMT
      , (((NVL(DTT.TRAN_AMT,0) * 0.002) * 70) / 100) AS INCOME--, DTT.CREDIT AS INCOME
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'DBRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      --AND TRUNC(B.PSTD_DATE) BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND B.PSTD_DATE >= TO_DATE(CONCAT(CONCAT(CAST(ci_startDate AS VARCHAR(10)), ' '),ci_startTime),'dd-MM-yyyy HH24:MI:SS') 
      AND B.PSTD_DATE <= TO_DATE(CONCAT(CONCAT(CAST(ci_endDate AS VARCHAR(10)), ' '),ci_endTime),'dd-MM-yyyy HH24:MI:SS')
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' --AND G.ACCT_CLS_FLG = 'N' 
  AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBRS'
      AND NVL(FREE_TEXT3,'') LIKE '%MPU%'
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  WHERE --(TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') BETWEEN ci_startTime AND ci_endTime) AND
  NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  ORDER BY NVL(REGEXP_SUBSTR(D.CARDTYPE,'[^|]+',1,1), ' ');

  PROCEDURE FIN_ACQ_TRANS_REVERSAL_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_InstitutionID VARCHAR2(10);
  v_BinCode VARCHAR2(20);
  v_TerminalID VARCHAR2(20);
  v_EntryNo VARCHAR2(20);
  v_CardNumber VARCHAR2(20);
  v_DatePart TBAADM.DAILY_TRAN_DETAIL_TABLE.TRAN_DATE%type;
  v_TimePart VARCHAR2(20);
  v_N10000 TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_N5000 TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_N1000 TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_TranAmt TBAADM.REF_TRN_TBL.TRAN_AMT%type;
  v_Income TBAADM.REF_TRN_TBL.TRAN_AMT%type;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
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

    vi_startDate  :=  outArr(0);
    vi_endDate    :=  outArr(1);
    vi_cardType   :=  outArr(2);
    vi_branchCode :=  outArr(6);
    vi_startTime  :=  outArr(3);
    vi_endTime    :=  outArr(4);
    vi_exRate     :=  outArr(5);

  ------------------------------------------------------------------------------------------------

  if( vi_startDate is null or vi_endDate is null or vi_cardType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0
                  || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' ||'-' || '|' || '-' || '|' || '-' || '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;

  -----------------------------------------------------------------------------------------------

    IF vi_cardType = 'MPU' THEN
      vi_cardType := '%MPU%';
    END IF;
    IF vi_cardType = 'JCB' THEN
      vi_cardType := '%JCB%';
    END IF;
    IF vi_cardType = 'VISA' THEN
      vi_cardType := '%VISA%';
    END IF;
    IF vi_cardType = 'MASTER' THEN
      vi_cardType := '%MASTER%';
    END IF;
    IF vi_cardType = 'CUP' THEN
      vi_cardType := '%CUP%';
    END IF;

    IF vi_startTime IS NULL or vi_startTime = '' THEN
      vi_startTime := '00:00:00';
    END IF;

    IF vi_endTime IS NULL or vi_endTime = '' or vi_endTime = '00:00:00' THEN
      vi_endTime := '23:59:59';
    END IF;

    IF vi_exRate IS NULL or vi_exRate = '' THEN
      vi_exRate := '1';
    END IF;

    ------------------------------------------------------------------------------
    
    IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
      vi_branchCode  := '';
    END IF;

  ------------------------------------------------------------------------------
    
      IF vi_cardType = '%MPU%' THEN
  ------------------------------------------------------------------------------
        IF NOT MPUExtractDataByBranch%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN MPUExtractDataByBranch (vi_startDate, vi_endDate, vi_branchCode, vi_startTime, vi_endTime);
          --}
          END;
        --}
        END IF;

        IF MPUExtractDataByBranch%ISOPEN THEN
        --{
          FETCH	MPUExtractDataByBranch
          INTO v_InstitutionID, v_BinCode, v_TerminalID, v_EntryNo, v_CardNumber
          , v_DatePart, v_TimePart, v_N10000, v_N5000, v_N1000, v_TranAmt, v_Income;
  ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
          IF MPUExtractDataByBranch%NOTFOUND THEN
          --{
            CLOSE MPUExtractDataByBranch;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
        ------------------------------------------------------------------------
        ELSE
        ------------------------------------------------------------------------
        IF NOT ExtractDataByBranch%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataByBranch (vi_startDate, vi_endDate, vi_cardType, vi_branchCode, vi_startTime, vi_endTime);
          --}
          END;
        --}
        END IF;

        IF ExtractDataByBranch%ISOPEN THEN
        --{
          FETCH	ExtractDataByBranch
          INTO v_InstitutionID, v_BinCode, v_TerminalID, v_EntryNo, v_CardNumber
          , v_DatePart, v_TimePart, v_N10000, v_N5000, v_N1000, v_TranAmt, v_Income;
  ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
          IF ExtractDataByBranch%NOTFOUND THEN
          --{
            CLOSE ExtractDataByBranch;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;

    END IF;

   BEGIN
-------------------------------------------------------------------------------
  -- GET BANK INFORMATION
-------------------------------------------------------------------------------
  IF vi_branchCode IS NOT NULL THEN
    SELECT
       BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
       BRANCH_CODE_TABLE.BR_ADDR_1 AS "Bank_Address",
       BRANCH_CODE_TABLE.PHONE_NUM AS "Bank_Phone",
       BRANCH_CODE_TABLE.FAX_NUM AS "Bank_Fax"
       INTO
       v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
    FROM
       TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
       TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE
       SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
       AND SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
       AND SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
       AND SERVICE_OUTLET_TABLE.BANK_ID = '01';
  END IF;
  END;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(
                v_InstitutionID	    || '|' ||
                v_BinCode	          || '|' ||
                v_TerminalID 	      || '|' ||
                v_EntryNo           || '|' ||
                v_CardNumber        || '|' ||
                to_char(to_date(v_DatePart,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_TimePart   	|| '|' ||
                v_N10000 	    || '|' ||
                v_N5000 	    || '|' ||
                v_N1000 	    || '|' ||
                v_TranAmt     || '|' ||
                v_Income      || '|' ||
                v_BranchName  || '|' ||
                v_BankAddress || '|' ||
                v_BankPhone   || '|' ||
                v_BankFax);

			dbms_output.put_line(out_rec);

  END FIN_ACQ_TRANS_REVERSAL_LISTING;

END FIN_ACQ_TRANS_REVERSAL_LISTING;
/
