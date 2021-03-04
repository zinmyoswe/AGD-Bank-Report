CREATE OR REPLACE PACKAGE               FIN_POS_ISSUING_LISTING AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_POS_ISSUING_LISTING(	inp_str      IN  VARCHAR2,
                                      out_retCode  OUT NUMBER,
                                      out_rec      OUT VARCHAR2 );

END FIN_POS_ISSUING_LISTING;


/


CREATE OR REPLACE PACKAGE BODY                                                                                                                               FIN_POS_ISSUING_LISTING AS
/******************************************************************************
 NAME:       FIN_POS_ISSUING_LISTING
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
  vi_tranDate       VARCHAR2(10);               -- Input to procedure
  vi_branchCode     VARCHAR2(5);                -- Input to procedure  
  vi_channelType    VARCHAR2(50);               -- Input to procedure
  vi_tranType       VARCHAR2(50);               -- Input to procedure

--------------------------------------------------------------------------------
-- CURSOR declaration FIN_POS_ISSUING_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_tranDate VARCHAR2, ci_branchCode VARCHAR2, ci_channelType VARCHAR2)
IS
  SELECT D.CHANNEL_DEVICE_ID AS TERMINAL_ID, DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER
     , D.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME, C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
     , REGEXP_SUBSTR(C.TRAN_PARTICULAR,'[^/]+',1,1) AS TRAN_TYPE
     , DTT.DEBIT
     , CASE WHEN NVL(DTT.CREDIT,0) > 0 THEN DTT.CREDIT - ((((DTT.CREDIT * 1) / 100) * 10) / 100) ELSE 0 END AS CREDIT
     , CASE WHEN NVL(DTT.CREDIT,0) > 0 THEN ((((DTT.CREDIT * 1) / 100) * 10) / 100) ELSE 0 END AS ICREDIT
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, NVL(A_A,0) AS CREDIT,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE DTT.GL_SUB_HEAD_CODE WHEN '70301' THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE --DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      --AND 
      T.DCC_ID = 'EFT'
      AND T.CMD = 'PRCR' --LIKE 'P%'
      AND REGEXP_SUBSTR(DTT.TRAN_PARTICULAR,'[^/]+',1,1) = ci_channelType--(REGEXP_SUBSTR(DTT.TRAN_PARTICULAR,'[^/]+',1,1) = 'PVR' OR DTT.TRAN_PARTICULAR LIKE ci_channelType)
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
        IN ('70301' AS A, '70101' AS B, '70111' AS C, '70121' AS D))
  )DTT
  INNER JOIN
  (
      SELECT V.* FROM -- ****(NOT IN CLAUSE REMOVE FOR PERFORMANCE)****
      (
        SELECT T2.TRAN_ID AS TMP_ID, T1.* FROM
        (SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, B.TRAN_PARTICULAR, T.MESG
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
        WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
        --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'PRCR' --LIKE 'P%'
        AND B.PART_TRAN_TYPE = 'D'
        AND B.PSTD_FLG  = 'Y'
        AND REGEXP_SUBSTR(B.TRAN_PARTICULAR,'[^/]+',1,1) = ci_channelType--B.TRAN_PARTICULAR LIKE ci_channelType
        AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
        AND B.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
        )T1 LEFT JOIN
        (SELECT REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) AS TRAN_ID
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
        WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
        --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'PRRR'
        AND B.PART_TRAN_TYPE = 'C'
        AND B.PSTD_FLG  = 'Y'
        AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
        AND B.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
        AND REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) IS NOT NULL)T2 ON T2.TRAN_ID = T1.TRAN_ID
      )V WHERE V.TMP_ID IS NULL
      --UNION ALL
      --SELECT '' AS TMP_ID, G.TRAN_ID, G.TRAN_DATE, G.PSTD_DATE, G.VALUE_DATE, G.ACID, G.SOL_ID, G.TRAN_PARTICULAR, S.MESG
      --FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW G
      --INNER JOIN TBAADM.RTT S ON G.TRAN_ID = S.TRAN_ID AND G.SOL_ID = S.SOL_ID
      --AND G.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
      --AND TO_DATE(CAST(G.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(S.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      --AND S.DCC_ID = 'EFT'
      --AND S.CMD = 'PRCR'
      --AND G.PART_TRAN_TYPE = 'D'
      --AND G.PSTD_FLG  = 'Y'
      --AND REGEXP_SUBSTR(G.TRAN_PARTICULAR,'[^/]+',1,1) = 'PVR'
      --AND G.SOL_ID LIKE '%' || ci_branchCode || '%'
      --AND G.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
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
  FROM TBAADM.DCTI
  WHERE SOL_ID LIKE '%' || ci_branchCode || '%'
  AND CHANNEL_ID = 'EFT'
  AND DEL_CHANNEL_MESG_ID = 'PRCS' --LIKE 'P%'
  AND TRAN_REMARKS = 'POS'
  --AND TRAN_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) NOT IN ('00000010','00000020')
  ORDER BY D.CHANNEL_DEVICE_ID;

CURSOR OExtractData (ci_tranDate VARCHAR2, ci_branchCode VARCHAR2, ci_channelType VARCHAR2)
IS
  SELECT D.CHANNEL_DEVICE_ID AS TERMINAL_ID, DTT.TRAN_ID AS ENTRY_NO, ' ' AS CARD_NUMBER
     , D.FORACID AS ACC_NO, G.ACCT_NAME AS ACC_NAME, C.VALUE_DATE AS DATEPART, TO_CHAR(C.PSTD_DATE, 'HH24:MI:SS') AS TIMEPART
     , REGEXP_SUBSTR(C.TRAN_PARTICULAR,'[^/]+',1,1) AS TRAN_TYPE
     , DTT.DEBIT
     , CASE WHEN NVL(DTT.CREDIT,0) > 0 THEN DTT.CREDIT - ((((DTT.CREDIT * 1) / 100) * 10) / 100) ELSE 0 END AS CREDIT
     , CASE WHEN NVL(DTT.CREDIT,0) > 0 THEN ((((DTT.CREDIT * 1) / 100) * 10) / 100) ELSE 0 END AS ICREDIT
  FROM
  (
      SELECT TRAN_ID, SOL_ID, TRAN_DATE, NVL(A_A,0) AS CREDIT,(NVL(B_B,0)+ NVL(C_B,0)+ NVL(D_B,0)) AS DEBIT
      FROM
      (SELECT DTT.TRAN_ID, DTT.TRAN_DATE, DTT.DTH_INIT_SOL_ID AS SOL_ID
         --, CASE D.TRAN_TYPE WHEN 'D' THEN T.TRAN_AMT ELSE 0 END AS DEBIT
         --, CASE D.TRAN_TYPE WHEN 'C' THEN T.TRAN_AMT ELSE 0 END AS CREDIT
         , CASE WHEN DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121') THEN DTT.TRAN_AMT ELSE 0 END AS DEBIT
         , CASE DTT.GL_SUB_HEAD_CODE WHEN '70301' THEN DTT.TRAN_AMT ELSE 0 END AS CREDIT
         , DTT.GL_SUB_HEAD_CODE
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW DTT
      INNER JOIN TBAADM.RTT T ON DTT.TRAN_ID = T.TRAN_ID AND DTT.DTH_INIT_SOL_ID = T.SOL_ID AND DTT.TRAN_DATE = T.TRAN_DATE
      WHERE --DTT.GL_SUB_HEAD_CODE IN ('70101','70111','70121','70301')
      --AND TO_DATE(CAST(DTT.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      --AND 
      T.DCC_ID = 'EFT'
      AND T.CMD = 'PRCR' --LIKE 'P%'
      AND REGEXP_SUBSTR(DTT.TRAN_PARTICULAR,'[^/]+',1,1) = ci_channelType--(REGEXP_SUBSTR(DTT.TRAN_PARTICULAR,'[^/]+',1,1) = 'PVR' OR DTT.TRAN_PARTICULAR LIKE ci_channelType)
      AND DTT.DTH_INIT_SOL_ID LIKE '%' || ci_branchCode || '%'
      AND DTT.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy'))
      PIVOT (SUM(CREDIT) AS A , SUM(DEBIT) AS B FOR (GL_SUB_HEAD_CODE)
        IN ('70301' AS A, '70101' AS B, '70111' AS C, '70121' AS D))
  )DTT
  INNER JOIN
  (
      SELECT V.* FROM -- ****(NOT IN CLAUSE REMOVE FOR PERFORMANCE)****
      (
        SELECT T2.TRAN_ID AS TMP_ID, T1.* FROM
        (SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.VALUE_DATE, B.ACID, B.SOL_ID, B.TRAN_PARTICULAR, T.MESG
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
        WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
        --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'PRCR' --LIKE 'P%'
        AND B.PART_TRAN_TYPE = 'D'
        AND B.PSTD_FLG  = 'Y'
        AND REGEXP_SUBSTR(B.TRAN_PARTICULAR,'[^/]+',1,1) = ci_channelType--B.TRAN_PARTICULAR LIKE ci_channelType
        AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
        AND B.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
        )T1 LEFT JOIN
        (SELECT REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) AS TRAN_ID
        FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
        INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
        WHERE B.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
        --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
        AND T.DCC_ID = 'EFT'
        AND T.CMD = 'PRRR'
        AND B.PART_TRAN_TYPE = 'C'
        AND B.PSTD_FLG  = 'Y'
        AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
        AND B.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
        AND REGEXP_SUBSTR(B.TRAN_RMKS,'[^/]+',1,1) IS NOT NULL)T2 ON T2.TRAN_ID = T1.TRAN_ID
      )V WHERE V.TMP_ID IS NULL
      --UNION ALL
      --SELECT '' AS TMP_ID, G.TRAN_ID, G.TRAN_DATE, G.PSTD_DATE, G.VALUE_DATE, G.ACID, G.SOL_ID, G.TRAN_PARTICULAR, S.MESG
      --FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW G
      --INNER JOIN TBAADM.RTT S ON G.TRAN_ID = S.TRAN_ID AND G.SOL_ID = S.SOL_ID
      --AND G.GL_SUB_HEAD_CODE IN ('70101','70111','70121')
      --AND TO_DATE(CAST(G.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(S.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      --AND S.DCC_ID = 'EFT'
      --AND S.CMD = 'PRCR'
      --AND G.PART_TRAN_TYPE = 'D'
      --AND G.PSTD_FLG  = 'Y'
      --AND REGEXP_SUBSTR(G.TRAN_PARTICULAR,'[^/]+',1,1) = 'PVR'
      --AND G.SOL_ID LIKE '%' || ci_branchCode || '%'
      --AND G.VALUE_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
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
  FROM TBAADM.DCTI
  WHERE SOL_ID LIKE '%' || ci_branchCode || '%'
  AND CHANNEL_ID = 'EFT'
  AND DEL_CHANNEL_MESG_ID = 'PRCS' --LIKE 'P%'
  AND TRAN_REMARKS = 'POS'
  --AND TRAN_DATE = TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE
  WHERE NVL(D.INSTITUTION_ID,LTRIM(SUBSTR(C.MESG,INSTR(C.MESG,'BC', 1, 1)-10,8), '2')) IN ('00000010','00000020')
  ORDER BY D.CHANNEL_DEVICE_ID;

  PROCEDURE FIN_POS_ISSUING_LISTING(	inp_str      IN  VARCHAR2,
                                      out_retCode  OUT NUMBER,
                                      out_rec      OUT VARCHAR2 ) AS
  v_TerminalID VARCHAR2(10);
  v_EntryNo VARCHAR2(20);
  v_CardNumber VARCHAR2(20);
  v_AccNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_AccName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_DatePart TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE%type;
  v_TimePart VARCHAR2(20);
  v_TranType VARCHAR2(10);
  v_Debit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Credit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_ICredit TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
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

    vi_tranDate       :=  outArr(0);
    vi_branchCode     :=  outArr(1);    
    vi_channelType    :=  outArr(2);
    vi_tranType       :=  outArr(3);

  --------------------------------------------------------------------------------------------

  if( vi_tranDate is null or vi_channelType is null or vi_tranType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || '-'
                      || '|' || '-' || '|' || '-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;

  --------------------------------------------------------------------------------------------
  
    IF vi_channelType = 'Purchase Transaction' THEN
      vi_channelType := 'PUC';
    END IF;
    IF vi_channelType = 'Purchase Void Transaction' THEN
      vi_channelType := 'PVC';
    END IF;
    IF vi_channelType = 'PreAuth Transaction' THEN
      vi_channelType := 'PreAuth';
    END IF;
    IF vi_channelType = 'PreAuth Void Transaction' THEN
      vi_channelType := 'PreAuthV';
    END IF;
    
  ---------------------------------------------------------------------------------------------
  
  IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
      vi_branchCode  := '';
  END IF;

  ------------------------------------------------------------------------------
    IF vi_tranType = 'Local Transaction' THEN
    
    IF NOT ExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN ExtractData (vi_tranDate, vi_branchCode, vi_channelType);
      --}
      END;
    --}
    END IF;

    IF ExtractData%ISOPEN THEN
    --{
      FETCH	ExtractData
      INTO v_TerminalID, v_EntryNo, v_CardNumber, v_AccNo, v_AccName,
           v_DatePart, v_TimePart, v_TranType, v_Debit, v_Credit, v_ICredit;
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
    ------------------------------------------------------------------------
      ELSE
    ------------------------------------------------------------------------
    IF NOT OExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN OExtractData (vi_tranDate, vi_branchCode, vi_channelType);
      --}
      END;
    --}
    END IF;

    IF OExtractData%ISOPEN THEN
    --{
      FETCH	OExtractData
      INTO v_TerminalID, v_EntryNo, v_CardNumber, v_AccNo, v_AccName,
           v_DatePart, v_TimePart, v_TranType, v_Debit, v_Credit, v_ICredit;
------------------------------------------------------------------------------
      -- Here it is checked whether the cursor has fetched
      -- something or not if not the cursor is closed
      -- and the out ret code is made equal to 1
------------------------------------------------------------------------------
      IF OExtractData%NOTFOUND THEN
      --{
        CLOSE OExtractData;
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
                v_TerminalID	      || '|' ||
                v_EntryNo           || '|' ||
                v_CardNumber        || '|' ||
                v_AccNo	            || '|' ||
                v_AccName 	        || '|' ||
                to_char(to_date(v_DatePart,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_TimePart          || '|' ||
                v_TranType 	        || '|' ||
                v_Debit 	          || '|' ||
                v_Credit 	          || '|' ||
                v_BranchName        || '|' ||
                v_BankAddress       || '|' ||
                v_BankPhone         || '|' ||
                v_BankFax           || '|' ||
                v_ICredit);

			dbms_output.put_line(out_rec);

  END FIN_POS_ISSUING_LISTING;

END FIN_POS_ISSUING_LISTING;
/
