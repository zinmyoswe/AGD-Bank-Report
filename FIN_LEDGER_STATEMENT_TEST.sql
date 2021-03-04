CREATE OR REPLACE PACKAGE FIN_LEDGER_STATEMENT_TEST AS 

  PROCEDURE FIN_LEDGER_STATEMENT_TEST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_LEDGER_STATEMENT_TEST;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 FIN_LEDGER_STATEMENT_TEST AS

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

  

-----------------------------------------------------------------------------
-- CURSOR ExtractDataMMK
-----------------------------------------------------------------------------
CURSOR ExtractDataMMK (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2,ci_currencyCode VARCHAR2)  IS
    select *
    from (
      select   '' as tran_id,
                TO_DATE( CAST ( OpenDate AS VARCHAR(10) ) , 'dd-Mon-yy' ) as tran_date,
                dobal as dobal,
                null as CrAmt,
                'Opening Balance' as tran_particular,
                 null  as entry_user_id,
                null as dramt,
                null as brname,
                 0 as ForSort
        from    dual
        
        union all

         select   trim(t.tran_id) as tran_id,
                  t.tran_date,
                  case part_tran_type when 'C' then (SUBLEDGERESSENTIAL.CUSTOM_DOBAMOUNT(t.part_tran_type,t.cr_amt)) else(SUBLEDGERESSENTIAL.CUSTOM_DOBAMOUNT(t.part_tran_type,t.dr_amt)) end as aa,
                  case part_tran_type when 'C' then t.cr_amt else 0 end as CrAmt,
                  t.tran_particular   as tran_particular,
                  t.entry_user_id,
                  case part_tran_type when 'D' then t.Dr_amt else 0 end as drAmt,
                  t.abbr_br_name,
                  rownum as ForSort
          from 
          (select q.tran_id ,q.tran_date ,sum(q.CR_amt)as cr_amt,
          
          sum(q.DR_amt) as dr_amt,q.tran_particular,q.entry_user_id ,q.part_tran_type,q.abbr_br_name
          from
          (select
          
          cdav.tran_id ,
          cdav.tran_date ,
          gam.foracid,
          case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
          case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt,
          cdav.tran_particular,
          cdav.entry_user_id ,
          cdav.rate,
          cdav.part_tran_type,   --270
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
          and cdav.tran_crncy_code = gam.acct_crncy_code
          and gam.sol_id = cdav.sol_id
          and (trim (cdav.tran_id),/*trim(cdav.part_tran_srl_num),*/cdav.tran_date)
                                                                          NOT IN (select trim(atd.cont_tran_id),/* trim(atd.cont_part_tran_srl_num),*/atd.cont_tran_date
                                                                                from TBAADM.ATD atd
                                                                                where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
          order by cdav.tran_date
          ) q
          group by q.tran_id, q.tran_particular, q.entry_user_id, q.tran_date, q.part_tran_type,q.abbr_br_name
          order by q.tran_date)t
           order by ForSort,tran_date,tran_id
           )t
      order by t.forsort
           ;


-----------------------------------------------------------------------------
   -------------------------
  PROCEDURE FIN_LEDGER_STATEMENT_TEST(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    v_tran_id TBAADM.CTD_DTD_ACLI_VIEW.tran_id%type;
    v_tran_date TBAADM.CTD_DTD_ACLI_VIEW.tran_date%type;
    v_tran_amt TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_tran_amt_mmk TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_teller_no TBAADM.CTD_DTD_ACLI_VIEW.entry_user_id%type;
    v_part_tran_type TBAADM.CTD_DTD_ACLI_VIEW.part_tran_type%type;
    v_tran_amt_dr TBAADM.CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_tran_particular varchar2(50);
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
      output  varchar2(100);
      Result_Flg varchar2(100);
      

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
    vi_currencyType := outArr(2);
    v_cur           := outArr(3);
    vi_AccountNo	 :=  outArr(4);
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


        dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  --end if;
end ;


--dbms_output.put_line(v_gl_desc);
-------------------------------------------------------------------------------------------------------
if( vi_startDate is null or vi_endDate is null or vi_currencyType  is null or vi_AccountNo is null ) then
        --resultstr := 'No Data For Report';
       out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' ||  '-' || '|' || '-' || '|' || '-' || '|' || '-' );


        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;
  end if;

      
      begin
        select  tran_date_bal,  eod_date  INTO dobal,OpenDate
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
          EXCEPTION
      WHEN NO_DATA_FOUND THEN
        dobal := 0;
      end;
        -- dbms_output.put_line(dobal);
  begin
    Result_Flg := SUBLEDGERESSENTIAL.TODAYDOBAL(dobal);
  end;

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
     
      
  begin
----------------------------------------------------------------------------------------------
    IF NOT ExtractDataMMK%ISOPEN THEN
		--{
   -- dbms_output.put_line('Worked');
			BEGIN
			--{
				OPEN ExtractDataMMK(vi_startDate , vi_endDate, vi_AccountNo,v_cur) ;
			--}
			END;

		--}
		END IF;
    IF ExtractDataMMK%ISOPEN Then
      FETCH	ExtractDataMMK INTO	 v_tran_id,v_tran_date,dobal,v_tran_amt,v_tran_particular,v_teller_no,v_tran_amt_dr,v_sol,num;
        
     	------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
     -- dbms_output.put_line(v_tran_id);
			------------------------------------------------------------------
      IF ExtractDataMMK%NOTFOUND THEN
			--{
				CLOSE ExtractDataMMK;
				out_retCode:= 1;
         --dbms_output.put_line('Not Found');
				RETURN;
			--}
			END IF;

		--}
    END IF;
 end;

      
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec :=	(--to_char(to_date(v_tran_date,'dd/Mon/yy'), 'dd/MM/yyyy')||'|' ||
          v_tran_date  ||'|' ||
          v_tran_id 	|| '|' ||
          v_tran_particular || '|' ||
          v_tran_amt 	|| '|' ||
          v_tran_amt_dr 	|| '|' ||
          dobal 	|| '|' ||
          v_rate 	|| '|' ||
          v_teller_no || '|' ||
          v_sol || '|' ||
          v_cur   || '|' ||
          v_gl_desc);

			dbms_output.put_line(out_rec);
      dbms_output.put_line(out_retCode);

  END FIN_LEDGER_STATEMENT_TEST;

END FIN_LEDGER_STATEMENT_TEST;
/
