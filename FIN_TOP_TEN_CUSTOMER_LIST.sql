CREATE OR REPLACE PACKAGE        FIN_TOP_TEN_CUSTOMER_LIST AS 
PROCEDURE FIN_TOP_TEN_CUSTOMER_LIST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
  

END FIN_TOP_TEN_CUSTOMER_LIST;
/


CREATE OR REPLACE PACKAGE BODY                                         FIN_TOP_TEN_CUSTOMER_LIST AS  
/******************************************************************************
 NAME:      FIN_TOP_TEN_CUSTOMER_LIST
 PURPOSE:
 Coder   :  Hlaing Nadi Phyo

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
    outArr tbaadm.basp0099.ArrayType;  -- Input Parse Array
                    

  vi_Due_Date        Varchar2(10);     -- Input to procedure
  vi_loanType         Varchar2(10);     -- Input to procedure



--------------------------------------------------------------------------------
-- CURSOR ExtractData with Business Type
--------------------------------------------------------------------------------
CURSOR ExtractData( ci_Due_Date VARCHAR2, vi_loanType Varchar2 )
IS



select q.ACCT_NAME as Customer_acc_Name,q.UNIQUEID as NRC_No,
q.INDUSTRY_TYPE as Bussiness,q.collectral_type as Type_of_Collateral,
q.LIM_SANCT_DATE as Sanction_Date,q.SANCT_LIM as Sanction_Amount,
 q.LIM_EXP_DATE as Due_Date,q.sol_desc as Branch from (
select distinct gam.acid,gam.ACCT_NAME,UNIQUEID,INDUSTRY_TYPE,lht.LIM_SANCT_DATE ,lht.SANCT_LIM ,coa.GROUP_CODE,
 lht.LIM_EXP_DATE,
 sol.sol_desc,
(select secu_desc from tbaadm.cid ,tbaadm.asm  where
cid.SECU_CODE=asm.SECU_CODE
and gam.acid=cid.acid) as collectral_type
from  
tbaadm.gam gam,crmuser.accounts acc ,tbaadm.gac,tbaadm.lht,custom.coa_mp coa,tbaadm.sol sol
where gam.CIF_ID=acc.ORGKEY
and gam.acid=gac.acid
and gam.acid=lht.acid
and gam.SOL_ID=sol.SOL_ID
and coa.gl_sub_head_code=gam.gl_sub_head_code 
and coa.CUR=gam.ACCT_CRNCY_CODE
--and coa.GROUP_CODE ='A24'
and lht.SANCT_LIM <>0
and lht.SANCT_LIM not like '99999999999999%'
and coa.GROUP_CODE not in 'A25'
and coa.GROUP_CODE like '%A%'
and coa.GROUP_CODE  like '%'|| '' || '%'
and lht.LIM_EXP_DATE <= TO_DATE( CAST ( ci_Due_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
order by SANCT_LIM desc)q
where ROWNUM <= 20;


-----------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_TOP_TEN_CUSTOMER_LIST (  inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_Customer_acc_Name  tbaadm.gam.acct_name%type;
  v_NRC_No  crmuser.accounts.UNIQUEID%type;
  v_Bussiness  tbaadm.gac.INDUSTRY_TYPE%type;
  v_Type_of_Collateral  tbaadm.cid.SECU_CODE%type;
  v_Sanction_Date    tbaadm.lht.LIM_SANCT_DATE%type;
  v_Sanction_Amount   tbaadm.lht.SANCT_LIM%type;
  v_Due_Date  tbaadm.lht.LIM_EXP_DATE%type;
 v_Branch  tbaadm.sol.SOL_DESC%type;
  
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

vi_Due_Date :=  outArr(0);
 --------------------------------------------------------
  IF vi_loanType = 'Demand Loan' then
       vi_loanType := 'A21';
 ELSif    vi_loanType ='OverDraft' then
        vi_loanType := 'A23';
         ELSif    vi_loanType ='Hire Purchase' then
        vi_loanType := 'A24';
      -- ELSif    vi_loanType ='StaffLoan' then
      --  vi_loanType := 'A25';
      --  ELSE  vi_loanType := '';
    END IF;
 ----------------------------------------------------------
        IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData(vi_Due_Date,vi_loanType);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO v_Customer_acc_Name,v_NRC_No ,v_Bussiness ,v_Type_of_Collateral ,v_Sanction_Date,v_Sanction_Amount,    
             v_Due_Date , v_Branch;
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
     
---------------------------------------------------------------------------

     out_rec:= (  v_Customer_acc_Name    || '|' ||
v_NRC_No    || '|' ||
v_Bussiness    || '|' ||
v_Type_of_Collateral    || '|' ||
v_Sanction_Date    || '|' ||
v_Sanction_Amount    || '|' || 
v_Due_Date    || '|' ||
v_Branch ); 

			dbms_output.put_line(out_rec);
  END   FIN_TOP_TEN_CUSTOMER_LIST;
END   FIN_TOP_TEN_CUSTOMER_LIST;
/
