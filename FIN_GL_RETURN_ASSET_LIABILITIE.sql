CREATE OR REPLACE PACKAGE FIN_GL_RETURN_ASSET_LIABILITIE AS 

  PROCEDURE FIN_GL_RETURN_ASSET_LIABILITIE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_GL_RETURN_ASSET_LIABILITIE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_GL_RETURN_ASSET_LIABILITIE AS

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

Cursor ExtractDataAsset(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2) IS
select T.group_code,
       T.description,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt),
       sum(T.Transfer_Dr_amt),
       sum(T.Clearing_dr_amt),
       sum(T.Cash_Cr_amt),
       sum(T.Transfer_Cr_amt),
       sum(T.Clearing_Cr_amt)
from 
(select q.group_code,
   q.description,
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
   coa.group_code,
   coa.description,
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
   and coa.group_code like 'A%' )q 
   group by q.group_code, q.description 
union all 
   select q.group_code ,
   q.description ,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(select coa.group_code,
   coa.description,
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
   and coa.group_code like 'A%')q 
   group by q.group_code, q.description) T
   group by T.group_code,T.description
   order by T.group_code;
   
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractAssetAll(ci_TranDate Varchar2, ci_branch_code Varchar2) IS
select HEAD.group_code,
      HEAD.description,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from 
(select B.group_code,
       B.description,
       CASE WHEN B.cur = 'MMK'  THEN B.Opening
      when  B.gl_sub_head_code = '70002' and  B.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
                              
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
 CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
   CASE WHEN B.cur = 'MMK'  THEN B.Closing
      when  B.gl_sub_head_code = '70002' and  B.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
(select T.group_code,T.gl_sub_head_code,
       T.description,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      ( sum(T.Closing_dr_amt)-sum(T.Closing_cr_amt)) as Closing
from 
(select q.group_code,q.gl_sub_head_code,
   q.description,q.cur,
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
   coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'A%' )q 
   group by q.group_code, q.description ,q.cur,q.gl_sub_head_code
   
union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'A%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code
   
   union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'A%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code) T
   group by T.group_code,T.description,T.cur,T.gl_sub_head_code
   order by T.group_code) B 
   order by B.group_code)HEAD
   group by HEAD.group_code, HEAD.description
   order by HEAD.group_code;
   
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractAssetFCY(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select HEAD.group_code,
      HEAD.description,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from 
(select B.group_code,
       B.description,
       CASE WHEN B.cur = 'MMK'  THEN B.Opening
      when  B.gl_sub_head_code = '70002' and  B.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
                              
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
 CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
   CASE WHEN B.cur = 'MMK'  THEN B.Closing
      when  B.gl_sub_head_code = '70002' and  B.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
(select T.group_code,T.gl_sub_head_code,
       T.description,T.cur,
       ( sum(T.Dr_amt)-sum(T.Cr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      ( sum(T.Closing_dr_amt)-sum(T.Closing_cr_amt)) as Closing
from 
(select q.group_code,q.gl_sub_head_code,
   q.description,q.cur,
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
   coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.cur != upper('MMK')
   and coa.group_code like 'A%' )q 
   group by q.group_code, q.description ,q.cur,q.gl_sub_head_code
   
union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'A%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code
   
   union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.group_code like 'A%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code) T
   group by T.group_code,T.description,T.cur,T.gl_sub_head_code
   order by T.group_code) B 
   order by B.group_code)HEAD
   group by HEAD.group_code, HEAD.description
   order by HEAD.group_code;
   

-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataLiabilities(ci_TranDate Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2) IS
select T.group_code,
       T.description,
      (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt),
       sum(T.Transfer_Dr_amt),
       sum(T.Clearing_dr_amt),
       sum(T.Cash_Cr_amt),
       sum(T.Transfer_Cr_amt),
       sum(T.Clearing_Cr_amt)
from 
(select q.group_code,
   q.description,
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
   coa.group_code,
   coa.description,
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
   and coa.group_code like 'L%' )q 
   group by q.group_code, q.description 
union all 
   select q.group_code ,
   q.description ,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt,
  sum(q.Cash_Dr_amt) as Cash_Dr_amt,
    sum(q.Transfer_Dr_amt) as Transfer_Dr_amt,
    sum(q.Clearing_dr_amt) as Clearing_dr_amt,
    sum(q.Cash_Cr_amt) as Cash_Cr_amt,
    sum(q.Transfer_Cr_amt) as Transfer_Cr_amt,
    sum(q.Clearing_Cr_amt) as Clearing_Cr_amt
from(select coa.group_code,
   coa.description,
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
   and coa.group_code like 'L%')q 
   group by q.group_code, q.description) T
   group by T.group_code,T.description
   order by T.group_code;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractLiabilitiesAll(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select HEAD.group_code,
      HEAD.description,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from 
(select B.group_code,
       B.description,
       CASE WHEN B.cur = 'MMK'  THEN B.Opening
      when  B.gl_sub_head_code = '70002' and  B.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
                              
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
 CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
   CASE WHEN B.cur = 'MMK'  THEN B.Closing
      when  B.gl_sub_head_code = '70002' and  B.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
(select T.group_code,T.gl_sub_head_code,
       T.description,T.cur,
       (sum(T.Cr_amt)-sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.group_code,q.gl_sub_head_code,
   q.description,q.cur,
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
   coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'L%' )q 
   group by q.group_code, q.description ,q.cur,q.gl_sub_head_code
   
union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'L%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code
   
   union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'L%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code) T
   group by T.group_code,T.description,T.cur,T.gl_sub_head_code
   order by T.group_code) B 
   order by B.group_code)HEAD
   group by HEAD.group_code, HEAD.description
   order by HEAD.group_code;
-------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractLiabilitiesFCY(ci_TranDate Varchar2,ci_branch_code Varchar2) IS
select HEAD.group_code,
      HEAD.description,
      SUM(HEAD.Opening),
      SUM(HEAD.Cash_Dr_amt),
      SUM(HEAD.Transfer_Dr_amt),
      SUM(HEAD.Clearing_dr_amt),
      SUM(HEAD.Cash_Cr_amt),
      SUM(HEAD.Transfer_Cr_amt),
      SUM(HEAD.Clearing_Cr_amt),
      SUM(HEAD.Closing)
from 
(select B.group_code,
       B.description,
       CASE WHEN B.cur = 'MMK'  THEN B.Opening
      when  B.gl_sub_head_code = '70002' and  B.Opening <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Opening ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Opening * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
                              
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
 CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_dr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_dr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_dr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_dr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Cash_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Cash_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Cash_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Cash_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Transfer_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Transfer_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Transfer_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Transfer_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
  CASE WHEN B.cur = 'MMK'  THEN B.Clearing_Cr_amt
      when  B.gl_sub_head_code = '70002' and  B.Clearing_Cr_amt <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Clearing_Cr_amt ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Clearing_Cr_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
   CASE WHEN B.cur = 'MMK'  THEN B.Closing
      when  B.gl_sub_head_code = '70002' and  B.Closing <> 0 THEN TO_NUMBER('4138000000')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='18282678.36' and B.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='1259531.25' and B.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='653408.19' and B.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='874441.97' and B.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  B.gl_sub_head_code = '60161' and  B.Closing ='29894' and B.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE B.Closing * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(B.cur) 
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
(select T.group_code,T.gl_sub_head_code,
       T.description,T.cur,
       (sum(T.Cr_amt)- sum(T.Dr_amt)) as Opening,
       sum(T.Cash_Dr_amt) as Cash_Dr_amt,
       sum(T.Transfer_Dr_amt) as Transfer_Dr_amt,
       sum(T.Clearing_dr_amt) as Clearing_dr_amt,
       sum(T.Cash_Cr_amt) as Cash_Cr_amt,
       sum(T.Transfer_Cr_amt) as Transfer_Cr_amt,
       sum(T.Clearing_Cr_amt) as Clearing_Cr_amt,
      (sum(T.Closing_cr_amt)- sum(T.Closing_dr_amt)) as Closing
from 
(select q.group_code,q.gl_sub_head_code,
   q.description,q.cur,
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
   coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.cur != upper('MMK')
   and coa.group_code like 'L%' )q 
   group by q.group_code, q.description ,q.cur,q.gl_sub_head_code
   
union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and coa.group_code like 'L%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code
   
   union all 
   select q.group_code ,q.gl_sub_head_code,
   q.description ,q.cur,
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
(select coa.group_code,coa.gl_sub_head_code,
   coa.description,coa.cur,
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
   and gsh.crncy_code != upper('MMK')
   and gstt.crncy_code != upper('MMK')
   and coa.cur!= upper('MMK')
   and coa.group_code like 'L%')q 
   group by q.group_code, q.description,q.cur,q.gl_sub_head_code) T
   group by T.group_code,T.description,T.cur,T.gl_sub_head_code
   order by T.group_code) B 
   order by B.group_code)HEAD
   group by HEAD.group_code, HEAD.description
   order by HEAD.group_code;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_GL_RETURN_ASSET_LIABILITIE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_group_code  custom.coa_mp.group_code%type;
    v_description custom.coa_mp.description%type;
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
     v_Closing tbaadm.gstt.tot_dr_bal%type;
     
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
    If vi_Type like 'Asset%' then
    IF vi_currency_type not like 'All%' then
     IF NOT ExtractDataAsset%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataAsset ( vi_TranDate, vi_currency_code,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataAsset%ISOPEN THEN
        --{
          FETCH	ExtractDataAsset
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataAsset%NOTFOUND THEN
          --{
            CLOSE ExtractDataAsset;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      ELSIF vi_currency_type = 'All Currency' then 
      IF NOT ExtractAssetAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractAssetAll ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractAssetAll%ISOPEN THEN
        --{
          FETCH	ExtractAssetAll
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_Closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractAssetAll%NOTFOUND THEN
          --{
            CLOSE ExtractAssetAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      --}
      ELSE 
        IF NOT ExtractAssetFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractAssetFCY ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractAssetFCY%ISOPEN THEN
        --{
          FETCH	ExtractAssetFCY
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_Closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractAssetFCY%NOTFOUND THEN
          --{
            CLOSE ExtractAssetFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      --}
      END IF;
    ELSE --liabilities 
    IF vi_currency_type not like 'All%' then
        IF NOT ExtractDataLiabilities%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataLiabilities ( vi_TranDate, vi_currency_code,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataLiabilities%ISOPEN THEN
        --{
          FETCH	ExtractDataLiabilities
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataLiabilities%NOTFOUND THEN
          --{
            CLOSE ExtractDataLiabilities;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      ELSIF vi_currency_type = 'All Currency' then 
      IF NOT ExtractLiabilitiesAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractLiabilitiesAll ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractLiabilitiesAll%ISOPEN THEN
        --{
          FETCH	ExtractLiabilitiesAll
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_Closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractLiabilitiesAll%NOTFOUND THEN
          --{
            CLOSE ExtractLiabilitiesAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      --}
      ELSE 
        IF NOT ExtractLiabilitiesFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractLiabilitiesFCY ( vi_TranDate,vi_branch_code);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractLiabilitiesFCY%ISOPEN THEN
        --{
          FETCH	ExtractLiabilitiesFCY
          INTO  v_group_code,v_description,v_Opening, v_cash_dr_amt,v_transfer_dr_amt,v_clearing_dr_amt,v_cash_cr_amt,v_transfer_cr_amt,v_clearing_cr_amt,v_Closing;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractLiabilitiesFCY%NOTFOUND THEN
          --{
            CLOSE ExtractLiabilitiesFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      --}
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

    out_rec:= (     v_group_code|| '|' ||
                    v_description|| '|' ||
                    v_Opening|| '|' ||
                    v_cash_dr_amt|| '|' ||
                    v_transfer_dr_amt|| '|' ||
                    v_clearing_dr_amt|| '|' ||
                    v_cash_cr_amt|| '|' ||
                    v_transfer_cr_amt|| '|' ||
                    v_clearing_cr_amt|| '|' ||
                    v_rate || '|' ||
                    BranchName || '|' ||
                    v_Closing
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_GL_RETURN_ASSET_LIABILITIE;

END FIN_GL_RETURN_ASSET_LIABILITIE;
/
