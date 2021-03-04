CREATE OR REPLACE PACKAGE        FIN_BILL_PAYMENT_STATUS AS 

PROCEDURE FIN_BILL_PAYMENT_STATUS(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_BILL_PAYMENT_STATUS;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_BILL_PAYMENT_STATUS
AS
  -------------------------------------------------------------------------------------
------------------------------Update User-  Saung Hnin OO -------------------------
------------------------------Update Date - 2-5-2017-------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array

  vi_startDate  VARCHAR2(10);         -- Input to procedure
  vi_endDate    VARCHAR2(10);         -- Input to procedure
  vi_billerId   VARCHAR2(10);         -- Input to procedure
  vi_billStatus VARCHAR2(10);          -- Input to procedure
    vi_user_id  VARCHAR2(15);  
   vi_branchCode VARCHAR2(5);          -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData
  -----------------------------------------------------------------------------
  CURSOR ExtractData ( ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_billerId VARCHAR2, ci_billStatus VARCHAR2,ci_user_id VARCHAR2,ci_branchCode VARCHAR2 )
  IS
    SELECT pyht.biller_id       AS "Biller ID",
      pyht.biller_service_id    AS "Biller Service ID",
      pyht.subscription_id      AS "Subscription ID",
      pyht.bill_date         AS "Payment Date",
      pyht.bill_status          AS "Bill Status",
      pyst.bill_details_mandate AS "Bill Details Mandate",
      gam.foracid               AS "Account ID",
      gam.cif_id                AS "CIF_ID" ,
      pyht.payment_id           AS "Payment ID",
      pyht.bill_amt             AS "Bill Amount",
      pyht.min_pymt_amt         AS "Min Pay Amount",
      pyht.charge_amt           AS "Charges Amount"
    FROM tbaadm.pyht
    INNER JOIN tbaadm.pyst
    ON pyht.subscription_id = pyst.subscription_id
    INNER JOIN tbaadm.gam
    ON pyst.transfer_acid = gam.acid
    WHERE pyht.biller_id  like '%'|| upper(ci_billerId) || '%'
    AND gam.sol_id       like '%'|| ci_branchCode || '%'
    AND pyht.bill_status   like '%'|| upper(ci_billStatus) || '%'
    and pyht.rcre_user_id = upper(ci_user_id)
    AND pyht.bill_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.DEL_FLG  = 'N'
    AND pyst.DEL_FLG = 'N'
    AND pyst.bank_id = '01'
    AND gam.bank_id  = '01'
    AND pyht.bank_id = '01'
    ORDER BY  gam.foracid,pyht.bill_date ASC ;
 -----------------------------------------------------------------------------------
  PROCEDURE FIN_BILL_PAYMENT_STATUS(
      inp_str IN VARCHAR2,
      out_retCode OUT NUMBER,
      out_rec OUT VARCHAR2 )
  AS
    v_BillerId TBAADM.pyht.BILLER_ID%type;
    v_BillerServiceId TBAADM.pyht.BILLER_SERVICE_ID%type;
    v_SubscriptionId TBAADM.pyht.SUBSCRIPTION_ID%type;
    v_PaymentDate TBAADM.pyht.BILL_DATE%type;
    v_BillStatus TBAADM.pyht.BILL_STATUS%type;
    v_BillDetailMandate TBAADM.pyst.BILL_DETAILS_MANDATE%type;
    v_AccountID TBAADM.gam.FORACID%type;
    v_cif_id  TBAADM.gam.cif_id%type;
    v_PaymentID TBAADM.pyht.PAYMENT_ID%type;
    v_BillAmount TBAADM.pyht.BILL_AMT%type;
    v_MinPayAmount TBAADM.pyht.MIN_PYMT_AMT%type;
    v_ChargesAmount TBAADM.pyht.CHARGE_AMT%type;
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
    vi_startDate    := outArr(0);
    vi_endDate      := outArr(1);
    vi_billerId     := outArr(2);
    vi_billStatus   := outArr(3);
    vi_user_id      := outArr(4);
    vi_branchCode   := outArr(5);
    
    --------------------------------------------------
     IF vi_billerId ='MPT' then
       vi_billerId := 'MPT';
 ELSif    vi_billerId ='MOEP' then
        vi_billerId := 'MOEP';
         ELSif    vi_billerId ='REDLINK' then
        vi_billerId := 'REDLINK';
       ELSif    vi_billerId ='ADSL' then
        vi_billerId := 'ADSL';
        ELSE  vi_billerId := '';
    END IF;
    --------------------------------------------
     IF vi_billerId IS NULL OR vi_billerId = '' THEN
   vi_billerId  := '';
  END IF;
  
  -------------------------------------------
  IF vi_billStatus ='SUCCESS' then
       vi_billStatus := 'P';
 ELSif    vi_billStatus ='FAIL' then
        vi_billStatus := 'F';
     ELSE  vi_billStatus := '';
    END IF;    
  ----------------------------------------------------
    IF vi_billStatus IS NULL OR vi_billStatus = '' THEN
   vi_billStatus  := '';
  END IF;
  
    ------------------------------------------------------
    IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
--------------------------------------------------------
   
   IF NOT ExtractData %ISOPEN THEN
      --{
      BEGIN
        --{
        OPEN ExtractData ( vi_startDate , vi_endDate , vi_billerId , vi_billStatus,vi_user_id,vi_branchCode );
        --}
      END;
      --}
    END IF;
    IF ExtractData %ISOPEN THEN
      --{
      FETCH ExtractData 
      INTO  v_BillerId,
          v_BillerServiceId,
          v_SubscriptionId,
          v_PaymentDate,
          v_BillStatus,
          v_BillDetailMandate,
          v_AccountID,
          v_cif_id,
          v_PaymentID,
          v_BillAmount,
          v_MinPayAmount,
          v_ChargesAmount;
         

     
      ------------------------------------------------------------------
      -- Here it is checked whether the cursor has fetched
      -- something or not if not the cursor is closed
      -- and the out ret code is made equal to 1
      ------------------------------------------------------------------
      IF ExtractData %NOTFOUND THEN
        --{
        CLOSE ExtractData ;
        out_retCode:= 1;
        RETURN;
        --}
      END IF;
      --}
    END IF;
  Begin
        -------------------------------------------------------------------------------
        -- GET BANK INFORMATION
        -------------------------------------------------------------------------------
         if vi_branchCode is not null then 
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
        end if;
      END;
      -----------------------------------------------------------------------------------
      -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
      ------------------------------------------------------------------------------------
      out_rec:= ( 
        v_BillerId || '|' || 
        v_BillerServiceId || '|' || 
        v_SubscriptionId || '|' || 
        trim(TO_CHAR(to_date(v_PaymentDate,'dd/Mon/yy'), 'dd-MM-yyyy') ) || '|' || 
        v_BillStatus || '|' || 
        v_BillDetailMandate || '|' || 
        v_AccountID || '|' || 
        v_cif_id  || '|' || 
        v_PaymentID || '|' || 
        v_BillAmount || '|' || 
        v_MinPayAmount || '|' || 
        v_ChargesAmount || '|' ||
        v_BankAddress || '|' || 
        v_BankPhone || '|' || 
        v_BankFax );
      dbms_output.put_line(out_rec);
    END FIN_BILL_PAYMENT_STATUS;
  END FIN_BILL_PAYMENT_STATUS;
/
