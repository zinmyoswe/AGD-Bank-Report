CREATE OR REPLACE PACKAGE                      FIN_CLEARING_SCHEDULE AS 

 PROCEDURE FIN_CLEARING_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CLEARING_SCHEDULE;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_CLEARING_SCHEDULE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
	vi_TransactionDate		Varchar2(10);		    	    -- Input to procedure
  --vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_SchemeType		Varchar2(3);		    	    -- Input to procedure

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_TransactionDate VARCHAR2,ci_branchCode VARCHAR2,ci_currency VARCHAR2)
  IS
  SELECT  --OCPT.SET_NUM as "CheqNo",
          OCI.INSTRMNT_AMT as "TranAmt", 
          OCI.INSTRMNT_ID as "CheqNo",
          BCT.BANK_NAME as "BankName",
          BCT.BANK_CODE as "BankCode"
    
  FROM  TBAADM.OUT_ZONE_HDR_TABLE OZH,
        TBAADM.OUT_CLG_INSTRMNT_TABLE OCI,
        TBAADM.OUT_CLG_PART_TRAN_TABLE OCPT, 
        TBAADM.BANK_CODE_TABLE BCT
        
  WHERE OZH.CLG_ZONE_CODE = OCI.CLG_ZONE_CODE
  AND   OCI.CLG_ZONE_CODE= OCPT.CLG_ZONE_CODE
  and  OZH.CLG_ZONE_DATE = OCI.CLG_ZONE_DATE
  AND   OCI.CLG_ZONE_DATE= OCPT.CLG_ZONE_DATE
 -- AND   OZH.ZONE_STAT =  'S'
 -- AND   OZH.TRAN_DATE2 = OCPT.TRAN_DATE
  AND   OCPT.SET_NUM = OCI.SET_NUM
  AND   OZH.CLG_ZONE_DATE = TO_DATE(CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
  AND   OCI.BANK_CODE = BCT.BANK_CODE
  AND   OCPT.ACCT_CRNCY_CODE = UPPER(ci_currency)
  AND    OCPT.SOL_ID =  ci_branchCode 
  AND   OCPT.DEL_FLG = 'N'
  AND   OCI.DEL_FLG = 'N'
  AND   OZH.DEL_FLG = 'N'
  AND   BCT.DEL_FLG = 'N'
  ORDER BY   BCT.BANK_CODE,OCI.INSTRMNT_ID ;
  
  PROCEDURE FIN_CLEARING_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS


    v_TranAmt TBAADM.OUT_CLG_INSTRMNT_TABLE.INSTRMNT_AMT%type;
    v_CheqNo TBAADM.OUT_CLG_INSTRMNT_TABLE.INSTRMNT_ID%type;
    v_Bank  TBAADM.BANK_CODE_TABLE.BANK_NAME%type;
    v_BankCode    TBAADM.BANK_CODE_TABLE.BANK_CODE%type;
    
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
    
    vi_TransactionDate :=outArr(0);
    
    vi_currency :=outArr(1);		
    vi_branchCode :=outArr(2);
  
  ------------------------------------------------------------------------------------------
  
  
   if( vi_TransactionDate is null or vi_currency is null or vi_branchCode is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  
  ---------------------------------------------------------------------------------------------------------
 
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_TransactionDate, vi_branchCode,vi_currency);
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
        		INTO	v_TranAmt, v_CheqNo,
            v_Bank ,v_BankCode ;
      

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

     out_rec:=	(
					v_TranAmt         || '|' ||  
          v_CheqNo          || '|' ||
          v_Bank            || '|' ||
          v_BankCode        || '|' ||
					v_BranchName	    || '|' ||
					v_BankAddress     || '|' ||
					v_BankPhone       || '|' ||
          v_BankFax );
  
          dbms_output.put_line(out_rec);
     
  END FIN_CLEARING_SCHEDULE;

END FIN_CLEARING_SCHEDULE;
/
