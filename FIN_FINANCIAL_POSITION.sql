CREATE OR REPLACE PACKAGE                                                         FIN_FINANCIAL_POSITION AS 

 PROCEDURE FIN_FINANCIAL_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FINANCIAL_POSITION;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                       FIN_FINANCIAL_POSITION AS
--{
	-------------------------------------------------------------------------------------
  --updated by Saung Hnin Oo (8-5-2017)
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
	-------------------------------------------------------------------------------------
	outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_StartDate	   	Varchar2(10);               	-- Input to procedure
 -- vi_StartDate	   	Varchar2(10);               	-- Input to procedure
  v_BranchCode	   	Varchar2(15);               	-- Input to procedure
    num number;
    
   CURSOR ExtractData (	
			ci_BranchCode VARCHAR2)   IS      
       select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"         
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = ci_BranchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
         
         
      CURSOR ExtractDataHO (	
			ci_BranchCode VARCHAR2)  IS      
       select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"         
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = '10100'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
-----------------------------------------------------------------------------
-- Procedure declaration FIN_Training_SPBX Procedure
-----------------------------------------------------------------------------
	PROCEDURE FIN_FINANCIAL_POSITION(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

	IS
  
 
	--{
	-------------------------------------------------------------
	--Variable declaration
	-------------------------------------------------------------
 --   B_date TBAADM.GL_SUB_HEAD_TRAN_TABLE.bal_date%type;
    PaidUp_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Current_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Saving_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Special_amt  TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Fixed_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Income_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Charges_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Free_T_bondA11  TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Free_T_bondL31  TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Cash_amt  TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    CBM_amt TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    Total_loan TBAADM.GL_SUB_HEAD_TRAN_TABLE.tot_dr_bal%type;
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  ---------------------
 BEGIN
	--{
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
    	
		vi_StartDate:=outArr(0);
   -- vi_StartDate:=outArr(1);		
if v_BranchCode is not null then
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (v_BranchCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
		INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax;
      

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
    END IF;
    ELSE --branchcode is null
    IF NOT ExtractDataHO%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataHO(v_BranchCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataHO%ISOPEN THEN
		--{
			FETCH	ExtractDataHO
		INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataHO%NOTFOUND THEN
			--{
				CLOSE ExtractDataHO;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;

	end if;
  
  -----------------------------------------------------------
  ------------------Paid UP-----------------------------------
  begin
  SELECT 
sum(T.amt)  into PaidUp_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-(gstt.tot_cr_bal+4138000000))/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L01')
   and gstt.gl_sub_head_code not in ('70002')
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        PaidUp_amt := 0;
   end;

-----------------------------Current----------------------------------------
Begin
SELECT 
sum(T.amt) into Current_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L11','L21','L22')
   
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Current_amt := 0;

end;
-----------------------------------------------------------------------------
    --------------------------------------------------------
    -----------------------------Saving----------------------------------------
    Begin
SELECT 
sum(T.amt) into Saving_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa 
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L13','L24')
   
   group by coa.cur)q)T ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Saving_amt := 0;
   end;

 --------------------------------------------------------
    -----------------------------Special----------------------------------------
    Begin
SELECT 
sum(T.amt) into  Special_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L15')
   
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Special_amt := 0;
   end;

      -----------------------------Fixed----------------------------------------
      Begin
SELECT 
sum(T.amt)  into Fixed_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L17','L26')
   
   group by coa.cur)q)T
;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Fixed_amt := 0;
end;

---------------------------------------Income--------------------------------------
  ---------------------------------------------------------------------
  Begin
SELECT 
sum(T.amt) into  Income_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('L40')
   
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Income_amt := 0;
   end;

---------------------------------------------------------------------
 --------------------------------Charges-------------------------------------
 Begin
 SELECT  
sum(T.amt)/1000000  into  Charges_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST (vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A50')
   
   group by coa.cur)q)T
   ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Charges_amt := 0;
   End;
---------------------------------------------------------------------
 --------------------------------Free_T_bondA11-------------------------------------
 Begin
SELECT 
sum(T.amt)  into  Free_T_bondA11
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
      AND coa.group_code in ('A11')
   
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Free_T_bondA11 := 0;
End;
---------------------------------------------------------------------
 --------------------------------Free_T_bondL31-------------------------------------
 Begin
SELECT 
sum(T.amt)  into  Free_T_bondL31
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
      AND coa.group_code ='L31'
      and coa.gl_sub_head_code ='70141'
   
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Free_T_bondL31 := 0;
End;
--------------------------------Cash_amt-------------------------------------
Begin
SELECT 
sum(T.amt) into Cash_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
       AND coa.group_code in ('A01','A02','A03')
   
   group by coa.cur)q)T
;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Cash_amt := 0;
End;
   --------------------------------CBM-------------------------------------
   Begin
SELECT 
sum(T.amt) into CBM_amt
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 select sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05')
   group by coa.cur)q)T;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CBM_amt := 0;
End;
 --------------------------------------------------------
    -----------------------------Totla loan----------------------------------------
    Begin
SELECT 
sum(T.amt) into Total_loan
from(
select CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt 
      from           
 (
 SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal)/1000000 as amt , coa.cur as cur 
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   AND gstt.BAL_DATE <= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   AND gstt.END_BAL_DATE >= TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND coa.group_code in ('A21','A22','A23','A24','A25','A26')
    and coa.group_code not in ('A22')
   
   group by coa.cur)q)T
  ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Total_loan := 0;
End;


IF Free_T_bondA11 IS  NULL or Free_T_bondA11 = ''  THEN
         Free_T_bondA11 := 0;
    END IF;
    
    IF Free_T_bondL31 IS  NULL or Free_T_bondL31 = ''  THEN
         Free_T_bondL31 := 0;
    END IF;

    -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
			out_rec :=	(--b_date || '|' ||
      PaidUp_amt || '|' ||
      Current_amt || '|' ||
                  Saving_amt   || '|' ||
                    Special_amt  || '|' ||
                    Fixed_amt || '|' ||
                    Income_amt || '|' ||
                    Charges_amt || '|' ||
                    Free_T_bondA11 || '|' ||
                    Free_T_bondL31 || '|' ||
                    Cash_amt || '|' ||
                    CBM_amt || '|' ||
                    Total_loan
                   );

			dbms_output.put_line(out_rec);  
      RETURN;

	--}-end for procedure
	END FIN_FINANCIAL_POSITION;

--}--end package
END FIN_FINANCIAL_POSITION;

------------------------------------------------------------------
-- Execution grants are given to tbaadm, tbagen, tbautil
-- Synonym is made for TBAGEN.FIN_Training_SPBX
------------------------------------------------------------------
/
