CREATE OR REPLACE PACKAGE                                                                FIN_CLEAN_CASH
AS
PROCEDURE FIN_CLEAN_CASH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_CLEAN_CASH;
/


CREATE OR REPLACE PACKAGE BODY FIN_CLEAN_CASH AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;      -- Input Parse Array
	v_TrANDate		  Varchar2(10);		    	    -- Input to procedure
  v_BranchCode	  Varchar2(7);              -- Input to procedure
  v_CurrencyCode	Varchar2(7);
  v_cur_type	   	Varchar2(25); 
  resultrate      varchar(2000);
   
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData

-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_TrANDate VARCHAR2,
			ci_BranchCode VARCHAR2,ci_CurrencyCode VARCHAR2)
      IS
select coa.group_code ,coa.description,
sum(gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT),
sum(gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT)
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and gstt.crncy_code = upper(ci_CurrencyCode) 
and gstt.sol_id like   '%' || ci_BranchCode || '%'
and coa.group_code not in ('A01','A02','A03')
AND gstt.DEL_FLG = 'N' AND gstt.BANK_ID = '01'
and gstt.BAL_DATE = TO_DATE( ci_TrANDate, 'dd-MM-yyyy' )
group by coa.group_code,coa.description;

CURSOR ExtractData_All (	ci_TrANDate VARCHAR2,ci_BranchCode VARCHAR2)
      IS
 SELECT T.group_code,
  T.description,
  sum(T.DR_amt),
  sum(T.CR_amt) 
  FROM
  (
  SELECT  q.group_code, q.description,
  CASE WHEN q.cur = 'MMK' THEN q.DR_amt
  ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  CASE WHEN q.cur = 'MMK' THEN q.CR_amt 
  ELSE q.CR_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt
 
 FROM(
select coa.group_code ,coa.description,
sum(gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) as DR_amt,
sum(gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) as CR_amt,coa.cur
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and gstt.sol_id like   '%' || ci_BranchCode || '%'
and coa.group_code not in ('A01','A02','A03')
AND gstt.DEL_FLG = 'N' AND gstt.BANK_ID = '01'
and gstt.BAL_DATE = TO_DATE( ci_TrANDate, 'dd-MM-yyyy' )
group by coa.group_code,coa.description,coa.cur
)q 
   )T GROUP BY T.group_code, T.description
   order by T.group_code;
   
CURSOR ExtractData_All_FCY (	ci_TrANDate VARCHAR2,ci_BranchCode VARCHAR2)
      IS
 SELECT T.group_code,
  T.description,
  sum(T.DR_amt),
  sum(T.CR_amt) 
  FROM
  (
  SELECT  q.group_code, q.description,
  CASE WHEN q.cur = 'MMK' THEN q.DR_amt
  ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  CASE WHEN q.cur = 'MMK' THEN q.CR_amt 
  ELSE q.CR_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt
 
 FROM(
 select coa.group_code ,coa.description,
 sum(gstt.TOT_cash_DR_AMT + gstt.TOT_xfer_DR_AMT + gstt.TOT_clg_DR_AMT) as DR_amt,
sum(gstt.TOT_cash_CR_AMT + gstt.TOT_xfer_CR_AMT + gstt.TOT_clg_CR_AMT) as CR_amt,coa.cur
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and gstt.crncy_code not like 'MMK'
and gstt.sol_id like   '%' || ci_BranchCode || '%'
and coa.group_code not in ('A01','A02','A03')
AND gstt.DEL_FLG = 'N' AND gstt.BANK_ID = '01'
and gstt.BAL_DATE = TO_DATE( ci_TrANDate, 'dd-MM-yyyy' )
group by coa.group_code,coa.description,coa.cur)q 
   )T GROUP BY T.group_code, T.description
   order by T.group_code;
     
PROCEDURE FIN_CLEAN_CASH(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

    IS
-------------------------------------------------------------
	--Variable declaration that sEND to report
-------------------------------------------------------------
  v_gl_sub_head_code custom.coa_mp.group_code%type;
  v_gl_sub_head_desc custom.coa_mp.description%type; 
  v_cr_amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_dr_amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_openingamount decimal(18,2) ;
  v_TransferCredit TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_TransferDebit TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
 BRANCH_NAME tbaadm.sol.sol_desc%type; 
  Bank_Address varchar2(200); 
  Bank_Phone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  Bank_Fax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  nodata VARCHAR2(5) := null;
  AMOJNT TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  num number;
   rate decimal(18,2);
  resultstr varchar(20) :=v_BranchCode;

  BEGIN
        -------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
        -------------------------------------------------------------
		out_retCode := 0;     ---when return to iReport 0 will fail and 1 will success
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps FROM the string
		--------------------------------------
    
    v_TrANDate:=outArr(0);		
    v_CurrencyCode:= outArr(1);
    v_cur_type:= outArr(2);
    v_BranchCode:=outArr(3);
    -----------------------------------------------------
		-- Checking whether the cursor is open IF not
		-- it is opened
		-----------------------------------------------------
    BEGIN
      
         ---------To get rate for home currency --> FROM FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
          IF v_cur_type = 'Home Currency' then
            IF(upper(v_CurrencyCode) = 'MMK') then rate := 1;  
            ELSE select VAR_CRNCY_UNITS into rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(v_TrANDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(v_CurrencyCode)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
            END IF;
          ELSE 
           rate := 1;
    END IF;  
   

  IF( v_TrANDate is null or v_cur_type is null ) then
       out_rec:=	('-'
    || '|' ||  '-'
    || '|' || '-'
    || '|' || '-'
    || '|' || 0
    || '|' || 0
    || '|' || '-'
    || '|' || '-'
    || '|' || 0
    || '|' || 0);
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  END IF; 

  IF v_BranchCode IS  NULL or v_BranchCode = v_BranchCode  THEN
  v_BranchCode := v_BranchCode;
  END IF;
  
  IF v_BranchCode is not null then
    SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into BRANCH_NAME,Bank_Address,Bank_Phone ,Bank_Fax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = v_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   else 
   SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into BRANCH_NAME,Bank_Address,Bank_Phone ,Bank_Fax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = '10100' AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
 END IF;
   
 BEGIN 
 
If V_Cur_Type Like 'All%(FCY)' Then
/*
select sum(t.Dr_amt) into v_openingamount  from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
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
  gstt.gl_sub_head_code =  coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('A02')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A02') group by gstt.crncy_code
    )q )t;
     */
       select sum(t.Dr_amt) into v_openingamount 
from (       
        
        SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
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
  AND (gstt.BAL_DATE,gstt.sol_id,coa.group_code) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id ,q.group_code
            FROM(
              SELECT BAL_DATE,gstt.sol_id,coa1.group_code
              FROM tbaadm.gstt,custom.coa_mp coa1
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa1.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa1.cur
              --AND gstt.SOL_ID like   '%' || v_BranchCode || '%' --for Query performance
              AND coa1.group_code in ('A02')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id ,q.group_code
              )
  AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   And Coa.Group_Code In ('A02') Group By Gstt.Crncy_Code)Q)T
   ;
   
   -------------------------------------------------------------------
     IF v_BranchCode IS  NULL or v_BranchCode = v_BranchCode  THEN
         v_BranchCode := v_BranchCode;
    END IF;
   
   -------------------------------------------------------------
       
    IF NOT ExtractData_All_FCY%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All_FCY(v_TrANDate,v_BranchCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All_FCY%ISOPEN THEN
		--{
			FETCH	ExtractData_All_FCY
			INTO	v_gl_sub_head_code, v_gl_sub_head_desc, v_cr_amount, v_dr_amount;      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not IF not the cursor is closed
			-- AND the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All_FCY%NOTFOUND THEN
			--{
	 out_rec:=	(BRANCH_NAME
    || '|' ||  Bank_Address
    || '|' || Bank_Phone
    || '|' || Bank_Fax
    || '|' || 0
    || '|' || 0
    || '|' || '-'
    || '|' || '-'
    || '|' || v_openingamount
    || '|' || rate);
  
			dbms_output.put_line(out_rec);
				CLOSE ExtractData_All_FCY;
				out_retCode:= 1;
				RETURN;    
		
			END IF;
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
    
   END IF;   
   
IF v_cur_type like 'All Currency' then

/*select sum(t.Dr_amt) into v_openingamount 
from (
SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
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
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('A01')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01') group by gstt.crncy_code
   union
   SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt    ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('A02')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A02') group by gstt.crncy_code
   union
   SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND,gstt.crncy_code as cur
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
  AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = coa.cur
              AND coa.group_code in ('A03')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A03') group by gstt.crncy_code
    )q )t;                          
     */  
     /*this is a performance tuning query */
      select sum(t.Dr_amt) into v_openingamount 
from (       
        
        SELECT CASE WHEN q.cur = 'MMK' THEN q.cashinhAND
  ELSE q.cashinhAND * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
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
  AND (gstt.BAL_DATE,gstt.sol_id,coa.group_code) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id ,q.group_code
            FROM(
              SELECT BAL_DATE,gstt.sol_id,coa1.group_code
              FROM tbaadm.gstt,custom.coa_mp coa1
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa1.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.crncy_code  = coa1.cur
              --AND gstt.SOL_ID like   '%' || v_BranchCode || '%' --for Query performance
              AND coa1.group_code in ('A01','A02','A03')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id ,q.group_code
              )
  AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = coa.cur
   AND coa.group_code in ('A01','A02','A03') group by gstt.crncy_code)Q)T
   ;
    IF NOT ExtractData_All%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All(v_TrANDate,v_BranchCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All%ISOPEN THEN
		--{
			FETCH	ExtractData_All
			INTO	v_gl_sub_head_code, v_gl_sub_head_desc, v_cr_amount, v_dr_amount;      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not IF not the cursor is closed
			-- AND the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All%NOTFOUND THEN
			--{
		 out_rec:=	(BRANCH_NAME
    || '|' ||  Bank_Address
    || '|' || Bank_Phone
    || '|' || Bank_Fax
    || '|' || 0
    || '|' || 0
    || '|' || '-'
    || '|' || '-'
    || '|' || v_openingamount
    || '|' || rate);
  
			dbms_output.put_line(out_rec);
				CLOSE ExtractData_All;
				out_retCode:= 1;
				RETURN;  
		
			END IF;
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
    
   END IF;  
   
   If  V_Cur_Type Not Like 'All%'  Then  
   SELECT sum(cashinhAND)  into v_openingamount FROM ( 
SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt 
   ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
    AND (gstt.BAL_DATE,gstt.sol_id,coa.group_code) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id ,q.group_code
            FROM(
              SELECT BAL_DATE,gstt.sol_id,coa1.group_code
              FROM tbaadm.gstt,custom.coa_mp coa1
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa1.gl_sub_head_code = gstt.gl_sub_head_code
              And Gstt.Crncy_Code  = Coa1.Cur
              and gstt.crncy_code = upper(v_CurrencyCode)
              --AND gstt.SOL_ID like   '%' || '30200' || '%' --for Query performance
              AND coa1.group_code in ('A01','A02','A03')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id ,q.group_code
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = upper(v_CurrencyCode)
   And Coa.Cur= Gstt.Crncy_Code
   And Coa.Group_Code In ('A01','A02','A03')
   );
   /*
SELECT sum(cashinhAND)  into v_openingamount FROM ( 
SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashinhAND
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt 
   ,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = coa.gl_sub_head_code
   AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = upper(v_CurrencyCode)
              AND coa.CUR  = upper(v_CurrencyCode)
              AND coa.group_code in ('A01','A02')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gstt.crncy_code = upper(v_CurrencyCode)
   AND coa.cur= gstt.crncy_code
   AND coa.group_code in ('A01','A02')
   
   UNION 
   
   SELECT    
  sum(gstt.tot_dr_bal-gstt.tot_cr_bal) as cashatatm --into v_openingamount
FROM 
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
WHERE
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   AND gstt.sol_id=gsh.sol_id
   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
   --AND gstt.BAL_DATE <= TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
   --AND gstt.END_BAL_DATE >= TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND (gstt.BAL_DATE,gstt.sol_id) in ( 
             SELECT  Max(q.BAL_DATE) , q.sol_id 
            FROM(
              SELECT BAL_DATE,gstt.sol_id
              FROM tbaadm.gstt,custom.coa_mp coa
              WHERE tbaadm.gstt.BAL_DATE < TO_DATE( CAST ( v_TrANDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )    
              --AND tbaadm.gstt.END_BAL_DATE >= TO_DATE( CAST ( '11-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND coa.gl_sub_head_code = gstt.gl_sub_head_code
              AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
              AND gstt.crncy_code  = upper(v_CurrencyCode)
              AND coa.CUR  = upper(v_CurrencyCode)
              AND coa.group_code in ('A03')
              --AND rownum =1
              order by BAL_DATE desc)q
              group by  q.sol_id 
              )
   AND gstt.SOL_ID like   '%' || v_BranchCode || '%'
   AND (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   AND gstt.DEL_FLG = 'N' 
   AND gstt.BANK_ID = '01'
   AND gsh.crncy_code = upper(v_CurrencyCode)
   AND gstt.crncy_code = upper(v_CurrencyCode)
   AND coa.cur= upper(v_CurrencyCode)
   AND coa.group_code in ('A03'));
   */           
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(v_TrANDate,v_BranchCode,v_CurrencyCode);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_gl_sub_head_code, v_gl_sub_head_desc, v_cr_amount, v_dr_amount;      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not IF not the cursor is closed
			-- AND the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
      
    out_rec:=	(BRANCH_NAME
    || '|' ||  Bank_Address
    || '|' || Bank_Phone
    || '|' || Bank_Fax
    || '|' || 0
    || '|' || 0
    || '|' || '-'
    || '|' || '-'
    || '|' || v_openingamount
    || '|' || rate);
  
			dbms_output.put_line(out_rec);
				CLOSE ExtractData;
				out_retCode:= 1;
				RETURN;  
		
			END IF;
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
    
  END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_openingamount := 0;
        
       
  END;    
  

   -----------------------

   
END;     
   
----------------------------------------------------------
  
  
--------------------------------------------
   
  out_rec:=	(BRANCH_NAME
    || '|' ||  Bank_Address
    || '|' || Bank_Phone
    || '|' || Bank_Fax
    || '|' || v_cr_amount
    || '|' || v_dr_amount
    || '|' || v_gl_sub_head_desc
    || '|' || v_gl_sub_head_code
    || '|' || v_openingamount
    || '|' || rate);
  
			dbms_output.put_line(out_rec);
      --dbms_output.put_line( nodata);
  END FIN_CLEAN_CASH;

END FIN_CLEAN_CASH;
/
