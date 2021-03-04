CREATE OR REPLACE PACKAGE        FIN_DAILY_FE_BALANCE AS 

  PROCEDURE FIN_DAILY_FE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DAILY_FE_BALANCE;
/


CREATE OR REPLACE PACKAGE BODY        FIN_DAILY_FE_BALANCE AS

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		Varchar2(10);		    	    -- Input to procedure
  v_rate decimal;

  Cursor ExtractData(ci_startDate varchar2) is
   SELECT Q.Gl_Sub_Head_desc as GL,
        ABS(SUM(USD)),ABS(SUM(EUR)),ABS(SUM(SGD)),ABS(SUM(JPY)),ABS(SUM(THB)),ABS(SUM(MYR))
       -- INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
    From (
      SELECT   coa.Gl_Sub_Head_desc as  Gl_Sub_Head_desc,
              case when  GSTT.CRNCY_CODE = 'USD' then    abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL)else 0 end as USD,
              case when  GSTT.CRNCY_CODE = 'EUR' then    abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as EUR,
              case when  GSTT.CRNCY_CODE = 'SGD' then    abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as SGD,
              case when  GSTT.CRNCY_CODE = 'JPY' then   abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as JPY,
              case when  GSTT.CRNCY_CODE = 'THB' then    abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as THB,
              case when  GSTT.CRNCY_CODE = 'MYR' then    abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   Q.Tran_Date_Bal else 0 end as INR
      FROM    TBAADM.GSTT GSTT , CUSTOM.COA_MP COA
      WHERE   COA.GL_SUB_HEAD_CODE = GSTT.GL_SUB_HEAD_CODE
      And     Coa.Cur = Gstt.Crncy_Code
      AND     COA.gl_sub_head_code in ('10137','10135','10136','10140','10133','10160','10132','10134','10139','10161')
      AND     GSTT.GL_SUB_HEAD_CODE  <> '10142' 
      AND     gstt.BAL_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND     GSTT.END_BAL_DATE >=TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')  
      
      Union All
      
      Select  Case When  Gam.Foracid ='2030010131023012' Then 'Nostro Acc with May Bank' Else 'Nostro Acc with May Bank(Spore)' End As Gl_Sub_Head_Desc,
              Case When  Coa.Cur = 'USD' Then    Eab.Tran_Date_Bal Else 0 End As Usd,
              case when  Coa.Cur = 'EUR' then    eab.Tran_date_bal  else 0 end as EUR,
              Case When  Coa.Cur = 'SGD' Then    Eab.Tran_Date_Bal  Else 0 End As Sgd,
              Case When  Coa.Cur = 'JPY' Then    Eab.Tran_Date_Bal  Else 0 End As Jpy,
              case when  Coa.Cur = 'THB' then    eab.Tran_date_bal  else 0 end as THB,
              case when  Coa.Cur = 'MYR' then    eab.Tran_date_bal else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   Q.Tran_Date_Bal else 0 end as INR
      FROM    TBAADM.eab eab , CUSTOM.COA_MP COA, tbaadm.gam gam
      Where   Gam.Acct_Crncy_Code = Coa.Cur
      and     gam.acid = eab.acid
      and     coa.gl_sub_head_code = gam.gl_sub_head_code
      And     Coa.Gl_Sub_Head_Code= '10131'
      And     Gam.Foracid In ('2030010131023012','2030010131023022')
      AND     eab.eod_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      And     eab.End_eod_Date >=To_Date(Cast(ci_startDate As Varchar(10)),'dd-MM-yyyy')  
      
      Union All
      
      Select  'NOSTRO ACCOUNT WITH UOB' As Gl_Sub_Head_Desc,
              Case When  Coa.Cur = 'USD' Then    Eab.Tran_Date_Bal Else 0 End As Usd,
              case when  Coa.Cur = 'EUR' then    eab.Tran_date_bal  else 0 end as EUR,
              Case When  Coa.Cur = 'SGD' Then    Eab.Tran_Date_Bal  Else 0 End As Sgd,
              Case When  Coa.Cur = 'JPY' Then    Eab.Tran_Date_Bal  Else 0 End As Jpy,
              case when  Coa.Cur = 'THB' then    eab.Tran_date_bal  else 0 end as THB,
              case when  Coa.Cur = 'MYR' then    eab.Tran_date_bal else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   Q.Tran_Date_Bal else 0 end as INR
      FROM    TBAADM.eab eab , CUSTOM.COA_MP COA, tbaadm.gam gam
      Where   Gam.Acct_Crncy_Code = Coa.Cur
      and     gam.acid = eab.acid
      and     coa.gl_sub_head_code = gam.gl_sub_head_code
      And     Coa.Gl_Sub_Head_Code= '10130'
      And     Gam.Foracid LIKE '203001013002201%' --2030010130022022
      AND     eab.eod_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)),'dd-MM-yyyy')
      And     Eab.End_Eod_Date >=To_Date(Cast(ci_startDate As Varchar(10)),'dd-MM-yyyy')  
      
      UNION ALL
       
      Select  'NOSTRO ACCOUNT WITH UOB BANK(UPI)' As Gl_Sub_Head_Desc,
              Case When  Coa.Cur = 'USD' Then    Eab.Tran_Date_Bal Else 0 End As Usd,
              case when  Coa.Cur = 'EUR' then    eab.Tran_date_bal  else 0 end as EUR,
              Case When  Coa.Cur = 'SGD' Then    Eab.Tran_Date_Bal  Else 0 End As Sgd,
              Case When  Coa.Cur = 'JPY' Then    Eab.Tran_Date_Bal  Else 0 End As Jpy,
              case when  Coa.Cur = 'THB' then    eab.Tran_date_bal  else 0 end as THB,
              case when  Coa.Cur = 'MYR' then    eab.Tran_date_bal else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   Q.Tran_Date_Bal else 0 end as INR
      FROM    TBAADM.eab eab , CUSTOM.COA_MP COA, tbaadm.gam gam
      Where   Gam.Acct_Crncy_Code = Coa.Cur
      and     gam.acid = eab.acid
      and     coa.gl_sub_head_code = gam.gl_sub_head_code
      And     Coa.Gl_Sub_Head_Code= '10130'
      And     Gam.Foracid LIKE '203001013002202%' --2030010130022022
      And     Eab.Eod_Date <= To_Date(Cast(ci_startDate As Varchar(10)),'dd-MM-yyyy')
      And     Eab.End_Eod_Date >=To_Date(Cast(ci_startDate As Varchar(10)),'dd-MM-yyyy')  
    )Q
  Group By Q.Gl_Sub_Head_Desc
  ORDER BY Q.GL_SUB_HEAD_DESC;

  FUNCTION FUNC_GET_CURRENCY_RATE(currency varchar2, ci_Date varchar2) 
   RETURN number AS
   
   v_rate number;
  BEGIN
    BEGIN
        SELECT r.VAR_CRNCY_UNITS   INTO v_rate
        FROM TBAADM.RTH r
        WHERE r.fxd_crncy_code       = Upper(currency) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
        AND r.RATECODE               = 'NOR'
        AND trim(r.VAR_CRNCY_CODE)   = 'MMK'
        AND (fxd_crncy_code, Rtlist_date,r.Rtlist_num) IN
          (SELECT a.fxd_crncy_code,
            MAX(a.Rtlist_date),
            MAX(a.rtlist_num)
          FROM TBAADM.RTH a
          WHERE a.RATECODE     = 'NOR'
          AND a.fxd_crncy_code = Upper(currency)
          AND (a.Rtlist_date) IN
            (SELECT MAX(a.Rtlist_date)
            FROM TBAADM.RTH a
            WHERE a.Rtlist_date       <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND a.RATECODE             = 'NOR'
            AND trim(a.VAR_CRNCY_CODE) = 'MMK'
            )
          AND trim(a.VAR_CRNCY_CODE) = 'MMK'
          GROUP BY a.fxd_crncy_code
      ) ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_rate := 1;
    END;
    RETURN v_rate;
  END FUNC_GET_CURRENCY_RATE;

  PROCEDURE FIN_DAILY_FE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_description varchar2(254);
      v_glSubHeadCode TBAADM.gstt.GL_SUB_HEAD_CODE%TYPE;
      v_usdAmt number := 0;
      v_eurAmt number := 0;
      v_sgdAmt number := 0;
      v_jpyAmt number := 0;
      v_thbAmt number := 0;
      v_myrAmt number := 0;
      v_usdRate number := 1;
      v_eurRate number := 1;
      v_sgdRate number := 1;
      v_jpyRate number := 1;
      v_thbRate number := 1;
      v_myrRate number := 1;
      
      
      
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
    
    vi_startDate :=outArr(0);		
    
    BEGIN
    
    v_usdRate := FUNC_GET_CURRENCY_RATE('USD',vi_startDate);
    v_eurRate := FUNC_GET_CURRENCY_RATE('EUR',vi_startDate);
    v_sgdRate := FUNC_GET_CURRENCY_RATE('SGD',vi_startDate);
    v_jpyRate := FUNC_GET_CURRENCY_RATE('JPY',vi_startDate);
    v_thbRate := FUNC_GET_CURRENCY_RATE('THB',vi_startDate);
    v_myrRate := FUNC_GET_CURRENCY_RATE('MYR',vi_startDate);
    END;
    	
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(vi_startDate);
			--}
			END;

		--}
		END IF;
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_description, v_usdAmt, v_eurAmt,
      v_sgdAmt,v_jpyAmt,v_thbAmt,v_myrAmt;
      

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
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
    
    Out_Rec:=	(V_Description            || '|' ||
          V_Usdamt      			          || '|' ||
					V_Euramt	                    || '|' ||
					V_Sgdamt                      || '|' ||
					V_Jpyamt                      || '|' ||
					V_Thbamt                      || '|' ||
					V_Myramt                      || '|' ||
          V_Usdrate      		            || '|' ||
					V_Eurrate	                    || '|' ||
					V_Sgdrate                     || '|' ||
					V_Jpyrate                     || '|' ||
					v_thbRate                     || '|' ||
					v_myrRate);
  
			dbms_output.put_line(out_rec);
    
  END FIN_DAILY_FE_BALANCE;

END FIN_DAILY_FE_BALANCE;
/
