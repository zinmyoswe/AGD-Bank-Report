CREATE OR REPLACE PACKAGE FIN_TYPE_BY_ADVANCES_POSITION AS 

  PROCEDURE FIN_TYPE_BY_ADVANCES_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_TYPE_BY_ADVANCES_POSITION;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                               FIN_TYPE_BY_ADVANCES_POSITION AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_currency		Varchar2(30);		    	     -- Input to procedure
  vi_branch_code Varchar2(5);             -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractData(ci_TranDate Varchar2,ci_currency Varchar2, ci_BranchCode Varchar2)
IS
select sol.br_open_date,sol.sol_id,sol.sol_desc,
      Demand_Loan.Loan_Limit_amt  as Demand_Loan_Limit,
       HP.HP_Limit_amt as HP_Limit,
      Staff_Loan.Staff_Limit_amt as Staff_Loan_Limit,
      Overdraft.Overdraft_Limit_amt as Overdraft_Limit,
      Demand_Loan_TOD.Demand_Loan_TOD_Limit_amt as Demand_Loan_TOD_Limit,
      HP_TOD.HP_TOD_Limit_amt as HP_TO_Limit,
      Staff_loan_TOD.Staff_loan_TOD_Limit_amt as Staff_Loan_TOD_Limit,
      Overdraft_TOD.Overdraft_TOD_Limit_amt as Overdraft_TOD_Limit,
      Demand_Loan.no as Demand_Loan_no,
     Demand_Loan.amount   as Demand_Amount,
      HP.no as HP_no,
      HP.amount as HP_Amount,
      Staff_Loan.no as Staff_no,
      Staff_Loan.amount as Staff_Amount,
      Overdraft.no as Overdraft_no,
     Overdraft.amount AS Overdraft_Amount,
      Demand_Loan_TOD.no as Demand_Loan_TOD_no,
      Demand_Loan_TOD.amount as Demand_Loan_TOD_Amount,
      HP_TOD.no as HP_TOD_no,
      HP_TOD.amount as HP_TOD_Amount,
      Staff_loan_TOD.no as Staff_loan_TOD_no,
      Staff_loan_TOD.amount as Staff_loan_TOD_Amount,
      Overdraft_TOD.no as Overdraft_TOD_no,
      Overdraft_TOD.amount as Overdraft_TOD_Amount,
      Demand_Loan.unused_limit as Demand_Loan_unused_Limit,
      HP.unused_limit as HP_unused_limit,
      Staff_Loan.unused_limit as Staff_Loan_unused_limit,
      Overdraft.unused_limit as Overdraft_unused_limit,
      Demand_Loan_TOD.unused_limit as Demand_Loan_TOD_unused_limit,
      HP_TOD.unused_limit as HP_TOD_unused_limit,
      Staff_loan_TOD.unused_limit as Staff_loan_TOD_unused_limit,
      Overdraft_TOD.unused_limit as Overdraft_TOD_unused_limit
      from
  
  (select sol.br_open_date,sol.sol_id, sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      and sol.sol_id = ci_BranchCode 
      order by sol.br_open_date,sol.sol_id
      ) sol
Left join
(select sum(q.no) as no,
        sum(q.Loan_Limit_amt) as Loan_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as Loan_Limit_amt ,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and eab.acid = gam.acid
and eab.eab_crncy_code =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
--and ldt.ldt_crncy_code  = UPPER('MMk')
and eab.EOD_DATE <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code in ('A21','A26') 
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id
--order by sol.br_open_date,gam.sol_id
union all
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Loan_Limit_amt ,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
--and ldt.ldt_crncy_code  = UPPER('MMk')
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code in ('A21','A26') 
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code in ('A21','A26') 
                                     and gam.sol_id = ci_BranchCode 
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id) Demand_Loan
on sol.sol_id = Demand_Loan.sol_id
left join
( select sum(q.no) as no,
          sum(q.HP_Limit_amt) as HP_Limit_amt,
          sum(q.amount) as amount,
          sum(q.unused_limit) as unused_limit,
          q.sol_id,
          q.br_open_date
from
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as HP_Limit_amt,
      sum(eab.tran_date_bal) as amount, 
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid 
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode
and eab.EOD_DATE <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and sol.bank_code = '116'
and coa.group_code ='A24'
and gam.schm_type ='LAA'
--and eab.tran_date_bal <0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id 
union all
select count(gam.acid) as no,
      sum(gam.sanct_lim) as HP_Limit_amt,
      sum(gam.clr_bal_amt) as amount, 
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and sol.bank_code = '116'
and coa.group_code ='A24'
and gam.schm_type ='LAA'
--and gam.clr_bal_amt <0 
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code ='A24'
                                     and gam.sol_id = ci_BranchCode
                                     --and eab.tran_date_bal <0
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q 
group by q.br_open_date,q.sol_id) HP
on sol.sol_id = HP.sol_id
left join
(select sum(q.no) as no,
        sum(q.Staff_Limit_amt) as Staff_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from 
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as Staff_Limit_amt,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid 
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
--and gam.clr_bal_amt < 0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id 
union all 
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Staff_Limit_amt,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
--and gam.clr_bal_amt < 0
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code ='A25'
                                     and gam.sol_id = ci_BranchCode 
                                     --and gam.clr_bal_amt < 0
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id )q
group by q.br_open_date,q.sol_id) Staff_Loan
on sol.sol_id = Staff_Loan.sol_id
left join
(select sum(q.no) as no,
        sum(q.Overdraft_Limit_amt) as Overdraft_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from
(select count(acid) as no,
      sum(sanct_lim) as Overdraft_Limit_amt,
      sum(amount) as amount,
      sum(unused_limit) as unused_limit,
      sol_id,
      br_open_date from(
      select
      gam.acid,
      gam.sanct_lim ,
      case when ((eab.TRAN_DATE_BAL * -1 ) > gam.SANCT_LIM ) and gam.acct_cls_date is null then gam.SANCT_LIM
      WHEN gam.acct_cls_date is not null then eab.TRAN_DATE_BAL* -1
      else eab.TRAN_DATE_BAL* -1 end as amount,
      (gam.sanct_lim)- (gam.drwng_power) as unused_limit,
      gam.sol_id as sol_id,
      sol.br_open_date as br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='CAA'
and sol.bank_code = '116'
and coa.group_code ='A23'
--and gam.sanct_lim <>0
--and (eab.TRAN_DATE_BAL * -1 ) <= gam.SANCT_LIM
/*and ((gam.sanct_lim =0 
and TO_DATE( CAST ( '20-7-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
--and gam.clr_bal_amt <0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y')
group by br_open_date,sol_id 
union all 
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Overdraft_Limit_amt,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='CAA'
and sol.bank_code = '116'
and coa.group_code ='A23'
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
--and gam.sanct_lim <>0
--and (gam.clr_bal_amt * -1 ) <= gam.SANCT_LIM
/*and ((gam.sanct_lim =0 
and TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
--and gam.clr_bal_amt <0
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='CAA'
                                     and coa.group_code ='A23'
                                     and gam.sol_id = ci_BranchCode 
                                     --and gam.sanct_lim <>0
                                     /*and ((gam.sanct_lim =0 
                                            and TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
                                                (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q
--where q.amount >0
group by q.br_open_date,q.sol_id) Overdraft
on sol.sol_id = Overdraft.sol_id
left join
(select count(q.no) as no,
      sum(q.Demand_Loan_TOD_Limit_amt) as Demand_Loan_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as Demand_Loan_TOD_Limit_amt,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date 
from tbaadm.eab eab, tbaadm.gam gam,tbaadm.sol sol
where eab.acid in (select lam.op_acid 
                  from tbaadm.eab eab, tbaadm.gam gam, tbaadm.lam lam, custom.coa_mp coa
                  where gam.acid = eab.acid
                  and coa.gl_sub_head_code = gam.gl_sub_head_code
                  and gam.acid =lam.acid
                  and gam.acct_crncy_code =upper(ci_currency)
                  and gam.acct_crncy_code= coa.cur
                  and eab.eab_crncy_code = lam.lam_crncy_code
                  and gam.acct_crncy_code= eab.eab_crncy_code
                  and gam.schm_type ='LAA'
                  and coa.group_code in ('A21','A26')
                  and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
and eab.acid = gam.acid
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.tran_date_bal <0
and eab.eab_crncy_code =upper(ci_currency)
and eab.eab_crncy_code = gam.acct_crncy_code
group by gam.acid,gam.sol_id,sol.br_open_date
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id 
) Demand_Loan_TOD
on sol.sol_id = Demand_Loan_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.HP_TOD_Limit_amt) as HP_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as HP_TOD_Limit_amt,
      (sum(ldt.dmd_amt) - sum(ldt.tot_adj_amt)) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam, tbaadm.ldt ldt,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where gam.acid = ldt.acid
and eab.acid = gam.acid
and coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and ldt.ldt_crncy_code  = UPPER(ci_currency)
and eab.eab_crncy_code =upper(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A24'
--and gam.sol_id ='30100'
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
and gam.clr_bal_amt <0
and (ldt.dmd_amt - ldt.tot_adj_amt) > 0 
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id,gam.acid 
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id ) HP_TOD
on sol.sol_id = HP_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.Staff_loan_TOD_Limit_amt) as Staff_loan_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as Staff_loan_TOD_Limit_amt,
      (sum(ldt.dmd_amt) - sum(ldt.tot_adj_amt)) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam, tbaadm.ldt ldt,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where gam.acid = ldt.acid
and eab.acid = gam.acid
and coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and ldt.ldt_crncy_code  = UPPER(ci_currency)
and eab.eab_crncy_code =upper(ci_currency)
and gam.sol_id = sol.sol_id
and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_Date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
and (ldt.dmd_amt - ldt.tot_adj_amt) >0 
and gam.clr_bal_amt <0
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id,gam.acid 
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id
)Staff_loan_TOD
on sol.sol_id = Staff_loan_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.Overdraft_TOD_Limit_amt) as Overdraft_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from
(select gam.acid as no,
      sum(gam.sanct_lim) as Overdraft_TOD_Limit_amt,
      --sum(tdat.discret_advn_amt) as amount,
      sum(NVL((eab.TRAN_DATE_BAL * -1),0) - gam.SANCT_LIM ) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from  tbaadm.gam gam,tbaadm.eab eab
--,tbaadm.tdat tdat
,custom.coa_mp coa,tbaadm.sol sol
where eab.acid = gam.acid
--and tdat.acid = gam.acid
--and gam.sol_id = tdat.sol_id
and sol.sol_id = gam.sol_id
and gam.sol_id = ci_BranchCode
and coa.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
--and gam.acct_crncy_code = tdat.acct_crncy_code
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.acct_crncy_code =UPPER(ci_currency)
and gam.schm_type ='CAA'
and gam.clr_bal_amt <> 0
and (eab.TRAN_DATE_BAL * -1 ) > gam.SANCT_LIM
--and gam.sanct_lim <> 0
--and gam.sol_id ='31000'
--and gam.schm_code='AGDOD'
--and gam.foracid ='3011120000499'
--and tdat.discret_advn_reglr_ind !='R'
and coa.group_code ='A23'
and eab.eod_date <=TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
group by gam.acid,gam.sol_id,sol.br_open_date
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id) Overdraft_TOD
on sol.sol_id = Overdraft_TOD.sol_id
order by sol.br_open_date,sol.sol_id;
-------------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataAll(ci_TranDate Varchar2,ci_currency Varchar2)
IS
select sol.br_open_date,sol.sol_id,sol.sol_desc,
      Demand_Loan.Loan_Limit_amt  as Demand_Loan_Limit,
       HP.HP_Limit_amt as HP_Limit,
      Staff_Loan.Staff_Limit_amt as Staff_Loan_Limit,
      Overdraft.Overdraft_Limit_amt as Overdraft_Limit,
      Demand_Loan_TOD.Demand_Loan_TOD_Limit_amt as Demand_Loan_TOD_Limit,
      HP_TOD.HP_TOD_Limit_amt as HP_TO_Limit,
      Staff_loan_TOD.Staff_loan_TOD_Limit_amt as Staff_Loan_TOD_Limit,
      Overdraft_TOD.Overdraft_TOD_Limit_amt as Overdraft_TOD_Limit,
      Demand_Loan.no as Demand_Loan_no,
     Demand_Loan.amount   as Demand_Amount,
      HP.no as HP_no,
      HP.amount as HP_Amount,
      Staff_Loan.no as Staff_no,
      Staff_Loan.amount as Staff_Amount,
      Overdraft.no as Overdraft_no,
     Overdraft.amount AS Overdraft_Amount,
      Demand_Loan_TOD.no as Demand_Loan_TOD_no,
      Demand_Loan_TOD.amount as Demand_Loan_TOD_Amount,
      HP_TOD.no as HP_TOD_no,
      HP_TOD.amount as HP_TOD_Amount,
      Staff_loan_TOD.no as Staff_loan_TOD_no,
      Staff_loan_TOD.amount as Staff_loan_TOD_Amount,
      Overdraft_TOD.no as Overdraft_TOD_no,
      Overdraft_TOD.amount as Overdraft_TOD_Amount,
      Demand_Loan.unused_limit as Demand_Loan_unused_Limit,
      HP.unused_limit as HP_unused_limit,
      Staff_Loan.unused_limit as Staff_Loan_unused_limit,
      Overdraft.unused_limit as Overdraft_unused_limit,
      Demand_Loan_TOD.unused_limit as Demand_Loan_TOD_unused_limit,
      HP_TOD.unused_limit as HP_TOD_unused_limit,
      Staff_loan_TOD.unused_limit as Staff_loan_TOD_unused_limit,
      Overdraft_TOD.unused_limit as Overdraft_TOD_unused_limit
      from
  
  (select sol.br_open_date,sol.sol_id, sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      --and sol.sol_id = ci_BranchCode 
      order by sol.br_open_date,sol.sol_id
      ) sol
Left join
(select sum(q.no) as no,
        sum(q.Loan_Limit_amt) as Loan_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as Loan_Limit_amt ,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and eab.acid = gam.acid
and eab.eab_crncy_code =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
--and ldt.ldt_crncy_code  = UPPER('MMk')
and eab.EOD_DATE <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code in ('A21','A26') 
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id
--order by sol.br_open_date,gam.sol_id
union all
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Loan_Limit_amt ,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
--and ldt.ldt_crncy_code  = UPPER('MMk')
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code in ('A21','A26') 
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code in ('A21','A26') 
                                     --and gam.sol_id = ci_BranchCode 
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id) Demand_Loan
on sol.sol_id = Demand_Loan.sol_id
left join
( select sum(q.no) as no,
          sum(q.HP_Limit_amt) as HP_Limit_amt,
          sum(q.amount) as amount,
          sum(q.unused_limit) as unused_limit,
          q.sol_id,
          q.br_open_date
from
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as HP_Limit_amt,
      sum(eab.tran_date_bal) as amount, 
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid 
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode
and eab.EOD_DATE <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and sol.bank_code = '116'
and coa.group_code ='A24'
and gam.schm_type ='LAA'
--and eab.tran_date_bal <0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id 
union all
select count(gam.acid) as no,
      sum(gam.sanct_lim) as HP_Limit_amt,
      sum(gam.clr_bal_amt) as amount, 
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and sol.bank_code = '116'
and coa.group_code ='A24'
and gam.schm_type ='LAA'
--and gam.clr_bal_amt <0 
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code ='A24'
                                     --and gam.sol_id = ci_BranchCode
                                     --and eab.tran_date_bal <0
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q 
group by q.br_open_date,q.sol_id) HP
on sol.sol_id = HP.sol_id
left join
(select sum(q.no) as no,
        sum(q.Staff_Limit_amt) as Staff_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from 
(select count(gam.acid) as no,
      sum(gam.sanct_lim) as Staff_Limit_amt,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid 
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
--and gam.clr_bal_amt < 0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id 
union all 
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Staff_Limit_amt,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
--and gam.clr_bal_amt < 0
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='LAA'
                                     and coa.group_code ='A25'
                                     --and gam.sol_id = ci_BranchCode 
                                     --and gam.clr_bal_amt < 0
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id )q
group by q.br_open_date,q.sol_id) Staff_Loan
on sol.sol_id = Staff_Loan.sol_id
left join
(select sum(q.no) as no,
        sum(q.Overdraft_Limit_amt) as Overdraft_Limit_amt,
        sum(q.amount) as amount,
        sum(q.unused_limit) as unused_limit,
        q.sol_id,
        q.br_open_date
from
(select count(acid) as no,
      sum(sanct_lim) as Overdraft_Limit_amt,
      sum(amount) as amount,
      sum(unused_limit) as unused_limit,
      sol_id,
      br_open_date from(
      select
      gam.acid,
      gam.sanct_lim ,
      case when ((eab.TRAN_DATE_BAL * -1 ) > gam.SANCT_LIM ) and gam.acct_cls_date is null then gam.SANCT_LIM
      WHEN gam.acct_cls_date is not null then eab.TRAN_DATE_BAL* -1
      else eab.TRAN_DATE_BAL* -1 end as amount,
      (gam.sanct_lim)- (gam.drwng_power) as unused_limit,
      gam.sol_id as sol_id,
      sol.br_open_date as br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa, tbaadm.eab eab
where coa.gl_sub_head_code = gam.gl_sub_head_code
and eab.acid = gam.acid
and eab.eab_crncy_code =UPPER(ci_currency)
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='CAA'
and sol.bank_code = '116'
and coa.group_code ='A23'
--and gam.sanct_lim <>0
--and (eab.TRAN_DATE_BAL * -1 ) <= gam.SANCT_LIM
/*and ((gam.sanct_lim =0 
and TO_DATE( CAST ( '20-7-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
--and gam.clr_bal_amt <0
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
AND gam.ENTITY_CRE_FLG = 'Y')
group by br_open_date,sol_id 
union all 
select count(gam.acid) as no,
      sum(gam.sanct_lim) as Overdraft_Limit_amt,
      sum(gam.clr_bal_amt) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam,tbaadm.sol sol,custom.coa_mp coa
where coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and gam.acct_opn_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='CAA'
and sol.bank_code = '116'
and coa.group_code ='A23'
--AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
--and gam.sanct_lim <>0
--and (gam.clr_bal_amt * -1 ) <= gam.SANCT_LIM
/*and ((gam.sanct_lim =0 
and TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
--and gam.clr_bal_amt <0
AND gam.ENTITY_CRE_FLG = 'Y'
and gam.acid not in (SELECT EAB.ACID
                                      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,CUSTOM.COA_MP COA
                                      WHERE  EAB.ACID = GAM.ACID
                                      AND    COA.GL_SUB_HEAD_CODE = GAM.GL_SUB_HEAD_CODE
                                      AND    COA.CUR = gam.acct_crncy_code
                                      and    gam.acct_crncy_code = eab.eab_crncy_code
                                   and gam.schm_type ='CAA'
                                     and coa.group_code ='A23'
                                     --and gam.sol_id = ci_BranchCode 
                                     --and gam.sanct_lim <>0
                                     /*and ((gam.sanct_lim =0 
                                            and TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) > ((select LIM_EXP_DATE from tbaadm.lht where gam.acid = lht.acid and serial_num = 
                                                (select max(serial_num) from tbaadm.lht where acid = gam.acid)))) or gam.sanct_lim <>0 )*/
                                      AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)), 'dd-MM-yyyy')
                              
                                      AND    GAM.BANK_ID = '01'
                                      AND    GAM.ENTITY_CRE_FLG = 'Y')
group by sol.br_open_date,gam.sol_id)q
--where q.amount >0
group by q.br_open_date,q.sol_id) Overdraft
on sol.sol_id = Overdraft.sol_id
left join
(select count(q.no) as no,
      sum(q.Demand_Loan_TOD_Limit_amt) as Demand_Loan_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as Demand_Loan_TOD_Limit_amt,
      sum(eab.tran_date_bal) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date 
from tbaadm.eab eab, tbaadm.gam gam,tbaadm.sol sol
where eab.acid in (select lam.op_acid 
                  from tbaadm.eab eab, tbaadm.gam gam, tbaadm.lam lam, custom.coa_mp coa
                  where gam.acid = eab.acid
                  and coa.gl_sub_head_code = gam.gl_sub_head_code
                  and gam.acid =lam.acid
                  and gam.acct_crncy_code =upper(ci_currency)
                  and gam.acct_crncy_code= coa.cur
                  and eab.eab_crncy_code = lam.lam_crncy_code
                  and gam.acct_crncy_code= eab.eab_crncy_code
                  and gam.schm_type ='LAA'
                  and coa.group_code in ('A21','A26')
                  and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
and eab.acid = gam.acid
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.tran_date_bal <0
and eab.eab_crncy_code =upper(ci_currency)
and eab.eab_crncy_code = gam.acct_crncy_code
group by gam.acid,gam.sol_id,sol.br_open_date
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id 
) Demand_Loan_TOD
on sol.sol_id = Demand_Loan_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.HP_TOD_Limit_amt) as HP_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as HP_TOD_Limit_amt,
      (sum(ldt.dmd_amt) - sum(ldt.tot_adj_amt)) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam, tbaadm.ldt ldt,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where gam.acid = ldt.acid
and eab.acid = gam.acid
and coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and ldt.ldt_crncy_code  = UPPER(ci_currency)
and eab.eab_crncy_code =upper(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A24'
--and gam.sol_id ='30100'
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
and gam.clr_bal_amt <0
and (ldt.dmd_amt - ldt.tot_adj_amt) > 0 
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id,gam.acid 
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id ) HP_TOD
on sol.sol_id = HP_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.Staff_loan_TOD_Limit_amt) as Staff_loan_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from 
(select gam.acid as no,
      sum(gam.sanct_lim) as Staff_loan_TOD_Limit_amt,
      (sum(ldt.dmd_amt) - sum(ldt.tot_adj_amt)) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from tbaadm.gam gam, tbaadm.ldt ldt,tbaadm.sol sol,custom.coa_mp coa,tbaadm.eab eab
where gam.acid = ldt.acid
and eab.acid = gam.acid
and coa.gl_sub_head_code = gam.gl_sub_head_code
and coa.cur =UPPER(ci_currency)
and gam.acct_crncy_code = UPPER(ci_currency)
and ldt.ldt_crncy_code  = UPPER(ci_currency)
and eab.eab_crncy_code =upper(ci_currency)
and gam.sol_id = sol.sol_id
--and gam.sol_id = ci_BranchCode 
and eab.eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_Date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and gam.schm_type ='LAA'
and sol.bank_code = '116'
and coa.group_code ='A25'
AND gam.ACCT_CLS_FLG = 'N'
AND gam.BANK_ID = '01'
and (ldt.dmd_amt - ldt.tot_adj_amt) >0 
and gam.clr_bal_amt <0
AND gam.ENTITY_CRE_FLG = 'Y'
group by sol.br_open_date,gam.sol_id,gam.acid 
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id
)Staff_loan_TOD
on sol.sol_id = Staff_loan_TOD.sol_id
left join
(select count(q.no) as no,
      sum(q.Overdraft_TOD_Limit_amt) as Overdraft_TOD_Limit_amt,
      sum(q.amount) as amount,
      sum(unused_limit) as unused_limit,
      q.sol_id,
      q.br_open_date
from
(select gam.acid as no,
      sum(gam.sanct_lim) as Overdraft_TOD_Limit_amt,
      --sum(tdat.discret_advn_amt) as amount,
      sum(NVL((eab.TRAN_DATE_BAL * -1),0) - gam.SANCT_LIM ) as amount,
      (sum(gam.sanct_lim)- sum(gam.drwng_power)) as unused_limit,
      gam.sol_id,
      sol.br_open_date
from  tbaadm.gam gam,tbaadm.eab eab
--,tbaadm.tdat tdat
,custom.coa_mp coa,tbaadm.sol sol
where eab.acid = gam.acid
--and tdat.acid = gam.acid
--and gam.sol_id = tdat.sol_id
and sol.sol_id = gam.sol_id
--and gam.sol_id = ci_BranchCode
and coa.gl_sub_head_code = gam.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
--and gam.acct_crncy_code = tdat.acct_crncy_code
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.acct_crncy_code =UPPER(ci_currency)
and gam.schm_type ='CAA'
and gam.clr_bal_amt <> 0
and (eab.TRAN_DATE_BAL * -1 ) > gam.SANCT_LIM
--and gam.sanct_lim <> 0
--and gam.sol_id ='31000'
--and gam.schm_code='AGDOD'
--and gam.foracid ='3011120000499'
--and tdat.discret_advn_reglr_ind !='R'
and coa.group_code ='A23'
and eab.eod_date <=TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
group by gam.acid,gam.sol_id,sol.br_open_date
order by sol.br_open_date,gam.sol_id)q
group by q.br_open_date,q.sol_id
order by q.br_open_date,q.sol_id) Overdraft_TOD
on sol.sol_id = Overdraft_TOD.sol_id
order by sol.br_open_date,sol.sol_id;


-------------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_TYPE_BY_ADVANCES_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_sol_open_date tbaadm.sol.br_open_date%type;
    v_sol_id  tbaadm.sol.sol_id%type;
    v_sol_desc tbaadm.sol.sol_desc%type;
    v_Demand_Loan_limit_amount tbaadm.gam.sanct_lim%type;
    v_HP_limit_amount tbaadm.gam.sanct_lim%type;
    v_Staff_Loan_limit_amount tbaadm.gam.sanct_lim%type;
    v_Overdraft_limit_amount tbaadm.gam.sanct_lim%type; 
    v_Demand_Loan_TOD_limit_amount tbaadm.gam.sanct_lim%type;
    v_HP_TOD_limit_amount tbaadm.gam.sanct_lim%type;
    v_Staff_Loan_TOD_limit_amount tbaadm.gam.sanct_lim%type;
    v_Overdraft_TOD_limit_amount tbaadm.gam.sanct_lim%type;
    v_Demand_Loan_no tbaadm.gam.acid%type;
    v_Demand_Loan_amount tbaadm.gam.clr_bal_amt%type;
    v_HP_no tbaadm.gam.acid%type;
    v_HP_amount tbaadm.gam.clr_bal_amt%type;
    v_Staff_Loan_no tbaadm.gam.acid%type;
    v_Staff_Loan_amount tbaadm.gam.clr_bal_amt%type;
    v_Overdraft_no tbaadm.gam.acid%type;
    v_Overdraft_amount tbaadm.gam.clr_bal_amt%type;
    v_Demand_Loan_TOD_no tbaadm.gam.acid%type;
    v_Demand_Loan_TOD_amount tbaadm.ldt.dmd_amt%type;
    v_HP_TOD_no tbaadm.gam.acid%type;
    v_HP_TOD_amount tbaadm.ldt.dmd_amt%type;
    v_Staff_Loan_TOD_no tbaadm.gam.acid%type;
    v_Staff_Loan_TOD_amount tbaadm.ldt.dmd_amt%type;
    v_Overdraft_TOD_no tbaadm.gam.acid%type;
    v_Overdraft_TOD_amount tbaadm.ldt.dmd_amt%type;
    v_Demand_Loan_unused_limit tbaadm.gam.drwng_power%type;
    v_HP_Loan_unused_limit tbaadm.gam.drwng_power%type;
    v_Staff_Loan_unused_limit tbaadm.gam.drwng_power%type;
    v_Overdraft_Loan_unused_limit tbaadm.gam.drwng_power%type;
    Demand_Loan_TOD_unused_limit tbaadm.gam.drwng_power%type;
    HP_TOD_unused_limit tbaadm.gam.drwng_power%type;
    Staff_loan_TOD_unused_limit tbaadm.gam.drwng_power%type;
    Overdraft_TOD_unused_limit tbaadm.gam.drwng_power%type;
    
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
    vi_currency := outArr(1);
    vi_branch_code := outArr(2);
    -------------------------------------------------------------------------------------
    
    if( vi_TranDate is null or vi_currency is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= (  '-'  || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
                0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 
                || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0);
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    IF vi_branch_code IS  NULL or vi_branch_code = ''  THEN
  IF NOT ExtractDataAll%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataAll (vi_TranDate,vi_currency);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataAll%ISOPEN THEN
        --{
          FETCH	ExtractDataAll
          INTO  v_sol_open_date,v_sol_id  , v_sol_desc ,
              v_Demand_Loan_limit_amount  ,v_HP_limit_amount ,v_Staff_Loan_limit_amount ,v_Overdraft_limit_amount ,
              v_Demand_Loan_TOD_limit_amount ,v_HP_TOD_limit_amount ,v_Staff_Loan_TOD_limit_amount ,v_Overdraft_TOD_limit_amount ,
                v_Demand_Loan_no ,v_Demand_Loan_amount ,
                v_HP_no ,v_HP_amount ,
                v_Staff_Loan_no ,v_Staff_Loan_amount ,
                v_Overdraft_no ,v_Overdraft_amount ,
                v_Demand_Loan_TOD_no ,v_Demand_Loan_TOD_amount ,
                v_HP_TOD_no ,v_HP_TOD_amount ,
                v_Staff_Loan_TOD_no ,v_Staff_Loan_TOD_amount ,
                v_Overdraft_TOD_no ,v_Overdraft_TOD_amount,
                v_Demand_Loan_unused_limit,
                v_HP_Loan_unused_limit,
                v_Staff_Loan_unused_limit,
                v_Overdraft_Loan_unused_limit,
                Demand_Loan_TOD_unused_limit,
                HP_TOD_unused_limit,
                Staff_loan_TOD_unused_limit,
                Overdraft_TOD_unused_limit;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataAll%NOTFOUND THEN
          --{
            CLOSE ExtractDataAll;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;

    
 ELSE
     IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData (vi_TranDate,vi_currency,vi_branch_code );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  v_sol_open_date,v_sol_id  , v_sol_desc ,
              v_Demand_Loan_limit_amount  ,v_HP_limit_amount ,v_Staff_Loan_limit_amount ,v_Overdraft_limit_amount ,
              v_Demand_Loan_TOD_limit_amount ,v_HP_TOD_limit_amount ,v_Staff_Loan_TOD_limit_amount ,v_Overdraft_TOD_limit_amount ,
                v_Demand_Loan_no ,v_Demand_Loan_amount ,
                v_HP_no ,v_HP_amount ,
                v_Staff_Loan_no ,v_Staff_Loan_amount ,
                v_Overdraft_no ,v_Overdraft_amount ,
                v_Demand_Loan_TOD_no ,v_Demand_Loan_TOD_amount ,
                v_HP_TOD_no ,v_HP_TOD_amount ,
                v_Staff_Loan_TOD_no ,v_Staff_Loan_TOD_amount ,
                v_Overdraft_TOD_no ,v_Overdraft_TOD_amount,
                v_Demand_Loan_unused_limit,
                v_HP_Loan_unused_limit,
                v_Staff_Loan_unused_limit,
                v_Overdraft_Loan_unused_limit,
                Demand_Loan_TOD_unused_limit,
                HP_TOD_unused_limit,
                Staff_loan_TOD_unused_limit,
                Overdraft_TOD_unused_limit;
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
     END IF;   
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (    
                   v_sol_desc  || '|' ||
                    v_Demand_Loan_limit_amount  || '|' ||
                    v_HP_limit_amount || '|' ||
                    v_Staff_Loan_limit_amount || '|' ||
                    v_Overdraft_limit_amount || '|' ||
              v_Demand_Loan_TOD_limit_amount || '|' ||
              v_HP_TOD_limit_amount || '|' ||
              v_Staff_Loan_TOD_limit_amount || '|' ||
              v_Overdraft_TOD_limit_amount || '|' ||
                    v_Demand_Loan_no || '|' ||
                    v_Demand_Loan_amount || '|' ||
                     v_HP_no || '|' ||
                    v_HP_amount || '|' ||
                v_Staff_Loan_no || '|' ||
                v_Staff_Loan_amount || '|' ||
                v_Overdraft_no || '|' ||
                v_Overdraft_amount || '|' ||
                v_Demand_Loan_TOD_no || '|' ||
                v_Demand_Loan_TOD_amount || '|' ||
                v_HP_TOD_no || '|' ||
                v_HP_TOD_amount || '|' ||
                v_Staff_Loan_TOD_no || '|' ||
                v_Staff_Loan_TOD_amount || '|' ||
                v_Overdraft_TOD_no || '|' ||
                v_Overdraft_TOD_amount || '|' ||
                v_Demand_Loan_unused_limit || '|' ||
                v_HP_Loan_unused_limit || '|' ||
                v_Staff_Loan_unused_limit || '|' ||
                v_Overdraft_Loan_unused_limit
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_TYPE_BY_ADVANCES_POSITION;

END FIN_TYPE_BY_ADVANCES_POSITION;
/
