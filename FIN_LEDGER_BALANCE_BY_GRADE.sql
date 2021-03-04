CREATE OR REPLACE PACKAGE                                                              FIN_LEDGER_BALANCE_BY_GRADE AS 

  PROCEDURE FIN_LEDGER_BALANCE_BY_GRADE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_LEDGER_BALANCE_BY_GRADE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                    FIN_LEDGER_BALANCE_BY_GRADE AS

  -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(5);              -- Input to procedure
	vi_startAmount		Varchar2(50);		    	    -- Input to procedure
  vi_endAmount		  Varchar2(50);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeCode		Varchar2(6);		    	    -- Input to procedure
    vi_EOD_DATE	   	Varchar2(20);               -- Input to procedure
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------

  CURSOR ExtractData (ci_EOD_DATE VARCHAR2,	ci_branchCode VARCHAR2, ci_startAmount VARCHAR2, ci_endAmount VARCHAR2,
      ci_currency VARCHAR2,ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2
			 )
  IS
  select 
   gam.FORACID as "Account No." , 
   gam.ACCT_NAME as "Name" , 
   eab.Tran_date_bal as "Balance"  ,
   gam.clr_bal_amt as "Today_bal"
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.eab
where
   gam.acct_cls_flg = 'N'
   and gam.acid = tbaadm.eab.acid
   and gam.del_flg = 'N'
   and gam.bank_id = '01'
   and gam.CLR_BAL_AMT >= ci_startAmount
   and gam.CLR_BAL_AMT <= ci_endAmount
   and eab.Tran_date_bal >= ci_startAmount
   and eab.Tran_date_bal <= ci_endAmount
   and gam.acct_crncy_code  = upper(ci_currency )
   and eab.eab_crncy_code  = upper(ci_currency )
   and gam.SCHM_TYPE =upper( ci_SchemeType )
   and gam.SCHM_CODE like   '%' || ci_SchemeCode || '%' 
   and gam.SOL_ID =   ci_branchCode
   and eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' );
   
/*  union all
select 
   gam.FORACID as "Account No." , 
   gam.ACCT_NAME as "Name" , 
   gam.clr_bal_amt as "Balance" ,
   gam.clr_bal_amt as "Today_bal"
  
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam
 
 
where
   gam.acct_cls_flg = 'N'
   and gam.del_flg = 'N'
   and gam.bank_id = '01'
   and gam.acct_crncy_code  = upper(ci_currency )
   and gam.SCHM_TYPE =upper( ci_SchemeType )
   and gam.SCHM_CODE  like   '%' || ci_SchemeCode || '%' 
   and gam.SOL_ID =   ci_branchCode
   and gam.CLR_BAL_AMT >= ci_startAmount
   and gam.CLR_BAL_AMT <= ci_endAmount
    and gam.clr_bal_amt <> 0
   --and gam.foracid ='3440005000001018'
   and gam.acct_opn_date <=TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' ) 
   and gam.acid not in (select eab.acid 
                        from TBAADM.GENERAL_ACCT_MAST_TABLE gam ,tbaadm.eab
                        where gam.acct_cls_flg = 'N'
                        and gam.acid = tbaadm.eab.acid
                        and gam.del_flg = 'N'
                        and gam.bank_id = '01'
                        and gam.CLR_BAL_AMT >= ci_startAmount
                        and gam.CLR_BAL_AMT <= ci_endAmount
                        and eab.Tran_date_bal >= ci_startAmount
                        and eab.Tran_date_bal <= ci_endAmount
                        and gam.acct_crncy_code  = upper(ci_currency )
                        and eab.eab_crncy_code  = upper(ci_currency )
                        and gam.SCHM_TYPE =upper( ci_SchemeType )
                        and gam.SCHM_CODE  like   '%' || ci_SchemeCode || '%' 
                        and gam.SOL_ID =   ci_branchCode
                        --and gam.foracid ='3440005000001018'
                      and eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
                      and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' ));*/
   
-----------------------------------------------------------------------------------------------------------


  CURSOR ExtractDatawithoutamt (ci_EOD_DATE VARCHAR2,	ci_branchCode VARCHAR2,
      ci_currency VARCHAR2,ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2
			 )
  IS
  select 
   gam.FORACID as "Account No." , 
   gam.ACCT_NAME as "Name" , 
   eab.Tran_date_bal as "Balance" ,
   gam.clr_bal_amt as "Today_bal"
  
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam ,tbaadm.eab
 
 
where
   gam.acct_cls_flg = 'N'
   and gam.acid = tbaadm.eab.acid
   and gam.del_flg = 'N'
   and gam.bank_id = '01'
   and gam.acct_crncy_code  = upper(ci_currency )
   and eab.eab_crncy_code  = upper(ci_currency )
   and gam.SCHM_TYPE =upper( ci_SchemeType )
   and gam.SCHM_CODE  like   '%' || ci_SchemeCode || '%' 
   and gam.SOL_ID =   ci_branchCode 
   and eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' );
 /*  union all
select 
   gam.FORACID as "Account No." , 
   gam.ACCT_NAME as "Name" , 
   gam.clr_bal_amt as "Balance" ,
   gam.clr_bal_amt as "Today_bal"
  
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam
 
 
where
   gam.acct_cls_flg = 'N'
   and gam.del_flg = 'N'
   and gam.bank_id = '01'
   and gam.acct_crncy_code  = upper(ci_currency )
   and gam.SCHM_TYPE =upper( ci_SchemeType )
   and gam.SCHM_CODE  like   '%' || ci_SchemeCode || '%' 
   and gam.SOL_ID =   ci_branchCode
    and gam.clr_bal_amt <> 0
   --and gam.foracid ='3440005000001018'
   and gam.acct_opn_date <=TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' ) 
   and gam.acid not in (select eab.acid 
                        from TBAADM.GENERAL_ACCT_MAST_TABLE gam ,tbaadm.eab
                        where gam.acct_cls_flg = 'N'
                        and gam.acid = tbaadm.eab.acid
                        and gam.del_flg = 'N'
                        and gam.bank_id = '01'
                        and gam.acct_crncy_code  = upper(ci_currency )
                        and eab.eab_crncy_code  = upper(ci_currency )
                        and gam.SCHM_TYPE =upper( ci_SchemeType )
                        and gam.SCHM_CODE  like   '%' || ci_SchemeCode || '%' 
                        and gam.SOL_ID =   ci_branchCode
                        --and gam.foracid ='3440005000001018'
                      and eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
                      and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' ));*/

------------------------------------------------------------------------------------------------------------

  PROCEDURE FIN_LEDGER_BALANCE_BY_GRADE(inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_accountNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_name TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_balanceAmt TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type; 
      v_branchShortName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type; 
      v_bankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
      v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type; 
      v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      v_Today_bal tbaadm.gam.clr_bal_amt%type;
      
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
   
   vi_EOD_DATE :=outArr(0);	
    vi_startAmount :=outArr(1);		
    vi_endAmount :=outArr(2);	
    vi_currency :=outArr(3);
     vi_SchemeType	:=outArr(4);	
    vi_SchemeCode	:=outArr(5);
     vi_branchCode :=outArr(6);	
    
    if( vi_EOD_DATE is null or vi_currency is null or vi_SchemeType is null or vi_branchCode is null    ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || 
		           '-' || '|' || '-' || '|' || '-' );                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
   
   IF vi_SchemeCode IS  NULL or vi_SchemeCode = ''  THEN
  vi_SchemeCode := '';
  END IF;
  
   IF (vi_startAmount IS  NULL OR vi_startAmount = '') or ( vi_endAmount IS  NULL OR vi_endAmount = '')THEN
    --IF vi_endAmount IS  NULL OR vi_endAmount = '' THEN
   --{
   
  ----------------------------------------------------
    IF NOT ExtractDatawithoutamt%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDatawithoutamt (	
         vi_EOD_DATE,vi_branchCode  ,vi_currency , vi_SchemeType , vi_SchemeCode
			 );
			--}
			END;

		--}
		END IF;
    
    IF ExtractDatawithoutamt%ISOPEN THEN
		--{
			FETCH	ExtractDatawithoutamt
			INTO	v_accountNo, v_name, v_balanceAmt,v_Today_bal;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDatawithoutamt%NOTFOUND THEN
			--{
				CLOSE ExtractDatawithoutamt;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;

    
  ElSE
   IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_EOD_DATE,
         vi_branchCode , 
      vi_startAmount , vi_endAmount
      ,vi_currency , vi_SchemeType , vi_SchemeCode
			 );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_accountNo, v_name, v_balanceAmt,v_Today_bal;
      

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

    End If;
    
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
         v_branchShortName, v_bankAddress, v_bankPhone, v_bankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE;
    END;
    
    if( TO_DATE( sysdate, 'dd-MM-yyyy' ) like TO_DATE( vi_EOD_DATE, 'dd-MM-yyyy' ) ) then
         out_rec:=	(v_accountNo      			|| '|' ||
          v_name      			|| '|' ||
					v_Today_bal	|| '|' ||
					v_branchShortName      			|| '|' ||
					v_bankAddress      			|| '|' ||
					v_bankPhone || '|' ||
          v_bankFax );
    else 
        out_rec:=	(v_accountNo      			|| '|' ||
          v_name      			|| '|' ||
					v_balanceAmt	|| '|' ||
					v_branchShortName      			|| '|' ||
					v_bankAddress      			|| '|' ||
					v_bankPhone || '|' ||
          v_bankFax );
    end if;
      
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
  
  
			dbms_output.put_line(out_rec);
  END FIN_LEDGER_BALANCE_BY_GRADE;

END FIN_LEDGER_BALANCE_BY_GRADE;
/
