CREATE OR REPLACE PACKAGE FIN_CASH_RECEIPT_AND_PAYMENT AS 

   PROCEDURE FIN_CASH_RECEIPT_AND_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CASH_RECEIPT_AND_PAYMENT;
/


CREATE OR REPLACE PACKAGE BODY
       FIN_CASH_RECEIPT_AND_PAYMENT AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------


outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_StartDate  	Varchar2(20);               -- Input to procedure
  vi_EndDate  	Varchar2(20);               -- Input to procedure
 -- vi_Monthly 	Varchar2(20);               -- Input to procedure
 vi_Cur	Varchar2(10);		    	    -- Input to procedure
  vi_Cur_Type varchar (50);  -- Input to procedure
 ----------------------------------------------------------------------------- 
CURSOR ExtractData(ci_StartDate VARCHAR2, ci_EndDate VARCHAR2,ci_Cur VARCHAR2)
IS
select sol.sol_id,
sol.sol_desc,
nvl(W.NoOfRTYPE,0),
nvl(W.NoOfPTYPE,0),
nvl(W.receipt,0),
nvl(W.payment,0)
from
(select sol.br_open_date,sol.sol_id, sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      and sol.sol_id not in ( '101','20100')
      order by sol.br_open_date,sol.sol_id) Sol
      left join
(select sum(NoOfRTYPE) as NoOfRTYPE,sum(NoOfPTYPE) as NoOfPTYPE,sum(receipt) as receipt,sum(payment) as payment, T.sol_id,T.cur
     from (
select count(distinct q.receiptcount) as NoOfRTYPE,count( distinct q.paymentcount) as NoOfPTYPE,sum(q.receipt) as receipt,sum(q.payment) as payment,q.sol_id,q.cur

from(
select tran_id,tran_date,
case when part_tran_type = 'C' then tran_amt else 0 end as receipt,
 case when part_tran_type = 'D' then tran_amt else 0 end payment,
 case when part_tran_type = 'C' then tran_id end as receiptcount,
 case when part_tran_type = 'D' then tran_id end as paymentcount,
 cdav.TRAN_CRNCY_CODE as cur,
 cdav.sol_id 
 from custom.custom_ctd_dtd_acli_view cdav,custom.coa_mp coa
 where cdav.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.gl_sub_head_code = coa.gl_sub_head_code
 and cdav.tran_crncy_code = coa.cur
 and cdav.tran_type='C'
 and cdav.pstd_user_id is not null
 and cdav.vfd_user_id is not null
 and cdav.tran_crncy_code=upper(ci_Cur)
 and coa.group_code not in ('A01','A02','A03')
 union all
 select V.tran_id,V.bal_date,
        V.receipt,
        V.payment,
        V.receiptcount,
        V.paymentcount,V.cur,V.sol_id
 from 
 (select 'AG1' as tran_id,gstt.bal_date,
case when sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) > sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) then
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) - sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) 
else 0 end as payment,
case when sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) > sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) then
sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) - sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) 
else 0 end as receipt,
'AG2' as receiptcount,
'AG3' as paymentcount,coa.cur , gstt.sol_id
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and gstt.crncy_code = upper(ci_Cur)
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE >= TO_DATE(ci_StartDate, 'dd-MM-yyyy' )
and gstt.BAL_DATE <= TO_DATE(ci_EndDate, 'dd-MM-yyyy' )
group by 'AG1',gstt.bal_date,'AG2','AG3',coa.cur , gstt.sol_id) V)q
 group by  q.sol_id,q.cur) T
 group by T.sol_id,T.cur)W
 on W.sol_id=  sol.sol_id
 order by sol.sol_desc;
 -----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractData_All(ci_StartDate VARCHAR2, ci_EndDate VARCHAR)
IS
select G.sol_id,G.sol_desc,nvl(sum(G.NoOfRTYPE),0),
nvl(sum(G.NoOfPTYPE),0),nvl(sum(G.receipt),0),nvl(sum(G.payment),0)
from
(select sol.sol_id,
 sol.sol_desc,
W.NoOfRTYPE,
W.NoOfPTYPE,
 CASE WHEN W.cur = 'MMK'  THEN W.receipt
  ELSE W.receipt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(W.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS receipt,      
                              
 CASE WHEN W.cur = 'MMK'  THEN W.payment
  ELSE W.payment * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(W.cur) and r.Rtlist_date = TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
   ),1) END AS  payment
   
   from
(select sol.br_open_date,sol.sol_id, sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      and sol.sol_id not in ( '101','20100')
      order by sol.br_open_date,sol.sol_id) Sol
      
      left join
      
(select sum(NoOfRTYPE) as NoOfRTYPE,sum(NoOfPTYPE) as NoOfPTYPE,sum(receipt) as receipt,sum(payment) as payment, T.sol_id,T.cur
     from (
select count(distinct q.receiptcount) as NoOfRTYPE,count(distinct q.paymentcount) as NoOfPTYPE,sum(q.receipt) as receipt,sum(q.payment) as payment,q.sol_id,q.cur

from(select tran_id,tran_date,
case when part_tran_type = 'C' then tran_amt else 0 end as receipt,
 case when part_tran_type = 'D' then tran_amt else 0 end payment,
 case when part_tran_type = 'C' then tran_id end as receiptcount,
 case when part_tran_type = 'D' then tran_id end as paymentcount,
 cdav.TRAN_CRNCY_CODE as cur,
 cdav.sol_id 
 from custom.custom_ctd_dtd_acli_view cdav,custom.coa_mp coa
 where cdav.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.gl_sub_head_code = coa.gl_sub_head_code
 and cdav.tran_crncy_code = coa.cur
 and cdav.tran_type='C'
 and cdav.pstd_user_id is not null
 and cdav.vfd_user_id is not null
 and coa.group_code not in ('A01','A02','A03')
 union all
 select V.tran_id,V.bal_date,
        V.receipt,
        V.payment,
        V.receiptcount,
        V.paymentcount,V.cur,V.sol_id
 from 
 (select 'AG1' as tran_id,gstt.bal_date,
case when sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) > sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) then
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) - sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) 
else 0 end as payment,
case when sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) > sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) then
sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) - sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) 
else 0 end as receipt,
'AG2' as receiptcount,
'AG3' as paymentcount,coa.cur , gstt.sol_id
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE >= TO_DATE(ci_StartDate, 'dd-MM-yyyy' )
and gstt.BAL_DATE <= TO_DATE(ci_EndDate, 'dd-MM-yyyy' )
group by 'AG1',gstt.bal_date,'AG2','AG3',coa.cur , gstt.sol_id) V
  )q
 group by q.sol_id,q.cur) T
 group by T.sol_id,T.cur)W
 
 on W.sol_id=  sol.sol_id
 order by sol.sol_id) G
 group by G.sol_id,G.sol_desc
 order by G.sol_desc;
----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractData_All_FCY(ci_StartDate VARCHAR2, ci_EndDate VARCHAR2)
IS
select G.sol_id,G.sol_desc,nvl(sum(G.NoOfRTYPE),0),
nvl(sum(G.NoOfPTYPE),0),nvl(sum(G.receipt),0),nvl(sum(G.payment),0)
from
(select sol.sol_id,
 sol.sol_desc,
W.NoOfRTYPE,
W.NoOfPTYPE,
 CASE WHEN W.cur = 'MMK'  THEN W.receipt
  ELSE W.receipt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(W.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS receipt,      
                              
 CASE WHEN W.cur = 'MMK'  THEN W.payment
  ELSE W.payment * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(W.cur) and r.Rtlist_date = TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
   ),1) END AS  payment
   
   from
(select sol.br_open_date,sol.sol_id, sol.sol_desc 
      from tbaadm.sol sol 
      where sol.bank_code = '116'
      and sol.sol_id not in ( '101','20100')
      order by sol.br_open_date,sol.sol_id) Sol
      
      left join
      
(select sum(NoOfRTYPE) as NoOfRTYPE,sum(NoOfPTYPE) as NoOfPTYPE,sum(receipt) as receipt,sum(payment) as payment, T.sol_id,T.cur
     from (
select count(distinct q.receiptcount) as NoOfRTYPE,count(distinct q.paymentcount) as NoOfPTYPE,sum(q.receipt) as receipt,sum(q.payment) as payment,q.sol_id,q.cur

from(select tran_id,tran_date,
case when part_tran_type = 'C' then tran_amt else 0 end as receipt,
 case when part_tran_type = 'D' then tran_amt else 0 end payment,
 case when part_tran_type = 'C' then tran_id end as receiptcount,
 case when part_tran_type = 'D' then tran_id end as paymentcount,
 cdav.TRAN_CRNCY_CODE as cur,
 cdav.sol_id 
 from custom.custom_ctd_dtd_acli_view cdav,custom.coa_mp coa
 where cdav.tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 and cdav.gl_sub_head_code = coa.gl_sub_head_code
 and cdav.tran_crncy_code = coa.cur
 and coa.cur != upper('MMK')
 and cdav.tran_type='C'
 and cdav.pstd_user_id is not null
 and cdav.vfd_user_id is not null
 and coa.group_code not in ('A01','A02','A03')
 union all
 select V.tran_id,V.bal_date,
        V.receipt,
        V.payment,
        V.receiptcount,
        V.paymentcount,V.cur,V.sol_id
 from 
 (select 'AG1' as tran_id,gstt.bal_date,
case when sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) > sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) then
sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) - sum(gstt.tot_clg_cr_amt + gstt.tot_xfer_cr_amt) 
else 0 end as payment,
case when sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) > sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) then
sum(gstt.tot_clg_Cr_amt + gstt.tot_xfer_Cr_amt) - sum(gstt.tot_clg_dr_amt + gstt.tot_xfer_dr_amt) 
else 0 end as receipt,
'AG2' as receiptcount,
'AG3' as paymentcount,coa.cur , gstt.sol_id
from tbaadm.gstt,custom.coa_mp coa
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and coa.cur = gstt.crncy_code 
and gstt.crncy_code != upper('MMK')
and coa.group_code not in ('A01','A02','A03')
and gstt.BAL_DATE >= TO_DATE(ci_StartDate, 'dd-MM-yyyy' )
and gstt.BAL_DATE <= TO_DATE(ci_EndDate, 'dd-MM-yyyy' )
group by 'AG1',gstt.bal_date,'AG2','AG3',coa.cur , gstt.sol_id) V
  )q
 group by q.sol_id,q.cur) T
 group by T.sol_id,T.cur)W
 
 on W.sol_id=  sol.sol_id
 order by sol.sol_id) G
 group by G.sol_id,G.sol_desc
 order by G.sol_desc;


--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIN_CASH_RECEIPT_AND_PAYMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
v_sol_id tbaadm.sol.sol_id%type;
v_sol_desc tbaadm.sol.sol_desc%type;
v_NoOfRTYPE custom.custom_ctd_dtd_acli_view.tran_id%type;
v_NoOfPTYPE custom.custom_ctd_dtd_acli_view.tran_id%type;
v_receipt  custom.custom_ctd_dtd_acli_view.tran_amt%type; 
v_payment custom.custom_ctd_dtd_acli_view.tran_amt%type; 
vi_Cur custom.custom_ctd_dtd_acli_view.tran_crncy_code%type;
vi_rate varchar(20);   

BEGIN
		out_retCode := 0;
		out_rec := NULL;
      tbaadm.basp0099.formInputArr(inp_str, outArr);
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 vi_StartDate   :=  outArr(0);			
  vi_EndDate  	 :=  outArr(1);		
  --vi_Monthly  :=  outArr(2);		
  vi_Cur		 :=  outArr(2);		
  vi_Cur_Type  :=  outArr(3);		
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if vi_Cur_Type not like 'All%' then
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_StartDate, vi_EndDate,vi_Cur);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_sol_id, v_sol_desc, v_NoOfRTYPE ,v_NoOfPTYPE,v_receipt,v_payment;
      

			------------------------------------------------------------------
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
    end if; 
 ---------------------------------------------------------------------------   
    if vi_Cur_Type like 'All%(FCY)' then
    
    IF NOT ExtractData_All_FCY%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All_FCY (vi_StartDate, vi_EndDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All_FCY%ISOPEN THEN
		--{
			FETCH	ExtractData_All_FCY
			INTO	v_sol_id, v_sol_desc, v_NoOfRTYPE ,v_NoOfPTYPE ,v_receipt,v_payment ;
      
			------------------------------------------------------------------
			IF ExtractData_All_FCY%NOTFOUND THEN
			--{
				CLOSE ExtractData_All_FCY;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    end if; 
    
    if vi_Cur_Type =  'All Currency' then
    
    IF NOT ExtractData_All%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All (vi_StartDate, vi_EndDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All%ISOPEN THEN
		--{
			FETCH	ExtractData_All
			INTO	v_sol_id,v_sol_desc, v_NoOfRTYPE ,v_NoOfPTYPE ,v_receipt,v_payment ;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All%NOTFOUND THEN
			--{
				CLOSE ExtractData_All;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    end if; 
  ------------------------------------------------------------------------------
---------------------------------------------------------------------------------
 BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_Cur_Type  = 'Home Currency' THEN
                if upper(vi_Cur) = 'MMK' THEN vi_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_Cur)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF vi_Cur_Type = 'Source Currency' THEN
                 
                      vi_rate := 1;
              ELSE
                  vi_rate := 1;
              END IF;
  end;
--------------------------------------------------------------------------------
------------------------------------------------------------------------------
  out_rec:=  (
v_sol_id  || '|' ||
v_sol_desc || '|' ||
v_NoOfRTYPE || '|' ||
v_NoOfPTYPE || '|' ||
v_receipt  || '|' ||
v_payment || '|' ||
vi_Cur  || '|' ||
vi_rate );
dbms_output.put_line(out_rec);
    
END FIN_CASH_RECEIPT_AND_PAYMENT;
END FIN_CASH_RECEIPT_AND_PAYMENT;
/
