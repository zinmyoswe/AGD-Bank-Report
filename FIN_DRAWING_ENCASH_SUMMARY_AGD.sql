CREATE OR REPLACE PACKAGE        FIN_DRAWING_ENCASH_SUMMARY_AGD AS 
PROCEDURE FIN_DRAWING_ENCASH_SUMMARY_AGD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DRAWING_ENCASH_SUMMARY_AGD;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                               FIN_DRAWING_ENCASH_SUMMARY_AGD AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_BranchCode		Varchar2(30);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractData(ci_TranDate Varchar2,ci_BranchCode  Varchar2)
IS
select sol.sol_desc,
        Drawing.Drawing_id as Drawing_id,
        Drawing.Drawing_Amount as Drawing_Amount,
        (nvl(Encash_Other_sol.Encash_id,0) + (nvl(Encash_IBD.Encash_id,0))) as Encash_id,
        (nvl(Encash_Other_sol.Encash_Amount,0) + (nvl(Encash_IBD.Encash_Amount,0))) as Encash_Amount,
        (nvl(Encash_Outstanding.Encash_id,0) + nvl(Encash_Outstanding_OP.Encash_id,0))  as Encash_Outstanding_id,
        (nvl(Encash_Outstanding.Encash_Amount,0) + nvl(Encash_Outstanding_OP.Encash_Amount,0)) as Encash_Outstanding_Amount,
        Encash_Withdrawal.Encash_id as Encash_Withdrawal_id,
        Encash_Withdrawal.Encash_Amount as Encash_Withdrawal_Amount,
        Encash_Outstanding_OP.Encash_id as Encash_Outstanding_id,
        Encash_Outstanding_OP.Encash_Amount as Encash_Outstanding_Amount
  from
  (select sol.micr_branch_code,sol.sol_desc,sol.sol_id
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      order by sol.sol_desc) sol
left join
(select 
      count(q.Drawing_id) as Drawing_id,
      q.bank_code,q.br_code,
      sum(q.Drawing_amt) as Drawing_Amount 
      from
      ( select 
      case when ctd.tran_sub_type = 'RI' or ctd.tran_sub_type = 'CI' then ctd.tran_id else '' end as Drawing_id,
      bct.bank_code,bct.br_code,
      case when ctd.tran_sub_type = 'RI' or ctd.tran_sub_type = 'CI' then ctd.tran_amt else 0 end as Drawing_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
   ctd.tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
    and  ctd.rpt_code  in ('REMIT','REMIB')
    and ctd.bank_code = '116'
    and ctd.dth_init_sol_id = ci_BranchCode 
    and ctd.dth_init_sol_id !='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) )
        
     union all
      select 
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'RI'  then ctd.tran_id else '' end as Drawing_id,
      bct.bank_code,bct.br_code,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'RI' then ctd.tran_amt else 0 end as Drawing_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
   ctd.tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
    and  ctd.rpt_code  in ('REMIT','REMIB')
    and ctd.bank_code = '116'
    and ctd.dth_init_sol_id = ci_BranchCode 
    and ctd.dth_init_sol_id ='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) ))q 
    group by q.bank_code,q.br_code) Drawing
    on sol.micr_branch_code = Drawing.br_code
    
    Left join
 ( SELECT count(q.Encash_id) as Encash_id,
          q.sol_id,
          sum(q.Encash_Amount) as Encash_Amount
  FROM (
  select  CTD_DTD_ACLI_VIEW.tran_id  as Encash_id,
          CTD_DTD_ACLI_VIEW.dth_init_sol_id as sol_id,
           CTD_DTD_ACLI_VIEW.TRAN_AMT as Encash_Amount
            
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
           custom.custom_CTH_DTH_VIEW CTH_DTH_VIEW   , tbaadm.bct bct ,tbaadm.sol sol
        where
           TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
           and CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
           and CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and bct.bank_code = CTD_DTD_ACLI_VIEW.bank_code
           and bct.br_code = CTD_DTD_ACLI_VIEW.branch_code
           and sol.sol_id = CTD_DTD_ACLI_VIEW.dth_init_sol_id
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.branch_code = (select sol.micr_branch_code
                                                from tbaadm.sol sol ,tbaadm.bct bct
                                                where sol.micr_branch_code = CTD_DTD_ACLI_VIEW.branch_code 
                                                and sol.bank_code = CTD_DTD_ACLI_VIEW.bank_code
                                                and sol.micr_branch_code = bct.br_code
                                                and sol.bank_code = bct.bank_code
                                                and sol.bank_code ='116'
                                                and substr(bct.br_short_name,1,3) =sol.abbr_br_name
                                                and sol.sol_id = ci_BranchCode
                                                and sol.sol_id !='20300')
           and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI'
           and CTH_DTH_VIEW.TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) ))q
       group by q.sol_id) Encash_Other_sol
  on sol.sol_id = Encash_Other_sol.sol_id
  left join
  (SELECT count(q.Encash_id) as Encash_id,
          q.bank_code,q.br_code,
          sum(q.Encash_Amount) as Encash_Amount
  from
  (SELECT 
       CTD_DTD_ACLI_VIEW.tran_id  as Encash_id,
       bct.bank_code,bct.br_code,
       CTD_DTD_ACLI_VIEW.TRAN_AMT as Encash_Amount
       
   FROM
       custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
       custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW,
       TBAADM.BRANCH_CODE_TABLE bct ,
       tbaadm.BANK_CODE_TABLE bank

    WHERE
       
       TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
       AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
       AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       AND CTH_DTH_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
       and CTD_DTD_ACLI_VIEW.bank_code ='116'
       AND  CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID  = ci_BranchCode 
       and CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID  != '20300'
       AND CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIB','REMIT')
        and CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE = 'BI'
        and CTD_DTD_ACLI_VIEW.uad_module_key is not null
        and CTD_DTD_ACLI_VIEW.uad_module_id is not null
        and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ))
                                                  
    
       AND bct.BANK_CODE  = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bct.BR_CODE   = CTD_DTD_ACLI_VIEW.Branch_Code
       AND bank.BANK_CODE = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bank.DEL_FLG = 'N'
       AND bank.BANK_ID = '01') q
   group by q.bank_code,q.br_code) Encash_IBD
on sol.micr_branch_code = Encash_IBD.br_code
left join
(select 
      count(q.TRAN_ID) as Encash_id,
      q.dth_init_sol_id,
      sum(q.TRAN_AMT) as Encash_Amount 
      from
      (select 
           CTD_DTD_ACLI_VIEW.TRAN_ID , 
           ctd_dtd_acli_view.dth_init_sol_id,
           CTD_DTD_ACLI_VIEW.TRAN_AMT 
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
        where CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and CTD_DTD_ACLI_VIEW.branch_code = (select sol.micr_branch_code
                                                from tbaadm.sol sol ,tbaadm.bct bct
                                                where sol.micr_branch_code = CTD_DTD_ACLI_VIEW.branch_code 
                                                and sol.bank_code = CTD_DTD_ACLI_VIEW.bank_code
                                                and sol.micr_branch_code = bct.br_code
                                                and sol.bank_code = bct.bank_code
                                                and sol.bank_code ='116'
                                                and substr(bct.br_short_name,1,3) =sol.abbr_br_name
                                                and sol.sol_id = ci_BranchCode 
                                                and sol.sol_id !='20300')
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type in ('RI','CI')
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           AND (TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID),CTD_DTD_ACLI_VIEW.Tran_date) NOT IN(SELECT TRIM(T.TRAN_ID),t.Tran_date
                                                      FROM TBAADM.TCT T
                                                      WHERE ENTITY_CRE_FLG = 'Y' 
                                                      AND DEL_FLG = 'N'
                                                      and T.TRAN_DATE = TO_DATE( ci_TranDate , 'dd-MM-yyyy' ))
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date = TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) )
      )q 
    group by q.dth_init_sol_id) Encash_Outstanding
    on sol.sol_id = Encash_Outstanding.dth_init_sol_id
 left join
 (select 
      count(q.Encash_id) as Encash_id,
      q.br_code,
      sum(q.Encash_Amount) as Encash_Amount
  from
 (SELECT TCT.CONTRA_TRAN_ID AS Encash_id,
         (select bct.br_code 
          from CUSTOM.custom_ctd_dtd_acli_view cdav , tbaadm.bct bct
          where trim(cdav.tran_id) =trim(tct.contra_tran_id) 
          and cdav.branch_code= bct.br_code and rownum = 1
          and cdav.bank_code = bct.bank_code
          and cdav.tran_date= tct.contra_tran_date
          and cdav.part_tran_type= 'D') as br_code,
              TCT.AMT_OFFSET AS Encash_Amount
       FROM TBAADM.TCT TCT , custom.custom_CTH_DTH_VIEW CTH
       WHERE TCT.ENTITY_CRE_FLG = 'Y'
       AND TCT.DEL_FLG = 'N'
       AND trim(TCT.CONTRA_TRAN_ID)= trim(CTH.TRAN_ID)
       and TCT.CONTRA_TRAN_DATE =TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
       AND  TCT.sol_id  = ci_BranchCode 
       and tct.contra_tran_date = cth.tran_date
       and tct.sol_id = CTH.init_sol_id 
       AND (trim(TCT.CONTRA_TRAN_ID),TCT.contra_tran_date)  in (select trim(TRAN_ID),Tran_date
                                                 from TBAADM.CTD_DTD_ACLI_VIEW
                                                 where Tran_Date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
                                                 and DTH_INIT_SOL_ID = ci_BranchCode 
                                                 and bank_code ='116'
                                                 and DEL_FLG = 'N' 
                                                 and PSTD_FLG = 'Y')
         AND (trim(TCT.TRAN_ID),TCT.tran_date,trim(tct.part_tran_srl_num)  )
       in (select trim(cdav.TRAN_ID),cdav.Tran_date,trim(cdav.part_tran_srl_num)
                                                 from TBAADM.CTD_DTD_ACLI_VIEW cdav
                                                 where --cdav.rpt_code in ( 'REMIT','IBREM')
                                                    bank_code is not null
                                                 and  branch_code is not null
                                                 and cdav.bank_code ='116'
                                                 and cdav.DEL_FLG = 'N' 
                                                 and cdav.PSTD_FLG = 'Y')
         AND (trim(TCT.contra_TRAN_ID),TCT.contra_tran_date,trim(tct.contra_part_tran_srl_num)  )
       not in (select trim(atd.cont_tran_id),atd.cont_tran_date,trim(atd.cont_part_tran_srl_num)
                                                 from TBAADM.atd atd
                                                 where atd.cont_tran_date =TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
                                                )   )q
        group by q.br_code) Encash_Withdrawal
  on sol.micr_branch_code = Encash_Withdrawal.br_code
left join
(select 
      count(q.TRAN_ID) as Encash_id,
      q.dth_init_sol_id,
      sum(q.TRAN_AMT) as Encash_Amount 
      from
      (select 
           CTD_DTD_ACLI_VIEW.TRAN_ID , 
           ctd_dtd_acli_view.dth_init_sol_id,
           CTD_DTD_ACLI_VIEW.TRAN_AMT 
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
        where CTD_DTD_ACLI_VIEW.TRAN_DATE < TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and CTD_DTD_ACLI_VIEW.branch_code = (select sol.micr_branch_code
                                                from tbaadm.sol sol ,tbaadm.bct bct
                                                where sol.micr_branch_code = CTD_DTD_ACLI_VIEW.branch_code 
                                                and sol.bank_code = CTD_DTD_ACLI_VIEW.bank_code
                                                and sol.micr_branch_code = bct.br_code
                                                and sol.bank_code = bct.bank_code
                                                and sol.bank_code ='116'
                                                and substr(bct.br_short_name,1,3) =sol.abbr_br_name
                                                and sol.sol_id = ci_BranchCode 
                                                and sol.sol_id !='20300')
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type in ('RI','CI')
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           AND (TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID),CTD_DTD_ACLI_VIEW.Tran_date) NOT IN(SELECT TRIM(T.TRAN_ID),t.Tran_date
                                                      FROM TBAADM.TCT T
                                                      WHERE ENTITY_CRE_FLG = 'Y' 
                                                      AND DEL_FLG = 'N'
                                                      and T.TRAN_DATE < TO_DATE( ci_TranDate , 'dd-MM-yyyy' ))
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date < TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) )
      )q 
    group by q.dth_init_sol_id) Encash_Outstanding_OP
    on sol.sol_id = Encash_Outstanding_OP.dth_init_sol_id
order by sol.sol_desc;
----------------------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataAll(ci_TranDate Varchar2,ci_BranchCode  Varchar2)
IS
select 'All Branch' as sol_desc,
        Drawing.Drawing_id as Drawing_id,
        Drawing.Drawing_Amount as Drawing_Amount,
        (nvl(Encash_Other_sol.Encash_id,0) + (nvl(Encash_IBD.Encash_id,0))) as Encash_id,
        (nvl(Encash_Other_sol.Encash_Amount,0) + (nvl(Encash_IBD.Encash_Amount,0))) as Encash_Amount,
        (nvl(Encash_Outstanding.Encash_id,0) + nvl(Encash_Outstanding_OP.Encash_Count,0))  as Encash_Outstanding_id,
        (nvl(Encash_Outstanding.Encash_Amount,0) + nvl(Encash_Outstanding_OP.Encash_Amt,0)) as Encash_Outstanding_Amount,
        Encash_Withdrawal.Encash_id as Encash_Withdrawal_id,
        Encash_Withdrawal.Encash_Amount as Encash_Withdrawal_Amount,
        Encash_Outstanding_OP.Encash_Count as Encash_Outstanding_id,
        Encash_Outstanding_OP.Encash_Amt as Encash_Outstanding_Amount
  from
(select 
      count(q.Drawing_id) as Drawing_id,
      sum(q.Drawing_amt) as Drawing_Amount ,'t' as temp
      from
      ( select 
      case when ctd.tran_sub_type = 'RI' or ctd.tran_sub_type = 'CI' then ctd.tran_id else '' end as Drawing_id,
      case when ctd.tran_sub_type = 'RI' or ctd.tran_sub_type = 'CI' then ctd.tran_amt else 0 end as Drawing_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
   ctd.tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
    and  ctd.rpt_code  in ('REMIT','REMIB')
    and ctd.bank_code = '116'
    and ctd.dth_init_sol_id !='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) )
        
     union all
      select 
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'RI'  then ctd.tran_id else '' end as Drawing_id,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'RI' then ctd.tran_amt else 0 end as Drawing_amt
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct
where
   ctd.tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
    and  ctd.rpt_code  in ('REMIT','REMIB')
    and ctd.bank_code = '116'
    and ctd.dth_init_sol_id ='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.uad_module_key is not null
    and ctd.uad_module_id is not null
    and (trim (ctd.tran_id),ctd.tran_date) NOT IN (select trim(CONT_TRAN_ID),atd.cont_tran_date from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) ))q) Drawing
    
    Left join
 ( SELECT count(q.Encash_id) as Encash_id,
          sum(q.Encash_Amount) as Encash_Amount,'t' as temp
  FROM (
  select  CTD_DTD_ACLI_VIEW.tran_id  as Encash_id,
           CTD_DTD_ACLI_VIEW.TRAN_AMT as Encash_Amount
            
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
           custom.custom_CTH_DTH_VIEW CTH_DTH_VIEW   , tbaadm.bct bct ,tbaadm.sol sol
        where
           TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
           and CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
           and CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and bct.bank_code = CTD_DTD_ACLI_VIEW.bank_code
           and bct.br_code = CTD_DTD_ACLI_VIEW.branch_code
           and sol.sol_id = CTD_DTD_ACLI_VIEW.dth_init_sol_id
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type ='RI'
           and CTH_DTH_VIEW.TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) ))q) Encash_Other_sol
  on Drawing.temp = Encash_Other_sol.temp
  left join
  (SELECT count(q.Encash_id) as Encash_id,
          sum(q.Encash_Amount) as Encash_Amount,'t' as temp
  from
  (SELECT 
       CTD_DTD_ACLI_VIEW.tran_id  as Encash_id,
       CTD_DTD_ACLI_VIEW.TRAN_AMT as Encash_Amount
       
   FROM
       custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
       custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW,
       TBAADM.BRANCH_CODE_TABLE bct ,
       tbaadm.BANK_CODE_TABLE bank

    WHERE
       
       TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID) = trim(CTH_DTH_VIEW.TRAN_ID)
       AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
       AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
       AND CTH_DTH_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
       and CTD_DTD_ACLI_VIEW.bank_code ='116'
       and CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID  != '20300'
       AND CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIB','REMIT')
        and CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE = 'BI'
        and CTD_DTD_ACLI_VIEW.uad_module_key is not null
        and CTD_DTD_ACLI_VIEW.uad_module_id is not null
        and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ))
                                                  
    
       AND bct.BANK_CODE  = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bct.BR_CODE   = CTD_DTD_ACLI_VIEW.Branch_Code
       AND bank.BANK_CODE = CTD_DTD_ACLI_VIEW.Bank_Code
       AND bank.DEL_FLG = 'N'
       AND bank.BANK_ID = '01') q) Encash_IBD
on Drawing.temp = Encash_IBD.temp
left join
(select 
      count(q.TRAN_ID) as Encash_id,
      sum(q.TRAN_AMT) as Encash_Amount ,'t' as temp
      from
      (select 
           CTD_DTD_ACLI_VIEW.TRAN_ID , 
           CTD_DTD_ACLI_VIEW.TRAN_AMT 
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
        where CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE(ci_TranDate, 'dd-MM-yyyy' )
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           AND CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.tran_sub_type in ('RI','CI')
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null
           AND (TRIM(CTD_DTD_ACLI_VIEW.TRAN_ID),CTD_DTD_ACLI_VIEW.Tran_date) NOT IN(SELECT TRIM(T.TRAN_ID),t.Tran_date
                                                      FROM TBAADM.TCT T
                                                      WHERE ENTITY_CRE_FLG = 'Y' 
                                                      AND DEL_FLG = 'N'
                                                      and T.TRAN_DATE = TO_DATE( ci_TranDate , 'dd-MM-yyyy' ))
           and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                      (select trim(CONT_TRAN_ID),cont_tran_date 
                                                      from TBAADM.ATD atd 
                                                      where cont_tran_date = TO_DATE(ci_TranDate , 'dd-MM-yyyy' ) )
      )q ) Encash_Outstanding
    on Drawing.temp = Encash_Outstanding.temp
 left join
 (select 
      count(q.Encash_id) as Encash_id,
      sum(q.Encash_Amount) as Encash_Amount,'t' as temp
  from
 (SELECT TCT.CONTRA_TRAN_ID AS Encash_id,
              TCT.AMT_OFFSET AS Encash_Amount
       FROM TBAADM.TCT TCT , custom.custom_CTH_DTH_VIEW CTH
       WHERE TCT.ENTITY_CRE_FLG = 'Y'
       AND TCT.DEL_FLG = 'N'
       AND trim(TCT.CONTRA_TRAN_ID)= trim(CTH.TRAN_ID)
       and TCT.CONTRA_TRAN_DATE =TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
       and tct.contra_tran_date = cth.tran_date
       and tct.sol_id = CTH.init_sol_id 
       AND (trim(TCT.CONTRA_TRAN_ID),TCT.contra_tran_date)  in (select trim(TRAN_ID),Tran_date
                                                 from TBAADM.CTD_DTD_ACLI_VIEW
                                                 where Tran_Date = TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
                                                 and bank_code ='116'
                                                 --and tran_sub_type not in( 'NR','BI')
                                                 and DEL_FLG = 'N' 
                                                 and PSTD_FLG = 'Y')
         AND (trim(TCT.TRAN_ID),TCT.tran_date,trim(tct.part_tran_srl_num)  )
       in (select trim(cdav.TRAN_ID),cdav.Tran_date,trim(cdav.part_tran_srl_num)
                                                 from TBAADM.CTD_DTD_ACLI_VIEW cdav
                                                 where --cdav.rpt_code in ( 'REMIT','IBREM')
                                                    bank_code is not null
                                                 and  branch_code is not null
                                                 and cdav.bank_code ='116'
                                                 and cdav.DEL_FLG = 'N' 
                                                 and cdav.PSTD_FLG = 'Y')
       AND (trim(TCT.contra_TRAN_ID),TCT.contra_tran_date,trim(tct.contra_part_tran_srl_num)  )
       not in (select trim(atd.cont_tran_id),atd.cont_tran_date,trim(atd.cont_part_tran_srl_num)
                                                 from TBAADM.atd atd
                                                 where atd.cont_tran_date =TO_DATE(ci_TranDate, 'dd-MM-yyyy' ) 
                                                ))q) Encash_Withdrawal
  on Drawing.temp = Encash_Withdrawal.temp
left join
--Encash
(select ((Encash.Encash_id-Reversal.Encash_id)- (Withdrawal.Encash_id-Reversal.Encash_id)) as Encash_Count,
       ((Encash.Encash_Amount-Reversal.Encash_Amount)- (Withdrawal.Encash_Amount-Reversal.Encash_Amount)) as Encash_Amt,'t' as temp
from 
(select 
      count(q.Encash_id) as Encash_id,
      sum(q.Encash_amt) as Encash_Amount,'t' as temp 
      from
      (select 
           case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then CTD_DTD_ACLI_VIEW.TRAN_ID else '' end as Encash_id ,
           case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then CTD_DTD_ACLI_VIEW.TRAN_AMT else 0 end as Encash_amt
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
        where CTD_DTD_ACLI_VIEW.tran_date < TO_DATE(ci_TranDate,'dd-MM-yyyy' ) 
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.branch_code is not null
           and CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null)q group by 't') Encash
left join         
-- Reversal
(select 
      count(q.Encash_id) as Encash_id,
      sum(q.Encash_amt) as Encash_Amount,'t' as temp 
      from
      (select 
           case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then CTD_DTD_ACLI_VIEW.TRAN_ID else '' end as Encash_id , 
           case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then CTD_DTD_ACLI_VIEW.TRAN_AMT else 0 end as Encash_amt
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,TBAADM.ATD atd
        where CTD_DTD_ACLI_VIEW.tran_date < TO_DATE(ci_TranDate,'dd-MM-yyyy' ) 
        and CTD_DTD_ACLI_VIEW.tran_date = atd.cont_tran_date
        and CTD_DTD_ACLI_VIEW.TRAN_ID = atd.CONT_TRAN_ID
        and ctd_dtd_acli_view.part_tran_srl_num = atd.cont_part_tran_srl_num
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.branch_code is not null
           and CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and atd.reversal_flg ='R'
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null)q group by 't') Reversal
on Encash.temp =Reversal.temp
left join          
--Withdrawal, Reversal to subtract 
(select 
      count (q.Encash_id) as Encash_id,
      sum(q.Encash_amt) as Encash_Amount,'t' as temp 
      from
      (select --CTD_DTD_ACLI_VIEW.tran_id,CTD_DTD_ACLI_VIEW.tran_amt,CTD_DTD_ACLI_VIEW.tran_date,
      case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then tct.contra_tran_id else '' end as Encash_id,
          case when CTD_DTD_ACLI_VIEW.tran_sub_type = 'RI' or CTD_DTD_ACLI_VIEW.tran_sub_type ='CI' then tct.amt_offset else 0 end as Encash_amt
        from 
           custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,tbaadm.tct tct
        where CTD_DTD_ACLI_VIEW.tran_date < TO_DATE(ci_TranDate,'dd-MM-yyyy' ) 
        and CTD_DTD_ACLI_VIEW.tran_id = tct.tran_id 
        and CTD_DTD_ACLI_VIEW.tran_date = tct.tran_date
        and ctd_dtd_acli_view.part_tran_srl_num = tct.part_tran_srl_num
           and CTD_DTD_ACLI_VIEW.bank_code ='116'
           and CTD_DTD_ACLI_VIEW.branch_code !='203'
           and CTD_DTD_ACLI_VIEW.branch_code is not null
           and CTD_DTD_ACLI_VIEW.RPT_CODE  = 'REMIT'
           and CTD_DTD_ACLI_VIEW.uad_module_key is not null
          and CTD_DTD_ACLI_VIEW.uad_module_id is not null)q group by 't') Withdrawal
on Encash.temp =Withdrawal.temp) Encash_Outstanding_OP
on Drawing.temp = Encash_Outstanding_OP.temp;
----------------------------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE FIN_DRAWING_ENCASH_SUMMARY_AGD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
        v_sol_desc tbaadm.sol.sol_desc%type;
        v_Drawing_id Number;
        v_Drawing_Amount CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
        v_Encash_id Number;
        v_Encash_Amount CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
        v_Encash_Outstanding_id Number;
        v_Encash_Outstanding_Amount CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
        v_Encash_Withdrawal_id Number;
        v_Encash_Withdrawal_Amount CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
        v_Encash_Outstanding_OP_id Number;
        v_Encash_Outstanding_OP_Amount CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
        v_BranchName tbaadm.sol.sol_desc%type;
     
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
     vi_BranchCode :=outArr(1);
    
   
    -------------------------------------------------------------------------------------
    if( vi_TranDate is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    
    
    ------------------------------------------------------------------------------------
    IF vi_BranchCode IS not NULL then
     IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData (vi_TranDate,vi_BranchCode );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  v_sol_desc,v_Drawing_id,v_Drawing_Amount,v_Encash_id,
        v_Encash_Amount,v_Encash_Outstanding_id,v_Encash_Outstanding_Amount,v_Encash_Withdrawal_id,
        v_Encash_Withdrawal_Amount,v_Encash_Outstanding_OP_id,v_Encash_Outstanding_OP_Amount;
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
  Else
    IF NOT ExtractDataAll%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataAll (vi_TranDate,vi_BranchCode );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataAll%ISOPEN THEN
        --{
          FETCH	ExtractDataAll
          INTO  v_sol_desc,v_Drawing_id,v_Drawing_Amount,v_Encash_id,
        v_Encash_Amount,v_Encash_Outstanding_id,v_Encash_Outstanding_Amount,v_Encash_Withdrawal_id,
        v_Encash_Withdrawal_Amount,v_Encash_Outstanding_OP_id,v_Encash_Outstanding_OP_Amount;
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
  end if;
       If  vi_BranchCode is not null then
        SELECT sol.sol_desc
   into v_BranchName
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   end if;
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (  v_sol_desc || '|' ||
                 v_Drawing_id|| '|' || 
                 v_Drawing_Amount|| '|' || 
                 v_Encash_id|| '|' || 
        v_Encash_Amount|| '|' || 
        v_Encash_Outstanding_id|| '|' || 
        v_Encash_Outstanding_Amount|| '|' || 
        v_Encash_Withdrawal_id|| '|' || 
        v_Encash_Withdrawal_Amount|| '|' || 
        v_Encash_Outstanding_OP_id|| '|' || 
        v_Encash_Outstanding_OP_Amount || '|' || 
        v_BranchName
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_DRAWING_ENCASH_SUMMARY_AGD;

END FIN_DRAWING_ENCASH_SUMMARY_AGD;
/
