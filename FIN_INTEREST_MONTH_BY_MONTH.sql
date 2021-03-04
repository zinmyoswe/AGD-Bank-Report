CREATE OR REPLACE PACKAGE FIN_INTEREST_MONTH_BY_MONTH AS 

  PROCEDURE FIN_INTEREST_MONTH_BY_MONTH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INTEREST_MONTH_BY_MONTH;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_INTEREST_MONTH_BY_MONTH AS

-----------------------------------------------------------------------
--Update User - Yin Win Phyu
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranYear	   	Varchar2(20);              -- Input to procedure
  vi_Type       Varchar2(50);		    	     -- Input to procedure
	vi_currency_code		Varchar2(3);		    	     -- Input to procedure
  vi_currency_type Varchar2(50);		    	     -- Input to procedure
  vi_branch_code Varchar2(5);	                   -- Input to procedure
  vi_group_code1 Varchar2(3);            -- Input to procedure
  vi_gl_sub_head_code1 Varchar2(5);            -- Input to procedure
  vi_group_code2 Varchar2(3);            -- Input to procedure
  vi_gl_sub_head_code2 Varchar2(5);            -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractDataReceived(ci_TranYear Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        gam.schm_code
from tbaadm.gam gam
where  gam.acct_crncy_code =upper(ci_currency_code)
--and gam.schm_code ='AGDNL'
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, 
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where cdav.tran_crncy_code=upper(ci_currency_code)
and (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataReceivedAll(ci_TranYear Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,
       sum(HEAD.April_amt) as April_amt,
       sum(HEAD.May_amt) as May_amt,
       sum(HEAD.June_amt) as June_amt,
       sum(HEAD.July_amt) as July_amt,
       sum(HEAD.August_amt) as August_amt,
       sum(HEAD.Setempter_amt) as Setempter_amt,
       sum(HEAD.October_amt) as October_amt,
       sum(HEAD.November_amt) as November_amt,
       sum(HEAD.December_amt) as December_amt,
       sum(HEAD.January_amt) as January_amt,
       sum(HEAD.February_amt) as February_amt,
       sum(HEAD.March_amt) as March_amt,
       HEAD.schm_code
from
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
       CASE WHEN Q.cur = 'MMK'  THEN Q.April_amt
            ELSE Q.April_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS April_amt,
        CASE WHEN Q.cur = 'MMK'  THEN Q.May_amt
            ELSE Q.May_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS May_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.June_amt
            ELSE Q.June_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS June_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.July_amt
            ELSE Q.July_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS July_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.August_amt
            ELSE Q.August_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS August_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.Setempter_amt
            ELSE Q.Setempter_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS Setempter_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.October_amt
            ELSE Q.October_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS October_amt, 
              CASE WHEN Q.cur = 'MMK'  THEN Q.November_amt
            ELSE Q.November_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS November_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.December_amt
            ELSE Q.December_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS December_amt,
           CASE WHEN Q.cur = 'MMK'  THEN Q.January_amt
            ELSE Q.January_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS January_amt, 
            CASE WHEN Q.cur = 'MMK'  THEN Q.February_amt
            ELSE Q.February_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS February_amt,
                              
              CASE WHEN Q.cur = 'MMK'  THEN Q.March_amt
            ELSE Q.March_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS March_amt,
          Q.schm_code
from 
(select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.cur,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code,
        q.cur
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        gam.schm_code,
        gam.acct_crncy_code as cur
from tbaadm.gam gam
where (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, q.cur,
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,cdav.tran_crncy_code as cur,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id,q.cur)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
and Customer_data.cur = Amount.cur
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.cur,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date)Q)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataReceivedFCY(ci_TranYear Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,
       sum(HEAD.April_amt) as April_amt,
       sum(HEAD.May_amt) as May_amt,
       sum(HEAD.June_amt) as June_amt,
       sum(HEAD.July_amt) as July_amt,
       sum(HEAD.August_amt) as August_amt,
       sum(HEAD.Setempter_amt) as Setempter_amt,
       sum(HEAD.October_amt) as October_amt,
       sum(HEAD.November_amt) as November_amt,
       sum(HEAD.December_amt) as December_amt,
       sum(HEAD.January_amt) as January_amt,
       sum(HEAD.February_amt) as February_amt,
       sum(HEAD.March_amt) as March_amt,
       HEAD.schm_code
from
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
       CASE WHEN Q.cur = 'MMK'  THEN Q.April_amt
            ELSE Q.April_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS April_amt,
        CASE WHEN Q.cur = 'MMK'  THEN Q.May_amt
            ELSE Q.May_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS May_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.June_amt
            ELSE Q.June_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS June_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.July_amt
            ELSE Q.July_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS July_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.August_amt
            ELSE Q.August_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS August_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.Setempter_amt
            ELSE Q.Setempter_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS Setempter_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.October_amt
            ELSE Q.October_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS October_amt, 
              CASE WHEN Q.cur = 'MMK'  THEN Q.November_amt
            ELSE Q.November_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS November_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.December_amt
            ELSE Q.December_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS December_amt,
           CASE WHEN Q.cur = 'MMK'  THEN Q.January_amt
            ELSE Q.January_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS January_amt, 
            CASE WHEN Q.cur = 'MMK'  THEN Q.February_amt
            ELSE Q.February_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS February_amt,
                              
              CASE WHEN Q.cur = 'MMK'  THEN Q.March_amt
            ELSE Q.March_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS March_amt,
          Q.schm_code
from 
(select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.cur,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code,
        q.cur
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        gam.schm_code,
        gam.acct_crncy_code as cur
from tbaadm.gam gam
where (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.acct_crncy_code != upper('MMK')
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, q.cur,
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,cdav.tran_crncy_code as cur,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_crncy_code !=upper('MMK')
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id,q.cur)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
and Customer_data.cur = Amount.cur
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.cur,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date)Q)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixed(ci_TranYear Varchar2, ci_currency_code Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        tam.deposit_period_mths as schm_code
from tbaadm.gam gam,tbaadm.tam tam
where  gam.acct_crncy_code =upper(ci_currency_code)
and tam.acid = gam.acid
--and gam.schm_code ='AGDNL'
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, 
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where cdav.tran_crncy_code=upper(ci_currency_code)
and (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixedAll(ci_TranYear Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,
       sum(HEAD.April_amt) as April_amt,
       sum(HEAD.May_amt) as May_amt,
       sum(HEAD.June_amt) as June_amt,
       sum(HEAD.July_amt) as July_amt,
       sum(HEAD.August_amt) as August_amt,
       sum(HEAD.Setempter_amt) as Setempter_amt,
       sum(HEAD.October_amt) as October_amt,
       sum(HEAD.November_amt) as November_amt,
       sum(HEAD.December_amt) as December_amt,
       sum(HEAD.January_amt) as January_amt,
       sum(HEAD.February_amt) as February_amt,
       sum(HEAD.March_amt) as March_amt,
       HEAD.schm_code
from
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
       CASE WHEN Q.cur = 'MMK'  THEN Q.April_amt
            ELSE Q.April_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS April_amt,
        CASE WHEN Q.cur = 'MMK'  THEN Q.May_amt
            ELSE Q.May_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS May_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.June_amt
            ELSE Q.June_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS June_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.July_amt
            ELSE Q.July_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS July_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.August_amt
            ELSE Q.August_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS August_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.Setempter_amt
            ELSE Q.Setempter_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS Setempter_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.October_amt
            ELSE Q.October_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS October_amt, 
              CASE WHEN Q.cur = 'MMK'  THEN Q.November_amt
            ELSE Q.November_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS November_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.December_amt
            ELSE Q.December_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS December_amt,
           CASE WHEN Q.cur = 'MMK'  THEN Q.January_amt
            ELSE Q.January_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS January_amt, 
            CASE WHEN Q.cur = 'MMK'  THEN Q.February_amt
            ELSE Q.February_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS February_amt,
                              
              CASE WHEN Q.cur = 'MMK'  THEN Q.March_amt
            ELSE Q.March_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS March_amt,
          Q.schm_code
from 
(select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.cur,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code,
        q.cur
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        tam.deposit_period_mths as schm_code,
        gam.acct_crncy_code as cur
from tbaadm.gam gam,tbaadm.tam tam
where tam.acid= gam.acid
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, q.cur,
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,cdav.tran_crncy_code as cur,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id,q.cur)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
and Customer_data.cur = Amount.cur
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.cur,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date)Q)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataFixedFCY(ci_TranYear Varchar2,ci_branch_code Varchar2,ci_gl_sub_head_code1 Varchar2,ci_gl_sub_head_code2 Varchar2) IS
select HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,
       sum(HEAD.April_amt) as April_amt,
       sum(HEAD.May_amt) as May_amt,
       sum(HEAD.June_amt) as June_amt,
       sum(HEAD.July_amt) as July_amt,
       sum(HEAD.August_amt) as August_amt,
       sum(HEAD.Setempter_amt) as Setempter_amt,
       sum(HEAD.October_amt) as October_amt,
       sum(HEAD.November_amt) as November_amt,
       sum(HEAD.December_amt) as December_amt,
       sum(HEAD.January_amt) as January_amt,
       sum(HEAD.February_amt) as February_amt,
       sum(HEAD.March_amt) as March_amt,
       HEAD.schm_code
from
(select Q.Account_Number,Q.foracid,Q.acct_opn_date,Q.acct_name,Q.Interest_Rate,
       CASE WHEN Q.cur = 'MMK'  THEN Q.April_amt
            ELSE Q.April_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS April_amt,
        CASE WHEN Q.cur = 'MMK'  THEN Q.May_amt
            ELSE Q.May_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS May_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.June_amt
            ELSE Q.June_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS June_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.July_amt
            ELSE Q.July_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS July_amt,
          CASE WHEN Q.cur = 'MMK'  THEN Q.August_amt
            ELSE Q.August_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS August_amt,
         CASE WHEN Q.cur = 'MMK'  THEN Q.Setempter_amt
            ELSE Q.Setempter_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS Setempter_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.October_amt
            ELSE Q.October_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS October_amt, 
              CASE WHEN Q.cur = 'MMK'  THEN Q.November_amt
            ELSE Q.November_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS November_amt,
            CASE WHEN Q.cur = 'MMK'  THEN Q.December_amt
            ELSE Q.December_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS December_amt,
           CASE WHEN Q.cur = 'MMK'  THEN Q.January_amt
            ELSE Q.January_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS January_amt, 
            CASE WHEN Q.cur = 'MMK'  THEN Q.February_amt
            ELSE Q.February_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS February_amt,
                              
              CASE WHEN Q.cur = 'MMK'  THEN Q.March_amt
            ELSE Q.March_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(Q.cur) 
                                and r.Rtlist_date = (select max(r.Rtlist_date)
                                                     from TBAADM.RTH r
                                                     where to_char(r.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = (select max(a.Rtlist_date)
                                                                                                 from TBAADM.RTH a
                                                                                                 where to_char(a.Rtlist_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code)
                              ),1) END AS March_amt,
          Q.schm_code
from 
(select Customer_data.Account_Number,
       Customer_data.foracid,
       Customer_data.acct_opn_date,
       Customer_data.acct_name,
       Customer_data.Interest_Rate,
       sum(Amount.April_amt) as April_amt,
       sum(Amount.May_amt) as May_amt,
       sum(Amount.June_amt) as June_amt,
       sum(Amount.July_amt) as July_amt,
       sum(Amount.August_amt) as August_amt,
       sum(Amount.Setempter_amt) as Setempter_amt,
       sum(Amount.October_amt) as October_amt,
       sum(Amount.November_amt) as November_amt,
       sum(Amount.December_amt) as December_amt,
       sum(Amount.January_amt) as January_amt,
       sum(Amount.February_amt) as February_amt,
       sum(Amount.March_amt) as March_amt,
       Customer_data.cur,
       Customer_data.schm_code
from 
(select q.acid,
       (select gam.foracid from tbaadm.gam gam
               where gam.acid = (select lam.op_acid 
                           from  tbaadm.lam lam 
                           where lam.acid = q.acid) ) as Account_Number,
        q.foracid,
        q.acct_opn_date,
        q.acct_name,
        q.sol_id,
        (select eit.interest_rate from tbaadm.eit eit where eit.entity_id =q.acid) as Interest_Rate,
        q.schm_code,
        q.cur
from
(select  gam.acid,
        gam.foracid,
        gam.acct_opn_date,
        gam.acct_name,
        gam.sol_id,
        tam.deposit_period_mths as schm_code,
        gam.acct_crncy_code as cur
from tbaadm.gam gam,tbaadm.tam tam
where tam.acid= gam.acid
and (gam.gl_sub_head_code = ci_gl_sub_head_code1 or gam.gl_sub_head_code = ci_gl_sub_head_code2)
and gam.acct_crncy_code != upper('MMK')
and gam.sol_id like   '%' || ci_branch_code || '%'
and gam.acct_ownership !='O'
order by gam.foracid, gam.acct_opn_date)q
order by q.foracid,q.acct_opn_date) Customer_data
left Join
(select q.acid,q.sol_id, q.cur,
        sum(q.April_amt) as April_amt,sum(q.May_amt) as May_amt,sum(q.June_amt) as June_amt,sum(q.July_amt) as July_amt,
        sum(q.August_amt) as August_amt,sum(q.Setempter_amt) as Setempter_amt,sum(q.October_amt) as October_amt,
        sum(q.November_amt) as November_amt,sum(q.December_amt) as December_amt,sum(q.January_amt) as January_amt,
        sum(q.February_amt) as February_amt,sum(q.March_amt) as March_amt
        
from
(select  cdav.acid,cdav.sol_id,cdav.tran_crncy_code as cur,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'0'),'MM-YYYY') then cdav.tran_amt else 0  end as April_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'1'),'MM-YYYY') then cdav.tran_amt else 0  end as May_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'2'),'MM-YYYY') then cdav.tran_amt else 0  end as June_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'3'),'MM-YYYY') then cdav.tran_amt else 0  end as July_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'4'),'MM-YYYY') then cdav.tran_amt else 0  end as August_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'5'),'MM-YYYY') then cdav.tran_amt else 0  end as Setempter_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'6'),'MM-YYYY') then cdav.tran_amt else 0  end as October_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'7'),'MM-YYYY') then cdav.tran_amt else 0  end as November_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'8'),'MM-YYYY') then cdav.tran_amt else 0  end as December_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'9'),'MM-YYYY') then cdav.tran_amt else 0  end as January_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'10'),'MM-YYYY') then cdav.tran_amt else 0  end as February_amt,
        case when to_char(cdav.tran_date,'MM-YYYY') =to_char(ADD_MONTHS(TO_date('04-'||ci_TranYear, 'MM-YYYY'),'11'),'MM-YYYY') then cdav.tran_amt else 0  end as March_amt
from CUSTOM.custom_ctd_dtd_acli_view cdav
where (cdav.gl_sub_head_code = ci_gl_sub_head_code1 or cdav.gl_sub_head_code = ci_gl_sub_head_code2)
and cdav.tran_crncy_code !=upper('MMK')
and cdav.tran_rmks ='Interest run'
and cdav.sol_id like   '%' || ci_branch_code || '%')q
group by q.acid,q.sol_id,q.cur)Amount
on Customer_data.acid = Amount.acid
and Customer_data.sol_id= Amount.sol_id
and Customer_data.cur = Amount.cur
group by Customer_data.Account_Number, Customer_data.foracid,Customer_data.acct_opn_date,Customer_data.acct_name,Customer_data.Interest_Rate,Customer_data.cur,Customer_data.schm_code
order by Customer_data.schm_code,Customer_data.foracid,Customer_data.acct_opn_date)Q)HEAD
group by HEAD.Account_Number,HEAD.foracid,HEAD.acct_opn_date,HEAD.acct_name,HEAD.Interest_Rate,HEAD.schm_code
order by HEAD.schm_code,HEAD.foracid,HEAD.acct_opn_date;
-----------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_INTEREST_MONTH_BY_MONTH(	inp_str      IN  VARCHAR2,
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
    v_April_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_May_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_June_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_July_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_August_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_Setemper_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_October_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_November_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_December_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_January_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_February_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
    v_March_amt custom.custom_ctd_dtd_acli_view.tran_amt%type;
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
   vi_TranYear := outArr(0);
     vi_Type := outArr(1);
     vi_currency_code :=outArr(2);
     vi_currency_type :=outArr(3);
     vi_branch_code := outArr(4);
     
     -----------------------------------------------------------------
     if(vi_TranYear  is null or vi_Type is null or vi_currency_type is null ) then
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
     vi_gl_sub_head_code1 :='70121';
     vi_gl_sub_head_code2 :='';
  
  elsif vi_Type ='Saving Deposit' then 
     vi_gl_sub_head_code1 :='70111';
     vi_gl_sub_head_code2 :='70314';
 
 elsif vi_Type ='Fixed Deposit' then 
     vi_gl_sub_head_code1 :='70131';
     vi_gl_sub_head_code2 :='70315';
 end if;
 ----------------------------------------------------------------------------------------------------------- 
 
 If (vi_Type = 'Demand Loan') or (vi_Type ='Trade Finance') or (vi_Type ='Overdraft') or (vi_Type ='Hire Purchase') or (vi_Type ='Staff Loan') or (vi_Type ='Credit Card') or (vi_Type ='Inter Bank Loans') or (vi_Type ='Saving Deposit')or (vi_Type ='Special Deposit') then 
    If vi_currency_type not like 'All Currency' then
     IF NOT ExtractDataReceived%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataReceived ( vi_TranYear, vi_currency_code,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataReceived%ISOPEN THEN
        --{
          FETCH	ExtractDataReceived
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataReceived%NOTFOUND THEN
          --{
            CLOSE ExtractDataReceived;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    elsif vi_currency_type = 'All Currency' then
      IF NOT ExtractDataReceivedAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataReceivedAll ( vi_TranYear,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataReceivedAll%ISOPEN THEN
        --{
          FETCH	ExtractDataReceivedAll
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataReceivedAll%NOTFOUND THEN
          --{
            CLOSE ExtractDataReceivedAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
      else 
       IF NOT ExtractDataReceivedFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataReceivedFCY ( vi_TranYear,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataReceivedFCY%ISOPEN THEN
        --{
          FETCH	ExtractDataReceivedFCY
          INTO v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataReceivedFCY%NOTFOUND THEN
          --{
            CLOSE ExtractDataReceivedFCY;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    end if;-- currency type
  elsif (vi_Type ='Fixed Deposit') then
     If vi_currency_type not like 'All Currency' then
     IF NOT ExtractDataFixed%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataFixed ( vi_TranYear, vi_currency_code,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataFixed%ISOPEN THEN
        --{
          FETCH	ExtractDataFixed
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataFixed%NOTFOUND THEN
          --{
            CLOSE ExtractDataFixed;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    elsif vi_currency_type = 'All Currency' then
     IF NOT ExtractDataFixedAll%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataFixedAll ( vi_TranYear,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataFixedAll%ISOPEN THEN
        --{
          FETCH	ExtractDataFixedAll
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataFixedAll%NOTFOUND THEN
          --{
            CLOSE ExtractDataFixedAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
    else
    IF NOT ExtractDataFixedFCY%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataFixedFCY ( vi_TranYear,vi_branch_code,vi_gl_sub_head_code1,vi_gl_sub_head_code2);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataFixedFCY%ISOPEN THEN
        --{
          FETCH	ExtractDataFixedFCY
          INTO  v_current_Acc,v_foracid,v_opn_date, v_acct_name,v_interest_rate,
          v_April_amt,v_May_amt,v_June_amt,v_July_amt,v_August_amt,v_Setemper_amt,
          v_October_amt,v_November_amt,v_December_amt,v_January_amt,v_February_amt,v_March_amt,
          v_schm_code;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataFixedFCY%NOTFOUND THEN
          --{
            CLOSE ExtractDataFixedFCY;
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
                  and rtlist_date = TO_DATE( CAST ( vi_TranYear AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
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

    out_rec:= (    v_current_Acc|| '|' ||
                   v_foracid|| '|' ||
                   trim(to_char(to_date(v_opn_date,'dd/Mon/yy'), 'dd-MM-yyyy')) || '|' ||
                   v_acct_name|| '|' ||
                   v_interest_rate|| '|' ||
                   v_April_amt|| '|' ||
                   v_May_amt|| '|' ||
                   v_June_amt|| '|' ||
                   v_July_amt|| '|' ||
                   v_August_amt|| '|' ||
                   v_Setemper_amt|| '|' ||
                   v_October_amt|| '|' ||
                   v_November_amt|| '|' ||
                   v_December_amt|| '|' ||
                   v_January_amt|| '|' ||
                   v_February_amt|| '|' ||
                   v_March_amt|| '|' ||
                   v_schm_code|| '|' ||
                   v_rate || '|' ||
                  BranchName
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_INTEREST_MONTH_BY_MONTH;

END FIN_INTEREST_MONTH_BY_MONTH;
/
