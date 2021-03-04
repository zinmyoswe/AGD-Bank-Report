CREATE OR REPLACE PACKAGE FIN_INCOME_EXPENDITURE AS 

  PROCEDURE FIN_INCOME_EXPENDITURE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INCOME_EXPENDITURE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_INCOME_EXPENDITURE AS

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
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractDataExpense(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Opening,HEAD.Cash_Dr_amt,HEAD.Transfer_Dr_amt,
      HEAD.Clearing_dr_amt,HEAD.Cash_Cr_amt,HEAD.Transfer_Cr_amt,HEAD.Clearing_Cr_amt
from
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'1' as no,'Interest and Expense' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Interest_Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'2' as no,'Establishment Salaries and Allowances' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Establishment Salaries and Allowances
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'3' as no,'Travel and Entertainment' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50212','50213','50214','50215','50216')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Travel and Entertainment
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'4' as no,'Fees and Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Fees and Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'5' as no,'Sales and Marketing Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Sales and Marketing Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'6' as no,'Repair and Maintenance Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Repair and Maintenance Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'7' as no,'Supply and Services Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Supply and Services Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'8' as no,'Card Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50294')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50294') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50294'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Card Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'9' as no,'ICT Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50295')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50295') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- ICT Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'10' as no,'Misceallenous Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Misceallenous Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'11' as no,'Rent' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Rent
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'12' as no,'Rate and Tax' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Rate and Tax
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'13' as no,'Insurance' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Insurance
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'14' as no,'Deprecitaion' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Deprecitaion
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'15' as no,'Loss and Write Off' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50351','50352','50354','50196')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Loss and Write Off
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'16' as no,'Discount  Expenses' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50361')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Discount  Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'17'as no,'Foreign Currency Gain/(loss)' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50371')
  and coa.cur =upper(ci_currency_code)
  order by coa.gl_sub_head_code) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Foreign Currency Gain/(loss)
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   ) HEAD;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractExpenseAll(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from
(select G.gl_sub_head_code,G.no,G.description,G.gl_sub_head_desc,
        CASE WHEN G.cur = 'MMK'  THEN G.Opening
      when  G.gl_sub_head_code = '70002' and  G.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_amt,
      CASE WHEN G.cur = 'MMK'  THEN G.Clearing_dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Clearing_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Closing
      when  G.gl_sub_head_code = '70002' and  G.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing
from 
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,1 as no,'Interest and Expense' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest_Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur ) B 

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code, 2 as no,'Establishment Salaries and Allowances' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)-sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Establishment Salaries and Allowances
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,3 as no,'Travel and Entertainment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50212','50213','50214','50215','50216')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Travel and Entertainment
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,4 as no,'Fees and Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Fees and Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,5 as no,'Sales and Marketing Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Sales and Marketing Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,6 as no,'Repair and Maintenance Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Repair and Maintenance Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,7 as no,'Supply and Services Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
  select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Supply and Services Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,8 as no,'Card Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50294')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50294') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50294'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50294'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Card Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,9 as no,'ICT Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50295')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50295') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- ICT Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,10 as no,'Misceallenous Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Misceallenous Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,11 as no,'Rent' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
  select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rent
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,12 as no,'Rate and Tax' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rate and Tax
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,13 as no,'Insurance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Insurance
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,14 as no,'Deprecitaion' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Deprecitaion
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,15 as no,'Loss and Write Off' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50351','50352','50354','50196')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50351','50352','50354','50196'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Loss and Write Off
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,16 as no,'Discount  Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50361')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50361'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Discount  Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code, 17 as no,'Foreign Currency Gain/(loss)' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50371')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc, q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Foreign Currency Gain/(loss)
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B )G) HEAD
   group by  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc
   order by HEAD.no asc;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractExpenseFCY(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from
(select G.gl_sub_head_code,G.no,G.description,G.gl_sub_head_desc,
        CASE WHEN G.cur = 'MMK'  THEN G.Opening
      when  G.gl_sub_head_code = '70002' and  G.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_amt,
      CASE WHEN G.cur = 'MMK'  THEN G.Clearing_dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Clearing_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Closing
      when  G.gl_sub_head_code = '70002' and  G.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing
from 
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,1 as no,'Interest and Expense' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest and Expense' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50109','50105'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest_Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur ) B 

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code, 2 as no,'Establishment Salaries and Allowances' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)-sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Establishment Salaries and Allowances
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,3 as no,'Travel and Entertainment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50212','50213','50214','50215','50216')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50212','50213','50214','50215','50216'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Travel and Entertainment
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,4 as no,'Fees and Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50231','50232','50233','50234','50235','50236','50237','50238'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Fees and Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,5 as no,'Sales and Marketing Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50271','50272','50273','50273','50274','50275'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Sales and Marketing Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,6 as no,'Repair and Maintenance Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285','50286'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Repair and Maintenance Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,7 as no,'Supply and Services Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
  select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50121','50122','50201','50202','50291','50292','50293','50296'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Supply and Services Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,8 as no,'Card Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50294')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50294') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50294'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Card Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50294'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Card Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,9 as no,'ICT Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50295')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50295') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- ICT Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,10 as no,'Misceallenous Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50142','50145','50311','50312','50313','50314','50315'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Misceallenous Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,11 as no,'Rent' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
  select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rent
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,12 as no,'Rate and Tax' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50131','50301','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rate and Tax
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,13 as no,'Insurance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Insurance
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,14 as no,'Deprecitaion' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Deprecitaion
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,15 as no,'Loss and Write Off' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50351','50352','50354','50196')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50351','50352','50354','50196') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50351','50352','50354','50196'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Loss and Write Off
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,16 as no,'Discount  Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50361')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt)- sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50361') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50361'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Discount  Expenses
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code, 17 as no,'Foreign Currency Gain/(loss)' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50371')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_dr_amt) - sum(T.Closing_cr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc, q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('50371') )q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Foreign Currency Gain/(loss)
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B )G) HEAD
   group by  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc
   order by HEAD.no asc;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataIncome(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Opening,HEAD.Cash_Dr_amt,HEAD.Transfer_Dr_amt,
      HEAD.Clearing_dr_amt,HEAD.Cash_Cr_amt,HEAD.Transfer_Cr_amt,HEAD.Clearing_Cr_amt
from
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'1' as no,'Interest on Loans and Advanced' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code) B

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'2' as no,'Interest on Investment' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40001','40002','40003','40004')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40001','40002','40003','40004') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Interest on Investment
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'3' as no,'Interest on Deposits' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40016','40017')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40016','40017') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Interest on Deposits
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'4' as no,'Income on Remittance' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40031','40032','40033','40034')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Income on Remittance
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'5' as no,'Commission' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Commission
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'6' as no,'Fees' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'7' as no,'Income on Services Charges' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40050','40063','40056','40060')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40050','40063','40056','40060') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Income on Services Charges
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'8' as no,'Income on Cards Fees' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Income on Cards Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'9' as no,'Miscellaneous Income' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40081','40082','40114')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt))as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40081','40082','40114') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40081','40082','40114'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Miscellaneous Income
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'10' as no,'Disount Income' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40091','40092')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40091','40092') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Disount Income
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'11' as no,'Foreign Transaction Income' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40101','40102','40103','40104')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40101','40102','40103','40104') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40101','40102','40103','40104'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Foreign Transaction Income
   on x.gl_sub_head_code = GL.gl_sub_head_code) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt
from
(select coa.gl_sub_head_code,'12' as no,'Rental Income' as description,coa.gl_sub_head_desc
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40111','40112','40113')
  and coa.cur =upper(ci_currency_code)) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40111','40112','40113') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc
   order by T.gl_sub_head_code)x -- Rental Income
   on x.gl_sub_head_code = GL.gl_sub_head_code) B
   ) HEAD;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractIncomeAll(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from
(select G.gl_sub_head_code,G.no,G.description,G.gl_sub_head_desc,
        CASE WHEN G.cur = 'MMK'  THEN G.Opening
      when  G.gl_sub_head_code = '70002' and  G.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_amt,
      CASE WHEN G.cur = 'MMK'  THEN G.Clearing_dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Clearing_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Closing
      when  G.gl_sub_head_code = '70002' and  G.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing
from 
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,1 as no,'Interest on Loans and Advanced' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019') )q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,2 as no,'Interest on Investment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40001','40002','40003','40004')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40001','40002','40003','40004') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
 select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Investment
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur=GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,3 as no,'Interest on Deposits' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40016','40017')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)-sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40016','40017') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Deposits
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,4 as no,'Income on Remittance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40031','40032','40033','40034')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Remittance
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,5 as no,'Commission' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Commission
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,6 as no,'Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,7 as no,'Income on Services Charges' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40050','40063','40056','40060')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40050','40063','40056','40060') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Services Charges
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,8 as no,'Income on Cards Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
  --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Cards Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,9 as no,'Miscellaneous Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40081','40082','40114')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt))as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40081','40082','40114') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40081','40082','40114'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40081','40082','40114'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Miscellaneous Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,10 as no,'Disount Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40091','40092')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40091','40092') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Disount Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,11 as no,'Foreign Transaction Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40101','40102','40103','40104')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40101','40102','40103','40104') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40101','40102','40103','40104'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40101','40102','40103','40104'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Foreign Transaction Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,12 as no,'Rental Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40111','40112','40113')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40111','40112','40113') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code = upper(ci_currency_code)
   --and gstt.crncy_code = upper(ci_currency_code)
   --and coa.cur= upper(ci_currency_code)
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   --and gsh.crncy_code != upper('MMK')
   --and gstt.crncy_code != upper('MMK')
   --and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rental Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B )G) HEAD
   group by  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc
   order by HEAD.no asc;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractIncomeFCY(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from
(select G.gl_sub_head_code,G.no,G.description,G.gl_sub_head_desc,
        CASE WHEN G.cur = 'MMK'  THEN G.Opening
      when  G.gl_sub_head_code = '70002' and  G.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Opening ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_amt,
      CASE WHEN G.cur = 'MMK'  THEN G.Clearing_dr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_dr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_dr_amt,
    CASE WHEN G.cur = 'MMK'  THEN G.Cash_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Cash_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Transfer_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Transfer_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Clearing_Cr_amt
      when  G.gl_sub_head_code = '70002' and  G.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Clearing_Cr_amt ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_amt,
  CASE WHEN G.cur = 'MMK'  THEN G.Closing
      when  G.gl_sub_head_code = '70002' and  G.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='18282678.36' and G.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='1259531.25' and G.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='653408.19' and G.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='874441.97' and G.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  G.gl_sub_head_code = '60161' and  G.Closing ='29894' and G.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE G.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(G.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing
from 
(select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,1 as no,'Interest on Loans and Advanced' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021','40018','40019') )q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

union all
select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,2 as no,'Interest on Investment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40001','40002','40003','40004')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40001','40002','40003','40004') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
 select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Investment
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur=GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,3 as no,'Interest on Deposits' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40016','40017')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)-sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40016','40017') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Interest on Deposits
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,4 as no,'Income on Remittance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40031','40032','40033','40034')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Remittance
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,5 as no,'Commission' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40042','40043','40044','40045','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Commission
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur =GL.cur) B
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,6 as no,'Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all 
  select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,7 as no,'Income on Services Charges' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40050','40063','40056','40060')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40050','40063','40056','40060') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Services Charges
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,Gl.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,8 as no,'Income on Cards Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Income on Cards Fees
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,9 as no,'Miscellaneous Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40081','40082','40114')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt))as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40081','40082','40114') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40081','40082','40114'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40081','40082','40114'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Miscellaneous Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,10 as no,'Disount Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40091','40092')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40091','40092') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Disount Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
   select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,11 as no,'Foreign Transaction Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40101','40102','40103','40104')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40101','40102','40103','40104') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40101','40102','40103','40104'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40101','40102','40103','40104'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Foreign Transaction Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B 
   
   union all
    select B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.Opening,B.Cash_Dr_amt,B.Transfer_Dr_amt,
      B.Clearing_dr_amt,B.Cash_Cr_amt,B.Transfer_Cr_amt,B.Clearing_Cr_amt,B.Closing
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,x.cur,x.Opening,x.Cash_Dr_amt,x.Transfer_Dr_amt,
      x.Clearing_dr_amt,x.Cash_Cr_amt,x.Transfer_Cr_amt,x.Clearing_Cr_amt,x.Closing
from
(select coa.gl_sub_head_code,12 as no,'Rental Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40111','40112','40113')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
       (sum(T.Closing_cr_amt) - sum(T.Closing_dr_amt)) as Closing
from 
(select q.gl_sub_head_code,
   q.description,
   q.gl_sub_head_desc,q.cur,
  sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
   sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
select
   coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal,
  0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
    and gstt.end_bal_date >= (select max(gstt.BAL_DATE)
                         from tbaadm.gstt gstt 
                         where to_char(gstt.BAL_DATE,'MM-YYYY') < to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40111','40112','40113') )q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur 
union all 
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from(
  select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
   0 as tot_dr_bal,
  0 as tot_cr_bal,
    gstt.TOT_cash_DR_AMT as Cash_Dr_amt,
    gstt.TOT_xfer_DR_AMT as Transfer_Dr_amt,
    gstt.TOT_clg_DR_AMT as Clearing_dr_amt,
    gstt.TOT_cash_CR_AMT as Cash_Cr_amt,
    gstt.TOT_xfer_CR_AMT as Transfer_Cr_amt,
    gstt.TOT_clg_CR_AMT as Clearing_Cr_amt,
    0 as Closing_dr_amt,
    0 as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and to_char(gstt.BAL_DATE,'MM-YYYY') = to_char(to_date(cast(ci_TranDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
   and gstt.SOL_ID like   '%' || ci_branch_code || '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.cur
union all
select q.gl_sub_head_code,
   q.description ,q.gl_sub_head_desc,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
    sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt,
    sum(q.Closing_dr_amt) as Closing_dr_amt,
    sum(q.Closing_cr_amt) as Closing_cr_amt
from
(select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc,coa.cur,
    0 as tot_dr_bal,
    0 as tot_cr_bal,
    0 as Cash_Dr_amt,
    0 as Transfer_Dr_amt,
    0 as Clearing_dr_amt,
    0 as Cash_Cr_amt,
    0 as Transfer_Cr_amt,
    0 as Clearing_Cr_amt,
    gstt.tot_dr_bal as Closing_dr_amt,
  gstt.tot_cr_bal as Closing_cr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_branch_code|| '%'
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   AND gsh.crncy_code =gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code,q.description ,q.gl_sub_head_desc,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.cur)x -- Rental Income
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B )G) HEAD
   group by  HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc
   order by HEAD.no asc;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_INCOME_EXPENDITURE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_gl_sub_head_code  custom.coa_mp.gl_sub_head_code%type;
    v_no Varchar(10);
    v_description Varchar(200);
    v_gl_sub_head_desc  custom.coa_mp.gl_sub_head_desc%type;
    v_dr_amt tbaadm.gstt.tot_dr_bal%type;
    v_cr_amt tbaadm.gstt.tot_cr_bal%type;
    v_Opening tbaadm.gstt.tot_dr_bal%type;
    v_cash_dr_amt tbaadm.gstt.TOT_cash_DR_AMT%type;
    v_transfer_dr_amt tbaadm.gstt.TOT_xfer_DR_AMT%type;
    v_clearing_dr_amt tbaadm.gstt.TOT_clg_DR_AMT%type;
    v_cash_cr_amt tbaadm.gstt.TOT_cash_CR_AMT%type;
    v_transfer_cr_amt tbaadm.gstt.TOT_xfer_CR_AMT%type;
    v_clearing_cr_amt tbaadm.gstt.TOT_clg_CR_AMT%type;
    v_rate tbaadm.rth.VAR_CRNCY_UNITS%type; 
     BranchName TBAADM.sol.sol_desc%type;
     v_closing  tbaadm.gstt.tot_dr_bal%type;
     
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
    If vi_Type like 'Expenditure%' then
    IF vi_currency_type not like 'All%' then
     IF NOT ExtractDataExpense%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataExpense ( vi_TranDate, vi_currency_code,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataExpense%ISOPEN THEN
        --{
          FETCH	ExtractDataExpense
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataExpense%NOTFOUND THEN
          --{
            CLOSE ExtractDataExpense;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    ELSIF vi_currency_type ='All Currency' then
     IF NOT ExtractExpenseAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractExpenseAll ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractExpenseAll%ISOPEN THEN
        --{
          FETCH	ExtractExpenseAll
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractExpenseAll%NOTFOUND THEN
          --{
            CLOSE ExtractExpenseAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      ELSE 
      IF NOT ExtractExpenseFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractExpenseFCY ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractExpenseFCY%ISOPEN THEN
        --{
          FETCH	ExtractExpenseFCY
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractExpenseFCY%NOTFOUND THEN
          --{
            CLOSE ExtractExpenseFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
        END IF;
      ELSE --Income
      IF vi_currency_type not like 'All%' then
      IF NOT ExtractDataIncome%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataIncome ( vi_TranDate, vi_currency_code,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataIncome%ISOPEN THEN
        --{
          FETCH	ExtractDataIncome
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataIncome%NOTFOUND THEN
          --{
            CLOSE ExtractDataIncome;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    ELSIF vi_currency_type ='All Currency' then
     IF NOT ExtractIncomeAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractIncomeAll ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractIncomeAll%ISOPEN THEN
        --{
          FETCH	ExtractIncomeAll
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractIncomeAll%NOTFOUND THEN
          --{
            CLOSE ExtractIncomeAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
     ELSE
     IF NOT ExtractIncomeFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractIncomeFCY ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractIncomeFCY%ISOPEN THEN
        --{
          FETCH	ExtractIncomeFCY
          INTO  v_gl_sub_head_code,v_no,v_description,v_gl_sub_head_desc,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractIncomeFCY%NOTFOUND THEN
          --{
            CLOSE ExtractIncomeFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
        END IF;
        END IF;
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
                   if upper(vi_currency_code) = 'MMK' THEN v_rate := 1 ;
                   ELSE
                      v_rate := 1;
                  end if;
              ELSE
                  v_rate := 1;
              END IF;
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
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (     v_gl_sub_head_code|| '|' ||
                    v_no|| '|' ||
                    v_description|| '|' ||
                    v_gl_sub_head_desc || '|' ||
                    v_Opening|| '|' ||
                    v_cash_dr_amt|| '|' ||
                    v_transfer_dr_amt|| '|' ||
                    v_clearing_dr_amt|| '|' ||
                    v_cash_cr_amt|| '|' ||
                    v_transfer_cr_amt|| '|' ||
                    v_clearing_cr_amt|| '|' ||
                    v_rate || '|' ||
                    BranchName || '|' ||
                    v_closing
                    
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_INCOME_EXPENDITURE;

END FIN_INCOME_EXPENDITURE;
/
