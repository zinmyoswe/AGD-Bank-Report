CREATE OR REPLACE PACKAGE                             FIN_DAILY_ENCASH_REMMITTANCE AS 

  PROCEDURE FIN_DAILY_ENCASH_REMMITTANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
END FIN_DAILY_ENCASH_REMMITTANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                               FIN_DAILY_ENCASH_REMMITTANCE AS



-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_TranDate		Varchar2(20);		    	            -- Input to procedure
  vi_branchCode Varchar2(10);
 -- v_thisBank Varchar2(20);
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------
    CURSOR ExtractData (	ci_TranDate		Varchar2,ci_branchCode Varchar2) IS
  SELECT distinct *
  FROM (
  select 
           CTH_DTH_VIEW.REMARKS as "fax_no",
           bct.br_name as BankName,
           sol.sol_desc as ShortName,
           CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" ,
           CTD_DTD_ACLI_VIEW.TRAN_TYPE as "Type",
           CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as "NRC" ,  
           CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" ,  
           CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" ,
           CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" ,
           CTD_DTD_ACLI_VIEW.RPT_CODE ,
           CTD_DTD_ACLI_VIEW.tran_id  
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
           custom.custom_CTH_DTH_VIEW CTH_DTH_VIEW   , tbaadm.bct bct ,tbaadm.sol sol
        where
           TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
           and CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
           and CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and bct.bank_code = CTD_DTD_ACLI_VIEW.bank_code
           and bct.br_code = CTD_DTD_ACLI_VIEW.branch_code
           and sol.sol_id = CTD_DTD_ACLI_VIEW.dth_init_sol_id
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.branch_code = (select sol.micr_branch_code
                                                from tbaadm.sol sol ,tbaadm.bct bct
                                                where sol.micr_branch_code = CTD_DTD_ACLI_VIEW.branch_code 
                                                and sol.bank_code = CTD_DTD_ACLI_VIEW.bank_code
                                                and sol.micr_branch_code = bct.br_code
                                                and sol.bank_code = bct.bank_code
                                                and sol.bank_code ='116'
                                                and substr(bct.br_short_name,1,3) =sol.abbr_br_name
                                                and sol.sol_id = ci_branchCode
                                                and sol.sol_id !='20300')
           and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type in ('RI','CI')
           and CTH_DTH_VIEW.TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) )
    
    UNION ALL 
    
     SELECT 
       CTH_DTH_VIEW.REMARKS as "fax_no",
       bank.BANK_NAME as  BankName,
       bct.br_name as ShortName,
       CTD_DTD_ACLI_VIEW.TRAN_DATE as "TRAN_DATE" ,
       CTD_DTD_ACLI_VIEW.TRAN_TYPE as "Type",
       CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as "NRC" ,  
       CTD_DTD_ACLI_VIEW.TRAN_RMKS as "Payee_Name" ,  
       CTD_DTD_ACLI_VIEW.REF_NUM as "Phone_No" ,
       CTD_DTD_ACLI_VIEW.TRAN_AMT as "Tran_Amt" ,
       CTD_DTD_ACLI_VIEW.RPT_CODE ,
       CTD_DTD_ACLI_VIEW.tran_id
       
   FROM
       custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
       custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW,
       TBAADM.BRANCH_CODE_TABLE bct ,
       tbaadm.BANK_CODE_TABLE bank

    WHERE
       
       TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
       AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
       AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       AND CTH_DTH_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      -- AND CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
       AND  CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID  = ci_branchCode
       and CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID  != '20300'
       AND CTD_DTD_ACLI_VIEW.RPT_CODE in ('IBREM','REMIB','REMIT')
       --AND CTD_DTD_ACLI_VIEW.part_TRAN_TYPE = 'C'
        and CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE in ( 'BI')
        and CTD_DTD_ACLI_VIEW.uad_module_key is not null
        and CTD_DTD_ACLI_VIEW.uad_module_id is not null
      -- AND CTD_DTD_ACLI_VIEW.VFD_USER_ID not like '%null%'
     -- and CTD_DTD_ACLI_VIEW.PART_TRAN_SRL_NUM like '%2'
      /* AND (TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID),CTD_DTD_ACLI_VIEW.Tran_date) not IN(SELECT TRIM(T.TRAN_ID),t.Tran_date
                                                  FROM TBAADM.TCT T
                                                  WHERE ENTITY_CRE_FLG = 'Y' 
                                                  AND DEL_FLG = 'N'
                                                  AND T.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                               )*/
        and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
                                                  
    
       AND bct.BANK_CODE  = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bct.BR_CODE   = CTD_DTD_ACLI_VIEW.Branch_Code
       AND bank.BANK_CODE = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bank.DEL_FLG = 'N'
       AND bank.BANK_ID = '01')q
       
       ORDER BY q.RPT_CODE desc;

  PROCEDURE FIN_DAILY_ENCASH_REMMITTANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    -- TODO: Implementation required for PROCEDURE FIN_DAILY_ENCASH_REMMITTANCE.FIN_DAILY_ENCASH_REMMITTANCE
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
     v_faxNo custom.CUSTOM_CTH_DTH_VIEW.REMARKS%type;
     v_BankName varchar(200);
     v_BankShortName varchar(200);
     v_TranDate TBAADM.CTD_DTD_ACLI_VIEW.TRAN_DATE%type;
     v_Type  custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_TYPE%type;
     v_nrc TBAADM.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
     v_payeeName TBAADM.CTD_DTD_ACLI_VIEW.TRAN_RMKS%type;
     v_Phone tbaadm.CTD_DTD_ACLI_VIEW.REF_NUM%type; 
     v_TranAmt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
     v_RPT TBAADM.CTD_DTD_ACLI_VIEW.RPT_CODE%type;
     v_tran_id custom.CUSTOM_CTD_DTD_ACLI_VIEW.tran_id%type;
    
      v_BranchName tbaadm.sol.sol_desc%type;
    v_BankAddress varchar(200);
     
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
    
  
		vi_TranDate   := outArr(0);
    vi_branchCode := outArr(1);
   
   ------------------------------------------------------------------------------
   if( vi_TranDate is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
		            '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-'  );
					
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
   
   
   -------------------------------------------------------------------------
   
   
-------------------------FOR AGDTO AGD Remittance-------------------------------
    /*   select sot.MICR_BRANCH_CODE into   v_thisBank 
       from TBAADM.SERVICE_OUTLET_TABLE sot, tbaadm.branch_code_table bct
       where sot.bank_code = bct.BANK_CODE
       and    sot.br_code = bct.BR_CODE
       and sot.sol_id = vi_branchCode; */
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ( vi_TranDate,vi_branchCode);	
			--}
			END;

		--}
		END IF;
  
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	  v_faxNo, v_BankName, v_BankShortName,v_TranDate,v_Type, v_nrc,v_payeeName,
             v_Phone,v_TranAmt,v_RPT,v_tran_id;
      
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
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
    END;

  
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------

    out_rec:=	(
					v_faxNo      			|| '|' ||
					v_BankName        || '|' ||
					v_BankShortName   || '|' ||
          v_TranDate        || '|' ||
          v_Type            || '|' ||
          v_nrc             || '|' ||
          v_payeeName       || '|' ||
          v_Phone           || '|' ||
          v_TranAmt         || '|' ||
         
          v_BranchName      || '|' ||
          v_BankAddress     || '|' ||
          v_BankPhone       || '|' ||
          v_BankFax         || '|' ||
          v_RPT             || '|' ||
          v_tran_id
        );
  
			dbms_output.put_line(out_rec);
  END FIN_DAILY_ENCASH_REMMITTANCE;

END FIN_DAILY_ENCASH_REMMITTANCE;
/
