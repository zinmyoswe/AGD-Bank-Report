CREATE OR REPLACE PACKAGE FIN_LOAN_REGISTER_LISTING1 AS 

  PROCEDURE FIN_LOAN_REGISTER_LISTING1(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_LOAN_REGISTER_LISTING1;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                           FIN_LOAN_REGISTER_LISTING1 AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	
	--vi_startDate		Varchar2(10);		    	    -- Input to procedure
  --vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_date    VARCHAR2(10); 
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeCode		Varchar2(5);		    	    -- Input to procedure
  vi_currency	   	Varchar2(3);               -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData_SL (ci_date Varchar2, ci_SchemeCode VARCHAR2 ,ci_currency VARCHAR2,ci_branchCode VARCHAR2)
  IS
select 
   distinct GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Account Name" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM as "Total Limit" ,
  abs(eab.tran_date_bal) as "Outstanding Limit" , 
   (select LIM_EXP_DATE from tbaadm.lht where GENERAL_ACCT_MAST_TABLE.acid = lht.acid and serial_num = 
   (select max(serial_num) from tbaadm.lht where acid = GENERAL_ACCT_MAST_TABLE.acid)) as "Expired Date",
   (select gam.foracid from tbaadm.gam gam
    where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = GENERAL_ACCT_MAST_TABLE.acid) ) as "Account Number"
    
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE,tbaadm.eab eab
where
   GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N' 
   And General_Acct_Mast_Table.Bank_Id = '01'
   and eab.tran_date_bal <> 0
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE in('LAA','CAA')
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
   and GENERAL_ACCT_MAST_TABLE.acid=eab.acid
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code=eab.eab_crncy_code
   and eab.eod_date<= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and eab.end_eod_date>= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   union all
select 
   distinct GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Account Name" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM as "Total Limit" , 
   abs(GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT) as "Outstanding Limit" , 
   (select LIM_EXP_DATE from tbaadm.lht where GENERAL_ACCT_MAST_TABLE.acid = lht.acid and serial_num = 
   (select max(serial_num) from tbaadm.lht where acid = GENERAL_ACCT_MAST_TABLE.acid)) as "Expired Date",
   (select gam.foracid from tbaadm.gam gam
    where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = GENERAL_ACCT_MAST_TABLE.acid) ) as "Account Number"
    
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE  --3380006000010012
where
   GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N' 
   And General_Acct_Mast_Table.Bank_Id = '01'
   and GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT <> 0 
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE in('LAA','CAA')
   and GENERAL_ACCT_MAST_TABLE.acct_opn_date <= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
   and GENERAL_ACCT_MAST_TABLE.acid not in ( select eab.acid from tbaadm.eab,tbaadm.gam 
                                             where gam.acid = eab.acid
                                             and gam.acct_crncy_code = upper(ci_currency)
                                             and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
                                             and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE in('LAA','CAA')
                                             and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
                                             and eab.eod_date<= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                             and eab.end_eod_date>= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )  );
   
   
 
 ----------------------------------------------------------------------------------------------------------  
CURSOR ExtractData (ci_date Varchar2, ci_SchemeCode VARCHAR2 ,ci_currency VARCHAR2, ci_branchCode VARCHAR2)
  IS
  select 
   distinct GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Account Name" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM as "Total Limit" , 
   eab.tran_date_bal as "Outstanding Limit" , 
   LA_ACCT_MAST_TABLE.LIM_EXP_DATE as "Expired Date",
   (select gam.foracid from tbaadm.gam gam
    where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = GENERAL_ACCT_MAST_TABLE.acid) ) as "Account Number"
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE ,TBAADM.lht LA_ACCT_MAST_TABLE,tbaadm.eab eab
where
   GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N' 
   and LA_ACCT_MAST_TABLE.acid = GENERAL_ACCT_MAST_TABLE.acid 
   And General_Acct_Mast_Table.Bank_Id = '01'
   and  eab.tran_date_bal <> 0 
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE = 'LAA' 
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
      and GENERAL_ACCT_MAST_TABLE.acid=eab.acid
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code=eab.eab_crncy_code
  and eab.eod_date<= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and eab.end_eod_date>= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 

  union all 
  
  
  select 
    distinct GENERAL_ACCT_MAST_TABLE.FORACID as "Account No." , 
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME as "Account Name" , 
   GENERAL_ACCT_MAST_TABLE.SANCT_LIM as "Total Limit" , 
   (GENERAL_ACCT_MAST_TABLE.clr_bal_amt) as "Outstanding Limit" , 
   LA_ACCT_MAST_TABLE.LIM_EXP_DATE as "Expired Date",
   (select gam.foracid from tbaadm.gam gam
    where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = GENERAL_ACCT_MAST_TABLE.acid) ) as "Account Number"
    
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE , TBAADM.lht LA_ACCT_MAST_TABLE --3380006000010012 
where
   GENERAL_ACCT_MAST_TABLE.DEL_FLG = 'N' 
   And General_Acct_Mast_Table.Bank_Id = '01'
   and GENERAL_ACCT_MAST_TABLE.acid = LA_ACCT_MAST_TABLE.acid
   and GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT <> 0 
   and GENERAL_ACCT_MAST_TABLE.acct_crncy_code = upper(ci_currency)
   and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
   and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE in('LAA')
   and GENERAL_ACCT_MAST_TABLE.acct_opn_date <= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
   and GENERAL_ACCT_MAST_TABLE.acid not in ( select eab.acid 
                                            from tbaadm.eab,tbaadm.gam 
                                             where gam.acid = eab.acid
                                             and gam.acct_crncy_code = upper(ci_currency)
                                             and GENERAL_ACCT_MAST_TABLE.SCHM_CODE = upper(ci_SchemeCode)
                                             and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE in('LAA')
                                             and GENERAL_ACCT_MAST_TABLE.SOL_ID = ci_branchCode
                                             and eab.eod_date<= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                             and eab.end_eod_date>= TO_DATE( CAST ( ci_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )  );
    
 -------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------  
  
  
  PROCEDURE FIN_LOAN_REGISTER_LISTING1(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_HP_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_TotalLimit varchar2(100);
    v_OutstandingLimit varchar2(100);
    v_ExpiredDate tbaadm.general_acct_mast_table.acct_opn_date%type;
    v_Account_Number varchar2(50);
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
    
    --vi_startDate  :=  outArr(0);		
    --vi_endDate    :=  outArr(1);
         vi_date   := outArr(0);
         vi_SchemeCode	:=  outArr(1);
         vi_currency   :=  outArr(2);
    vi_branchCode :=  outArr(3);	
    
    

  -----------------------------------------------------------------------------
  
  
  if(vi_date is null or vi_SchemeCode is null or vi_currency is null or vi_branchCode is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || '-' || '|' ||
		          '-' || '|' || '-' || '|' || '-' || '|' || '-' );
		          
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  -------------------------------------------------------------------------------------------------
    
    if vi_SchemeCode like '%S%' then
    
    IF NOT ExtractData_SL%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_SL (vi_date,  vi_SchemeCode ,vi_currency,vi_branchCode );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_SL%ISOPEN THEN
		--{
			FETCH	ExtractData_SL
			INTO	   v_HP_AccountNumber,v_AccountName ,v_TotalLimit,v_OutstandingLimit,v_ExpiredDate,v_Account_Number ;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_SL%NOTFOUND THEN
			--{
				CLOSE ExtractData_SL;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
    else 
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_date ,  vi_SchemeCode ,vi_currency, vi_branchCode);
			--}
			END;
		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	   v_HP_AccountNumber,v_AccountName ,v_TotalLimit,v_OutstandingLimit,v_ExpiredDate,v_Account_Number ;
      

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
    
    end if;
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into    v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
    END;

    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
             v_HP_AccountNumber	|| '|' ||
             v_AccountName 	|| '|' ||
             v_TotalLimit 	|| '|' ||
             v_OutstandingLimit 	|| '|' ||
             to_char(to_date(v_ExpiredDate,'dd/Mon/yy'), 'dd/MM/yyyy') 	|| '|' ||
					   v_BranchName	|| '|' ||
					   v_BankAddress      			|| '|' ||
					   v_BankPhone || '|' ||
             v_BankFax || '|' ||
             v_Account_Number);
  
			dbms_output.put_line(out_rec);
    
  END FIN_LOAN_REGISTER_LISTING1;

END FIN_LOAN_REGISTER_LISTING1;
/
