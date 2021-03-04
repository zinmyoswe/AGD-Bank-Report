CREATE OR REPLACE PACKAGE        FIN_INSUFF_AMT_LIST_CUST_2 AS 

  PROCEDURE FIN_INSUFF_AMT_LIST_CUST_2(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 


END FIN_INSUFF_AMT_LIST_CUST_2;
/


CREATE OR REPLACE PACKAGE BODY                                                  FIN_INSUFF_AMT_LIST_CUST_2 AS
  
--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;    -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_SchemeCode   Varchar2(6);              -- Input to procedure
  vi_branchId     Varchar2(5);              -- Input to procedure
 
  CURSOR ExtractDataHPByBranch (ci_SchemeCode VARCHAR2,
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
    and lrs.flow_id = 'PRDEM'
    and lam.op_acid in (select g.acid 
    from tbaadm.gam g where lam.op_acid = g.acid
    and g.clr_bal_amt < ldt.dmd_amt)
    and ldt.dmd_amt <> ldt.tot_adj_amt
    AND GAM.BANK_ID = '01'
    AND GAM.DEL_FLG = 'N'
    AND GAM.ACCT_CLS_FLG = 'N'
    AND GAM.SCHM_TYPE = UPPER('LAA')
    AND GAM.SCHM_CODE = UPPER(ci_SchemeCode)
    AND GAM.ACCT_CRNCY_CODE = UPPER(ci_currency)
    AND GAM.SOL_ID like   '%' || ci_branchId || '%'
    --and  TO_CHAR(ei.accrued_upto_date_dr, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM') 
    and  TO_CHAR(lrs.next_dmd_date, 'YYYY-MM')  =  TO_CHAR(sysdate, 'YYYY-MM') 
    group by GAM.FORACID, GAM.ACCT_NAME, GAM.CLR_BAL_AMT ,lam.op_acid
    ORDER BY GAM.FORACID ,lam.op_acid;

 PROCEDURE FIN_INSUFF_AMT_LIST_CUST_2(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_LoanNo            TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountID             TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountName           TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_oustandingAmount     tbaadm.ldt.dmd_amt%type;
      v_InstallAmount    tbaadm.ldt.dmd_amt%type;
      v_PaidAmount    tbaadm.ldt.dmd_amt%type;
      v_Interest       NUMBER;
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
      vi_SchemeCode :=outArr(0);
      vi_currency   :=outArr(1);
      vi_branchId   :=outArr(2);

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
				OPEN ExtractDataHPByBranch ( vi_SchemeCode, vi_currency,	vi_branchId);
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
    
    -----------FOR ODA ----------
  /*  IF UPPER(vi_SchemeType) = 'ODA' THEN
      IF vi_branchId is not null then
        IF NOT ExtractDataLoanOdByBranch%ISOPEN THEN
          BEGIN
            OPEN ExtractDataLoanOdByBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency, vi_branchId);
          END;
        END IF;
        IF ExtractDataLoanOdByBranch%ISOPEN THEN
          FETCH	ExtractDataLoanOdByBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount, v_solId, 
          v_branchName,
          v_currencyCode;
	

        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
          IF ExtractDataLoanOdByBranch%NOTFOUND THEN
            CLOSE ExtractDataLoanOdByBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      ELSE
        IF NOT ExtractDataLoanOdAllBranch%ISOPEN THEN
          BEGIN
            OPEN ExtractDataLoanOdAllBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency);
          END;
        END IF;
 
        IF ExtractDataLoanOdAllBranch%ISOPEN THEN
          FETCH	ExtractDataLoanOdAllBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount,v_currencyCode;
	

        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
          IF ExtractDataLoanOdAllBranch%NOTFOUND THEN
            CLOSE ExtractDataLoanOdAllBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF; 
      -----------FOR LAA ----------
   IF UPPER(vi_SchemeType) = ci_SchemeType THEN
	IF vi_branchId is not null then
		IF UPPER(vi_SchemeCode) = 'AGDNL' THEN
        IF NOT ExtractDataLoanOdByBranch%ISOPEN THEN
           BEGIN
            OPEN ExtractDataLoanOdByBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency, vi_branchId);
          END;
        END IF;
		 
        IF ExtractDataLoanOdByBranch%ISOPEN THEN
		  
          FETCH	ExtractDataLoanOdByBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount, v_solId, 
          v_branchName,
          v_currencyCode;
			
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
          IF ExtractDataLoanOdByBranch%NOTFOUND THEN
			
            CLOSE ExtractDataLoanOdByBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      ELSIF UPPER(vi_SchemeCode) = 'AGDHP' THEN
        IF NOT ExtractDataHPByBranch%ISOPEN THEN
           BEGIN
            OPEN ExtractDataHPByBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency, vi_branchId);
          END;
        END IF;
		 
        IF ExtractDataHPByBranch%ISOPEN THEN
		  
          FETCH	ExtractDataHPByBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount, v_solId, 
          v_branchName,
          v_currencyCode;
			
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
          IF ExtractDataHPByBranch%NOTFOUND THEN
			
            CLOSE ExtractDataHPByBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      ELSE
        IF NOT ExtractDataStaffLoanByBranch%ISOPEN THEN 
          BEGIN
            OPEN ExtractDataStaffLoanByBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency, vi_branchId);
          END;
        END IF;
        IF ExtractDataStaffLoanByBranch%ISOPEN THEN
        
          FETCH	ExtractDataStaffLoanByBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount, v_solId, 
          v_branchName,
          v_currencyCode;
        
      
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
          IF ExtractDataStaffLoanByBranch%NOTFOUND THEN
        
            CLOSE ExtractDataStaffLoanByBranch;
            out_retCode:= 1;
          RETURN;
        
          END IF;
        END IF;	
      END IF;
	ELSE
		IF UPPER(vi_SchemeCode) = 'AGDNL' THEN
        IF NOT ExtractDataLoanOdAllBranch%ISOPEN THEN
           BEGIN
            OPEN ExtractDataLoanOdAllBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency);
          END;
        END IF;
		 
        IF ExtractDataLoanOdAllBranch%ISOPEN THEN
		  
          FETCH	ExtractDataLoanOdAllBranch
          INTO	v_AccountID,v_LoanNo, v_AccountName ,
          v_oustandingAmount, v_insufficientAmount,v_currencyCode;
			
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
          IF ExtractDataLoanOdAllBranch%NOTFOUND THEN
			
            CLOSE ExtractDataLoanOdAllBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      ELSIF UPPER(vi_SchemeCode) = 'AGDHP' THEN
        IF NOT ExtractDataHPAllBranch%ISOPEN THEN
           BEGIN
            OPEN ExtractDataHPAllBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency);
          END;
        END IF;
		 
        IF ExtractDataHPAllBranch%ISOPEN THEN
		  
          FETCH	ExtractDataHPAllBranch
          INTO	v_AccountID, v_LoanNo,v_AccountName ,
          v_oustandingAmount, v_insufficientAmount,v_currencyCode;
			
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
          IF ExtractDataHPAllBranch%NOTFOUND THEN
			
            CLOSE ExtractDataHPAllBranch;
            out_retCode:= 1;
            RETURN;
          END IF;
        END IF;
      ELSE
        IF NOT ExtractDataStaffLoanAllBranch%ISOPEN THEN 
          BEGIN
            OPEN ExtractDataStaffLoanAllBranch (	vi_SchemeType, vi_SchemeCode ,
            vi_currency);
          END;
        END IF;
        IF ExtractDataStaffLoanAllBranch%ISOPEN THEN
        
          FETCH	ExtractDataStaffLoanAllBranch
          INTO	v_AccountID, v_LoanNo,v_AccountName ,
          v_oustandingAmount, v_insufficientAmount,v_currencyCode;
        
      
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
          IF ExtractDataStaffLoanAllBranch%NOTFOUND THEN
        
            CLOSE ExtractDataStaffLoanAllBranch;
            out_retCode:= 1;
          RETURN;
        
          END IF;
        END IF;	
      END IF;
	END IF;
END IF;  
*/
if vi_branchId is not null then
 BEGIN
 
 SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchId AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
END; end if;

    out_rec:=	( 
					v_AccountID      	    || '|' ||
          v_LoanNo || '|' ||
          v_AccountName         || '|' ||
          v_oustandingAmount    || '|' ||
					v_InstallAmount	|| '|' ||         
          v_Interest || '|' || v_PaidAmount || '|' ||
          v_BranchName ||'|'||
					v_BankAddress               || '|' ||
          v_BankPhone          || '|' ||
          v_BankFax);
  
			dbms_output.put_line(out_rec);
  END FIN_INSUFF_AMT_LIST_CUST_2;

END FIN_INSUFF_AMT_LIST_CUST_2;
/
