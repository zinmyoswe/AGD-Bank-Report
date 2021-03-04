CREATE OR REPLACE PACKAGE                      FIN_POGC_REGISTER_LISTING AS 

 
 PROCEDURE FIN_POGC_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
      
END FIN_POGC_REGISTER_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                          FIN_POGC_REGISTER_LISTING AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_StartDate	   	Varchar2(10);               -- Input to procedure
  vi_EndDate        Varchar2(10);               -- Input to procedure
  vi_SchmCode        Varchar2(20);
  vi_SOL_ID		      Varchar2(5);		    	            -- Input to procedure
  vi_currency		    Varchar2(3);		    	          -- Input to procedure
  
 
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (ci_StartDate VARCHAR2,ci_EndDate VARCHAR2,ci_SchmCode VARCHAR2, ci_SOL_ID VARCHAR2, ci_currency VARCHAR2) IS

SELECT  
        CTD.TRAN_SUB_TYPE as "TranSubType",
        CTD.Tran_type as "TranType", 
        DST.DD_AMT  as "TranAmt",
        trim(dst.INSTRMNT_ALPHA) || trim(dst.INSTRMNT_NUM)  as "PONumber", 
        DDC.TRAN_DATE as "TranDate",
        DST.ISSU_BR_CODE AS "IssueBrCode",
        DST.PAYEE_BR_CODE AS "PayeeBrCode",
        DST.PAYING_BR_CODE as "PayingBrCode"
         
from    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM, TBAADM.DDC DDC, TBAADM.DST DST
where   CTD.ACID = GAM.ACID
and     TRIM(DDC.TRAN_ID) = TRIM(CTD.TRAN_ID)
--and DDC.VALUE_DATE = CTD.VALUE_DATE
AND     DDC.TRAN_DATE = CTD.TRAN_DATE
AND    CTD.VALUE_DATE= DST.ISSUE_DATE
AND     CTD.PART_TRAN_SRL_NUM = DDC.PART_TRAN_SRL_NUM
AND     GAM.SCHM_CODE = UPPER(ci_SchmCode)
AND     DST.SCHM_CODE = UPPER(ci_SchmCode)
AND     TRIM(DST.DD_NUM )  = TRIM(DDC.DD_NUM)
AND     CTD.TRAN_DATE >= TO_DATE( CAST (  ci_StartDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
AND     CTD.TRAN_DATE <= TO_DATE( CAST (  ci_EndDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and     CTD.PART_TRAN_TYPE = 'C'

and     GAM.ACCT_CRNCY_CODE = upper(ci_currency)
AND     DDC.INIT_SOL_ID = ci_SOL_ID
AND     DST.ISSU_BR_CODE IN(  select 
            BRANCH_CODE_TABLE.BR_Code
          --BRANCH_CODE_TABLE.DD_ISS_BR_CODE
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = ci_SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01')
AND     GAM.ENTITY_CRE_FLG = 'Y'
AND     GAM.DEL_FLG = 'N'
AND     CTD.DEL_FLG = 'N'
ORDER BY CTD.TRAN_DATE;



  PROCEDURE FIN_POGC_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
     
    
      v_TranSubType  TBAADM.CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE%type;
      v_TranType     TBAADM.CTD_DTD_ACLI_VIEW.Tran_type%type;
      v_TranAmt      TBAADM.DST.DD_AMT%type;
      v_PONumber     TBAADM.DDC.DD_NUM%type;
      v_TranDate     TBAADM.DDC.TRAN_DATE%type;
      v_IssueBrCode  TBAADM.DST.ISSU_BR_CODE%type;
      v_PayeeBrCode  TBAADM.DST.PAYEE_BR_CODE%type;
      v_PayingBrCode TBAADM.DST.PAYING_BR_CODE%type;
      v_BranchName   TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
      v_BankAddress  TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
      v_BankPhone    TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax      TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
        
        
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
    
    vi_StartDate  :=  outArr(0);	
    vi_EndDate    :=  outArr(1);
    vi_SOL_ID     :=  outArr(4);		
    vi_currency   :=  outArr(2);
    vi_SchmCode   :=  outArr(3);
----------------------------------------------------------------------------------------------------
if( vi_StartDate is null or vi_EndDate is null or vi_currency is null or vi_SchmCode is null or vi_SOL_ID is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;


----------------------------------------------------------------------------------------------
    IF vi_SchmCode LIKE  'Gift Cheque%' then
      vi_SchmCode := 'DDGC';
    END IF;
    IF vi_SchmCode LIKE 'Payment Order%' then
      vi_SchmCode := 'DDPO';
    END IF;
    IF vi_SchmCode LIKE 'Certified Cheque%' then
      vi_SchmCode := 'DDCC';
    END IF;
    
   
       IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData ( vi_StartDate,vi_EndDate,vi_SchmCode,	vi_SOL_ID,vi_currency);
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO	 v_TranSubType , v_TranType  ,v_TranAmt,v_PONumber,v_TranDate,v_IssueBrCode,v_PayeeBrCode,v_PayingBrCode;
          
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
         SERVICE_OUTLET_TABLE.SOL_ID = vi_SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_TranSubType   || '|' ||
          v_TranType      || '|' ||
          v_TranAmt       || '|' ||
          v_PONumber      || '|' ||
          v_TranDate      || '|' ||
          v_IssueBrCode   || '|' ||
					v_BranchName	  || '|' ||
					v_BankAddress   || '|' ||
					v_BankPhone     || '|' ||
          v_BankFax       || '|' ||
           v_PayeeBrCode  || '|' ||
          v_PayingBrCode  );
  
			dbms_output.put_line(out_rec);
      
  END FIN_POGC_REGISTER_LISTING;

END FIN_POGC_REGISTER_LISTING;
/
