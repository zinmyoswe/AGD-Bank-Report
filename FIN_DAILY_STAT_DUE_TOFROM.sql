CREATE OR REPLACE PACKAGE FIN_DAILY_STAT_DUE_TOFROM AS 

PROCEDURE FIN_DAILY_STAT_DUE_TOFROM(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAILY_STAT_DUE_TOFROM;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                           FIN_DAILY_STAT_DUE_TOFROM AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_currency	  	Varchar2(5);		    	    -- Input to procedure
  vi_currencyType	Varchar2(50);		    	    -- Input to procedure
     vi_option		Varchar2(50);    	    -- Input to procedure
  Vi_Beforedate   Varchar2(10);
  vi_percentage  number(20);
  
  vi_id  Number(20);
  vi_rateone   DECIMAL;
  vi_ratetwo   DECIMAL;
  vi_ratethree DECIMAL;
  vi_ratefour  DECIMAL;
  vi_ratefive  DECIMAL;
      

--------------------------------------------------------------------------------
  -- Cursor for Result
--------------------------------------------------------------------------------
      CURSOR ExtractData IS
      select   q.BB,
               q.CC,
               q.DD,
               nvl(q."'1'",0) as one,
               nvl( q."'2'",0) as two,
               nvl( q."'3'",0) as three,
               nvl(  q."'4'",0) as four,
               nvl(  q."'5'",0) as five 
      from (select *  
        from (
              select a."TranDate" AS AA, a."Header" AS BB , a."AcctType" AS CC ,a."AcctName" AS DD ,nvl(a."Amount",0) AS EE
              from custom."CUST_DAILY_Due_FromTo" a
              where a."Amount" <> 0
          
              )
        pivot(
                    sum(EE)
                    FOR AA IN ( '1' ,'2','3','4','5' )
          ))q
          order by bb;

--------------------------------------------------------------------------------
 -- Function 
    -- There are three Functions here
        -- 1)GetDailyDueAllFCY
        -- 2)GetDailyDueAllCurrency
        -- 3)GetDailyDue
--------------------------------------------------------------------------------
 FUNCTION GetDailyDueAllCurrency(ci_TranDate VARCHAR2,ci_TEMPCountDateTo VARCHAR2,ci_id varchar2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_TranDate;
   BEGIN
     BEGIN

       INSERT INTO custom."CUST_DAILY_Due_FromTo" 
       select * 
       from (
       SELECT  ci_id as Tran_date,
               'From' as Header,
               'Current A/C' as  AcctType,
               T.BANK AS BANK,
               ABS(sum(T.CurrAcc)) as Amount
       FROM (
          Select q.BankName as Bank,
                   CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
                   ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS CurrAcc
                  
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Current Foracid'1010010115007011'
                          CASE  WHEN  GAM.foracid in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,  '3010010123015011'  ,'3220010120012011','3070010117009011', '3260010120012011'      , '1010010123015011'         ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                          ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011')  
                          THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,gam.acct_crncy_code                    
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where
                 eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                 and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                -- and gam.SOL_ID like   '%' || '' || '%'
                 and eab.Tran_date_bal <> 0
                 and gam.sol_id = gsh.sol_id
                 and gam.acct_crncy_code = gsh.crncy_code
                 and gsh.crncy_code = coa.cur
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and gam.DEL_FLG = 'N' 
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01' 
                 --and gam.acct_cls_flg = 'N'
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and gam.schm_type in ('OAB','OAP','OAD','DDA')
                    and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011' ,'3070010117009011'                ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')                        
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('10145','10128','10110','10129','10146','10147','10148','10149','10150','10109','10111','10112','10113')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and   eab.Tran_date_bal <> 0
                   and   gam.DEL_FLG = 'N' 
                   and   gam.BANK_ID = '01' 
                   and   eab.bank_id = '01'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and   coa.cur =  gam.acct_crncy_code
                   and   gsh.crncy_code = coa.cur 
                   and   eab.acid = gam.acid 
                   and   gam.sol_id=gsh.sol_id
                   and   gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( '10145','10128','10129','10146','10147','10110','10148','10149','10150','10109','10111','10112','10113')
             --   and   acct_cls_flg = 'N'
                   )q
              )T
                  
          GROUP BY T.BANK
       
          
           UNION ALL 
    
      SELECT ci_id as Tran_date,
            'From' as Header,
            'Saving A/C' as  AcctType,
            T.BANK AS BANK,
            ABS(sum(T.SavAcc)) as Amount
       FROM (
          Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                    ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS SavAcc
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Saving Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                          ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                          ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021')
                          THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                          
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                  and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                 -- and gam.SOL_ID like   '%' || '' || '%'
                  and eab.Tran_date_bal <> 0
                  and gam.sol_id = gsh.sol_id
                  and gam.acct_crncy_code = gsh.crncy_code
                  and gsh.crncy_code = coa.cur
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and gam.DEL_FLG = 'N' 
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01' 
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and gam.schm_type in ('OAB','OAP','OAD','DDA')
                  and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011' ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                            
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                 from    tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where   Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and eab.Tran_date_bal <> 0
                 and gam.DEL_FLG = 'N' 
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01'
                 and   acct_cls_flg = 'N'
                 and   gam.entity_cre_flg = 'Y'
                 and coa.cur =  gam.acct_crncy_code
                 and gsh.crncy_code = coa.cur 
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and   coa.group_code in ('A07','A06')
                 and   coa.gl_sub_head_code in ('nodata' )
                     --   and   acct_cls_flg = 'N'
                )q
            )T
                  
          GROUP BY T.BANK
       
    
       UNION ALL 
          
            SELECT ci_id as Tran_date,
                  'From' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANK AS BANK,
                  ABS(sum(T.FixAcc)) as Amount
           FROM (
                Select q.BankName as Bank,
                        CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                          ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS FixAcc
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Fixed Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                          ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                          ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')
                          THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                          
                        from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                        where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                       and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                       --and gam.SOL_ID like   '%' || '' || '%'
                       and eab.Tran_date_bal <> 0
                       and gam.sol_id = gsh.sol_id
                       and gam.acct_crncy_code = gsh.crncy_code
                       and gsh.crncy_code = coa.cur
                       and coa.gl_sub_head_code = gsh.gl_sub_head_code
                       and gam.DEL_FLG = 'N' 
                       and gam.BANK_ID = '01' 
                       and eab.bank_id = '01' 
                       --and gam.acct_cls_flg = 'N'
                       and eab.acid = gam.acid 
                       and gam.sol_id=gsh.sol_id
                       and gam.gl_sub_head_code=gsh.gl_sub_head_code
                       and gam.schm_type in ('OAB','OAP','OAD','DDA')
                      and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                     ,   '3010010123015011' ,'3220010120012011', '3260010120012011'                 ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                  ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                        '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                  ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                  ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                        '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                  ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                  ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                  
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( 'nodata')
             --   and   acct_cls_flg = 'N'
                )q
                  )T
                  
          GROUP BY T.BANK
       
          
            UNION ALL 
            
            SELECT ci_id as Tran_date,
                  'To' as Header,
                  'Current A/C' as  AcctType,
                  T.BANK AS BANK,
                   sum(T.CurrAcc) as Amount
           FROM (
            Select q.BankName as Bank,
                   CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
                   ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS CurrAcc
                    
          from  (
                  select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('70311','70312','70313')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and eab.Tran_date_bal <> 0
                  and gam.DEL_FLG = 'N' 
                 --and coa.cur = 'MMK'
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01'
                  and coa.cur =  gam.acct_crncy_code
                  and gsh.crncy_code = coa.cur 
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                  and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
       
                  UNION ALL 
                  
               
          SELECT  ci_id as Tran_date,
                  'To' as Header,
                  'Saving A/C' as  AcctType,
                  T.BANK AS BANK,
                  sum(T.SavAcc) as Amount
           FROM (
           Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                    ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS SavAcc
          from  (
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70314')  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                  -- and coa.cur = 'MMK'
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
       
                  
                  
           UNION ALL       
                        
          SELECT  ci_id as Tran_date,
                  'To' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANK AS BANK,
                  sum(T.FixAcc) as Amount
           FROM (
           Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                    ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS FixAcc
          from  (
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70315')  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                  -- and coa.cur = 'MMK'
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
            )
                  ;    

     End;
  Return v_returnValue; 
END GetDailyDueAllCurrency;
 
 
FUNCTION GetDailyDueAllFCY(ci_TranDate VARCHAR2,ci_TEMPCountDateTo varchar2, ci_id varchar2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_TranDate;
   BEGIN
     BEGIN

       INSERT INTO custom."CUST_DAILY_Due_FromTo" 
       select * 
       from (
       SELECT  ci_id as Tran_date,
               'From' as Header,
               'Current A/C' as  AcctType,
               T.BANK AS BANK,
               ABS(sum(T.CurrAcc)) as Amount
       FROM (
          Select q.BankName as Bank,
                   CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
                   ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS CurrAcc
                  
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Current Foracid'1010010115007011'
                          CASE  WHEN  GAM.foracid in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,  '3010010123015011'  ,'3220010120012011', '3260010120012011'      , '1010010123015011'         ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                          ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011')  
                          THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,gam.acct_crncy_code                    
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where
                 eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                 and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                -- and gam.SOL_ID like   '%' || '' || '%'
                 and eab.Tran_date_bal <> 0
                 and gam.sol_id = gsh.sol_id
                 and gam.acct_crncy_code = gsh.crncy_code
                 and coa.cur <> 'MMK'
                 and gsh.crncy_code = coa.cur
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and gam.DEL_FLG = 'N' 
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01' 
                 --and gam.acct_cls_flg = 'N'
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and gam.schm_type in ('OAB','OAP','OAD','DDA')
                    and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011'                 ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')                        
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('10145','10128','10110','10129','10146','10147','10148','10149','10150','10109','10111','10112','10113')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and   eab.Tran_date_bal <> 0
                   and   gam.DEL_FLG = 'N' 
                   and   coa.cur <> 'MMK'
                   and   gam.BANK_ID = '01' 
                   and   eab.bank_id = '01'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and   coa.cur =  gam.acct_crncy_code
                   and   gsh.crncy_code = coa.cur 
                   and   eab.acid = gam.acid 
                   and   gam.sol_id=gsh.sol_id
                   and   gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( '10145','10128','10129','10146','10147','10110','10148','10149','10150','10109','10111','10112','10113')
             --   and   acct_cls_flg = 'N'
                   )q
              )T
                  
          GROUP BY T.BANK
       
          
           UNION ALL 
    
      SELECT ci_id as Tran_date,
            'From' as Header,
            'Saving A/C' as  AcctType,
            T.BANK AS BANK,
            ABS(sum(T.SavAcc)) as Amount
       FROM (
          Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                    ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS SavAcc
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Saving Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                          ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                          ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021')
                          THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                          
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                  and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                 -- and gam.SOL_ID like   '%' || '' || '%'
                  and eab.Tran_date_bal <> 0
                  and gam.sol_id = gsh.sol_id
                  and gam.acct_crncy_code = gsh.crncy_code
                  and gsh.crncy_code = coa.cur
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and gam.DEL_FLG = 'N' 
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01' 
                  and   coa.cur <> 'MMK'
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and gam.schm_type in ('OAB','OAP','OAD','DDA')
                  and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011' ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                            
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                 from    tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where   Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and eab.Tran_date_bal <> 0
                 and gam.DEL_FLG = 'N' 
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01'
                 and   coa.cur <> 'MMK'
                 and   acct_cls_flg = 'N'
                 and   gam.entity_cre_flg = 'Y'
                 and coa.cur =  gam.acct_crncy_code
                 and gsh.crncy_code = coa.cur 
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and   coa.group_code in ('A07','A06')
                 and   coa.gl_sub_head_code in ('nodata' )
                     --   and   acct_cls_flg = 'N'
                )q
            )T
                  
          GROUP BY T.BANK
       
    
       UNION ALL 
          
            SELECT ci_id as Tran_date,
                  'From' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANK AS BANK,
                  ABS(sum(T.FixAcc)) as Amount
           FROM (
                Select q.BankName as Bank,
                        CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                          ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                                FROM TBAADM.RTH r
                                                where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                and  r.RATECODE = 'NOR'
                                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                      FROM TBAADM.RTH a
                                                                                      where a.Rtlist_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                      and  a.RATECODE = 'NOR'
                                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                      group by a.fxd_crncy_code
                                                    )
                                              ),1) END AS FixAcc
          from  (
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Fixed Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                          ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                          ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')
                          THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                          
                        from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                        where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                       and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                       --and gam.SOL_ID like   '%' || '' || '%'
                       and eab.Tran_date_bal <> 0
                       and gam.sol_id = gsh.sol_id
                       and gam.acct_crncy_code = gsh.crncy_code
                       and gsh.crncy_code = coa.cur
                       and coa.gl_sub_head_code = gsh.gl_sub_head_code
                       and gam.DEL_FLG = 'N' 
                       and gam.BANK_ID = '01' 
                       and eab.bank_id = '01' 
                       and   coa.cur <> 'MMK'
                       --and gam.acct_cls_flg = 'N'
                       and eab.acid = gam.acid 
                       and gam.sol_id=gsh.sol_id
                       and gam.gl_sub_head_code=gsh.gl_sub_head_code
                       and gam.schm_type in ('OAB','OAP','OAD','DDA')
                      and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                     ,   '3010010123015011' ,'3220010120012011', '3260010120012011'                 ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                  ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                        '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                  ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                  ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                        '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                  ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                  ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                  
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and   coa.cur <> 'MMK'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( 'nodata')
             --   and   acct_cls_flg = 'N'
                )q
                  )T
                  
          GROUP BY T.BANK
       
          
            UNION ALL 
            
            SELECT ci_id as Tran_date,
                  'To' as Header,
                  'Current A/C' as  AcctType,
                  T.BANK AS BANK,
                   sum(T.CurrAcc) as Amount
           FROM (
            Select q.BankName as Bank,
                   CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
                   ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS CurrAcc
                    
          from  (
                  select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('70311','70312','70313')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and eab.Tran_date_bal <> 0
                  and gam.DEL_FLG = 'N' 
                 --and coa.cur = 'MMK'
                  and   coa.cur <> 'MMK'
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01'
                  and coa.cur =  gam.acct_crncy_code
                  and gsh.crncy_code = coa.cur 
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                  and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
       
                  UNION ALL 
                  
               
          SELECT  ci_id as Tran_date,
                  'To' as Header,
                  'Saving A/C' as  AcctType,
                  T.BANK AS BANK,
                  sum(T.SavAcc) as Amount
           FROM (
           Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                    ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS SavAcc
          from  (
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70314')  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                  -- and coa.cur = 'MMK'
                  and   coa.cur <> 'MMK'
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
       
                  
                  
           UNION ALL       
                        
          SELECT  ci_id as Tran_date,
                  'To' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANK AS BANK,
                  sum(T.FixAcc) as Amount
           FROM (
           Select q.BankName as Bank,
                    CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                    ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                          FROM TBAADM.RTH r
                                          where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                          and  r.RATECODE = 'NOR'
                                          and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                          and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                                FROM TBAADM.RTH a
                                                                                where a.Rtlist_date = TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' )
                                                                                and  a.RATECODE = 'NOR'
                                                                                and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                group by a.fxd_crncy_code
                                              )
                                        ),1) END AS FixAcc
          from  (
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70315')  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                  -- and coa.cur = 'MMK'
                  and   coa.cur <> 'MMK'
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                  )Q
                  )T
          GROUP BY T.BANK
            )
                  ;    

     End;
  Return v_returnValue; 
END GetDailyDueAllFCY;   
  
  
  FUNCTION GetDailyDue(ci_TranDate VARCHAR2,ci_TEMPCountDateTo varchar2, ci_id varchar2,ci_currency varchar2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_TranDate;
   BEGIN
     BEGIN

       INSERT INTO custom."CUST_DAILY_Due_FromTo" 
        select * 
       from (
       SELECT  ci_id  as Tran_date,
               'From' as Header,
               'Current A/C' as  AcctType,
               T.BankName AS BANK,
               ABS(sum(T.CurrAcc)) as Amount
       FROM (
        
          --KBZ
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Current Foracid'1010010115007011'
                          CASE  WHEN  GAM.foracid in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,  '3010010123015011'  ,'3220010120012011', '3260010120012011'      , '1010010123015011'         ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                          ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011')  
                          THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,gam.acct_crncy_code                    
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where
                 eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                 and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                -- and gam.SOL_ID like   '%' || '' || '%'
                  and  gam.acct_crncy_code= Upper(ci_currency)
                 and eab.Tran_date_bal <> 0
                 and gam.sol_id = gsh.sol_id
                 and gam.acct_crncy_code = gsh.crncy_code
                 and gsh.crncy_code = coa.cur
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and gam.DEL_FLG = 'N' 
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01' 
                 --and gam.acct_cls_flg = 'N'
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and gam.schm_type in ('OAB','OAP','OAD','DDA')
                    and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011'                 ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')                        
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('10145','10128','10110','10129','10146','10147','10148','10149','10150','10109','10111','10112','10113')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and   eab.Tran_date_bal <> 0
                   and   gam.DEL_FLG = 'N' 
                   and  gam.acct_crncy_code= Upper(ci_currency)
                   and   gam.BANK_ID = '01' 
                   and   eab.bank_id = '01'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and   coa.cur =  gam.acct_crncy_code
                   and   gsh.crncy_code = coa.cur 
                   and   eab.acid = gam.acid 
                   and   gam.sol_id=gsh.sol_id
                   and   gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( '10145','10128','10129','10146','10147','10110','10148','10149','10150','10109','10111','10112','10113')
             --   and   acct_cls_flg = 'N'
                
              )T
                  
          GROUP BY T.BankName
       
          
           UNION ALL 
    
     SELECT  ci_id  as Tran_date,
            'From' as Header,
            'Saving A/C' as  AcctType,
            T.BankName AS BANK,
            ABS(sum(T.SavAcc)) as Amount
       FROM (
         
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Saving Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                          ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                          ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021')
                          THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                          
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                  and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                 -- and gam.SOL_ID like   '%' || '' || '%'
                  and eab.Tran_date_bal <> 0
                  and gam.sol_id = gsh.sol_id
                  and  gam.acct_crncy_code= Upper(ci_currency)
                  and gam.acct_crncy_code = gsh.crncy_code
                  and gsh.crncy_code = coa.cur
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and gam.DEL_FLG = 'N' 
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01' 
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and gam.schm_type in ('OAB','OAP','OAD','DDA')
                  and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                       ,   '3010010123015011' ,'3220010120012011', '3260010120012011' ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                    ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                          '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                    ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                    ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                          '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                    ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                    ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                            
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                 from    tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                 where   Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                 and coa.gl_sub_head_code = gsh.gl_sub_head_code
                 and eab.Tran_date_bal <> 0
                 and gam.DEL_FLG = 'N' 
                 and  gam.acct_crncy_code= Upper(ci_currency)
                 and gam.BANK_ID = '01' 
                 and eab.bank_id = '01'
                 and   acct_cls_flg = 'N'
                 and   gam.entity_cre_flg = 'Y'
                 and coa.cur =  gam.acct_crncy_code
                 and gsh.crncy_code = coa.cur 
                 and eab.acid = gam.acid 
                 and gam.sol_id=gsh.sol_id
                 and gam.gl_sub_head_code=gsh.gl_sub_head_code
                 and   coa.group_code in ('A07','A06')
                 and   coa.gl_sub_head_code in ('nodata' )
                     --   and   acct_cls_flg = 'N'
                
            )T
                  
          GROUP BY T.BankName
       
    
       UNION ALL 
          
           SELECT  ci_id  as Tran_date,
                  'From' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANKName AS BANK,
                  ABS(sum(T.FixAcc)) as Amount
           FROM (
              
                  select coa.gl_sub_head_desc as BankName, 
                  --      For Other Bank Fixed Foracid
                          CASE  WHEN  GAM.foracid in ('1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                          ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                          ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')
                          THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                          
                        from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                        where eab.EOD_DATE <= TO_DATE(ci_TranDate, 'dd-Mon-yy' )
                       and eab.end_eod_date >= TO_DATE(ci_TranDate , 'dd-Mon-yy' )
                       --and gam.SOL_ID like   '%' || '' || '%'
                       and eab.Tran_date_bal <> 0
                       and gam.sol_id = gsh.sol_id
                       and  gam.acct_crncy_code= Upper(ci_currency)
                       and gam.acct_crncy_code = gsh.crncy_code
                       and gsh.crncy_code = coa.cur
                       and coa.gl_sub_head_code = gsh.gl_sub_head_code
                       and gam.DEL_FLG = 'N' 
                       and gam.BANK_ID = '01' 
                       and eab.bank_id = '01' 
                       --and gam.acct_cls_flg = 'N'
                       and eab.acid = gam.acid 
                       and gam.sol_id=gsh.sol_id
                       and gam.gl_sub_head_code=gsh.gl_sub_head_code
                       and gam.schm_type in ('OAB','OAP','OAD','DDA')
                      and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011'
                     ,   '3010010123015011' ,'3220010120012011', '3260010120012011'                 ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                                  ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011',
                        '1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                                  ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                                  ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021',
                        '1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                                  ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                                  ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')           
                  
                  
                  union all
                  ---Nostro can't distinguish SBA,FIX,Current in here So i use by GL Code
                  select coa.gl_sub_head_desc as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                 from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                   where Eod_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TranDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                   and gam.BANK_ID = '01' 
                   and  gam.acct_crncy_code= Upper(ci_currency)
                   and eab.bank_id = '01'
                   and   acct_cls_flg = 'N'
                   and   gam.entity_cre_flg = 'Y'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.group_code in ('A07','A06')
                   and   coa.gl_sub_head_code in ( 'nodata')
             --   and   acct_cls_flg = 'N'
              
                  )T
                  
          GROUP BY T.BANKName
       
          
            UNION ALL 
            
           SELECT  ci_id  as Tran_date,
                  'To' as Header,
                  'Current A/C' as  AcctType,
                  T.BANKName AS BANK,
                   sum(T.CurrAcc) as Amount
           FROM (
           
                  select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in('70311','70312','70313')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                  and coa.gl_sub_head_code = gsh.gl_sub_head_code
                  and eab.Tran_date_bal <> 0
                  and gam.DEL_FLG = 'N' 
                  and  gam.acct_crncy_code= Upper(ci_currency)
                  and gam.BANK_ID = '01' 
                  and eab.bank_id = '01'
                  and coa.cur =  gam.acct_crncy_code
                  and gsh.crncy_code = coa.cur 
                 --and gam.acct_cls_flg = 'N'
                  and eab.acid = gam.acid 
                  and gam.sol_id=gsh.sol_id
                  and gam.gl_sub_head_code=gsh.gl_sub_head_code
                  and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                  and   coa.group_code in ('L21','L22','L24','L26')
                
                  )T
          GROUP BY T.BANKName
       
                  UNION ALL 
                  
               
          SELECT  ci_id  as Tran_date,
                  'To' as Header,
                  'Saving A/C' as  AcctType,
                  T.BANKName AS BANK,
                  sum(T.SavAcc) as Amount
           FROM (
        
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70314')  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                   and  gam.acct_crncy_code= Upper(ci_currency)
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                  
                  )T
          GROUP BY T.BANKName
       
                  
                  
           UNION ALL       
                        
          SELECT  ci_id  as Tran_date,
                  'To' as Header,
                  'Fixed A/C' as  AcctType,
                  T.BANKName AS BANK,
                  sum(T.FixAcc) as Amount
           FROM (
          
                 select gam.acct_name as BankName, 
                          CASE  WHEN  coa.gl_sub_head_code in( '70315')  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                          gam.acct_crncy_code
                  from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
                  where  Eod_date <= TO_DATE( CAST ( ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and   end_eod_date >= TO_DATE( CAST (ci_TEMPCountDateTo AS VARCHAR(10) ) , 'dd-Mon-yy' ) 
                   and coa.gl_sub_head_code = gsh.gl_sub_head_code
                   and eab.Tran_date_bal <> 0
                   and gam.DEL_FLG = 'N' 
                   and  gam.acct_crncy_code= Upper(ci_currency)
                   and gam.BANK_ID = '01' 
                   and eab.bank_id = '01'
                   and coa.cur =  gam.acct_crncy_code
                   and gsh.crncy_code = coa.cur 
                   --and gam.acct_cls_flg = 'N'
                   and eab.acid = gam.acid 
                   and gam.sol_id=gsh.sol_id
                   and gam.gl_sub_head_code=gsh.gl_sub_head_code
                   and   coa.gl_sub_head_code in ('70311','70312','70313','70314','70315' )
                   and   coa.group_code in ('L21','L22','L24','L26')
                 
                  )T
          GROUP BY T.BANKName
            )
        ;     

     End;
  Return v_returnValue; 
END GetDailyDue;
 
  
  PROCEDURE FIN_DAILY_STAT_DUE_TOFROM(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
   
   
       v_ToFrom varchar2(20);
       v_Header   varchar2(50);
       v_AcctType varchar2(150);
       v_one      Number(20,2);
       v_two      Number(20,2);
       v_three    Number(20,2);
       v_four     Number(20,2);
       v_five     Number(20,2);

       Test_Date     Number;
       out_put Varchar2(60);
       Countdate Number := 0;
       TEMPCountDate varchar2(20);
       TEMPCountDateTo varchar2(20);
       
       
   
       
       
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
 
    vi_startDate    :=  outArr(0);		
    vi_endDate      :=  outArr(1);
    vi_Currency     :=  outArr(2);
    vi_CurrencyType :=  outArr(3);
    vi_option       :=  outArr(4);

    
    ----------------------------------------------------------
    -- Check  are There no Parameters Parsing from Front End
    ----------------------------------------------------------
    
    IF( vi_startDate is null or vi_endDate is null or vi_CurrencyType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||'-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
     END IF;
  
    IF vi_option like 'Thousand' then
        vi_percentage :=  1000;
    elsif vi_option like 'Million' then
        vi_percentage :=  1000000;
    else 
        vi_percentage := 1;
    end if;
    ----------------------------------------------------------
    -- Get the number of day for Looping 
    ----------------------------------------------------------
   BEGIN 
      select TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) - TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )+ 1 as aa
      into CountDate
      from dual;
    END;
      Vi_Id := 1;
      begin
   delete from  custom."CUST_DAILY_Due_FromTo"; 
   end;
  
    ------------------------Function call FOR get daily amount--------------------------
 
   FOR CC IN 1 .. CountDate   --30-1
   LOOP 
  
      select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1 +CC
      into TEMPCountDate
      From Dual;
      select  TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1 +CC
      into TEMPCountDateTo
      From Dual;
       dbms_output.put_line(TEMPCountDate);
       dbms_output.put_line(TEMPCountDateTo);
       Begin 
          IF vi_CurrencyType LIKE 'All Currency' then
            Out_Put := GetDailyDueAllCurrency(Tempcountdate,TEMPCountDateTo,Vi_Id);
          --  dbms_output.put_line('all');
          elsif vi_CurrencyType LIKE 'All Currency(FCY)' then
            Out_Put := GetDailyDueAllFCY(Tempcountdate,TEMPCountDateTo,Vi_Id);
           -- dbms_output.put_line('fcy');
          else
            Out_Put := GetDailyDue(Tempcountdate,TEMPCountDateTo,Vi_Id, vi_currency);
           -- dbms_output.put_line('no');
           end if;
           vi_id := Vi_Id+1;
        END;
     -- dbms_output.put_line(TEMPCountDate);
  End Loop;
 

--------------------------------------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData;	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			Fetch	Extractdata
			Into	     v_ToFrom ,
                 v_Header ,
                 v_AcctType ,
                 v_one   ,   
                 v_two  ,   
                 v_three,   
                 v_four  , 
                 v_five     ;


			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
		--}
    END if;
-------------------------------------------------------------------------------
 -- For Different Rate
-------------------------------------------------------------------------------
      IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_rateone := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_rateone from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_rateone            := 1;
    ELSE
      vi_rateone := 1;
    END IF;
         IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_ratetwo := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_ratetwo from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_ratetwo            := 1;
    ELSE
      vi_ratetwo := 1;
    END IF;
         IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_ratethree := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_ratethree from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_ratethree            := 1;
    ELSE
      vi_ratethree := 1;
    END IF;
         IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_ratefour := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_ratefour from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_ratefour            := 1;
    ELSE
      vi_ratefour := 1;
    END IF;
         IF vi_currencyType           = 'Home Currency' THEN
      if upper(vi_currency) = 'MMK' THEN vi_ratefive := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_ratefive from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
         vi_ratefive            := 1;
    ELSE
      vi_ratefive := 1;
    END IF;
 /*      
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
  BEGIN
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      Where
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;  
*/    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
                v_ToFrom     || '|' ||
                 v_Header      || '|' ||
                 v_AcctType    || '|' ||
                 v_one/vi_percentage          || '|' || 
                 v_two/vi_percentage          || '|' || 
                 v_three/vi_percentage        || '|' || 
                 v_four/vi_percentage         || '|' ||
                 v_five/vi_percentage         || '|' ||
                  vi_rateone   || '|' ||
                  vi_ratetwo   || '|' ||
                  vi_ratethree || '|' ||
                  vi_ratefour  || '|' ||
                  vi_ratefive  
            );
  
			dbms_output.put_line(out_rec);
  END FIN_DAILY_STAT_DUE_TOFROM;

END FIN_DAILY_STAT_DUE_TOFROM;
/
