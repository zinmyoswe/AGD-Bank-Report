CREATE OR REPLACE PACKAGE               FIN_DL_OUTSTANDING_BALANCE AS 

 PROCEDURE FIN_DL_OUTSTANDING_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DL_OUTSTANDING_BALANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                          FIN_DL_OUTSTANDING_BALANCE AS
/******************************************************************************
 NAME:      FIN_DL_OUTSTANDING_BALANCE
 PURPOSE:
 Coder   :  Moe Htet Kyaw

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_DateBefore      VARCHAR2(10);               -- Input to procedure
  vi_branchCode     VARCHAR2(5);      
  vi_currency       Varchar2(3);                -- Input to procedure
  vi_SchemeType     Varchar2(10);           
  vi_SchemeCode     Varchar2(10);
  vi_curreneyType   Varchar2(20);
  vi_CollectralType Varchar2(20);
  vi_rate           DECIMAL;
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_DML_LEDGER_BALANCE_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData with Business Type
--------------------------------------------------------------------------------
CURSOR ExtractData (ci_DateBefore VARCHAR2,ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2,ci_currency VARCHAR2,
   ci_CollectralType VARCHAR2,ci_branchCode VARCHAR2
 )
IS
  SELECT     distinct  
        BRANCH_CODE_TABLE.BR_SHORT_NAME AS BRANCHNAME,
    GAM.FORACID AS ACCOUNTNUMBER,
         GAM.ACCT_NAME AS ACCTNAME,
         LAM.EI_PERD_START_DATE AS STARTDATE,
         LAM.EI_PERD_END_DATE AS ENDDATE,
         EIT.INTEREST_RATE AS INTERESTRATE,
         LAM.DIS_AMT AS LIMITAMT,
        abs( GAM.CLR_BAL_AMT )AS BALANCE,
        ' ' AS COLLECTRAL,
         LAM.PAST_DUE_FLG AS NPL,
         case when  gam.acid in (select acid from tbaadm.LLADT)  then 'Y' else 'N' end AS Legal,
        sum (ldt.DMD_amt-ldt.TOT_ADJ_AMT) as tot_overdueAmt,
    sum(ei.penal_accrued_amount_dr) as late_fee ,
    sum(ei.NRML_ACCRUED_AMOUNT_DR - ei.NRML_INTEREST_AMOUNT_DR) as Interest,
       (select ldmt.dealer_id from TBAADM.li_dealer_master_table ldmt where ldmt.dealer_id= lam.dealer_id ) as dealer_id,
        (select ldmt.dealer_name from TBAADM.li_dealer_master_table ldmt where ldmt.dealer_id= lam.dealer_id ) as dealer_name
    FROM   tbaadm.LA_ACCT_MAST_TABLE LAM,tbaadm.GENERAL_ACCT_MAST_TABLE GAM,
            TBAADM.ENTITY_INTEREST_TABLE EIT--,TBAADM.CID CID--
            , TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
            TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE,  TBAADM.ldt ldt,tbaadm.entity_interest_table ei,tbaadm.eab eab
            
    WHERE  GAM.ACID = LAM.ACID
    and    ldt.ACID = GAM.ACID
             and ei.ENTITY_ID=gam.acid
    AND    EIT.ENTITY_ID = GAM.ACID
    and gam.acid = eab.acid
    and gam.acct_crncy_code = eab.eab_crncy_code
   -- AND    GAM.FORACID = CID.PROPERTY_DOCUMENT_NUM
    and eab.EOD_DATE <= TO_DATE( CAST ( ci_DateBefore AS VARCHAR(10) ) , 'dd-MM-yyyy' )
     and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_DateBefore AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    --AND    LAM.EI_PERD_START_DATE <= to_date(CAST(ci_DateBefore AS VARCHAR(10)), 'dd-MM-yyyy')
    AND    GAM.SCHM_TYPE  LIKE '%' || UPPER(ci_SchemeType) || '%'
    AND    GAM.SCHM_CODE  LIKE '%' || uPPER( ci_SchemeCode) || '%'
    AND    GAM.ACCT_CRNCY_CODE LIKE '%' || UPPER(ci_currency) || '%'
    AND    GAM.SOL_ID  LIKE '%' || ci_branchCode || '%'
    AND    gam.del_flg = 'N'
    AND    gam.acct_cls_flg = 'N'
    and    lam.dealer_id is not null
    AND    gam.bank_id ='01'
    and    SERVICE_OUTLET_TABLE.SOL_ID = gam.sol_id
    AND    SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
    AND  SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
      AND SERVICE_OUTLET_TABLE.BANK_ID = '01' 
      
       group by    GAM.FORACID ,
        BRANCH_CODE_TABLE.BR_SHORT_NAME ,
         GAM.ACCT_NAME ,
         LAM.EI_PERD_START_DATE ,
         LAM.EI_PERD_END_DATE ,
         EIT.INTEREST_RATE ,
         LAM.DIS_AMT,
         GAM.CLR_BAL_AMT,
         LAM.PAST_DUE_FLG ,
         gam.acid , 
        
          lam.dealer_id 
          order by dealer_id
     ;
     

-----------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_DL_OUTSTANDING_BALANCE(  inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
 
  
   v_branchshortname       TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
   v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
   v_AcctName      TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
   v_StartDate     TBAADM.LAM.EI_PERD_START_DATE%TYPE;
   v_EndDate       TBAADM.LAM.EI_PERD_START_DATE%TYPE;
   v_InterestRate  TBAADM.EIT.INTEREST_RATE%TYPE;
   v_LimtAmt       TBAADM.LAM.DIS_AMT%TYPE;
   v_Balance       TBAADM.GAM.CLR_BAL_AMT%TYPE;
   v_Collectral    TBAADM.CID.SECU_CODE%TYPE;     
   v_LEGAL         VARCHAR2(50);
   v_NPLPrinciple  VARCHAR2(50);  
   v_tot_overdueAmt Tbaadm.ldt.DMD_amt%TYPE; 
   v_late_fee      Tbaadm.entity_interest_table.penal_accrued_amount_dr%TYPE; 
   v_Interest      Tbaadm.entity_interest_table.NRML_ACCRUED_AMOUNT_DR%TYPE; 
   v_dealer_name   TBAADM.li_dealer_master_table.dealer_name%TYPE; 
    v_BranchName   TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress  TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
   v_BankPhone     TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
   v_BankFax       TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
   vi_tempBranchCode varchar2(20);
   dealer_name varchar2(100);
  
  BEGIN
    ------------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
  ------------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);    
  ------------------------------------------------------------------------------
		-- Parsing the i/ps from the string
	------------------------------------------------------------------------------

    vi_DateBefore      :=  outArr(0);
    vi_SchemeType      :=  outArr(1);  
    vi_SchemeCode      :=  outArr(2);
    vi_currency        :=  outArr(3);
    vi_curreneyType    :=  outArr(4);  
    vi_CollectralType  :=  outArr(5);
    vi_branchCode      :=  outArr(6);
    
 --------------------------------------------------------------------------------------------------
/* 
 if( vi_DateBefore is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0  || '|' ||
                 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
                    '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||  0		);
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 */
 
 -------------------------------------------------------------------------------------------
  
  
    
    IF vi_SchemeCode IS  NULL or vi_SchemeCode = '' THEN
         vi_SchemeCode := '';
    END IF;
    
    IF vi_CollectralType IS  NULL or vi_CollectralType = '' THEN
         vi_CollectralType := '';
    END IF;
     IF vi_CollectralType like 'Land%'  THEN
         vi_CollectralType := 'BLDG';
    END IF;
    IF vi_branchCode IS  NULL or vi_branchCode = ''THEN
         vi_branchCode := '';
    END IF;
    
   
    
        IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData(vi_DateBefore, vi_SchemeType, vi_SchemeCode,vi_currency,vi_CollectralType,vi_branchCode
          );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  v_branchshortname, v_AccountNumber, v_AcctName, v_StartDate, 
                v_EndDate, v_InterestRate, v_LimtAmt, 
                v_Balance, v_Collectral,v_NPLPrinciple, v_LEGAL,v_tot_overdueAmt ,  v_late_fee ,   v_Interest  ,   v_dealer_name ,dealer_name
                ;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractData%NOTFOUND THEN
          --{
            CLOSE ExtractData;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      
  
      

--------------------------------------------------------------------------------
     
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
   
 /*BEGIN
 --if vi_branchCode is not null then
 SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
  -- end if;
 
   end;  */
     -----------------------------------------------------------------------------------
  Begin
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    if vi_curreneyType like 'Home%' then
      if(upper(vi_currency) = 'MMK') then vi_rate := 1;  
      else SELECT  VAR_CRNCY_UNITS into vi_rate
	    FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(vi_currency) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              and rownum = 1
                              order by rtlist_date desc;
      end if;
      elsif vi_curreneyType like 'Source%' then
      if(upper(vi_currency) = 'MMK') then vi_rate := 1;  
      else SELECT  VAR_CRNCY_UNITS into vi_rate
	    FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(vi_currency) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              and rownum = 1
                              order by rtlist_date desc;
      end if;
    else 
     vi_rate := 1;
    end if;
    end;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (     v_branchshortname             || '|' ||
                    v_AccountNumber      || '|' ||
                    v_AcctName           || '|' ||
                    v_StartDate          || '|' ||
                    v_EndDate            || '|' ||
                    v_InterestRate       || '|' ||
                    v_LimtAmt            || '|' ||
                    v_Balance            || '|' ||
                    v_tot_overdueAmt     || '|' ||
                      
                    v_late_fee           || '|' ||
                    v_Interest           || '|' ||
                    v_Collectral         || '|' ||
                    v_LEGAL              || '|' ||
                    v_NPLPrinciple       || '|' ||
                    
                  
                    v_dealer_name        || '|' ||
                    
                    v_BranchName         || '|' ||
                    v_BankAddress        || '|' ||
                    v_BankPhone          || '|' ||
                    v_BankFax            || '|' ||
                    vi_rate              || '|' ||
                    dealer_name
                   
               ); 
  
			dbms_output.put_line(out_rec);
  END FIN_DL_OUTSTANDING_BALANCE;

END FIN_DL_OUTSTANDING_BALANCE;
/
