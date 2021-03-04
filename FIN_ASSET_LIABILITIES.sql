CREATE OR REPLACE PACKAGE                                                                       FIN_ASSET_LIABILITIES
AS
PROCEDURE FIN_ASSET_LIABILITIES(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_ASSET_LIABILITIES;
/


CREATE OR REPLACE PACKAGE BODY                             FIN_ASSET_LIABILITIES
AS
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  v_startDate    VARCHAR2(10);         -- Input to procedure
  v_endDate      VARCHAR2(10);         -- Input to procedure
  v_BranchCode   VARCHAR2(7);          -- Input to procedure
  v_CurrencyCode VARCHAR2(5);          -- Input to procedure
  v_CurrencyType VARCHAR2(20);         -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractDataWithoutHOWithMMK(Include BranchCode)
  -----------------------------------------------------------------------------
  CURSOR ExtractWithoutHOMMK ( ci_startDate VARCHAR2,ci_endDate VARCHAR2,ci_BranchCode VARCHAR2,ci_CurrencyCode VARCHAR2)
  IS
    select T.acct_name,
  T.foracid,
  T.group_code,
  T.gl_sub_head_code,
  T.Transfer_Dr_Amt,
  T.Transfer_Cr_Amt,T.Cash_Dr_Amt,
  T.Cash_Cr_Amt,
  T.Clearing_Dr_Amt,
  T.Clearing_Cr_Amt,
  T.Opening_amount
  from
  (
  select  q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code,
          SUM(q.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(q.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(q.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(q.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(q.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(q.Clearing_Cr_Amt) as Clearing_Cr_Amt,
          SUM(q.Opening_amount) as Opening_amount
 from(select x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt,
          x.Opening_amount as Opening_amount
    from
   (SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid, 
              coa.group_code,gam.gl_sub_head_code,gam.acid,
            cdav.tran_crncy_code AS cur,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt,
                (select sum(eab.tran_date_bal) 
        from tbaadm.eab
        where gam.acid = eab.acid
        and eab.eod_date =(select max(eab.eod_date)
                          from tbaadm.eab eab
                          where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                          and gam.acid = eab.acid
                          and gam.acct_crncy_code = eab.eab_crncy_code
                          and gam.acct_crncy_code = upper(ci_CurrencyCode))
                          --group by coa.group_code
                          --order by eod_date desc )
        and gam.acct_crncy_code = eab.eab_crncy_code
        and gam.acct_crncy_code = upper(ci_CurrencyCode)) as Opening_amount
from  
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
--   and eab.eod_date 
   AND cdav.SOL_ID         like '%' || ci_BranchCode || '%'
   and gam.SOL_ID like   '%' || ci_BranchCode || '%'
   
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and gam.BANK_ID = '01' 
  -- and eab.bank_id = '01'
   and cdav.bank_id ='01'
   and coa.cur =  upper(ci_CurrencyCode)
   and gam.acct_crncy_code = upper(ci_CurrencyCode)
   --and eab.eab_crncy_code = upper('MMK')
   and cdav.tran_crncy_code =upper(ci_CurrencyCode)
   --and gam.acct_cls_flg = 'N'
   --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
   and gam.acid = cdav.acid
   --and coa.group_code in ('L17')
   and gam.schm_type in ('OAB','OAP','OAD','DDA')
   --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
         -- where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
         -- and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  union all
    SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
              coa.group_code,gam.gl_sub_head_code,gam.acid,
            gam.acct_crncy_code AS cur,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt,
           (select sum(eab.tran_date_bal) 
        from tbaadm.eab
        where gam.acid = eab.acid
        and eab.eod_date =(select max(eab.eod_date)
                          from tbaadm.eab eab
                          where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                          and gam.acid = eab.acid
                          and gam.acct_crncy_code = eab.eab_crncy_code
                          and gam.acct_crncy_code = upper(ci_CurrencyCode)
        --order by eod_date desc
        )
        and gam.acct_crncy_code = eab.eab_crncy_code
        and gam.acct_crncy_code = upper(ci_CurrencyCode)) as Opening_amount
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                            from tbaadm.eab eab
                            where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                            and gam.acid =eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode || '%'
          AND eab.eab_crncy_code = upper(ci_CurrencyCode)
          and gam.acct_crncy_code = upper(ci_CurrencyCode)
          and coa.cur = upper(ci_CurrencyCode)
          and gam.acid = eab.acid
         and gam.schm_type in ('OAB','OAP','OAD','DDA')
         and gam.acct_ownership not in ('C','E')
         --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              --   and eab.eod_date 
                              AND cdav.SOL_ID         like '%' || ci_BranchCode || '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode || '%'
   
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.Tran_date_bal <> 0
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and gam.BANK_ID = '01' 
                              -- and eab.bank_id = '01'
                              and cdav.bank_id ='01'
                              --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
                              and coa.cur =  upper(ci_CurrencyCode)
                              and gam.acct_crncy_code = upper(ci_CurrencyCode)
                              --and eab.eab_crncy_code = upper('MMK')
                              and cdav.tran_crncy_code =upper(ci_CurrencyCode)
                              --and gam.acct_cls_flg = 'N'
                              and gam.acid = cdav.acid
                              --and coa.group_code in ('L17')
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA'))
                              /*and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )*/
                              )
    )x
    group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.Opening_amount,x.acid
   union  all
   select t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.acid,
      SUM(t.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(t.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(t.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(t.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(t.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(t.Clearing_Cr_Amt) as Clearing_Cr_Amt ,
           SUM((select SUM(eab.tran_date_bal)
        from tbaadm.eab
        where t.acid = eab.acid
        and eab.eod_date =(select max(eab.eod_date)
        from tbaadm.eab eab
        where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and t.acid = eab.acid
        --order by eod_date desc
        ))) as Opening_Amount
   from
   (select  x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt
    from
(select
   coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid,
   coa.group_code,gam.gl_sub_head_code,
            cdav.tran_crncy_code AS cur,gam.acid,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt
   
   from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND cdav.SOL_ID         like '%' || ci_BranchCode || '%'
   and gam.SOL_ID like   '%' || ci_BranchCode || '%'
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.acid = gam.acid 
   and gam.acid = cdav.acid
   and coa.cur =  upper(ci_CurrencyCode)
   and gam.acct_crncy_code = upper(ci_CurrencyCode)
   --and eab.eab_crncy_code = upper('MMK')
   and cdav.tran_crncy_code =upper(ci_CurrencyCode)
   --and coa.group_code = 'L17'
   --and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and cdav.bank_id ='01'
   and gam.BANK_ID = '01'
   --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
   --and eab.bank_id = '01'
   and gam.acct_ownership in ('C','E') 
   /*and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
          where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
          and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )*/
    --group by coa.gl_sub_head_desc,gam.gl_sub_head_code,coa.group_code,gam.gl_sub_head_code,cdav.tran_crncy_code
    union all
    SELECT coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid, 
              coa.group_code,gam.gl_sub_head_code,
            gam.acct_crncy_code AS cur,gam.acid,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                            from tbaadm.eab eab
                            where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                            and gam.acid = eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode || '%'
          AND eab.eab_crncy_code = upper(ci_CurrencyCode)
          and gam.acct_crncy_code = upper(ci_CurrencyCode)
          and coa.cur = upper(ci_CurrencyCode)
          and gam.acid = eab.acid
          --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
          and gam.acct_ownership in ('C','E') 
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              AND cdav.SOL_ID         like '%' || ci_BranchCode || '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode || '%'
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.acid = gam.acid 
                              and gam.acid = cdav.acid
                              and coa.cur =  upper(ci_CurrencyCode)
                              and gam.acct_crncy_code = upper(ci_CurrencyCode)
                              --and eab.eab_crncy_code = upper('MMK')
                              and cdav.tran_crncy_code =upper(ci_CurrencyCode)
                              --and coa.group_code  ='L17'
                              --and eab.Tran_date_bal <> 0
                              --and substr(gam.foracid,6,length(gam.foracid)-5) !='10101000011'
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and cdav.bank_id ='01'
                              and gam.BANK_ID = '01'
                              --and eab.bank_id = '01'
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA')) 
                             /* and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )*/))x
          group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.acid)t
          group by t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.acid
          --order by t.group_code,t.gl_sub_head_code,t.foracid
   --group by coa.gl_sub_head_desc, gam.gl_sub_head_code, coa.group_code,gam.gl_sub_head_code,cdav.tran_amt,cdav.tran_crncy_code
   )q
   group by q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code
   )T 
   order by T.group_code,T.gl_sub_head_code,T.foracid;
    -----------------------------------------------------------------------------
    -- CURSOR ExtractDataWithoutHOWithAllCurrency
    -----------------------------------------------------------------------------
    CURSOR ExtractWithoutHOAll ( ci_startDate VARCHAR2,ci_endDate VARCHAR2,ci_BranchCode VARCHAR2)
    IS
      select T.acct_name,
  T.foracid,
  T.group_code,
  T.gl_sub_head_code,
  SUM(T.Transfer_Dr_Amt),
  SUM(T.Transfer_Cr_Amt),
  SUM(T.Cash_Dr_Amt),
  SUM(T.Cash_Cr_Amt),
  SUM(T.Clearing_Dr_Amt),
  SUM(T.Clearing_Cr_Amt),
  SUM(T.Opening_amount),
  SUM(T.Closing_amount)
  from
  (
  select  q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code,
  CASE WHEN q.cur = 'MMK'  THEN q.Transfer_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Transfer_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Transfer_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_Amt,
          
        CASE WHEN q.cur = 'MMK'  THEN q.Transfer_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Transfer_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Transfer_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Cash_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Cash_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Cash_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Cash_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Cash_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Cash_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_Amt,
        CASE WHEN q.cur = 'MMK'  THEN q.Clearing_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Clearing_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Clearing_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Dr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Clearing_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Clearing_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Clearing_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Opening_Amount
      when  q.gl_sub_head_code = '70002' and  q.Opening_Amount <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Opening_Amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening_Amount,
    CASE WHEN q.cur = 'MMK'  THEN q.Closing_amount
      when  q.gl_sub_head_code = '70002' and  q.Closing_amount <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Closing_amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing_amount
 from
 (select x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt,
          x.Opening_amount as Opening_amount,
          x.Closing_amount as Closing_amount
    from
   (SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid, 
              coa.group_code,gam.gl_sub_head_code,
            cdav.tran_crncy_code AS cur,gam.acid,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt,
                (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    --group by coa.group_code
                                    --order by eod_date desc
                                    )
              and gam.acct_crncy_code = eab.eab_crncy_code) as Opening_amount,
        (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and eab.end_eod_date >= TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and gam.acct_crncy_code = eab.eab_crncy_code) as Closing_amount
from  
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
--   and eab.eod_date 
   AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
   and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and gam.BANK_ID = '01' 
  -- and eab.bank_id = '01'
   and cdav.bank_id ='01'
   and coa.cur =  gam.acct_crncy_code 
   and gam.acct_crncy_code = cdav.tran_crncy_code
   and gam.acid = cdav.acid
   --and coa.group_code in ('L17')
   and gam.schm_type in ('OAB','OAP','OAD','DDA')
   --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
         -- where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
          --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  union all
    SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
              coa.group_code,gam.gl_sub_head_code,
            gam.acct_crncy_code AS cur,gam.acid,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt,
           (select sum(eab.tran_date_bal) 
            from tbaadm.eab
            where gam.acid = eab.acid
           and eab.eod_date =(select max(eab.eod_date)
                              from tbaadm.eab eab
                              where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              and gam.acid = eab.acid
                              and gam.acct_crncy_code = eab.eab_crncy_code
                              --order by eod_date desc
                              )
            and gam.acct_crncy_code = eab.eab_crncy_code) as Opening_amount,
            (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                 and eab.end_eod_date >= TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and gam.acct_crncy_code = eab.eab_crncy_code) as Closing_amount
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                                from tbaadm.eab eab
                                where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and gam.acid =eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode|| '%'
          AND eab.eab_crncy_code = gam.acct_crncy_code
          and gam.acct_crncy_code = coa.cur
          and gam.acid = eab.acid
         and gam.schm_type in ('OAB','OAP','OAD','DDA')
         and gam.acct_ownership not in ('C','E')
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              --   and eab.eod_date 
                              AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.Tran_date_bal <> 0
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and gam.BANK_ID = '01' 
                              -- and eab.bank_id = '01'
                              and cdav.bank_id ='01'
                              and coa.cur =  gam.acct_crncy_code 
                              and gam.acct_crncy_code = cdav.tran_crncy_code
                              --and gam.acct_cls_flg = 'N'
                              and gam.acid = cdav.acid
                              --and coa.group_code in ('L17')
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA'))
                              --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              --where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
                              )
    )x
    group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.Opening_amount,x.Closing_amount,x.cur,x.acid
   union  all
   select t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.cur,t.acid,
      SUM(t.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(t.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(t.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(t.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(t.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(t.Clearing_Cr_Amt) as Clearing_Cr_Amt ,
           SUM((select SUM(eab.tran_date_bal)
                from tbaadm.eab
                where t.acid = eab.acid
                and eab.eod_date =(select max(eab.eod_date)
                                  from tbaadm.eab eab
                                  where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  and t.acid = eab.acid
                                  --order by eod_date desc
              ))) as Opening_Amount,
          SUM((select SUM(eab.tran_date_bal)
                from tbaadm.eab
                where t.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and eab.end_eod_date >=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
              )) as Closing_Amount       
   from
   (select  x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt
    from
(select
   coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid,
   coa.group_code,gam.gl_sub_head_code,
            cdav.tran_crncy_code AS cur,gam.acid,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt
   
   from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
   and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.acid = gam.acid 
   and gam.acid = cdav.acid
   and coa.cur =  gam.acct_crncy_code
   and gam.acct_crncy_code = cdav.tran_crncy_code
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and cdav.bank_id ='01'
   and gam.BANK_ID = '01'
   --and substr(gam.foracid,6,length(gam.foracid)-5) ='40101010031'
   --and eab.bank_id = '01'
   and gam.acct_ownership in ('C','E') 
  /* and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
          where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
          and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )*/
    --group by coa.gl_sub_head_desc,gam.gl_sub_head_code,coa.group_code,gam.gl_sub_head_code,cdav.tran_crncy_code
    union all
    SELECT coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid, 
              coa.group_code,gam.gl_sub_head_code,
            gam.acct_crncy_code AS cur,gam.acid,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                                from tbaadm.eab eab
                                where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and gam.acid =eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode|| '%'
          AND eab.eab_crncy_code = gam.acct_crncy_code
          and gam.acct_crncy_code = coa.cur
          and gam.acid = eab.acid
          --and substr(gam.foracid,6,length(gam.foracid)-5) ='40101010031'
          and gam.acct_ownership in ('C','E') 
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.acid = gam.acid 
                              and gam.acid = cdav.acid
                              and coa.cur =  gam.acct_crncy_code
                              and gam.acct_crncy_code = cdav.tran_crncy_code
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and cdav.bank_id ='01'
                              and gam.BANK_ID = '01'
                              --and eab.bank_id = '01'
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA')) 
                              --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              --where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
                              ))x
          group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid)t
          group by t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.cur,t.acid
          --order by t.group_code,t.gl_sub_head_code,t.foracid
   --group by coa.gl_sub_head_desc, gam.gl_sub_head_code, coa.group_code,gam.gl_sub_head_code,cdav.tran_amt,cdav.tran_crncy_code
   )q
   --group by q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code
   )T 
   group by T.acct_name,T.foracid,T.group_code,T.gl_sub_head_code
   order by T.group_code,T.gl_sub_head_code,T.foracid;
      -----------------------------------------------------------------------------
      -- CURSOR ExtractDataWithoutHOWithAll_FCY_Currency
      -----------------------------------------------------------------------------
      CURSOR ExtractWithoutHOAll_FCY ( ci_startDate VARCHAR2,ci_endDate VARCHAR2,ci_BranchCode VARCHAR2)
      IS
        select T.acct_name,
  T.foracid,
  T.group_code,
  T.gl_sub_head_code,
  SUM(T.Transfer_Dr_Amt),
  SUM(T.Transfer_Cr_Amt),
  SUM(T.Cash_Dr_Amt),
  SUM(T.Cash_Cr_Amt),
  SUM(T.Clearing_Dr_Amt),
  SUM(T.Clearing_Cr_Amt),
  SUM(T.Opening_amount),
  SUM(T.Closing_amount)
  from
  (
  select  q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code,
  CASE WHEN q.cur = 'MMK'  THEN q.Transfer_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Transfer_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Transfer_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_Amt,
          
        CASE WHEN q.cur = 'MMK'  THEN q.Transfer_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Transfer_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Transfer_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Transfer_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Cash_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Cash_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Cash_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Cash_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Cash_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Cash_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Cash_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_Amt,
        CASE WHEN q.cur = 'MMK'  THEN q.Clearing_Dr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Clearing_Dr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Dr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Clearing_Dr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Dr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Clearing_Cr_Amt
      when  q.gl_sub_head_code = '70002' and  q.Clearing_Cr_Amt <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Clearing_Cr_Amt ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Clearing_Cr_Amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Clearing_Cr_Amt,
       CASE WHEN q.cur = 'MMK'  THEN q.Opening_Amount
      when  q.gl_sub_head_code = '70002' and  q.Opening_Amount <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='1259531.25' and q.cur = 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Opening_Amount ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Opening_Amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where to_char(r.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where to_char(a.Rtlist_date,'MM-YYYY') < to_char(to_date(cast(ci_startDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY'))
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Opening_Amount,
    CASE WHEN q.cur = 'MMK'  THEN q.Closing_amount
      when  q.gl_sub_head_code = '70002' and  q.Closing_amount <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Closing_amount ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Closing_amount * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Closing_amount
 from
 (select x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt,
          x.Opening_amount as Opening_amount,
          x.Closing_amount as Closing_amount
    from
   (SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid, 
              coa.group_code,gam.gl_sub_head_code,
            cdav.tran_crncy_code AS cur,gam.acid,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt,
                (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date =(select max(eab.eod_date)
                                    from tbaadm.eab eab
                                    where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                    and gam.acid = eab.acid
                                    and gam.acct_crncy_code = eab.eab_crncy_code
                                    and gam.acct_crncy_code != upper('MMK')
                                    --group by coa.group_code
                                    --order by eod_date desc
                                    )
              and gam.acct_crncy_code = eab.eab_crncy_code) as Opening_amount,
        (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and eab.end_eod_date >= TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and gam.acct_crncy_code = eab.eab_crncy_code
                 and gam.acct_crncy_code != upper('MMK')) as Closing_amount
from  
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
--   and eab.eod_date 
   AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
   and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and gam.BANK_ID = '01' 
  -- and eab.bank_id = '01'
   and cdav.bank_id ='01'
   and coa.cur =  gam.acct_crncy_code 
   and gam.acct_crncy_code = cdav.tran_crncy_code
   and gam.acct_crncy_code != upper('MMK')
   and cdav.tran_crncy_code  !=upper('MMK')
   and coa.cur !=upper('MMK')
   and gam.acid = cdav.acid
   --and coa.group_code in ('L17')
   and gam.schm_type in ('OAB','OAP','OAD','DDA')
   --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
         -- where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
          --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  union all
    SELECT gam.acct_name, substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
              coa.group_code,gam.gl_sub_head_code,
            gam.acct_crncy_code AS cur,gam.acid,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt,
           (select sum(eab.tran_date_bal) 
            from tbaadm.eab
            where gam.acid = eab.acid
           and eab.eod_date =(select max(eab.eod_date)
                              from tbaadm.eab eab
                              where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              and gam.acid = eab.acid
                              and gam.acct_crncy_code = eab.eab_crncy_code
                              and gam.acct_crncy_code !=upper('MMK')
                              --order by eod_date desc
                              )
            and gam.acct_crncy_code = eab.eab_crncy_code) as Opening_amount,
            (select sum(eab.tran_date_bal) 
                from tbaadm.eab
                where gam.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                 and eab.end_eod_date >= TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and gam.acct_crncy_code = eab.eab_crncy_code
                and gam.acct_crncy_code !=upper('MMK')) as Closing_amount
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                                from tbaadm.eab eab
                                where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and gam.acid =eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode|| '%'
          AND eab.eab_crncy_code = gam.acct_crncy_code
          and gam.acct_crncy_code = coa.cur
          and gam.acct_crncy_code != upper('MMK')
          and eab.eab_crncy_code  !=upper('MMK')
          and coa.cur !=upper('MMK')
          and gam.acid = eab.acid
         and gam.schm_type in ('OAB','OAP','OAD','DDA')
         and gam.acct_ownership not in ('C','E')
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              --   and eab.eod_date 
                              AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.Tran_date_bal <> 0
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and gam.BANK_ID = '01' 
                              -- and eab.bank_id = '01'
                              and cdav.bank_id ='01'
                              and coa.cur =  gam.acct_crncy_code 
                              and gam.acct_crncy_code = cdav.tran_crncy_code
                              and gam.acct_crncy_code != upper('MMK')
                              and cdav.tran_crncy_code  !=upper('MMK')
                              and coa.cur !=upper('MMK')
                              --and gam.acct_cls_flg = 'N'
                              and gam.acid = cdav.acid
                              --and coa.group_code in ('L17')
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA'))
                              --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              --where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
                              )
    )x
    group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.Opening_amount,x.Closing_amount,x.cur,x.acid
   union  all
   select t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.cur,t.acid,
      SUM(t.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(t.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(t.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(t.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(t.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(t.Clearing_Cr_Amt) as Clearing_Cr_Amt ,
           SUM((select SUM(eab.tran_date_bal)
                from tbaadm.eab
                where t.acid = eab.acid
                and eab.eod_date =(select max(eab.eod_date)
                                  from tbaadm.eab eab
                                  where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  and t.acid = eab.acid
                                  --order by eod_date desc
              ))) as Opening_Amount,
          SUM((select SUM(eab.tran_date_bal)
                from tbaadm.eab
                where t.acid = eab.acid
                and eab.eod_date <=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
                and eab.end_eod_date >=TO_DATE( ci_endDate, 'dd-MM-yyyy' )
              )) as Closing_Amount       
   from
   (select  x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid,
      SUM(x.Transfer_Dr_Amt) as Transfer_Dr_Amt,
          SUM(x.Transfer_Cr_Amt) as Transfer_Cr_Amt,
          SUM(x.Cash_Dr_Amt) as Cash_Dr_Amt,
          SUM(x.Cash_Cr_Amt) as Cash_Cr_Amt,
          SUM(x.Clearing_Dr_Amt) as Clearing_Dr_Amt,
          SUM(x.Clearing_Cr_Amt) as Clearing_Cr_Amt
    from
(select
   coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid,
   coa.group_code,gam.gl_sub_head_code,
            cdav.tran_crncy_code AS cur,gam.acid,
            CASE cdav.Tran_type WHEN 'T' THEN 
              CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Dr_Amt,
            CASE cdav.Tran_type WHEN 'T'THEN
                CASE cdav.part_tran_type WHEN 'C'THEN cdav.tran_amt ELSE 0 END END AS Transfer_Cr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Cash_Dr_Amt,
            CASE cdav.Tran_type WHEN 'C'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Cash_Cr_Amt,
            CASE cdav.Tran_type WHEN 'L' THEN
                CASE cdav.part_tran_type WHEN 'D'THEN cdav.tran_amt ELSE 0 END END AS Clearing_Dr_Amt,
            CASE cdav.Tran_type WHEN 'L'THEN
                CASE cdav.part_tran_type WHEN 'C' THEN cdav.tran_amt ELSE 0 END END AS Clearing_Cr_Amt
   
   from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
where
   cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
   and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
   and coa.gl_sub_head_code = gam.gl_sub_head_code
   and coa.gl_sub_head_code = cdav.gl_sub_head_code
   --and eab.acid = gam.acid 
   and gam.acid = cdav.acid
   and coa.cur =  gam.acct_crncy_code
   and gam.acct_crncy_code = cdav.tran_crncy_code
   and gam.acct_crncy_code != upper('MMK')
   and cdav.tran_crncy_code  !=upper('MMK')
   and coa.cur !=upper('MMK')
   and gam.DEL_FLG = 'N' 
   and cdav.del_flg ='N'
   and cdav.bank_id ='01'
   and gam.BANK_ID = '01'
   --and substr(gam.foracid,6,length(gam.foracid)-5) ='40101010031'
   --and eab.bank_id = '01'
   and gam.acct_ownership in ('C','E') 
  /* and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
          where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
          and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )*/
    --group by coa.gl_sub_head_desc,gam.gl_sub_head_code,coa.group_code,gam.gl_sub_head_code,cdav.tran_crncy_code
    union all
    SELECT coa.gl_sub_head_desc as acct_name,
   gam.gl_sub_head_code as foracid, 
              coa.group_code,gam.gl_sub_head_code,
            gam.acct_crncy_code AS cur,gam.acid,
            0 AS Transfer_Dr_Amt,
            0 AS Transfer_Cr_Amt,
            0 AS Cash_Dr_Amt,
            0 AS Cash_Cr_Amt,
            0 AS Clearing_Dr_Amt,
            0 AS Clearing_Cr_Amt
          FROM  tbaadm.gam gam ,custom.coa_mp coa, tbaadm.eab eab
          WHERE eab.EOD_DATE <= (select max(eab.eod_date)
                                from tbaadm.eab eab
                                where eab.eod_date < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and gam.acid =eab.acid)
          --and EAB.END_EOD_DATE >= TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
          and gam.sol_id          like '%' || ci_BranchCode|| '%'
          AND eab.eab_crncy_code = gam.acct_crncy_code
          and gam.acct_crncy_code = coa.cur
          and gam.acct_crncy_code != upper('MMK')
          and eab.eab_crncy_code  !=upper('MMK')
          and coa.cur !=upper('MMK')
          and gam.acid = eab.acid
          --and substr(gam.foracid,6,length(gam.foracid)-5) ='40101010031'
          and gam.acct_ownership in ('C','E') 
          --and coa.group_code  ='L17'
          and coa.gl_sub_head_code = gam.gl_sub_head_code
          and eab.acid not in (select cdav.acid
                              from TBAADM.GENERAL_ACCT_MAST_TABLE gam,custom.coa_mp coa, custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
                              where cdav.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              AND cdav.SOL_ID         like '%' || ci_BranchCode|| '%'
                              and gam.SOL_ID like   '%' || ci_BranchCode|| '%'
                              and coa.gl_sub_head_code = gam.gl_sub_head_code
                              and coa.gl_sub_head_code = cdav.gl_sub_head_code
                              --and eab.acid = gam.acid 
                              and gam.acid = cdav.acid
                              and coa.cur =  gam.acct_crncy_code
                              and gam.acct_crncy_code = cdav.tran_crncy_code
                              and gam.acct_crncy_code != upper('MMK')
                              and cdav.tran_crncy_code  !=upper('MMK')
                              and coa.cur !=upper('MMK')
                              and gam.DEL_FLG = 'N' 
                              and cdav.del_flg ='N'
                              and cdav.bank_id ='01'
                              and gam.BANK_ID = '01'
                              --and eab.bank_id = '01'
                              and (gam.acct_ownership  in ('C','E') or gam.schm_type in ('OAB','OAP','OAD','DDA')) 
                              --and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                              --where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                              --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
                              ))x
          group by x.acct_name,x.foracid,x.group_code,x.gl_sub_head_code,x.cur,x.acid)t
          group by t.acct_name,t.foracid,t.group_code,t.gl_sub_head_code,t.cur,t.acid
          --order by t.group_code,t.gl_sub_head_code,t.foracid
   --group by coa.gl_sub_head_desc, gam.gl_sub_head_code, coa.group_code,gam.gl_sub_head_code,cdav.tran_amt,cdav.tran_crncy_code
   )q
   --group by q.acct_name, q.foracid,q.group_code,q.gl_sub_head_code
   )T 
   group by T.acct_name,T.foracid,T.group_code,T.gl_sub_head_code
   order by T.group_code,T.gl_sub_head_code,T.foracid;
              ---------------------------------------------------------------------------------------------------------------------------------
            PROCEDURE FIN_ASSET_LIABILITIES(
                inp_str IN VARCHAR2,
                out_retCode OUT NUMBER,
                out_rec OUT VARCHAR2)
            IS
              -------------------------------------------------------------
              --Variable declaration
              -------------------------------------------------------------
              foracid TBAADM.gam.foracid%type;
              acct_name TBAADM.gam.acct_name%type;
              group_code custom.coa_mp.group_code%type;
              gl_sub_head_code tbaadm.gam.gl_sub_head_code%type;
              Transfer_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              Transfer_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              Cash_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              Cash_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              Clearing_Dr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              Clearing_Cr_Amt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              OpenningAmount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              ClosingAmount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              part_tran_type custom.CUSTOM_CTD_DTD_ACLI_VIEW.part_tran_type%type;
              rate TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
              BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
              BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
              BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
              BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
            BEGIN
              -------------------------------------------------------------
              -- Out Ret code is the code which controls
              -- the while loop,it can have values 0,1
              -- 0 - The while loop is being executed
              -- 1 - Exit
              -------------------------------------------------------------
              out_retCode := 0;
              out_rec     := NULL;
              tbaadm.basp0099.formInputArr(inp_str, outArr);
              --------------------------------------
              -- Parsing the i/ps from the string
              --------------------------------------
              v_startDate    :=outArr(0);
              v_endDate      :=outArr(1);
              v_CurrencyType :=outArr(2);
              v_CurrencyCode := outArr(3);
              v_BranchCode   :=outArr(4);
              -----------------------------------------------------
              -- Checking whether the cursor is open if not
              -- it is opened
              -----------------------------------------------------
  IF v_BranchCode IS  NULL or v_BranchCode = ''  THEN
  v_BranchCode := '';
  END IF;            
-------------------------------------------------------------------------------
-- to get branchname
--------------------------------------------------------------------------------
              BEGIN
              IF v_BranchCode is not null then
                SELECT bct.BR_SHORT_NAME,
                  bct.BR_ADDR_1,
                  bct.PHONE_NUM,
                  bct.FAX_NUM
                INTO BranchName,
                  BankAddress,
                  BankPhone ,
                  BankFax
                FROM tbaadm.sol,
                  tbaadm.bct
                WHERE sol.SOL_ID = v_BranchCode
                AND bct.br_code  = sol.br_code
                and bct.bank_code =sol.bank_code;
                END IF;
              END;
--------------------------------------------------------------------------------------
                IF v_CurrencyType not like 'All%' THEN
                  IF NOT ExtractWithoutHOMMK%ISOPEN THEN
                    --{
                    BEGIN
                      --{
                      OPEN ExtractWithoutHOMMK(v_startDate,v_endDate, v_BranchCode,v_CurrencyCode);
                      --}
                    END;
                    --}
                  END IF;
                  IF ExtractWithoutHOMMK%ISOPEN THEN
                    --{
                    FETCH ExtractWithoutHOMMK
                    INTO acct_name,foracid,
                      group_code,
                      gl_sub_head_code,
                      Transfer_Dr_Amt,
                      Transfer_Cr_Amt,
                      Cash_Dr_Amt,
                      Cash_Cr_Amt,
                      Clearing_Dr_Amt,
                      Clearing_Cr_Amt ,
                      OpenningAmount;
                    ------------------------------------------------------------------
                    -- Here it is checked whether the cursor has fetched
                    -- something or not if not the cursor is closed
                    -- and the out ret code is made equal to 1
                    ------------------------------------------------------------------
                    IF ExtractWithoutHOMMK%NOTFOUND THEN
                      --{
                      CLOSE ExtractWithoutHOMMK;
                      out_retCode:= 1;
                      RETURN;
                      --}
                    END IF;
                    --}
                  END IF;
                ELSIF v_CurrencyType = 'All Currency' THEN
                  IF NOT ExtractWithoutHOAll%ISOPEN THEN
                    --{
                    BEGIN
                      --{
                      OPEN ExtractWithoutHOAll(v_startDate,v_endDate, v_BranchCode);
                      --}
                    END;
                    --}
                  END IF;
                  IF ExtractWithoutHOAll%ISOPEN THEN
                    --{
                    FETCH ExtractWithoutHOAll
                    INTO acct_name,foracid,
                      group_code,
                      gl_sub_head_code,
                      Transfer_Dr_Amt,
                      Transfer_Cr_Amt,
                      Cash_Dr_Amt,
                      Cash_Cr_Amt,
                      Clearing_Dr_Amt,
                      Clearing_Cr_Amt ,
                      OpenningAmount,
                      ClosingAmount;
                    ------------------------------------------------------------------
                    -- Here it is checked whether the cursor has fetched
                    -- something or not if not the cursor is closed
                    -- and the out ret code is made equal to 1
                    ------------------------------------------------------------------
                    IF ExtractWithoutHOAll%NOTFOUND THEN
                      --{
                      CLOSE ExtractWithoutHOAll;
                      out_retCode:= 1;
                      RETURN;
                      --}
                    END IF;
                    --}
                  END IF;
                ELSE
                  IF NOT ExtractWithoutHOAll_FCY%ISOPEN THEN
                    --{
                    BEGIN
                      --{
                      OPEN ExtractWithoutHOAll_FCY(v_startDate,v_endDate, v_BranchCode);
                      --}
                    END;
                    --}
                  END IF;
                  IF ExtractWithoutHOAll_FCY%ISOPEN THEN
                    --{
                    FETCH ExtractWithoutHOAll_FCY
                    INTO acct_name,foracid,
                      group_code,
                      gl_sub_head_code,
                      Transfer_Dr_Amt,
                      Transfer_Cr_Amt,
                      Cash_Dr_Amt,
                      Cash_Cr_Amt,
                      Clearing_Dr_Amt,
                      Clearing_Cr_Amt ,
                      OpenningAmount,
                      ClosingAmount;
                    ------------------------------------------------------------------
                    -- Here it is checked whether the cursor has fetched
                    -- something or not if not the cursor is closed
                    -- and the out ret code is made equal to 1
                    ------------------------------------------------------------------
                    IF ExtractWithoutHOAll_FCY%NOTFOUND THEN
                      --{
                      CLOSE ExtractWithoutHOAll_FCY;
                      out_retCode:= 1;
                      RETURN;
                      --}
                    END IF;
                    --}
                  END IF;
                END IF;
                
              -------------------------------------------------------------------------------------------------------
              -----------------------------------------------------------------------------------
              --  out_rec variable retrieves the data to be sent to LST file with pipe seperation
              ------------------------------------------------------------------------------------
              ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
              IF v_CurrencyType          = 'Home Currency' THEN
                if upper(v_CurrencyCode) = 'MMK' THEN rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date >= TO_DATE( CAST ( v_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                  and rtlist_date <= TO_DATE( CAST ( v_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(v_CurrencyCode)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF v_CurrencyType          = 'Source Currency' THEN
                  rate := 1;
              ELSE
                  rate := 1;
              END IF;
              --out_retCode:= 1;
              --out_retCode:= 1;
              out_rec:= (acct_name || '|' || trim(foracid) || '|' || group_code || '|' || gl_sub_head_code || '|' ||  Transfer_Dr_Amt || '|' || Transfer_Cr_Amt || '|' || Cash_Dr_Amt || '|' || Cash_Cr_Amt || '|' || Clearing_Dr_Amt || '|' || Clearing_Cr_Amt || '|' || OpenningAmount  || '|' || rate || '|' || BranchName || '|' || BankAddress|| '|' || BankPhone || '|' ||
                  BankFax || '|' ||  ClosingAmount);
              dbms_output.put_line(out_rec);
              --dbms_output.put_line( nodata);
            END FIN_ASSET_LIABILITIES;
          END FIN_ASSET_LIABILITIES;
/
