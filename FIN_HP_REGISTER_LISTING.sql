CREATE OR REPLACE PACKAGE                                    FIN_HP_REGISTER_LISTING AS 

  PROCEDURE FIN_HP_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_HP_REGISTER_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                         FIN_HP_REGISTER_LISTING AS

-----------------------------------------------------------------------------
------Update user - Saung Hnin OO -----------------------------
-----Update Date - 28-4-2017------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-----------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;      -- Input Parse Array
	vi_StartDate	   	Varchar2(10);             -- Input to procedure
	vi_EndDate    		Varchar2(10);		    	    -- Input to procedure
  vi_Currency    		Varchar2(3);		    	    -- Input to procedure
  vi_schme_code     Varchar2(10);		    	    -- Input to procedure
  vi_branchCode     Varchar2(5);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------

  CURSOR ExtractData (	ci_StartDate VARCHAR2,
			ci_EndDate VARCHAR2,  ci_Currency Varchar2 ,ci_schme_code Varchar2,ci_branchCode Varchar2)
  IS
  
  select gam.acct_name,
   gam.foracid,
   gam.acid,
   gam.ACCT_OPN_DATE,
   gam.SANCT_LIM,
   lrs.NUM_OF_FLOWS,
   lrs.flow_start_date,
   (select dealer_remarks from tbaadm.li_dmd where  gam.acid = li_dmd.remittance_account) as descb, --mcd.COMMODITY_DESC,
   (select dealer_name from tbaadm.li_dmd where  gam.acid = li_dmd.remittance_account) as dealer_name 
   from tbaadm.gam gam, tbaadm.lam lam, tbaadm.lrs lrs
   where --gam.foracid ='3110005000100010'
    lam.acid = gam.acid
   and lrs.acid = gam.acid
   and gam.schm_code =upper(ci_schme_code)
   and gam.schm_type ='LAA'
   and gam.ACCT_OPN_DATE >= TO_DATE( CAST (ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and gam.ACCT_OPN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and gam.sol_id like '%' || ci_branchCode || '%'
   and gam.del_flg ='N'
   and lam.del_flg ='N'
   and lrs.del_flg ='N'
   and gam.bank_id ='01'
   and lrs.bank_id ='01'
   and lam.bank_id ='01'
   and gam.acct_crncy_code =upper(ci_Currency)
   and lam.lam_crncy_code =upper(ci_Currency)
   and gam.acct_cls_flg ='N'
   AND lrs.FLOW_ID not like  'INDEM%'
   order by gam.ACCT_OPN_DATE, gam.acct_name ,gam.acid;
   

  PROCEDURE FIN_HP_REGISTER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
     v_name TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
     v_accountId TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
v_acid TBAADM.GENERAL_ACCT_MAST_TABLE.acid%type;
     v_acctOpenDate TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_OPN_DATE%type;
     v_loanAmt TBAADM.GENERAL_ACCT_MAST_TABLE.SANCT_LIM%type;
     v_loanPeriod TBAADM.LRS.NUM_OF_FLOWS%type;
     v_loanStartDate TBAADM.LA_ACCT_MAST_TABLE.EI_PERD_START_DATE%type;
     v_stockName TBAADM.MAINT_COMMODITY_DETAILS.COMMODITY_DESC%type;
     v_dealerName TBAADM.LI_DMD.DEALER_NAME%type;
     v_brachShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
     v_bankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
     v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
     v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      
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
    vi_StartDate :=outArr(0);	   	
	  vi_EndDate :=outArr(1);   		   		    
    vi_Currency :=outArr(2);
    vi_schme_code :=outArr(3);
    vi_branchCode :=outArr(4);
    
    
    -----------------------------------------------------
		-- Checking whether the cursor is open if not
		-- it is opened
		-----------------------------------------------------
 -------------------------------------------------------------------------------
 
/* if( vi_StartDate is null or vi_EndDate is null or vi_Currency is null or vi_schme_code is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||  '-' || '|' ||
		           '-' || '|' || '-' || '|' || '-' || '|' || '-'  || '|' || '-'    );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
 
 */
 
  IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
  vi_branchCode := '';
  END IF; 
 -----------------------------------------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(vi_StartDate,
						vi_EndDate,vi_Currency,vi_schme_code, vi_branchCode);
			--}
			END;

		--}
		END IF;
    
   
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_name, v_accountId,v_acid, v_acctOpenDate, v_loanAmt, 
            v_loanPeriod, v_loanStartDate, v_stockName, v_dealerName;
      

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
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
    
    BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
If vi_branchCode is not null then
      select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_brachShortName, v_bankAddress, v_bankPhone, v_bankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
        
  end if;
    END;

    out_rec:=	(
					v_accountId      			|| '|' ||
          to_char(to_date(v_acctOpenDate,'dd/Mon/yy'), 'dd/MM/yyyy')|| '|' ||
          v_loanAmt      			|| '|' ||
          to_char(v_loanPeriod)	|| '|' ||		
          to_char(to_date(v_loanStartDate,'dd/Mon/yy'), 'dd/MM/yyyy')|| '|' ||
					v_stockName      			|| '|' ||
					v_dealerName      			|| '|' ||
					v_brachShortName || '|' ||
          v_bankAddress || '|' ||
          v_bankPhone || '|' ||
					v_bankFax    || '|' ||
          v_name           );
  
			dbms_output.put_line(out_rec);
    
  END FIN_HP_REGISTER_LISTING;

END FIN_HP_REGISTER_LISTING;
/
