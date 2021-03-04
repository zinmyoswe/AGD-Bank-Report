CREATE OR REPLACE PACKAGE        FIN_INSUFF_PHONE_BILL_PAYMENT AS

  PROCEDURE FIN_INSUFF_PHONE_BILL_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INSUFF_PHONE_BILL_PAYMENT;


/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                FIN_INSUFF_PHONE_BILL_PAYMENT
AS
  --------------------------------------------------------------------------------------
  --Update User -Saung Hnin OO--------------------------
  --Update Date - 22-5-2017-----------------------
  --count the Transaction
  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_StartDate        VARCHAR2(10);             -- Input to procedure
  vi_EndDate        VARCHAR2(10);             -- Input to procedure
  vi_service_type  VARCHAR2(15);                 -- Input to procedure
  vi_other_ServiceType  VARCHAR2(15);                 -- Input to procedure
  vi_user_id  VARCHAR2(15);                 -- Input to procedure
  vi_OtherUserID  VARCHAR2(15);                 -- Input to procedure
  vi_branchCode   VARCHAR2(5);              -- Input to procedure
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData_Multi
  -----------------------------------------------------------------------------
  CURSOR ExtractData ( ci_StartDate VARCHAR2,ci_EndDate VARCHAR2,ci_service_type VARCHAR2,
  ci_other_ServiceType VARCHAR2,
  ci_user_id VARCHAR2, ci_OtherUserID VARCHAR2, ci_branchCode VARCHAR2)
  IS
SELECT distinct
  pyst.bill_details_idx     AS ServiceNo,
  gam.FORACID               AS "AccountNumber" ,
 --count( gam.FORACID)       AS "Phone Record",
  pyht.Bill_date            AS "Tran_Date",
  pyht.bill_crncy_code      AS "Currency",
  accounts.name             AS "Customer Name",
 (SELECT AGDCOMMONPACK.geteffavailamtPool(gam.foracid) FROM dual) AS "Current Balance",
 ( pyht.Bill_amt +  adm.fixed_amt) AS "Total amt" ,
((AGDCOMMONPACK.geteffavailamtPool(gam.foracid)- ( pyht.Bill_amt +  adm.fixed_amt))) As "After Payment",
  pyht.Bill_amt             AS "bill amount",
  gam.sol_id                AS "Open Branch",
  accounts.strfield2        AS "Phone NO",
  adm.fixed_amt             AS "Charges amt"
FROM tbaadm.gam gam,
  tbaadm.pyst pyst,
  tbaadm.pyht pyht ,
  crmuser.accounts accounts,
  tbaadm.ptt ptt ,
  tbaadm.bsrt bsrt ,
  tbaadm.adm adm
WHERE pyst.subscription_id                        = pyht.subscription_id
AND bsrt.cust_charge_event_id                     = ptt.event_id
AND ptt.amt_derv_srl_num                          = adm.amt_drv_srl_num
AND pyst.biller_id                                = bsrt.biller_id
AND pyst.transfer_acid                            =gam.acid
AND accounts.orgkey                               = gam.cif_id
AND   ( agdcommonpack.geteffavailamtPool(gam.foracid))  < ( adm.fixed_amt + pyht.Bill_amt )
AND pyht.Bill_date                               >=TO_DATE( CAST (ci_StartDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' )     
AND pyht.Bill_date                            <= TO_DATE( CAST (ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' ) 
and (trim(pyht.rcre_user_id)   LIKE '%'||  upper(ci_user_id) ||'%' or trim(pyht.rcre_user_id)   LIKE '%'||  upper(ci_OtherUserID) ||'%' )
AND (pyht.biller_id LIKE '%'|| upper(ci_service_type) ||'%' or pyht.biller_id LIKE '%'|| upper(ci_other_ServiceType) ||'%')
AND gam.SOL_ID LIKE '%' || ci_branchCode ||'%'
and pyht.bill_status ='F'
AND ptt.event_type !='TRANF'
AND ptt.srl_num     = '1'
AND gam.del_flg     ='N'
AND pyst.del_flg    ='N'
AND gam.bank_id        ='01'
AND accounts.bank_id   ='01'
AND pyst.bank_id       ='01'
AND pyht.bank_id       ='01'
order by   gam.FORACID , pyst.bill_details_idx  ;

  ---------------------------------------------------------------------------------------------
PROCEDURE FIN_INSUFF_PHONE_BILL_PAYMENT(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_service_NO  TBAADM.pyst.bill_details_idx  %type;
  v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
 -- v_phone_record NUMBER(5);
  v_Transaction_Date TBAADM.pnpd.Bill_date %type ;
  v_cur_code TBAADM.pyht.bill_crncy_code  %type;
  v_CustomerName   CRMUSER.accounts.name    %type;
  v_cur_Balance integer;
  v_total_bal integer;
  v_after integer;
  v_Bill_Amount TBAADM.pyht.Bill_amt%type;
  v_OpenBranch TBAADM.GENERAL_ACCT_MAST_TABLE.SOL_ID%type;
  v_phone_no  CRMUSER.accounts.strfield2 %type;
  v_charges_amt Tbaadm.adm.fixed_amt%type;
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
  vi_EndDate              :=outArr(1);
  vi_service_type        :=outArr(2);
  vi_other_ServiceType   :=outArr(3);
  vi_user_id               :=outArr(4);
  vi_OtherUserID           :=outArr(5);
  vi_branchCode           :=outArr(6);
  
 -- SELECT AGDCOMMONPACK.geteffavailamtPool(gam.foracid) into str FROM dual;

  IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;

    IF vi_service_type IS  NULL or vi_service_type = ''  THEN
         vi_service_type := '';
    END IF;
    
    IF vi_user_id IS  NULL or vi_user_id = ''  THEN
         vi_user_id := '';
    END IF;
    
    IF vi_other_ServiceType IS  NULL or vi_other_ServiceType = ''  THEN
         vi_other_ServiceType := '';
    END IF;
    IF vi_OtherUserID IS  NULL or vi_OtherUserID = ''  THEN
         vi_OtherUserID := '';
    END IF;
----------------------------------------------------------------------
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
--------------------------------------------------------------------------
  IF vi_other_ServiceType ='MPT' then
       vi_other_ServiceType := 'MPT';
 ELSif    vi_other_ServiceType ='MOEP' then
        vi_other_ServiceType := 'MOEP';
         ELSif    vi_other_ServiceType ='REDLINK' then
        vi_other_ServiceType := 'REDLINK';
       ELSif    vi_other_ServiceType ='ADSL' then
        vi_other_ServiceType := 'ADSL';
        ELSE  vi_other_ServiceType := '';
    END IF;



-------------------------------------------------------------------------

    IF NOT ExtractData%ISOPEN THEN
      --{
      BEGIN
        --{
        OPEN ExtractData ( vi_StartDate , vi_EndDate ,vi_service_type , vi_other_ServiceType  ,vi_user_id , vi_OtherUserID ,        
  vi_branchCode);
        --}
      END;
      --}
    END IF;
    IF ExtractData%ISOPEN THEN
      --{
      FETCH ExtractData
      INTO  v_service_NO,
        v_AccountNumber,
     -- v_phone_record,
        v_Transaction_Date,
        v_cur_code,
        v_CustomerName,
        v_cur_Balance,
        v_total_bal,
        v_after,
        v_Bill_Amount,
        v_OpenBranch,
        v_phone_no,
        v_charges_amt;
       
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
     IF vi_branchCode IS not NULL then
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
    ENd if;
  END;
  
  out_rec :=             (     v_service_NO  || '|' ||
                             v_AccountNumber  || '|' ||
                            --  v_phone_record  || '|' ||
                               TO_CHAR(to_date(v_Transaction_Date,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' ||
                               v_cur_code  || '|' ||
                               v_CustomerName  || '|' ||
                             v_cur_Balance  || '|' ||
                               v_Bill_Amount  || '|' ||
                               v_total_bal || '|' ||
                               v_after || '|' ||
                                SUBSTR(v_OpenBranch,1,3)|| '|' ||
                                 v_phone_no  || '|' ||
                                 v_charges_amt || '|' ||
                               v_BranchName || '|' ||
                              v_BankAddress || '|' ||
                              v_BankPhone || '|' ||
                              v_BankFax);



  dbms_output.put_line(out_rec);
END FIN_INSUFF_PHONE_BILL_PAYMENT;
END FIN_INSUFF_PHONE_BILL_PAYMENT;
/
