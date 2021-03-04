CREATE OR REPLACE PACKAGE                             FIN_LR
AS
PROCEDURE FIN_LR(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_LR;
 
/


CREATE OR REPLACE PACKAGE BODY                                                   FIN_LR AS
--{
	-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
	-------------------------------------------------------------------------------------
	outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	v_SelectedDate	   	Varchar2(15);               	-- Input to procedure
  currentdate         CHAR(15) := TO_CHAR(TO_DATE(v_SelectedDate, 'dd/mm/yyyy'),'DAY');
  daycount number := 0 ;
   
  
------------ExtractData---------------------------
CURSOR ExtractData    IS      
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
         and SERVICE_OUTLET_TABLE.BANK_ID = '01'
         and BRANCH_CODE_TABLE.bank_code like '116';
 

-----------------------------------------------------------------------------
-- Procedure declaration FIN_Training_SPBX Procedure
-----------------------------------------------------------------------------

	PROCEDURE FIN_LR(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

	IS
	--{
	-------------------------------------------------------------
	--Variable declaration
	-------------------------------------------------------------
   type array_t is varray(5) of number(10);
   array array_t := array_t(); -- Initialise it  
  
 ---------1-----------
  v_CashAmountOne		tbaadm.eab.tran_date_bal%type := 0; 
  v_CashAmountTwo		tbaadm.eab.tran_date_bal%type := 0; 
  v_CashAmountThree		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_CashAmountFour		tbaadm.eab.tran_date_bal%type:= 0; 
  v_CashAmountFive		tbaadm.eab.tran_date_bal%type:= 0; 
  -----------2---------
  v_ChequeAmountOne		tbaadm.eab.tran_date_bal%type:= 0; 
  v_ChequeAmountTwo		tbaadm.eab.tran_date_bal%type:= 0; 
  v_ChequeAmountThree		tbaadm.eab.tran_date_bal%type:= 0; 
  v_ChequeAmountFour		tbaadm.eab.tran_date_bal%type:= 0; 
  v_ChequeAmountFive		tbaadm.eab.tran_date_bal%type := 0; 
  ----------3----------
  v_GovernmentAmountOne		tbaadm.eab.tran_date_bal%type := 0; 
  v_GovernmentAmountTwo		tbaadm.eab.tran_date_bal%type := 0;  
  v_GovernmentAmountThree		tbaadm.eab.tran_date_bal%type := 0; 
  v_GovernmentAmountFour		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_GovernmentAmountFive		tbaadm.eab.tran_date_bal%type := 0; 
  ----------4---------
  v_DueFromDomesticAmountOne		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueFromDomesticAmountTwo		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueFromDomesticAmountThree		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DueFromDomesticAmountFour		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueFromDomesticAmountFive		tbaadm.eab.tran_date_bal%type:= 0 ; 
  ---------5-----------
  v_DueFromAbroadAmountOne		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DueFromAbroadAmountTwo		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueFromAbroadAmountThree		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_DueFromAbroadAmountFour		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueFromAbroadAmountFive		tbaadm.eab.tran_date_bal%type:= 0 ; 
  ----------6----------
  v_ChequeBillAmountOne		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_ChequeBillAmountTwo		tbaadm.eab.tran_date_bal%type := 0; 
  v_ChequeBillAmountThree		tbaadm.eab.tran_date_bal%type := 0;  
  v_ChequeBillAmountFour		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_ChequeBillAmountFive		tbaadm.eab.tran_date_bal%type:= 0 ; 
   ----------7----------
  v_DueToDomesticAmountOne		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_DueToDomesticAmountTwo		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DueToDomesticAmountThree		tbaadm.eab.tran_date_bal%type := 0; 
  v_DueToDomesticAmountFour		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DueToDomesticAmountFive		tbaadm.eab.tran_date_bal%type:= 0 ; 
   ----------8----------
  v_DepositAmountOne		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DepositAmountTwo		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_DepositAmountThree		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_DepositAmountFour		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_DepositAmountFive		tbaadm.eab.tran_date_bal%type:= 0 ; 
   ----------9----------
  v_TimeAmountOne		tbaadm.eab.tran_date_bal%type:= 0 ; 
  v_TimeAmountTwo		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_TimeAmountThree		tbaadm.eab.tran_date_bal%type:= 0 ;  
  v_TimeAmountFour		tbaadm.eab.tran_date_bal%type := 0;  
  v_TimeAmountFive		tbaadm.eab.tran_date_bal%type := 0; 
  
   v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  -------10------
  
    v_Date1	   	Varchar2(15);  
    v_Date2	   	Varchar2(15);  
    v_Date3	   	Varchar2(15);
    v_Date4	   	Varchar2(15); 
    v_Date5	   	Varchar2(15);  
    
  v_LessOne		tbaadm.eab.tran_date_bal%type ; 
  v_LessTwo		tbaadm.eab.tran_date_bal%type ;  
  v_LessThree		tbaadm.eab.tran_date_bal%type ;  
  v_LessFour		tbaadm.eab.tran_date_bal%type ;  
  v_LessFive		tbaadm.eab.tran_date_bal%type ; 
  
  v_DueToAbroadOne tbaadm.eab.tran_date_bal%type ; 
  v_DueToAbroadTwo tbaadm.eab.tran_date_bal%type ; 
  v_DueToAbroadThree tbaadm.eab.tran_date_bal%type ; 
  v_DueToAbroadFour tbaadm.eab.tran_date_bal%type ; 
  v_DueToAbroadFive tbaadm.eab.tran_date_bal%type ; 
  
  	amt tbaadm.eab.tran_date_bal%type := 0; 
    cbm_amt tbaadm.eab.tran_date_bal%type := 0 ;
    A_amt tbaadm.eab.tran_date_bal%type := 0 ;
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
		v_SelectedDate:=outArr(0);
    --v_BranchCode:=outArr(1);		
    ----------------------------------------------------------------------------------------------------------------
    if( v_SelectedDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
				    0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					  0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					   0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					    0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
						  0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
						    0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
							  0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
							    0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
								  0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 );
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    
    
    
    -----------------------------------------------------------------------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ;
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
		
				-----------------------------------------------------
		-- Checking whether the cursor is open if not
		-- it is opened
		----------------------------------------------------- 
     dbms_output.put_line('v_SelectedDate '|| v_SelectedDate);
     
     select trunc(TO_DATE(v_SelectedDate, 'dd-mm-yyyy') ,'D') + 1 into v_Date1 from dual connect by level = 1;
     dbms_output.put_line('v_Date1 '|| v_Date1);
     
      select trunc(TO_DATE(v_SelectedDate, 'dd-mm-yyyy') ,'D') + 2 into v_Date2 from dual connect by level = 1;
     dbms_output.put_line('v_Date2 '|| v_Date2);
     
      select trunc(TO_DATE(v_SelectedDate, 'dd-mm-yyyy') ,'D') + 3 into v_Date3 from dual connect by level = 1;
     dbms_output.put_line('v_Date3 '|| v_Date3);
     
      select trunc(TO_DATE(v_SelectedDate, 'dd-mm-yyyy') ,'D') + 4 into v_Date4 from dual connect by level = 1;
     dbms_output.put_line('v_Date4 '|| v_Date4);
     
      select trunc(TO_DATE(v_SelectedDate, 'dd-mm-yyyy') ,'D') + 5 into v_Date5 from dual connect by level = 1;
     dbms_output.put_line('v_Date5 '|| v_Date5);
      
     currentdate  := TO_CHAR(TO_DATE(v_SelectedDate, 'dd/mm/yyyy'),'DAY');
     dbms_output.put_line('currentdate '|| currentdate);
     --dbms_output.put_line(currentdate);
     if currentdate = 'MONDAY'   then daycount := 1; v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy'); end if;
     if currentdate = 'TUESDAY'   then daycount := 2;v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy'); end if;
     if currentdate = 'WEDNESDAY'  then daycount := 3;v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy'); end if;
     if currentdate = 'THURSDAY' then daycount := 4;v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy'); end if;
     if currentdate = 'FRIDAY'  then daycount := 5;v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy'); end if;
    dbms_output.put_line(v_SelectedDate);
    while daycount > 0 loop	

		  if( daycount = 1) then--------1
      begin
         select sum(t.Dr_amt)*5/100 into amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('L21','L23','L24','L25','L26')
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L21','L23','L24','L25','L26') group by gstt.crncy_code
    )q )t;
    
     select sum(t.Dr_amt) into cbm_amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05') group by gstt.crncy_code
    )q )t;
    
    A_amt := cbm_amt - amt;
    
    select sum(t.Dr_amt) into v_CashAmountOne  
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code
    )q )t;
    
    if (A_amt < 0 )then -- A_amt value is minus , take A01 to A03
    
          v_CashAmountOne := v_CashAmountOne;
    else -- A_amt value is plus , take ( A_amt + A01 to A03)
    
         v_CashAmountOne := v_CashAmountOne + A_amt;
         
    end if;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_CashAmountOne := 0;
   END; 
    -------------------------
--------------------------------------------------2-----------------------------
begin
select sum(t.Dr_amt) into v_ChequeAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A31','A32') group by gstt.crncy_code
    )q )t;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ChequeAmountOne := 0;
   END;     
         -----3
begin
  select sum(t.Dr_amt) into v_GovernmentAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A11') group by gstt.crncy_code
    )q )t;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_GovernmentAmountOne := 0;
   END;
         -----4
begin
select sum(t.Dr_amt) into v_DueFromDomesticAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,tbaadm.gam,custom.coa_mp coa
WHERE
   gstt.gl_sub_head_code = gam.gl_sub_head_code
   AND gstt.sol_id=gam.sol_id
   AND gam.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A06','A07')
   and gam.foracid not like '%10114006031' group by gstt.crncy_code
    )q )t;
    
    if(v_DueFromDomesticAmountOne > 0 ) then
        v_DueToDomesticAmountOne := 0 ;
    else 
        v_DueToDomesticAmountOne := v_DueFromDomesticAmountOne;
        v_DueFromDomesticAmountOne := 0;
    end if;  
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_DueFromDomesticAmountOne := 0;
   END;
  
         -----5
begin
 select sum(t.Dr_amt) into v_DueFromAbroadAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A08') group by gstt.crncy_code
    )q )t;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_DueFromAbroadAmountOne := 0;
   END;
         -----6
select sum(t.Dr_amt) into v_ChequeBillAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L33','L39') group by gstt.crncy_code
    )q )t;
         -----7
       --v_DueToDomesticAmountOne
         -----8
 
select sum(t.Dr_amt) into v_DepositAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L11') group by gstt.crncy_code
    )q )t;
    
         -----9
select sum(t.Dr_amt) into v_TimeAmountOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L13','L15','L17') group by gstt.crncy_code
    )q )t;

---------------------10----------------------------
         select sum(t.Dr_amt) into v_LessOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L31') group by gstt.crncy_code
    )q )t;

---------------------11----------------
select sum(t.Dr_amt) into v_DueToAbroadOne  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L22') group by gstt.crncy_code
    )q )t;
end if;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
      if( daycount = 2) then
------------2------------------------------------
         select sum(t.Dr_amt)*5/100 into amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('L21','L23','L24','L25','L26')
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L21','L23','L24','L25','L26') group by gstt.crncy_code
    )q )t;
    
     select sum(t.Dr_amt) into cbm_amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05') group by gstt.crncy_code
    )q )t;
    
    A_amt := cbm_amt - amt;
    
    select sum(t.Dr_amt) into v_CashAmountTwo 
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code
    )q )t;
    
    if (A_amt < 0 )then -- A_amt value is minus , take A01 to A03
    
          v_CashAmountTwo := v_CashAmountTwo;
    else -- A_amt value is plus , take ( A_amt + A01 to A03)
    
         v_CashAmountTwo := v_CashAmountTwo + A_amt;
         A_amt := 0 ;
         amt := 0;
         cbm_amt := 0;
         
    end if;
    -------------------------
--------------------------------------------------2-----------------------------
select sum(t.Dr_amt) into v_ChequeAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A31','A32') group by gstt.crncy_code
    )q )t;
         -----3
  select sum(t.Dr_amt) into v_GovernmentAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A11') group by gstt.crncy_code
    )q )t;
         -----4
      
select sum(t.Dr_amt) into v_DueFromDomesticAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,tbaadm.gam,custom.coa_mp coa
WHERE
   gstt.gl_sub_head_code = gam.gl_sub_head_code
   AND gstt.sol_id=gam.sol_id
   AND gam.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A06','A07')
   and gam.foracid not like '%10114006031' group by gstt.crncy_code
    )q )t;
    
    if(v_DueFromDomesticAmountTwo > 0 ) then
        v_DueToDomesticAmountTwo := 0 ;
    else 
        v_DueToDomesticAmountTwo := v_DueFromDomesticAmountTwo;
        v_DueFromDomesticAmountTwo := 0;
    end if;      
  
         -----5
 select sum(t.Dr_amt) into v_DueFromAbroadAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A08') group by gstt.crncy_code
    )q )t;
         -----6
select sum(t.Dr_amt) into v_ChequeBillAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L33','L39') group by gstt.crncy_code
    )q )t;
         -----7
       --v_DueToDomesticAmountOne
         -----8
 
select sum(t.Dr_amt) into v_DepositAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L11') group by gstt.crncy_code
    )q )t;
    
         -----9
select sum(t.Dr_amt) into v_TimeAmountTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L13','L15','L17') group by gstt.crncy_code
    )q )t;

---------------------10----------------------------
         select sum(t.Dr_amt) into v_LessTwo from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L31') group by gstt.crncy_code
    )q )t;

---------------------11----------------
select sum(t.Dr_amt) into v_DueToAbroadTwo  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L22') group by gstt.crncy_code
    )q )t;
end if;    
----------------------------------------------------------------------------
----------------------------------------------------------------------------
      if( daycount = 3) then
        -----1
         select sum(t.Dr_amt)*5/100 into amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('L21','L23','L24','L25','L26')
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L21','L23','L24','L25','L26') group by gstt.crncy_code
    )q )t;
    
     select sum(t.Dr_amt) into cbm_amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05') group by gstt.crncy_code
    )q )t;
    
    A_amt := cbm_amt - amt;
    
    select sum(t.Dr_amt) into v_CashAmountThree
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code
    )q )t;
    
    if (A_amt < 0 )then -- A_amt value is minus , take A01 to A03
    
          v_CashAmountThree := v_CashAmountThree;
    else -- A_amt value is plus , take ( A_amt + A01 to A03)
    
         v_CashAmountThree := v_CashAmountThree + A_amt;
         A_amt := 0 ;
         amt := 0;
         cbm_amt := 0;
         
    end if;
    -------------------------
--------------------------------------------------2-----------------------------
select sum(t.Dr_amt) into v_ChequeAmountThree from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A31','A32') group by gstt.crncy_code
    )q )t;
         -----3
  select sum(t.Dr_amt) into v_GovernmentAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A11') group by gstt.crncy_code
    )q )t;
         -----4
      
select sum(t.Dr_amt) into v_DueFromDomesticAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,tbaadm.gam,custom.coa_mp coa
WHERE
   gstt.gl_sub_head_code = gam.gl_sub_head_code
   AND gstt.sol_id=gam.sol_id
   AND gam.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A06','A07')
   and gam.foracid not like '%10114006031' group by gstt.crncy_code
    )q )t;
    
    if(v_DueFromDomesticAmountThree > 0 ) then
        v_DueToDomesticAmountThree := 0 ;
    else 
        v_DueToDomesticAmountThree := v_DueFromDomesticAmountThree;
        v_DueFromDomesticAmountThree := 0;
    end if;      
  
         -----5
 select sum(t.Dr_amt) into v_DueFromAbroadAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A08') group by gstt.crncy_code
    )q )t;
         -----6
select sum(t.Dr_amt) into v_ChequeBillAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L33','L39') group by gstt.crncy_code
    )q )t;
         -----7
       --v_DueToDomesticAmountOne
         -----8
 
select sum(t.Dr_amt) into v_DepositAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L11') group by gstt.crncy_code
    )q )t;
    
         -----9
select sum(t.Dr_amt) into v_TimeAmountThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L13','L15','L17') group by gstt.crncy_code
    )q )t;

---------------------10----------------------------
         select sum(t.Dr_amt) into v_LessThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L31') group by gstt.crncy_code
    )q )t;

---------------------11----------------
select sum(t.Dr_amt) into v_DueToAbroadThree  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L22') group by gstt.crncy_code
    )q )t;
    
    end if;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
if( daycount = 4) then
		   -----1
         select sum(t.Dr_amt)*5/100 into amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('L21','L23','L24','L25','L26')
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L21','L23','L24','L25','L26') group by gstt.crncy_code
    )q )t;
    
     select sum(t.Dr_amt) into cbm_amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05') group by gstt.crncy_code
    )q )t;
    
    A_amt := cbm_amt - amt;
    
    select sum(t.Dr_amt) into v_CashAmountFour
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code
    )q )t;
    
    if (A_amt < 0 )then -- A_amt value is minus , take A01 to A03
    
          v_CashAmountFour := v_CashAmountFour;
    else -- A_amt value is plus , take ( A_amt + A01 to A03)
    
         v_CashAmountFour := v_CashAmountFour + A_amt;
         A_amt := 0 ;
         amt := 0;
         cbm_amt := 0;
         
    end if;
    -------------------------
--------------------------------------------------2-----------------------------
select sum(t.Dr_amt) into v_ChequeAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A31','A32') group by gstt.crncy_code
    )q )t;
         -----3
  select sum(t.Dr_amt) into v_GovernmentAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A11') group by gstt.crncy_code
    )q )t;
         -----4
      
select sum(t.Dr_amt) into v_DueFromDomesticAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,tbaadm.gam,custom.coa_mp coa
WHERE
   gstt.gl_sub_head_code = gam.gl_sub_head_code
   AND gstt.sol_id=gam.sol_id
   AND gam.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A06','A07')
   and gam.foracid not like '%10114006031' group by gstt.crncy_code
    )q )t;
    
    if(v_DueFromDomesticAmountFour > 0 ) then
        v_DueToDomesticAmountFour := 0 ;
    else 
        v_DueToDomesticAmountFour := v_DueFromDomesticAmountFour;
        v_DueFromDomesticAmountFour := 0;
    end if;      
  
         -----5
 select sum(t.Dr_amt) into v_DueFromAbroadAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A08') group by gstt.crncy_code
    )q )t;
         -----6
select sum(t.Dr_amt) into v_ChequeBillAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L33','L39') group by gstt.crncy_code
    )q )t;
         -----7
       --v_DueToDomesticAmountOne
         -----8
 
select sum(t.Dr_amt) into v_DepositAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L11') group by gstt.crncy_code
    )q )t;
    
         -----9
select sum(t.Dr_amt) into v_TimeAmountFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L13','L15','L17') group by gstt.crncy_code
    )q )t;

---------------------10----------------------------
         select sum(t.Dr_amt) into v_LessFour from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L31') group by gstt.crncy_code
    )q )t;
      
---------------------11----------------
select sum(t.Dr_amt) into v_DueToAbroadFour  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L22') group by gstt.crncy_code
    )q )t;
end if;    
----------------------------------------------------------------------------
----------------------------------------------------------------------------
if( daycount = 5) then
select sum(t.Dr_amt)*5/100 into amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('L21','L23','L24','L25','L26')
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L21','L23','L24','L25','L26') group by gstt.crncy_code
    )q )t;
    
     select sum(t.Dr_amt) into cbm_amt  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A04','A05') group by gstt.crncy_code
    )q )t;
    
    A_amt := cbm_amt - amt;
    
    select sum(t.Dr_amt) into v_CashAmountFive  
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code
    )q )t;
    
    if (A_amt < 0 )then -- A_amt value is minus , take A01 to A03
    
          v_CashAmountFive := v_CashAmountFive;
    else -- A_amt value is plus , take ( A_amt + A01 to A03)
    
         v_CashAmountFive := v_CashAmountFive + A_amt;
         A_amt := 0 ;
         amt := 0;
         cbm_amt := 0;
         
    end if;
    -------------------------
--------------------------------------------------2-----------------------------
select sum(t.Dr_amt) into v_ChequeAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A31','A32') group by gstt.crncy_code
    )q )t;
         -----3
  select sum(t.Dr_amt) into v_GovernmentAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A11') group by gstt.crncy_code
    )q )t;
         -----4
      
select sum(t.Dr_amt) into v_DueFromDomesticAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,tbaadm.gam,custom.coa_mp coa
WHERE
   gstt.gl_sub_head_code = gam.gl_sub_head_code
   AND gstt.sol_id=gam.sol_id
   AND gam.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
    AND gam.acct_crncy_code = gstt.crncy_code
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A06','A07')
   and gam.foracid not like '%10114006031' group by gstt.crncy_code
    )q )t;
    
    if(v_DueFromDomesticAmountFive > 0 ) then
        v_DueToDomesticAmountFive := 0 ;
    else 
        v_DueToDomesticAmountFive := v_DueFromDomesticAmountFive;
        v_DueFromDomesticAmountFive := 0;
    end if;      
  
         -----5
 select sum(t.Dr_amt) into v_DueFromAbroadAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A08') group by gstt.crncy_code
    )q )t;
         -----6
select sum(t.Dr_amt) into v_ChequeBillAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L33','L39') group by gstt.crncy_code
    )q )t;
         -----7
       --v_DueToDomesticAmountOne
         -----8
 
select sum(t.Dr_amt) into v_DepositAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L11') group by gstt.crncy_code
    )q )t;
    
         -----9
select sum(t.Dr_amt) into v_TimeAmountFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L13','L15','L17') group by gstt.crncy_code
    )q )t;

---------------------10----------------------------
         select sum(t.Dr_amt) into v_LessFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L31') group by gstt.crncy_code
    )q )t;
    
---------------------11----------------
select sum(t.Dr_amt) into v_DueToAbroadFive  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt
from 
(SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND tbaadm.gstt.BAL_DATE <= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )  
   and tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( v_SelectedDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('L22') group by gstt.crncy_code
    )q )t;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
end if;   
      
    v_SelectedDate := TO_DATE(v_SelectedDate, 'dd/mm/yyyy') -1 ;
    dbms_output.put_line('After decrease Selected Date ' || v_SelectedDate);  
    daycount := daycount - 1;
    dbms_output.put_line('daycount ' || daycount); 
  
    end loop;
    -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
			out_rec:=	(	 v_CashAmountOne ||'|'||  v_CashAmountTwo ||'|'||  v_CashAmountThree ||'|'||  v_CashAmountFour ||'|'|| v_CashAmountFive		
      ||'|'|| v_ChequeAmountOne	||'|'|| v_ChequeAmountTwo	||'|'||  v_ChequeAmountThree	||'|'||  v_ChequeAmountFour	||'|'|| v_ChequeAmountFive
      ||'|'|| v_GovernmentAmountOne	||'|'|| v_GovernmentAmountTwo	||'|'|| v_GovernmentAmountThree	||'|'|| v_GovernmentAmountFour ||'|'|| v_GovernmentAmountFive	
      ||'|'|| v_DueFromDomesticAmountOne ||'|'|| v_DueFromDomesticAmountTwo ||'|'|| v_DueFromDomesticAmountThree ||'|'|| v_DueFromDomesticAmountFour ||'|'|| v_DueFromDomesticAmountFive 
      ||'|'|| v_DueFromAbroadAmountOne ||'|'|| v_DueFromAbroadAmountTwo	||'|'|| v_DueFromAbroadAmountThree ||'|'|| v_DueFromAbroadAmountFour ||'|'|| v_DueFromAbroadAmountFive
      ||'|'|| v_ChequeBillAmountOne	||'|'|| v_ChequeBillAmountTwo	||'|'|| v_ChequeBillAmountThree ||'|'|| v_ChequeBillAmountFour ||'|'|| v_ChequeBillAmountFive	
      ||'|'|| v_DueToDomesticAmountOne ||'|'|| v_DueToDomesticAmountTwo	||'|'|| v_DueToDomesticAmountThree ||'|'|| v_DueToDomesticAmountFour ||'|'|| v_DueToDomesticAmountFive
      ||'|'|| v_DepositAmountOne ||'|'|| v_DepositAmountTwo	||'|'|| v_DepositAmountThree ||'|'|| v_DepositAmountFour ||'|'|| v_DepositAmountFive
      ||'|'|| v_TimeAmountOne	||'|'|| v_TimeAmountTwo	||'|'|| v_TimeAmountThree	||'|'|| v_TimeAmountFour ||'|'|| v_TimeAmountFive 
      ||'|'|| v_LessOne ||'|'|| v_LessTwo ||'|'|| v_LessThree ||'|'|| v_LessFour ||'|'|| v_LessFive
      ||'|'|| to_char(to_date(v_Date1,'dd/Mon/yy'), 'dd.MM.yyyy') ||'|'|| to_char(to_date(v_Date2,'dd/Mon/yy'), 'dd.MM.yyyy')
      ||'|'|| to_char(to_date(v_Date3,'dd/Mon/yy'), 'dd.MM.yyyy') ||'|'|| to_char(to_date(v_Date4,'dd/Mon/yy'), 'dd.MM.yyyy') 
      ||'|'|| to_char(to_date(v_Date5,'dd/Mon/yy'), 'dd.MM.yyyy'));

			dbms_output.put_line(out_rec);  
      RETURN;

	--}-end for procedure
	END FIN_LR;

--}--end package
END FIN_LR;

------------------------------------------------------------------
-- Execution grants are given to tbaadm, tbagen, tbautil
-- Synonym is made for TBAGEN.FIN_Training_SPBX
------------------------------------------------------------------
/
