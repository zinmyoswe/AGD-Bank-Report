CREATE OR REPLACE PACKAGE FIN_DAILY_LIMIT_CHARGE AS

PROCEDURE FIN_DAILY_LIMIT_CHARGE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAILY_LIMIT_CHARGE;
 
/


CREATE OR REPLACE PACKAGE BODY               FIN_DAILY_LIMIT_CHARGE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  vi_EOD_DATE	   	Varchar2(10);               -- Input to procedure
  vi_Before_After_Type Varchar2(30);               -- Input to procedure
  vi_Within_Month  Varchar2(10);               -- Input to procedure
  vi_currency   Varchar2(10);               -- Input to procedure
  vi_currencyType Varchar2(30);               -- Input to procedure
  vi_SOL_ID			Varchar2(5);		   	    -- Input to procedure

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DAILY_LIMIT_CHARGE CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractDataAfterMMK (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2,ci_currency VARCHAR2, ci_SOLID VARCHAR2) IS
 select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= TO_date(ci_EntDATE, 'DD-MM-YYYY')
 and lht.lim_exp_date <= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),ci_Within_Month)
 and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 and lht.CRNCY_CODE = UPPER(ci_currency)
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' );
-----------------------------------------------------------------------------
CURSOR ExtractDataAfterAll (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2, ci_SOLID VARCHAR2) IS
select distinct q.ACID,q.account_name,
       CASE WHEN q.cur = 'MMK' THEN q.SANCT_LIM 
      ELSE q.SANCT_LIM * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS SANCT_LIM,
      q.cur,q.LIM_EXP_DATE
from
(select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE as cur, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= TO_date(ci_EntDATE, 'DD-MM-YYYY')
 and lht.lim_exp_date <= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),ci_Within_Month)
 and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 --and CRNCY_CODE = UPPER('MMK')
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' ))q;
-----------------------------------------------------------------------------
CURSOR ExtractDataAfterFCY (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2, ci_SOLID VARCHAR2) IS
select distinct q.ACID,q.account_name,
       CASE WHEN q.cur = 'MMK' THEN q.SANCT_LIM 
      ELSE q.SANCT_LIM * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS SANCT_LIM,
      q.cur,q.LIM_EXP_DATE
from
(select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE as cur, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= TO_date(ci_EntDATE, 'DD-MM-YYYY')
 and lht.lim_exp_date <= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),ci_Within_Month)
 and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 and lht.CRNCY_CODE != UPPER('MMK')
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' ))q;
-----------------------------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataBeforeMMK (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2,ci_currency VARCHAR2, ci_SOLID VARCHAR2) IS
 select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),'-'||ci_Within_Month)
 and lht.lim_exp_date <= TO_date(ci_EntDATE, 'DD-MM-YYYY')
 and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 and lht.CRNCY_CODE = UPPER(ci_currency)
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' );
-----------------------------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataBeforeAll (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2, ci_SOLID VARCHAR2) IS
select distinct q.ACID,q.account_name,
       CASE WHEN q.cur = 'MMK' THEN q.SANCT_LIM 
      ELSE q.SANCT_LIM * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS SANCT_LIM,
      q.cur,q.LIM_EXP_DATE
from
(select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE as cur, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),'-'||ci_Within_Month)
 and  
 lht.lim_exp_date <= TO_date(ci_EntDATE, 'DD-MM-YYYY')
and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 --and CRNCY_CODE = UPPER('MMK')
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' ))q;
-----------------------------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataBeforeFCY (ci_SchmCode VARCHAR2, ci_EntDATE VARCHAR2,ci_Within_Month VARCHAR2, ci_SOLID VARCHAR2) IS
select distinct q.ACID,q.account_name,
       CASE WHEN q.cur = 'MMK' THEN q.SANCT_LIM 
      ELSE q.SANCT_LIM * NVL( (SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = upper(q.cur) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              and RATECODE = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'FOREIGN_CURRENCY' 
                              and variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) where rownum = 1
                              ),1) END AS SANCT_LIM,
      q.cur,q.LIM_EXP_DATE
from
(select distinct ACID,
        (select gam.acct_name from tbaadm.gam gam where gam.acid = lht.acid) as account_name,
        SANCT_LIM, CRNCY_CODE as cur, LIM_EXP_DATE
 from
 tbaadm.lht lht where
 lht.lim_exp_date >= ADD_MONTHS(TO_date(ci_EntDATE, 'DD-MM-YYYY'),'-'||ci_Within_Month)
 and  
 lht.lim_exp_date <= TO_date(ci_EntDATE, 'DD-MM-YYYY')
and lht.del_flg = 'N'
 and lht.entity_cre_flg ='Y'
 and lht.status = 'A'
 and lht.CRNCY_CODE != UPPER('MMK')
 and lht.acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id like '%'|| ci_SOLID || '%'
	and bank_id = '01' ))q;
------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIN_DAILY_LIMIT_CHARGE(	inp_str IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
  
  vi_start_date TBAADM.LHT.LIM_EXP_DATE%type;
  vi_end_date TBAADM.LHT.LIM_EXP_DATE%type;
	v_Foracid 		TBAADM.GAM.FORACID%type;
	v_Acid 			TBAADM.GAM.ACID%type;
  v_acc_name  TBAADM.GAM.acct_name%type;
	v_SanLimit		TBAADM.LHT.SANCT_LIM%type;
	v_ExpDate		TBAADM.LHT.LIM_EXP_DATE%type;
	v_Days			Number;
	v_Charges		Number(17 ,2);
	v_CrncyCode		TBAADM.LHT.CRNCY_CODE%type;
	v_schm			CUSTOM.C_CGPM.variable_value%type;
	v_rate			Number(2);
  vi_rate     Number(2);
	v_BranchName 	TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
	v_BankAddress 	TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
	v_BankPhone 	TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
	v_BankFax 		TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  v_bank_des     TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%type;
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
    vi_EOD_DATE	:=  outArr(0);
    vi_Before_After_Type :=  outArr(1);
    vi_Within_Month :=  outArr(2);
    vi_currency :=  outArr(3);
    vi_currencyType :=  outArr(4);
    vi_SOL_ID	:=  outArr(5);

----------------------------------------------------------------------------------

if( vi_EOD_DATE is null or vi_Before_After_Type is null or vi_Within_Month is null or vi_currencyType is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		            '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-'  );
					
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;


------------------------------------------------------------------------------


	BEGIN
  -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
	-------------------------------------------------------------------------------
    If vi_SOL_ID is not null then
      select
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "BankAddress",
         BRANCH_CODE_TABLE.PHONE_NUM as "BankPhone",
         BRANCH_CODE_TABLE.FAX_NUM as "BankFax" ,
         SERVICE_OUTLET_TABLE.SOL_DESC as "Branch Description"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax ,v_bank_des
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    end if;
	--------------------------------------
	-- Get List of Schemes
	--------------------------------------
    select variable_value into v_schm from custom.c_cgpm where module_name = 'OD' and sub_module_name = 'ACCTMNT' and variable_name = 'SCHMCODE';

	--------------------------------------
	-- Get Rate Code
	--------------------------------------
    select variable_value into v_rate from custom.c_cgpm where module_name = 'OD' and sub_module_name = 'ACCTDATEMNT' and variable_name = 'RATE';

	--------------------------------------
	-- Get Days till Qtr End
	--------------------------------------
    select ADD_MONTHS(TRUNC(TO_DATE(vi_EOD_DATE,'DD-MM-YYYY') , 'Q'),3) - 1 - TO_DATE(vi_EOD_DATE,'DD-MM-YY')
	into v_Days from dual;

    END;
---------------------------------------------------------------------------------------------------------------


      If vi_Within_Month ='1' then
        vi_Within_Month := '1' ;
      elsif vi_Within_Month ='2' then
        vi_Within_Month := '2' ;
      elsif vi_Within_Month ='3' then
        vi_Within_Month := '3' ;
      elsif vi_Within_Month ='4' then
        vi_Within_Month := '4' ;
      elsif vi_Within_Month ='5' then
        vi_Within_Month := '5' ;
      elsif vi_Within_Month ='6' then
        vi_Within_Month := '6' ;
      elsif vi_Within_Month ='7' then
        vi_Within_Month := '7' ;
      elsif vi_Within_Month ='8' then
        vi_Within_Month := '8' ;
      elsif vi_Within_Month ='9' then
        vi_Within_Month := '9' ;
       elsif vi_Within_Month ='10' then
        vi_Within_Month := '10';
      elsif vi_Within_Month ='11' then
        vi_Within_Month := '11';
      elsif vi_Within_Month ='12' then
        vi_Within_Month := '12';
       end if;
	--------------------------------------
	-- Call Cursor for each Scheme
	--------------------------------------
  
  If vi_Before_After_Type like 'After%' then
   If vi_currencyType not like 'All%' then
   
    IF NOT ExtractDataAfterMMK%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataAfterMMK(v_schm, vi_EOD_DATE,vi_Within_Month,vi_currency, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataAfterMMK%ISOPEN THEN
	--{
		FETCH ExtractDataAfterMMK
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataAfterMMK%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataAfterMMK;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
  ELSIF vi_currencyType like 'All Currency' then
   
    IF NOT ExtractDataAfterAll%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataAfterAll(v_schm, vi_EOD_DATE,vi_Within_Month, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataAfterAll%ISOPEN THEN
	--{
		FETCH ExtractDataAfterAll
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataAfterAll%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataAfterAll;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
    
    ELSE --FCY
     IF NOT ExtractDataAfterFCY%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataAfterFCY(v_schm, vi_EOD_DATE,vi_Within_Month, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataAfterFCY%ISOPEN THEN
	--{
		FETCH ExtractDataAfterFCY
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataAfterFCY%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataAfterFCY;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
    
    end if;--currencytype
    ELSE --beforetype
    If vi_currencyType not like 'All%' then
   
    IF NOT ExtractDataBeforeMMK%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataBeforeMMK(v_schm, vi_EOD_DATE,vi_Within_Month,vi_currency, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataBeforeMMK%ISOPEN THEN
	--{
		FETCH ExtractDataBeforeMMK
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataBeforeMMK%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataBeforeMMK;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
  ELSIF vi_currencyType like 'All Currency' then
   
    IF NOT ExtractDataBeforeAll%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataBeforeAll(v_schm, vi_EOD_DATE,vi_Within_Month, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataBeforeAll%ISOPEN THEN
	--{
		FETCH ExtractDataBeforeAll
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataBeforeAll%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataBeforeAll;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
    
    ELSE --FCY
     IF NOT ExtractDataBeforeFCY%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataBeforeFCY(v_schm, vi_EOD_DATE,vi_Within_Month, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataBeforeFCY%ISOPEN THEN
	--{
		FETCH ExtractDataBeforeFCY
		INTO v_Acid,v_acc_name, v_SanLimit, v_CrncyCode, v_ExpDate;

		--------------------------------------
		-- Get Foracid from GAM
		--------------------------------------
		BEGIN
		select foracid into v_Foracid from tbaadm.gam where acid = v_Acid;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			v_Foracid := '';
		END;
		v_Charges := v_SanLimit * v_rate * v_Days / 36500;


		------------------------------------------------------------------
		-- Here it is checked whether the cursor has fetched
		-- something or not if not the cursor is closed
		-- and the out ret code is made equal to 1
		------------------------------------------------------------------
		IF ExtractDataBeforeFCY%NOTFOUND THEN
		--{
     /* out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des);

			dbms_output.put_line(out_rec);*/
			CLOSE ExtractDataBeforeFCY;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;
    end if;
    end if;
BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_currencyType      = 'Home Currency' THEN
      IF(upper(vi_currency) = 'MMK') THEN
        vi_rate            := 1;
      ELSE
        SELECT VAR_CRNCY_UNITS
        INTO vi_rate
        FROM tbaadm.RTL e
        WHERE TRIM(FXD_CRNCY_CODE) = upper(vi_currency)
        AND TRIM(VAR_CRNCY_CODE)   = 'MMK'
        AND RATECODE               =
          (SELECT variable_value
          FROM custom.CUST_GENCUST_PARAM_MAINT
          WHERE module_name = 'FOREIGN_CURRENCY'
          AND variable_name = 'RATE_CODE'
          )
        AND rownum = 1
        ORDER BY rtlist_date DESC;
      END IF;
      ELSIF vi_currencyType           = 'Source Currency' THEN
          IF(upper(vi_currency) = 'MMK') THEN
        vi_rate            := 1;
      ELSE
        SELECT VAR_CRNCY_UNITS
        INTO vi_rate
        FROM tbaadm.RTL e
        WHERE TRIM(FXD_CRNCY_CODE) = upper(vi_currency)
        AND TRIM(VAR_CRNCY_CODE)   = 'MMK'
        AND RATECODE               =
          (SELECT variable_value
          FROM custom.CUST_GENCUST_PARAM_MAINT
          WHERE module_name = 'FOREIGN_CURRENCY'
          AND variable_name = 'RATE_CODE'
          )
        AND rownum = 1
        ORDER BY rtlist_date DESC;
      END IF;
    ELSE
      vi_rate := 1;
    END IF;
  END;
	-----------------------------------------------------------------------------------
	-- out_rec variable retrieves the data to be sent to LST file with pipe separation
	------------------------------------------------------------------------------------
    out_rec:=	(
           v_Foracid  || '|' || v_acc_name || '|' || v_SanLimit  || '|' || v_CrncyCode || '|' || to_char(v_ExpDate, 'DD-MM-YYYY') || '|' ||
					v_Days || '|' || v_Charges || '|' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_bank_des || '|' ||
          vi_rate);

	dbms_output.put_line(out_rec);

END FIN_DAILY_LIMIT_CHARGE;

END FIN_DAILY_LIMIT_CHARGE;
/
