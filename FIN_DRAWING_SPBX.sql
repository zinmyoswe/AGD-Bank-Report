CREATE OR REPLACE PACKAGE                                           FIN_DRAWING_SPBX AS 

  PROCEDURE FIN_DRAWING_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DRAWING_SPBX;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     FIN_DRAWING_SPBX AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranId	   	Varchar2(20);              -- Input to procedure
	vi_TranDate		Varchar2(20);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------
    CURSOR ExtractData (ci_TranId	   	Varchar2,	
			ci_TranDate		Varchar2) IS
      select 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID as "tran_id", 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT as "tran_amt", 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as "nrc", 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS as "name", 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as "address" , 
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE  as "tran_date",   
            CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM as "phone_no", 
            CUSTOM_CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID as "branch_code",
            CUSTOM_CTD_DTD_ACLI_VIEW.ACID as "acid",
           -- USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO as "drawee_info",
          -- nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 1),'-') drawee_info,
          -- nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 2),'-') drawee_Name,
          -- nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 3),'-') drawee_NRC,
          -- nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 4),'-') drawee_Address,
           --nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 6),'-') Description_Code,
         -- nvl(regexp_substr(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO, '[^|]+', 1, 5),'-') drawee_Phone,
          nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 1),'-') drawee_info,
          nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 2),'-') drawee_Name,
           nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 3),'-') drawee_NRC,
           nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 4),'-') drawee_Address,
           nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 6),'-') Description_Code,
          nvl(regexp_substr(regexp_replace(USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO,'[|][|]', '|-|'), '[^|]+', 1, 5),'-') drawee_Phone,
            CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE 
            --into 
        from 
            custom.CUSTOM_CTD_DTD_ACLI_VIEW CUSTOM_CTD_DTD_ACLI_VIEW , 
            TBAADM.USER_ADDTL_DET_TABLE USER_ADDTL_DET_TABLE
        where 
            trim(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(ci_TranId))
            and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            and USER_ADDTL_DET_TABLE.MODULE_KEY = CUSTOM_CTD_DTD_ACLI_VIEW.UAD_MODULE_Key
            And User_Addtl_Det_Table.Module_Id = Custom_Ctd_Dtd_Acli_View.Uad_Module_Id
             and USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO is not null
            --and CUSTOM_CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'(no need to check coz bank want to print before post)
            and CUSTOM_CTD_DTD_ACLI_VIEW.BANK_ID = '01';
            --and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE = 'RI';
    
    PROCEDURE FIN_DRAWING_SPBX(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

    IS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------

    v_tranId CUSTOM. CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID %type;
    v_actualTranAmt CUSTOM. CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_interRemitTranAmt TBAADM. CHRG_TRAN_LOG_TBL.ACTUAL_AMT_COLL%type;
    v_commTranAmt  TBAADM.CHRG_TRAN_LOG_TBL.ACTUAL_AMT_COLL%type;
    v_nrc CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
    v_payeeName CUSTOM. CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS %type;
    v_payeeAddress CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2%type;
    v_outTranDate DATE;
    v_phoneNo CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM%type;
    v_branchShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;  
    v_faxNo custom.custom_CTH_DTH_VIEW.REMARKS%type; 
    v_draweeInfo TBAADM.USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO%type;
    v_branchCode CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.SOL_ID%type;
    v_acid CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.ACID%type;
    v_currency CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE%type;
      v_BankPhone TBAADM. BRANCH_CODE_TABLE.PHONE_NUM%type;
     v_payeeBranch TBAADM.BRANCH_CODE_TABLE.BR_NAME%type;
     
     v_draweeName  varchar2(100);
    v_draweeNRC  varchar2(100);
    v_draweeAddress  varchar2(100);
    v_descriptionCode  varchar2(100);
    v_draweePhone  varchar2(100);
     v_Nothing  varchar2(100);
   
   
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
    
    vi_TranId:=outArr(0);
		vi_TranDate:=outArr(1);
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_TranId, vi_TranDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_tranId, v_actualTranAmt, v_nrc, v_payeeName, 
            v_payeeAddress, v_outTranDate, v_phoneNo, v_branchCode,v_acid,
            v_draweeInfo,
    v_draweeName,
    v_draweeNRC  ,
    v_draweeAddress ,
    v_descriptionCode ,
    v_draweePhone , v_currency;
      

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
    
 
-------------------------------------------------------------------------------
    -- GET FAX NO
-------------------------------------------------------------------------------
begin
   select 
         CTH_DTH_VIEW.REMARKS as "fax_no"
         INTO
         v_faxNo
      from 
         custom.custom_CTH_DTH_VIEW CTH_DTH_VIEW  
      where
         TRIM(CTH_DTH_VIEW.TRAN_ID) = upper(vi_TranId)
         and CTH_DTH_VIEW.TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ); 
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_faxNo := ''; 
 end;
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
begin
     select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchShortName",
          BRANCH_CODE_TABLE.PHONE_NUM          AS "Bank_Phone"
         INTO
         v_branchShortName, v_BankPhone
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = v_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE; 
          EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_branchShortName := '';  

  end; 
--------------------------------------------------------------------------------
      --Telex remittance charges
--------------------------------------------------------------------------------
begin   
      select 
          sum(CHRG_TRAN_LOG_TBL.ACTUAL_AMT_COLL) INTO v_commTranAmt
      from 
          TBAADM.CHRG_TRAN_LOG_TBL CHRG_TRAN_LOG_TBL
      where 
          trim(CHRG_TRAN_LOG_TBL.CHRG_TRAN_ID) = upper(vi_TranId)
          and CHRG_TRAN_LOG_TBL.CHRG_TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          and CHRG_TRAN_LOG_TBL.CHRG_RPT_CODE in (select CUST_GENCUST_PARAM_MAINT.VARIABLE_VALUE from 
          CUSTOM.CUST_GENCUST_PARAM_MAINT CUST_GENCUST_PARAM_MAINT
          where CUST_GENCUST_PARAM_MAINT.VARIABLE_NAME = 'TELEX_CHARGE'
          and CUST_GENCUST_PARAM_MAINT.BANK_ID = '01'
          and CUST_GENCUST_PARAM_MAINT.DEL_FLG = 'N'
          and CUST_GENCUST_PARAM_MAINT.MODULE_NAME = 'REPORT'
          and CUST_GENCUST_PARAM_MAINT.SUB_MODULE_NAME = 'TELEX') ;
          EXCEPTION
 WHEN NO_DATA_FOUND THEN
        v_commTranAmt := 0.00;  
 end;  
--------------------------------------------------------------------------------
      --Commission remittance charges
--------------------------------------------------------------------------------          
begin 
      select 
          sum(CHRG_TRAN_LOG_TBL.ACTUAL_AMT_COLL ) INTO v_interRemitTranAmt
      from 
          TBAADM.CHRG_TRAN_LOG_TBL CHRG_TRAN_LOG_TBL
      where 
          trim(CHRG_TRAN_LOG_TBL.CHRG_TRAN_ID) = upper(vi_TranId )
          and CHRG_TRAN_LOG_TBL.CHRG_TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          and (CHRG_TRAN_LOG_TBL.CHRG_RPT_CODE is null or  CHRG_TRAN_LOG_TBL.CHRG_RPT_CODE = 'COMCH')/*(select CUST_GENCUST_PARAM_MAINT.VARIABLE_VALUE from 
          CUSTOM.CUST_GENCUST_PARAM_MAINT CUST_GENCUST_PARAM_MAINT
          where CUST_GENCUST_PARAM_MAINT.VARIABLE_NAME = 'COM_CHARGE'
          and CUST_GENCUST_PARAM_MAINT.BANK_ID = '01'
          and CUST_GENCUST_PARAM_MAINT.DEL_FLG = 'N'
          and CUST_GENCUST_PARAM_MAINT.MODULE_NAME = 'REPORT'
          and CUST_GENCUST_PARAM_MAINT.SUB_MODULE_NAME = 'COMMISION')*/ ;
          EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_interRemitTranAmt := 0.00;  
 end;  
     
--------------------------------------------------------------------------------
      --Charges internal remittance
--------------------------------------------------------------------------------          
Begin

select BR_NAME INTO v_payeeBranch  from (
       
          select
          bct.BR_NAME 
         -- INTO v_payeeBranch
      from
          CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW cdav,
          TBAADM.BRANCH_CODE_TABLE bct
      where 
        bct.bank_code = cdav.bank_code
        and bct.br_code = cdav.branch_code
        and cdav.tran_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and trim(cdav.tran_id) = upper(vi_TranId)
        and rownum =1
           union all
        select
          BRANCH_CODE_TABLE.BR_NAME 
         -- INTO v_payeeBranch
      from
          CUSTOM.CCHRG_TBL CCHRG_TBL,
          TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where 
          CCHRG_TBL.chrgevt = (select distinct event_id from tbaadm.cxl 
          where chrg_tran_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          and trim(chrg_tran_id) = upper(vi_TranId))
          and CCHRG_TBL.BANKCODE = BRANCH_CODE_TABLE.BANK_CODE
          and CCHRG_TBL.BRANCHCODE = BRANCH_CODE_TABLE.BR_CODE
          and rownum =1
        )
        where  rownum =1
          ;
        
             EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_payeeBranch := '';  
    END; 
    
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------
 ------------------checking of v_actualTranAmt value null-------------------
 IF v_actualTranAmt IS NULL OR v_actualTranAmt = '' THEN
   v_actualTranAmt  := 0;
  END IF;
  -----------------------------------------
------------------checking of v_interRemitTranAmt value null-------------------
 IF v_interRemitTranAmt IS NULL OR v_interRemitTranAmt = '' THEN
   v_interRemitTranAmt  := 0;
  END IF;
  -----------------------------------------
  ------------------checking of v_commTranAmt value null-------------------
 IF v_commTranAmt IS NULL OR v_commTranAmt = '' THEN
   v_commTranAmt  := 0;
  END IF;
  -----------------------------------------
  
    out_rec:=	(v_tranId            || '|' ||
					v_actualTranAmt      			|| '|' ||
          v_interRemitTranAmt      			|| '|' ||
          v_commTranAmt      			|| '|' ||
					v_nrc	|| '|' ||
					v_payeeName      			|| '|' ||
					v_payeeAddress      			|| '|' ||
          to_char(to_date(v_outTranDate,'dd/Mon/yy'), 'dd/MM/yyyy')      			|| '|' ||
					v_phoneNo      			|| '|' ||
					v_branchShortName || '|' ||        
          v_BankPhone || '|' ||
					v_payeeBranch  || '|' ||      
          trim(v_currency)|| '|' || 
          v_faxNo              || '|' ||
          v_draweeInfo          || '|' ||
            upper(v_draweeName)       || '|' ||
           upper(v_draweeNRC)           || '|' ||
           upper(v_draweeAddress)       || '|' ||
          upper(v_descriptionCode)     || '|' ||
          v_Nothing             || '|' ||
            upper(v_draweePhone) );
  
			dbms_output.put_line(out_rec);
  END FIN_DRAWING_SPBX;
END FIN_DRAWING_SPBX;
/
