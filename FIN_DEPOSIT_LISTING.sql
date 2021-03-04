CREATE OR REPLACE PACKAGE                                    FIN_DEPOSIT_LISTING AS 

  PROCEDURE FIN_DEPOSIT_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
END FIN_DEPOSIT_LISTING;
/


CREATE OR REPLACE PACKAGE BODY        FIN_DEPOSIT_LISTING
AS
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_startDate   VARCHAR2(10);        -- Input to procedure
  vi_endDate     VARCHAR2(10);        -- Input to procedure
  vi_SchemeType  VARCHAR2(5);         -- Input to procedure
  vi_SchemeCode  VARCHAR2(6);         -- Input to procedure
  vi_currency    VARCHAR2(5);         -- Input to procedure
  vi_entryUserId VARCHAR2(20);        -- Input to procedure
  vi_branchCode  VARCHAR2(5);         -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData with Scheme Code
  -----------------------------------------------------------------------------
  ---------------------------User ID(with) and Scheme Code (with)-------------
  ----------------------------------------------------------------------------
  CURSOR ExtractData ( ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_SchemeCode VARCHAR2, ci_SchemeType VARCHAR2,ci_currency VARCHAR2, ci_entryUserId VARCHAR2, ci_branchCode VARCHAR2)
  IS
    SELECT detail.tran_id  AS entryNumber,
      detail.tran_date     AS entryDate,
      detail.entry_user_id AS enteredBy,
      gam.foracid          AS accountNumber,
      detail.tran_amt      AS amount,
      gam.acct_name        AS accountName
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam
    WHERE detail.acid       = gam.acid
    AND gam.del_flg         = 'N'
    AND gam.acct_cls_flg    = 'N'
    AND gam.bank_id         ='01'
    AND gam.acct_crncy_code = UPPER(ci_currency)
    AND detail.pstd_flg     = 'Y'
      --and detail.TRAN_PARTICULAR_CODE ='CHD'
    AND DETAIL.TRAN_TYPE      = 'C' --**
    AND detail.part_tran_type = 'C'
    AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND detail.dth_init_sol_id LIKE '%' || ci_branchCode || '%'
    AND gam.schm_type LIKE '%' || ci_SchemeType|| '%'
    AND gam.schm_code LIKE '%' || UPPER(ci_SchemeCode) || '%'
    AND detail.entry_user_id LIKE '%'  || UPPER(ci_entryUserId) || '%'
    ORDER BY detail.tran_date ASC ,
      gam.foracid ASC ;
  ---------------------------------------------------------------------------
PROCEDURE FIN_DEPOSIT_LISTING(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
IS
  v_entryNumber TBAADM.CTD_DTD_ACLI_VIEW.TRAN_ID%type;
  v_entryDate DATE;
  v_enteredBy TBAADM.CTD_DTD_ACLI_VIEW.ENTRY_USER_ID%type;
  v_accountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_accountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
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
  vi_startDate   :=outArr(0);
  vi_endDate     :=outArr(1);
  vi_SchemeType  :=outArr(2);
  vi_SchemeCode  :=outArr(3);
  vi_currency    :=outArr(4);
  vi_entryUserId :=outArr(5);
  vi_branchCode  :=outArr(6);
  ------------------------------------------------------------
  IF vi_SchemeType IS NULL OR vi_SchemeType = '' THEN
  vi_SchemeType  := '';
  END IF; 
  IF vi_SchemeCode IS NULL OR vi_SchemeCode = '' THEN
    vi_SchemeCode  := '';
  END IF;
  IF vi_entryUserId IS NULL OR vi_entryUserId = '' THEN
    vi_entryUserId  := '';
  END IF;
  IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
    vi_branchCode  := '';
  END IF;
  -----------------------------------------------------------------------
  
  IF( vi_entryUserId IS NULL and vi_SchemeType IS NULL) THEN
    --resultstr := 'No Data For Report';
    out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-');
    --dbms_output.put_line(out_rec);
    out_retCode:= 1;
    RETURN;
  END IF;
  

  
 IF( vi_startDate IS NULL OR vi_endDate IS NULL OR vi_currency IS NULL ) THEN
    --resultstr := 'No Data For Report';
    out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-');
    --dbms_output.put_line(out_rec);
    out_retCode:= 1;
    RETURN;
  END IF;

  --------------------------------------------------------------------
  IF vi_entryUserId = '' THEN
    vi_entryUserId := NULL;
  END IF;
  ----------------------------Without Scheme Code  -----------------------------------
  IF NOT ExtractData%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractData ( vi_startDate , vi_endDate , vi_SchemeCode , vi_SchemeType ,vi_currency , vi_entryUserId , vi_branchCode );
      --}
    END;
    --}
  END IF;
  IF ExtractData%ISOPEN THEN
    --{
    FETCH ExtractData
    INTO v_entryNumber,
      v_entryDate,
      v_enteredBy,
      v_accountNumber,
      v_amount,
      v_accountName;
    ------------------------------------------------------------------
    -- Here it is checked whether the cursor has fetched
    -- something or not if not the cursor is closed
    -- and the out ret code is made equal to 1
    ------------------------------------------------------------------
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
    IF vi_branchCode IS NOT NULL THEN
      SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
        BRANCH_CODE_TABLE.BR_ADDR_1          AS "BankAddress",
        BRANCH_CODE_TABLE.PHONE_NUM          AS "BankPhone",
        BRANCH_CODE_TABLE.FAX_NUM            AS "BankFax"
      INTO v_BranchName,
        v_BankAddress,
        v_BankPhone,
        v_BankFax
      FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
        TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
      AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
      AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
      AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
    END IF;
  END;
  -----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  ------------------------------------------------------------------------------------
  out_rec:= (v_entryNumber || '|' || TO_CHAR(to_date(v_entryDate,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' || v_enteredBy || '|' || v_accountNumber || '|' || v_amount || '|' || v_accountName || '|' || v_BranchName || '|' || v_BankAddress || '|' || v_BankPhone || '|' || v_BankFax );
  dbms_output.put_line(out_rec);
END FIN_DEPOSIT_LISTING;
END FIN_DEPOSIT_LISTING;
/
