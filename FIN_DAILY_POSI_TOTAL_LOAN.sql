CREATE OR REPLACE PACKAGE                      FIN_DAILY_POSI_TOTAL_LOAN AS 

  PROCEDURE FIN_DAILY_POSI_TOTAL_LOAN(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DAILY_POSI_TOTAL_LOAN;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                       FIN_DAILY_POSI_TOTAL_LOAN AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_Tran_date		Varchar2(10);		    	  -- Input to procedure

    
CURSOR ExtractDataAllBranch(ci_Tran_date VARCHAR2) IS

 select sol.sol_desc, 
      two.sol_id,
     nvl(two.DLBFAccountBalance,0) as DLBFAccountBalance,
      nvl(two.TFBFAccountBalance,0) as TFBFAccountBalance,
      nvl(two.ODBFAccountBalance,0) as ODBFAccountBalance,
      nvl(two.HPBFAccountBalance,0) as HPBFAccountBalance,
      nvl(two.SLBFAccountBalance,0) as SLBFAccountBalance,
       --open
      nvl(two.DLOpenAccount,0) as DLOpenAccount,
         nvl(two.TFOpenAccount,0) as TFOpenAccount,
         nvl(two.ODOpenAccount,0) as ODOpenAccount,
         nvl(two.HPOpenAccount,0) as HPOpenAccount,
         nvl(two.SLOpenAccount,0) as SLOpenAccount,
       --close
       nvl(two.DLCloseAccount,0) as DLCloseAccount,
         nvl(two.TFCloseAccount,0) as TFCloseAccount,
         nvl(two.ODCloseAccount,0) as ODCloseAccount,
         nvl(two.HPCloseAccount,0) as HPCloseAccount,
         nvl(two.SLCloseAccount,0) as SLCloseAccount,
          --fcy mmk totalsum(q.SLCloseAccount,0) as HPCloseAccount,
          nvl(two.DLTotalMMK,0) as DLTotalMMK,
         nvl(two.DLTotalFCY,0) as DLTotalFCY,
         nvl(two.TFTotalMMK,0) as TFTotalMMK,
         nvl(two.TFTotalFCY,0) as TFTotalFCY,
         nvl(two.ODTotalMMK,0) as ODTotalMMK,
         nvl(two.ODTotalFCY,0) as ODTotalFCY,
         nvl(two.HPTotalMMK,0) as HPTotalMMK,
         nvl(two.HPTotalFCY,0) as HPTotalFCY,
         nvl(two.SLTotalMMK,0) as SLTotalMMK,
         nvl(two.SLTotalFCY,0) as SLTotalFCY,
       --open bal
       nvl(two.DLOpeningBal,0) as DLOpeningBal,
       nvl(two.TFOpeningBal,0) as TFOpeningBal,
       nvl(two.ODOpeningBal,0) as ODOpeningBal,
       nvl(two.HPOpeningBal,0) as HPOpeningBal,
       nvl(two.SLOpeningBal,0) as SLOpeningBal,
       
        nvl(two.DLClosingBal,0) as DLClosingBal,
       nvl(two.TFClosingBal,0) as TFClosingBal,
       nvl(two.ODClosingBal,0) as ODClosingBal,
       nvl(two.HPClosingBal,0) as HPClosingBal,
       nvl(two.SLClosingBal,0) as SLClosingBal,
     
       
        --
        --deposit withdrawal
       nvl(two.DLDeposit,0) as DLDeposit,
       nvl(two.DLWithdraw,0) as DLWithdraw,
       nvl(two.TFDeposit,0) as TFDeposit,
       nvl(two.TFWithdraw,0) as TFWithdraw,
      nvl(two.ODOpeningBalDeposit,0) as ODOpeningBalDeposit,
       nvl(two.ODOpeningBalWithdraw,0) as ODOpeningBalWithdraw ,
       nvl(two.HPDeposit,0) as HPDeposit,
       nvl(two.HPWithdraw,0) as HPWithdraw ,
       nvl(two.SLDeposit,0) as SLDeposit,
       nvl(two.SLWithdraw,0) as SLWithdraw
from tbaadm.sol sol
left join (select a.sol_id,
      sum(a.DLBFAccountBalance) as DLBFAccountBalance,
       sum(a.TFBFAccountBalance) as TFBFAccountBalance,
       sum(a.ODBFAccountBalance)  as ODBFAccountBalance,
       sum(a.HPBFAccountBalance) as HPBFAccountBalance,
       sum(a.SLBFAccountBalance) as SLBFAccountBalance,
       --open
       sum(a.DLOpenAccount) as DLOpenAccount,
          sum(a.TFOpenAccount) as TFOpenAccount,
          sum(a.ODOpenAccount) as ODOpenAccount,
          sum(a.HPOpenAccount) as HPOpenAccount,
          sum(a.SLOpenAccount) as SLOpenAccount,
       --close
         sum(a.DLCloseAccount) as DLCloseAccount,
          sum(a.TFCloseAccount) as TFCloseAccount,
          sum(a.ODCloseAccount) as ODCloseAccount,
          sum(a.HPCloseAccount) as HPCloseAccount,
          sum(a.SLCloseAccount) as SLCloseAccount,
          --fcy mmk totalsum(q.SLCloseAccount) as HPCloseAccount,
           sum(a.DLTotalMMK) as DLTotalMMK,
          sum(a.DLTotalFCY) as DLTotalFCY,
          sum(a.TFTotalMMK) as TFTotalMMK,
          sum(a.TFTotalFCY) as TFTotalFCY,
          sum(a.ODTotalMMK) as ODTotalMMK,
          sum(a.ODTotalFCY) as ODTotalFCY,
          sum(a.HPTotalMMK) as HPTotalMMK,
          sum(a.HPTotalFCY) as HPTotalFCY,
          sum(a.SLTotalMMK) as SLTotalMMK,
          sum(a.SLTotalFCY) as SLTotalFCY,
       --open bal
       abs( sum(a.DLOpeningBal)) as DLOpeningBal,
       abs(  sum(a.TFOpeningBal)) as TFOpeningBal,
       abs(  sum(a.ODOpeningBal)) as ODOpeningBal,
       abs(  sum(a.HPOpeningBal)) as HPOpeningBal,
       abs(  sum(a.SLOpeningBal)) as SLOpeningBal,
       
        abs(sum(a.DLClosingBal)) as DLClosingBal,
        abs(sum(a.TFClosingBal)) as TFClosingBal,
        abs(sum(a.ODClosingBal)) as ODClosingBal,
        abs(sum(a.HPClosingBal)) as HPClosingBal,
        abs(sum(a.SLClosingBal)) as SLClosingBal,   
        --
        
        --deposit withdrawal
        sum(a.DLDeposit) as DLDeposit,
        sum(a.DLWithdraw) as DLWithdraw,
        sum(a.TFDeposit) as TFDeposit,
        sum(a.TFWithdraw) as TFWithdraw,
       sum(a.ODOpeningBalDeposit) as ODOpeningBalDeposit,
        sum(a.ODOpeningBalWithdraw) as ODOpeningBalWithdraw ,
        sum(a.HPDeposit) as HPDeposit,
        sum(a.HPWithdraw) as HPWithdraw ,
        sum(a.SLDeposit) as SLDeposit,
        sum(a.SLWithdraw) as SLWithdraw
from (
       -- BF A/C Total Counting logic
      select  q.sol_id,
              --bf 
             sum(q.DLBFAccountBalance) as DLBFAccountBalance,
             sum(q.TFBFAccountBalance) as TFBFAccountBalance,
             sum(q.ODBFAccountBalance) as ODBFAccountBalance,
             sum(q.HPBFAccountBalance) as HPBFAccountBalance, 
             sum(q.SLBFAccountBalance) as SLBFAccountBalance,
             --open
             0 as DLOpenAccount,
             0 as TFOpenAccount,
             0 as ODOpenAccount,
             0 as HPOpenAccount,
             0 as SLOpenAccount,
             --close
             0 as DLCloseAccount,
             0 as TFCloseAccount,
             0 as ODCloseAccount,
             0 as HPCloseAccount,
            0 as SLCloseAccount,
                --fcy mmk total
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
             0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
            0 as DLOpeningBal,
            0 as TFOpeningBal,
            0 as ODOpeningBal,
            0 as HPOpeningBal,
            0 as SLOpeningBal,
            
             0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
            0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
             0  as SLWithdraw
      from (
            Select gam.sol_id as sol_id,
                   case when gam.schm_code = 'AGDNL'   then 1 else 0 end as DLBFAccountBalance,
                   case when gam.gl_sub_head_code  in ('10313','10314') then 1 else 0 end as TFBFAccountBalance,
                   case when gam.schm_code = 'AGDOD' then 1 else 0 end as ODBFAccountBalance,
                  case when gam.schm_code like 'AG%HP%'   then 1 else 0 end as HPBFAccountBalance,
                  case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') then 1 else 0 end as SLBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
           AND    GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
            --AND    GAM.ACCT_CLS_FLG = 'N'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            
            union all
            
             Select gam.sol_id as sol_id,
                   case when gam.schm_code = 'AGDNL'   then 1 else 0 end as DLBFAccountBalance,
                   case when gam.gl_sub_head_code  in ('10313','10314') then 1 else 0 end as TFBFAccountBalance,
                   case when gam.schm_code = 'AGDOD' then 1 else 0 end as ODBFAccountBalance,
                  case when gam.schm_code like 'AG%HP%'   then 1 else 0 end as HPBFAccountBalance,
                  case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') then 1 else 0 end as SLBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
           AND    GAM.acct_opn_date = (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
            --AND    GAM.ACCT_CLS_FLG = 'N'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            
            union all
            
             Select gam.sol_id as sol_id,
                   case when gam.schm_code = 'AGDNL'   then -1 else 0 end as DLBFAccountBalance,
                   case when gam.gl_sub_head_code  in ('10313','10314') then -1 else 0 end as TFBFAccountBalance,
                   case when gam.schm_code = 'AGDOD' then -1 else 0 end as ODBFAccountBalance,
                  case when gam.schm_code like 'AG%HP%'   then -1 else 0 end as HPBFAccountBalance,
                  case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') then -1 else 0 end as SLBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')-1
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
            AND    GAM.ACCT_CLS_FLG = 'Y'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
          
          /*  
            union all
            
             Select gam.sol_id as sol_id,
                   case when gam.schm_code = 'AGDNL'   then 1 else 0 end as DLBFAccountBalance,
                   case when gam.gl_sub_head_code  in ('10313','10314') then 1 else 0 end as TFBFAccountBalance,
                   case when gam.schm_code = 'AGDOD' then 1 else 0 end as ODBFAccountBalance,
                  case when gam.schm_code like 'AG%HP%'   then 1 else 0 end as HPBFAccountBalance,
                  case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') then 1 else 0 end as SLBFAccountBalance
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_opn_date < TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
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
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance, 
             0 as SLBFAccountBalance,
             --open
             sum(q.DLOpenAccount) as DLOpenAccount,
             sum(q.TFOpenAccount) as TFOpenAccount,
             sum(q.ODOpenAccount) as ODOpenAccount,
             sum(q.HPOpenAccount) as HPOpenAccount,
             sum(q.SLOpenAccount) as SLOpenAccount,
             
             --close
             0 as DLCloseAccount,
             0 as TFCloseAccount,
             0 as ODCloseAccount,
             0 as HPCloseAccount,
             0 as SLCloseAccount,
                --fcy mmk total
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
              0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
            0 as DLOpeningBal,
            0 as TFOpeningBal,
            0 as ODOpeningBal,
            0 as HPOpeningBal,
            0 as SLOpeningBal,
            
             0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
            0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
             0  as SLWithdraw
         from (
             Select gam.sol_id as sol_id,
                    case when gam.schm_code = 'AGDNL'  and acct_cls_flg = 'N'                    then 1 else 0 end as DLOpenAccount,
                    case when gl_sub_head_code  in ('10313','10314')  and acct_cls_flg = 'N'     then 1 else 0 end as TFOpenAccount,
                    case when gam.schm_code = 'AGDOD'  and acct_cls_flg = 'N'                    then 1 else 0 end as ODOpenAccount,
                    case when gam.schm_code like 'AG%HP%'   and acct_cls_flg = 'N'               then 1 else 0 end as HPOpenAccount, 
                    case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') and acct_cls_flg = 'N'  then 1 else 0 end as SLOpenAccount
            from    tbaadm.gam 
            where   gam.del_flg = 'N'
            and     gam.bank_id = '01'
            and     gam.schm_type in ('CAA','LAA','OAB')
            and     gam.acct_opn_date = TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          group by q.sol_id
          
   Union all 
            --closing a/c Counting logic
            
           select        q.sol_id,
              --bf 
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance,
             0 as SLBFAccountBalance,
             --open
            0 as DLOpenAccount,
            0 as TFOpenAccount,
            0 as ODOpenAccount,
            0 as HPOpenAccount,
            0 as SLOpenAccount,
             --close
            sum(q.DLCloseAccount) as DLCloseAccount,
            sum(q.TFCloseAccount) as TFCloseAccount,
            sum(q.ODCloseAccount) as ODCloseAccount,
            sum(q.HPCloseAccount) as HPCloseAccount,
             sum(q.SLCloseAccount) as HPCloseAccount,
                --fcy mmk total
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
              0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
            0 as DLOpeningBal,
            0 as TFOpeningBal,
            0 as ODOpeningBal,
            0 as HPOpeningBal,
            0 as SLOpeningBal,
            
             0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
              0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
             0  as SLWithdraw
         from (
             Select gam.sol_id as sol_id,
                     case when gam.schm_code = 'AGDNL'                and acct_cls_flg = 'Y'     then 1 else 0 end as DLCloseAccount,
                    case when gl_sub_head_code  in ('10313','10314')  and acct_cls_flg = 'Y'     then 1 else 0 end as TFCloseAccount,
                    case when gam.schm_code = 'AGDOD'                 and acct_cls_flg = 'Y'     then 1 else 0 end as ODCloseAccount,
                    case when gam.schm_code like 'AG%HP%'             and acct_cls_flg = 'Y'     then 1 else 0 end as HPCloseAccount, 
                    case when gam.schm_code in ('AGDHL','AGSS1','AGDS3') and acct_cls_flg = 'Y'  then 1 else 0 end as SLCloseAccount
            from    tbaadm.gam 
            where   gam.del_flg = 'N'
            and     gam.bank_id = '01'
            and     gam.schm_type in ('CAA','LAA','OAB')
            and     gam.acct_cls_date = TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          group by q.sol_id
          
  Union all 
  
        --Fcy and MMK total account logic
          select    q.sol_id,
              --bf 
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance,
             0 as SLBFAccountBalance,
             --open
            0 as DLOpenAccount,
            0 as TFOpenAccount,
            0 as ODOpenAccount,
            0 as HPOpenAccount,
            0 as SLOpenAccount,
             --close
            0 as DLCloseAccount,
            0 as TFCloseAccount,
            0 as ODCloseAccount,
            0 as HPCloseAccount,
            0 as SLCloseAccount,
                --fcy mmk totalsum(q.SLCloseAccount) as HPCloseAccount,
             sum(q.DLTotalMMK) as DLTotalMMK,
              sum(q.DLTotalFCY) as DLTotalFCY,
              sum(q.TFTotalMMK) as TFTotalMMK,
              sum(q.TFTotalFCY) as TFTotalFCY,
              sum(q.ODTotalMMK) as ODTotalMMK,
              sum(q.ODTotalFCY) as ODTotalFCY,
              sum(q.HPTotalMMK) as HPTotalMMK,
              sum(q.HPTotalFCY) as HPTotalFCY,
              sum(q.SLTotalMMK) as SLTotalMMK,
              sum(q.SLTotalFCY) as SLTotalFCY,
             --open bal
            0 as DLOpeningBal,
            0 as TFOpeningBal,
            0 as ODOpeningBal,
            0 as HPOpeningBal,
            0 as SLOpeningBal,
            
             0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
            0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
            0  as SLWithdraw
          from (
            Select gam.sol_id as sol_id,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as DLTotalMMK,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as DLTotalFCY,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as TFTotalMMK,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as TFTotalFCY,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as ODTotalMMK,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as ODTotalFCY,
                  case when   gam.schm_code like 'AG%HP%'              and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as HPTotalMMK,
                  case when   gam.schm_code like 'AG%HP%'             and gam.acct_crncy_code <>    'MMK'  then 1 else 0 end as HPTotalFCY,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3')  and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as SLTotalMMK,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3') and gam.acct_crncy_code <> 'MMK'  then 1 else 0 end as SLTotalFCY
                  
                
           FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_opn_date < TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
           -- AND    GAM.ACCT_CLS_FLG = 'N'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            
            union all
            
            Select gam.sol_id as sol_id,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as DLTotalMMK,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as DLTotalFCY,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as TFTotalMMK,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as TFTotalFCY,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as ODTotalMMK,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as ODTotalFCY,
                  case when   gam.schm_code like 'AG%HP%'              and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as HPTotalMMK,
                  case when   gam.schm_code like 'AG%HP%'             and gam.acct_crncy_code <>    'MMK'  then 1 else 0 end as HPTotalFCY,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3')  and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as SLTotalMMK,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3') and gam.acct_crncy_code <> 'MMK'  then 1 else 0 end as SLTotalFCY
                  
                
           FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_opn_date = TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
           -- AND    GAM.ACCT_CLS_FLG = 'N'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            
            union all
            
            Select gam.sol_id as sol_id,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code =    'MMK'  then -1 else 0 end as DLTotalMMK,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code <>   'MMK'  then -1 else 0 end as DLTotalFCY,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code =    'MMK'  then -1 else 0 end as TFTotalMMK,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code <>   'MMK'  then -1 else 0 end as TFTotalFCY,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code =    'MMK'  then -1 else 0 end as ODTotalMMK,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code <>   'MMK'  then -1 else 0 end as ODTotalFCY,
                  case when   gam.schm_code like 'AG%HP%'              and gam.acct_crncy_code =    'MMK'  then -1 else 0 end as HPTotalMMK,
                  case when   gam.schm_code like 'AG%HP%'             and gam.acct_crncy_code <>    'MMK'  then -1 else 0 end as HPTotalFCY,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3')  and gam.acct_crncy_code = 'MMK'  then -1 else 0 end as SLTotalMMK,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3') and gam.acct_crncy_code <> 'MMK'  then -1 else 0 end as SLTotalFCY
                  
                
           FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA ,tbaadm.eab eab
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     eab.acid = gam.acid
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_cls_date = TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
           AND    GAM.ACCT_CLS_FLG = 'Y'
            AND    GAM.BANK_ID = '01'
            AND    GAM.ENTITY_CRE_FLG = 'Y'
            
           /* union all
            
             Select gam.sol_id as sol_id,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as DLTotalMMK,
                   case when  gam.schm_code = 'AGDNL'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as DLTotalFCY,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as TFTotalMMK,
                   case when  gam.gl_sub_head_code  in ('10313','10314')   and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as TFTotalFCY,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as ODTotalMMK,
                   case when  gam.schm_code = 'AGDOD'                  and gam.acct_crncy_code <>   'MMK'  then 1 else 0 end as ODTotalFCY,
                  case when   gam.schm_code like 'AG%HP%'              and gam.acct_crncy_code =    'MMK'  then 1 else 0 end as HPTotalMMK,
                  case when   gam.schm_code like 'AG%HP%'             and gam.acct_crncy_code <>    'MMK'  then 1 else 0 end as HPTotalFCY,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3')  and gam.acct_crncy_code = 'MMK'  then 1 else 0 end as SLTotalMMK,
                  case when   gam.schm_code in ('AGDHL','AGSS1','AGDS3') and gam.acct_crncy_code <> 'MMK'  then 1 else 0 end as SLTotalFCY
                  
                
            FROM   TBAADM.GAM GAM , CUSTOM.COA_MP COA
            WHERE  coa.gl_sub_head_code = gam.gl_sub_head_code
            AND    COA.CUR = gam.acct_crncy_code
            and     schm_type in ('LAA','CAA')
            AND    GAM.acct_opn_date <= TO_DATE(CAST(ci_Tran_date AS VARCHAR(10)), 'dd-MM-yyyy')
            AND    COA.GROUP_CODE IN ('A21','A23','A24','A25','A26')
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
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance, 
             0 as SLBFAccountBalance,
             --open
            0 as DLOpenAccount,
            0 as TFOpenAccount,
            0 as ODOpenAccount,
            0 as HPOpenAccount,
            0 as SLOpenAccount,
             --close
            0 as DLCloseAccount,
            0 as TFCloseAccount,
            0 as ODCloseAccount,
            0 as HPCloseAccount,
            0 as SLCloseAccount,
            
                --fcy mmk totalsum(q.SLCloseAccount) as HPCloseAccount,
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
              0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
              sum(t.DLOpeningBal) as DLOpeningBal,
              sum(t.TFOpeningBal) as TFOpeningBal,
              sum(t.ODOpeningBal) as ODOpeningBal,
              sum(t.HPOpeningBal) as HPOpeningBal, 
              sum(t.SLOpeningBal) as SLOpeningBal,
            -- clos
            0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
            0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
            0  as SLWithdraw
       from (
           select q.sol_id,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.DLOpeningBal)
                   ELSE (q.DLOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
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
                                        ),1) END   as DLOpeningBal,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.TFOpeningBal)
                   ELSE (q.TFOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
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
                                        ),1) END   as TFOpeningBal,  
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.ODOpeningBal)
                   ELSE (q.ODOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
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
                                        ),1) END   as ODOpeningBal, 
                     CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.HPOpeningBal)
                   ELSE (q.HPOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
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
                                        ),1) END   as HPOpeningBal,
                CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.SLOpeningBal)
                   ELSE (q.SLOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
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
                                        ),1) END   as SLOpeningBal                         
                  
           from (
            select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('A21') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as DLOpeningBal,
                   case when coa.group_code in ('A22') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as TFOpeningBal,
                   case when coa.group_code in ('A23') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as ODOpeningBal,
                   case when coa.group_code in ('A24') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as HPOpeningBal,
                   case when coa.group_code in ('A25') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as SLOpeningBal
                    
            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('A21','A22','A23','A24','A25')
            and     gstt.bal_date <=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )-1
            and     gstt.end_bal_date >=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )-1
            )q
          )t
          group by t.sol_id
union all      
      --opening bal amount logic
select        t.sol_id,
              --bf 
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance, 
             0 as SLBFAccountBalance,
             --open
            0 as DLOpenAccount,
            0 as TFOpenAccount,
            0 as ODOpenAccount,
            0 as HPOpenAccount,
            0 as SLOpenAccount,
             --close
            0 as DLCloseAccount,
            0 as TFCloseAccount,
            0 as ODCloseAccount,
            0 as HPCloseAccount,
            0 as SLCloseAccount,
            
                --fcy mmk totalsum(q.SLCloseAccount) as HPCloseAccount,
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
              0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
              0 as DLOpeningBal,
              0 as TFOpeningBal,
              0 as ODOpeningBal,
              0 as HPOpeningBal, 
              0 as SLOpeningBal,
            -- clos
            sum(t.DLOpeningBal) as DLClosingBal,
            sum(t.TFOpeningBal) as TFClosingBal,
            sum(t.ODOpeningBal) as ODClosingBal,
            sum(t.HPOpeningBal) as HPClosingBal,
            sum(t.SLOpeningBal) as SLClosingBal,
              --
              --deposit withdrawal
            0 as DLDeposit,
            0 as DLWithdraw,
            0 as TFDeposit,
            0 as TFWithdraw,
            0 as ODOpeningBalDeposit,
            0 as ODOpeningBalWithdraw,
            0 as HPDeposit,
            0 as HPWithdraw,
            0 as SLDeposit,
            0  as SLWithdraw
       from (
           select q.sol_id,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.DLOpeningBal)
                   ELSE (q.DLOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as DLOpeningBal,
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.TFOpeningBal)
                   ELSE (q.TFOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as TFOpeningBal,  
                  CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.ODOpeningBal)
                   ELSE (q.ODOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as ODOpeningBal, 
                     CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.HPOpeningBal)
                   ELSE (q.HPOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as HPOpeningBal,
                CASE WHEN  q.CRNCY_CODE = 'MMK' THEN (q.SLOpeningBal)
                   ELSE (q.SLOpeningBal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(q.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(q.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  ci_Tran_date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as SLOpeningBal                         
                  
           from (
            select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('A21') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as DLOpeningBal,
                   case when coa.group_code in ('A22') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as TFOpeningBal,
                   case when coa.group_code in ('A23') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as ODOpeningBal,
                   case when coa.group_code in ('A24') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as HPOpeningBal,
                   case when coa.group_code in ('A25') then gstt.tot_cr_bal - gstt.tot_dr_bal else 0 end as SLOpeningBal
                    
            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('A21','A22','A23','A24','A25')
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
             0 as DLBFAccountBalance,
             0 as TFBFAccountBalance,
             0 as ODBFAccountBalance,
             0 as HPBFAccountBalance,
            0 as SLBFAccountBalance,
             --open
            0 as DLOpenAccount,
            0 as TFOpenAccount,
            0 as ODOpenAccount,
            0 as HPOpenAccount,
            0 as SLOpenAccount,
             --close
            0 as DLCloseAccount,
            0 as TFCloseAccount,
            0 as ODCloseAccount,
            0 as HPCloseAccount,
            0 as SLCloseAccount,
                --fcy mmk totalsum(q.SLCloseAccount) as HPCloseAccount,
             0 as DLTotalMMK,
             0 as DLTotalFCY,
             0 as TFTotalMMK,
             0 as TFTotalFCY,
             0 as ODTotalMMK,
             0 as ODTotalFCY,
             0 as HPTotalMMK,
             0 as HPTotalFCY,
              0 as SLTotalMMK,
             0 as SLTotalFCY,
             --open bal
             0 as DLOpeningBal,
             0 as TFOpeningBal,
             0 as ODOpeningBal,
             0 as HPOpeningBal, 
             0 as SLOpeningBal,
            -- clos
            0 as DLClosingBal,
            0 as TFClosingBal,
            0 as ODClosingBal,
            0 as HPClosingBal,
            0 as SLClosingBal,
              --
              --deposit withdrawal
             sum(t.DLDeposit) as DLDeposit,
              sum(t.DLWithdraw) as DLWithdraw,
              sum(t.TFDeposit) as TFDeposit,
              sum(t.TFWithdraw) as TFWithdraw,
             sum(t.ODOpeningBalDeposit) as ODOpeningBalDeposit,
              sum(t.ODOpeningBalWithdraw) as ODOpeningBalWithdraw,
              sum(t.HPDeposit) as HPDeposit,
              sum(t.HPWithdraw) as HPWithdraw,
              sum(t.SLDeposit) as SLDeposit,
              sum(t.SLWithdraw) as SLWithdraw
       from (
           select q.sol_id,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.DLDeposit 
                  ELSE q.DLDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS DLDeposit,
                  CASE WHEN q.crncy_code = 'MMK' THEN q.DLWithdraw 
                  ELSE q.DLWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS DLWithdraw,              
                  CASE WHEN q.crncy_code = 'MMK' THEN q.TFDeposit 
                  ELSE q.TFDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS TFDeposit,           
                   CASE WHEN q.crncy_code = 'MMK' THEN q.TFWithdraw 
                  ELSE q.TFWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS TFWithdraw,
                    CASE WHEN q.crncy_code = 'MMK' THEN q.ODOpeningBalDeposit 
                  ELSE q.ODOpeningBalDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS ODOpeningBalDeposit,                                        
                 CASE WHEN q.crncy_code = 'MMK' THEN q.ODOpeningBalWithdraw 
                  ELSE q.ODOpeningBalWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS ODOpeningBalWithdraw,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.HPDeposit 
                  ELSE q.HPDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS HPDeposit,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.HPWithdraw 
                  ELSE q.HPWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS HPWithdraw ,
                  CASE WHEN q.crncy_code = 'MMK' THEN q.SLDeposit 
                  ELSE q.SLDeposit  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS SLDeposit,
                 CASE WHEN q.crncy_code = 'MMK' THEN q.SLWithdraw 
                  ELSE q.SLWithdraw  * NVL( (SELECT r.VAR_CRNCY_UNITS 
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
                                              ),1) END AS SLWithdraw  
           from (
            select gstt.sol_id,gstt.crncy_code,
                   case when coa.group_code in ('A21') then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as DLDeposit,
                   case when coa.group_code in ('A21') then  (gstt.TOT_cash_cR_AMT + gstt.TOT_xfer_cR_AMT + gstt.TOT_clg_cR_AMT) else 0 end as DLWithdraw,
                   case when coa.group_code in ('A22') then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT)  else 0 end as  TFDeposit,
                   case when coa.group_code in ('A22') then  (gstt.TOT_cash_cR_AMT + gstt.TOT_xfer_cR_AMT + gstt.TOT_clg_cR_AMT) else 0 end as  TFWithdraw,
                   case when coa.group_code in ('A23') then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) else 0 end as ODOpeningBalDeposit,
                   case when coa.group_code in ('A23') then  (gstt.TOT_cash_cR_AMT + gstt.TOT_xfer_cR_AMT + gstt.TOT_clg_cR_AMT) else 0 end as ODOpeningBalWithdraw,
                   case when coa.group_code in ('A24') then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT)  else 0 end as HPDeposit,
                   case when coa.group_code in ('A24') then  (gstt.TOT_cash_cR_AMT + gstt.TOT_xfer_cR_AMT + gstt.TOT_clg_cR_AMT) else 0 end as HPWithdraw,
                   case when coa.group_code in ('A25') then  (gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT)  else 0 end as SLDeposit,
                   case when coa.group_code in ('A25') then  (gstt.TOT_cash_cR_AMT + gstt.TOT_xfer_cR_AMT + gstt.TOT_clg_cR_AMT) else 0 end as SLWithdraw

            from   tbaadm.gstt gstt, custom.coa_mp coa
            where   gstt.gl_sub_head_code = coa.gl_sub_head_code
            and     gstt.crncy_code = coa.cur
            and     gstt.del_flg = 'N' 
            and     coa.group_code in ('A21','A22','A23','A24','A25')
            and     gstt.bal_date =  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
           -- and     gstt.end_bal_date >=  TO_DATE( ci_Tran_date, 'dd-MM-yyyy' )
            )q
          )t
          group by t.sol_id
    )a   
  group by a.sol_id)two
  on  sol.sol_id = two.sol_id
  where sol.sol_id not in ('10100','101','20100')
  and two.sol_id is not null
  order by sol.sol_id;
         
  PROCEDURE FIN_DAILY_POSI_TOTAL_LOAN(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS 
      
      Sol_Id tbaadm.sol.sol_id%type;
      Sol_Desc TBAADM.sol.sol_desc%type;
      DLBFAccountBalance      Number(20,2);
      TFBFAccountBalance      Number(20,2);
      ODBFAccountBalance      Number(20,2);
      HPBFAccountBalance      Number(20,2);
      SLBFAccountBalance      Number(20,2);
       --open
      DLOpenAccount      Number(20,2);
      TFOpenAccount      Number(20,2);
      ODOpenAccount      Number(20,2);
      HPOpenAccount      Number(20,2);
      SLOpenAccount      Number(20,2);
       --close
      DLCloseAccount      Number(20,2);
      TFCloseAccount      Number(20,2);
      ODCloseAccount      Number(20,2);
      HPCloseAccount      Number(20,2);
      SLCloseAccount      Number(20,2);
     --fcy mmk total
      DLTotalMMK      Number(20,2);
      DLTotalFCY      Number(20,2);
      TFTotalMMK      Number(20,2);
      TFTotalFCY      Number(20,2);
      ODTotalMMK      Number(20,2);
      ODTotalFCY      Number(20,2);
      HPTotalMMK      Number(20,2);
      HPTotalFCY      Number(20,2);
      SLTotalMMK      Number(20,2);
      SLTotalFCY      Number(20,2);
       --open bal
       DLOpeningBal      Number(20,2);
       TFOpeningBal      Number(20,2);
       ODOpeningBal      Number(20,2);
       HPOpeningBal      Number(20,2);
       SLOpeningBal      Number(20,2);
       
       DLClosingBal      Number(20,2);
       TFClosingBal      Number(20,2);
       ODClosingBal      Number(20,2);
       HPClosingBal      Number(20,2);
       SLClosingBal      Number(20,2);
       
        --deposit withdrawal
       DLDeposit              Number(20,2);
       DLWithdraw             Number(20,2);
       TFDeposit              Number(20,2);
       TFWithdraw             Number(20,2);
       ODOpeningBalDeposit    Number(20,2);
       ODOpeningBalWithdraw   Number(20,2);
       HPDeposit              Number(20,2);
       HPWithdraw             Number(20,2);
       SLDeposit              Number(20,2);
       SLWithdraw             Number(20,2);
      
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
      DLBFAccountBalance      ,
      TFBFAccountBalance      ,
      ODBFAccountBalance      ,
      HPBFAccountBalance      ,
      SLBFAccountBalance      ,
       --open
      DLOpenAccount      ,
      TFOpenAccount      ,
      ODOpenAccount      ,
      HPOpenAccount      ,
      SLOpenAccount      ,
       --close
      DLCloseAccount      ,
      TFCloseAccount      ,
      ODCloseAccount      ,
      HPCloseAccount      ,
      SLCloseAccount      ,
     --fcy mmk total
      DLTotalMMK      ,
      DLTotalFCY      ,
      TFTotalMMK      ,
      TFTotalFCY      ,
      ODTotalMMK      ,
      ODTotalFCY      ,
      HPTotalMMK      ,
      HPTotalFCY      ,
      SLTotalMMK      ,
      SLTotalFCY      ,
       --open bal
       DLOpeningBal      ,
       TFOpeningBal      ,
       ODOpeningBal      ,
       HPOpeningBal      ,
       SLOpeningBal      ,
       
       DLClosingBal,
       TFClosingBal,
       ODClosingBal,
       HPClosingBal,
       SLClosingBal,
        --deposit withdrawal
       DLDeposit              ,
       DLWithdraw             ,
       TFDeposit              ,
       TFWithdraw             ,
       ODOpeningBalDeposit    ,
       ODOpeningBalWithdraw   ,
       HPDeposit              ,
       HPWithdraw             ,
       SLDeposit              ,
       SLWithdraw             ;
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


    out_rec:=	(  Sol_Id    ||'|'||
                Sol_Desc   ||'|'|| 
      DLBFAccountBalance      ||'|'||
      TFBFAccountBalance      ||'|'||
      ODBFAccountBalance      ||'|'||
      HPBFAccountBalance      ||'|'||
      SLBFAccountBalance      ||'|'||
       --open
      DLOpenAccount      ||'|'||
      TFOpenAccount      ||'|'||
      ODOpenAccount      ||'|'||
      HPOpenAccount      ||'|'||
      SLOpenAccount      ||'|'||
       --close
      DLCloseAccount      ||'|'||
      TFCloseAccount      ||'|'||
      ODCloseAccount      ||'|'||
      HPCloseAccount      ||'|'||
      SLCloseAccount      ||'|'||
     --fcy mmk total
      DLTotalMMK      ||'|'||
      DLTotalFCY      ||'|'||
      TFTotalMMK      ||'|'||
      TFTotalFCY      ||'|'||
      ODTotalMMK      ||'|'||
      ODTotalFCY      ||'|'||
      HPTotalMMK      ||'|'||
      HPTotalFCY      ||'|'||
      SLTotalMMK      ||'|'||
      SLTotalFCY      ||'|'||
       --open bal
       DLOpeningBal      ||'|'||
       TFOpeningBal      ||'|'||
       ODOpeningBal      ||'|'||
       HPOpeningBal      ||'|'||
       SLOpeningBal      ||'|'||
       
        --deposit withdrawal
       DLDeposit              ||'|'||
       DLWithdraw             ||'|'||
       TFDeposit              ||'|'||
       TFWithdraw             ||'|'||
       ODOpeningBalDeposit    ||'|'||
       ODOpeningBalWithdraw   ||'|'||
       HPDeposit              ||'|'||
       HPWithdraw             ||'|'||
       SLDeposit              ||'|'||
       SLWithdraw               ||'|'||      
       
       DLClosingBal              ||'|'||
       TFClosingBal              ||'|'||
       ODClosingBal              ||'|'||
       HPClosingBal              ||'|'||
       SLClosingBal
 );
    
      dbms_output.put_line(out_rec);
  END FIN_DAILY_POSI_TOTAL_LOAN;

END FIN_DAILY_POSI_TOTAL_LOAN;
/
