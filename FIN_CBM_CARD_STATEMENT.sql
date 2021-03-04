CREATE OR REPLACE PACKAGE FIN_CBM_CARD_STATEMENT AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE                   FIN_CBM_CARD_STATEMENT( inp_str      IN  VARCHAR2,
                                                    out_retCode  OUT NUMBER,
                                                    out_rec      OUT VARCHAR2 );

END FIN_CBM_CARD_STATEMENT;
/


CREATE OR REPLACE PACKAGE BODY        FIN_CBM_CARD_STATEMENT AS
/******************************************************************************
 NAME:       FIN_CBM_CARD_STATEMENT
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
  vi_exRate         VARCHAR2(10);               -- Input to procedure

--------------------------------------------------------------------------------
-- CURSOR declaration FIN_CBM_CARD_STATEMENT CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_cardType VARCHAR2, ci_exRate VARCHAR2)
IS
  SELECT  ' ' AS WithdrawalDate, 'BF' AS SettlementDate, 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
          , 0 AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD, 0 AS WithdrawalAmtUSD
          , 0 AS CommissionUSD
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
      AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'DBTR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND TRUNC(B.PSTD_DATE) < TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
      CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBTS'
      AND NVL(FREE_TEXT3,'') LIKE ci_cardType
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  UNION ALL
  SELECT  T.WithdrawalDate, T.SettlementDate, T.Channel, T.TransCountMMK, T.WithdrawalAmtMMK
          , T.CommissionMMK, T.TransCountUSD, T.WithdrawalAmtUSD, T.CommissionUSD 
  FROM
  (
    SELECT  TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS WithdrawalDate, TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS SettlementDate
            , 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
            , 0 AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD, 0 AS WithdrawalAmtUSD, 0 AS CommissionUSD
    FROM
    (
        SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
        --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
        AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'DBTR'
        AND B.PART_TRAN_TYPE = 'C'
        AND B.PSTD_FLG  = 'Y'
        AND TRUNC(B.PSTD_DATE) >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
        AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
    )DTT
    INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
    AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
    INNER JOIN
    (
        SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
        , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
        , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
        , NVL(FREE_TEXT1,'') AS TRAN_ID
        , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
        , NVL(FREE_TEXT3,'') AS CARDTYPE
        FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
        CHANNEL_ID = 'EFT'
        AND DEL_CHANNEL_MESG_ID = 'DBTS'
        AND NVL(FREE_TEXT3,'') LIKE ci_cardType
    ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
    WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
    GROUP BY to_char(to_date(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy')
  ) T ORDER BY WithdrawalDate;
  
CURSOR CUPExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_exRate VARCHAR2)
IS
  SELECT  ' ' AS WithdrawalDate, 'BF' AS SettlementDate, 'ATM' AS Channel
          , COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK, ROUND(SUM(USD_INCOME),2) * TO_NUMBER(ci_exRate) AS CommissionMMK
          , COUNT(DTT.TRAN_ID) AS TransCountUSD, SUM(USD_AMT) AS WithdrawalAmtUSD, SUM(USD_INCOME) AS CommissionUSD
  FROM
  (
      SELECT  B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
              , (NVL(B.TRAN_AMT,0) * ROUND(( 1 / TO_NUMBER(ci_exRate)),7)) AS USD_AMT
              , (5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7) + 1.25) * 0.4 AS USD_INCOME
              --, (((5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7)) + 1.25) * 0.4) * ROUND(TO_NUMBER(ci_exRate)) AS MMK_INCOME
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
      AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'DBTR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND TRUNC(B.PSTD_DATE) < TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
      CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBTS'
      AND NVL(FREE_TEXT3,'') LIKE '%CUP%'
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  UNION ALL
  SELECT  T.WithdrawalDate, T.SettlementDate, T.Channel, T.TransCountMMK, T.WithdrawalAmtMMK
          , T.CommissionMMK, T.TransCountUSD, T.WithdrawalAmtUSD, T.CommissionUSD 
  FROM
  (
    SELECT  TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS WithdrawalDate, TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS SettlementDate
            , 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK, ROUND(SUM(USD_INCOME),2) * TO_NUMBER(ci_exRate) AS CommissionMMK
            , COUNT(DTT.TRAN_ID) AS TransCountUSD, SUM(USD_AMT) AS WithdrawalAmtUSD, SUM(USD_INCOME) AS CommissionUSD
    FROM
    (
        SELECT  B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
                , (NVL(B.TRAN_AMT,0) * ROUND(( 1 / TO_NUMBER(ci_exRate)),7)) AS USD_AMT
                , (5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7) + 1.25) * 0.4 AS USD_INCOME
                --, (((5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7)) + 1.25) * 0.4) * ROUND(TO_NUMBER(ci_exRate)) AS MMK_INCOME
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
        --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
        AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'DBTR'
        AND B.PART_TRAN_TYPE = 'C'
        AND B.PSTD_FLG  = 'Y'
        AND TRUNC(B.PSTD_DATE) >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
        AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
    )DTT
    INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
    AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
    INNER JOIN
    (
        SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
        , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
        , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
        , NVL(FREE_TEXT1,'') AS TRAN_ID
        , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
        , NVL(FREE_TEXT3,'') AS CARDTYPE
        FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
        CHANNEL_ID = 'EFT'
        AND DEL_CHANNEL_MESG_ID = 'DBTS'
        AND NVL(FREE_TEXT3,'') LIKE '%CUP%'
    ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
    WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
    GROUP BY to_char(to_date(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy')
  ) T ORDER BY WithdrawalDate;
  
CURSOR JCBExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_exRate VARCHAR2)
IS
  SELECT  ' ' AS WithdrawalDate, 'BF' AS SettlementDate, 'ATM' AS Channel
          , COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
          , SUM(MMK_INCOME) AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD
          , SUM(USD_AMT) AS WithdrawalAmtUSD, SUM(USD_INCOME) AS CommissionUSD
  FROM
  (
      SELECT  B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
              , ((5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7)) + 1.25) * 0.4 AS USD_AMT
              , 2.5 AS USD_INCOME
              , (2.5 * TO_NUMBER(ci_exRate)) AS MMK_INCOME
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
      AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD = 'DBTR'
      AND B.PART_TRAN_TYPE = 'C'
      AND B.PSTD_FLG  = 'Y'
      AND TRUNC(B.PSTD_DATE) < TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
      CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID = 'DBTS'
      AND NVL(FREE_TEXT3,'') LIKE '%JCB%'
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  UNION ALL
  SELECT  T.WithdrawalDate, T.SettlementDate, T.Channel, T.TransCountMMK, T.WithdrawalAmtMMK
          , T.CommissionMMK, T.TransCountUSD, T.WithdrawalAmtUSD, T.CommissionUSD 
  FROM
  (
    SELECT  TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS WithdrawalDate, TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS SettlementDate
            , 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
            , SUM(MMK_INCOME) AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD
            , SUM(USD_AMT) AS WithdrawalAmtUSD, SUM(USD_INCOME) AS CommissionUSD
    FROM
    (
        SELECT  B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
                , ((5000 * ROUND(( 1 / TO_NUMBER(ci_exRate)), 7)) + 1.25) * 0.4 AS USD_AMT
                , 2.5 AS USD_INCOME
                , (2.5 * TO_NUMBER(ci_exRate)) AS MMK_INCOME
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
        --AND B.GL_SUB_HEAD_CODE IN ('70101','70111','70121','60100','10310')
        AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'DBTR'
        AND B.PART_TRAN_TYPE = 'C'
        AND B.PSTD_FLG  = 'Y'
        AND TRUNC(B.PSTD_DATE) >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
        AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
    )DTT
    INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
    AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
    INNER JOIN
    (
        SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
        , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
        , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
        , NVL(FREE_TEXT1,'') AS TRAN_ID
        , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
        , NVL(FREE_TEXT3,'') AS CARDTYPE
        FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
        CHANNEL_ID = 'EFT'
        AND DEL_CHANNEL_MESG_ID = 'DBTS'
        AND NVL(FREE_TEXT3,'') LIKE '%JCB%'
    ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
    WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
    GROUP BY to_char(to_date(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy')
  ) T ORDER BY WithdrawalDate;
  
CURSOR MPUExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_exRate VARCHAR2)
IS
  SELECT  ' ' AS WithdrawalDate, 'BF' AS SettlementDate, 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
          , SUM(DTT.MMK_INCOME) AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD, 0 AS WithdrawalAmtUSD
          , 0 AS CommissionUSD
  FROM
  (
    SELECT V.* FROM -- ****(NOT IN CLAUSE REMOVE FOR PERFORMANCE)****
    (
      SELECT  T2.TRAN_ID AS TMP_ID, T1.TRAN_ID, T1.TRAN_DATE, T1.PSTD_DATE
              , T1.ACID, T1.DTH_INIT_SOL_ID, T1.SOL_ID, T1.TRAN_AMT, T1.MESG
              , (NVL(T1.TRAN_AMT,0) * 0.002) * 0.7 AS MMK_INCOME FROM
      (SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
      AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'
      AND T.CMD IN ('DBTR','CWDR')
      AND B.PART_TRAN_TYPE = 'D'
      AND B.GL_SUB_HEAD_CODE NOT IN ('10102')
      AND B.PSTD_FLG  = 'Y'
      AND TRUNC(B.PSTD_DATE) < TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy'))T1
      LEFT JOIN
      (SELECT REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) AS TRAN_ID
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
      AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      AND T.DCC_ID = 'EFT'      
      AND T.CMD IN ('DBRR','CWRR')
      AND B.PART_TRAN_TYPE = 'C'
      AND B.GL_SUB_HEAD_CODE NOT IN ('10102')
      AND B.PSTD_FLG  = 'Y'
      AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) IS NOT NULL)T2 ON T2.TRAN_ID = T1.TRAN_ID
    )V WHERE V.TMP_ID IS NULL
  )DTT
  INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
  AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
  INNER JOIN
  (
      SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
      , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
      , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
      , NVL(FREE_TEXT1,'') AS TRAN_ID
      , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
      , NVL(FREE_TEXT3,'') AS CARDTYPE
      FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
      CHANNEL_ID = 'EFT'
      AND DEL_CHANNEL_MESG_ID IN ('DBTS','CWDS')
      AND NVL(FREE_TEXT3,'') LIKE '%MPU%'
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
  UNION ALL
  SELECT  T.WithdrawalDate, T.SettlementDate, T.Channel, T.TransCountMMK, T.WithdrawalAmtMMK
          , T.CommissionMMK, T.TransCountUSD, T.WithdrawalAmtUSD, T.CommissionUSD 
  FROM
  (
    SELECT  TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS WithdrawalDate, TO_CHAR(TO_DATE(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy') AS SettlementDate
            , 'ATM' AS Channel, COUNT(DTT.TRAN_ID) AS TransCountMMK, SUM(DTT.TRAN_AMT) AS WithdrawalAmtMMK
            , SUM(DTT.MMK_INCOME) AS CommissionMMK, COUNT(DTT.TRAN_ID) AS TransCountUSD, 0 AS WithdrawalAmtUSD, 0 AS CommissionUSD
    FROM
    (
        SELECT V.* FROM -- ****(NOT IN CLAUSE REMOVE FOR PERFORMANCE)****
        (
          SELECT  T2.TRAN_ID AS TMP_ID, T1.TRAN_ID, T1.TRAN_DATE, T1.PSTD_DATE
                  , T1.ACID, T1.DTH_INIT_SOL_ID, T1.SOL_ID, T1.TRAN_AMT, T1.MESG
                  , (NVL(T1.TRAN_AMT,0) * 0.002) * 0.7 AS MMK_INCOME FROM
          (SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG
          FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
          INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
          AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
          AND T.DCC_ID = 'EFT'
          AND T.CMD IN ('DBTR','CWDR')
          AND B.PART_TRAN_TYPE = 'D'
          AND B.GL_SUB_HEAD_CODE NOT IN ('10102')
          AND B.PSTD_FLG  = 'Y'
          AND TRUNC(B.PSTD_DATE) >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
          AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy'))T1
          LEFT JOIN
          (SELECT REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) AS TRAN_ID
          FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
          INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID
          AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
          AND T.DCC_ID = 'EFT'      
          AND T.CMD IN ('DBRR','CWRR')
          AND B.PART_TRAN_TYPE = 'C'
          AND B.GL_SUB_HEAD_CODE NOT IN ('10102')
          AND B.PSTD_FLG  = 'Y'
          AND TRUNC(B.PSTD_DATE) >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
          AND TRUNC(B.PSTD_DATE) <= TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
          AND REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) IS NOT NULL)T2 ON T2.TRAN_ID = T1.TRAN_ID
        )V WHERE V.TMP_ID IS NULL
    )DTT
    INNER JOIN TBAADM.GAM G ON DTT.ACID = G.ACID AND DTT.SOL_ID = G.SOL_ID
    AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
    INNER JOIN
    (
        SELECT SL_NO, CHANNEL_ID, CHANNEL_DEVICE_ID
        , DEL_CHANNEL_MESG_ID, TRAN_DATE, SOL_ID, FORACID, TRAN_TYPE
        , TRAN_AMT, CRNCY_CODE, TRAN_STATUS, BANK_ID
        , NVL(FREE_TEXT1,'') AS TRAN_ID
        , NVL(FREE_TEXT2,'') AS INSTITUTION_ID
        , NVL(FREE_TEXT3,'') AS CARDTYPE
        FROM TBAADM.DCTI WHERE --SOL_ID LIKE '%' || ci_branchCode || '%' AND 
        CHANNEL_ID = 'EFT'
        AND DEL_CHANNEL_MESG_ID IN ('DBTS','CWDS')
        AND NVL(FREE_TEXT3,'') LIKE '%MPU%'
    ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
    WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(DTT.MESG,INSTR(DTT.MESG,'BC', 1, 1)-10,8), '2')) IN ('10300004','00240001')
    GROUP BY to_char(to_date(DTT.PSTD_DATE,'dd/Mon/yy'), 'dd-MM-yyyy')
  ) T ORDER BY WithdrawalDate;

  PROCEDURE                   FIN_CBM_CARD_STATEMENT( inp_str      IN  VARCHAR2,
                                                      out_retCode  OUT NUMBER,
                                                      out_rec      OUT VARCHAR2 ) AS
  v_WithdrawalDate VARCHAR2(10);
  v_SettlementDate VARCHAR2(10);
  v_Channel VARCHAR2(10);
  v_TransCountMMK TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_WithdrawalAmtMMK TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_CommissionMMK TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_TransCountUSD TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_WithdrawalAmtUSD TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_CommissionUSD TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  
  BEGIN
  
    -- TODO: Implementation required for PROCEDURE FIN_CBM_CARD_STATEMENT.FIN_CBM_CARD_STATEMENT
    ----------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
    ----------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;

    tbaadm.basp0099.formInputArr(inp_str, outArr);
  ------------------------------------------------------------------------------
		-- Parsing the i/ps from the string
	------------------------------------------------------------------------------

    vi_startDate  :=  outArr(0);
    vi_endDate    :=  outArr(1);
    vi_cardType   :=  outArr(2);
    vi_exRate     :=  outArr(3);

  ------------------------------------------------------------------------------

  if( vi_startDate is null or vi_endDate is null or vi_cardType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;

  ------------------------------------------------------------------------------
  
  IF vi_exRate IS NULL or vi_exRate = '' THEN
      vi_exRate := '1';
  END IF;
  
  ------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
 IF vi_cardType = '%CUP%' THEN
--------------------------------------------------------------------------------
  IF NOT CUPExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN CUPExtractData (vi_startDate, vi_endDate, vi_exRate);
      --}
      END;
    --}
    END IF;
  
    IF CUPExtractData%ISOPEN THEN
    --{
      FETCH	CUPExtractData
      INTO  v_WithdrawalDate, v_SettlementDate, v_Channel, v_TransCountMMK,
            v_WithdrawalAmtMMK, v_CommissionMMK, v_TransCountUSD, v_WithdrawalAmtUSD, v_CommissionUSD;
  ------------------------------------------------------------------------------
      -- Here it is checked whether the cursor has fetched
      -- something or not if not the cursor is closed
      -- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
      IF CUPExtractData%NOTFOUND THEN
      --{
        CLOSE CUPExtractData;
        out_retCode:= 1;
        RETURN;
      --}
      END IF;
    --}
    END IF;
 --------------------------------------------------------------------------------   
 ELSIF vi_cardType = '%JCB%' THEN
 --------------------------------------------------------------------------------
  IF NOT JCBExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN JCBExtractData (vi_startDate, vi_endDate, vi_exRate);
      --}
      END;
    --}
    END IF;
  
    IF JCBExtractData%ISOPEN THEN
    --{
      FETCH	JCBExtractData
      INTO  v_WithdrawalDate, v_SettlementDate, v_Channel, v_TransCountMMK,
            v_WithdrawalAmtMMK, v_CommissionMMK, v_TransCountUSD, v_WithdrawalAmtUSD, v_CommissionUSD;
  ------------------------------------------------------------------------------
      -- Here it is checked whether the cursor has fetched
      -- something or not if not the cursor is closed
      -- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
      IF JCBExtractData%NOTFOUND THEN
      --{
        CLOSE JCBExtractData;
        out_retCode:= 1;
        RETURN;
      --}
      END IF;
    --}
    END IF;
    
    --------------------------------------------------------------------------------   
 ELSIF vi_cardType = '%MPU%' THEN
 --------------------------------------------------------------------------------
  IF NOT MPUExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN MPUExtractData (vi_startDate, vi_endDate, vi_exRate);
      --}
      END;
    --}
    END IF;
  
    IF MPUExtractData%ISOPEN THEN
    --{
      FETCH	MPUExtractData
      INTO  v_WithdrawalDate, v_SettlementDate, v_Channel, v_TransCountMMK,
            v_WithdrawalAmtMMK, v_CommissionMMK, v_TransCountUSD, v_WithdrawalAmtUSD, v_CommissionUSD;
  ------------------------------------------------------------------------------
      -- Here it is checked whether the cursor has fetched
      -- something or not if not the cursor is closed
      -- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
      IF MPUExtractData%NOTFOUND THEN
      --{
        CLOSE MPUExtractData;
        out_retCode:= 1;
        RETURN;
      --}
      END IF;
    --}
    END IF;
--------------------------------------------------------------------------------
 ELSE 
--------------------------------------------------------------------------------
  IF NOT ExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN ExtractData (vi_startDate, vi_endDate, vi_cardType, vi_exRate);
      --}
      END;
    --}
    END IF;
  
    IF ExtractData%ISOPEN THEN
    --{
      FETCH	ExtractData
      INTO  v_WithdrawalDate, v_SettlementDate, v_Channel, v_TransCountMMK,
            v_WithdrawalAmtMMK, v_CommissionMMK, v_TransCountUSD, v_WithdrawalAmtUSD, v_CommissionUSD;
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
   --}
  END IF;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(
                v_WithdrawalDate	    || '|' ||
                v_SettlementDate	    || '|' ||
                v_Channel 	          || '|' ||
                v_TransCountMMK       || '|' ||
                v_WithdrawalAmtMMK    || '|' ||
                v_CommissionMMK   	  || '|' ||
                v_TransCountUSD 	    || '|' ||
                v_WithdrawalAmtUSD 	  || '|' ||
                v_CommissionUSD
              );

			dbms_output.put_line(out_rec);
      
  END FIN_CBM_CARD_STATEMENT;

END FIN_CBM_CARD_STATEMENT;
/
