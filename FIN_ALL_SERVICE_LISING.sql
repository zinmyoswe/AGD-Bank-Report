CREATE OR REPLACE PACKAGE                      FIN_ALL_SERVICE_LISING AS 

   PROCEDURE FIN_ALL_SERVICE_LISING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ALL_SERVICE_LISING;
 
/


CREATE OR REPLACE PACKAGE BODY                      FIN_ALL_SERVICE_LISING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_accountno	   	Varchar2(3);              -- Input to procedure
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_accountno VARCHAR2)
  IS
  select 
  gam.foracid as "AccountNumber",
  gam.acct_name as "AcountName",
  address.address_line1 || 
  address.address_line2 || 
  address.address_line3 || 
  address.city || 
  address.state || 
  address.country as "Address",
  gam.acct_opn_date as "OpenDate",
  pe.phoneno as "PhoneNumber",
  address.faxnolocalcode||
  address.faxnocountrycode||
  address.faxnocitycode||
  address.faxno as "FaxNumber"

from 
  tbaadm.general_acct_mast_table gam,
  CRMUSER.address address,
  crmuser.phoneemail pe
where 
  gam.schm_type=UPPER(ci_SchemeType)
  and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg = 'N'
  and gam.acct_cls_flg = 'N'
  and gam.bank_id ='01'
  and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
  and pe.PHONEOREMAIL  = 'PHONE'
  AND PE.PREFERREDFLAG = 'Y'
  and gam.acct_crncy_code = UPPER(ci_currency)
  and gam.SOL_ID  = ci_branchCode
  and gam.cif_id     = address.orgkey
  and pe.orgkey = gam.cif_id 
  order by 
    gam.acct_opn_date ASC,gam.foracid asc  ;
  
  PROCEDURE FIN_ALL_SERVICE_LISING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_Address varchar2(100);
    v_OpenDate tbaadm.general_acct_mast_table.acct_opn_date%type;
     v_PhoneNumber varchar2(50);
    v_FaxNumber varchar2(20);
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
    vi_branchCode :=  outArr(2);	
    vi_SchemeType	:=  outArr(3);
    vi_currency   :=  outArr(4);
   
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode , 
      vi_SchemeType ,vi_currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_AccountNumber,v_AccountName,
            v_Address,v_OpenDate,v_PhoneNumber,v_FaxNumber;
      

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
    END;
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_AccountNumber     			|| '|' ||
					v_AccountName	|| '|' ||
					v_Address      			|| '|' ||
          to_char(to_date(v_OpenDate,'dd/Mon/yy'), 'dd/MM/yyyy')      			|| '|' ||
          v_PhoneNumber    			|| '|' ||
          v_FaxNumber    			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_ALL_SERVICE_LISING;

END FIN_ALL_SERVICE_LISING;
/
