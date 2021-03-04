CREATE OR REPLACE PACKAGE                                           FIN_TERM_DEPOSIT_BY_DURATION AS 

  PROCEDURE FIN_TERM_DEPOSIT_BY_DURATION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_TERM_DEPOSIT_BY_DURATION;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_TERM_DEPOSIT_BY_DURATION AS

  -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure

  vi_duration		Varchar2(5);		    	    -- Input to procedure
  vi_transaction_date Varchar2(10);
    vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_entryUserId	Varchar2(20);		    	    -- Input to procedure
  
  -----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
  CURSOR ExtractData (	 ci_duration VARCHAR2,ci_branchCode VARCHAR2, 
      ci_currency VARCHAR2,ci_transaction_date VARCHAR2)
  IS
  
  select 
   GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Name" ,  
   TD_ACCT_MASTER_TABLE.DEPOSIT_AMOUNT as "Balance",
   TD_ACCT_MASTER_TABLE.OPEN_EFFECTIVE_DATE,
   TD_ACCT_MASTER_TABLE.MATURITY_DATE,
   GENERAL_ACCT_MAST_TABLE.acct_opn_date as "Transaction Date"
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE , 
   TBAADM.TD_ACCT_MASTER_TABLE TD_ACCT_MASTER_TABLE 
where
   GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
   and TD_ACCT_MASTER_TABLE.DEPOSIT_PERIOD_MTHS = ci_duration
   and GENERAL_ACCT_MAST_TABLE.acct_opn_date <= TO_DATE( CAST ( ci_transaction_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and GENERAL_ACCT_MAST_TABLE.ACID = TD_ACCT_MASTER_TABLE.ACID 
   and GENERAL_ACCT_MAST_TABLE.ACCT_CLS_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.BANK_ID = '01'
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)
   
   order by GENERAL_ACCT_MAST_TABLE.FORACID desc,
    TD_ACCT_MASTER_TABLE.MATURITY_DATE desc;
    
CURSOR ExtractData_All(	 ci_branchCode VARCHAR2, 
      ci_currency VARCHAR2,ci_transaction_date VARCHAR2)
  IS
  
  select 
   GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Name" ,  
   TD_ACCT_MASTER_TABLE.DEPOSIT_AMOUNT as "Balance",
   TD_ACCT_MASTER_TABLE.OPEN_EFFECTIVE_DATE,
   TD_ACCT_MASTER_TABLE.MATURITY_DATE,
   GENERAL_ACCT_MAST_TABLE.acct_opn_date as "Transaction Date"
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE , 
   TBAADM.TD_ACCT_MASTER_TABLE TD_ACCT_MASTER_TABLE 
where
   GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
   --and TD_ACCT_MASTER_TABLE.DEPOSIT_PERIOD_MTHS = ci_duration
   and GENERAL_ACCT_MAST_TABLE.acct_opn_date <=  TO_DATE( CAST ( ci_transaction_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and GENERAL_ACCT_MAST_TABLE.ACID = TD_ACCT_MASTER_TABLE.ACID 
   and GENERAL_ACCT_MAST_TABLE.ACCT_CLS_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N'
   and GENERAL_ACCT_MAST_TABLE.BANK_ID = '01'
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)   
   order by GENERAL_ACCT_MAST_TABLE.FORACID desc,
    TD_ACCT_MASTER_TABLE.MATURITY_DATE desc;

  PROCEDURE FIN_TERM_DEPOSIT_BY_DURATION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
      v_accountNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_name TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_transaction_date TBAADM.GENERAL_ACCT_MAST_TABLE.acct_opn_date%type;
      v_branchShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
      v_depositAmount TBAADM.TD_ACCT_MASTER_TABLE.DEPOSIT_AMOUNT%type;
      v_assignDate TBAADM.TD_ACCT_MASTER_TABLE.OPEN_EFFECTIVE_DATE%type;
      v_maturity TBAADM.TD_ACCT_MASTER_TABLE.MATURITY_DATE%type;
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
     vi_duration := outArr(0);
   	
    vi_transaction_date :=outArr(1);
    vi_currency :=outArr(2); 
     vi_branchCode :=outArr(3);
   
    --vi_entryUserId	:=outArr(6);
    ---------------------------------------------------------------------------------------
    if( vi_transaction_date is null or vi_currency is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    
    -----------------------------------------------------------------------------------
   
   IF  vi_duration = 'All' then
    IF NOT ExtractData_All%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All (	vi_branchCode , vi_currency,vi_transaction_date);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All%ISOPEN THEN
		--{
			FETCH	ExtractData_All
			INTO	v_accountNo, v_name, v_depositAmount, 
            v_assignDate, v_maturity,v_transaction_date;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All%NOTFOUND THEN
			--{
				CLOSE ExtractData_All;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
    ELSE -----------------Other duration 1/3/6/9/12
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_duration , vi_branchCode ,
          
          vi_currency,vi_transaction_date);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_accountNo, v_name, v_depositAmount, 
            v_assignDate, v_maturity,v_transaction_date;
      

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
    
    End if;
    
    
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
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE;
    END;
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(trim(v_accountNo)   			|| '|' ||
					trim(v_name)	|| '|' ||
					v_branchShortName      			|| '|' ||
					v_depositAmount	|| '|' ||
          to_char(to_date(v_assignDate,'dd/Mon/yy'), 'dd/MM/yyyy')	|| '|' ||
          to_char(to_date(v_maturity,'dd/Mon/yy'), 'dd/MM/yyyy')	|| '|' ||
          to_char(to_date(v_transaction_date,'dd/Mon/yy'), 'dd/MM/yyyy')	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_bankPhone || '|' ||
          v_bankFax );
  
			dbms_output.put_line(out_rec);
  END FIN_TERM_DEPOSIT_BY_DURATION;

END FIN_TERM_DEPOSIT_BY_DURATION;
/
