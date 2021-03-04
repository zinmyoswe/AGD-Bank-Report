CREATE OR REPLACE PACKAGE                                    FIN_INTEREST_LISTING AS 

  PROCEDURE FIN_INTEREST_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INTEREST_LISTING;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                              FIN_INTEREST_LISTING AS
  
  
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeCode  Varchar2(6);

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	 ci_branchCode VARCHAR2, ci_SchemeCode VARCHAR2,
      ci_SchemeType VARCHAR2, ci_currency VARCHAR2)
  IS
  select 
   (EIT.NRML_ACCRUED_AMOUNT_CR-EIT.NRML_INTEREST_AMOUNT_CR) as "Interest_CR" , 
   (EIT.NRML_ACCRUED_AMOUNT_DR-EIT.NRML_INTEREST_AMOUNT_DR) as "Interest_DR" ,  
   GAM.ACCT_NAME as "Account_Name" , 
   GAM.FORACID as "Account_ID" , 
   GAM.SCHM_TYPE as "Scheme_Type",
   EIT.NRML_ACCRUED_AMOUNT_CR AS "Accured_Cr",
   EIT.NRML_ACCRUED_AMOUNT_DR as "Accured_Dr",
   EIT.NRML_BOOKED_AMOUNT_CR as "Booked_Cr",
   EIT.NRML_BOOKED_AMOUNT_DR as "Booked_Dr" ,
   EIT.NRML_INTEREST_AMOUNT_CR as "Applied_Cr",
   EIT.NRML_INTEREST_AMOUNT_DR as "Applied_Dr"
from 
   TBAADM.EIT EIT , 
   TBAADM.GAM GAM 
where
   GAM.SCHM_TYPE = upper(ci_SchemeType )
   and GAM.SOL_ID = ci_branchCode
   and gam.schm_code = upper(ci_SchemeCode)
   and EIT.ENTITY_ID = GAM.ACID 
   and gam.acct_crncy_code = upper(ci_currency)
   and GAM.DEL_FLG = 'N' 
   and GAM.ACCT_CLS_FLG = 'N' 
   and GAM.Bank_id = '01'
   order by GAM.FORACID;
   
  PROCEDURE FIN_INTEREST_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_Interest_CR TBAADM.EIT.NRML_INTEREST_AMOUNT_CR%type;
      v_Interest_DR TBAADM.EIT.NRML_INTEREST_AMOUNT_DR%type;
      v_Account_Name TBAADM.GAM.ACCT_NAME%type;
      v_Account_Id  TBAADM.GAM.FORACID%type;
      v_Scheme_Type TBAADM.GAM.SCHM_TYPE%type;
      v_Branch_Name TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
      v_Bank_Address TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
      v_Bank_Phone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_Bank_Fax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      v_Accured_Cr TBAADM.EIT.NRML_ACCRUED_AMOUNT_CR%TYPE;
      v_Accured_Dr TBAADM.EIT.NRML_ACCRUED_AMOUNT_DR%TYPE;
      v_Book_Cr TBAADM.EIT.NRML_BOOKED_AMOUNT_CR%type;
      v_Book_Dr TBAADM.EIT.NRML_BOOKED_AMOUNT_DR%type;
      v_Applied_Cr  TBAADM.EIT.NRML_INTEREST_AMOUNT_CR%type;
      v_Applied_Dr  TBAADM.EIT.NRML_INTEREST_AMOUNT_DR%type;


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
    
  
   vi_SchemeCode  := outArr(0);
    vi_SchemeType	:=outArr(1);	
    vi_currency :=outArr(2);
     vi_branchCode :=outArr(3);
  --------------------------------------------------------------------
  
  if( vi_SchemeCode is null or vi_SchemeType is null or vi_currency is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		          '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
				  '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 
				  0 || '|' || 0 || '|' || 0);
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  
  ----------------------------------------------------------------------
   
    
     IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_branchCode ,vi_SchemeCode,
      vi_SchemeType,vi_currency  );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_Interest_CR, v_Interest_DR,  v_Account_Name,  v_Account_Id, 
            v_Scheme_Type, v_Accured_Cr,v_Accured_Dr,v_Book_Cr,v_Book_Dr,v_Applied_Cr,v_Applied_Dr;
      

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
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "Branch_Name",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_Branch_Name, v_Bank_Address, v_Bank_Phone, v_Bank_Fax
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
           v_Interest_CR      			|| '|' ||
					v_Interest_DR           	|| '|' ||
					v_Account_Name      			|| '|' ||
					v_Account_Id      		  	|| '|' ||
					v_Scheme_Type	            || '|' ||
          v_Branch_Name             || '|' ||
					v_Bank_Address      			|| '|' ||
					v_Bank_Phone              || '|' ||
          v_Bank_Fax                || '|' ||
           v_Accured_Cr             || '|' ||
           v_Accured_Dr             || '|' ||
           v_Book_Cr                || '|' ||
           v_Book_Dr                || '|' ||
           v_Applied_Cr             || '|' ||
           v_Applied_Dr);
  
			dbms_output.put_line(out_rec);

  END FIN_INTEREST_LISTING;

END FIN_INTEREST_LISTING;
/
