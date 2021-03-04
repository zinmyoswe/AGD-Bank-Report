CREATE OR REPLACE PACKAGE        FIN_BILL_REGISTERED_DATA AS

PROCEDURE FIN_BILL_REGISTERED_DATA(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BILL_REGISTERED_DATA;


/


CREATE OR REPLACE PACKAGE BODY                                                                                                  FIN_BILL_REGISTERED_DATA AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  -- Update user -     Saung Hnin OO
  -- Update Date -     11-5-2017
----------------------------------------------------------------------------------

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_billerId	   	Varchar2(10);               -- Input to procedure
  vi_auto_pay_type Varchar2(20);               -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_billerId VARCHAR2,ci_auto_pay_type VARCHAR2 ,ci_branchCode VARCHAR2 )
  IS
SELECT DISTINCT
 bill_details_mandate AS "Bill Details Mandate",
 biller_id AS "Biller ID",
 biller_service_id AS "Biller Service ID",
 subscription_id AS "Subscription ID",
 subscr_start_date AS "Subscription Start Date",
 subscr_end_date AS "Subscription End Date",
 pyst.del_flg AS "Subscription Verification Flag",
 gam.cif_id AS "CIF ID", 
accounts.strfield2 AS "Phone No",
 gam.acct_name AS "Account Name",
(select gam.foracid from tbaadm.gam where pyst.transfer_acid=gam.acid)  AS "Account ID",
 auto_pay_flg  AS "Auto Pay Flag",
 pyst.free_code1 AS "Priority",
 pyst.free_text1 AS "Owner name",
 pyst.free_text2 AS "Ledger NO",
 pyst.free_text3 AS "Tariff",
 pyst.free_text4 AS "free_text4"
FROM tbaadm.pyst pyst ,  CRMUSER.accounts accounts  , tbaadm.gam gam
where
gam.cust_id = pyst.cust_id
and  accounts.core_cust_id =gam.cust_id 
and biller_id like '%' || upper(ci_billerId) || '%'
AND gam.sol_id like '%' || ci_branchCode || '%'
and pyst.AUTO_PAY_FLG like '%' || upper(ci_auto_pay_type) || '%'
AND trim(pyst.lchg_time) between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
--AND gam.DEL_FLG      = 'N'
AND pyst.DEL_FLG     = 'N'
AND gam.bank_id      = '01'
AND pyst.bank_id     = '01' 
ORDER BY bill_details_mandate ASC  ;

  PROCEDURE FIN_BILL_REGISTERED_DATA(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    v_BillDetailMandate TBAADM.PAYER_SUBSCRIPTION_TABLE.BILL_DETAILS_MANDATE%type;
    v_BillerId TBAADM.PAYER_SUBSCRIPTION_TABLE.BILLER_ID%type;
    v_BillerServiceId TBAADM.PAYER_SUBSCRIPTION_TABLE.BILLER_SERVICE_ID%type;
    v_SubscriptionId TBAADM.PAYER_SUBSCRIPTION_TABLE.SUBSCRIPTION_ID%type;
    v_SubscriptionStartDate TBAADM.PAYER_SUBSCRIPTION_TABLE.SUBSCR_START_DATE%type;
    v_SubscriptionEndDate TBAADM.PAYER_SUBSCRIPTION_TABLE.SUBSCR_END_DATE%type;
    v_SubscriptionVerificationFlag TBAADM.pyst.subscr_verify_flg%type;
   
    v_CIF_ID TBAADM.GENERAL_ACCT_MAST_TABLE.CIF_ID%type;
	  v_Txt1 CRMUSER.accounts.strfield2%type;
	  v_Txt2 TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_Txt3 TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
	  v_Txt4 TBAADM.PAYER_SUBSCRIPTION_TABLE.AUTO_PAY_FLG%type;
    v_Priority TBAADM.pyst.free_code1%type;
    v_Owner_Name TBAADM.pyst.free_text1%type;
    v_Ledger_No TBAADM. pyst.free_text2%type;
    v_Tariff    TBAADM.pyst.free_text3%type;
     v_free_text4 TBAADM.pyst.free_text4%type;
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
		out_rec := NULL;

     tbaadm.basp0099.formInputArr(inp_str, outArr);

    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------

	  vi_startDate  :=  outArr(0);
    vi_endDate    :=  outArr(1);
    vi_billerId :=  outArr(2);
    vi_auto_pay_type :=  outArr(3);
    vi_branchCode :=  outArr(4);


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

    ------------------------------------------------------
     IF vi_auto_pay_type ='Yes' then
       vi_auto_pay_type := 'Y';
 ELSif    vi_auto_pay_type ='No' then
        vi_auto_pay_type := 'N';
       ELSE
        vi_auto_pay_type := '' ;
    END IF;

  -----------------------------------------------------------------------------
    IF vi_billerId IS NULL OR vi_billerId = '' THEN
   vi_billerId  := '';
  END IF;


    IF vi_branchCode IS NULL OR vi_branchCode = '' THEN
   vi_branchCode  := '';
  END IF;

  ----------------------------------------------------------------


        IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (
			vi_startDate , vi_endDate , vi_billerId ,vi_auto_pay_type,vi_branchCode );
			--}
			END;

		--}
		END IF;

    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_BillDetailMandate,v_BillerId,v_BillerServiceId,v_SubscriptionId,
            v_SubscriptionStartDate,v_SubscriptionEndDate,v_SubscriptionVerificationFlag
			,v_CIF_ID,v_Txt1,v_Txt2,v_Txt3,v_Txt4,v_Priority,v_Owner_Name,v_Ledger_No,v_Tariff,v_free_text4;


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
    if vi_branchCode is not null then
      select
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
         end if;
    END;


    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
      v_BillerId     			|| '|' ||
		  v_BillerServiceId	            || '|' ||
      v_SubscriptionId              || '|' ||
      trim(to_char(to_date(v_SubscriptionStartDate,'dd/Mon/yy'), 'dd-MM-yyyy')  )      			      || '|' ||
      trim(to_char(to_date(v_SubscriptionEndDate,'dd/Mon/yy'), 'dd-MM-yyyy')  )     			|| '|' ||
      v_SubscriptionVerificationFlag    			    || '|' ||
      v_BillDetailMandate    			      || '|' ||
      v_CIF_ID                || '|' ||
      v_Txt1             || '|' ||
		  v_Txt2             || '|' ||
		  v_Txt3             || '|' ||
		  v_Txt4             || '|' ||
      v_Priority            || '|' ||
      v_Owner_Name   || '|' ||
      v_Ledger_No || '|' ||
      v_Tariff  || '|' ||
      v_free_text4 || '|' ||
		  v_BranchName	            || '|' ||
		  v_BankAddress      			  || '|' ||
		  v_BankPhone               || '|' ||
      v_BankFax );

			dbms_output.put_line(out_rec);

  END FIN_BILL_REGISTERED_DATA;

END FIN_BILL_REGISTERED_DATA;
/
