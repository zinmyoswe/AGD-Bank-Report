CREATE OR REPLACE PACKAGE FIN_INTEREST_RECEIVABLE_PAY AS 

 PROCEDURE FIN_INTEREST_RECEIVABLE_PAY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INTEREST_RECEIVABLE_PAY;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_INTEREST_RECEIVABLE_PAY AS

-----------------------------------------------------------------------
--Update User - Yin Win Phyu
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
  vi_Type       Varchar2(50);		    	     -- Input to procedure
	vi_currency_code		Varchar2(3);		    	     -- Input to procedure
  vi_currency_type Varchar2(50);		    	     -- Input to procedure
  vi_branch_code Varchar2(5);	                   -- Input to procedure
  vi_schm_code Varchar2(10);	 -- Input to procedure
  vi_group_code1 Varchar2(3);            -- Input to procedure
  vi_gl_sub_head_code1 Varchar2(5);            -- Input to procedure
  vi_group_code2 Varchar2(3);            -- Input to procedure
  vi_gl_sub_head_code2 Varchar2(5);            -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractDataReceived(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select (select gam.foracid from tbaadm.gam gam
      where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,gam.schm_code
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav
where  gam.acid = cdav.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
and gam.acct_crncy_code =upper(ci_currency_code)
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,gam.schm_code
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataPayment(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2,ci_schm_code Varchar2) IS
select '' as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,gam.schm_code
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav
where  gam.acid = cdav.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_type ='T'
and cdav.tran_sub_type ='IP'  --IC
and cdav.part_tran_type ='C'
and gam.acct_crncy_code =upper(ci_currency_code)
and gam.schm_code =ci_schm_code
and cdav.tran_date <= to_date(ci_TranDate, 'dd-MM-yyyy')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,gam.schm_code--,cdav.tran_id
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataReceivedAll(ci_TranDate Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,SUM(HEAD.amount) as amount,HEAD.schm_code
from 
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
      CASE WHEN Q.cur = 'MMK'  THEN Q.amount
  ELSE Q.amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amount,
    Q.schm_code,Q.cur
from
(select (select gam.foracid from tbaadm.gam gam
         where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code,q.cur
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,gam.schm_code,gam.acct_crncy_code as cur
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav
where  gam.acid = cdav.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
--and gam.acct_crncy_code =upper('MMK')
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,gam.schm_code,gam.acct_crncy_code
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date)Q
order by Q.schm_code,Q.foracid,Q.acct_opn_date)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataReceivedFCY(ci_TranDate Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,SUM(HEAD.amount) as amount,HEAD.schm_code
from 
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
      CASE WHEN Q.cur = 'MMK'  THEN Q.amount
  ELSE Q.amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amount,
    Q.schm_code,Q.cur
from
(select (select gam.foracid from tbaadm.gam gam
         where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code,q.cur
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,gam.schm_code,gam.acct_crncy_code as cur
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav
where  gam.acid = cdav.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
and gam.acct_crncy_code !=upper('MMK')
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,gam.schm_code,gam.acct_crncy_code
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date)Q
order by Q.schm_code,Q.foracid,Q.acct_opn_date)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixed(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select (select gam.foracid from tbaadm.gam gam
      where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,tam.deposit_period_mths as schm_code
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav,tbaadm.tam tam
where  gam.acid = cdav.acid
and tam.acid = gam.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
and gam.acct_crncy_code =upper(ci_currency_code)
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,tam.deposit_period_mths
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixedAll(ci_TranDate Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,SUM(HEAD.amount) as amount,HEAD.schm_code
from 
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
      CASE WHEN Q.cur = 'MMK'  THEN Q.amount
  ELSE Q.amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amount,
    Q.schm_code,Q.cur
from
(select (select gam.foracid from tbaadm.gam gam
      where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code,q.cur
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,tam.deposit_period_mths as schm_code,gam.acct_crncy_code as cur
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav,tbaadm.tam tam
where  gam.acid = cdav.acid
and tam.acid = gam.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
--and gam.acct_crncy_code =upper(ci_currency_code)
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,tam.deposit_period_mths,gam.acct_crncy_code
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date)Q
order by Q.schm_code,Q.foracid,Q.acct_opn_date)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixedFCY(ci_TranDate Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,SUM(HEAD.amount) as amount,HEAD.schm_code
from 
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
      CASE WHEN Q.cur = 'MMK'  THEN Q.amount
  ELSE Q.amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amount,
    Q.schm_code,Q.cur
from
(select (select gam.foracid from tbaadm.gam gam
      where gam.acid = (select lam.op_acid 
                      from  tbaadm.lam lam 
                      where lam.acid = q.acid) ) as Account_Number,
    q.foracid,q.acct_opn_date,q.acct_name,
    (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
    q.amount,q.schm_code,q.cur
from
(select gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,sum(cdav.tran_amt) as amount,tam.deposit_period_mths as schm_code,gam.acct_crncy_code as cur
from tbaadm.gam gam, CUSTOM.custom_ctd_dtd_acli_view cdav,tbaadm.tam tam
where  gam.acid = cdav.acid
and tam.acid = gam.acid
and cdav.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = cdav.tran_crncy_code
and gam.sol_id = cdav.sol_id
and cdav.tran_rmks ='Interest run'
and gam.acct_crncy_code !=upper('MMK')
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and to_char(cdav.tran_date,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
and gam.sol_id like   '%' || ci_branch_code || '%'
group by gam.acid,gam.foracid,gam.acct_opn_date,gam.acct_name,tam.deposit_period_mths,gam.acct_crncy_code
order by gam.foracid, gam.acct_opn_date)q
order by q.schm_code,q.foracid,q.acct_opn_date)Q
order by Q.schm_code,Q.foracid,Q.acct_opn_date)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_INTEREST_RECEIVABLE_PAY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_current_Acc  tbaadm.gam.foracid%type;
    v_foracid tbaadm.gam.foracid%type;
    v_opn_date tbaadm.gam.acct_opn_date%type;
    v_acct_name tbaadm.gam.acct_name%type;
    v_interest_rate tbaadm.eit.interest_rate%type;
    v_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_schm_code tbaadm.gam.schm_code%type;
    v_rate tbaadm.rth.VAR_CRNCY_UNITS%type; 
    BranchName TBAADM.sol.sol_desc%type;
     
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
   --  vi_TranDate := outArr(0);
   vi_TranDate := outArr(0);
     vi_Type := outArr(1);
     vi_currency_code :=outArr(2);
     vi_currency_type :=outArr(3);
     vi_branch_code := outArr(4);
     
     -----------------------------------------------------------------
     if(vi_TranDate  is null or vi_Type is null or vi_currency_type is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  ---------------------------------------------------------------------------------------------------------
  If (vi_branch_code = '' or vi_branch_code is null) then
     vi_branch_code :='';
  end if;
 ----------------------------------------------------------------------------------------------------------- 
  if vi_Type ='Demand Loan' then 
     vi_gl_sub_head_code1 :='10501';
     vi_gl_sub_head_code2 :='';
     
  elsif vi_Type ='Trade Finance' then
     vi_gl_sub_head_code1 :='10313';
     vi_gl_sub_head_code2 :='';
     
  elsif vi_Type ='Overdraft' then 
     vi_gl_sub_head_code1 :='10551';
     vi_gl_sub_head_code2 :='';
  
  elsif vi_Type ='Hire Purchase' then 
     vi_gl_sub_head_code1 :='10571';
     vi_gl_sub_head_code2 :='';
     
  elsif vi_Type ='Staff Loan' then 
     vi_gl_sub_head_code1 :='10507';
     vi_gl_sub_head_code2 :='';
  
  elsif vi_Type ='Credit Card' then 
     vi_gl_sub_head_code1 :='10581';
     vi_gl_sub_head_code2 :='';
    
  elsif vi_Type ='Inter Bank Loans' then
     vi_gl_sub_head_code1 :='10506';
     vi_gl_sub_head_code2 :='';
  
  elsif vi_Type ='Special Deposit' then 
     vi_schm_code :='SASPL';
  
  elsif vi_Type ='Saving Deposit' then 
     vi_schm_code :='SAREG';
 
 elsif vi_Type ='Fixed Deposit' then 
     vi_gl_sub_head_code1 :='70131';
     vi_gl_sub_head_code2 :='70315';
 end if;
 ----------------------------------------------------------------------------------------------------------- 
 
 If (vi_Type ='Saving Deposit')or (vi_Type ='Special Deposit') then 
    If vi_currency_type not like 'All Currency' then
     IF NOT ExtractDataPayment%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataPayment ( vi_TranDate, vi_currency_code,vi_branch_code,vi_schm_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataPayment%ISOPEN THEN
        --{
          FETCH	ExtractDataPayment
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,v_amt,v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataPayment%NOTFOUND THEN
          --{
            CLOSE ExtractDataPayment;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    end if;-- currency type
    end if; --type
-------------------------------------------------------------------------------
-- to get branchname
--------------------------------------------------------------------------------
BEGIN
              IF vi_branch_code is not null then
                SELECT sol.sol_desc
                INTO BranchName
                FROM tbaadm.sol,
                  tbaadm.bct
                WHERE sol.SOL_ID = vi_branch_code
                AND bct.br_code  = sol.br_code
                and bct.bank_code =sol.bank_code;
                END IF;
              END;
-----------------------------------------------------------------------------------
-- To get rate 
-----------------------------------------------------------------------------------
            IF vi_currency_type  = 'Home Currency' THEN
                if upper(vi_currency_code) = 'MMK' THEN v_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into v_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency_code)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF vi_currency_type = 'Source Currency' THEN
                      v_rate := 1;
              ELSE
                  v_rate := 1;
              END IF;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (   v_current_Acc|| '|' ||
                  v_foracid|| '|' ||
                  trim(to_char(to_date(v_opn_date,'dd/Mon/yy'), 'dd-MM-yyyy')) || '|' ||
                  v_acct_name|| '|' ||
                  v_interest_rate|| '|' ||
                  v_amt|| '|' ||
                  v_schm_code || '|' ||
                  v_rate || '|' ||
                  BranchName
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_INTEREST_RECEIVABLE_PAY;

END FIN_INTEREST_RECEIVABLE_PAY;
/
