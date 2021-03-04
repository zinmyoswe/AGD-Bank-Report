CREATE OR REPLACE PACKAGE                                    FIN_LEDGER_STATEMENT AS

   PROCEDURE FIN_LEDGER_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_LEDGER_STATEMENT;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                FIN_LEDGER_STATEMENT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  --3021210106578
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_AccountNo		Varchar2(100);		    	    -- Input to procedure
  vi_currencyType Varchar2(50);            -- Input to procedure
  v_cur Varchar2(20);

  v_sol_id Varchar2(20);
   v_rate decimal;
  num number;
  dobal TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type := 0.00;
  result_rec Varchar2(30000);
  OpeningAmount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  OpenDate		Varchar2(10);
  limitsize  INTEGER := 800;

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractDataMMK
-----------------------------------------------------------------------------
CURSOR ExtractDataMMK (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2,ci_currencyCode VARCHAR2)  IS

  select q.tran_id ,q.tran_date ,sum(q.CR_amt)as cr_amt,sum(q.DR_amt) as dr_amt,q.tran_particular,q.entry_user_id ,q.part_tran_type,q.abbr_br_name
  from
  (select
  
  cdav.tran_id ,
  cdav.tran_date ,
  case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
  case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt,
  cdav.tran_particular,
  cdav.entry_user_id ,
  cdav.part_tran_type,
  (select sol.abbr_br_name from tbaadm.sol,tbaadm.upr upr where sol.sol_id = cdav.dth_init_sol_id and upr.user_id = cdav.entry_user_id) as abbr_br_name
  from
  tbaadm.general_acct_mast_table gam,custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
  where
  gam.acid = cdav.acid
  and gam.foracid = ci_AccountNo
  and cdav.tran_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and cdav.bank_id ='01'
  and cdav.DEL_FLG <> 'Y'
  and cdav.TRAN_CRNCY_CODE = Upper(ci_currencyCode )
  and cdav.tran_crncy_code = Upper(ci_currencyCode )
  and gam.acct_crncy_code = Upper(ci_currencyCode)
  and gam.sol_id = cdav.sol_id
  and (trim (cdav.tran_id),trim(cdav.part_tran_srl_num),cdav.tran_date) NOT IN (select trim(atd.cont_tran_id), trim(atd.cont_part_tran_srl_num),atd.cont_tran_date
                                                                                from TBAADM.ATD atd
                                                                                where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by cdav.tran_date
  ) q
  group by q.tran_id, q.tran_particular, q.entry_user_id, q.tran_date, q.part_tran_type,q.abbr_br_name
  order by q.tran_date;

-----------------------------------------------------------------------------
-- CURSOR ExtractDataAll
-----------------------------------------------------------------------------
CURSOR ExtractDataAll (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2)  IS

  select T.tran_id ,T.tran_date,sum(T.CR_amt)as cr_amt,sum(T.DR_amt) as dr_amt,T.tran_particular,T.entry_user_id ,T.part_tran_type,T.abbr_br_name
  from(
  select  q.tran_id, q.tran_date,
  CASE WHEN q.cur = 'MMK' THEN q.CR_amt
                 ELSE q.CR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt,
  CASE WHEN q.cur = 'MMK' THEN q.DR_amt
                 ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  q.tran_particular,q.entry_user_id ,q.part_tran_type,q.abbr_br_name

  from
  (select
  
  cdav.tran_id ,
  cdav.tran_date ,
  case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
  case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt,
  cdav.tran_particular,
  cdav.entry_user_id ,
  cdav.part_tran_type,
  (select sol.abbr_br_name from tbaadm.sol,tbaadm.upr upr where sol.sol_id = cdav.dth_init_sol_id and upr.user_id = cdav.entry_user_id) as abbr_br_name,
  cdav.tran_crncy_code as cur

  from
  tbaadm.general_acct_mast_table gam,custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
  where
  gam.acid = cdav.acid
  and gam.foracid = ci_AccountNo
  and cdav.tran_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg != 'Y'
  and cdav.DEL_FLG <> 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and cdav.bank_id ='01'
  and gam.sol_id = cdav.sol_id
  and (trim (cdav.tran_id),trim(cdav.part_tran_srl_num),cdav.tran_date) NOT IN (select trim(atd.cont_tran_id), trim(atd.cont_part_tran_srl_num),atd.cont_tran_date
                                                                                from TBAADM.ATD atd
                                                                                where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by cdav.tran_date
  ) q
  --group by q.tran_id, q.tran_particular, q.entry_user_id, q.tran_date, q.part_tran_type,q.cur
  order by q.tran_date)T
  group by T.tran_id, T.tran_particular, T.entry_user_id, T.tran_date, T.part_tran_type,T.abbr_br_name;

 -----------------------------------------------------------------------------
-- CURSOR ExtractDataAllFCY
-----------------------------------------------------------------------------
CURSOR ExtractDataAllFCY (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2)  IS

  select T.tran_id ,T.tran_date ,sum(T.CR_amt)as cr_amt,sum(T.DR_amt) as dr_amt,T.tran_particular,T.entry_user_id ,T.part_tran_type,T.abbr_br_name
  from(
  select  q.tran_id, q.tran_date,
   CASE WHEN q.cur = 'MMK' THEN q.CR_amt
                 ELSE q.CR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt,
  CASE WHEN q.cur = 'MMK' THEN q.DR_amt
                 ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  q.tran_particular,q.entry_user_id ,q.part_tran_type,q.abbr_br_name

  from
  (select
  
  cdav.tran_id ,
  cdav.tran_date ,
  case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
  case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt,
  cdav.tran_particular,
  cdav.entry_user_id ,
  cdav.part_tran_type,
  (select sol.abbr_br_name from tbaadm.sol,tbaadm.upr upr where sol.sol_id = cdav.dth_init_sol_id and upr.user_id = cdav.entry_user_id) as abbr_br_name,
  cdav.tran_crncy_code as cur

  from
  tbaadm.general_acct_mast_table gam,custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav
  where
  gam.acid = cdav.acid
  and gam.foracid = ci_AccountNo
  and cdav.tran_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg != 'Y'
  and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and cdav.bank_id ='01'
  and cdav.DEL_FLG <> 'Y'
  and cdav.TRAN_CRNCY_CODE != Upper('MMK' )
  and cdav.tran_crncy_code != Upper('MMK' )
  and gam.acct_crncy_code != Upper('MMK')
  and gam.sol_id = cdav.sol_id
  and (trim (cdav.tran_id),trim(cdav.part_tran_srl_num),cdav.tran_date) NOT IN (select trim(atd.cont_tran_id), trim(atd.cont_part_tran_srl_num),atd.cont_tran_date
                                                                                from TBAADM.ATD atd
                                                                                where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by cdav.tran_date
  ) q
  --group by q.tran_id, q.tran_particular, q.entry_user_id, q.tran_date, q.part_tran_type,q.cur
  order by q.tran_date)T
  group by T.tran_id, T.tran_particular, T.entry_user_id, T.tran_date, T.part_tran_type,T.abbr_br_name;

--------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataForResult IS
select  trim(tran_id),tran_date,dobal,tran_amt,tran_particular,teller_no,tran_amt_dr,rate,sol_id from TEMP_TABLE order by ID;

   TYPE mainretailtable IS TABLE OF ExtractDataMMK%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtable         mainretailtable;
   TYPE mainretailtable1 IS TABLE OF ExtractDataAll%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtable1         mainretailtable1;
   TYPE mainretailtable2 IS TABLE OF ExtractDataAllFCY%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtable2         mainretailtable2;

   -------------------------
  PROCEDURE FIN_LEDGER_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    v_tran_id TBAADM.CTD_DTD_ACLI_VIEW.tran_id%type;
    v_tran_date TBAADM.CTD_DTD_ACLI_VIEW.tran_date%type;
    v_tran_amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_tran_amt_mmk TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_teller_no TBAADM.CTD_DTD_ACLI_VIEW.entry_user_id%type;
    v_part_tran_type TBAADM.CTD_DTD_ACLI_VIEW.part_tran_type%type;
    v_tran_amt_dr TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_tran_particular TBAADM.CTD_DTD_ACLI_VIEW.tran_particular%type;
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_sol tbaadm.sol.abbr_br_name%type;
    v_cur TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_crncy_code%type;
    v_Address varchar2(200);
    v_Nrc CRMUSER.ACCOUNTS.UNIQUEID%type;
    v_Bal TBAADM.GENERAL_ACCT_MAST_TABLE.clr_bal_amt%type;
    v_PhoneNumber varchar2(50);
    v_FaxNumber varchar2(50);
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      v_gl_desc Varchar2(200);

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

    vi_startDate  :=  outArr(0);
    vi_endDate    :=  outArr(1);
    vi_currencyType := outArr(2);
    v_cur   := outArr(3);
    vi_AccountNo	:=  outArr(4);
   -- v_CurrencyCode := outArr(3);
-----------------------------------------------------------------------------------------------------
  begin
-- if vi_branchcode is not null then
   select acct_name
  into v_gl_desc
  from tbaadm.gam
  where
gam.foracid = vi_AccountNo
and rownum =1 ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' ||  '-' || '|' || '-' || '|' || '-' || '|' || '-' );


        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  --end if;
end ;
-------------------------------------------------------------------------------------------------------
if( vi_startDate is null or vi_endDate is null or vi_currencyType  is null or vi_AccountNo is null ) then
        --resultstr := 'No Data For Report';
       out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' ||  '-' || '|' || '-' || '|' || '-' || '|' || '-' );


        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;


--------------------------------------------------------------------------------
 IF vi_currencyType NOT LIKE 'All%' then  --for HomeCurrency and Source Currency
    IF NOT ExtractDataMMK%ISOPEN THEN
		--{
			BEGIN
			--{
      	OPEN ExtractDataMMK (vi_startDate , vi_endDate, vi_AccountNo,v_cur);
			--}
			END;

		--}
		END IF;

    IF ExtractDataMMK%ISOPEN Then
		--{
    Begin
   select  tran_date_bal,eod_date  INTO OpeningAmount,OpenDate
   from tbaadm.eab,tbaadm.general_acct_mast_table gam
   where gam.acid = tbaadm.eab.acid
   and eod_date = ( select  eod_date   from(
        select eod_date
        from tbaadm.eab eab,tbaadm.gam gam
        where eab.eod_date < TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and gam.foracid = vi_AccountNo
        and gam.acid = tbaadm.eab.acid
        order by eod_date desc)
        where rownum =1)
   and gam.foracid = vi_AccountNo;
   /*and gam.gl_sub_head_code = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'Report'
                              and variable_name = 'Cash in Hand (Vault)') ;--cash in hand(vault)*/

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OpeningAmount := 0.00;
   end;

      delete from custom.TEMP_TABLE ; commit;
      dobal := OpeningAmount;

      insert into custom.TEMP_TABLE(Tran_Date,dobal,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID)
      values(TO_DATE( CAST ( OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ),OpeningAmount,v_tran_amt,'','Opening Balance',v_part_tran_type,0);
      commit;
      FETCH	ExtractDataMMK	BULK COLLECT INTO ptmainretailtable ;     --outer Cursor
      select acct_crncy_code into v_cur from tbaadm.gam where gam.foracid = vi_AccountNo and rownum = 1;
      FOR outindx IN 1 .. ptmainretailtable.COUNT            --outer For loop
      LOOP
        if ptmainretailtable (outindx).part_tran_type = 'C' then
          dobal := dobal + ptmainretailtable (outindx).cr_amt;


       -- end if;
        v_tran_date := ptmainretailtable (outindx).tran_date;
        v_tran_id := ptmainretailtable (outindx).tran_id;
        v_tran_amt := ptmainretailtable (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable (outindx).dr_amt;
        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable (outindx).tran_particular;
        v_teller_no := ptmainretailtable (outindx).entry_user_id;
        v_sol := ptmainretailtable (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
        elsif ptmainretailtable (outindx).part_tran_type = 'D' then
          dobal := dobal - ptmainretailtable (outindx).dr_amt;
          v_tran_date := ptmainretailtable (outindx).tran_date;
        v_tran_id := ptmainretailtable (outindx).tran_id;
        v_tran_amt := ptmainretailtable (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable (outindx).dr_amt;
        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable (outindx).tran_particular;
        v_teller_no := ptmainretailtable (outindx).entry_user_id;
        v_sol := ptmainretailtable (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
        end if;
      END LOOP;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataMMK%NOTFOUND THEN
			--{
				CLOSE ExtractDataMMK;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;

		--}
    END IF;
-----------------------------------------------------------------------------------------------
ELSIF vi_currencyType ='All Currency' then
    IF NOT ExtractDataAll%ISOPEN THEN
		--{
			BEGIN
			--{
      	OPEN ExtractDataAll (vi_startDate , vi_endDate, vi_AccountNo);
			--}
			END;

		--}
		END IF;

    IF ExtractDataAll%ISOPEN Then
		--{
    Begin
   select  tran_date_bal,eod_date  INTO OpeningAmount,OpenDate
   from tbaadm.eab,tbaadm.general_acct_mast_table gam
   where gam.acid = tbaadm.eab.acid
   and eod_date = ( select  eod_date   from(
        select eod_date
        from tbaadm.eab eab,tbaadm.gam gam
        where eab.eod_date < TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and gam.foracid = vi_AccountNo
        and gam.acid = tbaadm.eab.acid
        order by eod_date desc)
        where rownum =1)
   and gam.foracid = vi_AccountNo;
   /*and gam.gl_sub_head_code = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'Report'
                              and variable_name = 'Cash in Hand (Vault)') ;--cash in hand(vault)*/

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OpeningAmount := 0.00;
   end;

      delete from custom.TEMP_TABLE ; commit;
      dobal := OpeningAmount;
      dbms_output.put_line(dobal);
      insert into custom.TEMP_TABLE(Tran_Date,dobal,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID)
      values(TO_DATE( CAST ( OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ),OpeningAmount,v_tran_amt,'','Opening Balance',v_part_tran_type,0);
      commit;
      FETCH	ExtractDataAll	BULK COLLECT INTO ptmainretailtable1 ;     --outer Cursor
     select acct_crncy_code into v_cur from tbaadm.gam where gam.foracid = vi_AccountNo and rownum = 1 ;
      FOR outindx IN 1 .. ptmainretailtable1.COUNT            --outer For loop
      LOOP
        if ptmainretailtable1 (outindx).part_tran_type = 'C' then
          dobal := dobal + ptmainretailtable1 (outindx).cr_amt;
          dbms_output.put_line(dobal);

       -- end if;
        v_tran_date := ptmainretailtable1 (outindx).tran_date;
        v_tran_id := ptmainretailtable1 (outindx).tran_id;
       -- v_cur    : =ptmainretailtable1 (outindx).cur;
        v_tran_amt := ptmainretailtable1 (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable1 (outindx).dr_amt;

        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable1 (outindx).tran_particular;
        v_teller_no := ptmainretailtable1 (outindx).entry_user_id;
        v_sol := ptmainretailtable1 (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
          dbms_output.put_line(dobal);

          elsif ptmainretailtable1 (outindx).part_tran_type = 'D' then
          dobal := dobal - ptmainretailtable1 (outindx).dr_amt;
          dbms_output.put_line(dobal);
          v_tran_date := ptmainretailtable1 (outindx).tran_date;
        v_tran_id := ptmainretailtable1 (outindx).tran_id;
       -- v_cur    : =ptmainretailtable1 (outindx).cur;
        v_tran_amt := ptmainretailtable1 (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable1 (outindx).dr_amt;

        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable1 (outindx).tran_particular;
        v_teller_no := ptmainretailtable1 (outindx).entry_user_id;
        v_sol := ptmainretailtable1 (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
        end if;
      END LOOP;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataAll%NOTFOUND THEN
			--{
				CLOSE ExtractDataAll;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;

		--}
    END IF;
ELSE-- for AllCurrency(FCY)
      IF NOT ExtractDataAllFCY%ISOPEN THEN
		--{
			BEGIN
			--{
      	OPEN ExtractDataAllFCY (vi_startDate , vi_endDate, vi_AccountNo);
			--}
			END;

		--}
		END IF;

    IF ExtractDataAllFCY%ISOPEN Then
		--{
    Begin
   select  tran_date_bal,eod_date  INTO OpeningAmount,OpenDate
   from tbaadm.eab,tbaadm.general_acct_mast_table gam
   where gam.acid = tbaadm.eab.acid
   and eod_date = ( select  eod_date   from(
        select eod_date
        from tbaadm.eab eab,tbaadm.gam gam
        where eab.eod_date < TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and gam.foracid = vi_AccountNo
        and gam.acid = tbaadm.eab.acid
        order by eod_date desc)
        where rownum =1)
   and gam.foracid = vi_AccountNo;
   /*and gam.gl_sub_head_code = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT
                              where module_name = 'Report'
                              and variable_name = 'Cash in Hand (Vault)') ;--cash in hand(vault)*/

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OpeningAmount := 0.00;
   end;

      delete from custom.TEMP_TABLE ; commit;
      dobal := OpeningAmount;
      insert into custom.TEMP_TABLE(Tran_Date,dobal,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID)
      values(TO_DATE( CAST ( OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ),OpeningAmount,v_tran_amt,'','Opening Balance',v_part_tran_type,0);
      commit;
      FETCH	ExtractDataAllFCY	BULK COLLECT INTO ptmainretailtable2 ;     --outer Cursor
     select acct_crncy_code into v_cur from tbaadm.gam where gam.foracid = vi_AccountNo and rownum = 1;
      FOR outindx IN 1 .. ptmainretailtable2.COUNT            --outer For loop
      LOOP
        if ptmainretailtable2 (outindx).part_tran_type = 'C' then
          dobal := dobal + ptmainretailtable2 (outindx).cr_amt;

        --end if;
        v_tran_date := ptmainretailtable2 (outindx).tran_date;
        v_tran_id := ptmainretailtable2 (outindx).tran_id;
        v_tran_amt := ptmainretailtable2 (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable2 (outindx).dr_amt;
        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable2 (outindx).tran_particular;
        v_teller_no := ptmainretailtable2 (outindx).entry_user_id;
        v_sol := ptmainretailtable2 (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
         elsif ptmainretailtable2 (outindx).part_tran_type = 'D' then
          dobal := dobal - ptmainretailtable2 (outindx).dr_amt;
          v_tran_date := ptmainretailtable2 (outindx).tran_date;
        v_tran_id := ptmainretailtable2 (outindx).tran_id;
        v_tran_amt := ptmainretailtable2 (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtable2 (outindx).dr_amt;
        --v_tran_type := ptmainretailtable (outindx).tran_type;
        --v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable2 (outindx).tran_particular;
        v_teller_no := ptmainretailtable2 (outindx).entry_user_id;
        v_sol := ptmainretailtable2 (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol);
        commit;
        end if;
      END LOOP;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataAllFCY%NOTFOUND THEN
			--{
				CLOSE ExtractDataAllFCY;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;

		--}
    END IF;
END IF;--currencytype

----------------------------------------------------------------------------------------------
    IF NOT ExtractDataForResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForResult ;
			--}
			END;

		--}
		END IF;
    IF ExtractDataForResult%ISOPEN Then
      FETCH	ExtractDataForResult INTO	 v_tran_id,v_tran_date,dobal,v_tran_amt,v_tran_particular,v_teller_no,v_tran_amt_dr,v_rate,v_sol;
     	------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataForResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataForResult;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;

		--}
    END IF;

  ----------------to get daily rate of account
      begin
      IF vi_currencyType           = 'Home Currency' THEN
      if upper(v_cur) = 'MMK' THEN v_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into v_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(v_cur)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
      ELSIF vi_currencyType           = 'Source Currency' THEN
        v_rate            := 1;
    ELSE
      v_rate := 1;
    END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_rate := 1;
      end;
----------------------------------------------------------------------------------
     /*BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
      select
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = ''
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';

  END;*/


    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    dbms_output.put_line(dobal);
    out_rec:=	(to_char(to_date(v_tran_date,'dd/Mon/yy'), 'dd/MM/yyyy')||'|' ||
          v_tran_id 	|| '|' ||
          v_tran_particular || '|' ||
          v_tran_amt 	|| '|' ||
          v_tran_amt_dr 	|| '|' ||
          dobal 	|| '|' ||
          v_rate 	|| '|' ||
          v_teller_no || '|' ||
          v_sol || '|' ||
          --v_BranchName	|| '|' ||
					--v_BankAddress      			|| '|' ||
					--v_BankPhone || '|' ||
          --v_BankFax || '|' ||
          v_cur   || '|' ||
          v_gl_desc);
  dbms_output.put_line(dobal);
			--dbms_output.put_line(out_rec);

  END FIN_LEDGER_STATEMENT;

END FIN_LEDGER_STATEMENT;
/
