CREATE OR REPLACE PACKAGE                                           FIN_OD_REGISTER_LISTING AS 

    PROCEDURE FIN_OD_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_OD_REGISTER_LISTING;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                  FIN_OD_REGISTER_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_currency	   	Varchar2(3);              -- Input to procedure

    
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
SELECT  
   GENERAL_ACCT_MAST_TABLE.FORACID as "AccountNo." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "AccountName" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM as "TotalLimit" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM - abs(GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT) as "OutstandingLimit" , 
   lht.LIM_EXP_DATE as "ExpiredDate"
FROM
   --TBAADM.LA_ACCT_MAST_TABLE LA_ACCT_MAST_TABLE ,
    tbaadm.GENERAL_ACCT_MAST_TABLE,TBAADM.lht lht
where
   GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N'
   and lht.acid = GENERAL_ACCT_MAST_TABLE.acid   
   --and GENERAL_ACCT_MAST_TABLE.ACID = LA_ACCT_MAST_TABLE.ACID
   and GENERAL_ACCT_MAST_TABLE.ACCT_CLS_FLG = 'N' 
   and GENERAL_ACCT_MAST_TABLE.ENTITY_CRE_FLG = 'Y' 
   and GENERAL_ACCT_MAST_TABLE.Bank_id = '01'
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency )
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = 'CAA'
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = 'AGDOD' --OVERDRAFT
   and GENERAL_ACCT_MAST_TABLE.SANCT_LIM > 0
   and GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode 
order by 
  GENERAL_ACCT_MAST_TABLE.FORACID desc,
   GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE desc;

  PROCEDURE FIN_OD_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
       v_AccountNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
       v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
       v_TotalLimit TBAADM.GENERAL_ACCT_MAST_TABLE.SANCT_LIM%type;
       v_OutstandingLimit TBAADM.GENERAL_ACCT_MAST_TABLE.SANCT_LIM%type;
       v_ExpiredDate date;
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
-----------------------------------------------------------------------------------------

if( vi_startDate is null or vi_endDate is null or vi_currency is null or  vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 
		           0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;



--------------------------------------------------------------------------------------------
	
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (
			vi_startDate , vi_endDate , vi_branchCode , 	vi_currency  );
			--}
			END;

		--}
		END IF;
   
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_AccountNo, v_AccountName, v_TotalLimit, v_OutstandingLimit, 
            v_ExpiredDate;
      

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
   
    out_rec:=	(v_AccountNo      			|| '|' ||
          v_AccountName      			|| '|' ||
					v_TotalLimit	|| '|' ||
					v_OutstandingLimit      			|| '|' ||
					 to_char(to_date(v_ExpiredDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
 
  END FIN_OD_REGISTER_LISTING;

END FIN_OD_REGISTER_LISTING;
/
