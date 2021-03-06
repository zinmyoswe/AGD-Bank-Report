CREATE OR REPLACE PACKAGE FIN_ATM_BILL_PAYMENT_LISTING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_ATM_BILL_PAYMENT_LISTING(	inp_str       IN  VARCHAR2,
                                          out_retCode   OUT NUMBER,
                                          out_rec       OUT VARCHAR2 );

END FIN_ATM_BILL_PAYMENT_LISTING;
/


CREATE OR REPLACE PACKAGE BODY FIN_ATM_BILL_PAYMENT_LISTING AS
/******************************************************************************
 NAME:       FIN_ATM_BILL_PAYMENT_LISTING
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
  
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_ATM_BILL_PAYMENT_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractDataByBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
IS  
  SELECT  DTT.TRAN_ID AS ENTRY_NO, D.CHANNEL_DEVICE_ID AS ATM_NO, G.FORACID AS ACC_NO
        , TRIM(SUBSTR(MESG, INSTR(MESG, 'M004', 1, 1)+6 ,INSTR(MESG, ' ', 1, 1) - INSTR(MESG, 'M004', 1, 1) -1)) AS SERVICE_NO
        , DTT.SNO, 'Phone' AS GNAME, DTT.TRAN_AMT, DTT.PSTD_DATE AS DATE_PART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIME_PART
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG, T.SNO
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'TRTR'
      AND T.MESG LIKE '%M004%'
      AND B.SOL_ID LIKE '%' || ci_branchCode || '%'
      AND B.PART_TRAN_TYPE = 'D'
      AND B.TRAN_TYPE = 'T'
      AND B.PSTD_FLG  = 'Y'
      AND B.PSTD_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
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
      AND DEL_CHANNEL_MESG_ID = 'TRTS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE  
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  ORDER BY DTT.TRAN_ID;
  
CURSOR ExtractDataAllBranch (ci_startDate VARCHAR2, ci_endDate VARCHAR2)
IS  
  SELECT  DTT.TRAN_ID AS ENTRY_NO, D.CHANNEL_DEVICE_ID AS ATM_NO, G.FORACID AS ACC_NO
        , TRIM(SUBSTR(MESG, INSTR(MESG, 'M004', 1, 1)+6 ,INSTR(MESG, ' ', 1, 1) - INSTR(MESG, 'M004', 1, 1) -1)) AS SERVICE_NO
        , DTT.SNO, 'Phone' AS GNAME, DTT.TRAN_AMT, DTT.PSTD_DATE AS DATE_PART, TO_CHAR(DTT.PSTD_DATE, 'HH24:MI:SS') AS TIME_PART
  FROM
  (
      SELECT B.TRAN_ID, B.TRAN_DATE, B.PSTD_DATE, B.ACID, B.DTH_INIT_SOL_ID, B.SOL_ID, B.TRAN_AMT, T.MESG, T.SNO
      FROM CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW B
      INNER JOIN TBAADM.RTT T ON B.TRAN_ID = T.TRAN_ID AND B.DTH_INIT_SOL_ID = T.SOL_ID AND B.TRAN_DATE = T.TRAN_DATE
      --AND TO_DATE(CAST(B.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy') = TO_DATE(CAST(T.TRAN_DATE AS VARCHAR(10)),'dd-MM-yyyy')
      WHERE T.DCC_ID = 'EFT'
      AND T.CMD = 'TRTR'
      AND T.MESG LIKE '%M004%'
      AND B.PART_TRAN_TYPE = 'D'
      AND B.TRAN_TYPE = 'T'
      AND B.PSTD_FLG  = 'Y'
      AND B.PSTD_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
      AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
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
      FROM TBAADM.DCTI 
      WHERE CHANNEL_ID = 'EFT' 
      AND DEL_CHANNEL_MESG_ID = 'TRTS'
      AND NVL(FREE_TEXT3,'') IS NULL
      --AND TRAN_DATE BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy') 
      --AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ) D ON DTT.TRAN_ID = D.TRAN_ID AND DTT.DTH_INIT_SOL_ID = D.SOL_ID AND DTT.TRAN_DATE = D.TRAN_DATE  
  --LEFT JOIN CUSTOM.C_CCMM M ON D.FORACID = M.ACCOUNT_ID AND D.SOL_ID = M.SOL_ID
  ORDER BY DTT.TRAN_ID;

  PROCEDURE FIN_ATM_BILL_PAYMENT_LISTING(	inp_str      IN  VARCHAR2,
                                        out_retCode  OUT NUMBER,
                                        out_rec      OUT VARCHAR2 ) AS
  v_EntryNo VARCHAR2(20);
  v_ATMNo VARCHAR2(20);
  v_AccNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_ServiceNo VARCHAR2(20);
  v_SrNo VARCHAR2(20);
  v_GName VARCHAR2(10);
  v_TranAmt TBAADM.REF_TRN_TBL.TRAN_AMT%type;
  v_DatePart TBAADM.DAILY_TRAN_DETAIL_TABLE.TRAN_DATE%type;
  v_TimePart VARCHAR2(20);
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;                                      
  BEGIN
  -- TODO: Implementation required for PROCEDURE FIN_ATM_BILL_TRANS_LISTING.FIN_ATM_BILL_TRANS_LISTING
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
    
  ------------------------------------------------------------------------------
  
  if( vi_startDate is null or vi_endDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0
                  || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' ||'-' || '|' || '-' || '|' || '-' || '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;  
  
  ------------------------------------------------------------------------------
  
  IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
      vi_branchCode  := '';
  END IF;

  ------------------------------------------------------------------------------
  
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
      INTO v_EntryNo, v_ATMNo, v_AccNo, v_ServiceNo, v_SrNo, v_GName, v_TranAmt, v_DatePart, v_TimePart;
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
                v_EntryNo	    || '|' ||
                v_ATMNo	      || '|' ||
                v_AccNo 	    || '|' ||
                v_ServiceNo   || '|' ||
                v_TranAmt     || '|' ||
                to_char(to_date(v_DatePart,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
                v_TimePart 	  || '|' ||                
                v_BranchName  || '|' ||
                v_BankAddress || '|' ||
                v_BankPhone   || '|' ||
                v_BankFax     || '|' ||
                v_SrNo        || '|' ||
                v_GName);
  
			dbms_output.put_line(out_rec);
      
  END FIN_ATM_BILL_PAYMENT_LISTING;

END FIN_ATM_BILL_PAYMENT_LISTING;
/
