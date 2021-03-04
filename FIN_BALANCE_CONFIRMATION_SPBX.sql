CREATE OR REPLACE PACKAGE                                                         FIN_BALANCE_CONFIRMATION_SPBX AS 

  PROCEDURE FIN_BALANCE_CONFIRMATION_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BALANCE_CONFIRMATION_SPBX;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                FIN_BALANCE_CONFIRMATION_SPBX AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  outArr			tbaadm.basp0099.ArrayType;     -- Input Parse Array
	vi_accountNo   	Varchar2(20);              -- Input to procedure

  CURSOR ExtractData (ci_accountNo   	Varchar2)
  IS
  select 
       GENERAL_ACCT_MAST_TABLE.FORACID as "Account Id" , 
       GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT as "Balance",
       GENERAL_ACCT_MAST_TABLE.SOL_ID as "branchCode",
       ACCOUNTS.SALUTATION as "Salutation",
       ACCOUNTS.CUST_FIRST_NAME as "First Name",
       ACCOUNTS.CUST_MIDDLE_NAME as "Middle Name",
       ACCOUNTS.CUST_LAST_NAME as "Last Name",
       ACCOUNTS.UNIQUEID as "Unique Id",
       ADDRESS.ADDRESS_LINE1 as "Address1",
       ADDRESS.ADDRESS_LINE2 as "Address2",
       ADDRESS.CITY ||','|| address.country ||','|| address.zip as "Address3",
       GENERAL_ACCT_MAST_TABLE.Acct_crncy_code as "Currency"
       --INTO
      -- v_accountNo, v_amount, v_branchCode, v_saluation,
      -- v_firstName, v_middleName, v_lastName, v_uniqueId,
      -- v_address1, v_address2, v_address3
      from 
         TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE,
         CRMUSER.ACCOUNTS ACCOUNTS,
         CRMUSER.ADDRESS ADDRESS
      where
         GENERAL_ACCT_MAST_TABLE.CIF_ID = ACCOUNTS.ORGKEY 
         AND ACCOUNTS.ORGKEY = ADDRESS.ORGKEY
         --AND ADDRESS.ADDRESSCATEGORY LIKE '%Mailing%'
         AND GENERAL_ACCT_MAST_TABLE.FORACID = ci_accountNo 
         and GENERAL_ACCT_MAST_TABLE.Bank_id = '01'
         and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N' 
         and GENERAL_ACCT_MAST_TABLE.del_flg = 'N';
         
  PROCEDURE FIN_BALANCE_CONFIRMATION_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
     v_accountNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
     v_amount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
     v_branchCode TBAADM.GENERAL_ACCT_MAST_TABLE.SOL_ID%type;
     v_saluation CRMUSER.ACCOUNTS.SALUTATION%type;
     v_firstName CRMUSER.ACCOUNTS.CUST_FIRST_NAME%type;
     v_middleName CRMUSER.ACCOUNTS.CUST_MIDDLE_NAME%type;
     v_lastName CRMUSER.ACCOUNTS.CUST_LAST_NAME%type;
     v_uniqueId CRMUSER.ACCOUNTS.UNIQUEID%type;
     v_address1 CRMUSER.ACCOUNTS.ADDRESS_LINE1%type;
     v_address2 CRMUSER.ACCOUNTS.ADDRESS_LINE2%type;
     v_address3 CRMUSER.ACCOUNTS.ADDRESS_LINE3%type;
     v_branchShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
     v_bankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
     v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
     v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
     v_currency TBAADM.GENERAL_ACCT_MAST_TABLE.Acct_crncy_code%TYPE;
      
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
    vi_accountNo := outArr(0);
 
 --------------------------------------------------------------------------------------------------
 if( vi_accountNo is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||'-' || '|' ||
                     '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||'-'|| '|' || '-' || '|' ||'-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 --------------------------------------------------------------------------------------------------
      IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_accountNo);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_accountNo , v_amount ,v_branchCode , v_saluation , 
       v_firstName ,v_middleName , v_lastName, 
       v_uniqueId, v_address1, v_address2, v_address3,v_currency;
      

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
      
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
      select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "BankAddress",
         BRANCH_CODE_TABLE.PHONE_NUM as "BankPhone",
         BRANCH_CODE_TABLE.FAX_NUM as "BankFax"
         INTO
         v_branchShortName, v_bankAddress, v_bankPhone, v_bankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = v_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(v_accountNo      			|| '|' ||
          v_amount     			|| '|' ||
          v_branchCode     			|| '|' ||
          v_saluation      			|| '|' ||
					v_firstName	|| '|' ||
					v_middleName      			|| '|' ||
					v_lastName      			|| '|' ||
          v_uniqueId      			|| '|' ||
          v_address1      			|| '|' ||
          v_address2      			|| '|' ||
          v_address3      			|| '|' ||
					v_branchShortName	|| '|' ||
					v_bankAddress      			|| '|' ||
					v_bankPhone || '|' ||
          v_bankFax || '|' ||
          v_currency);
			dbms_output.put_line(out_rec);
     -- dbms_output.put_line(out_retCode);
  END FIN_BALANCE_CONFIRMATION_SPBX;

END FIN_BALANCE_CONFIRMATION_SPBX;
/
