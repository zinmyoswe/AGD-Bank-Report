CREATE OR REPLACE PACKAGE FIN_NEW_CAR_RATIO AS 

  PROCEDURE FIN_NEW_CAR_RATIO(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );  

END FIN_NEW_CAR_RATIO;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                         FIN_NEW_CAR_RATIO AS
--{
	-------------------------------------------------------------------------------------
  --updated by Saung Hnin Oo (15-5-2017)
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
	-------------------------------------------------------------------------------------
	outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_Date	   	Varchar2(15);               	-- Input to procedure
--  v_BranchCode	   	Varchar2(15);               	-- Input to procedure
  
    num number;
    CURSOR ExtractData (ci_Date VARCHAR2)
  IS
  select sum(abs(P.Capital_amt)),
       sum(P.Retained_earning),
       sum(P.statutory_reserve),
       sum(P.Profit_lossA40),
       sum(P.Profit_lossA50),
       sum(P.General_Loss),
       sum(P.CashIn_Kyat),
       sum(P.Direct_Claim_CentralBank),
       sum(P.Direct_Claim_CBM),
       sum(P.Others_CBM),
       sum(P.Direct_Claim_CategoryA_A06),
       sum(P.Direct_Claim_CategoryA_A07), 
       sum(P.Direct_Claim_CategoryA_A08),
       sum(P.Cash_collection_A01),
       sum(P.Cash_collection_A31),
       sum(P.Other_CBM_A12),
       sum(P.Other_CBM_A22),
       sum(P.Less_age)
     

from (

select 
 CASE WHEN T.g_code ='L01'   THEN (T.Balance)    END as Capital_amt,
 CASE WHEN T.g_code ='L03'   THEN (T.Balance)    END as Retained_earning,
 CASE WHEN T.g_code ='L02'  and T.gl_sub_head_code in ('70021','70031','70061')  THEN (T.Balance)  END as statutory_reserve,
 CASE WHEN T.g_code in('L40')    THEN (T.Balance)    END as Profit_lossA40,
 CASE WHEN T.g_code ='L50'   THEN (T.Balance)    END as Profit_lossA50,
 CASE WHEN T.g_code ='L55'  -- and T.gl_sub_head_code in ('70031','70061') 
 THEN (T.Balance)    END as General_Loss,
 CASE WHEN T.g_code  in ('A01' , 'A02' , 'A03')   THEN (T.Balance)    END as CashIn_Kyat,
 CASE WHEN T.g_code ='A11'    THEN (T.Balance)    END as Direct_Claim_CentralBank,
 CASE WHEN T.g_code in('A04','A08')    THEN (T.Balance)    END as Direct_Claim_CBM, 
 CASE WHEN T.g_code in('A12')   and T.gl_sub_head_code in ('10202')  THEN (T.Balance)    END as Others_CBM,
 CASE WHEN T.g_code ='A06'    THEN (T.Balance)    END as Direct_Claim_CategoryA_A06,
 CASE WHEN T.g_code ='A07'    THEN (T.Balance)    END as Direct_Claim_CategoryA_A07,
 CASE WHEN T.g_code ='A08'    THEN (T.Balance)    END as Direct_Claim_CategoryA_A08,
 CASE WHEN T.g_code ='A55' 		and T.gl_sub_head_code = '10105'  THEN (T.Balance)    END as Cash_collection_A01,
 CASE WHEN T.g_code  in ('A31' , 'A67')    THEN (T.Balance)    END as Cash_collection_A31,
 CASE WHEN T.g_code ='A12'   and T.gl_sub_head_code = '10202'  THEN (T.Balance)    END as Other_CBM_A12,
 CASE WHEN T.g_code ='A22'   and T.gl_sub_head_code in ('10313','10314') THEN (T.Balance)    END as Other_CBM_A22,
 CASE WHEN T.g_code ='A90'   THEN (T.Balance)    END as Less_age
 
from (
SELECT  q.g_code,
CASE WHEN q.cur = 'MMK' THEN q.Balance
 when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
     ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS Balance ,q.gl_sub_head_code 
    
  FROM
    (SELECT   coa.group_code as g_code,  gstt.crncy_code     AS cur,  (gstt.tot_dr_bal -gstt.tot_cr_bal) AS Balance , gstt.gl_sub_head_code as gl_sub_head_code
            FROM   tbaadm.gstt gstt,  custom.coa_mp coa      
            WHERE coa.gl_sub_head_code = gstt.gl_sub_head_code
            and coa.cur = gstt.crncy_code
            AND gstt.bal_date         <= TO_DATE( CAST (ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND gstt.END_BAL_DATE     >=TO_DATE( CAST (ci_Date AS  VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND gstt.del_flg           = 'N'
            AND gstt.bank_id           = '01'
               )q)T)P;
       
-----------------------------------------------------------------------------
-- Procedure declaration FIN_Training_SPBX Procedure
-----------------------------------------------------------------------------
	
    
PROCEDURE FIN_NEW_CAR_RATIO(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
        v_Capital_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Retained_earning    TBAADM.gstt.tot_cash_cr_amt%type;
        v_statutory_reserve    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Profit_lossA40    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Profit_lossA50    TBAADM.gstt.tot_cash_cr_amt%type;
        v_General_Loss    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CashIn_Kyat    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Direct_Claim_CentralBank    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Direct_Claim_CBM   TBAADM.gstt.tot_cash_cr_amt%type;
        v_Others_CBM    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Direct_Claim_CategoryA_A06    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Direct_Claim_CategoryA_A07    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Direct_Claim_CategoryA_A08    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Cash_collection_A01    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Cash_collection_A31    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Other_CBM_A12    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Other_CBM_A22    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Less_age    TBAADM.gstt.tot_cash_cr_amt%type;
       
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
		 vi_Date := outArr(0);
	
------------------------------------------------------------------------------------------------

 /*if(vi_Date  is null ) then
        --resultstr := 'No Data For Report';
         out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 
							            0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 
										0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;*/

------------------------------------------------------------------------------------------------
IF NOT ExtractData%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractData ( vi_Date );
      --}
    END;
    --}
  END IF;
  IF ExtractData%ISOPEN THEN
    --{
    FETCH ExtractData
    INTO         v_Capital_amt ,v_Retained_earning ,v_statutory_reserve  ,
 v_Profit_lossA40 ,v_Profit_lossA50,v_General_Loss,v_CashIn_Kyat   ,
v_Direct_Claim_CentralBank ,v_Direct_Claim_CBM,v_Others_CBM  ,v_Direct_Claim_CategoryA_A06   ,
v_Direct_Claim_CategoryA_A07 ,v_Direct_Claim_CategoryA_A08 ,v_Cash_collection_A01   ,
v_Cash_collection_A31   , v_Other_CBM_A12   ,v_Other_CBM_A22   , v_Less_age  ;
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
      --}'
    END IF;
    --}
  END IF;
-----------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
IF v_Capital_amt IS  NULL or v_Capital_amt = ''  THEN
         v_Capital_amt := 0;
    END IF;
    
    IF v_Retained_earning IS  NULL or v_Retained_earning = ''  THEN
         v_Retained_earning := 0;
    END IF;
    IF v_statutory_reserve IS  NULL or v_statutory_reserve = ''  THEN
         v_statutory_reserve := 0;
    END IF;
    IF v_Profit_lossA40 IS  NULL or v_Profit_lossA40 = ''  THEN
         v_Profit_lossA40 := 0;
    END IF;
    IF v_Profit_lossA50 IS  NULL or v_Profit_lossA50 = ''  THEN
         v_Profit_lossA50 := 0;
    END IF;
    IF v_General_Loss IS  NULL or v_General_Loss = ''  THEN
         v_General_Loss := 0;
    END IF;
    IF v_CashIn_Kyat IS  NULL or v_CashIn_Kyat = ''  THEN
         v_CashIn_Kyat := 0;
    END IF;
    IF v_Direct_Claim_CentralBank IS  NULL or v_Direct_Claim_CentralBank = ''  THEN
         v_Direct_Claim_CentralBank := 0;
    END IF;
    IF v_Others_CBM IS  NULL or v_Others_CBM = ''  THEN
         v_Others_CBM := 0;
    END IF;
    IF v_Direct_Claim_CategoryA_A06 IS  NULL or v_Direct_Claim_CategoryA_A06 = ''  THEN
         v_Direct_Claim_CategoryA_A06 := 0;
    END IF;
    IF v_Direct_Claim_CategoryA_A07 IS  NULL or v_Direct_Claim_CategoryA_A07 = ''  THEN
         v_Direct_Claim_CategoryA_A07 := 0;
    END IF;
    IF v_Direct_Claim_CategoryA_A08 IS  NULL or v_Direct_Claim_CategoryA_A08 = ''  THEN
         v_Direct_Claim_CategoryA_A08 := 0;
    END IF;
    IF v_Cash_collection_A01 IS  NULL or v_Cash_collection_A01 = ''  THEN
         v_Cash_collection_A01 := 0;
    END IF;
    IF v_Cash_collection_A31 IS  NULL or v_Cash_collection_A31 = ''  THEN
         v_Cash_collection_A31 := 0;
    END IF;
    IF v_Other_CBM_A12 IS  NULL or v_Other_CBM_A12 = ''  THEN
         v_Other_CBM_A12 := 0;
    END IF;
      IF v_Other_CBM_A22 IS  NULL or v_Other_CBM_A22 = ''  THEN
         v_Other_CBM_A22 := 0;
    END IF;
    IF v_Less_age IS  NULL or v_Less_age = ''  THEN
         v_Less_age := 0;
    END IF;
 
   out_rec:= (     v_Capital_amt    || '|' ||
        v_Retained_earning    || '|' ||
        v_statutory_reserve    || '|' ||
        v_Profit_lossA40    || '|' ||
        v_Profit_lossA50    || '|' ||
        v_General_Loss    || '|' ||
        v_CashIn_Kyat    || '|' ||
        v_Direct_Claim_CentralBank    || '|' ||
        v_Direct_Claim_CBM    || '|' ||
        v_Others_CBM    || '|' ||
        v_Direct_Claim_CategoryA_A06    || '|' ||
        v_Direct_Claim_CategoryA_A07    || '|' ||
        v_Direct_Claim_CategoryA_A08    || '|' ||
        v_Cash_collection_A01    || '|' ||
        v_Cash_collection_A31    || '|' ||
        v_Other_CBM_A12    || '|' ||
        v_Other_CBM_A22    || '|' ||
        v_Less_age    ); 
  
			dbms_output.put_line(out_rec);
      RETURN;

	
	END FIN_NEW_CAR_RATIO;


END FIN_NEW_CAR_RATIO;
/
