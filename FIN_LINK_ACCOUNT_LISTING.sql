CREATE OR REPLACE PACKAGE                             FIN_LINK_ACCOUNT_LISTING AS 

 PROCEDURE FIN_LINK_ACCOUNT_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_LINK_ACCOUNT_LISTING;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                  FIN_LINK_ACCOUNT_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
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
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, 
      ci_currency VARCHAR2)
  IS
  select 
   GENERAL_ACCT_MAST_TABLE.POOL_ID as "Link ID" , 
   GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." ,
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Account Name" , 
   GENERAL_ACCT_MAST_TABLE.SCHM_CODE as "Scheme Code" , 
   GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT as "Current Amount" , 
   GENERAL_ACCT_MAST_TABLE.SWEEP_IN_MIN_BAL as "Current Min Bal" 
   from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE , 
   TBAADM.POOL_OF_FUNDS_TABLE POOL_OF_FUNDS_TABLE  
   WHERE POOL_OF_FUNDS_TABLE.POOL_ID = GENERAL_ACCT_MAST_TABLE.POOL_ID 
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode  
   --and POOL_OF_FUNDS_TABLE.RCRE_TIME >= TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   --and POOL_OF_FUNDS_TABLE.RCRE_TIME <= TO_DATE( CAST (ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and TRUNC(POOL_OF_FUNDS_TABLE.RCRE_TIME) between TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and TO_DATE( CAST (ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and GENERAL_ACCT_MAST_TABLE.DEL_FLG != 'Y' 
   and GENERAL_ACCT_MAST_TABLE.ACCT_CLS_FLG != 'Y' 
   and POOL_OF_FUNDS_TABLE.DEL_FLG != 'Y'
   and POOL_OF_FUNDS_TABLE.POOL_CLOSE_FLG != 'Y'
    and POOL_OF_FUNDS_TABLE.ENTITY_CRE_FLG = 'Y'
   and POOL_OF_FUNDS_TABLE.DEL_FLG = 'N'
    and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency);

  
  
  
  
  PROCEDURE FIN_LINK_ACCOUNT_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
   
    v_LinkId TBAADM.GENERAL_ACCT_MAST_TABLE.POOL_ID%type;
    v_AccountNumber tbaadm.GENERAL_ACCT_MAST_TABLE.FORACID %type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_SchmCode tbaadm.GENERAL_ACCT_MAST_TABLE.SCHM_CODE%type;
    v_CurrentAmount tbaadm.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
    v_CurrentMinBal tbaadm.GENERAL_ACCT_MAST_TABLE.SWEEP_IN_MIN_BAL%type;
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
    vi_branchCode :=  outArr(3);	
    vi_currency   :=  outArr(2);
  -------------------------------------------------------------------------
  
  if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		           0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' ||'-' || '|' || '-' );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  
  ----------------------------------------------------------------------------
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode , 
      vi_currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_LinkId,v_AccountNumber,v_AccountName,
            v_SchmCode,v_CurrentAmount,v_CurrentMinBal;
      

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
         BRANCH_CODE_TABLE.BR_ADDR_1 as "BankAddress",
         BRANCH_CODE_TABLE.PHONE_NUM as "BankPhone",
         BRANCH_CODE_TABLE.FAX_NUM as "BankFax"
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
          v_LinkId     			|| '|' ||
          trim(v_AccountNumber)  || '|' ||
					v_AccountName	|| '|' ||
					v_SchmCode      			|| '|' ||
          v_CurrentAmount     || '|' ||
          v_CurrentMinBal      || '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_LINK_ACCOUNT_LISTING;

END FIN_LINK_ACCOUNT_LISTING;
/
