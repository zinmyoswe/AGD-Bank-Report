CREATE OR REPLACE PACKAGE FIN_ACCRUAL_BALANCE_TEST AS 


   PROCEDURE FIN_ACCRUAL_BALANCE_TEST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ACCRUAL_BALANCE_TEST;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                  FIN_ACCRUAL_BALANCE_TEST AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	VARCHAR2(10);              -- Input to procedure
--	vi_startDate		Varchar2(10);		    	    -- Input to procedure
 -- vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		VARCHAR2(10);		    	    -- Input to procedure
  vi_SchemeType		VARCHAR2(10);		    	    -- Input to procedure
  Vi_Schemecode   Varchar2(10);              -- Input to procedure
  Vi_Producttype Varchar2(50); 

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractDataPay for Payable Customer balance
-----------------------------------------------------------------------------
CURSOR ExtractDataRec (	
			ci_branchCode VARCHAR2, 
      ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,ci_currency VARCHAR2)
  IS
        SELECT
         EIT.NRML_INTEREST_AMOUNT_DR AS AccuredCR ,
       --EIT.NRML_ACCRUED_AMOUNT_CR AS AccuredDR , 
         round(EIT.NRML_ACCRUED_AMOUNT_DR,2) AS AccuredDR ,  
         GAM.ACCT_NAME as "Account_Name" , 
         GAM.FORACID as "Account_ID",
         EIT.LAST_ACCRUAL_RUN_DATE_DR,
          gam.acct_opn_date
        
      FROM
         TBAADM.EIT EIT , 
         TBAADM.GAM GAM 
      WHERE
         EIT.ENTITY_ID = GAM.ACID 
         --and EIT.LAST_ACCRUAL_RUN_DATE_DR BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --and EIT.ACCRUED_UPTO_DATE_DR BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         and GAM.SCHM_TYPE  LIKE '%' ||UPPER(ci_SchemeType) || '%' 
         and GAM.SOL_ID LIKE '%' ||ci_branchCode || '%' 
         and gam.schm_code LIKE '%' ||UPPER(ci_SchemeCode) || '%'
         And Gam.Acct_Crncy_Code = Upper(Ci_Currency)
         And Eit.Nrml_Interest_Amount_Dr <> 0 
         and EIT.NRML_ACCRUED_AMOUNT_DR <> 0
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         order by GAM.FORACID;
         
            
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractDataRec for Receivable Customer balance
-----------------------------------------------------------------------------
CURSOR ExtractDataPay (	
			 ci_branchCode VARCHAR2, 
      Ci_Schemetype Varchar2,Ci_Schemecode Varchar2,Ci_Currency Varchar2)
  IS
        Select
         round(EIT.NRML_ACCRUED_AMOUNT_CR,2) AS AccuredCR , 
          --EIT.NRML_ACCRUED_AMOUNT_DR AS AccuredCR ,
         EIT.NRML_INTEREST_AMOUNT_CR AS AccuredDR ,  
         GAM.ACCT_NAME as "Account_Name" , 
         GAM.FORACID as "Account_ID",
         EIT.LAST_ACCRUAL_RUN_DATE_CR,
          gam.acct_opn_date
        
      FROM
         TBAADM.EIT EIT , 
         TBAADM.GAM GAM 
      WHERE
         EIT.ENTITY_ID = GAM.ACID 
         --and EIT.LAST_ACCRUAL_RUN_DATE_CR BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --a--nd EIT.ACCRUED_UPTO_DATE_CR BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         and GAM.SCHM_TYPE LIKE '%' ||UPPER(ci_SchemeType) || '%' 
         and GAM.SOL_ID LIKE '%' ||ci_branchCode || '%' 
         and gam.schm_code LIKE '%' ||UPPER(ci_SchemeCode) || '%' 
         And Gam.Acct_Crncy_Code = Upper(Ci_Currency)
         And  Eit.Nrml_Interest_Amount_Cr <>  0
         and  EIT.NRML_ACCRUED_AMOUNT_CR  <> 0
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         order by GAM.FORACID;
         
  PROCEDURE FIN_ACCRUAL_BALANCE_TEST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
     
        
        v_AccountID   TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
        v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
        v_AccuredCR   TBAADM.EIT.NRML_ACCRUED_AMOUNT_CR%TYPE;
        v_AccuredDR   TBAADM.EIT.NRML_ACCRUED_AMOUNT_DR%TYPE;
        v_BranchName  TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
        v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
        v_BankPhone   TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
        v_BankFax     TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
        v_Date        Varchar2(20);
        v_OpenDate    VarChar2(30);
          
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
    
    --vi_startDate  :=outArr(0);		
    --vi_endDate    :=outArr(1);		
    vi_SchemeType	:=outArr(0);
    vi_SchemeCode :=outArr(1);
    vi_currency   :=outArr(2);
    vi_branchCode :=outArr(3);	

   IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
  vi_branchCode := '';
  END IF;
   
  IF vi_SchemeCode IS  NULL or vi_SchemeCode = ''  THEN
  vi_SchemeCode := '';
  END IF;
  
  
  If Vi_Producttype Like 'Regular Saving'  Then
      Vi_Schemetype :=  'SBA';
      Vi_Schemecode :=  'SAREG';
      
  Elsif Vi_Producttype Like 'Saving Special' Then
      Vi_Schemetype :=  'SBA';
      Vi_Schemecode :=  'SASPL';
  
  Elsif Vi_Producttype Like 'Fixed Deposit' Then
      Vi_Schemetype :=  'TDA';
      Vi_Schemecode :=  '';
      
  Elsif Vi_Producttype Like 'Normal Loan' Then
      Vi_Schemetype :=  'LAA';
      Vi_Schemecode :=  'AGDNL';
      
  Elsif Vi_Producttype Like 'Staff Loan' Then
      Vi_Schemetype :=  'LAA';
      Vi_Schemecode :=  'AG_S';
      
  Elsif Vi_Producttype Like 'Hire Purchase' Then
      Vi_Schemetype :=  'LAA';
      Vi_Schemecode :=  'AG%HP';
      
  ELSIF Vi_Producttype LIKE 'Overdraft' THEN
      Vi_Schemetype :=  'CAA';
      Vi_Schemecode :=  'AGDOD';
  END IF;
    
    IF UPPER(vi_SchemeType) like 'SBA' or UPPER(vi_SchemeType) like 'TDA'  THEN
     --{
      IF NOT ExtractDataPay%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN ExtractDataPay (	
         vi_branchCode , 
        vi_SchemeType, vi_SchemeCode ,vi_currency);
        --}
        END;
  
      --}
      END IF;
     
      IF ExtractDataPay%ISOPEN THEN
      --{
        FETCH	ExtractDataPay
        INTO	v_AccuredCR, v_AccuredDR,
              v_AccountName ,v_AccountID ,v_Date,v_OpenDate;
        
  
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataPay%NOTFOUND THEN
        --{
          CLOSE ExtractDataPay;
          out_retCode:= 1;
          RETURN;
        --}
        END IF;
      --}
      END IF;
      
      -----------FOR Receivable ----------
   ELSE
   
      IF NOT ExtractDataRec%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN ExtractDataRec (	
         vi_branchCode , 
        vi_SchemeType , vi_SchemeCode,vi_currency);
        --}
        END;
  
      --}
      END IF;
      
      IF ExtractDataRec%ISOPEN THEN
      --{
        FETCH	ExtractDataRec
        INTO	v_AccuredCR, v_AccuredDR,
              v_AccountName ,v_AccountID ,v_Date,v_OpenDate;
        
  
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataRec%NOTFOUND THEN
        --{
          CLOSE ExtractDataRec;
          out_retCode:= 1;
          RETURN;
        --}
        END IF;
      --}
      END IF;
    --}  
  END IF;   
     IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
        v_BranchName := 'Conso';
     ELSE
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
      END IF;
     out_rec:=	(
					v_AccountID         || '|' ||  
					v_AccountName      	|| '|' ||       
          v_AccuredDR         || '|' ||
          v_AccuredCR         || '|' ||
					v_BranchName	      || '|' ||
					v_BankAddress      	|| '|' ||
					v_BankPhone         || '|' ||
          v_BankFax           || '|' ||
          v_Date              || '|' ||
          v_OpenDate);
  
			dbms_output.put_line(out_rec);
  END FIN_ACCRUAL_BALANCE_TEST;

END FIN_ACCRUAL_BALANCE_TEST;
/
