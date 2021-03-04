CREATE OR REPLACE PACKAGE        FIN_INSUFF_AMT_LIST_FOR_NEXT AS 

  PROCEDURE FIN_INSUFF_AMT_LIST_FOR_NEXT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 


END FIN_INSUFF_AMT_LIST_FOR_NEXT;
/


CREATE OR REPLACE PACKAGE BODY                                                  FIN_INSUFF_AMT_LIST_FOR_NEXT AS
  
--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;    -- Input Parse Array
  vi_date         	Varchar2(10);              -- Input to procedure
	vi_currency	   	Varchar2(3);              -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_SchemeCode   Varchar2(6);              -- Input to procedure
  vi_branchId     Varchar2(5);              -- Input to procedure
 
  CURSOR ExtractDataHPByBranch (ci_date VARCHAR2, ci_SchemeCode VARCHAR2,
  ci_currency VARCHAR2, ci_branchId VARCHAR2) IS

    SELECT 
    (select gam.foracid from tbaadm.gam where lam.op_acid=gam.acid) as accountno,
    GAM.FORACID as loanno,
    GAM.ACCT_NAME, 
    (select gam.CLR_BAL_AMT from tbaadm.gam where lam.op_acid=gam.acid) as outstandingamt,
    sum(ldt.DMD_amt) as installmentamt,
    sum(ldt.TOT_ADJ_AMT) as paidamt,
    sum(ei.NRML_ACCRUED_AMOUNT_DR - ei.NRML_INTEREST_AMOUNT_DR) as Interest
    
  FROM 
    TBAADM.ldt ldt,tbaadm.gam,tbaadm.lam, tbaadm.entity_interest_table ei,tbaadm.lrs
  WHERE 
    ldt.ACID = GAM.ACID
    and lam.acid = gam.acid
    and ei.ENTITY_ID=gam.acid
    and gam.acid = lrs.acid
    --and ldt.TOT_ADJ_AMT !=0
   -- and lrs.flow_id = 'PRDEM'
    and lam.op_acid in (select g.acid 
    from tbaadm.gam g where lam.op_acid = g.acid
  and g.clr_bal_amt < ldt.dmd_amt)
  and gam.clr_bal_amt <tot_adj_amt
  
 --  and ldt.dmd_amt <> ldt.tot_adj_amt
    AND GAM.BANK_ID = '01'
    AND GAM.DEL_FLG = 'N'
    AND GAM.ACCT_CLS_FLG = 'N'
    AND GAM.SCHM_TYPE = UPPER('LAA')
    AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
    AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
    AND GAM.SOL_ID like   '%' || ci_branchId || '%'
  --  and gam.foracid ='HP301000787'
   -- and lrs.next_dmd_date <= '5-JUN-2017'
-- and lrs.next_dmd_date >= '5-JUN-2017'
 and  lrs.next_dmd_date = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY')
 --and  TO_CHAR(lrs.next_dmd_date, 'YYYY-MM') >= to_char(to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY'))
  -- and  TO_CHAR(ei.accrued_upto_date_dr, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM') 
--and  TO_CHAR(lrs.next_dmd_date, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM') 
    group by GAM.FORACID, GAM.ACCT_NAME, GAM.CLR_BAL_AMT ,lam.op_acid
    ORDER BY GAM.FORACID ,lam.op_acid;

 PROCEDURE FIN_INSUFF_AMT_LIST_FOR_NEXT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_LoanNo            TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountID             TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountName           TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_oustandingAmount     tbaadm.ldt.dmd_amt%type;
      v_InstallAmount    tbaadm.ldt.dmd_amt%type;
      v_PaidAmount    tbaadm.ldt.dmd_amt%type;
      v_Interest       NUMBER;
    --  v_dealerID  varchar(50);
    --  v_dealerName  varchar(200);
      v_solId                 TBAADM.GAM.SOL_ID%TYPE;
       v_BranchName tbaadm.sol.sol_desc%type;
      v_BankAddress varchar(200);
      v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      v_currencyCode          TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_CRNCY_CODE%type;
      
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
      vi_date        :=outArr(0);
      vi_SchemeCode :=outArr(1);
      vi_currency   :=outArr(2);
      vi_branchId   :=outArr(3);

if (vi_SchemeCode is null or vi_currency is null ) then
  out_rec:=	( 
					'-'      	    || '|' ||
          '-'  || '|' ||
          '-'          || '|' ||
          0    || '|' ||
					0	|| '|' ||
					'-'                || '|' ||
          '-'           || '|' ||
          '-' );
  out_retCode:= 1;
        RETURN;        
  end if;
  
  IF vi_branchId IS  NULL or vi_branchId = ''  THEN
  vi_branchId := '';
  END IF;
  
  

IF NOT ExtractDataHPByBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataHPByBranch ( vi_date,vi_SchemeCode, vi_currency,	vi_branchId);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataHPByBranch%ISOPEN THEN
		--{
			FETCH	ExtractDataHPByBranch
			INTO	 v_AccountID ,v_LoanNo, v_AccountName,v_oustandingAmount,v_InstallAmount,v_PaidAmount,v_Interest;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataHPByBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataHPByBranch;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
  ---------------------------------------------------------------------------
/*begin 
select ldmt.dealer_id  ,ldmt.dealer_name into v_dealerID ,v_dealerName
from TBAADM.li_dealer_master_table ldmt ,tbaadm.gam gam 
where gam.acid = ldmt.remittance_account;
-- AND GAM.SCHM_TYPE = UPPER('LAA')
--   AND GAM.SCHM_CODE = UPPER(vi_SchemeCode)
 --  AND GAM.ACCT_CRNCY_CODE = UPPER(vi_currency)
  --  AND GAM.SOL_ID like   '%' || vi_branchId || '%';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dealerID := '';

end ;*/


 BEGIN
 if vi_branchId is not null then
 SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchId AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   end if;
END; 


    out_rec:=	( 
					v_AccountID      	    || '|' ||
          v_LoanNo || '|' ||
          v_AccountName         || '|' ||
          v_oustandingAmount    || '|' ||
					v_InstallAmount	|| '|' ||         
          v_Interest || '|' || v_PaidAmount || '|' ||
    --  v_dealerID  || '|' ||
        --  v_dealerName || '|' ||
          v_BranchName ||'|'||
					v_BankAddress               || '|' ||
          v_BankPhone          || '|' ||
          v_BankFax);
  
			dbms_output.put_line(out_rec);
  END FIN_INSUFF_AMT_LIST_FOR_NEXT;

END FIN_INSUFF_AMT_LIST_FOR_NEXT;
/
