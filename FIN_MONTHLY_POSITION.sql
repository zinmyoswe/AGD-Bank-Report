CREATE OR REPLACE PACKAGE FIN_MONTHLY_POSITION AS 

  PROCEDURE FIN_MONTHLY_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_MONTHLY_POSITION;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_MONTHLY_POSITION AS

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
select G.no,G.description,G.gl_sub_head_desc,G.Closing,
      case when G.gl_sub_head_desc is null then 0 
           when G.gl_sub_head_desc='Current A/C' then 1 
           when G.gl_sub_head_desc='Current A/C(Foreign Currency)' then 2
           when G.gl_sub_head_desc='Saving Deposit A/C' then 3
           when G.gl_sub_head_desc='Special Deposit A/C' then 4
           when G.gl_sub_head_desc='Fixed Deposit A/C' then 5
           when G.gl_sub_head_desc='Loan' then 6
           when G.gl_sub_head_desc ='Overdraft' then 7
           when G.gl_sub_head_desc ='Hire purchase' then 8
           when G.gl_sub_head_desc ='Staff Loan' then 9
           when G.gl_sub_head_desc ='A/C with State  Bank' then 10
           when G.gl_sub_head_desc ='A/C with Private Bank' then 11
           when G.gl_sub_head_desc ='A/C with Foreign Bank' then 12
           when G.gl_sub_head_desc ='Treasury Bond' then 13 
           when G.gl_sub_head_desc ='Treasury Bill' then 14
           when G.gl_sub_head_desc ='CBM' then 15
           when G.gl_sub_head_desc ='Institution' then 16 
           when G.gl_sub_head_desc ='Branches' then 17
           when G.gl_sub_head_desc ='Mini-Branches' then 18
           when G.gl_sub_head_desc ='Employee' then 19  
           else  123  end as gl_desc
from
(select A.no,A.description,A.gl_sub_head_desc,sum(A.Closing) as Closing
from
(select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select T.no, T.description,T.gl_sub_head_desc,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from
(select coa.group_code,1 as no,'Paid-up Capital' as description,coa.gl_sub_head_code,'' as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code ='L01'
  and coa.cur =upper(ci_currency_code) ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Paid-up Capital' as description,
   coa.gl_sub_head_code,
   '' as gl_sub_head_desc,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code ='L01')q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code)T
group by T.no, T.description,T.gl_sub_head_desc) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from
(select coa.group_code,2 as no,'Deposit' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26')
  and coa.cur =upper(ci_currency_code) ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Deposit' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X --Deposit
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
order by X.gl_sub_head_code) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select T.no,T.description,T.group_code,T.gl_sub_head_desc,SUM(T.Closing) as Closing
from 
(select GL.no,GL.description,Gl.group_code,GL.gl_sub_head_desc,X.Closing
from
(select coa.group_code,3 as no,'Loan and Advances' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code in ('A21','A23','A24','A25')
  and coa.cur =upper(ci_currency_code) ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'Loan and Advances' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code in ('A21','A23','A24','A25'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X --Loan and Advances
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
order by X.gl_sub_head_code) T
group by T.no,T.description,T.gl_sub_head_desc,T.group_code
order by T.group_code) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select T.no,T.description,T.gl_sub_head_desc,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from
(select coa.group_code,4 as no,'A/C with Other Bank' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code in ('A06','A07','A08')
  and coa.cur =upper(ci_currency_code) ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'A/C with Other Bank' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code in ('A06','A07','A08'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X --A/C with Other Bank
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
order by X.gl_sub_head_code)T
group by T.no,T.description,T.gl_sub_head_desc) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bond' as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code ='A11'
  and coa.cur =upper(ci_currency_code) ) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bond' as gl_sub_head_desc,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and gam.acct_crncy_code =upper(ci_currency_code)
and coa.group_code ='A11'
and gam.foracid in ('1010010201010011','1010010201020011','1010010201030011',' 1010010201030041')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code)B --Government Securities1

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bill' as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code ='A11'
  and coa.cur =upper(ci_currency_code) ) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bill' as gl_sub_head_desc,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and gam.acct_crncy_code =upper(ci_currency_code)
and coa.group_code ='A11'
and gam.foracid in('1010010201010021','1010010201010031','1010010201020021','1010010201020031','1010010201030021','1010010201030031','1010010201030051','1010010201030061')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code)B  --Government Securities2

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing/1000000 as Closing
from
(select T.no,T.description,T.gl_sub_head_desc,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.Closing
from
(select coa.group_code,6 as no,'Borrowing from other institutions' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc
  from custom.coa_mp coa
  where coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142')
  and coa.cur =upper(ci_currency_code) ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,
       (sum(q.Cr_amt)- sum(q.Dr_amt)) as Closing
from
  (select coa.group_code,
   'Borrowing from other institutions' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
order by X.gl_sub_head_code)T
group by T.no,T.description,T.gl_sub_head_desc) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing
from
(select 7 as no,
      'Number of Branches' as description,
      'Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc not like '%MINI%')B
union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing
from
(select 7 as no,
      'Number of Branches' as description,
      'Mini-Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc like '%MINI%')B
union all
select B.no,B.description,B.gl_sub_head_desc,B.Closing
from
(select 8 as no,
       'Strength' as description,
       'Employee' as gl_sub_head_desc,
       count(user_id) as Closing
from tbaadm.upr) B)A
group by A.no,A.description,A.gl_sub_head_desc) G
order by gl_desc;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractPositionAll(ci_TranDate Varchar2) IS
select G.no,G.description,G.gl_sub_head_desc,G.Closing,
      case when G.gl_sub_head_desc is null then 0 
           when G.gl_sub_head_desc='Current A/C' then 1 
           when G.gl_sub_head_desc='Current A/C(Foreign Currency)' then 2
           when G.gl_sub_head_desc='Saving Deposit A/C' then 3
           when G.gl_sub_head_desc='Special Deposit A/C' then 4
           when G.gl_sub_head_desc='Fixed Deposit A/C' then 5
           when G.gl_sub_head_desc='Loan' then 6
           when G.gl_sub_head_desc ='Overdraft' then 7
           when G.gl_sub_head_desc ='Hire purchase' then 8
           when G.gl_sub_head_desc ='Staff Loan' then 9
           when G.gl_sub_head_desc ='A/C with State  Bank' then 10
           when G.gl_sub_head_desc ='A/C with Private Bank' then 11
           when G.gl_sub_head_desc ='A/C with Foreign Bank' then 12
           when G.gl_sub_head_desc ='Treasury Bond' then 13 
           when G.gl_sub_head_desc ='Treasury Bill' then 14
           when G.gl_sub_head_desc ='CBM' then 15
           when G.gl_sub_head_desc ='Institution' then 16 
           when G.gl_sub_head_desc ='Branches' then 17
           when G.gl_sub_head_desc ='Mini-Branches' then 18
           when G.gl_sub_head_desc ='Employee' then 19  
           else  123  end as gl_desc
from
(select A.no,A.description,A.gl_sub_head_desc,sum(A.Closing) as Closing
from 
(select H.no,H.group_code,H.description,H.gl_sub_head_desc,H.Closing
from 
(select HEAD.no,HEAD.group_code, HEAD.description,HEAD.gl_sub_head_desc, SUM(HEAD.Closing)/1000000 as Closing
from
(select Q.no,Q.group_Code, Q.description, Q.gl_sub_head_desc,Q.gl_sub_head_code,
  CASE WHEN Q.cur = 'MMK'  THEN Q.Closing
  when  Q.gl_sub_head_code = '70002' and  Q.Closing <> 0 THEN TO_NUMBER('4138000000')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='18282678.36' and Q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='1259531.25' and Q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='653408.19' and Q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='874441.97' and Q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='29894' and Q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE Q.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
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
                              ),1) END AS Closing
from
(select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing 
from
(select T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,1 as no,'Paid-up Capital' as description,coa.gl_sub_head_code,'' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='L01') GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Paid-up Capital' as description,
   coa.gl_sub_head_code,
   '' as gl_sub_head_desc, coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.group_code ='L01')q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur)T
group by T.no,T.group_code, T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur) B

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,2 as no,'Deposit' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26') ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Deposit' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Deposit
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by GL.group_code,X.gl_sub_head_code) B

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from 
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,3 as no,'Loan and Advances' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('A21','A23','A24','A25')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'Loan and Advances' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.group_code in ('A21','A23','A24','A25'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Loan and Advances
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by X.gl_sub_head_code) T
group by T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.group_code,T.cur
order by T.group_code,T.gl_sub_head_code) B

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,4 as no,'A/C with Other Bank' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('A06','A07','A08') ) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'A/C with Other Bank' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.group_code in ('A06','A07','A08'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --A/C with Other Bank
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by GL.group_code,X.gl_sub_head_code)T
group by T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur) B

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bond' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='A11' ) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,q.cur,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bond' as gl_sub_head_desc,coa.cur,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and coa.group_code ='A11'
and gam.foracid in ('1010010201010011','1010010201020011','1010010201030011',' 1010010201030041')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X
on GL.group_code=X.group_code
and GL.cur = X.cur
and GL.gl_sub_head_code=X.gl_sub_head_code
order by GL.group_code,X.gl_sub_head_code)B --Government Securities1

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bill' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='A11' ) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,q.cur,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bill' as gl_sub_head_desc,coa.cur,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and coa.group_code ='A11'
and gam.foracid in('1010010201010021','1010010201010031','1010010201020021','1010010201020031','1010010201030021','1010010201030031','1010010201030051','1010010201030061')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by GL.group_code,X.gl_sub_head_code)B  --Government Securities2

union all
select B.no,B.group_code,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.group_code,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,6 as no,'Borrowing from other institutions' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142')
  order by coa.gl_sub_head_code) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(q.Dr_amt)) as Closing
from
  (select coa.group_code,
   'Borrowing from other institutions' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142')
  order by coa.group_code,coa.gl_sub_head_code)q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur
order by q.group_code,q.gl_sub_head_code) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by GL.group_code,X.gl_sub_head_code)T
group by T.no,T.group_code,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur
order by T.no,T.group_code,T.gl_sub_head_code) B)Q)HEAD
group by HEAD.no,HEAD.group_code, HEAD.description,HEAD.gl_sub_head_desc
union all
select HEAD.no,HEAD.group_code,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 7 as no,
      '1' as group_code,
      'Number of Branches' as description,
      'Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc not like '%MINI%')HEAD
union all
select HEAD.no,HEAD.group_code,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 7 as no,
      '2' as group_code,
      'Number of Branches' as description,
      'Mini-Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc like '%MINI%')HEAD
union all
select HEAD.no,HEAD.group_code,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 8 as no,
       '1' as group_code,
       'Strength' as description,
       'Employee' as gl_sub_head_desc,
       count(user_id) as Closing
from tbaadm.upr) HEAD)H
order by H.no,H.group_code) A
group by A.no,A.description,A.gl_sub_head_desc) G
order by gl_desc;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractPositionFCY(ci_TranDate Varchar2) IS
select G.no,G.description,G.gl_sub_head_desc,G.Closing,
      case when G.gl_sub_head_desc is null then 0 
           when G.gl_sub_head_desc='Current A/C' then 1 
           when G.gl_sub_head_desc='Current A/C(Foreign Currency)' then 2
           when G.gl_sub_head_desc='Saving Deposit A/C' then 3
           when G.gl_sub_head_desc='Special Deposit A/C' then 4
           when G.gl_sub_head_desc='Fixed Deposit A/C' then 5
           when G.gl_sub_head_desc='Loan' then 6
           when G.gl_sub_head_desc ='Overdraft' then 7
           when G.gl_sub_head_desc ='Hire purchase' then 8
           when G.gl_sub_head_desc ='Staff Loan' then 9
           when G.gl_sub_head_desc ='A/C with State  Bank' then 10
           when G.gl_sub_head_desc ='A/C with Private Bank' then 11
           when G.gl_sub_head_desc ='A/C with Foreign Bank' then 12
           when G.gl_sub_head_desc ='Treasury Bond' then 13 
           when G.gl_sub_head_desc ='Treasury Bill' then 14
           when G.gl_sub_head_desc ='CBM' then 15
           when G.gl_sub_head_desc ='Institution' then 16 
           when G.gl_sub_head_desc ='Branches' then 17
           when G.gl_sub_head_desc ='Mini-Branches' then 18
           when G.gl_sub_head_desc ='Employee' then 19  
           else  123  end as gl_desc
from
(select A.no,A.description,A.gl_sub_head_desc,sum(A.Closing) as Closing
from 
(select H.no,H.description,H.gl_sub_head_desc,H.Closing
from 
(select HEAD.no, HEAD.description,HEAD.gl_sub_head_desc, SUM(HEAD.Closing)/1000000 as Closing
from
(select Q.no, Q.description, Q.gl_sub_head_desc,Q.gl_sub_head_code,
  CASE WHEN Q.cur = 'MMK'  THEN Q.Closing
  when  Q.gl_sub_head_code = '70002' and  Q.Closing <> 0 THEN TO_NUMBER('4138000000')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='18282678.36' and Q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='1259531.25' and Q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='653408.19' and Q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='874441.97' and Q.cur = 'THB' THEN TO_NUMBER('34103236.83')
  when  Q.gl_sub_head_code = '60161' and  Q.Closing ='29894' and Q.cur = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE Q.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
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
                              ),1) END AS Closing
from
(select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing 
from
(select T.no, T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,1 as no,'Paid-up Capital' as description,coa.gl_sub_head_code,'' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='L01'
  and coa.cur !=upper('MMK')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Paid-up Capital' as description,
   coa.gl_sub_head_code,
   '' as gl_sub_head_desc, coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
    and coa.cur !=upper('MMK')
    and gsh.crncy_code !=upper('MMK')
    and gstt.crncy_code !=upper('MMK')
   and coa.group_code ='L01')q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur)T
group by T.no, T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,2 as no,'Deposit' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26')
  and coa.cur != upper('MMK')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(Dr_amt)) as Closing
from
  (select coa.group_code,
   'Deposit' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code =coa.cur
   and coa.cur !=upper('MMK')
    and gsh.crncy_code !=upper('MMK')
    and gstt.crncy_code !=upper('MMK')
   and coa.group_code in ('L11','L13','L15','L17','L21','L22','L23','L24','L26'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Deposit
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by X.gl_sub_head_code) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.description,T.group_code,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from 
(select GL.no,GL.description,Gl.group_code,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,3 as no,'Loan and Advances' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('A21','A23','A24','A25')
  and coa.cur !=upper('MMK')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'Loan and Advances' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.cur !=upper('MMK')
    and gsh.crncy_code !=upper('MMK')
    and gstt.crncy_code !=upper('MMK')
   and coa.group_code in ('A21','A23','A24','A25'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Loan and Advances
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by X.gl_sub_head_code) T
group by T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.group_code,T.cur
order by T.group_code,T.gl_sub_head_code) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,4 as no,'A/C with Other Bank' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code in ('A06','A07','A08')
  and coa.cur !=upper('MMK')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Dr_amt)- sum(q.Cr_amt)) as Closing
from
  (select coa.group_code,
   'A/C with Other Bank' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.cur !=upper('MMK')
    and gsh.crncy_code !=upper('MMK')
    and gstt.crncy_code !=upper('MMK')
   and coa.group_code in ('A06','A07','A08'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --A/C with Other Bank
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by X.gl_sub_head_code)T
group by T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur) B

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bond' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='A11' 
  and coa.cur !=upper('MMK')) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,q.cur,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bond' as gl_sub_head_desc,coa.cur,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and coa.cur !=upper('MMK')
and gam.acct_crncy_code !=upper('MMK')
    and eab.eab_crncy_code !=upper('MMK')
and coa.group_code ='A11'
and gam.foracid in ('1010010201010011','1010010201020011','1010010201030011',' 1010010201030041')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X
on GL.group_code=X.group_code
and GL.cur = X.cur
and GL.gl_sub_head_code=X.gl_sub_head_code)B --Government Securities1

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from 
(select coa.group_code,5 as no,'Government Securities' as description,coa.gl_sub_head_code, 'Treasury Bill' as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='A11'
  and coa.cur !=upper('MMK')) GL 
  left join
(select q.group_code,
        q.description,
        q.gl_sub_head_code,
        q.gl_sub_head_desc,q.cur,
        sum(q.tran_date_bal) as Closing
from
(select coa.group_code,
        5 as no,
       'Government Securities' as description,
       coa.gl_sub_head_code,
       'Treasury Bill' as gl_sub_head_desc,coa.cur,
       eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and coa.cur !=upper('MMK')
    and gam.acct_crncy_code !=upper('MMK')
    and eab.eab_crncy_code !=upper('MMK')
and coa.group_code ='A11'
and gam.foracid in('1010010201010021','1010010201010031','1010010201020021','1010010201020031','1010010201030021','1010010201030031','1010010201030051','1010010201030061')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur)B  --Government Securities2

union all
select B.no,B.description,B.gl_sub_head_desc,B.gl_sub_head_code,B.cur,B.Closing
from
(select T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur,SUM(T.Closing) as Closing
from
(select GL.no,GL.description,GL.gl_sub_head_desc,X.gl_sub_head_code,X.cur,X.Closing
from
(select coa.group_code,6 as no,'Borrowing from other institutions' as description,coa.gl_sub_head_code, coa.remarks as gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142')
  and coa.cur !=upper('MMK')) GL
Left Join
(select q.group_code,
       q.description,
       q.gl_sub_head_code,
       q.gl_sub_head_desc,q.cur,
       (sum(q.Cr_amt)- sum(q.Dr_amt)) as Closing
from
  (select coa.group_code,
   'Borrowing from other institutions' as description,
   coa.gl_sub_head_code,
   coa.gl_sub_head_desc,coa.cur,
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa,tbaadm.gsh gsh
where gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   and gstt.crncy_code = coa.cur
   and coa.cur !=upper('MMK')
    and gsh.crncy_code !=upper('MMK')
    and gstt.crncy_code !=upper('MMK')
   and coa.group_code ='L31'
  and coa.gl_sub_head_code in ('70141','70142'))q
group by q.group_code,q.description,q.gl_sub_head_code,q.gl_sub_head_desc,q.cur) X --Capital
on GL.group_code=X.group_code
and GL.gl_sub_head_code=X.gl_sub_head_code
and GL.cur = X.cur
order by X.gl_sub_head_code)T
group by T.no,T.description,T.gl_sub_head_desc,T.gl_sub_head_code,T.cur) B)Q)HEAD
group by HEAD.no, HEAD.description,HEAD.gl_sub_head_desc
union all
select HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 7 as no,
      'Number of Branches' as description,
      'Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc not like '%MINI%')HEAD
union all
select HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 7 as no,
      'Number of Branches' as description,
      'Mini-Branches' as gl_sub_head_desc,
      count(sol_id) as Closing
from tbaadm.sol where sol_desc like '%MINI%')HEAD
union all
select HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.Closing
from
(select 8 as no,
       'Strength' as description,
       'Employee' as gl_sub_head_desc,
       count(user_id) as Closing
from tbaadm.upr) HEAD)H
order by H.no)A
group by A.no,A.description,A.gl_sub_head_desc)G
order by gl_desc;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_MONTHLY_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_no Varchar2(10);
    v_description custom.coa_mp.description%type;
    v_gl_sub_head_desc custom.coa_mp.gl_sub_head_desc%type;
     v_Closing tbaadm.gstt.tot_dr_bal%type;
     v_rate Number;
     v_gl_desc Varchar2(20);
     
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
     if(vi_TranDate  is null or vi_currency_type is null ) then
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
          INTO  v_no,v_description, v_gl_sub_head_desc,v_Closing,v_gl_desc;
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
          INTO  v_no,v_description, v_gl_sub_head_desc,v_Closing,v_gl_desc;
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
          INTO  v_no,v_description, v_gl_sub_head_desc,v_Closing,v_gl_desc;
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
                  v_gl_sub_head_desc|| '|' ||
                  v_Closing || '|' ||
                  v_rate
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_MONTHLY_POSITION;

END FIN_MONTHLY_POSITION;
/
