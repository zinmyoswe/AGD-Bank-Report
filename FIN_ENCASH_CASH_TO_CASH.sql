CREATE OR REPLACE PACKAGE                                           FIN_ENCASH_CASH_TO_CASH AS 

  PROCEDURE FIN_ENCASH_CASH_TO_CASH(	inp_str      IN  VARCHAR2,
      out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_ENCASH_CASH_TO_CASH;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                       FIN_ENCASH_CASH_TO_CASH AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_TranId	   	Varchar2(10);              -- Input to procedure
	vi_TranDate		Varchar2(20);		    	            -- Input to procedure

  CURSOR ExtractData (ci_TranId	   	Varchar2,	
			ci_TranDate		Varchar2) IS
      select 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID as "Tran_Id" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as "NRC" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as "Payee_Address" ,  
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" , 
       USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO as "Drawee_Info",
       CUSTOM_CTD_DTD_ACLI_VIEW.BANK_CODE as "BankCode" ,
       CUSTOM_CTD_DTD_ACLI_VIEW.branch_code AS "BranchCode" ,
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE as "Cur",
       CUSTOM_CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID as "RegisterSol"
    from 
       CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW CUSTOM_CTD_DTD_ACLI_VIEW , 
       TBAADM.USER_ADDTL_DET_TABLE USER_ADDTL_DET_TABLE
    where
    TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(ci_TranId))
       --TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(substr(ci_TranId,(length(ci_TranId)-1)-instr(ci_TranId,'/',1,1),instr(ci_TranId,'/',1,1)-1)))
       --and trim(CUSTOM_CTD_DTD_ACLI_VIEW.part_tran_srl_num) = substr(ci_TranId,instr(ci_TranId,'/',1,1)+1,2)
       and USER_ADDTL_DET_TABLE.MODULE_KEY = CUSTOM_CTD_DTD_ACLI_VIEW.UAD_MODULE_Key
       and USER_ADDTL_DET_TABLE.MODULE_ID = CUSTOM_CTD_DTD_ACLI_VIEW.UAD_MODULE_ID 
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
       and CUSTOM_CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
     --  and CUSTOM_CTD_DTD_ACLI_VIEW.bank_code = '116'
       and CUSTOM_CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
      -- and CUSTOM_CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE = 'C'
       and CUSTOM_CTD_DTD_ACLI_VIEW.RPT_CODE IN('IBREM','REMIT','REMIB');
       --and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE in ('BI','RI');
  
  CURSOR ExtractDataForMIG (ci_TranId	   	Varchar2,	
			ci_TranDate		Varchar2) IS
      select 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID as "Tran_Id" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as "NRC" , 
       Custom_Ctd_Dtd_Acli_View.Tran_Particular_2 As "Payee_Address" ,  
      CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" , 
       USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO as "Drawee_Info",
       CUSTOM_CTD_DTD_ACLI_VIEW.BANK_CODE as "BankCode" ,
       CUSTOM_CTD_DTD_ACLI_VIEW.branch_code AS "BranchCode" ,
      CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE as "Cur",
       CUSTOM_CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID as "RegisterSol"
        
       --INTO
    from 
       CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW CUSTOM_CTD_DTD_ACLI_VIEW , 
       TBAADM.USER_ADDTL_DET_TABLE USER_ADDTL_DET_TABLE
    where
    --TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(ci_TranId))
       TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(substr(ci_TranId,(length(ci_TranId)-1)-instr(ci_TranId,'/',1,1),instr(ci_TranId,'/',1,1)-1)))
       and trim(CUSTOM_CTD_DTD_ACLI_VIEW.part_tran_srl_num) = substr(ci_TranId,instr(ci_TranId,'/',1,1)+1,2)
       and USER_ADDTL_DET_TABLE.MODULE_KEY = CUSTOM_CTD_DTD_ACLI_VIEW.UAD_MODULE_Key
       and USER_ADDTL_DET_TABLE.MODULE_ID = CUSTOM_CTD_DTD_ACLI_VIEW.UAD_MODULE_ID 
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
       and CUSTOM_CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       --and CUSTOM_CTD_DTD_ACLI_VIEW.bank_code = '116'
       --and CUSTOM_CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
      -- and CUSTOM_CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE = 'C'
       and CUSTOM_CTD_DTD_ACLI_VIEW.RPT_CODE IN('IBREM','REMIT','REMIB');
       --and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE in ('BI','RI');

  PROCEDURE FIN_ENCASH_CASH_TO_CASH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
      v_tranId CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID%type; 
      v_tranAmt number(20,2);
      v_nrc CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
      v_payeeAddress CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2%type;
      v_payeeName CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS%type;
      v_outTranDate CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE%type;
      v_phoneNo CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM%type;
      vii_branchCode CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.Branch_Code%type;
      v_draweeInfo TBAADM.USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO%type;
      v_branchCode TBAADM.BRANCH_CODE_TABLE.BR_code%type;
      v_faxNo CUSTOM.CUSTOM_CTH_DTH_VIEW.REMARKS%type;
      v_branchName TBAADM.BRANCH_CODE_TABLE.BR_NAME%type;
      vii_bankCode CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.Bank_Code%type;
      vi_cur  CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE%type;
      v_registerSol CUSTOM_CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID%type;
      v_RegisterBankName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%TYPE;
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
    
    --------------------------------------------------------------------------------------
    
    		  
if( vi_TranId is null or vi_TranDate is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
                    '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' 		);
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    -------------------------------------------------------------------------------------------
    if vi_TranId not like '%/%' then
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
			INTO	 v_tranId, v_tranAmt, v_nrc, v_payeeAddress, 
       v_payeeName, v_outTranDate, 
       v_phoneNo, v_draweeInfo,vii_bankCode, vii_branchCode,vi_cur,v_registerSol;
      

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
    else 
    
     IF NOT ExtractDataForMIG%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForMIG (vi_TranId, vi_TranDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataForMIG%ISOPEN THEN
		--{
			FETCH	ExtractDataForMIG
			INTO	 v_tranId, v_tranAmt, v_nrc, v_payeeAddress, 
       v_payeeName, v_outTranDate, 
       v_phoneNo, v_draweeInfo,vii_bankCode, vii_branchCode,vi_cur,v_registerSol;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataForMIG%NOTFOUND THEN
			--{
				CLOSE ExtractDataForMIG;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
   
   end if;
   
  BEGIN
    SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName"
    INTO v_RegisterBankName
    FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
      TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = v_registerSol
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
  END;
    BEGIN
    
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------   
    ---Corected BY
   begin
      select 
         BRANCH_CODE_TABLE.BR_code as "BranchShortName",
         BRANCH_CODE_TABLE.BR_NAME AS "BranchName" 
         into 
         v_branchCode,v_branchName
      from
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where BRANCH_CODE_TABLE.Br_code = vii_branchCode
      and    BRANCH_CODE_TABLE.bank_code = vii_bankCode;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_branchCode := '-';
        v_branchName := '-';
        
       
  END;   
  
  if vii_branchCode is null then vii_branchCode := '-';
  end if;
  
  if v_RegisterBankName is null or v_RegisterBankName = ''  then v_RegisterBankName := '-';
  end if;
      
     /* select 
         BRANCH_CODE_TABLE.BR_code as "BranchShortName",
         BRANCH_CODE_TABLE.BR_NAME AS "BranchName" 
         INTO
          v_branchCode,v_branchName
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = v_registerSol
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE; 
  */
-------------------------------------------------------------------------------
    -- GET FAX NO
-------------------------------------------------------------------------------
if vi_TranId not like '%/%'then
    begin
      select 
         distinct(CUSTOM_CTH_DTH_VIEW.REMARKS) as "fax_no"
         INTO
         v_faxNo
      from 
         CUSTOM.CUSTOM_CTH_DTH_VIEW CUSTOM_CTH_DTH_VIEW
      where
         TRIM(CUSTOM_CTH_DTH_VIEW.TRAN_ID) = trim(upper(vi_TranId))-- trim(upper(substr(vi_TranId,(length(vi_TranId)-1)-instr(vi_TranId,'/',1,1),instr(vi_TranId,'/',1,1)-1)))
         and CUSTOM_CTH_DTH_VIEW.TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' );  
                                                                             EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_faxNo := '-';
    end;
else 
  begin
      select 
         distinct(CUSTOM_CTH_DTH_VIEW.REMARKS) as "fax_no"
         INTO
         v_faxNo
      from 
         CUSTOM.CUSTOM_CTH_DTH_VIEW CUSTOM_CTH_DTH_VIEW
      where
         TRIM(CUSTOM_CTH_DTH_VIEW.TRAN_ID) = trim(upper(substr(vi_TranId,(length(vi_TranId)-1)-instr(vi_TranId,'/',1,1),instr(vi_TranId,'/',1,1)-1)))
         and CUSTOM_CTH_DTH_VIEW.TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' );  
        EXCEPTION
       WHEN NO_DATA_FOUND THEN
        v_faxNo := '-';
    end;   
 end if;
END;

Select Regexp_Replace(v_payeeName, ',',' ') into v_payeeName
from dual;
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------
    out_rec:=	(v_tranId            || '|' ||
					v_tranAmt      		     	 || '|' ||
          v_nrc      			         || '|' ||
          v_payeeAddress      		 || '|' ||
					v_payeeName	             || '|' ||
					to_char(to_date(v_outTranDate,'dd/Mon/yy'), 'dd/MM/yyyy')      			|| '|' ||
					v_phoneNo      			     || '|' ||
          v_draweeInfo             || '|' ||
					v_branchCode     			   || '|' ||
					v_faxNo                  || '|' ||
          v_branchName             || '|' ||
          vi_cur                   || '|' ||
          v_RegisterBankName);
			dbms_output.put_line(out_rec);
  END FIN_ENCASH_CASH_TO_CASH;

END FIN_ENCASH_CASH_TO_CASH;
/
