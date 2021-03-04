CREATE OR REPLACE PACKAGE FIN_FRIDAY_POSITION_NEW AS 

  PROCEDURE FIN_FRIDAY_POSITION_NEW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FRIDAY_POSITION_NEW;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_FRIDAY_POSITION_NEW AS

-----------------------------------------------------------------------
--Update User - Yin Win Phyu
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_currency_code		Varchar2(3);		    	     -- Input to procedure
  vi_currency_type Varchar2(50);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractPositionMMK(ci_TranDate Varchar2, ci_currency_code Varchar2) IS
select HEAD.no,HEAD.description,sum(HEAD.Closing) as Closing,HEAD.temp,HEAD.ID
from 
(select '1' as no,
       'Demand Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,1 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,2 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,3 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,4 as ID
from
  (select '' as no,'             Other Deposits - Current Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur as cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L11')q
group by q.no,q.description,'g',4  ---14646832610.68
union all
select q.no,
       q.description,
       case when q.group_code='L13' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,5 as ID
from
  (select '' as no,'                               Saving Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.group_code,5
union all
select q.no,
       q.description,
       case when q.group_code='L15' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,6 as ID
from
  (select '' as no,'                               Special Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.group_code,6
union all
select q.no,
       q.description,
       case when q.group_code='L17' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,7 as ID
from
  (select '' as no,'                               Fixed Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.group_code,7
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,8 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,9 as ID
from
  (select '' as no,'       (a) Deposit of private bank' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('L21','L22','L23','L24','L26'))q
group by q.no,q.description,'g',9
union all
select q.no,
       q.description,
       case when q.group_code='L33' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,10 as ID
from
  (select '' as no,'       (b) Other liabilities (P.O)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.group_code,10
union all
select '2' as no,
       'Time Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,11 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,12 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,13 as ID
from dual
union all
select '' as no,
       '               Current Deposit - SBB' as description,
       0 as Closing,'t' as temp,14 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'t' as temp,15 as ID
from dual
union all
select '' as no,
       '               Saving Deposit - AYA' as description,
       0 as Closing,'t' as temp,16 as ID
from dual
union all
select '' as no,
       '                              - MBL' as description,
       0 as Closing,'t' as temp,17 as ID
from dual
union all
select '' as no,
       '       (b) Other Deposits (Fixed Deposits)' as description,
       0 as Closing,'t' as temp,18 as ID
from dual
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,19 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,20 as ID
from
  (select '' as no,'        (1) BORROWING FROM (CBM)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='L31')q
group by q.no,q.description,'g',20
union all
select '' as no,
       '        (2) BORROWING FROM (MEB)' as description,
       0 as Closing,'t' as temp,21 as ID
from dual
union all
select '' as no,
       '        (3) BORROWING FROM (MBL)' as description,
       0 as Closing,'t' as temp,22 as ID
from dual
union all
select '' as no,
       '        (4) BORROWING FROM (CBM-S.L)' as description,
       0 as Closing,'t' as temp,23 as ID
from dual
union all
select '3' as no,
       'Cash in hand in Union of Myanmar' as description,
       0 as Closing,'t' as temp,24 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,25 as ID
from
  (select '' as no,'(a) Cash in hand' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A01','A02','A03'))q
group by q.no,q.description,'g',25
union all
select '4' as no,
       'Account With Bank Balances' as description,
       0 as Closing,'t' as temp,26 as ID
from dual
union all
select '' as no,
       '(1) Cash in hand in Central Bank of Myanmar' as description,
       0 as Closing,'t' as temp,27 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,28 as ID
from
  (select '' as no,'       (a)  Account with CBM' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A04','A05'))q
group by q.no,q.description,'g',28
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,29 as ID
from
(select '' as no,
       '(2) Account with Foreign Bank Balances' as description,
        case when q.group_code ='A08' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(2) Account with Foreign Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(2) Account with Foreign Bank Balances',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',29
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,30 as ID
from
  (select '' as no,'(3) Account with Privates Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',30
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10114' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,31 as ID
from(
select '' as no,'               Current Deposit - KBZ' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.gl_sub_head_code,31
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10115' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,32 as ID
from 
(select '' as no,'                               - MWD' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.gl_sub_head_code,32
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10116' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,33 as ID
from 
(select '' as no,'                               - GTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.gl_sub_head_code,33
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,34 as ID
from 
(select '' as no,
       '                               - MCB' as description,
       case when q.gl_sub_head_code='10117' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - MCB',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',34
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,35 as ID
from 
(select '' as no,
       '                               - AYA' as description,
       case when q.gl_sub_head_code='10118' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - AYA',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',35
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,36 as ID
from 
(select '' as no,
       '                               - Innwa' as description,
       case when q.gl_sub_head_code='10119' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - Innwa',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',36
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,37 as ID
from 
(select '' as no,
       '                               - CB' as description,
       case when q.gl_sub_head_code='10120' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',37
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,38 as ID
from 
(select '' as no,
       '                               - MAB' as description,
       case when q.gl_sub_head_code='10121' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - MAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',38
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,39 as ID
from 
(select '' as no,
       '                               - SMID' as description,
       case when q.gl_sub_head_code='10122' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SMID',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',39
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,40 as ID
from 
(select '' as no,
       '                               - RDB' as description,
       case when q.gl_sub_head_code='10123' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - RDB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',40
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,41 as ID
from 
(select '' as no,
       '                               - CHD' as description,
       case when q.gl_sub_head_code='10124' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CHD',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',41
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,42 as ID
from 
(select '' as no,
       '                               - UAB' as description,
       case when q.gl_sub_head_code='10125' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - UAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',42
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,43 as ID
from 
(select '' as no,
       '                               - SHWE' as description,
       case when q.gl_sub_head_code='10126' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - SHWE',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',43
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,44 as ID
from 
(select '' as no,
       '                               - SBTYY' as description,
       case when q.gl_sub_head_code='10127' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SBTYY',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',44
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code='10109' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,45 as ID
from
  (select '' as no,'                               - MEB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06')q
group by q.no,q.description,'g',q.gl_sub_head_code,45
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,46 as ID
from
  (select '' as no,'                               - MICB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10111','10112'))q
group by q.no,q.description,'g',46
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,47 as ID
from
  (select '' as no,'                               - MFTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10110','10113'))q
group by q.no,q.description,'g',47
union all
select '' as no,
       '                Saving Deposit - KBZ' as description,
       0 as Closing,'g' as temp,48 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,49 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,50 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,51 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,52 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,53 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
      0 as Closing,'g' as temp,54 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,55 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,56 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,57 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,58 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,59 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,60 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,61 as ID
from dual

union all
select '' as no,
       '                Fixed Deposit - KBZ' as description,
       0 as Closing,'g' as temp,62 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,63 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,64 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,65 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,66 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,67 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'g' as temp,68 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,69 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,70 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,71 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,72 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,73 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,74 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,75 as ID
from dual
union all
select '5' as no,
       'Demand Loans' as description,
       0 as Closing,'g' as temp,76 as ID
from dual
union all
select '6' as no,
       'Loans and Advances in Union of Myanmar' as description,
       0 as Closing,'t' as temp,77 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,78 as ID
from
(select '' as no,
       '(a) Loans and Advances to Banks' as description,
        case when q.group_code ='A28' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(a) Loans and Advances to Banks' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(a) Loans and Advances to Banks',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',78
union all
select '' as no,
       '(b) Loans and Advances to Customers' as description,
       0 as Closing,'t' as temp,79 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,80 as ID
from
(select '' as no,
       '       - LOANS ACCOUNT' as description,
        case when q.group_code ='A21' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',80
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,81 as ID
from
(select '' as no,
       '       - OVERDRAFT ACCOUNT' as description,
        case when q.group_code ='A23' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - OVERDRAFT ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - OVERDRAFT ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',81
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,82 as ID
from
(select '' as no,
       '       - HIRE PURCHASE ACCOUNT' as description,
        case when q.group_code ='A24' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - HIRE PURCHASE ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - HIRE PURCHASE ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',82
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,83 as ID
from
(select '' as no,
       '       -STAFF LOANS ACCOUNT' as description,
        case when q.group_code ='A25' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       -STAFF LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       -STAFF LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',83
union all
select '7' as no,
       'Purchased or Discounted Payment Orders in Union of Myanmar' as description,
       0 as Closing,'t' as temp,84 as ID
from dual
union all
select '8' as no,
       'Investments in Union of Myanmar' as description,
       0 as Closing,'t' as temp,85 as ID
from dual
union all
select '' as no,
       '(a) Government Securities' as description,
       0 as Closing,'t' as temp,86 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,87 as ID
from
(select '' as no,
       '       - TREASURY BONDS and BILLS' as description,
        case when q.group_code ='A11' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - TREASURY BONDS and BILLS' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = upper(ci_currency_code)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - TREASURY BONDS and BILLS',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',87
union all
select '' as no,
       '(b) Other Investments' as description,
       0 as Closing,'t' as temp,88 as ID
from dual
union all
select '' as no,
       '        According to Saving Deposits rule no.10' as description,
       0 as Closing,'t' as temp,89 as ID
from dual
union all
select '' as no,
       '       -Demand deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,90 as ID
from dual
union all
select '' as no,
       '       -Time deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,91 as ID
from dual) HEAD
group by HEAD.no,HEAD.description,HEAD.temp,HEAD.ID
order by HEAD.ID;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractPositionAll(ci_TranDate Varchar2) IS
select HEAD.no,HEAD.description,sum(HEAD.Closing) as Closing,HEAD.temp,HEAD.ID
from 
(select q.no,q.description,
      CASE WHEN q.cur = 'MMK'  THEN q.Closing
  when  q.gl_sub_head_code = '1' and  q.Closing <> 0 THEN TO_NUMBER('1')
  when  q.gl_sub_head_code = '70002' and  q.Closing <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE(ci_TranDate,'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing,q.temp,q.ID
from 
(select '1' as no,
       'Demand Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,1 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,2 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,3 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,4 as ID
from
  (select '' as no,'             Other Deposits - Current Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur as cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L11')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,4  ---14646832610.68
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,5 as ID
from
  (select '' as no,'                               Saving Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L13')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,5
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,6 as ID
from
  (select '' as no,'                               Special Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L15')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,6
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,7 as ID
from
  (select '' as no,'                               Fixed Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L17')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,7
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,8 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,9 as ID
from
  (select '' as no,'       (a) Deposit of private bank' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('L21','L22','L23','L24','L26'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,9
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,10 as ID
from
  (select '' as no,'       (b) Other liabilities (P.O)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='L33')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,10
union all
select '2' as no,
       'Time Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,11 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,12 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,13 as ID
from dual
union all
select '' as no,
       '               Current Deposit - SBB' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,14 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,15 as ID
from dual
union all
select '' as no,
       '               Saving Deposit - AYA' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,16 as ID
from dual
union all
select '' as no,
       '                              - MBL' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,17 as ID
from dual
union all
select '' as no,
       '       (b) Other Deposits (Fixed Deposits)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,18 as ID
from dual
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,19 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,20 as ID
from
  (select '' as no,'        (1) BORROWING FROM (CBM)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='L31')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,20
union all
select '' as no,
       '        (2) BORROWING FROM (MEB)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,21 as ID
from dual
union all
select '' as no,
       '        (3) BORROWING FROM (MBL)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,22 as ID
from dual
union all
select '' as no,
       '        (4) BORROWING FROM (CBM-S.L)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,23 as ID
from dual
union all
select '3' as no,
       'Cash in hand in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,24 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,25 as ID
from
  (select '' as no,'(a) Cash in hand' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A01','A02','A03'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,25
union all
select '4' as no,
       'Account With Bank Balances' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,26 as ID
from dual
union all
select '' as no,
       '(1) Cash in hand in Central Bank of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,27 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,28 as ID
from
  (select '' as no,'       (a)  Account with CBM' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A04','A05'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,28
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,29 as ID
from
(select '' as no,
       '(2) Account with Foreign Bank Balances' as description,
        case when q.group_code ='A08' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(2) Account with Foreign Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(2) Account with Foreign Bank Balances',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,29
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,30 as ID
from
  (select '' as no,'(3) Account with Privates Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,30
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,31 as ID
from(
select '' as no,'               Current Deposit - KBZ' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07'
   and coa.gl_sub_head_code ='10114')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,31
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,32 as ID
from 
(select '' as no,'                               - MWD' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07'
   and coa.gl_sub_head_code ='10115')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,32
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,33 as ID
from 
(select '' as no,'                               - GTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07'
   and coa.gl_sub_head_code ='10116')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,33
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,34 as ID
from 
(select '' as no,
       '                               - MCB' as description,
       case when q.gl_sub_head_code='10117' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - MCB',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,34
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,35 as ID
from 
(select '' as no,
       '                               - AYA' as description,
       case when q.gl_sub_head_code='10118' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - AYA',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,35
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,36 as ID
from 
(select '' as no,
       '                               - Innwa' as description,
       case when q.gl_sub_head_code='10119' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - Innwa',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,36
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,37 as ID
from 
(select '' as no,
       '                               - CB' as description,
       case when q.gl_sub_head_code='10120' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,37
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,38 as ID
from 
(select '' as no,
       '                               - MAB' as description,
       case when q.gl_sub_head_code='10121' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - MAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,38
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,39 as ID
from 
(select '' as no,
       '                               - SMID' as description,
       case when q.gl_sub_head_code='10122' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SMID',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,39
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,40 as ID
from 
(select '' as no,
       '                               - RDB' as description,
       case when q.gl_sub_head_code='10123' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - RDB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,40
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,41 as ID
from 
(select '' as no,
       '                               - CHD' as description,
       case when q.gl_sub_head_code='10124' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CHD',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,41
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,42 as ID
from 
(select '' as no,
       '                               - UAB' as description,
       case when q.gl_sub_head_code='10125' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - UAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,42
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,43 as ID
from 
(select '' as no,
       '                               - SHWE' as description,
       case when q.gl_sub_head_code='10126' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - SHWE',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,43
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,44 as ID
from 
(select '' as no,
       '                               - SBTYY' as description,
       case when q.gl_sub_head_code='10127' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SBTYY',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,44
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,45 as ID
from
  (select '' as no,'                               - MEB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code='10109')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,45
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,46 as ID
from
  (select '' as no,'                               - MICB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10111','10112'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,46
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,47 as ID
from
  (select '' as no,'                               - MFTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10110','10113'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,47
union all
select '' as no,
       '                Saving Deposit - KBZ' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,48 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,49 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,50 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,51 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1'gl_sub_head_code,52 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,53 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
      0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,54 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,55 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,56 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,57 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,58 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,59 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,60 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,61 as ID
from dual

union all
select '' as no,
       '                Fixed Deposit - KBZ' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,62 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,63 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,64 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,65 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,66 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,67 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,68 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,69 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,70 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,71 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,72 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,73 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,74 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,75 as ID
from dual
union all
select '5' as no,
       'Demand Loans' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,76 as ID
from dual
union all
select '6' as no,
       'Loans and Advances in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,77 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,78 as ID
from
(select '' as no,
       '(a) Loans and Advances to Banks' as description,
        case when q.group_code ='A28' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(a) Loans and Advances to Banks' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(a) Loans and Advances to Banks',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,78
union all
select '' as no,
       '(b) Loans and Advances to Customers' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,79 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,80 as ID
from
(select '' as no,
       '       - LOANS ACCOUNT' as description,
        case when q.group_code ='A21' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,80
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,81 as ID
from
(select '' as no,
       '       - OVERDRAFT ACCOUNT' as description,
        case when q.group_code ='A23' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - OVERDRAFT ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - OVERDRAFT ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,81
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,82 as ID
from
(select '' as no,
       '       - HIRE PURCHASE ACCOUNT' as description,
        case when q.group_code ='A24' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - HIRE PURCHASE ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - HIRE PURCHASE ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,82
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,83 as ID
from
(select '' as no,
       '       -STAFF LOANS ACCOUNT' as description,
        case when q.group_code ='A25' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       -STAFF LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       -STAFF LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,83
union all
select '7' as no,
       'Purchased or Discounted Payment Orders in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,84 as ID
from dual
union all
select '8' as no,
       'Investments in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,85 as ID
from dual
union all
select '' as no,
       '(a) Government Securities' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,86 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,87 as ID
from
(select '' as no,
       '       - TREASURY BONDS and BILLS' as description,
        case when q.group_code ='A11' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - TREASURY BONDS and BILLS' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - TREASURY BONDS and BILLS',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,87
union all
select '' as no,
       '(b) Other Investments' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,88 as ID
from dual
union all
select '' as no,
       '        According to Saving Deposits rule no.10' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,89 as ID
from dual
union all
select '' as no,
       '       -Demand deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,90 as ID
from dual
union all
select '' as no,
       '       -Time deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,91 as ID
from dual) q
order by q.ID) HEAD
group by HEAD.no,HEAD.description,HEAD.temp,HEAD.ID
order by HEAD.ID;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractPositionFCY(ci_TranDate Varchar2) IS
select HEAD.no,HEAD.description,sum(HEAD.Closing) as Closing,HEAD.temp,HEAD.ID
from 
(select q.no,q.description,
      CASE WHEN q.cur = 'MMK'  THEN q.Closing
  when  q.gl_sub_head_code = '1' and  q.Closing <> 0 THEN TO_NUMBER('1')
  when  q.gl_sub_head_code = '70002' and  q.Closing <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Closing ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE(ci_TranDate,'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing,q.temp,q.ID
from 
(select '1' as no,
       'Demand Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,1 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,2 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,3 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,4 as ID
from
  (select '' as no,'             Other Deposits - Current Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur as cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code='L11')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,4  ---14646832610.68
union all
select q.no,
       q.description,
       case when q.group_code='L13' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,5 as ID
from
  (select '' as no,'                               Saving Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,5,q.group_code
union all
select q.no,
       q.description,
       case when q.group_code='L15' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,6 as ID
from
  (select '' as no,'                               Special Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,6,q.group_code
union all
select q.no,
       q.description,
       case when q.group_code='L17' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,7 as ID
from
  (select '' as no,'                               Fixed Deposits' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,7,q.group_code
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,8 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,9 as ID
from
  (select '' as no,'       (a) Deposit of private bank' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('L21','L22','L23','L24','L26'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,9
union all
select q.no,
       q.description,
       case when q.group_code='L33' then (sum(q.Cr_amt)-sum(Dr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,10 as ID
from
  (select '' as no,'       (b) Other liabilities (P.O)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code,coa.group_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,10,q.group_code
union all
select '2' as no,
       'Time Deposit in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,11 as ID
from dual
union all
select '' as no,
       '(1) Deposits' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,12 as ID
from dual
union all
select '' as no,
       '       (a)  Deposit of bank' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,13 as ID
from dual
union all
select '' as no,
       '               Current Deposit - SBB' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,14 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,15 as ID
from dual
union all
select '' as no,
       '               Saving Deposit - AYA' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,16 as ID
from dual
union all
select '' as no,
       '                              - MBL' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,17 as ID
from dual
union all
select '' as no,
       '       (b) Other Deposits (Fixed Deposits)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,18 as ID
from dual
union all
select '' as no,
       '(2) Liabilities except customer deposit' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,19 as ID
from dual
union all
select q.no,
       q.description,
       (sum(q.Cr_amt)-sum(Dr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,20 as ID
from
  (select '' as no,'        (1) BORROWING FROM (CBM)' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='L31')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,20
union all
select '' as no,
       '        (2) BORROWING FROM (MEB)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,21 as ID
from dual
union all
select '' as no,
       '        (3) BORROWING FROM (MBL)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,22 as ID
from dual
union all
select '' as no,
       '        (4) BORROWING FROM (CBM-S.L)' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,23 as ID
from dual
union all
select '3' as no,
       'Cash in hand in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,24 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,25 as ID
from
  (select '' as no,'(a) Cash in hand' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A01','A02','A03'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,25
union all
select '4' as no,
       'Account With Bank Balances' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,26 as ID
from dual
union all
select '' as no,
       '(1) Cash in hand in Central Bank of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,27 as ID
from dual
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,28 as ID
from
  (select '' as no,'       (a)  Account with CBM' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code in ('A04','A05'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,28
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,29 as ID
from
(select '' as no,
       '(2) Account with Foreign Bank Balances' as description,
        case when q.group_code ='A08' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(2) Account with Foreign Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(2) Account with Foreign Bank Balances',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,29
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,30 as ID
from
  (select '' as no,'(3) Account with Privates Bank Balances' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,30
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10114' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,31 as ID
from(
select '' as no,'               Current Deposit - KBZ' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,31
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10115' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,32 as ID
from 
(select '' as no,'                               - MWD' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,32
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code ='10116' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,33 as ID
from 
(select '' as no,'                               - GTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,33
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,34 as ID
from 
(select '' as no,
       '                               - MCB' as description,
       case when q.gl_sub_head_code='10117' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - MCB',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,34
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,35 as ID
from 
(select '' as no,
       '                               - AYA' as description,
       case when q.gl_sub_head_code='10118' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - AYA',q.gl_sub_head_code,q.cur)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,35
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,36 as ID
from 
(select '' as no,
       '                               - Innwa' as description,
       case when q.gl_sub_head_code='10119' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - Innwa',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,36
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,37 as ID
from 
(select '' as no,
       '                               - CB' as description,
       case when q.gl_sub_head_code='10120' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,37
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,38 as ID
from 
(select '' as no,
       '                               - MAB' as description,
       case when q.gl_sub_head_code='10121' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - MAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,38
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,39 as ID
from 
(select '' as no,
       '                               - SMID' as description,
       case when q.gl_sub_head_code='10122' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SMID',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,39
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,40 as ID
from 
(select '' as no,
       '                               - RDB' as description,
       case when q.gl_sub_head_code='10123' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - RDB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,40
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,41 as ID
from 
(select '' as no,
       '                               - CHD' as description,
       case when q.gl_sub_head_code='10124' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - CHD',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,41
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,42 as ID
from 
(select '' as no,
       '                               - UAB' as description,
       case when q.gl_sub_head_code='10125' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - UAB',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,42
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,43 as ID
from 
(select '' as no,
       '                               - SHWE' as description,
       case when q.gl_sub_head_code='10126' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
   group by '','                               - SHWE',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,43
union all
select T.no,T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,44 as ID
from 
(select '' as no,
       '                               - SBTYY' as description,
       case when q.gl_sub_head_code='10127' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from 
(select 
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A07')q
group by '','                               - SBTYY',q.cur,q.gl_sub_head_code)T
group by T.no,T.description,'g',T.cur,T.gl_sub_head_code,44
union all
select q.no,
       q.description,
       case when q.gl_sub_head_code='10109' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,'g' as temp,q.cur,q.gl_sub_head_code,45 as ID
from
  (select '' as no,'                               - MEB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06')q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,45
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,46 as ID
from
  (select '' as no,'                               - MICB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10111','10112'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,46
union all
select q.no,
       q.description,
       (sum(Dr_amt)-sum(q.Cr_amt)) as Closing,'g' as temp,q.cur,q.gl_sub_head_code,47 as ID
from
  (select '' as no,'                               - MFTB' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.group_code ='A06'
   and coa.gl_sub_head_code in ('10110','10113'))q
group by q.no,q.description,'g',q.cur,q.gl_sub_head_code,47
union all
select '' as no,
       '                Saving Deposit - KBZ' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,48 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,49 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,50 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,51 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1'gl_sub_head_code,52 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,53 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
      0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,54 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,55 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,56 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,57 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,58 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,59 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,60 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,61 as ID
from dual

union all
select '' as no,
       '                Fixed Deposit - KBZ' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,62 as ID
from dual
union all
select '' as no,
       '                               - MWD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,63 as ID
from dual
union all
select '' as no,
       '                               - GTB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,64 as ID
from dual
union all
select '' as no,
       '                               - MCB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,65 as ID
from dual
union all
select '' as no,
       '                               - AYA' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,66 as ID
from dual
union all
select '' as no,
       '                               - Innwa' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,67 as ID
from dual
union all
select '' as no,
       '                               - CB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,68 as ID
from dual
union all
select '' as no,
       '                               - MAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,69 as ID
from dual
union all
select '' as no,
       '                               - SMID' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,70 as ID
from dual
union all
select '' as no,
       '                               - RDB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,71 as ID
from dual
union all
select '' as no,
       '                               - CHD' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,72 as ID
from dual
union all
select '' as no,
       '                               - UAB' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,73 as ID
from dual
union all
select '' as no,
       '                               - SHWE' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,74 as ID
from dual
union all
select '' as no,
       '                               - SBTYY' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,75 as ID
from dual
union all
select '5' as no,
       'Demand Loans' as description,
       0 as Closing,'g' as temp,'MMK' as cur,'1' as gl_sub_head_code,76 as ID
from dual
union all
select '6' as no,
       'Loans and Advances in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,77 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,78 as ID
from
(select '' as no,
       '(a) Loans and Advances to Banks' as description,
        case when q.group_code ='A28' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'(a) Loans and Advances to Banks' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','(a) Loans and Advances to Banks',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,78
union all
select '' as no,
       '(b) Loans and Advances to Customers' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,79 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,80 as ID
from
(select '' as no,
       '       - LOANS ACCOUNT' as description,
        case when q.group_code ='A21' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,80
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,81 as ID
from
(select '' as no,
       '       - OVERDRAFT ACCOUNT' as description,
        case when q.group_code ='A23' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - OVERDRAFT ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - OVERDRAFT ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,81
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,82 as ID
from
(select '' as no,
       '       - HIRE PURCHASE ACCOUNT' as description,
        case when q.group_code ='A24' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - HIRE PURCHASE ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - HIRE PURCHASE ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,82
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,83 as ID
from
(select '' as no,
       '       -STAFF LOANS ACCOUNT' as description,
        case when q.group_code ='A25' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       -STAFF LOANS ACCOUNT' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       -STAFF LOANS ACCOUNT',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,83
union all
select '7' as no,
       'Purchased or Discounted Payment Orders in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,84 as ID
from dual
union all
select '8' as no,
       'Investments in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,85 as ID
from dual
union all
select '' as no,
       '(a) Government Securities' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,86 as ID
from dual
union all
select T.no, T.description,sum(T.Closing) as Closing,'g' as temp,T.cur,T.gl_sub_head_code,87 as ID
from
(select '' as no,
       '       - TREASURY BONDS and BILLS' as description,
        case when q.group_code ='A11' then (sum(Dr_amt)-sum(q.Cr_amt)) else 0 end as Closing,q.cur,q.gl_sub_head_code
from
  (select '' as no,'       - TREASURY BONDS and BILLS' as description,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt,coa.group_code,coa.cur,coa.gl_sub_head_code
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.crncy_code != upper('MMK')
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01')q
group by '','       - TREASURY BONDS and BILLS',q.group_code,q.cur,q.gl_sub_head_code)T
group by T.no, T.description,'g',T.cur,T.gl_sub_head_code,87
union all
select '' as no,
       '(b) Other Investments' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,88 as ID
from dual
union all
select '' as no,
       '        According to Saving Deposits rule no.10' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,89 as ID
from dual
union all
select '' as no,
       '       -Demand deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,90 as ID
from dual
union all
select '' as no,
       '       -Time deposit (or) other investors in Union of Myanmar' as description,
       0 as Closing,'t' as temp,'MMK' as cur,'1' as gl_sub_head_code,91 as ID
from dual) q
order by q.ID) HEAD
group by HEAD.no,HEAD.description,HEAD.temp,HEAD.ID
order by HEAD.ID;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_FRIDAY_POSITION_NEW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_no custom.coa_mp.description%type;
    v_description Varchar(200);
     v_Closing Number;
     v_temp Varchar2(10);
     v_ID Varchar2(10);
     v_rate Number;
     
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
     vi_currency_code :=outArr(1);
     vi_currency_type :=outArr(2);
     
     -----------------------------------------------------------------
     if(vi_TranDate  is null or vi_currency_type is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
------------------------------------------------------------------------------------------------------------
 If vi_currency_type not like 'All Currency%' then
     IF NOT ExtractPositionMMK%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractPositionMMK ( vi_TranDate, vi_currency_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractPositionMMK%ISOPEN THEN
        --{
          FETCH	ExtractPositionMMK
          INTO  v_no,v_description,v_Closing,v_temp,v_ID;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractPositionMMK%NOTFOUND THEN
          --{
            CLOSE ExtractPositionMMK;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
  ELSIF vi_currency_type = 'All Currency' then
        IF NOT ExtractPositionAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractPositionAll ( vi_TranDate);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractPositionAll%ISOPEN THEN
        --{
          FETCH	ExtractPositionAll
          INTO  v_no,v_description,v_Closing,v_temp,v_ID;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractPositionAll%NOTFOUND THEN
          --{
            CLOSE ExtractPositionAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
ELSE 
     IF NOT ExtractPositionFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractPositionFCY( vi_TranDate);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractPositionFCY%ISOPEN THEN
        --{
          FETCH	ExtractPositionFCY
          INTO  v_no,v_description,v_Closing,v_temp,v_ID;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractPositionFCY%NOTFOUND THEN
          --{
            CLOSE ExtractPositionFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
END If;
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
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (   v_no  || '|' ||
                  v_description|| '|' ||
                  v_Closing || '|' ||
                  v_temp || '|' ||
                  v_rate
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_FRIDAY_POSITION_NEW;

END FIN_FRIDAY_POSITION_NEW;
/
