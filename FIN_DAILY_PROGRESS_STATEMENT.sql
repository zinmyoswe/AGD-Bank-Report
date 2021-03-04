CREATE OR REPLACE PACKAGE        FIN_DAILY_PROGRESS_STATEMENT
AS
PROCEDURE FIN_DAILY_PROGRESS_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_DAILY_PROGRESS_STATEMENT;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                     FIN_DAILY_PROGRESS_STATEMENT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr	tbaadm.basp0099.ArrayType;      -- Input Parse Array
	v_startDate		    Varchar2(20);		    	    -- Input to procedure
  --v_endDate		    Varchar2(20);		    	    -- Input to procedure
  --v_CurrencyCode	   	Varchar2(7);   -- Input to procedure
  
  var varchar(10);
   v_dr tbaadm.gstt.tot_cr_bal%type;
  v_cr  tbaadm.gstt.tot_cr_bal%type;
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData

-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_startDate VARCHAR2) IS
select 
cash.tran_date,
deposit.D_Tran_Amt,
loanb.L_Tran_Amt,
cash.Transfer_Dr_Amt,
cash.Transfer_Cr_Amt,
cash.Cash_Dr_Amt,
cash.Cash_Cr_Amt,
loan.Loan_Transfer_Dr_Amt,
loan.Loan_Transfer_Cr_Amt,
loan.Loan_Cash_Dr_Amt,
loan.Loan_Cash_Cr_Amt,
inhand.Cash_Inhand_Amt
from
(
select 'A' as temp,sum(T.tran_amt)/1000000 as D_Tran_Amt 
from
(select CASE WHEN q.cur = 'MMK' THEN q.tran_amt 
      ELSE q.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS tran_amt
 from
(select sum(gstt.tot_cr_bal - gstt.tot_dr_bal)as tran_amt,gstt.crncy_code as cur
   from tbaadm.gstt,custom.coa_mp coa
   where gstt.BAL_DATE <= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and coa.GL_SUB_HEAD_CODE = gstt.GL_SUB_HEAD_CODE
   and coa.cur = gstt.crncy_code
   and coa.group_code in ('L11','L12','L13','L14','L15','L16','L17','L18','L19','L20','L21','L22','L23','L24','L25','L26')
   group by gstt.bal_date, gstt.crncy_code
   )q
   )T
   group by  'A' 
)deposit

left join 

(select 'A' as temp,sum(T.tran_amt)/1000000 as L_Tran_Amt 
from
(select CASE WHEN q.cur = 'MMK' THEN q.tran_amt 
      ELSE q.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS tran_amt
 from
(select sum(gstt.tot_cr_bal - gstt.tot_dr_bal)as tran_amt,gstt.crncy_code as cur
   from tbaadm.gstt,custom.coa_mp coa
    where gstt.BAL_DATE <= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and coa.GL_SUB_HEAD_CODE = gstt.GL_SUB_HEAD_CODE
   and coa.cur = gstt.crncy_code
   and coa.group_code in ('A21','A23','A24','A25','A26')
   group by gstt.bal_date, gstt.crncy_code
   )q
   )T
   group by 'A' 
)loanb on deposit.temp = loanb.temp

left join

(select 'A' as temp,
T.tran_date,
sum(T.Transfer_Dr_Amt)/1000000 as Transfer_Dr_Amt,
sum(T.Transfer_Cr_Amt)/1000000 as Transfer_Cr_Amt,
sum(T.Cash_Dr_Amt)/1000000 as Cash_Dr_Amt,
sum(T.Cash_Cr_Amt)/1000000 as Cash_Cr_Amt 
from
(select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_Amt,                            
 q.bal_date as tran_date 
from
(
select gstt.bal_date,
case when sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) > sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) then
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) - sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) 
else 0 end as Cash_Dr_Amt,
case when sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) > sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) then
sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) - sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) 
else 0 end as Cash_Cr_Amt,
0  as Transfer_Cr_Amt,
0  as Transfer_Dr_Amt,
coa.cur
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE = TO_DATE( ci_startDate, 'dd-MM-yyyy' )
group by gstt.bal_date,coa.cur
union
select gstt.bal_date,
sum(gstt.TOT_cash_DR_AMT) as Cash_Dr_Amt ,
sum(gstt.tot_cash_Cr_amt) as Cash_Cr_Amt,
sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt)  as Transfer_Cr_Amt,
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt)  as Transfer_Dr_Amt,
coa.cur
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE = TO_DATE( ci_startDate, 'dd-MM-yyyy' )
group by gstt.bal_date,coa.cur
) q
   order by q.bal_date
) T
group by T.tran_date, 'A' order by T.tran_date
)cash on loanb.temp = cash.temp

left join
(select 
'A' as temp,
T.tran_date,
sum(T.Transfer_Dr_Amt)/1000000 as Loan_Transfer_Dr_Amt,
sum(T.Transfer_Cr_Amt)/1000000 as Loan_Transfer_Cr_Amt,
sum(T.Cash_Dr_Amt)/1000000 as Loan_Cash_Dr_Amt,
sum(T.Cash_Cr_Amt)/1000000 as Loan_Cash_Cr_Amt 
from
(select 
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Dr_Amt 
      ELSE q.Transfer_Dr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Transfer_Cr_Amt 
      ELSE q.Transfer_Cr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Transfer_Cr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Dr_Amt 
      ELSE q.Cash_Dr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Dr_Amt,
  CASE WHEN q.cur = 'MMK' THEN q.Cash_Cr_Amt 
      ELSE q.Cash_Cr_Amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Cash_Cr_Amt,                            
 q.bal_date as tran_date 
from
(
select gstt.bal_date,
sum(gstt.TOT_cash_CR_AMT) as Cash_Cr_Amt ,
sum(gstt.tot_cash_Dr_amt) as Cash_Dr_Amt,
sum(gstt.tot_XFER_Cr_amt+tot_clg_Cr_amt) as Transfer_Cr_Amt,
sum(gstt.tot_XFER_Dr_amt+tot_clg_Dr_amt) as Transfer_Dr_Amt,
coa.cur
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and coa.group_code in ('A21','A23','A24','A25','A26')
and gstt.BAL_DATE = TO_DATE( ci_startDate, 'dd-MM-yyyy' )
group by gstt.bal_date,coa.cur
) q
   order by q.bal_date
) T
group by T.tran_date, 'A' order by T.tran_date
) loan 
on cash.temp = loan.temp
left join
(select 'A' as temp,sum(T.tran_amt)/1000000 as Cash_Inhand_Amt
from
(select  CASE WHEN q.cur = 'MMK' THEN q.tran_amt 
      ELSE q.tran_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS tran_amt
  from
( select
        sum(gstt.tot_dr_bal- gstt.tot_cr_bal) as tran_amt,gstt.crncy_code as cur
   from tbaadm.gstt, custom.coa_mp coa
   where  coa.gl_sub_head_code = gstt.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = coa.cur
   and coa.group_code ='A01'
   and gstt.DEL_FLG = 'N'
  group by gstt.crncy_code
  union 
  select
        sum(gstt.tot_dr_bal- gstt.tot_cr_bal) as tran_amt,gstt.crncy_code as cur
   from tbaadm.gstt, custom.coa_mp coa
   where  coa.gl_sub_head_code = gstt.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = coa.cur
   and coa.group_code ='A02'
   and gstt.DEL_FLG = 'N'
  group by gstt.crncy_code
  union
  select
        sum(gstt.tot_dr_bal- gstt.tot_cr_bal) as tran_amt,gstt.crncy_code as cur
   from tbaadm.gstt, custom.coa_mp coa
   where  coa.gl_sub_head_code = gstt.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_startDate, 'dd-MM-yyyy' )
   and gstt.crncy_code = coa.cur
   and coa.group_code ='A03'
   and gstt.DEL_FLG = 'N'
  group by gstt.crncy_code
 )q
)T group by 'A'
) inhand 
on inhand.temp = loan.temp;
   
PROCEDURE FIN_DAILY_PROGRESS_STATEMENT(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

    IS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
  Tran_Date Date;
  Transfer_Dr_Amt tbaadm.gstt.tot_cr_bal%type;
  Transfer_Cr_Amt tbaadm.gstt.tot_cr_bal%type;
  Cash_Dr_Amt tbaadm.gstt.tot_cr_bal%type;
  Cash_Cr_Amt tbaadm.gstt.tot_cr_bal%type;
  Loan_Transfer_Dr_Amt tbaadm.gstt.tot_cr_bal%type;
  Loan_Transfer_Cr_Amt tbaadm.gstt.tot_cr_bal%type;
  Loan_Cash_Dr_Amt tbaadm.gstt.tot_cr_bal%type;
  Loan_Cash_Cr_Amt tbaadm.gstt.tot_cr_bal%type;
  Cash_Inhand_Amt tbaadm.gstt.tot_cr_bal%type;
  
  D_Tran_Amt tbaadm.gstt.tot_cr_bal%type;
  L_Tran_Amt tbaadm.gstt.tot_cr_bal%type;
  
  BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type; 
  BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type; 
  BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  num number;

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
    
    v_startDate:=outArr(0);
	 -- v_endDate:= outArr(1);
    
    ----------------------------------------------------------------------------------
    
    if v_startDate is null then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' ||  0 || '|' || 
    0|| '|' || 0|| '|' ||
    0|| '|' || 0|| '|' || 
    0|| '|' || 0 || '|' || 
    0|| '|' || 0 || '|' || 
    0 || '|' ||    
    '-'|| '|' ||'-'|| '|' ||'-' || '|' ||'-');
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    
    
    -----------------------------------------------------
		-- Checking whether the cursor is open if not
		-- it is opened
		-----------------------------------------------------
  
   /*select bct.BR_SHORT_NAME,bct.BR_ADDR_1,bct.PHONE_NUM, bct.FAX_NUM
   into BranchName,BankAddress,BankPhone ,BankFax
   from tbaadm.sol,tbaadm.bct 
   where sol.SOL_ID = v_BranchCode and bct.br_code = sol.br_code;*/   
 
   -----------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(v_startDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	Tran_Date,D_Tran_Amt,L_Tran_Amt,
      Transfer_Dr_Amt, Transfer_Cr_Amt, 
      Cash_Dr_Amt, Cash_Cr_Amt, 
      Loan_Transfer_Dr_Amt, Loan_Transfer_Cr_Amt,
      Loan_Cash_Dr_Amt, Loan_Cash_Cr_Amt,
      Cash_Inhand_Amt;      
      
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
      
END IF; 
 -----------------------------------     
     
 -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
select case when sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) > sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) then
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) - sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) 
else 0 end as dr_amt,
case when sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) > sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) then
sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) - sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) 
else 0 end as cr_amt
into v_dr,v_cr
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE = TO_DATE(v_startDate, 'dd-MM-yyyy' )  group by 'A81', 'INTERSOL RECONCILIATION';

 if v_dr > v_cr then
    
    out_rec:=	( to_char(to_date(Tran_Date,'dd-Mon-yy'), 'dd-MM-yyyy') || '|' || D_Tran_Amt || '|' ||  L_Tran_Amt || '|' || 
    Transfer_Cr_Amt|| '|' || Transfer_Cr_Amt|| '|' ||
    Cash_Dr_Amt|| '|' || Cash_Cr_Amt|| '|' || 
    Loan_Transfer_Dr_Amt|| '|' || Loan_Transfer_Cr_Amt || '|' || 
    Loan_Cash_Dr_Amt|| '|' || Loan_Cash_Cr_Amt || '|' || 
    Cash_Inhand_Amt || '|' ||    
    BranchName|| '|' ||BankAddress|| '|' ||BankPhone || '|' ||BankFax );
  else
  
  out_rec:=	( to_char(to_date(Tran_Date,'dd-Mon-yy'), 'dd-MM-yyyy') || '|' || D_Tran_Amt || '|' ||  L_Tran_Amt || '|' || 
    Transfer_Dr_Amt|| '|' || Transfer_Dr_Amt|| '|' ||
    Cash_Dr_Amt|| '|' || Cash_Cr_Amt|| '|' || 
    Loan_Transfer_Dr_Amt|| '|' || Loan_Transfer_Cr_Amt || '|' || 
    Loan_Cash_Dr_Amt|| '|' || Loan_Cash_Cr_Amt || '|' || 
    Cash_Inhand_Amt || '|' ||    
    BranchName|| '|' ||BankAddress|| '|' ||BankPhone || '|' ||BankFax );
    
    end if;
  			
      dbms_output.put_line(out_rec);
      
  END FIN_DAILY_PROGRESS_STATEMENT;

END FIN_DAILY_PROGRESS_STATEMENT;
/
