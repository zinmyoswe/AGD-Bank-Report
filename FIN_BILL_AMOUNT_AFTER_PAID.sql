CREATE OR REPLACE PACKAGE                FIN_BILL_AMOUNT_AFTER_PAID AS 

   PROCEDURE FIN_BILL_AMOUNT_AFTER_PAID(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BILL_AMOUNT_AFTER_PAID;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                              FIN_BILL_AMOUNT_AFTER_PAID AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType ;  -- Input Parse Array
  vi_tranDate		  Varchar2(10);		    	    -- Input to procedure
  vi_BranchCode		Varchar2(5);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (ci_tranDate VARCHAR2,ci_branchCode VARCHAR2)
  IS
  
select gam.foracid as AccountNo,
cusr.salutation || cusr.c_f_name || cusr.c_m_name || cusr.c_l_name as customername,
gam.ACCT_CRNCY_CODE as cur,
gam.CLR_BAL_AMT as CurrentBalance,
'',--txnh.total_amt as BillAmount,
'' as TotalAmount,
cusr.c_m_phone_no as PhoneNo,
cusr.c_email_id as Email,
gam.SOL_ID as OpenBranch
from 
ececuser.CORPORATE_USER@RPTLINK cusr
--inner join ececuser.TRANSACTION_HEADER@rptlink txnh on cusr.org_id = txnh.corp_id
inner join tbaadm.gam gam on gam.cif_id = cusr.cust_id
where 
user_type not like 4 --default user (for system start)
and cusr.org_id not like '01'
and cusr.del_flg = 'N'
and cusr.bank_id = '01' --for operator
and gam.bank_id = '01'
and gam.del_flg = 'N'
and gam.acct_cls_flg = 'N'
--and txnh.del_flg = 'N'
--and txnh.bank_id = '01'
--and txnh.txn_date = TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.sol_id = ci_branchCode
order by gam.foracid asc  ;
  
  PROCEDURE FIN_BILL_AMOUNT_AFTER_PAID(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_Cur varchar2(5);
    v_CurrentBalance tbaadm.general_acct_mast_table.clr_bal_amt%type;
    v_BillAmount tbaadm.general_acct_mast_table.clr_bal_amt%type;
    v_TotalAmount tbaadm.general_acct_mast_table.clr_bal_amt%type;
    v_PhoneNo varchar2(50);
    v_Email varchar2(20);
    v_OpenBranch varchar2(10);
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
   		
    vi_tranDate    :=  outArr(0);		
    vi_BranchCode :=  outArr(1);
   
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_tranDate , vi_BranchCode );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_AccountNumber,v_AccountName,v_Cur,v_CurrentBalance,v_BillAmount,v_TotalAmount,
            v_PhoneNo,v_Email,v_OpenBranch;
      

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
          v_AccountNumber	|| '|' ||v_AccountName || '|' ||
          v_Cur|| '|' || v_CurrentBalance	|| '|' ||
          v_BillAmount		|| '|' ||v_TotalAmount		|| '|' ||
          v_PhoneNo		|| '|' ||v_Email		|| '|' ||v_OpenBranch|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_BILL_AMOUNT_AFTER_PAID;

END FIN_BILL_AMOUNT_AFTER_PAID;
/
