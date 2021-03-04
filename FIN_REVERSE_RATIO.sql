CREATE OR REPLACE PACKAGE        FIN_REVERSE_RATIO AS 

  PROCEDURE FIN_REVERSE_RATIO(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_REVERSE_RATIO;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                           FIN_REVERSE_RATIO AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;        -- Input Parse Array

  
limitsize  INTEGER := 400;
  vi_startDate  VARCHAR2(10);                   ---- Input Parse Array
  vi_EndDate  VARCHAR2(10);                   ---- Input Parse Array
  vi_month  VARCHAR2(10);                   ---- Input Parse Array
  vi_year   VARCHAR2(10);                   ---- Input Parse Array
-------------------------------------------------------------------------------------------  
-------------------------------------------------------------------------
CURSOR ExtractData(ci_startDate varchar2 ,ci_EndDate varchar2 ) is
 select 
 T.bal_date as bal_date,
 SUM(T.MMK_CurrentAcc_bal)/1000000  as MMK_CurrentAcc_bal,
    SUM(T.USD_CurrentAcc_bal)/1000000  as USD_CurrentAcc_bal,
    '' as Running_MMKamt,
    '' as Running_USDamt 
 
    
FROM
(select q.bal_date as bal_date, 
CASE WHEN q.g_code  ='A04' and q.gl_head_code not in ('10108')  and q.cur='MMK' THEN q.amt    END as  MMK_CurrentAcc_bal,
CASE WHEN q.g_code  ='A05'  and q.cur='USD' THEN q.amt    END as USD_CurrentAcc_bal

from 
(
select 
coa.group_code as g_code,
coa.gl_sub_head_code as gl_head_code, 
sum(Round(abs(gstt.tot_dr_bal-gstt.tot_cr_bal))) as amt , 
coa.cur  as cur,
gstt.bal_date as bal_date
from custom.coa_mp coa , tbaadm.gstt gstt
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and gstt.crncy_code = coa.cur
and gstt.BAL_DATE >= to_date(cast(ci_startDate as varchar(10)), 'dd-MM-yyyy')
and gstt.END_BAL_DATE <= to_date(cast(ci_EndDate as varchar(10)), 'dd-MM-yyyy')
and GSTT.DEL_FLG = 'N'
AND GSTT.BANK_ID = '01'
group by 
coa.group_code ,
coa.gl_sub_head_code , 
coa.cur  ,
gstt.bal_date 
)q)T
group by T.bal_date
order by T.bal_date ;

CURSOR ExtractDataForResult IS
select Tran_Date,MMK_CurrentAcc_bal,USD_CurrentAcc_bal,Running_MMKamt,Running_USDamt from CUSTOM.temp_reserve_ratio order by ID ;
  
  
 TYPE mainretailtable IS TABLE OF ExtractData%ROWTYPE INDEX BY BINARY_INTEGER;
  ptmainretailtable         mainretailtable;
----------------------------------------------

  PROCEDURE FIN_REVERSE_RATIO(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      
      v_bal_date  tbaadm.gstt.bal_date%type;
      v_MMK_CurrentAcc_bal tbaadm.gstt.tot_dr_bal%type;
      v_USD_CurrentAcc_bal tbaadm.gstt.tot_dr_bal%type;
      
      v_Running_MMKamt  tbaadm.gstt.tot_dr_bal%type;
      v_Running_USDamt  tbaadm.gstt.tot_dr_bal%type;
      v_CurrentMMK_amt tbaadm.gstt.tot_dr_bal%type;
      v_SavingMMK_amt tbaadm.gstt.tot_dr_bal%type;
      v_SpecialMMK_amt tbaadm.gstt.tot_dr_bal%type;
      v_FixedMMK_amt tbaadm.gstt.tot_dr_bal%type;
      v_CurrentFCY_amt tbaadm.gstt.tot_dr_bal%type;
      v_SavingFCY_amt tbaadm.gstt.tot_dr_bal%type;
      v_SpecialFCY_amt tbaadm.gstt.tot_dr_bal%type;
      v_FixedFCY_amt tbaadm.gstt.tot_dr_bal%type;
      v_rate tbaadm.rth.VAR_CRNCY_UNITS%type;
      v_MMK_CurrentAcc_bal1 tbaadm.gstt.tot_dr_bal%type;
      v_USD_CurrentAcc_bal1   tbaadm.gstt.tot_dr_bal%type;
      ID  number := 0;
      v_Running_MMKamt1 tbaadm.gstt.tot_dr_bal%type;
   v_count number :=0;
      
      
      
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
    
    vi_startDate := outArr(0);	
    vi_EndDate := outArr(1);	
    vi_month  := outArr(2);	
    vi_year  := outArr(3);	
    -----------------------------------------------
     ------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(vi_startDate,vi_EndDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
      BEGIN
      
      delete from custom.temp_reserve_ratio ; commit;   
			FETCH	ExtractData 	Bulk Collect Into ptmainretailtable LIMIT limitsize;     --outer Cursor
      
      v_MMK_CurrentAcc_bal1 := 0;
      
      v_USD_CurrentAcc_bal1 := 0;
      v_Running_MMKamt1 := 0;
      v_Running_USDamt := 0;
      v_Running_MMKamt1 := ptmainretailtable(1).MMK_CurrentAcc_Bal;
      v_Running_USDamt := ptmainretailtable(1).USD_CurrentAcc_Bal;
            
         FOR outindx IN 1.. ptmainretailtable.COUNT
         loop
         v_bal_date := ptmainretailtable(outindx).bal_date;
         
        v_MMK_CurrentAcc_bal1 := ptmainretailtable(outindx).MMK_CurrentAcc_Bal;
        v_USD_CurrentAcc_bal := ptmainretailtable(outindx).USD_CurrentAcc_Bal;
        
        
        
         if v_MMK_CurrentAcc_bal1 is null or v_MMK_CurrentAcc_bal1 = '' then
         v_MMK_CurrentAcc_bal1 := 0;
         end if;
         
          if v_USD_CurrentAcc_bal is null or v_USD_CurrentAcc_bal = '' then
         v_USD_CurrentAcc_bal := 0;
         end if;
         
         if outindx = 1 then         
         insert into custom.temp_reserve_ratio  
         values(v_bal_date,v_MMK_CurrentAcc_bal1,v_USD_CurrentAcc_bal,
         0,0,outindx,0,0) ;        
         end if;
         
         if v_Running_MMKamt1 is null or v_Running_MMKamt1 = '' then
         v_Running_MMKamt1 := 0;
         end if;
         
           if v_Running_USDamt is null or v_Running_USDamt = '' then
         v_Running_USDamt := 0;
         end if;
         
         if outindx > 1 then         
         v_Running_MMKamt1 := v_Running_MMKamt1 + v_MMK_CurrentAcc_bal1;
         v_Running_USDamt := v_Running_USDamt + v_USD_CurrentAcc_bal; 
      
         insert into custom.temp_reserve_ratio
         values(v_bal_date,v_MMK_CurrentAcc_bal1,v_USD_CurrentAcc_bal,v_Running_MMKamt1,v_Running_USDamt,outindx,0,0) ;
       
         end if;

         end loop;
      COMMIT;
       dbms_output.put_line('Commit 1'); 
      -- END  IF;
       END;
  --  END  IF;
			------------------------------------------------------------------
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
   
    -----------------------------------------------------------------
    
    
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
   
     -- dobal := dobal + OpeningAmount;
      FETCH	ExtractDataForResult INTO	 v_bal_date,v_MMK_CurrentAcc_bal,v_USD_CurrentAcc_bal,v_Running_MMKamt,v_Running_USDamt;
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
    
    -------------------------------------------------
    
    
    
    -------------------------------------------------
 
-------------------------------------------------------------------------
------------for deposite-----------------------------------------------
------------------------------------------------------------------------
Begin
   select
    SUM(P.CurrentMMK_amt),
    SUM(P.SavingMMK_amt),
    SUM(P.SpecialMMK_amt),
    SUM(P.FixedMMK_amt),
    SUM(P.CurrentFCY_amt),
    SUM(P.SavingFCY_amt),
    SUM(P.SpecialFCY_amt),
    
    SUM(P.FixedFCY_amt)
    into  v_CurrentMMK_amt ,  v_SavingMMK_amt ,  v_SpecialMMK_amt , v_FixedMMK_amt,
          v_CurrentFCY_amt , v_SavingFCY_amt, v_SpecialFCY_amt , v_FixedFCY_amt 
   
   
   
   

FROM
(select 
CASE WHEN T.g_code  ='L11'  and T.cur='MMK' THEN T.amt    END as  CurrentMMK_amt,
CASE WHEN T.g_code  ='L13'  and T.cur='MMK'  THEN T.amt    END as SavingMMK_amt ,
CASE WHEN T.g_code  ='L15'  and T.cur='MMK'  THEN T.amt    END as SpecialMMK_amt ,
CASE WHEN T.g_code  ='L17'  and T.cur='MMK'  THEN T.amt    END as FixedMMK_amt ,

CASE WHEN T.g_code  ='L11'  and T.cur='USD' THEN T.fcy_amt    END as  CurrentFCY_amt,
CASE WHEN T.g_code  ='L13'  and T.cur='USD'  THEN T.fcy_amt    END as SavingFCY_amt ,
CASE WHEN T.g_code  ='L15'  and T.cur='USD'  THEN T.fcy_amt    END as SpecialFCY_amt ,
CASE WHEN T.g_code  ='L17'  and T.cur='USD'  THEN T.fcy_amt    END as FixedFCY_amt 

from 
(
select q.g_code,q.gl_head_code,q.amt ,q.cur ,

  CASE WHEN q.cur = 'MMK' THEN q.amt
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS   
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('USD') 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where
                                                     trim(to_char(r.Rtlist_date, 'MONTH'))  = upper(vi_month) 
                                                                          and extract(year from r.Rtlist_date) = vi_year                                               
                                                    )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where       
                                                                      trim(to_char(a.Rtlist_date, 'MONTH'))   = upper(vi_month) 
                                                                           and extract(year from a.Rtlist_date) = vi_year
                                                                                )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS fcy_amt 
from 
(
select 
coa.group_code as g_code,
coa.gl_sub_head_code as gl_head_code, 
Abs(sum(gstt.tot_dr_bal-gstt.tot_cr_bal)) as amt , 
coa.cur  as cur
from custom.coa_mp coa , tbaadm.gstt gstt
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and gstt.crncy_code = coa.cur
and trim(to_char(gstt.bal_date, 'MONTH'))  = upper(vi_month) 
and extract(year from gstt.bal_date) = vi_year
and GSTT.DEL_FLG = 'N'
AND GSTT.BANK_ID = '01'
group by coa.group_code ,
coa.gl_sub_head_code , 
coa.cur  
)q)T)P
;
end;
----------------------------------------------------------------------------
--------------------for rate-------------------------------------------------

SELECT r.VAR_CRNCY_UNITS   into v_rate 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('USD') 
                                and r.Rtlist_date =(select max(r.Rtlist_date)
                                                    from TBAADM.RTH r 
                                                    where
                                                     trim(to_char(r.Rtlist_date, 'MONTH'))  = upper(vi_month) 
                                                                          and extract(year from r.Rtlist_date) = vi_year
                           --   to_char( r.Rtlist_date ,'MM-YYYY') = TO_CHAR(to_date(cast(vi_month || '-' || vi_year as varchar(10)), 'MM-yyyy'),'MM-yyyy')                      
                                                   
                                                    )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =(select max(a.Rtlist_date)
                                                                                            from TBAADM.RTH a 
                                                                                            where
                                                              --  to_char( a.Rtlist_date ,'MM-YYYY') = TO_CHAR(to_date(cast(vi_month || '-' || vi_year as varchar(10)), 'MM-yyyy'),'MM-yyyy')                             
                                                                      trim(to_char(a.Rtlist_date, 'MONTH'))   = upper(vi_month) 
                                                                           and extract(year from a.Rtlist_date) = vi_year
                                                                                )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );

----------------------------------------------------
     IF v_CurrentMMK_amt IS NULL OR v_CurrentMMK_amt = '' THEN
   v_CurrentMMK_amt  := 0;
  END IF;
------------------------------------------------------
 IF v_SavingMMK_amt IS NULL OR v_SavingMMK_amt = '' THEN
   v_SavingMMK_amt  := 0;
  END IF;
-------------------------------------------------
 IF v_SpecialMMK_amt IS NULL OR v_SpecialMMK_amt = '' THEN
   v_SpecialMMK_amt  := 0;
  END IF;
---------------------------------------------------
 IF v_FixedMMK_amt IS NULL OR v_FixedMMK_amt = '' THEN
   v_FixedMMK_amt  := 0;
  END IF;
-------------------------------------------
 IF v_CurrentFCY_amt IS NULL OR v_CurrentFCY_amt = '' THEN
   v_CurrentFCY_amt  := 0;
  END IF;
--------------------------------------------------
 IF v_SavingFCY_amt IS NULL OR v_SavingFCY_amt = '' THEN
   v_SavingFCY_amt  := 0;
  END IF;
-----------------------------------------
 IF v_SpecialFCY_amt IS NULL OR v_SpecialFCY_amt = '' THEN
   v_SpecialFCY_amt  := 0;
  END IF;
---------------------------------------------
 IF v_FixedFCY_amt IS NULL OR v_FixedFCY_amt = '' THEN
   v_FixedFCY_amt  := 0;
  END IF;
 

---------------------------------------------
IF v_rate IS NULL OR v_rate = '' THEN
   v_rate  := 0; 
  END IF;

---------------------------------------------------------------
IF v_USD_CurrentAcc_bal IS NULL OR v_USD_CurrentAcc_bal = '' THEN
   v_USD_CurrentAcc_bal  := 0; 
  END IF;

---------------------------------------------
IF v_MMK_CurrentAcc_bal IS NULL OR v_MMK_CurrentAcc_bal = '' THEN

   v_MMK_CurrentAcc_bal  := 0; 
  END IF;

---------------------------------------------------------------
---------------------------------------------------------------
IF v_Running_MMKamt IS NULL OR v_Running_MMKamt = '' THEN
   v_Running_MMKamt  := 0; 
  END IF;

---------------------------------------------
IF v_Running_USDamt IS NULL OR v_Running_USDamt = '' THEN

   v_Running_USDamt  := 0; 
  END IF;

---------------------------------------------------------------
  
  out_rec:=	(  
  
              v_bal_date  || '|' ||
            v_MMK_CurrentAcc_bal || '|' ||
             v_USD_CurrentAcc_bal  || '|' ||
              
               v_Running_MMKamt  || '|' ||
               
             v_Running_USDamt       || '|' ||
              
                v_CurrentMMK_amt || '|' ||
                v_SavingMMK_amt || '|' || 
                v_SpecialMMK_amt || '|' ||
                v_FixedMMK_amt || '|' ||
                v_CurrentFCY_amt || '|' ||
                v_SavingFCY_amt || '|' ||
                v_SpecialFCY_amt || '|' || 
                v_FixedFCY_amt || '|' ||
                v_rate 
      ); 
    dbms_output.put_line(out_rec);
  
  END FIN_REVERSE_RATIO;

END FIN_REVERSE_RATIO;
/
