CREATE OR REPLACE PACKAGE               FIN_AUTO_CURRENT_LINK_CREDIT AS 

  PROCEDURE FIN_AUTO_CURRENT_LINK_CREDIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_AUTO_CURRENT_LINK_CREDIT;
 
/


CREATE OR REPLACE PACKAGE BODY                                                         FIN_AUTO_CURRENT_LINK_CREDIT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
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
			 ci_branchCode VARCHAR2, ci_startDate VARCHAR2, ci_endDate VARCHAR2,ci_currency VARCHAR2
      )
  IS
  select 
   GAM.FORACID as "Account No." , 
   GAM.ACCT_NAME as "Name" , 
   GAM.CLR_BAL_AMT as "Credit_Amount" , 
   CTD_DTD_ACLI_VIEW.TRAN_AMT as "Amount" , 
   CTD_DTD_ACLI_VIEW.TRAN_ID as "Transaction_Id" 
from 
   TBAADM.GAM GAM , 
   TBAADM.PFT PFT , 
   custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
where
  GAM.SOL_ID = ci_branchCode 
  and PFT.POOL_ID = GAM.pool_id
  and GAM.ACID = CTD_DTD_ACLI_VIEW.ACID 
  and GAM.del_flg = 'N'
  AND GAM.acct_cls_flg = 'N'
  and CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR like '%Sweep%'
  and CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ='C'
  and CTD_DTD_ACLI_VIEW.bank_id = '01'
  and CTD_DTD_ACLI_VIEW.pstd_flg = 'Y'
  and GAM.allow_sweeps = 'Y'
  and GAM.acct_crncy_code = upper(ci_currency )
  and CTD_DTD_ACLI_VIEW.tran_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  order by 
  GAM.FORACID;
  
  PROCEDURE FIN_AUTO_CURRENT_LINK_CREDIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    v_AccountNumber TBAADM.GAM.FORACID%type;
    v_AccountName TBAADM.GAM.ACCT_NAME%type;
    v_CreditAmount TBAADM.GAM.CLR_BAL_AMT%type;
    v_Amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_TransactionId TBAADM.CTD_DTD_ACLI_VIEW.TRAN_ID%type;
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
    
    
    vi_startDate :=outArr(0);		
    vi_endDate :=outArr(1);		
    vi_currency :=outArr(2);
 vi_branchCode :=outArr(3);  	
  
-------------------------------------------------------------------------------------
  
   if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||'-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
-------------------------------------------------------------------------------------------
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_branchCode, vi_startDate , vi_endDate,vi_currency   );
			--}
			END;

		--}
		END IF;
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_AccountNumber, v_AccountName, v_CreditAmount, v_Amount, 
            v_TransactionId;
      

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
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;

     -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(v_AccountNumber      			|| '|' ||
          v_AccountName       || '|' ||
          v_CreditAmount    			|| '|' ||
					v_Amount	|| '|' ||
					v_TransactionId     			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_AUTO_CURRENT_LINK_CREDIT;

END FIN_AUTO_CURRENT_LINK_CREDIT;
/
