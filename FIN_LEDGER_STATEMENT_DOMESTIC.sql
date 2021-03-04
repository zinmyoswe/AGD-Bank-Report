CREATE OR REPLACE PACKAGE                                           FIN_LEDGER_STATEMENT_DOMESTIC AS 

   PROCEDURE FIN_LEDGER_STATEMENT_DOMESTIC(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_LEDGER_STATEMENT_DOMESTIC;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                          FIN_LEDGER_STATEMENT_DOMESTIC AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  --3021210106578
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_AccountNo		Varchar2(25);		    	    -- Input to procedure
  vi_currency	   	Varchar2(3);               -- Input to procedure
  vi_branchcode  Varchar2(5);           -- Input to procedure
  
  v_cur Varchar2(20);
  --v_sol_id Varchar2(20);
  v_rate decimal(18,2);
  num number;
  dobal custom.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type := 0;		    	  
  result_rec Varchar2(30000);
  OpeningAmount custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  limitsize  INTEGER := 500;
  OpenDate		Varchar2(10);		
  rate decimal(18,2);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData_WithHO (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2,ci_currency VARCHAR2,ci_SOL_ID varchar2)  IS
  select q.tran_id ,q.tran_date ,sum(q.CR_amt)as cr_amt,sum(q.DR_amt) as dr_amt,q.tran_particular,q.entry_user_id ,
  q.part_tran_type,q.abbr_br_name
  from
  (select 
  cdav.tran_id ,
  cdav.tran_date ,
  case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
  case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt,
  cdav.tran_particular,
  cdav.entry_user_id ,
  cdav.part_tran_type,
  (select sol.abbr_br_name from tbaadm.upr,tbaadm.sol where sol.sol_id = upr.sol_id and upr.user_id = cdav.entry_user_id) as abbr_br_name
  from 
  tbaadm.general_acct_mast_table gam,custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav,tbaadm.sol sol
  where 
  gam.acid = cdav.acid
  and gam.sol_id = sol.sol_id
  and cdav.sol_id = sol.sol_id
  and gam.gl_sub_head_code = trim(ci_AccountNo)
  and gam.gl_sub_head_code = cdav.gl_sub_head_code
  and cdav.tran_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and cdav.TRAN_CRNCY_CODE= Upper(ci_currency )
  and gam.acct_crncy_code = upper(ci_currency)
  and gam.del_flg != 'Y'
  and cdav.del_flg = 'N'
  and gam.sol_id  like   '%' || ci_SOL_ID || '%'
  and cdav.sol_id  like   '%' || ci_SOL_ID || '%'
  --and gam.acct_cls_flg != 'Y'
  and gam.bank_id ='01'
  and gam.sol_id = cdav.sol_id
  and trim (cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
    where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  ) q
  group by q.tran_id, q.tran_particular, q.entry_user_id, q.tran_date, q.part_tran_type,q.abbr_br_name
  order by q.tran_date,q.abbr_br_name;

---------------------------------------------------------------------------------------------
  
CURSOR ExtractDataForResult IS
select  trim(tran_id),tran_date,dobal,tran_amt,tran_particular,teller_no,tran_amt_dr,rate ,sol_id
from TEMP_TABLE order by ID;
  
   TYPE mainretailtableWithHO IS TABLE OF ExtractData_WithHO%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtableWithHO         mainretailtableWithHO;
  
 
   ---------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_LEDGER_STATEMENT_DOMESTIC(	inp_str      IN  VARCHAR2,
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
    v_Cur TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_crncy_code%type;
    v_Address varchar2(200);
    v_Nrc CRMUSER.ACCOUNTS.UNIQUEID%type;
    v_Bal TBAADM.GENERAL_ACCT_MAST_TABLE.clr_bal_amt%type;
    v_PhoneNumber varchar2(50);
    v_FaxNumber varchar2(50);
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
    v_sol_id  TBAADM.sol.sol_id%type;
    v_gl_desc TBAADM.gsh.gl_sub_head_desc %type;
    
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
    vi_AccountNo	:=  outArr(2);
    vi_currency := outArr(3);
    vi_branchcode := outArr(4);
    
  IF vi_branchcode IS  NULL or vi_branchcode = ''  THEN
  vi_branchcode := '';
  END IF;
  --------------------------------------------------------------------
 IF vi_branchcode IS  NULL or vi_branchcode = ''  THEN
  v_gl_desc := '';
  END IF;
-----------------------------------------------------------------------------------
  IF NOT ExtractData_WithHO%ISOPEN THEN
		--{
			BEGIN
			--{     
   				OPEN ExtractData_WithHO (vi_startDate , vi_endDate, vi_AccountNo,vi_currency,vi_branchcode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_WithHO%ISOPEN Then
		--{
    Begin 
    
    select    
  sum(gstt.tot_cr_bal - gstt.tot_dr_bal) as cashinhand,BAL_DATE INTO OpeningAmount,OpenDate
from 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt
where gstt.BAL_DATE = ( select  max(BAL_DATE)  
            from(
              select BAL_DATE
              from tbaadm.gstt
              where tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              and gstt.SOL_ID like   '%' || vi_branchcode  || '%'
              and gstt.crncy_code  = upper(vi_currency)
              and gstt.gl_sub_head_code = vi_AccountNo
              order by BAL_DATE desc)  where rownum =1
              )
   and gstt.SOL_ID like   '%' || vi_branchcode || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N' 
   and gstt.BANK_ID = '01'
   and  gstt.gl_sub_head_code = vi_AccountNo
   and gstt.crncy_code = upper(vi_currency)  group by BAL_DATE;
   
  
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OpeningAmount := 0.00;  
        OpenDate := '';
   end;
   
      delete from custom.TEMP_TABLE ; commit;  
      dobal := OpeningAmount;
      insert into custom.TEMP_TABLE(Tran_Date,dobal,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID) 
      values(TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ),OpeningAmount,v_tran_amt,'','Opening Balance',v_part_tran_type,0);
      commit;
      FETCH	ExtractData_WithHO	BULK COLLECT INTO ptmainretailtableWithHO;     --outer Cursor  
     
     -- select acct_crncy_code into v_cur from tbaadm.gam where gam.gl_sub_head_code = vi_AccountNo and rownum = 1 order by sol_id ;
      
      FOR outindx IN 1 .. ptmainretailtableWithHO.COUNT            --outer For loop
      LOOP 
        if ptmainretailtableWithHO (outindx).part_tran_type = 'C' then
          dobal := dobal + ptmainretailtableWithHO (outindx).cr_amt;
        else if ptmainretailtableWithHO (outindx).part_tran_type = 'D' then
          dobal := dobal - ptmainretailtableWithHO (outindx).dr_amt;
        end if;
        end if;
        v_tran_date := ptmainretailtableWithHO (outindx).tran_date;
  ----------------to get daily rate of account 
      begin
     if vi_currency = 'MMK' THEN v_rate := 1 ;
     ELSE select VAR_CRNCY_UNITS into v_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = v_tran_date
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
      end if;   
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_rate := 1;
      end;
    ----------------to get daily rate of account 
        v_tran_id := ptmainretailtableWithHO (outindx).tran_id;
        v_tran_amt := ptmainretailtableWithHO (outindx).cr_amt;
        v_tran_amt_dr := ptmainretailtableWithHO (outindx).dr_amt;
        --v_tran_type := ptmainretailtableWithHO (outindx).tran_type;
        --v_part_tran_type := ptmainretailtableWithHO (outindx).part_tran_type;
        v_tran_particular := ptmainretailtableWithHO (outindx).tran_particular;
        v_teller_no := ptmainretailtableWithHO (outindx).entry_user_id;
        v_sol_id := ptmainretailtableWithHO (outindx).abbr_br_name;
        insert into custom.TEMP_TABLE(Tran_Date,dobal,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID,tran_id,teller_no,tran_amt_dr,rate,sol_id) 
        values(v_tran_date,dobal,v_tran_amt,'',v_tran_particular,'',outindx,v_tran_id,v_teller_no,v_tran_amt_dr,v_rate,v_sol_id);
        commit;
                           
      END LOOP;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData_WithHO%NOTFOUND THEN
			--{
				CLOSE ExtractData_WithHO;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    
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
      FETCH	ExtractDataForResult INTO	 v_tran_id,v_tran_date,dobal,v_tran_amt,v_tran_particular,v_teller_no,v_tran_amt_dr,v_rate,v_sol_id;
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
    
   -------------------------------------------------------------------
     begin
 --if vi_branchcode is not null then
   select gl_sub_head_desc
  into v_gl_desc 
  from tbaadm.gsh 
  where
  gl_sub_head_code = vi_AccountNo
  and gsh.crncy_code = vi_currency 
 and gsh.sol_id like '%' || vi_branchcode || '%'  
 and rownum =1 ;
 --end if;
end ; 
   --------------------------------------------------------------------
   
   
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
   if vi_branchcode is not null then
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
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchcode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
        end if; 
  END;
    
 
 
  
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(to_char(to_date(v_tran_date,'dd/Mon/yy'), 'dd/MM/yyyy')||'|' ||
          v_tran_id 	|| '|' || 
          v_tran_particular || '|' || 
          v_tran_amt 	|| '|' || 
          v_tran_amt_dr 	|| '|' || 
          dobal 	|| '|' || 
          v_rate 	|| '|' || 
          v_teller_no || '|' || 
          v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_cur ||'|'||
          v_sol_id ||'|'||
          v_gl_desc);
  
			--dbms_output.put_line(out_rec);
    
  END FIN_LEDGER_STATEMENT_DOMESTIC;

END FIN_LEDGER_STATEMENT_DOMESTIC;
/
