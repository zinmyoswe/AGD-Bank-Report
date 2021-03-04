CREATE OR REPLACE PACKAGE        FIN_DAILY_LOAN_DEPOSIT_RATIO AS 

  subtype limited_string is varchar2(2000);
  PROCEDURE FIN_DAILY_LOAN_DEPOSIT_RATIO(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ); 

END FIN_DAILY_LOAN_DEPOSIT_RATIO;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_DAILY_LOAN_DEPOSIT_RATIO AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_StartDate		Varchar2(10);		    	  -- Input to procedure
--  vi_EndDate		Varchar2(10);		    	  -- Input to procedure
 
    
CURSOR ExtractDataAllBranch(ci_StartDate VARCHAR2) IS
 
 select sum(NVL(DemandLoan,0)) DemandLoan
  , sum(NVL(OverDraft,0) ) OverDraft
  , sum(NVL(HirePurchase,0)) HirePurchase
  , sum(NVL(StaffLoan,0)) StaffLoan 
  ,sum(NVL(CurrentAcct,0)) CurrentAcct
  ,sum(NVL(SavingAcct,0)) SavingAcct
  ,sum(NVL(SpecialAcct,0)) SpecialAcct
  ,sum(NVL(FixedDeposit,0)) FixedDeposit
from (
SELECT BAL_DATE, 
  CASE WHEN CRNCY_CODE = 'MMK' THEN DemandLoan
  ELSE DemandLoan * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DemandLoan,
  CASE WHEN CRNCY_CODE = 'MMK' THEN OverDraft
  ELSE OverDraft * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS OverDraft,
   CASE WHEN CRNCY_CODE = 'MMK' THEN HirePurchase
  ELSE HirePurchase * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS     HirePurchase,
  CASE WHEN CRNCY_CODE = 'MMK' THEN StaffLoan
  ELSE StaffLoan * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS     StaffLoan,
  CASE WHEN CRNCY_CODE = 'MMK' THEN CurrentAcct
  ELSE CurrentAcct * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS     CurrentAcct,
  CASE WHEN CRNCY_CODE = 'MMK' THEN SavingAcct
  ELSE SavingAcct * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS     SavingAcct,
  CASE WHEN CRNCY_CODE = 'MMK' THEN SpecialAcct
  ELSE SpecialAcct * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(CRNCY_CODE) and r.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS     SpecialAcct ,
                              
   CASE WHEN CRNCY_CODE = 'MMK' THEN FixedDeposit
  ELSE FixedDeposit * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     FixedDeposit                           
  
  FROM
  (
 SELECT BAL_DATE,CRNCY_CODE,DemandLoan,OverDraft, HirePurchase
      , StaffLoan, CurrentAcct, SavingAcct,SpecialAcct,FixedDeposit
      FROM
      (SELECT CASE WHEN coa.group_code = 'A21' THEN '1'
      WHEN coa.group_code = 'A23' THEN '2'
      WHEN coa.group_code = 'A24' THEN '3'
      WHEN coa.group_code = 'A25' THEN '4'
      WHEN coa.group_code in ( 'L11','L21','L22') THEN '5'
      WHEN coa.group_code in ('L13','L24') THEN '6'
      WHEN coa.group_code = 'L15' THEN '7'
      WHEN coa.group_code in ( 'L17' ,'L26') THEN '8'
      ELSE '9' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      and gstt.BAL_DATE <= TO_DATE( ci_StartDate, 'dd-MM-yyyy' )
      and gstt.END_BAL_DATE >= TO_DATE( ci_StartDate, 'dd-MM-yyyy' )
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS DemandLoan, '2' AS OverDraft, '3' AS HirePurchase
      , '4' AS StaffLoan, '5' AS CurrentAcct, '6' AS SavingAcct, '7' as SpecialAcct, '8' as FixedDeposit)
      ) WHERE BAL_DATE IS NOT NULL)q) ;--group by BAL_DATE ;
    
    

  PROCEDURE FIN_DAILY_LOAN_DEPOSIT_RATIO(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ) IS    
     
      
      v_Total number;
      
      DemandLoan TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      OverDraft TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      StaffLoan TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      HirePurchase TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      CurrentAcct TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      SavingAcct TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      SpecialAcct TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      FixedDeposit TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
      LoanAdvance TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type;
          
      v_date TBAADM.GL_SUB_HEAD_TRAN_TABLE.BAL_DATE%type;
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
    
    vi_StartDate:=outArr(0);
 --   vi_EndDate:=outArr(1);
 -------------------------------------------------------------------------------
 if( vi_StartDate is null ) then
        --resultstr := 'No Data For Report';
       
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 ---------------------------------------------------------------------------------
 --if cur---
    IF NOT ExtractDataAllBranch%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAllBranch(vi_StartDate);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataAllBranch%ISOPEN THEN
    
    	FETCH	ExtractDataAllBranch
			INTO	 DemandLoan  ,OverDraft,HirePurchase,StaffLoan,CurrentAcct,SavingAcct,SpecialAcct,FixedDeposit;
		  ------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAllBranch%NOTFOUND THEN
			--{
				CLOSE ExtractDataAllBranch;
				out_retCode:= 1;
				RETURN;  
			--}
			END IF;
    END IF;  
-------------------------------------------------------------------------------

     
    out_rec:=	( to_char(to_date(v_date,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' || 
       DemandLoan  || '|' ||
       HirePurchase  || '|' ||
       OverDraft  || '|' ||
       StaffLoan  || '|' ||
       CurrentAcct  || '|' ||
       SavingAcct || '|' ||
       SpecialAcct  || '|' ||
       FixedDeposit  || '|' ||
       LoanAdvance  );
    
      dbms_output.put_line(out_rec);
  END FIN_DAILY_LOAN_DEPOSIT_RATIO;

END FIN_DAILY_LOAN_DEPOSIT_RATIO;
/
