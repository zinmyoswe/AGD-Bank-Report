CREATE OR REPLACE PACKAGE                      FIN_ONLINE_BILL_PAYMENT AS 

   PROCEDURE FIN_ONLINE_BILL_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ONLINE_BILL_PAYMENT;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                           FIN_ONLINE_BILL_PAYMENT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2 )
  IS
select 
txnh.txn_id as TransactionID,gam.foracid as AccountNo,
cusr.salutation || cusr.c_f_name || cusr.c_m_name || cusr.c_l_name as Name,
txnh.total_txn_amt_in_homecrn as Amount,
TO_TIMESTAMP (txnh.request_date, 'DD-Mon-RR HH24:MI:SS.FF') as Time
from
ececuser.CORPORATE_USER@RPTLINK cusr
inner join tbaadm.gam gam on cusr.cust_id = gam.cif_id
inner join ececuser.TRANSACTION_HEADER@RPTLINK txnh on cusr.user_id = txnh.corp_user
and txnh.corp_id = cusr.org_id
where gam.sol_id = ci_branchCode
AND txnh.request_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.DEL_FLG      = 'N'
    AND cusr.DEL_FLG     = 'N'
    AND txnh.DEL_FLG     = 'N'
    AND gam.bank_id      = '01'
    AND cusr.bank_id     = '01'
    AND txnh.bank_id     = '01'
    order by gam.foracid asc  ;
  
  PROCEDURE FIN_ONLINE_BILL_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_TransactionID ececuser.TRANSACTION_HEADER.TXN_ID%type;
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_Name ececuser.CORPORATE_USER.ACCT_NAME%type;
    v_Amount ececuser.TRANSACTION_HEADER.total_txn_amt_in_homecrn%type;
    v_Date ececuser.TRANSACTION_HEADER.request_date%type;
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
   
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_AccountNumber,v_Name,
            v_Amount,v_Time;
      

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
          v_TransactionID     			|| '|' ||
          v_AccountNumber     			|| '|' ||
					v_Name	|| '|' ||
					v_Amount      			|| '|' ||
          to_char(to_date(v_Date,'dd/Mon/yy'), 'dd/MM/yyyy')      			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_ONLINE_BILL_PAYMENT;

END FIN_ONLINE_BILL_PAYMENT;
/
