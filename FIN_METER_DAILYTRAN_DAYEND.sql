CREATE OR REPLACE PACKAGE        FIN_METER_DAILYTRAN_DAYEND AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  PROCEDURE FIN_METER_DAILYTRAN_DAYEND(  inp_str      IN  VARCHAR2,
                                          out_retCode  OUT NUMBER,
                                          out_rec      OUT VARCHAR2 );

END FIN_METER_DAILYTRAN_DAYEND;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                FIN_METER_DAILYTRAN_DAYEND
AS
  -------------------------------------------------------------------------------------
  --Update User --Saung Hnin OO--------------------------------------
  --Update Date ---2-5-2017--------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType ; -- Input Parse Array
  vi_startDate  VARCHAR2(10);         -- Input to procedure
  vi_endDate    VARCHAR2(10);         -- Input to procedure
  vi_serviceType  VARCHAR2(10); 
  vi_user_id  VARCHAR2(15);                 -- Input to procedure
  vi_branchCode VARCHAR2(5);          -- Input to procedure
 -- vi_zoneCode   VARCHAR(6);           -- Input to procedure
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
  pyst.bill_details_idx               AS "ServiceNo",
  gam.foracid                         AS "AccounttNumber",
  pyht.bill_amt                       AS "BillAmount",
  0.00                                AS "BankCharges",
  0.00                                AS "HostingCharges",
  pyht.charge_amt                     AS "ServiceCharges",
  pyht.bill_date                      AS "BillDate",
  0.00                                AS "DueCharges"
FROM tbaadm.gam gam ,
  tbaadm.pyst pyst,
  tbaadm.pyht pyht
WHERE pyst.transfer_acid = gam.acid
AND pyst.subscription_id         = pyht.subscription_id 
and pyht.bill_status = 'P'
and pyht.rcre_user_id = upper(ci_user_id)
AND pyht.biller_id LIKE '%' || upper(ci_serviceType) || '%' 
AND pyht.bill_date BETWEEN TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
AND gam.sol_id LIKE '%'|| ci_branchCode ||'%'
--AND SUBSTR(pyst.BILL_DETAILS_MANDATE, instr(pyst.BILL_DETAILS_MANDATE, '=', 1, 2)+1, instr(pyst.BILL_DETAILS_MANDATE, ';', 1, 2) - instr(pyst.BILL_DETAILS_MANDATE, '=', 1, 2)-1 ) LIKE '%'|| '' ||'%' 
ORDER BY pyht.bill_date;

PROCEDURE FIN_METER_DAILYTRAN_DAYEND(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
 v_ServiceNo TBAADM.pyst.bill_details_idx%type;
  v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  --v_BillMonth crbd.billmonth%type;
  v_BillAmount TBAADM.ppmt.bill_amt%type;
  v_BankCharges    DECIMAL;
  v_HostingCharges DECIMAL;
  v_ServiceCharges  TBAADM. pyht.charge_amt%type;
  v_bill_date tbaadm.pyht.bill_date%type;
  v_DueCharges DECIMAL;
  --v_TotalAmount txnd.total_entry_amt%type;
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
  vi_startDate  := outArr(0);
  vi_endDate    := outArr(1);
  vi_serviceType := outArr(2);
  vi_user_id    :=outArr(3);
  vi_BranchCode := outArr(4);
  
  -------------------------------------------------------------------
 IF vi_serviceType ='MPT' then
       vi_serviceType := 'MPT';
 ELSif    vi_serviceType ='MOEP' then
        vi_serviceType := 'MOEP';
         ELSif    vi_serviceType ='REDLINK' then
        vi_serviceType := 'REDLINK';
       ELSif    vi_serviceType ='ADSL' then
        vi_serviceType := 'ADSL';
        ELSE  vi_serviceType := '';
    END IF;
    ---------------------------------------------------------
    IF vi_serviceType IS NULL OR vi_serviceType = '' THEN
   vi_serviceType  := '';
  END IF;
    
    ------------------------------------------------------------
    
     IF vi_BranchCode IS  NULL or vi_BranchCode = ''  THEN
         vi_BranchCode := '';
    END IF; 
  
 
        IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (
			vi_startDate , vi_endDate , vi_serviceType ,vi_user_id,vi_BranchCode );
			--}
			END;

		--}
		END IF;

    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	
       v_ServiceNo,
      v_AccountNumber,
      v_BillAmount,
      v_BankCharges,
      v_HostingCharges,
      v_ServiceCharges,
      v_bill_date,
      v_DueCharges;


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
    if vi_BranchCode is not null then 
    
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
   v_ServiceNo || '|' || 
  v_AccountNumber || '|' ||
  v_BillAmount|| '|' || 
  v_BankCharges || '|' ||
  v_HostingCharges || '|' || 
  v_ServiceCharges || '|' ||
  TO_CHAR(to_date(v_bill_date,'dd/Mon/yy'), 'dd/MM/yyyy')|| '|' || 
  v_DueCharges || '|' ||
  v_BranchName || '|' || 
  v_BankAddress || '|' || 
  v_BankPhone || '|' ||
  v_BankFax );
  dbms_output.put_line(out_rec);
END FIN_METER_DAILYTRAN_DAYEND;
END FIN_METER_DAILYTRAN_DAYEND;
/
