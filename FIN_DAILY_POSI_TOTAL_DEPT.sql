CREATE OR REPLACE PACKAGE               FIN_DAILY_POSI_TOTAL_DEPT AS 

  PROCEDURE FIN_DAILY_POSI_TOTAL_DEPT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DAILY_POSI_TOTAL_DEPT;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                 FIN_DAILY_POSI_TOTAL_DEPT AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_Tran_date		Varchar2(10);		    	  -- Input to procedure

    
CURSOR ExtractDataAllBranch(ci_Tran_date VARCHAR2) IS
select sol.sol_desc,
         two.sol_id,
       nvl(two.CurrentBFAccountBalance,0),
       nvl(two.RegularSavingBFAccountBalance,0),
       nvl(two.SavingSpecialBFAccountBalance,0),
       nvl(two.TermDepositBFAccountBalance,0),
       
       nvl(two.CurrentOpenAccount,0),
       nvl(two.RegularSavingOpenAccount,0), 
       nvl(two.SavingSpecialOpenAccount,0),
       nvl(two.TermDepositOpenAccount,0),
       
       nvl(two.CurrentCloseAccount,0),
       nvl(two.RegularSavingCloseAccount,0),
       nvl(two.SavingSpecialCloseAccount,0),
       nvl(two.TermDepositCloseAccount,0),
       
       nvl(two.CurrentTotalMMK,0),
       nvl(two.CurrentTotalFCY,0),
       nvl(two.RegularSavingTotalMMK,0),
       nvl(two.RegularSavingTotalFCY,0),
       nvl(two.SavingSpecialTotalMMK,0),
       nvl(two.SavingSpecialTotalFCY,0),
       nvl(two.TermDepositTotalMMK,0),
       nvl(two.TermDepositTotalFCY,0),
       
       nvl(two.CurrentOpeningBal,0),
       nvl(two.RegularSavingOpeningBal,0),
       nvl(two.SavingSpecialOpeningBal,0),
       nvl(two.TermDepositOpeningBal,0),
       
       nvl(two.CurrentClosingBal,0),
       nvl(two.RegularSavingClosingBal,0),
       nvl(two.SavingSpecialClosingBal,0),
       nvl(two.TermDepositClosingBal,0),
       
       nvl(two.CurrentDeposit,0),
       nvl(two.CurrentWithdraw,0),
       nvl(two.RegularSavingDeposit,0),
       nvl(two.RegularSavingWithdraw,0),
       nvl(two.SavingSpecialDeposit,0),
       nvl(two.SavingSpecialWithdraw,0),
       nvl(two.TermDepositDeposit,0),
       nvl(two.TermDepositWithdraw,0) 
       
from tbaadm.sol sol
left join (
 select a.sol_id,
      sum(a.CurrentBFAccountBalance) as CurrentBFAccountBalance,
       sum(a.RegularSavingBFAccountBalance) as RegularSavingBFAccountBalance,
       sum(a.SavingSpecialBFAccountBalance)as SavingSpecialBFAccountBalance,
       sum(a.TermDepositBFAccountBalance) as TermDepositBFAccountBalance,
       --open
       sum(a.CurrentOpenAccount) as CurrentOpenAccount,
          sum(a.RegularSavingOpenAccount) as RegularSavingOpenAccount,
          sum(a.SavingSpecialOpenAccount) as SavingSpecialOpenAccount,
          sum(a.TermDepositOpenAccount) as TermDepositOpenAccount,
       --close
        sum(a.CurrentCloseAccount) as CurrentCloseAccount,
          sum(a.RegularSavingCloseAccount) as RegularSavingCloseAccount,
          sum(a.SavingSpecialCloseAccount) as SavingSpecialCloseAccount,
          sum(a.TermDepositCloseAccount) as TermDepositCloseAccount,
          --fcy mmk total
           sum(a.CurrentTotalMMK) as CurrentTotalMMK,
          sum(a.CurrentTotalFCY) as CurrentTotalFCY,
          sum(a.RegularSavingTotalMMK) as RegularSavingTotalMMK,
          sum(a.RegularSavingTotalFCY) as RegularSavingTotalFCY,
          sum(a.SavingSpecialTotalMMK) as SavingSpecialTotalMMK,
          sum(a.SavingSpecialTotalFCY) as SavingSpecialTotalFCY,
          sum(a.TermDepositTotalMMK) as TermDepositTotalMMK,
          sum(a.TermDepositTotalFCY) as TermDepositTotalFCY,
       --open bal
        sum(a.CurrentOpeningBal) as CurrentOpeningBal,
        sum(a.RegularSavingOpeningBal) as RegularSavingOpeningBal,
        sum(a.SavingSpecialOpeningBal) as SavingSpecialOpeningBal,
        sum(a.TermDepositOpeningBal) as TermDepositOpeningBal,
       
         sum(a.CurrentClosingBal) as CurrentClosingBal,
        sum(a.RegularSavingClosingBal) as RegularSavingClosingBal,
        sum(a.SavingSpecialClosingBal) as SavingSpecialClosingBal,
        sum(a.TermDepositClosingBal) as TermDepositClosingBal,
        --
        --deposit withdrawal
        sum(a.CurrentDeposit) as CurrentDeposit,
        sum(a.CurrentWithdraw) as CurrentWithdraw,
        sum(a.RegularSavingDeposit) as RegularSavingDeposit,
        sum(a.RegularSavingWithdraw) as RegularSavingWithdraw,
       sum(a.SavingSpecialDeposit) as SavingSpecialDeposit,
        sum(a.SavingSpecialWithdraw) as SavingSpecialWithdraw,
        sum(a.TermDepositDeposit) as TermDepositDeposit,
        sum(a.TermDepositWithdraw) as TermDepositWithdraw 
from (
       -- BF A/C Total Counting logic
      select  q.sol_id,
              --bf 
             sum(q.CurrentBFAccountBalance) as CurrentBFAccountBalance,
             sum(q.RegularSavingBFAccountBalance) as RegularSavingBFAccountBalance,
             sum(q.SavingSpecialBFAccountBalance) as SavingSpecialBFAccountBalance,
             sum(q.TermDepositBFAccountBalance) as TermDepositBFAccountBalance,
             --open
             0 as CurrentOpenAccount,
             0 as RegularSavingOpenAccount,
             0 as SavingSpecialOpenAccount,
             0 as TermDepositOpenAccount,
             --close
             0 as CurrentCloseAccount,
             0 as RegularSavingCloseAccount,
             0 as SavingSpecialCloseAccount,
             0 as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
            0 as CurrentOpeningBal,
            0 as RegularSavingOpeningBal,
            0 as SavingSpecialOpeningBal,
            0 as TermDepositOpeningBal,
             0 as CurrentClosingBal,
            0 as RegularSavingClosingBal,
            0 as SavingSpecialClosingBal,
            0 as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
      from (
            Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%'  then 1 else 0 end as CurrentBFAccountBalance,
                   case when gam.schm_code = 'SAREG' then 1 else 0 end as RegularSavingBFAccountBalance,
                   case when gam.schm_code = 'SASPL' then 1 else 0 end as SavingSpecialBFAccountBalance,
                  case when gam.schm_Type  = 'TDA'   then 1 else 0 end as TermDepositBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
            AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
             --AND    GAM.ACCT_CLS_FLG = 'N'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
             
             union all
             
             Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%'  then 1 else 0 end as CurrentBFAccountBalance,
                   case when gam.schm_code = 'SAREG' then 1 else 0 end as RegularSavingBFAccountBalance,
                   case when gam.schm_code = 'SASPL' then 1 else 0 end as SavingSpecialBFAccountBalance,
                  case when gam.schm_Type  = 'TDA'   then 1 else 0 end as TermDepositBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
           -- AND    GAM.acct_opn_date =  TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
             --AND    GAM.ACCT_CLS_FLG = 'N'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
             
       
             
           union all
           
            Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%'  then -1 else 0 end as CurrentBFAccountBalance,
                   case when gam.schm_code = 'SAREG' then -1 else 0 end as RegularSavingBFAccountBalance,
                   case when gam.schm_code = 'SASPL' then -1 else 0 end as SavingSpecialBFAccountBalance,
                  case when gam.schm_Type  = 'TDA'   then -1 else 0 end as TermDepositBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
            --AND    GAM.acct_cls_date = TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
             AND    GAM.ACCT_CLS_FLG = 'Y'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
           /* union all
            
             Select gam.sol_id as sol_id,
                  case when gam.schm_code  like 'AG%C%'  then 1 else 0 end as CurrentBFAccountBalance,
                   case when gam.schm_code = 'SAREG' then 1 else 0 end as RegularSavingBFAccountBalance,
                   case when gam.schm_code = 'SASPL' then 1 else 0 end as SavingSpecialBFAccountBalance,
                  case when gam.schm_Type  = 'TDA'   then 1 else 0 end as TermDepositBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     schm_type in ('CAA','TDA','SBA')
           -- AND    GAM.acct_opn_date < TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
           AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4)
            AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
            AND    GAM.ACCT_CLS_FLG = 'N'
            and    gam.clr_bal_amt <> 0
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            and    gam.acid  not in ( select acid
                                      from tbaadm.eab e
                                      where     e.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                      AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                      )*/
            )q
          group by q.sol_id
          
   Union all
            
        -- Opening A/c Counting Logic
         select  q.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
             sum(q.CurrentOpenAccount) as CurrentOpenAccount,
             sum(q.RegularSavingOpenAccount) as RegularSavingOpenAccount,
             sum(q.SavingSpecialOpenAccount) as SavingSpecialOpenAccount,
             sum(q.TermDepositOpenAccount) as TermDepositOpenAccount,
             --close
             0 as CurrentCloseAccount,
             0 as RegularSavingCloseAccount,
             0 as SavingSpecialCloseAccount,
             0 as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
            0 as CurrentOpeningBal,
            0 as RegularSavingOpeningBal,
            0 as SavingSpecialOpeningBal,
            0 as TermDepositOpeningBal,
             0 as CurrentClosingBal,
            0 as RegularSavingClosingBal,
            0 as SavingSpecialClosingBal,
            0 as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
         from (
             Select gam.sol_id as sol_id,
                    case when gam.schm_code like 'AG%C%'   and acct_cls_flg = 'N'  then 1 else 0 end as CurrentOpenAccount,
                    case when gam.schm_code = 'SAREG' and acct_cls_flg = 'N'  then 1 else 0 end as RegularSavingOpenAccount,
                    case when gam.schm_code = 'SASPL' and acct_cls_flg = 'N'  then 1 else 0 end as SavingSpecialOpenAccount,
                    case when gam.schm_Type  = 'TDA'  and acct_cls_flg = 'N'  then 1 else 0 end as TermDepositOpenAccount
            from    tbaadm.gam 
            where   gam.del_flg = 'N'
            and     gam.bank_id = '01'
            and     gam.schm_type in ('CAA','TDA','SBA')
            and     gam.acct_opn_date = TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          group by q.sol_id
          
   Union all 
            --closing a/c Counting logic
            
           select        q.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
            0 as CurrentOpenAccount,
            0 as RegularSavingOpenAccount,
            0 as SavingSpecialOpenAccount,
            0 as TermDepositOpenAccount,
             --close
            sum(q.CurrentCloseAccount) as CurrentCloseAccount,
            sum(q.RegularSavingCloseAccount) as RegularSavingCloseAccount,
            sum(q.SavingSpecialCloseAccount) as SavingSpecialCloseAccount,
            sum(q.TermDepositCloseAccount) as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
            0 as CurrentOpeningBal,
            0 as RegularSavingOpeningBal,
            0 as SavingSpecialOpeningBal,
            0 as TermDepositOpeningBal,
           0 as CurrentClosingBal,
            0 as RegularSavingClosingBal,
            0 as SavingSpecialClosingBal,
            0 as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
         from (
             Select gam.sol_id as sol_id,
                    case when gam.schm_code like 'AG%C%'   and acct_cls_flg = 'Y'  then 1 else 0 end as CurrentCloseAccount,
                    case when gam.schm_code = 'SAREG' and acct_cls_flg = 'Y'  then 1 else 0 end as RegularSavingCloseAccount,
                    case when gam.schm_code = 'SASPL' and acct_cls_flg = 'Y'  then 1 else 0 end as SavingSpecialCloseAccount,
                    case when gam.schm_Type  = 'TDA'  and acct_cls_flg = 'Y'  then 1 else 0 end as TermDepositCloseAccount
            from    tbaadm.gam 
            where   gam.del_flg = 'N'
            and     gam.bank_id = '01'
            and     gam.schm_type in ('CAA','TDA','SBA')
            and     gam.acct_cls_date = TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          group by q.sol_id
          
  Union all 
  
        --Fcy and MMK total account logic
          select    q.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
            0 as CurrentOpenAccount,
            0 as RegularSavingOpenAccount,
            0 as SavingSpecialOpenAccount,
            0 as TermDepositOpenAccount,
             --close
            0 as CurrentCloseAccount,
            0 as RegularSavingCloseAccount,
            0 as SavingSpecialCloseAccount,
            0 as TermDepositCloseAccount,
                --fcy mmk total
             sum(q.CurrentTotalMMK) as CurrentTotalMMK,
              sum(q.CurrentTotalFCY) as CurrentTotalFCY,
              sum(q.RegularSavingTotalMMK) as RegularSavingTotalMMK,
              sum(q.RegularSavingTotalFCY) as RegularSavingTotalFCY,
              sum(q.SavingSpecialTotalMMK) as SavingSpecialTotalMMK,
              sum(q.SavingSpecialTotalFCY) as SavingSpecialTotalFCY,
              sum(q.TermDepositTotalMMK) as TermDepositTotalMMK,
              sum(q.TermDepositTotalFCY) as TermDepositTotalFCY,
             --open bal
            0 as CurrentOpeningBal,
            0 as RegularSavingOpeningBal,
            0 as SavingSpecialOpeningBal,
            0 as TermDepositOpeningBal,
             0 as CurrentClosingBal,
            0 as RegularSavingClosingBal,
            0 as SavingSpecialClosingBal,
            0 as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
          from (
            Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as CurrentTotalMMK,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code <>'MMK'   then 1 else 0 end as CurrentTotalFCY,
                   case when gam.schm_code = 'SAREG'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as RegularSavingTotalMMK,
                   case when gam.schm_code = 'SAREG' and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as RegularSavingTotalFCY,
                   case when gam.schm_code = 'SASPL'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as SavingSpecialTotalMMK,
                   case when gam.schm_code = 'SASPL' and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as SavingSpecialTotalFCY,
                  case when gam.schm_Type  = 'TDA'   and gam.acct_crncy_code = 'MMK' then 1 else 0 end as TermDepositTotalMMK,
                  case when gam.schm_Type  = 'TDA'  and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as TermDepositTotalFCY
                  
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
            AND    GAM.acct_opn_date < TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
            -- AND    GAM.ACCT_CLS_FLG = 'N'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
             union all
             
              Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as CurrentTotalMMK,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code <>'MMK'   then 1 else 0 end as CurrentTotalFCY,
                   case when gam.schm_code = 'SAREG'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as RegularSavingTotalMMK,
                   case when gam.schm_code = 'SAREG' and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as RegularSavingTotalFCY,
                   case when gam.schm_code = 'SASPL'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as SavingSpecialTotalMMK,
                   case when gam.schm_code = 'SASPL' and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as SavingSpecialTotalFCY,
                  case when gam.schm_Type  = 'TDA'   and gam.acct_crncy_code = 'MMK' then 1 else 0 end as TermDepositTotalMMK,
                  case when gam.schm_Type  = 'TDA'  and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as TermDepositTotalFCY
                  
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
            AND    GAM.acct_opn_date = TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
            -- AND    GAM.ACCT_CLS_FLG = 'N'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
             
             union all
             
              Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code = 'MMK'  then -1 else 0 end as CurrentTotalMMK,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code <>'MMK'   then -1 else 0 end as CurrentTotalFCY,
                   case when gam.schm_code = 'SAREG'  and gam.acct_crncy_code = 'MMK' then -1 else 0 end as RegularSavingTotalMMK,
                   case when gam.schm_code = 'SAREG' and gam.acct_crncy_code <>'MMK'  then -1 else 0 end as RegularSavingTotalFCY,
                   case when gam.schm_code = 'SASPL'  and gam.acct_crncy_code = 'MMK' then -1 else 0 end as SavingSpecialTotalMMK,
                   case when gam.schm_code = 'SASPL' and gam.acct_crncy_code <>'MMK'  then -1 else 0 end as SavingSpecialTotalFCY,
                  case when gam.schm_Type  = 'TDA'   and gam.acct_crncy_code = 'MMK' then -1 else 0 end as TermDepositTotalMMK,
                  case when gam.schm_Type  = 'TDA'  and gam.acct_crncy_code <>'MMK'  then -1 else 0 end as TermDepositTotalFCY
                  
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
             WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
             AND    COA.CUR = gam.acct_crncy_code
             and     eab.acid = gam.acid
             and     schm_type  in ('CAA','TDA','SBA')
            AND    GAM.acct_cls_date = TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
             AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
             AND    GAM.ACCT_CLS_FLG = 'Y'
             AND    GAM.BANK_ID = '01'
             AND    GAM.ENTITY_CRE_FLG = 'Y'
             /*union all
             
             Select gam.sol_id as sol_id,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as CurrentTotalMMK,
                   case when gam.schm_code  like 'AG%C%' and gam.acct_crncy_code <>'MMK'   then 1 else 0 end as CurrentTotalFCY,
                   case when gam.schm_code = 'SAREG'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as RegularSavingTotalMMK,
                   case when gam.schm_code = 'SAREG' and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as RegularSavingTotalFCY,
                   case when gam.schm_code = 'SASPL'  and gam.acct_crncy_code = 'MMK' then 1 else 0 end as SavingSpecialTotalMMK,
                   case when gam.schm_code = 'SASPL' and gam.acct_crncy_code <>'MMK'  then 1else 0 end as SavingSpecialTotalFCY,
                  case when gam.schm_Type  = 'TDA'   and gam.acct_crncy_code = 'MMK' then 1 else 0 end as TermDepositTotalMMK,
                  case when gam.schm_Type  = 'TDA'  and gam.acct_crncy_code <>'MMK'  then 1 else 0 end as TermDepositTotalFCY
                  
                
             FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     schm_type in ('CAA','TDA','SBA')
            AND    GAM.acct_opn_date < TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('L11','L21','L22','L13','L24','L15','L17','L26')
            AND    GAM.ACCT_CLS_FLG = 'N'
            and    gam.clr_bal_amt <> 0
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            and    gam.acid  not in ( select acid
                                      from tbaadm.eab e
                                      where     e.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
                                      AND    e.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
                                      )*/
            )q
          group by q.sol_id
          
    Union all   
            
            --opening bal amount logic
       select        t.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
            0 as CurrentOpenAccount,
            0 as RegularSavingOpenAccount,
            0 as SavingSpecialOpenAccount,
            0 as TermDepositOpenAccount,
             --close
            0 as CurrentCloseAccount,
            0 as RegularSavingCloseAccount,
            0 as SavingSpecialCloseAccount,
            0 as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
              sum(t.CurrentOpeningBal) as CurrentOpeningBal,
              sum(t.RegularSavingOpeningBal) as RegularSavingOpeningBal,
              sum(t.SavingSpecialOpeningBal) as SavingSpecialOpeningBal,
              sum(t.TermDepositOpeningBal) as TermDepositOpeningBal, 
            -- clos
             0 as CurrentClosingBal,
            0 as RegularSavingClosingBal,
            0 as SavingSpecialClosingBal,
            0 as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
       from (
           select q.sol_id,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (CurrentOpeningBal)
                   ELSE (CurrentOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as CurrentOpeningBal,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (RegularSavingOpeningBal)
                   ELSE (RegularSavingOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as RegularSavingOpeningBal,  
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (SavingSpecialOpeningBal)
                   ELSE (SavingSpecialOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as SavingSpecialOpeningBal, 
                     CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (TermDepositOpeningBal)
                   ELSE (TermDepositOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as TermDepositOpeningBal
                  
           from (
            select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('L11','L21','L22') then (gstt.tot_cr_bal - gstt.tot_dr_bal) else 0 end as CurrentOpeningBal,
                   case when coa.group_code in ('L13','L24') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as RegularSavingOpeningBal,
                   case when coa.group_code in ('L15') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as SavingSpecialOpeningBal,
                   case when coa.group_code in ('L17','L26') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as TermDepositOpeningBal
                    
            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('L11','L21','L22','L13','L24','L15','L17','L26')
            and     gstt.bal_date <=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )-1
            and     gstt.end_bal_date >=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )-1
            )q
          )t
          group by t.sol_id
        
  Union all    
            -- closing bal amount logic
             select t.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
            0 as CurrentOpenAccount,
            0 as RegularSavingOpenAccount,
            0 as SavingSpecialOpenAccount,
            0 as TermDepositOpenAccount,
             --close
            0 as CurrentCloseAccount,
            0 as RegularSavingCloseAccount,
            0 as SavingSpecialCloseAccount,
            0 as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
             0 as CurrentOpeningBal,
             0 as RegularSavingOpeningBal,
             0 as SavingSpecialOpeningBal,
             0 as TermDepositOpeningBal, 
            -- clos
             sum(t.CurrentOpeningBal) as CurrentClosingBal,
              sum(t.RegularSavingOpeningBal) as RegularSavingClosingBal,
              sum(t.SavingSpecialOpeningBal) as SavingSpecialClosingBal,
              sum(t.TermDepositOpeningBal) as TermDepositClosingBal,
              --
              --deposit withdrawal
            0 as CurrentDeposit,
            0 as CurrentWithdraw,
            0 as RegularSavingDeposit,
            0 as RegularSavingWithdraw,
            0 as SavingSpecialDeposit,
            0 as SavingSpecialWithdraw,
            0 as TermDepositDeposit,
            0 as TermDepositWithdraw
       from (
           select q.sol_id,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.CurrentOpeningBal 
                  ELSE q.CurrentOpeningBal  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS CurrentOpeningBal,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.RegularSavingOpeningBal 
                  ELSE q.RegularSavingOpeningBal  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS  RegularSavingOpeningBal,  
                  CASE WHEN q.crncy_code = 'MMK' THEN q.SavingSpecialOpeningBal 
                  ELSE q.SavingSpecialOpeningBal  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS  SavingSpecialOpeningBal, 
                  CASE WHEN q.crncy_code = 'MMK' THEN q.TermDepositOpeningBal 
                  ELSE q.TermDepositOpeningBal  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS TermDepositOpeningBal
                  
           from (
             select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('L11','L21','L22') then (gstt.tot_cr_bal - gstt.tot_dr_bal) else 0 end as CurrentOpeningBal,
                   case when coa.group_code in ('L13','L24') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as RegularSavingOpeningBal,
                   case when coa.group_code in ('L15') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as SavingSpecialOpeningBal,
                   case when coa.group_code in ('L17','L26') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as TermDepositOpeningBal
                    
            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('L11','L21','L22','L13','L24','L15','L17','L26')
            and     gstt.bal_date <=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            and     gstt.end_bal_date >=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          )t
          group by t.sol_id
          
  Union all
          
          -- get Deposit and Withdrawal Logic
            select 
               t.sol_id,
              --bf 
             0 as CurrentBFAccountBalance,
             0 as RegularSavingBFAccountBalance,
             0 as SavingSpecialBFAccountBalance,
             0 as TermDepositBFAccountBalance,
             --open
            0 as CurrentOpenAccount,
            0 as RegularSavingOpenAccount,
            0 as SavingSpecialOpenAccount,
            0 as TermDepositOpenAccount,
             --close
            0 as CurrentCloseAccount,
            0 as RegularSavingCloseAccount,
            0 as SavingSpecialCloseAccount,
            0 as TermDepositCloseAccount,
                --fcy mmk total
             0 as CurrentTotalMMK,
             0 as CurrentTotalFCY,
             0 as RegularSavingTotalMMK,
             0 as RegularSavingTotalFCY,
             0 as SavingSpecialTotalMMK,
             0 as SavingSpecialTotalFCY,
             0 as TermDepositTotalMMK,
             0 as TermDepositTotalFCY,
             --open bal
             0 as CurrentOpeningBal,
             0 as RegularSavingOpeningBal,
             0 as SavingSpecialOpeningBal,
             0 as TermDepositOpeningBal, 
            -- clos
             0 as CurrentClosingBal,
             0 as RegularSavingClosingBal,
              0 as SavingSpecialClosingBal,
             0 as TermDepositClosingBal,
              --
              --deposit withdrawal
             sum(t.CurrentDeposit) as CurrentDeposit,
              sum(t.CurrentWithdraw) as CurrentWithdraw,
              sum(t.RegularSavingDeposit) as RegularSavingDeposit,
              sum(t.RegularSavingWithdraw) as RegularSavingWithdraw,
             sum(t.SavingSpecialDeposit) as SavingSpecialDeposit,
              sum(t.SavingSpecialWithdraw) as SavingSpecialWithdraw,
              sum(t.TermDepositDeposit) as TermDepositDeposit,
              sum(t.TermDepositWithdraw) as TermDepositWithdraw
       from (
           select q.sol_id,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.CurrentDeposit 
                  ELSE q.CurrentDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS CurrentDeposit,
                  CASE WHEN q.crncy_code = 'MMK' THEN q.CurrentWithdraw 
                  ELSE q.CurrentWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS CurrentWithdraw,              
                  CASE WHEN q.crncy_code = 'MMK' THEN q.RegularSavingDeposit 
                  ELSE q.RegularSavingDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS RegularSavingDeposit,           
                   CASE WHEN q.crncy_code = 'MMK' THEN q.RegularSavingWithdraw 
                  ELSE q.RegularSavingWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS RegularSavingWithdraw,
                    CASE WHEN q.crncy_code = 'MMK' THEN q.SavingSpecialDeposit 
                  ELSE q.SavingSpecialDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS SavingSpecialDeposit,                                        
                 CASE WHEN q.crncy_code = 'MMK' THEN q.SavingSpecialWithdraw 
                  ELSE q.SavingSpecialWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS SavingSpecialWithdraw,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.TermDepositDeposit 
                  ELSE q.TermDepositDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS TermDepositDeposit,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.TermDepositWithdraw 
                  ELSE q.TermDepositWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST (  ci_Tran_date  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                              ),1) END AS TermDepositWithdraw                                          
           from (
            select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('L11','L21','L22') then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as CurrentDeposit,
                   case when coa.group_code in ('L11','L21','L22') then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as CurrentWithdraw,
                   case when coa.group_code in ('L13','L24')       then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) else 0 end as RegularSavingDeposit,
                   case when coa.group_code in ('L13','L24')       then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as RegularSavingWithdraw,
                   case when coa.group_code in ('L15')             then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT)  else 0 end as SavingSpecialDeposit,
                    case when coa.group_code in ('L15')            then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as SavingSpecialWithdraw,
                   case when coa.group_code in ('L17','L26')       then (gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT)  else 0 end as TermDepositDeposit,
                   case when coa.group_code in ('L17','L26')       then (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as TermDepositWithdraw
       
            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('L11','L21','L22','L13','L24','L15','L17','L26')
            and     gstt.bal_date =  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            --and     gstt.end_bal_date >=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          )t
          group by t.sol_id
    )a   
  group by a.sol_id)two
  on  sol.sol_id = two.sol_id
  where sol.sol_id not in ('10100','101','20100')
    and two.sol_id is not null
    order by sol.sol_id;
 --   select * from custom.coa_mp ;where description like '%INT%';
    

    
    

  PROCEDURE FIN_DAILY_POSI_TOTAL_DEPT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS 
      
      Sol_Id tbaadm.sol.sol_id%type;
      Sol_Desc TBAADM.sol.sol_desc%type;
       
      CurrentBFAccountBalance                Number(20,2);
      RegularSavingBFAccountBalance          Number(20,2);
      SavingSpecialBFAccountBalance          Number(20,2);
      TermDepositBFAccountBalance            Number(20,2);
      
      CurrentOpenAccount                     Number(20,2);
      RegularSavingOpenAccount               Number(20,2);
      SavingSpecialOpenAccount               Number(20,2);
      TermDepositOpenAccount                 Number(20,2);
      
      CurrentCloseAccount                    Number(20,2);
      RegularSavingCloseAccount              Number(20,2);
      SavingSpecialCloseAccount              Number(20,2);
      TermDepositCloseAccount                Number(20,2);
      
      CurrentTotalMMK                        Number(20,2);
      CurrentTotalFCY                        Number(20,2);
      RegularSavingTotalMMK                  Number(20,2);
      RegularSavingTotalFCY                  Number(20,2);
      SavingSpecialTotalMMK                  Number(20,2);
      SavingSpecialTotalFCY                  Number(20,2);
      TermDepositTotalMMK                    Number(20,2);
      TermDepositTotalFCY                    Number(20,2);
      
             --open bal
      CurrentOpeningBal                      Number(20,2);
      RegularSavingOpeningBal                Number(20,2);
      SavingSpecialOpeningBal                Number(20,2);
      TermDepositOpeningBal                  Number(20,2);
      
      CurrentClosingBal                      Number(20,2);
      RegularSavingClosingBal                Number(20,2);
      SavingSpecialClosingBal                Number(20,2);
      TermDepositClosingBal                  Number(20,2);
      
        --deposit withdrawal
      CurrentDeposit                         Number(20,2);
      CurrentWithdraw                        Number(20,2);
      RegularSavingDeposit                   Number(20,2);
      RegularSavingWithdraw                  Number(20,2);
      SavingSpecialDeposit                   Number(20,2);
      SavingSpecialWithdraw                  Number(20,2);
      TermDepositDeposit                     Number(20,2);
      TermDepositWithdraw                    Number(20,2);
      
  BEGIN
        -------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
        -------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_Tran_date:=outArr(0);
 -------------------------------------------------------------------------------
 if( vi_Tran_date is null ) then
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 ---------------------------------------------------------------------------------
 --if cur---
    IF NOT ExtractDataAllBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAllBranch(vi_Tran_date);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataAllBranch%ISOPEN THEN
    
    	FETCH	ExtractDataAllBranch
			INTO	 Sol_Desc,Sol_Id,
       
      CurrentBFAccountBalance,
      RegularSavingBFAccountBalance ,
      SavingSpecialBFAccountBalance ,
      TermDepositBFAccountBalance   ,
      
      CurrentOpenAccount     ,
      RegularSavingOpenAccount      ,
      SavingSpecialOpenAccount      ,
      TermDepositOpenAccount        ,
      
      CurrentCloseAccount           ,
      RegularSavingCloseAccount     ,
      SavingSpecialCloseAccount     ,
      TermDepositCloseAccount       ,
      
      CurrentTotalMMK               ,
      CurrentTotalFCY               ,
      RegularSavingTotalMMK         ,
      RegularSavingTotalFCY         ,
      SavingSpecialTotalMMK         ,
      SavingSpecialTotalFCY         ,
      TermDepositTotalMMK           ,
      TermDepositTotalFCY           ,
      
             --open bal
      CurrentOpeningBal             ,
      RegularSavingOpeningBal       ,
      SavingSpecialOpeningBal       ,
      TermDepositOpeningBal         ,
      
      CurrentClosingBal              ,
      RegularSavingClosingBal        ,
      SavingSpecialClosingBal        ,
      TermDepositClosingBal          ,
      
        --deposit withdrawal
      CurrentDeposit                ,
      CurrentWithdraw               ,
      RegularSavingDeposit          ,
      RegularSavingWithdraw         ,
      SavingSpecialDeposit          ,
      SavingSpecialWithdraw         ,
      TermDepositDeposit            ,
      TermDepositWithdraw           ;
		  ------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAllBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataAllBranch;
				out_retCode:= 1;
				RETURN;  
			--}
			END IF;
    END IF;  
-------------------------------------------------------------------------------
     
    out_rec:=	(  Sol_Desc                 ||'|'|| 
                 Sol_Id                      ||'|'|| 
       
      CurrentBFAccountBalance              ||'|'|| 
      RegularSavingBFAccountBalance       ||'|'|| 
      SavingSpecialBFAccountBalance       ||'|'|| 
      TermDepositBFAccountBalance         ||'|'|| 
        
      CurrentOpenAccount                   ||'|'|| 
      RegularSavingOpenAccount            ||'|'|| 
      SavingSpecialOpenAccount            ||'|'|| 
      TermDepositOpenAccount              ||'|'|| 
      
      CurrentCloseAccount                 ||'|'|| 
      RegularSavingCloseAccount           ||'|'|| 
      SavingSpecialCloseAccount           ||'|'|| 
      TermDepositCloseAccount             ||'|'|| 
      
      CurrentTotalMMK                     ||'|'|| 
      CurrentTotalFCY                     ||'|'|| 
      RegularSavingTotalMMK               ||'|'|| 
      RegularSavingTotalFCY               ||'|'|| 
      SavingSpecialTotalMMK               ||'|'|| 
      SavingSpecialTotalFCY               ||'|'|| 
      TermDepositTotalMMK                 ||'|'|| 
      TermDepositTotalFCY                 ||'|'|| 
      
             --open bal
      CurrentOpeningBal                   ||'|'|| 
      RegularSavingOpeningBal             ||'|'|| 
      SavingSpecialOpeningBal             ||'|'|| 
      TermDepositOpeningBal               ||'|'|| 
 
        --deposit withdrawal
      CurrentDeposit                      ||'|'|| 
      CurrentWithdraw                     ||'|'|| 
      RegularSavingDeposit                ||'|'|| 
      RegularSavingWithdraw               ||'|'|| 
      SavingSpecialDeposit                ||'|'|| 
      SavingSpecialWithdraw               ||'|'|| 
      TermDepositDeposit                  ||'|'|| 
      TermDepositWithdraw                 ||'|'||       
          --clos bal
      CurrentClosingBal                   ||'|'|| 
      RegularSavingClosingBal             ||'|'|| 
      SavingSpecialClosingBal             ||'|'|| 
      TermDepositClosingBal              
  );
    
      dbms_output.put_line(out_rec);
  END FIN_DAILY_POSI_TOTAL_DEPT;

END FIN_DAILY_POSI_TOTAL_DEPT;
/
