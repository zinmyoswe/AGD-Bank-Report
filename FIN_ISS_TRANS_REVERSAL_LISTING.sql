CREATE OR REPLACE PACKAGE FIN_ISS_TRANS_REVERSAL_LISTING AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_ISS_TRANS_REVERSAL_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 );

END FIN_ISS_TRANS_REVERSAL_LISTING;

/


CREATE OR REPLACE PACKAGE BODY                             FIN_ISS_TRANS_REVERSAL_LISTING AS
/******************************************************************************
 NAME:       FIN_ISS_TRANS_REVERSAL_LISTING
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
  vi_branchCode     VARCHAR2(5);                -- Input to procedure
  vi_tranType       VARCHAR2(50);               -- Input to procedure
  
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_ISS_TRANS_REVERSAL_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractDataByBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER --NVL(M.CARD_NUMBER, ' ') AS CARD_NUMBER
        , G.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME
        , C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , DTT.DEBIT, DTT.CREDIT, 0.00 AS ICREDIT, 'ISS' AS TRAN_TYPE
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, (NVL(A_A,0)+ NVL(F_A,0)) AS CREDIT--NVL(F_A,0) AS CREDIT
      ,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      --, NVL(E_B,0) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70301','10102') THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301','10102','60100')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
      IN ('70301' AS A, '10102' AS F, '70101' AS B, '70111' AS C, '70121' AS D, '60100' AS E))
  )DTT
  INNER JOIN
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      AND B.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  )C ON DTT.TRAN_ID = C.TRAN_ID AND DTT.TRAN_DATE = C.TRAN_DATE AND DTT.SOL_ID = C.SOL_ID
  INNER JOIN TBAADM.GAM G ON C.ACID = G.ACID AND C.SOL_ID = G.SOL_ID
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
      AND DEL_CHANNEL_MESG_ID = 'CWRS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  --INNER JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID AND M.CARD_TYPE = ci_cardType
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) NOT IN ('10300004','00240001','00000010','00000020')
  ORDER BY D.INSTITUTION_ID;

CURSOR ExtractDataAll (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER
        , G.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME
        , C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , DTT.DEBIT, DTT.CREDIT, 0.00 AS ICREDIT, 'ISS' AS TRAN_TYPE
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, (NVL(A_A,0)+ NVL(F_A,0)) AS CREDIT--NVL(F_A,0) AS CREDIT
      ,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      --, NVL(E_B,0) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70301','10102') THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301','10102','60100')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
      IN ('70301' AS A, '10102' AS F, '70101' AS B, '70111' AS C, '70121' AS D, '60100' AS E))
  )DTT
  INNER JOIN
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      AND B.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  )C ON DTT.TRAN_ID = C.TRAN_ID AND DTT.TRAN_DATE = C.TRAN_DATE AND DTT.SOL_ID = C.SOL_ID
  INNER JOIN TBAADM.GAM G ON C.ACID = G.ACID AND C.SOL_ID = G.SOL_ID
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
      AND DEL_CHANNEL_MESG_ID = 'CWRS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE 
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) NOT IN ('10300004','00240001','00000010','00000020')
  ORDER BY D.INSTITUTION_ID;

CURSOR OSExtractDataByBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER --NVL(M.CARD_NUMBER, ' ') AS CARD_NUMBER
        , G.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME
        , C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , DTT.DEBIT, DTT.CREDIT, NVL(X.SYSTEM_CALC_AMT,0) AS ICREDIT, 'ISS' AS TRAN_TYPE
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, (NVL(A_A,0)+ NVL(F_A,0)) AS CREDIT--NVL(F_A,0) AS CREDIT
      ,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      --, NVL(E_B,0) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70301','10102') THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301','10102','60100')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
      IN ('70301' AS A, '10102' AS F, '70101' AS B, '70111' AS C, '70121' AS D, '60100' AS E))
  )DTT
  INNER JOIN
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      AND B.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  )C ON DTT.TRAN_ID = C.TRAN_ID AND DTT.TRAN_DATE = C.TRAN_DATE AND DTT.SOL_ID = C.SOL_ID
  INNER JOIN TBAADM.GAM G ON C.ACID = G.ACID AND C.SOL_ID = G.SOL_ID
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
      AND DEL_CHANNEL_MESG_ID = 'CWRS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  LEFT JOIN TBAADM.CXL X ON DTT.TRAN_ID = X.PARENT_TRAN_ID AND DTT.SOL_ID = X.SERVICE_SOL_ID
  AND X.COMP_B2KID_TYPE = 'CDCI' AND REGEXP_SUBSTR(X.COMP_B2KID,'[^/]+',1,5)= 'EFT'
  --INNER JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID AND M.CARD_TYPE = ci_cardType
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) IN ('00000010','00000020')
  ORDER BY D.INSTITUTION_ID;

CURSOR OSExtractDataAll (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
IS
  SELECT NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) AS INSTITUTION_ID
        , DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER
        , G.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME
        , C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
        , DTT.DEBIT, DTT.CREDIT, NVL(X.SYSTEM_CALC_AMT,0) AS ICREDIT, 'ISS' AS TRAN_TYPE
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, (NVL(A_A,0)+ NVL(F_A,0)) AS CREDIT--NVL(F_A,0) AS CREDIT
      ,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      --, NVL(E_B,0) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70301','10102') THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301','10102','60100')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
      IN ('70301' AS A, '10102' AS F, '70101' AS B, '70111' AS C, '70121' AS D, '60100' AS E))
  )DTT
  INNER JOIN
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100')
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'CWRR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      AND B.VALUE_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  )C ON DTT.TRAN_ID = C.TRAN_ID AND DTT.TRAN_DATE = C.TRAN_DATE AND DTT.SOL_ID = C.SOL_ID
  INNER JOIN TBAADM.GAM G ON C.ACID = G.ACID AND C.SOL_ID = G.SOL_ID
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
      AND DEL_CHANNEL_MESG_ID = 'CWRS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  LEFT JOIN TBAADM.CXL X ON DTT.TRAN_ID = X.PARENT_TRAN_ID AND DTT.SOL_ID = X.SERVICE_SOL_ID
  AND X.COMP_B2KID_TYPE = 'CDCI' AND REGEXP_SUBSTR(X.COMP_B2KID,'[^/]+',1,5)= 'EFT'
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) IN ('00000010','00000020')
  ORDER BY D.INSTITUTION_ID;

  PROCEDURE FIN_ISS_TRANS_REVERSAL_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_InstitutionID VARCHAR2(10);
  v_EntryNo VARCHAR2(20);
  v_CardNumber VARCHAR2(20);
  v_AccNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_AccName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_DatePart TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE%type;
  v_TimePart VARCHAR2(20);
  v_Debit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Credit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_ICredit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_TranType VARCHAR2(10);
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  BEGIN
    -- TODO: Implementation required for PROCEDURE FIN_ISS_TRANS_REVERSAL_LISTING.FIN_ISS_TRANS_REVERSAL_LISTING
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
    vi_branchCode :=  outArr(2);
    vi_tranType   :=  outArr(3);

 -------------------------------------------------------------------------------
 
 if( vi_startDate is null or vi_endDate is null or vi_tranType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
		          '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
              '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );

        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;
  
  ------------------------------------------------------------------------------
  
  IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
      vi_branchCode  := '';
  END IF;
  
  --IF vi_cardType IS NULL OR vi_cardType = '' THEN
      --vi_cardType  := ' ';
  --END IF;

  ------------------------------------------------------------------------------
    
    IF vi_tranType = 'Local Transaction' THEN
      IF NOT ExtractDataByBranch%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN ExtractDataByBranch (vi_startDate, vi_endDate, vi_branchCode);
        --}
        END;
      --}
      END IF;

      IF ExtractDataByBranch%ISOPEN THEN
      --{
        FETCH	ExtractDataByBranch
        INTO v_InstitutionID, v_EntryNo, v_CardNumber, v_AccNo, v_AccName
        , v_DatePart, v_TimePart, v_Debit, v_Credit, v_ICredit, v_TranType;
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
      ------------------------------------------------------------------------
      ELSE
      ------------------------------------------------------------------------
      IF NOT OSExtractDataByBranch%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN OSExtractDataByBranch (vi_startDate, vi_endDate, vi_branchCode);
        --}
        END;
      --}
      END IF;

      IF OSExtractDataByBranch%ISOPEN THEN
      --{
        FETCH	OSExtractDataByBranch
        INTO v_InstitutionID, v_EntryNo, v_CardNumber, v_AccNo, v_AccName
      , v_DatePart, v_TimePart, v_Debit, v_Credit, v_ICredit, v_TranType;
    ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
    ------------------------------------------------------------------------------
        IF OSExtractDataByBranch%NOTFOUND THEN
        --{
          CLOSE OSExtractDataByBranch;
          out_retCode:= 1;
          RETURN;
        --}
        END IF;
      --}
      END IF;
      ------------------------------------------------------------------------
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
                v_InstitutionID || '|' ||
                v_EntryNo       || '|' ||
                v_CardNumber    || '|' ||
                v_AccNo	        || '|' ||
                v_AccName 	    || '|' ||
                to_char(to_date(v_DatePart,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_TimePart      || '|' ||
                v_Debit 	      || '|' ||
                v_Credit 	      || '|' ||
                v_ICredit       || '|' ||
                v_TranType 	    || '|' ||
                v_BranchName    || '|' ||
                v_BankAddress   || '|' ||
                v_BankPhone     || '|' ||
                v_BankFax
              );

			dbms_output.put_line(out_rec);
  END FIN_ISS_TRANS_REVERSAL_LISTING;

END FIN_ISS_TRANS_REVERSAL_LISTING;
/
