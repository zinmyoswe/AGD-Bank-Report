CREATE OR REPLACE PACKAGE FIN_QTR_LIMIT_CHARGE AS

PROCEDURE FIN_QTR_LIMIT_CHARGE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_QTR_LIMIT_CHARGE;
 
/


CREATE OR REPLACE PACKAGE BODY        FIN_QTR_LIMIT_CHARGE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  vi_QTR_DATE	   	Varchar2(10);               -- Input to procedure
  vi_SOL_ID			Varchar2(5);		   	    -- Input to procedure

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DAILY_LIMIT_CHARGE CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractDataForSchm (ci_SchmCode VARCHAR2, ci_StDATE VARCHAR2, ci_EndDATE VARCHAR2, ci_SOLID VARCHAR2) IS
 select distinct ACID, SANCT_LIM, CRNCY_CODE, LIM_EXP_DATE
 from
 tbaadm.lht where
 lim_exp_date <= TO_date(ci_EndDATE, 'DD-MM-YYYY')
 and del_flg = 'N'
 and entity_cre_flg ='Y'
 and status = 'A'
 and acid in
	(select acid
	from tbaadm.gam
	where schm_code in (select regexp_substr(ci_SchmCode,'[^ ]+', 1, level) from dual
 connect by regexp_substr(ci_SchmCode, '[^ ]+', 1, level) is not null)
	and acct_cls_flg = 'N'
	and sol_id = ci_SOLID
	and bank_id = '01' );

PROCEDURE FIN_QTR_LIMIT_CHARGE(	inp_str IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

	v_Foracid 		TBAADM.GAM.FORACID%type;
	v_Acid 			TBAADM.GAM.ACID%type;
	v_SanLimit		TBAADM.LHT.SANCT_LIM%type;
	v_ExpDate		TBAADM.LHT.LIM_EXP_DATE%type;
	v_Days			Number;
	v_Charges		Number(17 ,2);
	v_CrncyCode		TBAADM.LHT.CRNCY_CODE%type;
	v_schm			CUSTOM.C_CGPM.variable_value%type;
	v_rate			Number(2);
	v_StDate	   	Varchar2(10);
	v_EndDate	   	Varchar2(10);
	v_BranchName 	TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
	v_BankAddress 	TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
	v_BankPhone 	TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
	v_BankFax 		TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;

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
    vi_QTR_DATE	:=  outArr(0);
    vi_SOL_ID	:=  outArr(1);
-------------------------------------------------------------------------------------

if( vi_QTR_DATE is null or vi_SOL_ID is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' ||'-' || '|' || '-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

-----------------------------------------------------------------------------------------
	BEGIN
  -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
	-------------------------------------------------------------------------------
      select
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "BankAddress",
         BRANCH_CODE_TABLE.PHONE_NUM as "BankPhone",
         BRANCH_CODE_TABLE.FAX_NUM as "BankFax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
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
    select ADD_MONTHS(TRUNC(TO_DATE(vi_QTR_DATE,'DD-MM-YYYY'), 'Q') - 1, 0) -
	ADD_MONTHS(TRUNC(TO_DATE(vi_QTR_DATE,'DD-MM-YYYY'), 'Q'), -3) + 1,
	TO_CHAR(ADD_MONTHS(TRUNC(TO_DATE(vi_QTR_DATE,'DD-MM-YYYY'), 'Q'), -3), 'DD-MM-YYYY'),
	TO_CHAR(TRUNC(TO_DATE(vi_QTR_DATE,'DD-MM-YYYY'), 'Q') - 1, 'DD-MM-YYYY')
	into v_Days, v_StDate, v_EndDate  from dual;

    END;

	--------------------------------------
	-- Call Cursor for each Scheme
	--------------------------------------
    IF NOT ExtractDataForSchm%ISOPEN THEN
	--{
		BEGIN
		--{
			OPEN ExtractDataForSchm(v_schm, v_StDate, v_EndDate, vi_SOL_ID);
		--}
		END;
	--}
	END IF;

    IF ExtractDataForSchm%ISOPEN THEN
	--{
		FETCH ExtractDataForSchm
		INTO v_Acid, v_SanLimit, v_CrncyCode, v_ExpDate;

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
		IF ExtractDataForSchm%NOTFOUND THEN
		--{
      out_rec:=	('||||||' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax);

			dbms_output.put_line(out_rec);
			CLOSE ExtractDataForSchm;
			out_retCode:= 1;
			RETURN;
		--}
		END IF;


	--}
    END IF;

	-----------------------------------------------------------------------------------
	-- out_rec variable retrieves the data to be sent to LST file with pipe separation
	------------------------------------------------------------------------------------
    out_rec:=	(
           v_Foracid  || '|' || v_SanLimit  || '|' || v_CrncyCode || '|' || to_char(v_ExpDate, 'DD-MM-YYYY') || '|' ||
					v_Days || '|' || v_Charges || '|' || v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );

	dbms_output.put_line(out_rec);

END FIN_QTR_LIMIT_CHARGE;

END FIN_QTR_LIMIT_CHARGE;
/
