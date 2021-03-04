CREATE OR REPLACE PACKAGE               FIN_AUTO_LINK_SCHEDULE AS 

 PROCEDURE FIN_AUTO_LINK_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_AUTO_LINK_SCHEDULE;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_AUTO_LINK_SCHEDULE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
	vi_TranDate		Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  --vi_SchemeCode		Varchar2(6);		    	    -- Input to procedure
  --vi_entryUserId	Varchar2(20);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData for Debit 
-----------------------------------------------------------------------------

  CURSOR ExtractDataDebit (	ci_TranDate VARCHAR2, 	ci_branchCode VARCHAR2, ci_currency VARCHAR2)
  IS
  select trim(ctd.tran_id),
  case when CTD.PART_TRAN_TYPE = 'D' then gam.FORACID  end AS "DebitAccountID",
 case when CTD.PART_TRAN_TYPE = 'C' then gam.FORACID  end AS "CreditAccountID",
    ctd.TRAN_AMT as "TranAmt",
    gam.SCHM_TYPE as "SchemeType",    
    ctd.PART_TRAN_TYPE as "TranType"
  from custom.CUSTOM_CTD_DTD_ACLI_VIEW ctd , tbaadm.gam gam 
  where ctd.acid = gam.acid
  and ctd.TRAN_PARTICULAR like '%Sweep%'
  and ctd.TRAN_DATE = TO_DATE( CAST (  ci_TranDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and ctd.dth_init_sol_id = ci_branchCode
  AND CTD.PSTD_FLG = 'Y'
  AND CTD.BANK_ID  = '01'
  and gam.ACCT_CRNCY_CODE = upper(ci_currency)
  order by ctd.tran_id,gam.schm_type desc;
  
  
--------------------------------------------------------------------------------
                -- CURSOR ExtractData for Credit --
--------------------------------------------------------------------------------
  
  
  PROCEDURE FIN_AUTO_LINK_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      Tran_id TBAADM.CTD_DTD_ACLI_VIEW.tran_id%type;
    v_CAccountId TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_DAccountId TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_TranAmt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_DSchemeType TBAADM.GENERAL_ACCT_MAST_TABLE.SCHM_TYPE%type;
    v_DTranType TBAADM.CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE%type;
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
    
    vi_TranDate :=outArr(0);		
    vi_currency :=outArr(1);
    vi_branchCode :=outArr(2);		
    
  -------------------------------------------------------------------------------------------
  if( vi_TranDate is null or vi_currency is null or vi_branchCode is null   ) then
        --resultstr := 'No Data For Report';
       out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
          		 '-' || '|' || '-' || '|' ||'-' || '|' || '-'
                 || '|' || 0 || '|' ||'-' || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  ---------------------------------------------------------------------------------------
 
----------------------------FOR DEBIT-------------------------------------------    
    
    IF NOT ExtractDataDebit%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataDebit (vi_TranDate  , vi_branchCode , vi_currency);
			--}
			END;

		--}
		END IF;
        
    IF ExtractDataDebit%ISOPEN THEN
		--{
			FETCH	ExtractDataDebit
			INTO	Tran_id,v_DAccountId,v_CAccountId,  v_TranAmt ,v_DSchemeType,v_DTranType  ;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataDebit%NOTFOUND THEN
			--{
				CLOSE ExtractDataDebit;
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

     out_rec:=	( Tran_id   || '|' ||  
     
					v_DAccountId     || '|' || v_CAccountId     || '|' ||   
					v_TranAmt      	|| '|' ||
          v_DSchemeType		|| '|' ||
          v_DTranType      || '|' ||
         
					v_BranchName	  || '|' ||
					v_BankAddress   || '|' ||
					v_BankPhone     || '|' ||
          v_BankFax      );
  
			dbms_output.put_line(out_rec);
  END FIN_AUTO_LINK_SCHEDULE;

END FIN_AUTO_LINK_SCHEDULE;
/
