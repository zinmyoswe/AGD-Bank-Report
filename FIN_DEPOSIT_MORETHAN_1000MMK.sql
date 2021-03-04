CREATE OR REPLACE PACKAGE                      FIN_DEPOSIT_MORETHAN_1000MMK AS 

 PROCEDURE FIN_DEPOSIT_MORETHAN_1000MMK(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
  
END FIN_DEPOSIT_MORETHAN_1000MMK;
/


CREATE OR REPLACE PACKAGE BODY                                    FIN_DEPOSIT_MORETHAN_1000MMK AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_SchemeCode		Varchar2(6);		    	    -- Input to procedure
   vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_entryUserId	Varchar2(20);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
  CURSOR ExtractData (	ci_currency VARCHAR2, 
      ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2, ci_branchCode VARCHAR2)
  IS
  
  select 
   GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Name" , 
   GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT as "Deposit Amt."
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE 
where
   GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode 
   and GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT > 1000 
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = UPPER(ci_SchemeType)
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = UPPER(ci_SchemeCode)
   and GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.ACCT_CLS_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.BANK_ID = '01'
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = UPPER(ci_currency);

  PROCEDURE FIN_DEPOSIT_MORETHAN_1000MMK(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
   v_accountNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
   v_name TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
   v_branchShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
   v_depositAmt TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
   v_bankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
   v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
   v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      
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
    
   	
    vi_SchemeType	:=outArr(0);	
    vi_SchemeCode	:=outArr(1);
    vi_currency :=outArr(2); 
     vi_branchCode :=outArr(3);
    --vi_entryUserId	:=outArr(6);
    
    ----------------------------------------------------------------------
    
    if( vi_SchemeType is null or vi_SchemeCode is null or vi_currency is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || 
		           '-' || '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    ---------------------------------------------------------------------
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_currency ,
           
          vi_SchemeType , vi_SchemeCode,vi_branchCode );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_accountNo, v_name, v_depositAmt;
      

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
         v_branchShortName, v_bankAddress, v_bankPhone, v_bankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
-----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------
    out_rec:=	(v_accountNo      			|| '|' ||
					v_name	|| '|' ||
					v_branchShortName      			|| '|' ||
					v_depositAmt	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_bankPhone || '|' ||
          v_bankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_DEPOSIT_MORETHAN_1000MMK;

END FIN_DEPOSIT_MORETHAN_1000MMK;
/
