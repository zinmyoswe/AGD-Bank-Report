CREATE OR REPLACE PACKAGE        FIN_FCY_DEPOSIT_WITHDRAWAL AS 

   PROCEDURE FIN_FCY_DEPOSIT_WITHDRAWAL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FCY_DEPOSIT_WITHDRAWAL;
/


CREATE OR REPLACE PACKAGE BODY                             FIN_FCY_DEPOSIT_WITHDRAWAL AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_rate decimal;
  vi_TransactionType VARCHAR2(20);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractDataDeposit
-----------------------------------------------------------------------------
CURSOR ExtractDataDeposit (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, 
      ci_currency VARCHAR2,ci_rate VARCHAR2)
  IS
    SELECT   GAM.ACCT_NAME as AcctName,
             ACCOUNTS.UNIQUEID as NRC,
              address.address_line1 || 
              address.address_line2 || 
              address.address_line3 ||','|| 
              address.city ||','||
              address.state ||','||
              address.country            as Address,
              GAM.FORACID  as AcctNumber,
              ctd.tran_amt as TranAmt,
              1 * ci_rate AS Rate,
              cth.REMARKS as Remark
    FROM   CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,custom.CUSTOM_CTH_DTH_VIEW cth,
           CRMUSER.ACCOUNTS ACCOUNTS, CRMUSER.ADDRESS ADDRESS , TBAADM.GAM gam 
    WHERE  CTD.TRAN_ID = CTH.TRAN_ID
    AND    CTD.TRAN_DATE = CTH.TRAN_DATE
    AND    CTD.ACID = GAM.ACID
    and      ctd.tran_amt  >= 10000
    AND    ACCOUNTS.ORGKEY = GAM.CIF_ID
    AND    GAM.CIF_ID = ADDRESS.ORGKEY 
    AND    CTD.tran_particular_code in ('CHD','TRD')
    AND   ( ADDRESS.ADDRESSCATEGORY like 'Mailing' or ADDRESS.ADDRESSCATEGORY like 'Registered') 
    AND    CTD.TRAN_DATE  >=    TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND    CTD.TRAN_DATE  <=    TO_DATE( CAST ( ci_endDate   AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND    CTD.SOL_ID = ci_branchCode
    AND    CTD.TRAN_CRNCY_CODE = UPPER(ci_currency)
    AND    ctd.tran_Amt >= 1000
    AND    GAM.DEL_FLG = 'N'
    AND    gam.ENTITY_CRE_FLG = 'Y'
    AND    gam.ACCT_CLS_FLG   = 'N'
    AND    ctd.DEL_FLG = 'N'
    ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
; 

-----------------------------------------------------------------------------
-- CURSOR ExtractDataWithdrawal
-----------------------------------------------------------------------------
CURSOR ExtractDataWithdrawal (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, 
      ci_currency VARCHAR2, ci_rate VARCHAR2)
  IS
    SELECT   GAM.ACCT_NAME AS AcctName,
             ACCOUNTS.UNIQUEID AS NRC,
             address.address_line1 || 
             address.address_line2 || 
             address.address_line3 ||','|| 
              address.city ||','||
              address.state ||','||
              address.country  AS Address,
             GAM.FORACID  AS AcctNumber,
             ctd.tran_amt AS TranAmt,
             1 * ci_rate AS Rate,
             cth.REMARKS AS Remark
    FROM     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,custom.CUSTOM_CTH_DTH_VIEW cth,
             CRMUSER.ACCOUNTS ACCOUNTS, CRMUSER.ADDRESS ADDRESS , TBAADM.GAM gam 
    WHERE    CTD.TRAN_ID = CTH.TRAN_ID
    AND      CTD.TRAN_DATE = CTH.TRAN_DATE
    AND      CTD.ACID = GAM.ACID
    and      ctd.tran_amt  >= 10000
    AND      ACCOUNTS.ORGKEY = GAM.CIF_ID
    AND      GAM.CIF_ID = ADDRESS.ORGKEY 
    AND      CTD.tran_particular_code in ('CHW','TRW')
    AND   ( ADDRESS.ADDRESSCATEGORY like 'Mailing' or ADDRESS.ADDRESSCATEGORY like 'Registered')
    AND      CTD.TRAN_DATE  >=    TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND      CTD.TRAN_DATE  <=    TO_DATE( CAST ( ci_endDate   AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND      CTD.SOL_ID = ci_branchCode
    AND      CTD.TRAN_CRNCY_CODE = UPPER(ci_currency)
    AND      ctd.tran_Amt >= 1000
    AND      GAM.DEL_FLG = 'N'
    AND      gam.ENTITY_CRE_FLG = 'Y'
    AND      gam.ACCT_CLS_FLG   = 'N'
    AND      ctd.DEL_FLG = 'N'
    ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
; 
  
  PROCEDURE FIN_FCY_DEPOSIT_WITHDRAWAL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
 
    v_AcctName    TBAADM.GAM.ACCT_NAME%type; 
    v_NRC         CRMUSER.ACCOUNTS.UNIQUEID%type;
    v_Address     varchar2(100);
    v_AcctNumber  TBAADM.GAM.FORACID%type;
    v_Rate        VARCHAR(30);
    v_TranAmt     CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_Remark      custom.CUSTOM_CTH_DTH_VIEW.REMARKS%type;
    v_BranchName  TBAADM.BRANCH_CODE_TABLE.BR_Name%type;
  
    
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
    
    vi_startDate       :=  outArr(0);		
    vi_endDate         :=  outArr(1);		
    vi_currency        :=  outArr(2);
    vi_TransactionType :=  outArr(3);
     vi_branchCode      :=  outArr(4);	
   
   ----------------------------------------------------------
   if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_TransactionType is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' ||
		           '-' || '|' || '-' );
					
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
   
   -------------------------------------------------------
   
    
    BEGIN
      
            IF(upper(vi_currency) = 'MMK') then vi_rate := 1;  
            ELSE select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_startDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
            END IF;
    END;
    IF vi_TransactionType like 'Deposit%' THEN
     --{
      IF NOT ExtractDataDeposit%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN ExtractDataDeposit (	
        vi_startDate , vi_endDate  , vi_branchCode , vi_currency,vi_rate);
        --}
        END;
  
      --}
      END IF;
      
      IF ExtractDataDeposit%ISOPEN THEN
      --{
        FETCH	ExtractDataDeposit
        INTO	 v_AcctName,v_NRC,v_Address, v_AcctNumber,v_TranAmt,v_Rate,v_Remark;
        
  
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataDeposit%NOTFOUND THEN
        --{
          CLOSE ExtractDataDeposit;
          out_retCode:= 1;
          RETURN;
        --}
        END IF;
      --}
      END IF;
     --}
     
    ELSE  -----  Withdrawal
    --{  
      IF NOT ExtractDataWithdrawal%ISOPEN THEN
      --{
        BEGIN
        --{
          OPEN ExtractDataWithdrawal (	
        vi_startDate , vi_endDate  , vi_branchCode , vi_currency,vi_rate);
        --}
        END;
  
      --}
      END IF;
      
      IF ExtractDataWithdrawal%ISOPEN THEN
      --{
        FETCH	ExtractDataWithdrawal
        INTO	 v_AcctName,v_NRC,v_Address, v_AcctNumber,v_TranAmt,v_Rate,v_Remark;
        
  
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataWithdrawal%NOTFOUND THEN
        --{
          CLOSE ExtractDataWithdrawal;
          out_retCode:= 1;
          RETURN;
        --}
        END IF;
      --}
      END IF;
     --}
  END IF;
      
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
--------------------------------------------------------------------------------
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
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
    out_rec:=	(
          v_AcctName     			|| '|' ||
					v_NRC	              || '|' ||
					v_Address      			|| '|' ||
          v_AcctNumber   			|| '|' ||
          v_TranAmt    			  || '|' ||
          v_Rate    			    || '|' ||
          v_Remark            || '|' ||
					v_BranchName	    
				 );
  
			dbms_output.put_line(out_rec);
      
  END FIN_FCY_DEPOSIT_WITHDRAWAL;

END FIN_FCY_DEPOSIT_WITHDRAWAL;
/
