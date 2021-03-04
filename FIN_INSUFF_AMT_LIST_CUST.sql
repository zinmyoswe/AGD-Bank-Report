CREATE OR REPLACE PACKAGE        FIN_INSUFF_AMT_LIST_CUST AS 

  PROCEDURE FIN_INSUFF_AMT_LIST_CUST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 


END FIN_INSUFF_AMT_LIST_CUST;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                             FIN_INSUFF_AMT_LIST_CUST AS
  
--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;    -- Input Parse Array
  vi_date        	Varchar2(20);              -- Input to procedure
	vi_currency	   	Varchar2(3);              -- Input to procedure
  vi_SchemeCode   Varchar2(6);              -- Input to procedure
  vi_branchId     Varchar2(5);              -- Input to procedure
 
  CURSOR ExtractDataHPByBranch (ci_date  VARCHAR2,ci_SchemeCode VARCHAR2,
  ci_currency VARCHAR2, ci_branchId VARCHAR2) IS
  
 select  P.accountno,
  P.loanno,
  P.Acc_name, 
  P.Install_amt,
sum(P.tot_overdueAmt),
sum(P.late_fee),
sum(P.Interest),
P.Tot_paid_amt,
  sum(P.outstandingamt),
/*P.Install_amt,
P.tot_overdueAmt,
P.late_fee,
P.Interest,
P.Tot_paid_amt,
P.outstandingamt,
*/
  P.dealer_name

   from ( SELECT 
    (select gam.foracid from tbaadm.gam where lam.op_acid=gam.acid) as accountno,
    GAM.FORACID as loanno,
    GAM.ACCT_NAME AS Acc_name, 
    (lrs.flow_amt) as Install_amt,
    (ldt.DMD_amt-ldt.TOT_ADJ_AMT) as tot_overdueAmt,
    (ei.penal_accrued_amount_dr) as late_fee ,
    (ei.NRML_ACCRUED_AMOUNT_DR - ei.NRML_INTEREST_AMOUNT_DR) as Interest,
    ldt.TOT_ADJ_AMT  AS Tot_paid_amt,
     (select gam.CLR_BAL_AMT from tbaadm.gam where lam.op_acid=gam.acid) as outstandingamt,
     lam.dealer_id  AS dealer_name  
  FROM 
    TBAADM.ldt ldt,tbaadm.gam,tbaadm.lam, tbaadm.entity_interest_table ei,tbaadm.lrs
  WHERE 
    ldt.ACID = GAM.ACID
    and lam.acid = gam.acid
    and ei.ENTITY_ID=gam.acid
   and gam.acid = lrs.acid
   -- and lrs.flow_id = 'PRDEM' 
    and lam.op_acid in (select g.acid 
    from tbaadm.gam g where lam.op_acid = g.acid)
    and lrs.flow_amt ! =0
    AND GAM.BANK_ID = '01'
    AND GAM.DEL_FLG = 'N'
    AND GAM.ACCT_CLS_FLG = 'N'  
    AND GAM.SCHM_TYPE = UPPER('LAA')
    AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
    AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
    AND GAM.SOL_ID like   '%' || ci_branchId || '%'
    and lrs.flow_amt != ldt.TOT_ADJ_AMT
  and  ldt.last_adj_date    = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY')

    union all 
   
    SELECT 
   (select gam.foracid from tbaadm.gam where lam.op_acid=gam.acid) as accountno,
    GAM.FORACID as loanno,
    GAM.ACCT_NAME AS Acc_name, 
    (lrs.flow_amt) as Install_amt,
    (ldt.DMD_amt-ldt.TOT_ADJ_AMT) as tot_overdueAmt,
    (ei.penal_accrued_amount_dr) as late_fee ,
    (ei.NRML_ACCRUED_AMOUNT_DR - ei.NRML_INTEREST_AMOUNT_DR) as Interest,
    ldt.TOT_ADJ_AMT  AS Tot_paid_amt,
     (select gam.CLR_BAL_AMT from tbaadm.gam where lam.op_acid=gam.acid) as outstandingamt,
     lam.dealer_id  AS dealer_name
  FROM 
    TBAADM.ldt ldt,tbaadm.gam,tbaadm.lam, tbaadm.entity_interest_table ei,tbaadm.lrs
  WHERE 
    ldt.ACID = GAM.ACID
    and lam.acid = gam.acid
    and ei.ENTITY_ID=gam.acid
   and gam.acid = lrs.acid
   -- and lrs.flow_id = 'PRDEM' 
    and lam.op_acid in (select g.acid 
    from tbaadm.gam g where lam.op_acid = g.acid)
   -- and( ldt.DMD_eff_Date != ldt.last_adj_date or ldt.last_adj_date is null)
    and lrs.flow_amt ! =0
    AND GAM.BANK_ID = '01'
    AND GAM.DEL_FLG = 'N'
    AND GAM.ACCT_CLS_FLG = 'N'
   AND GAM.SCHM_TYPE = UPPER('LAA')
    AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
    AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
    AND GAM.SOL_ID like   '%' || ci_branchId || '%'
    and lrs.flow_amt != ldt.TOT_ADJ_AMT
    and  TO_CHAR(ldt.dmd_eff_date, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM')
    and gam.acid not in ( select gam.acid
                      FROM TBAADM.ldt ldt,tbaadm.gam,tbaadm.lam, tbaadm.entity_interest_table ei,tbaadm.lrs
                      WHERE ldt.ACID = GAM.ACID
                      and lam.acid = gam.acid
                      and ei.ENTITY_ID=gam.acid
                      and gam.acid = lrs.acid
                      -- and lrs.flow_id = 'PRDEM' 
                      and lam.op_acid in (select g.acid 
                                          from tbaadm.gam g where lam.op_acid = g.acid)
                      and lrs.flow_amt ! =0
                      AND GAM.BANK_ID = '01'
                      AND GAM.DEL_FLG = 'N'
                      AND GAM.ACCT_CLS_FLG = 'N'  
                      AND GAM.SCHM_TYPE = UPPER('LAA')
                      AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
                      AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
                      AND GAM.SOL_ID like   '%' || ci_branchId || '%'
                      and lrs.flow_amt != ldt.TOT_ADJ_AMT
                      and  ldt.last_adj_date    = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY')))P
  group by P.accountno,
  P.loanno,
  P.Acc_name,
  P.Tot_paid_amt,
  P.Install_amt,
  P.dealer_name
  order by  P.dealer_name;
 
  
 /*select  P.accountno,
  P.loanno,
  P.Acc_name, 
P.Install_amt,
P.tot_overdueAmt,
P.late_fee,
P.Interest,
P.Tot_paid_amt,
P.outstandingamt,
  P.dealer_name
  from(
   SELECT 
   (select gam.foracid from tbaadm.gam where lam.op_acid=gam.acid) as accountno,
    GAM.FORACID as loanno,
    GAM.ACCT_NAME AS Acc_name, 
    (lrs.flow_amt) as Install_amt,
    (ldt.DMD_amt-ldt.TOT_ADJ_AMT) as tot_overdueAmt,
    (ei.penal_accrued_amount_dr) as late_fee ,
    (ei.NRML_ACCRUED_AMOUNT_DR - ei.NRML_INTEREST_AMOUNT_DR) as Interest,
    ldt.TOT_ADJ_AMT  AS Tot_paid_amt,
     (select gam.CLR_BAL_AMT from tbaadm.gam where lam.op_acid=gam.acid) as outstandingamt,
     lam.dealer_id  AS dealer_name
  FROM 
    TBAADM.ldt ldt,tbaadm.gam,tbaadm.lam, tbaadm.entity_interest_table ei,tbaadm.lrs
  WHERE 
    ldt.ACID = GAM.ACID
    and lam.acid = gam.acid
    and ei.ENTITY_ID=gam.acid
   and gam.acid = lrs.acid
   -- and lrs.flow_id = 'PRDEM' 
    and lam.op_acid in (select g.acid 
    from tbaadm.gam g where lam.op_acid = g.acid)
    and( ldt.DMD_eff_Date = ldt.last_adj_date or ldt.last_adj_date is null)
    and lrs.flow_amt ! =0
    AND GAM.BANK_ID = '01'
    AND GAM.DEL_FLG = 'N'
    AND GAM.ACCT_CLS_FLG = 'N'
   AND GAM.SCHM_TYPE = UPPER('LAA')
    AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
    AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
    AND GAM.SOL_ID like   '%' || ci_branchId || '%'
    and  (TO_CHAR(ldt.dmd_date, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM') 
    or  ldt.last_adj_date   = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY')))P
    order by  P.dealer_name;*/
    
 PROCEDURE FIN_INSUFF_AMT_LIST_CUST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_AccountID             TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_LoanNo            TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountName           TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_InstallAmount    tbaadm.ldt.dmd_amt%type;
      v_overDueAmt    tbaadm.ldt.dmd_amt%type;
      v_late_fee       tbaadm.eit.penal_accrued_amount_dr%type;
      v_Interest       NUMBER;
      v_PaidAmount    tbaadm.ldt.dmd_amt%type;
      v_oustandingAmount     tbaadm.ldt.dmd_amt%type;
      v_dealerID tbaadm. lam.dealer_id%type;
     -- v_solId                 TBAADM.GAM.SOL_ID%TYPE;
       v_BranchName tbaadm.sol.sol_desc%type;
      v_BankAddress varchar(200);
      v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      --v_currencyCode          TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_CRNCY_CODE%type;
      
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
       vi_date      :=outArr(0);
      vi_SchemeCode :=outArr(1);
      vi_currency   :=outArr(2);
      vi_branchId   :=outArr(3);

------------------------------------------------------------------------
  
  IF vi_branchId IS  NULL or vi_branchId = ''  THEN
  vi_branchId := '';
  END IF;
-------------------------------------------------------------------------
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
			INTO	 v_AccountID  ,        
      v_LoanNo ,          
      v_AccountName ,          
      v_InstallAmount ,  
      v_overDueAmt ,  
      v_late_fee  ,    
      v_Interest  ,    
      v_PaidAmount  , 
      v_oustandingAmount  ,
      v_dealerID;
      

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
    
  ---------------------------------  
if vi_branchId is not null then
 BEGIN
 
 SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchId AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
END; end if;
---------------------------------------------------------------------
 IF v_InstallAmount IS  NULL or v_InstallAmount = ''  THEN
  v_InstallAmount := '';
  END IF;

 IF v_overDueAmt IS  NULL or v_overDueAmt = ''  THEN
  v_overDueAmt := '';
  END IF;
  
   IF v_late_fee IS  NULL or v_late_fee = ''  THEN
  v_late_fee := 0;
  END IF;
   IF v_Interest IS  NULL or v_Interest = ''  THEN
  v_Interest := 0;
  END IF;
  
   IF v_PaidAmount IS  NULL or v_PaidAmount = ''  THEN
  v_PaidAmount := 0;
  END IF;
   IF v_oustandingAmount IS  NULL or v_oustandingAmount = ''  THEN
  v_oustandingAmount := 0;
  END IF;

--------------------------------------------------
    out_rec:=	( 
				   v_AccountID    || '|' ||   
      v_LoanNo   || '|' ||     
      v_AccountName   || '|' ||     
      v_InstallAmount  || '|' ||  
      v_overDueAmt  || '|' ||  
      v_late_fee   || '|' ||    
      v_Interest   || '|' ||    
      v_PaidAmount   || '|' || 
      v_oustandingAmount    || '|' || 
      v_dealerID  || '|' || 
          v_BranchName ||'|'||
					v_BankAddress               || '|' ||
          v_BankPhone          || '|' ||
          v_BankFax);
  
			dbms_output.put_line(out_rec);
  END FIN_INSUFF_AMT_LIST_CUST;

END FIN_INSUFF_AMT_LIST_CUST;
/
