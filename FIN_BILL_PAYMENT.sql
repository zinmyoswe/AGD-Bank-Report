CREATE OR REPLACE PACKAGE                                                                FIN_BILL_PAYMENT AS 

 PROCEDURE FIN_BILL_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );


END FIN_BILL_PAYMENT;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                               FIN_BILL_PAYMENT
AS
----------------------------------------------------------------------
------Update user- Saung Hnin OO------------------------------------------
-----Date -12-4-2017----------------------------------
  -- Cursor declaration--------------------------------------------------
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_StartDate         VARCHAR2(10);             -- Input to procedure
  vi_EndDate         VARCHAR2(10);             -- Input to procedure
  vi_service_type VARCHAR2(10);             -- Input to procedure
  vi_checktype    VARCHAR2(10);              -- Input to procedure
  vi_zonecode      VARCHAR2(10);              -- Input to procedure
  vi_branchCode   VARCHAR2(5);              -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData_Paid
  -----------------------------------------------------------------------------
  CURSOR ExtractData ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2,ci_service_type VARCHAR2,ci_checktype VARCHAR2,ci_zonecode VARCHAR2,ci_branchCode VARCHAR2)
  IS
  select 
 distinct
  pyst.bill_details_idx                                       AS ServiceNo,
  gam.FORACID                                                 AS "AccountNumber" ,
  gam.cif_id                                                  AS "CIF ID" ,
  pnpd.bill_status                                            AS "Status" ,
  pnpd.Bill_date                                              AS "Tran_Date",
  pnpd.bill_crncy_code                                        AS "Currency",
  accounts.name                                               AS "Customer Name",
  pnpd.Bill_amt                                               AS "bill amount",
  pnpd.charge_amt                                             AS "Service charges",
  ( pnpd.Bill_amt+  pnpd.charge_amt )                         AS "Total Amount",
  gam.sol_id                                                  AS "Open Branch",
accounts.strfield2                                            AS "Phone NO"
 
  from tbaadm.gam gam,
       tbaadm.pyst pyst,
       tbaadm.pnpd pnpd ,
        crmuser.accounts accounts
        
  
  where 
  pyst.subscription_id = pnpd.subscription_id 
  and pyst.transfer_acid =gam.acid
  and accounts.core_cust_id =  gam.cust_id 
  and pnpd.Bill_date between TO_DATE( CAST (ci_StartDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  AND pnpd.biller_id   LIKE '%'|| ci_service_type ||'%' 
  AND pnpd.bill_status LIKE '%'||ci_checktype||'%'
  AND gam.SOL_ID       LIKE '%'||''||'%'
 AND SUBSTR(SUBSTR(SUBSTR(BILL_DETAILS_MANDATE,INSTR(BILL_DETAILS_MANDATE,'ZONECODE'),LENGTH(BILL_DETAILS_MANDATE)), 10,LENGTH(BILL_DETAILS_MANDATE)),1,LENGTH(SUBSTR(SUBSTR(BILL_DETAILS_MANDATE,INSTR(BILL_DETAILS_MANDATE,'ZONECODE'),LENGTH(BILL_DETAILS_MANDATE)), 10,LENGTH(BILL_DETAILS_MANDATE)))-1) LIKE '%'
 || ci_zonecode
 ||'%'
   AND gam.del_flg            ='N'
   AND pyst.del_flg           ='N'
   AND gam.bank_id            ='01'
 --  AND phoneemail.bank_id     ='01'
   AND accounts.bank_id       ='01'
   AND pyst.bank_id           ='01'
   AND pnpd.bank_id           ='01'
   AND gam.acct_cls_flg       ='N'
   ORDER BY  pyst.bill_details_idx ;
 
  ---------------------------------------------------------------------------------------------
PROCEDURE FIN_BILL_PAYMENT(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
v_service_id tbaadm.pyst.bill_details_idx  %type; 
 v_AccountNumber TBAADM. gam.FORACID%type;
  v_cif_id  TBAADM.gam.cif_id%type;  
  v_status   TBAADM.pnpd.bill_status%type; 
  v_Transaction_Date TBAADM.pnpd.Bill_date %type ;
  v_cur_code TBAADM.pnpd.bill_crncy_code %type; 
  v_CustomerName crmuser.accounts.name %type;
  v_Bill_Amount TBAADM.pnpd.Bill_amt %type;
  v_total_service_charges TBAADM. pnpd.charge_amt%type;
  v_total_amount                                 DECIMAL;
  v_OpenBranch TBAADM.GENERAL_ACCT_MAST_TABLE.SOL_ID%type;
  v_phone_no CRMUSER.phoneemail.phoneno   %type;
 
  
  
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
  vi_StartDate           :=outArr(0);
  vi_EndDate                :=outArr(1);
  vi_service_type   :=outArr(2);
  vi_checktype       :=outArr(3);
  vi_zonecode      :=outArr(4);
  vi_branchCode     :=outArr(5);
  
----------------------------------------------  
    IF vi_service_type ='MPT' then
       vi_service_type := 'MPT';
 ELSif    vi_service_type ='MOEP' then
        vi_service_type := 'MOEP';
         ELSif    vi_service_type ='REDLINK' then
        vi_service_type := 'REDLINK';
       ELSif    vi_service_type ='ADSL' then
        vi_service_type := 'ADSL';
        ELSE  vi_service_type := '';
    END IF;
  -----------------------------------------------------------
  
   IF vi_checktype ='Paid' then
       vi_checktype := 'S';
 ELSif    vi_checktype ='Unpaid' then
        vi_checktype := 'F';
       ELSE 
        vi_checktype := '' ;
    END IF;
----------------------------------------------------------------------  
   IF vi_zonecode IS  NULL or vi_zonecode = ''  THEN
         vi_zonecode := '';
    END IF; 
 ---------------------------------------------------------------------------------- 
  IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
  
--------------------------------------------------------------------------
    IF NOT ExtractData %ISOPEN THEN
      --{
      BEGIN
        --{
        OPEN ExtractData  (vi_StartDate ,vi_EndDate ,vi_service_type ,vi_checktype,vi_zonecode, vi_branchCode);
        --}
      END;
      --}
    END IF;
    IF ExtractData %ISOPEN THEN
      --{
      FETCH ExtractData 
      INTO   v_service_id, 
        v_AccountNumber ,
        v_cif_id,
        v_status,
        v_Transaction_Date ,
        v_cur_code ,
        v_CustomerName ,
        v_Bill_Amount ,
        v_total_service_charges ,
        v_total_amount,
        v_OpenBranch ,
        v_phone_no  ;
    
       

     
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
  
  BEGIN
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
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
    end if;
  END;
  -------------------------------------------------------------------------------------------------------------------
  out_rec := ( 
             v_service_id || '|' ||       
            v_AccountNumber  || '|' || 
             v_cif_id || '|' || 
        v_status || '|' || 
            TO_CHAR(to_date(v_Transaction_Date ,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' ||
            v_cur_code  || '|' || 
            v_CustomerName  || '|' ||
            v_Bill_Amount  || '|' || 
            v_total_service_charges  || '|' ||
            v_total_amount || '|' || 
            SUBSTR(v_OpenBranch  ,1,3)|| '|' ||
            v_phone_no   || '|' || 
            v_BranchName || '|' || 
            v_BankAddress || '|' || 
            v_BankPhone || '|' || 
            v_BankFax);
  dbms_output.put_line(out_rec);
END FIN_BILL_PAYMENT;
END FIN_BILL_PAYMENT;
/
