CREATE OR REPLACE PACKAGE        FIN_LN_LEDGER_BALANCE_LISTING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE FIN_LN_LEDGER_BALANCE_LISTING(  inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 );
END FIN_LN_LEDGER_BALANCE_LISTING;
 
/


CREATE OR REPLACE PACKAGE BODY                             FIN_LN_LEDGER_BALANCE_LISTING AS
/******************************************************************************
 NAME:       FIN_LN_LEDGER_BALANCE_LISTING
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
  vi_currency       Varchar2(3);                -- Input to procedure
  vi_branchCode     VARCHAR2(5);                -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_LN_LEDGER_BALANCE_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2,  ci_currency VARCHAR2,ci_branchCode VARCHAR2)
IS
SELECT  TMP.ACCT_OPN_DATE AS openDate,
  TMP.EI_PERD_END_DATE AS expDate,
  TMP.FORACID AS accNo,
  TMP.FORACID AS dlNo,
  TMP.ACCT_NAME AS accName,
  TMP.DIS_AMT AS dlLimit,
  --(TMP.TRAN_DATE_BAL * -1) AS dlOutstanding,
   TMP.SUM_PRINCIPAL_DMD_AMT AS dlOutstanding,
  TMP.ODINTEREST AS dlInterest,
  TMP.ODate AS groupDate,
  0 AS serviceCharges,
  0 AS Commission,
  ' ' AS Commitment,
  CH.SYS_CALC_CHRGE_AMT AS lateFees
  FROM
  (
      SELECT  GA.ACID,GA.ACCT_OPN_DATE,LA.EI_PERD_END_DATE,GA.FORACID,GA.ACCT_NAME,
      T.TRAN_DATE_BAL,LA.DIS_AMT,LA.SUM_PRINCIPAL_DMD_AMT,
      SUM(EI.NRML_ACCRUED_AMOUNT_DR - EI.NRML_INTEREST_AMOUNT_DR) AS ODINTEREST,
      GA.SOL_ID,T.ODate,T.EOD_DATE        
      FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
      INNER JOIN TBAADM.LA_ACCT_MAST_TABLE LA ON GA.ACID = LA.ACID
      INNER JOIN 
      (
        SELECT t1.ACID, t2.TRAN_DATE_BAL, t2.EOD_DATE, 
        TO_CHAR(t2.EOD_DATE,'Mon-YYYY') AS ODate
        FROM
        (
            SELECT ACID, MAX(EOD_DATE) AS MDate 
            FROM TBAADM.EOD_ACCT_BAL_TABLE
            WHERE EOD_DATE BETWEEN TRUNC(to_date(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy'),'MM')
            AND LAST_DAY(to_date(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy'))
            GROUP BY ACID
            ORDER BY MDATE
        )t1 INNER JOIN TBAADM.EOD_ACCT_BAL_TABLE t2 
        ON t1.MDate = t2.EOD_DATE AND t1.ACID = t2.ACID
        ORDER BY t2.EOD_DATE
      )T ON GA.ACID = T.ACID
      --INNER JOIN TBAADM.LIM_HISTORY_TABLE LH ON GA.ACID = LH.ACID
      INNER JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
      WHERE GA.Schm_Type='LAA'
      AND GA.ACCT_CLS_FLG = 'N' AND GA.DEL_FLG = 'N'
      AND GA.SOL_ID = ci_branchCode AND GA.ACCT_CRNCY_CODE = upper(ci_currency)
      --AND LH.SANCT_REF_NUM IS NOT NULL
      AND T.TRAN_DATE_BAL < 0
      GROUP BY GA.ACID,GA.ACCT_OPN_DATE,LA.EI_PERD_END_DATE,GA.FORACID,GA.ACCT_NAME,
      T.TRAN_DATE_BAL,LA.DIS_AMT,LA.SUM_PRINCIPAL_DMD_AMT,GA.SOL_ID,T.ODate,T.EOD_DATE
  ) TMP LEFT JOIN TBAADM.CHAT CH ON TMP.ACID = CH.ACID AND CH.CHARGE_TYPE = 'LATEF';
  
  PROCEDURE FIN_LN_LEDGER_BALANCE_LISTING(  inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_openDate DATE;
  v_expDate DATE;
  v_accNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_dlNo TBAADM.LIM_HISTORY_TABLE.SANCT_REF_NUM%type;
  v_accName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_dlLimit TBAADM.LIM_HISTORY_TABLE.SANCT_LIM%type;
  v_dlOutstanding TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_dlInterest TBAADM.ENTITY_INTEREST_TABLE.NRML_INTEREST_AMOUNT_DR%type;
  v_groupDate TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_serviceCharges TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Commission TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Commitment VARCHAR2(50);
  v_lateFees TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
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
    vi_currency   :=  outArr(2);
     vi_branchCode :=  outArr(3);
    -------------------------------------------------------------------------------------------------
    if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		           '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||'-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
                    0|| '|' || 0 || '|' || 0 || '|' || 0 );
		          
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    
    -------------------------------------------------------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_startDate, vi_endDate, vi_currency, vi_branchCode);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO v_openDate, v_expDate, v_accNo, v_dlNo, 
            v_accName, v_dlLimit, v_dlOutstanding, 
            v_dlInterest, v_groupDate, v_serviceCharges,
            v_Commission, v_Commitment, v_lateFees;
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
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
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
    END;
    
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:= (to_char(to_date(v_openDate,'dd/Mon/yy'), 'dd/MM/yyyy')            || '|' ||
          to_char(to_date(v_expDate,'dd/Mon/yy'), 'dd/MM/yyyy')                  || '|' ||
                    v_accNo         || '|' ||
                    v_dlNo          || '|' ||
                    v_accName                  || '|' ||
                    v_dlLimit                  || '|' ||
                    v_dlOutstanding            || '|' ||
                    v_dlInterest               || '|' ||
                    v_BranchName      || '|' ||
                    v_BankAddress     || '|' ||
                    v_BankPhone       || '|' ||
                    v_BankFax         || '|' ||
                    v_groupDate       || '|' ||
                    v_serviceCharges  || '|' ||
                    v_Commission      || '|' ||
                    v_Commitment      || '|' ||
                    v_lateFees); 
  
			dbms_output.put_line(out_rec);
  END FIN_LN_LEDGER_BALANCE_LISTING;

END FIN_LN_LEDGER_BALANCE_LISTING;
/
