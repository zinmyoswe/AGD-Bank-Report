CREATE OR REPLACE PACKAGE                            FIN_HP_INSTALLMENT_LISTING
AS
PROCEDURE FIN_HP_INSTALLMENT_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_HP_INSTALLMENT_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                      FIN_HP_INSTALLMENT_LISTING AS
  
--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;    -- Input Parse Array
  vi_date        	Varchar2(20);              -- Input to procedure
	vi_loanType	   	Varchar2(20);              -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_SchemeCode   Varchar2(6);              -- Input to procedure
  vi_branchId     Varchar2(5);              -- Input to procedure
 
  CURSOR ExtractDataHPByBranch (ci_date VARCHAR2, ci_loanType VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,
  ci_branchId VARCHAR2) IS

   SELECT distinct
  (SELECT gam.foracid FROM tbaadm.gam WHERE lam.op_acid=gam.acid)           AS accountno,
  GAM.FORACID AS HP_No,
  GAM.ACCT_NAME AS Acc_Name,
 lrs.num_of_dmds AS Payment_Term,
   lam.dis_amt as start_amt,
    lrs.flow_amt as total_paid_amt ,
     lam.dealer_id
 
FROM TBAADM.ldt ldt,
  tbaadm.gam gam ,
  tbaadm.lam lam,
  custom.coa_mp coa,
  tbaadm.lrs lrs 
WHERE ldt.ACID       = GAM.ACID
AND lam.acid         = gam.acid
and lrs.acid = gam.acid 
and coa.gl_sub_head_code = gam.gl_sub_head_code
AND GAM.BANK_ID      = '01'
AND GAM.DEL_FLG      = 'N'
AND GAM.ACCT_CLS_FLG = 'N'
and  lrs.num_of_dmds != 0
and  lrs.flow_amt !=0
AND coa.group_code  LIKE   '%' || ci_loanType || '%'  
AND GAM.SCHM_TYPE LIKE   '%' || ci_SchemeType || '%'
AND GAM.SCHM_CODE  LIKE '%' || ci_SchemeCode || '%'
AND GAM.SOL_ID LIKE '%' || ci_branchId || '%' 
AND  ldt.DMD_EFF_Date = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY')
group by lam.op_acid, GAM.FORACID ,lrs.flow_amt,
  GAM.ACCT_NAME ,
   lam.dis_amt,
 lrs.num_of_dmds ,
  lam.dealer_id
  order by  lam.dealer_id
;
  
  ------------------------------------------------------------------------------------
  -----------------------------for next month--------------------------------------------
  
    CURSOR ExtractDataHPByBranchforNext (ci_date VARCHAR2,ci_loanType VARCHAR2 , ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,
  ci_branchId VARCHAR2) IS

   SELECT distinct
  (SELECT gam.foracid FROM tbaadm.gam WHERE lam.op_acid=gam.acid)           AS accountno,
  GAM.FORACID AS HP_No,
  GAM.ACCT_NAME AS Acc_Name,
 lrs.num_of_dmds AS Payment_Term,
 lam.dis_amt as start_amt,
    lrs.flow_amt as total_paid_amt ,
     lam.dealer_id
 
FROM 
  tbaadm.gam gam ,
  tbaadm.lam lam,
  custom.coa_mp coa,
  tbaadm.lrs lrs 
WHERE 
 lam.acid         = gam.acid
and lrs.acid = gam.acid 
and coa.gl_sub_head_code = gam.gl_sub_head_code
AND GAM.BANK_ID      = '01'
AND GAM.DEL_FLG      = 'N'
AND GAM.ACCT_CLS_FLG = 'N'
--and  lrs.num_of_dmds != 0
and  lrs.flow_amt !=0
AND coa.group_code  LIKE   '%' || ci_loanType || '%'  
AND GAM.SCHM_TYPE LIKE   '%' || ci_SchemeType || '%'
AND GAM.SCHM_CODE  LIKE '%' || ci_SchemeCode || '%'
AND GAM.SOL_ID LIKE '%' || ci_branchId || '%' 
AND  lrs.next_dmd_date  = to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY') 
--AND  lrs.next_dmd_date =  ADD_MONTHS(to_date(cast(ci_date as varchar(10)),'dd-MM-YYYY'),1)
group by lam.op_acid, GAM.FORACID ,lrs.flow_amt,
  GAM.ACCT_NAME ,
 lrs.num_of_dmds ,
  lam.dis_amt,
  lam.dealer_id
  order by  lam.dealer_id;
  ------------------------------------------------------------------------

 PROCEDURE FIN_HP_INSTALLMENT_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_AccountNo           TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_HP_No             TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_Acc_Name           TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_Payment_Term     TBAADM.lrs.num_of_dmds%type;
      v_startamount      TBAADM.lam.dis_amt%type;
     v_total_paidamt TBAADM.lrs.flow_amt%type;
     v_dealerID tbaadm.  lam.dealer_id%type;
        v_BranchName TBAADM.sol.sol_desc%type;
    v_BankAddress  Varchar(100);
    --  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
      v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
         sdate tbaadm.SOL_GROUP_CONTROL_TABLE.Db_Stat_Date%type;
          v_Date_Flg TBAADM.GENERAL_ACCT_MAST_TABLE.del_flg%type;
   
      
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
      vi_date     :=outArr(0);
      vi_loanType  :=outArr(1);
      vi_SchemeType :=outArr(2);
      vi_SchemeCode :=outArr(3);
      vi_branchId   :=outArr(4);

---------------------------------------------------------------
 ---------------------------------------------------------------
  IF vi_loanType = 'Demand Loan' then
       vi_loanType := 'A21';
 ELSif    vi_loanType ='OverDraft' then
        vi_loanType := 'A23';
         ELSif    vi_loanType ='Hire Purchase' then
        vi_loanType := 'A24';
       ELSif    vi_loanType ='StaffLoan' then
        vi_loanType := 'A25';
        ELSE  vi_loanType := '';
    END IF;
    -------------------------------------------------------
---------------------------------------------------------------
  IF vi_loanType IS  NULL or vi_loanType = ''  THEN
  vi_loanType := '';
  END IF;
  -----------------------------------------------------
---------------------------------------------------------------
  IF vi_SchemeType IS  NULL or vi_SchemeType = ''  THEN
  vi_SchemeType := '';
  END IF;
  -----------------------------------------------------
   IF vi_SchemeCode IS  NULL or vi_SchemeCode = ''  THEN
  vi_SchemeCode := '';
  END IF;
  --------------------------------------------------------
   IF vi_branchId IS  NULL or vi_branchId = ''  THEN
  vi_branchId := '';
  END IF;
 ------------------------------------------------------------
 
 --v_Date_Flg := '';
 
 
      
 select Db_Stat_Date into sdate from tbaadm.SOL_GROUP_CONTROL_TABLE where sol_group_id = '01';
 Select Case When To_Date( Cast ( vi_date As Varchar(10) ) , 'dd-MM-yyyy' ) >  To_Date( Cast ( trim(to_char(to_date(sdate,'dd-Mon-yy'), 'dd-MM-yyyy')) As Varchar(10) ) , 'dd-MM-yyyy' ) 
       Then 1 Else 0 End As Aa
      INTO v_Date_Flg 
      FROM DUAL;
 dbms_output.put_line(v_Date_Flg);
 ---------------------------------------------------------------
IF(v_Date_Flg = '0') THEN
IF NOT ExtractDataHPByBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataHPByBranch (vi_date, vi_loanType,vi_SchemeType,vi_SchemeCode,	vi_branchId);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataHPByBranch%ISOPEN THEN
		--{
			FETCH	ExtractDataHPByBranch
			INTO	 v_AccountNo  ,        
      v_HP_No        ,     
      v_Acc_Name  ,        
      v_Payment_Term   ,  
      v_startamount     ,
      v_total_paidamt  ,
      v_dealerID ;
      

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
    -----------------------------------------------------------------------------
ELSE

IF NOT ExtractDataHPByBranchforNext%ISOPEN THEN  --fornext
        --{
          BEGIN
          --{
            OPEN ExtractDataHPByBranchforNext ( vi_date,vi_loanType,vi_SchemeType,vi_SchemeCode,	vi_branchId);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataHPByBranchforNext%ISOPEN THEN
        --{
          FETCH	ExtractDataHPByBranchforNext
          INTO  v_AccountNo  ,        
      v_HP_No        ,     
      v_Acc_Name  ,        
      v_Payment_Term   ,  
      v_startamount     ,
      v_total_paidamt  ,
      v_dealerID ;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataHPByBranchforNext%NOTFOUND THEN
          --{
            CLOSE ExtractDataHPByBranchforNext;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
     --}
        END IF;  
 
    
    -----------------------------------------------------------------------
    

if vi_branchId is not null then
 BEGIN
 
 SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchId AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
END; end if;

    out_rec:=	(    v_AccountNo            || '|' || 
                   v_HP_No                || '|' ||
                   v_Acc_Name             || '|' ||
                   v_Payment_Term        || '|' ||
                       v_startamount   || '|' || 
      v_total_paidamt  || '|' || 
      v_dealerID || '|' || 
                    v_BranchName  || '|' || 
      v_BankAddress  || '|' || 
      v_BankPhone  || '|' || 
      v_BankFax );
			dbms_output.put_line(out_rec);
  END FIN_HP_INSTALLMENT_LISTING;

END FIN_HP_INSTALLMENT_LISTING;
/
