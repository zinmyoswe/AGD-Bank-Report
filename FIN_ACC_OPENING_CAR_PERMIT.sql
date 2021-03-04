CREATE OR REPLACE PACKAGE        FIN_ACC_OPENING_CAR_PERMIT AS 

PROCEDURE FIN_ACC_OPENING_CAR_PERMIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ACC_OPENING_CAR_PERMIT;
/


CREATE OR REPLACE PACKAGE BODY                      FIN_ACC_OPENING_CAR_PERMIT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
	vi_DateBefore		Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_DateBefore VARCHAR2, ci_currency VARCHAR2,  ci_branchCode VARCHAR2)
  IS
  SELECT  
  gam.foracid as "AccountNumber",
  gam.acct_name as "AcountName",
  accounts.uniqueid as "NRC Number",
  address.address_line1 || address.address_line2 ||  address.address_line3 ||','||  address.city ||','|| address.state ||','|| address.country as "Address",
  gam.acct_crncy_code as "Currency",
  detail.tran_amt as "Open Amount"
FROM 
  tbaadm.general_acct_mast_table gam,
  CRMUSER.address address,
  CRMUSER.accounts accounts,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW detail
WHERE 
  gam.schm_code = upper('AGCAR')
  and gam.acct_opn_date <= TO_DATE( CAST ( ci_DateBefore AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and gam.del_flg = 'N'
  and gam.acct_cls_flg = 'N'
  and gam.bank_id ='01'
  and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
  and gam.acct_crncy_code = UPPER(ci_currency)
  and gam.SOL_ID  = ci_branchCode
   and detail.tran_date= gam.acct_opn_date
  and detail.tran_particular_code='CHD'
  and gam.cif_id     = address.orgkey
  and gam.CIF_ID = accounts.ORGKEY
  and detail.acid         = gam.acid
 and (address.ADDRESSID,gam.foracid) in (  SELECT  min(address.ADDRESSID),gam.foracid
                                             from CRMUSER.address address,tbaadm.gam gam
                                             where gam.cif_id = address.ORGKEY
                                              and gam.del_flg = 'N'
                                              and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'
                                              and  gam.SOL_ID  = ci_branchCode
                                              and gam.schm_code = upper('AGCAR')  
                                              and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
                                              and gam.acct_opn_date <= TO_DATE( CAST ( ci_DateBefore AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                          
                                              group by gam.foracid)
  and (detail.tran_id,detail.acid, gam.acct_opn_date) in ( select
                                                    Min(detail.tran_id),detail.acid,gam.acct_opn_date
                                              from 
                                              tbaadm.general_acct_mast_table gam,
                                              custom.CUSTOM_CTD_DTD_ACLI_VIEW detail
                                              where 
                                               gam.schm_code = upper('AGCAR')
                                              and gam.acct_opn_date <= TO_DATE( CAST ( ci_DateBefore AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                              and gam.del_flg = 'N'
                                              and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'                      
                                              and gam.acct_crncy_code = UPPER('mmk')
                                              and gam.SOL_ID  = ci_branchCode
                                               and detail.tran_date= gam.acct_opn_date
                                              and detail.tran_particular_code='CHD'
                                              and detail.acid         = gam.acid                                 
                                               group by gam.acct_opn_date,detail.acid)

  order by 
    gam.acct_opn_date ASC,gam.foracid asc  ;
  
  PROCEDURE FIN_ACC_OPENING_CAR_PERMIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_NRC_Number CRMUSER.accounts.uniqueid%type;
    v_Address varchar2(100);
    v_Currency tbaadm.general_acct_mast_table.acct_crncy_code%type;
    v_OpenAmount custom.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
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
    
    vi_DateBefore  :=   outArr(0);	
    vi_currency    :=   outArr(1);
    vi_branchCode  :=   outArr(2);	
-----------------------------------------------------------------------------------------------------------------

 if( vi_DateBefore is null or vi_currency is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

--------------------------------------------------------------------------------------------------------------------
   
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_DateBefore ,vi_currency ,vi_branchCode 
     );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_AccountNumber,v_AccountName,v_NRC_Number,
            v_Address,v_Currency,v_OpenAmount;
      

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
         SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          trim(v_AccountNumber)     || '|' ||
					v_AccountName	            || '|' ||
          v_NRC_Number              || '|' ||
          v_Currency                || '|' ||
          v_Address                 || '|' ||
          v_OpenAmount              || '|' ||
					v_BranchName	            || '|' ||
					v_BankAddress      			  || '|' ||
					v_BankPhone               || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
      
  END FIN_ACC_OPENING_CAR_PERMIT;

END FIN_ACC_OPENING_CAR_PERMIT;
/
