CREATE OR REPLACE PACKAGE FIN_SUB_GL_CODE_BALANCE AS 

  PROCEDURE FIN_SUB_GL_CODE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_SUB_GL_CODE_BALANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_SUB_GL_CODE_BALANCE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_acct_id		Varchar2(100);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractDataTodayDate(ci_acct_id Varchar2)
IS
select T.foracid,T.acct_name,T.sol_desc,T.cur,T.Balance, T.MMKRateBlance,T.rate
from 
(select q.foracid,q.acct_name,q.sol_desc,q.cur,q.Balance,
        CASE WHEN q.cur = 'MMK' THEN q.Balance 
      ELSE q.Balance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS MMKRateBlance,
      (SELECT  VAR_CRNCY_UNITS 
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ) as rate
from 
(select  gam.foracid, gam.acct_name,
(select sol.sol_desc from tbaadm.sol where sol.sol_id =gam.sol_id ) as sol_desc,
gam.acct_crncy_code as cur, gam.clr_bal_amt as Balance
from tbaadm.gam gam 
where gam.del_flg ='N'
and gam.bank_id ='01'
and gam.foracid like '%' ||ci_acct_id
order by gam.foracid)q
order by q.foracid)T
order by T.foracid;


-----------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataBackDate(ci_TranDate Varchar2 ,ci_acct_id Varchar2)
IS
select T.foracid,T.acct_name,T.sol_desc,T.cur,T.Balance,T.MMKRateBlance,T.rate
from 
(select q.foracid,q.acct_name,q.sol_desc,q.cur,q.Balance,
      CASE WHEN q.cur = 'MMK' THEN q.Balance 
      ELSE q.Balance * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS MMKRateBlance,
      (SELECT  VAR_CRNCY_UNITS 
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ) as rate
from
(select gam.foracid,gam.acct_name,
(select sol.sol_desc from tbaadm.sol where sol.sol_id =gam.sol_id ) as sol_desc,
gam.acct_crncy_code as cur, (eab.tran_date_bal) as Balance      
from tbaadm.gam gam, tbaadm.eab 
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.del_flg ='N'
and gam.bank_id ='01'
and eab.bank_id = '01'
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.END_eod_DATE >=TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.foracid like '%' || ci_acct_id
order by gam.foracid)q
order by q.foracid)T
order by T.foracid;



-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_SUB_GL_CODE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_foracid  tbaadm.gam.foracid%type;
    v_acct_name tbaadm.gam.acct_name%type;
    v_sol_id tbaadm.gam.sol_id%type;
    v_sol_desc tbaadm.sol.sol_desc%type;
    v_cur tbaadm.gam.acct_crncy_code%type;
    v_balance tbaadm.gam.clr_bal_amt%type;
    v_MMKBalance tbaadm.gam.clr_bal_amt%type;
    v_rate tbaadm.RTL.VAR_CRNCY_UNITS%type;
    sdate tbaadm.SOL_GROUP_CONTROL_TABLE.Db_Stat_Date%type;
    v_Date_Flg TBAADM.GENERAL_ACCT_MAST_TABLE.del_flg%type;
     
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
     vi_TranDate := outArr(0);
     vi_acct_id := outArr(1);
     
     -----------------------------------------------------------------
     if( vi_TranDate is null or vi_acct_id is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
     
     -------------------------------------------------------------------
   select Db_Stat_Date into sdate from tbaadm.SOL_GROUP_CONTROL_TABLE where sol_group_id = '01';
    if( TO_DATE( sysdate, 'dd-MM-yyyy' ) = TO_DATE( vi_TranDate, 'dd-MM-yyyy' ) ) then
        v_Date_Flg := 'Y';
    else 
        v_Date_Flg := 'N';
    end if;  
 -----------------------------------------------------------------------------------------------------------    
    IF(v_Date_Flg = 'Y') THEN
     IF NOT ExtractDataTodayDate%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataTodayDate ( vi_acct_id );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataTodayDate%ISOPEN THEN
        --{
          FETCH	ExtractDataTodayDate
          INTO  v_foracid, v_acct_name, v_sol_desc, v_cur,v_balance,v_MMKBalance,v_rate;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataTodayDate%NOTFOUND THEN
          --{
            CLOSE ExtractDataTodayDate;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
----------------------------------------------------------------------------------
ELSE

IF NOT ExtractDataBackDate%ISOPEN THEN  --forbackdate
        --{
          BEGIN
          --{
            OPEN ExtractDataBackDate (vi_TranDate, vi_acct_id );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataBackDate%ISOPEN THEN
        --{
          FETCH	ExtractDataBackDate
          INTO  v_foracid, v_acct_name,v_sol_desc, v_cur,v_balance,v_MMKBalance,v_rate;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataBackDate%NOTFOUND THEN
          --{
            CLOSE ExtractDataBackDate;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
     --}
        END IF;    
 
        
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (     trim(v_foracid) || '|' ||
                    v_acct_name|| '|' ||
                    v_sol_desc|| '|' ||
                    v_cur|| '|' ||
                    v_balance|| '|' ||
                    v_MMKBalance || '|' ||
                    v_rate
                    
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_SUB_GL_CODE_BALANCE;

END FIN_SUB_GL_CODE_BALANCE;
/
