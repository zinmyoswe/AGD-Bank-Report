CREATE OR REPLACE PACKAGE FIN_BILL_AUTOPAY_FAIL1 AS 

  PROCEDURE FIN_BILL_AUTOPAY_FAIL1(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BILL_AUTOPAY_FAIL1;
/


CREATE OR REPLACE PACKAGE BODY FIN_BILL_AUTOPAY_FAIL1
AS
  -------------------------------------------------------------------------------------
  --Update User -Saung Hnin Oo--------------------------------------
  ---Update Date - 2-5-2017------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType ; -- Input Parse Array
  vi_Date   VARCHAR2(10);         -- Input to procedure
  vi_Currency     VARCHAR2(10);         -- Input to procedure
 
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData
  -----------------------------------------------------------------------------
  CURSOR ExtractData (ci_startDate VARCHAR2,ci_endDate VARCHAR2,ci_serviceType VARCHAR2,ci_user_id VARCHAR2, ci_branchCode VARCHAR2)
  IS
   SELECT
    DISTINCT 
      pyst.bill_details_mandate AS "ServiceNo",
      pyht.bill_amt                       AS "BillAmount",
      pyst.limit_crncy_code               AS "Cur_code" ,
      pyht.bill_due_date                  AS "Due Date" 
    
    FROM tbaadm.gam gam ,
      tbaadm.pyst pyst,
      tbaadm.pyht pyht
    WHERE pyst.transfer_acid = gam.acid
    AND pyst.subscription_id = pyht.subscription_id
    AND pyht.bill_status     = 'F'
   and pyht.rcre_user_id = upper(ci_user_id)
    AND pyht.biller_id LIKE '%'  || upper(ci_serviceType)   || '%'
    AND pyht.bill_date BETWEEN TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.sol_id LIKE '%'   || ci_branchCode   ||'%'
      --AND SUBSTR(pyst.BILL_DETAILS_MANDATE, instr(pyst.BILL_DETAILS_MANDATE, '=', 1, 2)+1, instr(pyst.BILL_DETAILS_MANDATE, ';', 1, 2) - instr(pyst.BILL_DETAILS_MANDATE, '=', 1, 2)-1 ) LIKE '%'|| '' ||'%'
    ORDER BY   pyst.bill_details_mandate; 
    
PROCEDURE FIN_BILL_AUTOPAY_FAIL1(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_service_id TBAADM.pyst.BILL_DETAILS_MANDATE%type;
  v_bill_amt TBAADM.pyht.bill_amt%type;
  v_cur_code TBAADM.pyst.limit_crncy_code%type;
  v_bill_due_date TBAADM.pyht.bill_due_date%type;
  -- v_BillDetailMandate TBAADM.pyst.BILL_DETAILS_MANDATE%type;
  --v_TranDate txnh.txn_date%type;
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
  vi_startDate   := outArr(0);
  vi_endDate     := outArr(1);
  vi_serviceType := outArr(2);
  vi_user_id  := outArr(3);
  vi_BranchCode  := outArr(4);
  -------------------------------------------------------------------
  IF vi_serviceType    ='MPT' THEN
    vi_serviceType    := 'MPT';
  ELSif vi_serviceType ='MOEP' THEN
    vi_serviceType    := 'MOEP';
  ELSif vi_serviceType ='REDLINK' THEN
    vi_serviceType    := 'REDLINK';
  ELSif vi_serviceType ='ADSL' THEN
    vi_serviceType    := 'ADSL';
     ELSif vi_serviceType ='CNP' THEN
    vi_serviceType    := 'CNP';
  ELSE
    vi_serviceType := '';
  END IF;
  ---------------------------------------------------------
  IF vi_serviceType IS NULL OR vi_serviceType = '' THEN
    vi_serviceType  := '';
  END IF;
  ------------------------------------------------------------
  IF vi_BranchCode IS NULL OR vi_BranchCode = '' THEN
    vi_BranchCode  := '';
  END IF;
  IF NOT ExtractData%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractData ( vi_startDate , vi_endDate , vi_serviceType ,vi_user_id,vi_BranchCode );
      --}
    END;
    --}
  END IF;
  IF ExtractData%ISOPEN THEN
    --{
    FETCH ExtractData
    INTO v_service_id, v_bill_amt,
      v_cur_code,
      v_bill_due_date;
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
      --}'
    END IF;
    --}
  END IF;
  BEGIN
    -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
    -------------------------------------------------------------------------------
    IF vi_BranchCode IS NOT NULL THEN
      SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
        BRANCH_CODE_TABLE.BR_ADDR_1          AS "Bank_Address",
        BRANCH_CODE_TABLE.PHONE_NUM          AS "Bank_Phone",
        BRANCH_CODE_TABLE.FAX_NUM            AS "Bank_Fax"
      INTO v_BranchName,
        v_BankAddress,
        v_BankPhone,
        v_BankFax
      FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
        TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
      AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
      AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
      AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
    END IF;
  END;
  -----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  ------------------------------------------------------------------------------------
  out_rec:= ( v_service_id || '|' || v_bill_amt || '|' || v_cur_code || '|' ||
      trim(to_char(to_date(v_bill_due_date,'dd/Mon/yy'), 'dd-MM-yyyy') )   );
  dbms_output.put_line(out_rec);
END FIN_BILL_AUTOPAY_FAIL1;
END FIN_BILL_AUTOPAY_FAIL1;
/
