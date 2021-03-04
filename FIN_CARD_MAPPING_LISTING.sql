CREATE OR REPLACE PACKAGE FIN_CARD_MAPPING_LISTING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_CARD_MAPPING_LISTING    (	inp_str      IN  VARCHAR2,
                                          out_retCode  OUT NUMBER,
                                          out_rec      OUT VARCHAR2 );
  

END FIN_CARD_MAPPING_LISTING;
/


CREATE OR REPLACE PACKAGE BODY        FIN_CARD_MAPPING_LISTING AS
/******************************************************************************
 NAME:       FIN_CARD_MAPPING_LISTING
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
  vi_cardType       VARCHAR2(50);               -- Input to procedure
  vi_branchCode     VARCHAR2(5);                -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_CARD_MAPPING_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_cardType VARCHAR2, ci_branchCode VARCHAR2)
IS
  SELECT CM.ACCOUNT_ID AS ACCT_NUMBER, CM.CARD_NUMBER, CM.CARD_TYPE
        , AC.NAME AS CUST_NAME, AC.UNIQUEID AS NRC, G.ACCT_OPN_DATE
        , CASE G.ACCT_CLS_FLG WHEN 'N' THEN 'OPEN' WHEN 'Y' THEN 'CLOSE' ELSE '-' END AS ACCT_STATUS
        , CM.SOL_ID, SL.SOL_DESC
  FROM CUSTOM.C_CCMM CM, TBAADM.GAM G, TBAADM.AAS AAS, CRMUSER.ACCOUNTS AC, TBAADM.SERVICE_OUTLET_TABLE SL
  WHERE CM.ACCOUNT_ID = G.FORACID AND CM.SOL_ID = G.SOL_ID
  AND AC.ENTITY_CRE_FLAG = 'Y' AND AAS.NMA_KEY_ID = AC.ORGKEY 
  AND G.ACID = AAS.ACID AND G.CIF_ID = AC.ORGKEY AND CM.SOL_ID = SL.SOL_ID
  AND G.DEL_FLG = 'N' AND G.ACCT_CLS_FLG = 'N' AND G.BANK_ID = '01'
  AND CM.ISSUED_FLAG = 'Y' AND CM.DEL_FLG = 'N'
  AND CM.CARD_TYPE LIKE '%' || ci_cardType || '%' AND CM.SOL_ID LIKE '%' || ci_branchCode || '%'
  AND TRUNC(CM.LCHG_TIME) BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
  AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)),'dd-MM-yyyy')
  ORDER BY CM.CARD_TYPE, CM.SOL_ID;

  PROCEDURE FIN_CARD_MAPPING_LISTING    (	inp_str      IN  VARCHAR2,
                                          out_retCode  OUT NUMBER,
                                          out_rec      OUT VARCHAR2 ) AS
  v_ACCT_NUMBER VARCHAR2(20);
  v_CARD_NUMBER VARCHAR2(20);
  v_CARD_TYPE VARCHAR2(50);
  v_CUST_NAME VARCHAR2(150);
  v_NRC VARCHAR2(30);
  v_ACCT_OPN_DATE TBAADM.DAILY_TRAN_DETAIL_TABLE.TRAN_DATE%type;
  v_ACCT_STATUS VARCHAR2(10);
  v_SOL_ID VARCHAR2(10);
  v_SOL_DESC VARCHAR2(100);
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  BEGIN
  -- TODO: Implementation required for PROCEDURE FIN_CARD_MAPPING_LISTING.FIN_CARD_MAPPING_LISTING
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
    vi_branchCode :=  outArr(3);

  ------------------------------------------------------------------------------

  if( vi_startDate is null or vi_endDate is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-' 
                  || '|' || '-' || '|' || '-' ||'-' || '|' || '-' || '|' || '-' 
                  || '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;
  
  ------------------------------------------------------------------------------
    
    IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
      vi_branchCode  := '';
    END IF;

  ------------------------------------------------------------------------------
  
   IF NOT ExtractData%ISOPEN THEN
    --{
      BEGIN
      --{
        OPEN ExtractData (vi_startDate, vi_endDate, vi_cardType, vi_branchCode);
      --}
      END;
    --}
    END IF;

    IF ExtractData%ISOPEN THEN
    --{
      FETCH	ExtractData
      INTO  v_ACCT_NUMBER, v_CARD_NUMBER, v_CARD_TYPE, v_CUST_NAME
            , v_NRC, v_ACCT_OPN_DATE, v_ACCT_STATUS, v_SOL_ID, v_SOL_DESC;
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
    
------------------------------------------------------------------------------

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
                v_ACCT_NUMBER   || '|' ||
                v_CARD_NUMBER   || '|' ||
                v_CARD_TYPE     || '|' ||
                v_CUST_NAME     || '|' ||
                v_NRC           || '|' ||
                to_char(to_date(v_ACCT_OPN_DATE,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' ||
                v_ACCT_STATUS   || '|' ||
                v_BranchName  || '|' ||
                v_BankAddress || '|' ||
                v_BankPhone   || '|' ||
                v_BankFax     || '|' ||
                v_SOL_ID      || '|' ||
                v_SOL_DESC);

			dbms_output.put_line(out_rec);
      
  END FIN_CARD_MAPPING_LISTING;

END FIN_CARD_MAPPING_LISTING;
/
