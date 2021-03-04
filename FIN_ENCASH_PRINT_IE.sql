CREATE OR REPLACE PACKAGE                                           FIN_ENCASH_PRINT_IE AS 

  PROCEDURE FIN_ENCASH_PRINT_IE(	inp_str      IN  VARCHAR2,
      out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_ENCASH_PRINT_IE;
/


CREATE OR REPLACE PACKAGE BODY   FIN_ENCASH_PRINT_IE AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_TranId	   	Varchar2(10);              -- Input to procedure
	vi_TranDate		Varchar2(20);		    	            -- Input to procedure
  vi_NRC        Varchar2(50);
    
  CURSOR ExtractDataForMB (ci_TranId	   	Varchar2,	
			ci_TranDate		Varchar2) IS
      
     /*select CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID as "Tran_Id" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" , 
       accounts.uniqueid as "NRC" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as "Payee_Address" ,  
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.BANK_CODE as "BankCode" ,
       CUSTOM_CTD_DTD_ACLI_VIEW.branch_code AS "BranchCode" ,
      CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE as "Cur",
       CUSTOM_CTD_DTD_ACLI_VIEW.SOL_ID as "RegisterSol",
       gam.foracid ,
       gam.acct_name
    from 
       CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW CUSTOM_CTD_DTD_ACLI_VIEW ,tbaadm.gam,CRMUSER.accounts accounts
    where
    TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(ci_TranId))
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
       and CUSTOM_CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       --and CUSTOM_CTD_DTD_ACLI_VIEW.gl_sub_head_code  in('70111','70101')
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 is not null
       and CUSTOM_CTD_DTD_ACLI_VIEW.RPT_CODE IN('IBREM','REMIT','REMIB')
       and CUSTOM_CTD_DTD_ACLI_VIEW.acid = gam.acid
       and accounts.orgkey = gam.cif_id;*/
       
       select CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID as "Tran_Id" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" , 
      -- accounts.uniqueid as "NRC" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR  as "NRC",
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as "Payee_Address" ,  
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" , 
       CUSTOM_CTD_DTD_ACLI_VIEW.BANK_CODE as "BankCode" ,
       CUSTOM_CTD_DTD_ACLI_VIEW.branch_code AS "BranchCode" ,
      CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE as "Cur",
       CUSTOM_CTD_DTD_ACLI_VIEW.SOL_ID as "RegisterSol",
       gam.foracid ,
       gam.acct_name
    from 
       CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW CUSTOM_CTD_DTD_ACLI_VIEW ,tbaadm.gam--,CRMUSER.accounts accounts
    where
    TRIM(CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(upper(ci_TranId))
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
       and CUSTOM_CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       and CUSTOM_CTD_DTD_ACLI_VIEW.part_tran_type  = 'C'
       --and CUSTOM_CTD_DTD_ACLI_VIEW.gl_sub_head_code  in('70111','70101')
       and CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 is not null
       and CUSTOM_CTD_DTD_ACLI_VIEW.RPT_CODE IN('IBREM','REMIT','REMIB')
       and CUSTOM_CTD_DTD_ACLI_VIEW.acid = gam.acid;
 

  PROCEDURE FIN_ENCASH_PRINT_IE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
      v_tranId CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_ID%type; 
      v_tranAmt CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
      v_nrc CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
      v_payeeAddress CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2%type;
      v_payeeName CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_RMKS%type;
      v_outTranDate CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE%type;
      v_phoneNo CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.REF_NUM%type;
      vii_branchCode CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.Branch_Code%type;
      v_drawee TBAADM.USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO%type;
      v_draweeName TBAADM.USER_ADDTL_DET_TABLE.ADDTL_DETAIL_INFO%type;
      v_branchCode TBAADM.BRANCH_CODE_TABLE.BR_code%type;
      v_faxNo CUSTOM.CUSTOM_CTH_DTH_VIEW.REMARKS%type;
      v_branchName varchar(200);
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
   
    
     IF NOT ExtractDataForMB%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForMB (vi_TranId, vi_TranDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataForMB%ISOPEN THEN
		--{
			FETCH	ExtractDataForMB
			INTO	 v_tranId, v_tranAmt, v_nrc, v_payeeAddress, 
       v_payeeName, v_outTranDate, 
       v_phoneNo, vii_bankCode, vii_branchCode,vi_cur,v_registerSol,v_drawee,v_draweeName;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataForMB%NOTFOUND THEN
			--{
				CLOSE ExtractDataForMB;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
   
  BEGIN
    SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName"
    INTO v_RegisterBankName
    FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
      TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = v_registerSol
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01'
    and BRANCH_CODE_TABLE.bank_code = '116';
  END;
  
 /* BEGIN 
    SELECT acc.uniqueid  into vi_NRC
     FROM CRMUSER.ACCOUNTS ACC, TBAADM.GAM GAM ,CUSTOM.custom_ctd_dtd_acli_view CTD
     WHERE ACC.ORGKEY = GAM.CIF_ID
     AND  GAM.ACID = CTD.ACID 
     AND  trim(CTD.TRAN_ID) = trim(upper(vi_TranId))
     and ctd
     and  ctd.tran_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
     and CUSTOM_CTD_DTD_ACLI_VIEW.DEL_FLG = 'N'
     and rownum  = 1;
  END;*/
  BEGIN
    
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------   
   
  
  if vii_branchCode is null then vii_branchCode := '-';
  end if;
  
  if v_RegisterBankName is null or v_RegisterBankName = ''  then v_RegisterBankName := '-';
  end if;
-------------------------------------------------------------------------------
    -- GET FAX NO
-------------------------------------------------------------------------------

 select 
         distinct(CUSTOM_CTH_DTH_VIEW.REMARKS) as "fax_no"
         INTO
         v_faxNo
      from 
         CUSTOM.CUSTOM_CTH_DTH_VIEW CUSTOM_CTH_DTH_VIEW
      where
         TRIM(CUSTOM_CTH_DTH_VIEW.TRAN_ID) =  trim(upper(vi_TranId))
         and CUSTOM_CTH_DTH_VIEW.TRAN_DATE = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' );  

    END;
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------


    out_rec:=	(v_tranId            || '|' ||
					v_tranAmt      		     	 || '|' ||
          v_nrc      			         || '|' ||
         --vi_NRC                    || '|' ||
          v_payeeAddress      		 || '|' ||
					v_payeeName	             || '|' ||
					to_char(to_date(v_outTranDate,'dd/Mon/yy'), 'dd/MM/yyyy')      			|| '|' ||
					v_phoneNo      			     || '|' ||
  				v_faxNo                  || '|' ||
          v_registerSol             || '|' ||
          v_drawee                 || '|' ||
          v_draweeName             || '|' ||
          vi_cur                   || '|' ||
          v_RegisterBankName);
			dbms_output.put_line(out_rec);
  END FIN_ENCASH_PRINT_IE;

END FIN_ENCASH_PRINT_IE;
/
