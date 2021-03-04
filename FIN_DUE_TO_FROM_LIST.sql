CREATE OR REPLACE PACKAGE               FIN_DUE_TO_FROM_LIST AS 

  subtype limited_string is varchar2(2000);
  PROCEDURE FIN_DUE_TO_FROM_LIST(inp_str IN varchar2,
                                out_retCode OUT Number,
                                out_rec OUT limited_string);

END FIN_DUE_TO_FROM_LIST;
/


CREATE OR REPLACE PACKAGE BODY                             FIN_DUE_TO_FROM_LIST AS

  --------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_tranDate		Varchar2(10);		    	    -- Input to procedure
  vi_type   		Varchar2(10);		    	    -- Input to procedure

  
  Cursor ExtractDataDueFrom(vi_tranDate varchar2) is
    SELECT T.BANK AS BANK,
        ABS(sum(T.CurrAcc)),
        ABS(sum(T.SavAcc)),
        ABS(sum(T.FixAcc))
 FROM (
      Select q.BankName as Bank,
               CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
               ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS CurrAcc,
                CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS SavAcc,
              CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS FixAcc
      from  (
      --KBZ
              select coa.gl_sub_head_desc as BankName, 
              --      For Other Bank Current Foracid'1010010115007011'
                      CASE  WHEN  GAM.foracid in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011','3070010117009011'
     ,  '3010010123015011'  ,'3220010120012011', '3260010120012011' ,'3070010117009011'     , '1010010123015011'         ,'1010010118010011','1010010119011011','1010010120012011','1010010121013011','1010010122014011'
                      ,'1010010123015011','1010010124016011','1010010125017011','1010010126018011','1010010127019011')  
                      THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
              --      For Other Bank Saving Foracid
                      CASE  WHEN  GAM.foracid in ('1010010114006021','1010010115007021','1010010116008021','1010010117009021'
                      ,'1010010118010021','1010010119011021','1010010120012021','1010010121013021','1010010122014021'
                      ,'1010010123015021','1010010124016021','1010010125017021','1010010126018021','1010010127019021')
                      THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
              --      For Other Bank Fixed Foracid
                      CASE  WHEN  GAM.foracid in ('1010010114006031','1010010115007031','1010010116008031','1010010117009031'
                      ,'1010010118010031','1010010119011031','1010010120012031','1010010121013031','1010010122014031'
                      ,'1010010123015031','1010010124016031','1010010125017031','1010010126018031','1010010127019031')
                      THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                      gam.acct_crncy_code
                      
                    from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
            where
   eab.EOD_DATE <= TO_DATE(vi_tranDate, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(vi_tranDate , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || '' || '%'
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
      and   gam.foracid  in( '1010010114006011','1010010115007011','1010010116008011','1010010117009011','3070010117009011'
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
                      CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                      CASE  WHEN  coa.gl_sub_head_code = ''  THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                      gam.acct_crncy_code
             from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
               where         
           Eod_date <= TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              and   end_eod_date >= TO_DATE( CAST (vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
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
      and   coa.gl_sub_head_code in ( '10145','10128','10129','10146','10147','10110','10148','10149','10150','10109','10111','10112','10113')
         --   and   acct_cls_flg = 'N'
            )q
              )T
              
      GROUP BY T.BANK
      ORDER BY T.BANK
      ;
      ----------------------------------------------------------
      -----------Due To----------------------------------------
      ---------------------------------------------------
  Cursor ExtractDataDueTo(vi_tranDate varchar2) is
   SELECT T.BANK AS BANK,
        sum(T.CurrAcc),
        sum(T.SavAcc),
        sum(T.FixAcc)
 FROM (
      Select q.BankName as Bank,
               CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.CurrAcc
               ELSE q.CurrAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS CurrAcc,
                CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.SavAcc
                ELSE q.SavAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS SavAcc,
              CASE WHEN q.acct_crncy_code = 'MMK'  THEN q.FixAcc
                ELSE q.FixAcc * NVL((SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where trim(r.fxd_crncy_code) = trim(q.acct_crncy_code) and r.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where a.Rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                            and  a.RATECODE = 'NOR'
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                            group by a.fxd_crncy_code
                                          )
                                    ),1) END AS FixAcc
      from  (
             select gam.acct_name as BankName, 
                      CASE  WHEN  coa.gl_sub_head_code in('70311','70312','70313')  THEN  eab.tran_date_bal ELSE 0 END AS CurrAcc,
                      CASE  WHEN  coa.gl_sub_head_code in( '70314')  THEN  eab.tran_date_bal ELSE 0 END AS SavAcc,
                      CASE  WHEN  coa.gl_sub_head_code in( '70315')   THEN  eab.tran_date_bal ELSE 0 END AS FixAcc,
                      gam.acct_crncy_code
              from  tbaadm.eab eab, custom.coa_mp coa, tbaadm.gam gam , tbaadm.gsh gsh 
             where         
           Eod_date <= TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              and   end_eod_date >= TO_DATE( CAST (vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   and coa.gl_sub_head_code = gsh.gl_sub_head_code
   and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and coa.cur = 'MMK'
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
      ORDER BY T.BANK
              ;
 
  
  PROCEDURE FIN_DUE_TO_FROM_LIST(inp_str IN varchar2,
                                out_retCode OUT Number,
                                out_rec OUT limited_string) AS
                                
  
  v_Current CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE := 0;
  v_Saving CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE := 0;
  v_Fixed CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE := 0;
  
  v_bankName varchar2(100);
  v_currentAmt number;
  v_savingAmt number;
  v_fixedAmt number;


  
  BEGIN
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_tranDate  :=  outArr(0);
    vi_type  :=  outArr(1);	
    
    
  IF vi_type like 'DUE TO' THEN 
    IF NOT ExtractDataDueTo%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataDueTo (vi_tranDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataDueTo%ISOPEN THEN
		--{
      FETCH	ExtractDataDueTo
			INTO	  v_bankName,v_currentAmt,v_savingAmt, v_fixedAmt;
      
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataDueTo%NOTFOUND THEN
			--{
				CLOSE ExtractDataDueTo;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
    ELSE
    
    IF NOT ExtractDataDueFrom%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataDueFrom (vi_tranDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataDueFrom%ISOPEN THEN
		--{
				FETCH	ExtractDataDueFrom
			  INTO	 v_bankName, v_currentAmt, v_savingAmt, v_fixedAmt;
      
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataDueFrom%NOTFOUND THEN
			--{
				CLOSE ExtractDataDueFrom;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
   END IF;
   
    
    out_rec:=	(v_bankName|| '|' ||(v_currentAmt/1000000)
              || '|' || v_savingAmt/1000000|| '|' || v_fixedAmt/1000000);
    dbms_output.put_line(out_rec);
    
  END FIN_DUE_TO_FROM_LIST;

END FIN_DUE_TO_FROM_LIST;
/
