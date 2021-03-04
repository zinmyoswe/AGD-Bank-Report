CREATE OR REPLACE PACKAGE                             FIN_FCY_POS_ALL_MC_BR AS 

  subtype limited_string is varchar2(2000);
  PROCEDURE FIN_FCY_POS_ALL_MC_BR(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string );

END FIN_FCY_POS_ALL_MC_BR;
/


CREATE OR REPLACE PACKAGE BODY                                                                FIN_FCY_POS_ALL_MC_BR AS

--------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	Vi_Startdate		Varchar2(10);		    	    -- Input to procedure
 -- vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  limitsize  INTEGER := 200;
  v_rate decimal;

  CURSOR ExtractData
  IS
  SELECT DISTINCT gstt.crncy_code 
  FROM tbaadm.gstt gstt
  where gstt.crncy_code = 'USD';

  CURSOR ExtractDataCashInHand (	ci_startDate VARCHAR2)--, ci_endDate VARCHAR2)
  IS
  Select
    /*case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
    Then Sum(Gstt.Tot_Cr_Bal) - Sum(Gstt.Tot_Dr_Bal) 
    else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL)  end as total,*/
   sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL)    as total,
    gstt.crncy_code,
    gstt.bal_date
    from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE FPT
    where gstt.BAL_DATE <= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.end_BAL_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
    and gstt.crncy_code IN ('USD','EUR','SGD','JPY','MYR','THB')
    and FPT.VARIABLE_NAME in ('CASH_MMK_PAA_10101', 
    'CASH_FCY_PAS_10103', 'CASH_FCY_PDT_10104')
    AND FPT.BANK_ID = '01'
    AND FPT.MODULE_NAME = 'REPORT'
    AND FPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    GROUP BY gstt.crncy_code,gstt.bal_date
    order by gstt.bal_date;
    
  CURSOR ExtractDataAccWithCBM (	ci_startDate VARCHAR2)--, ci_endDate VARCHAR2)
  IS
  Select
      sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL)  as total,
    gstt.crncy_code,
    gstt.bal_date
    from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE FPT
    where gstt.BAL_DATE <= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.end_BAL_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
    and gstt.crncy_code IN ('USD','EUR','SGD','JPY','MYR','THB')
    and FPT.VARIABLE_NAME in ('CBM_CCY_10107')
    AND FPT.BANK_ID = '01'
    AND FPT.MODULE_NAME = 'REPORT'
    AND FPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    GROUP BY gstt.crncy_code,gstt.bal_date
    order by gstt.bal_date;
    
  CURSOR ExtractDataAccWithMFTB (	ci_startDate VARCHAR2)
  IS
  select
      sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL)  as total,
    gstt.crncy_code,
    gstt.bal_date
    from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE FPT
    where gstt.BAL_DATE <= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.end_BAL_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
    and gstt.crncy_code IN ('USD','EUR','SGD','JPY','MYR','THB')
    and FPT.VARIABLE_NAME in ('MFTB')
    AND FPT.BANK_ID = '01'
    AND FPT.MODULE_NAME = 'REPORT'
    AND FPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    GROUP BY gstt.crncy_code, gstt.bal_date
    order by gstt.bal_date;
    
  CURSOR ExtractDataAccWithMICB (	ci_startDate VARCHAR2)--, ci_endDate VARCHAR2)
  IS
  select
      sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL)  as total,
    gstt.crncy_code,
    gstt.bal_date
    from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE FPT
    where gstt.BAL_DATE <= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.end_BAL_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gstt.GL_SUB_HEAD_CODE = FPT.VARIABLE_VALUE
    and gstt.crncy_code IN ('USD','EUR','SGD','JPY','MYR','THB')
    and FPT.VARIABLE_NAME in ('MICB_1', 'MICB_2')
    AND FPT.BANK_ID = '01'
    AND FPT.MODULE_NAME = 'REPORT'
    AND FPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    GROUP BY gstt.crncy_code, gstt.bal_date
    order by gstt.bal_date;

  PROCEDURE FIN_FCY_POS_ALL_MC_BR(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ) AS
      
      v_Currency tbaadm.gstt.crncy_code%type;
      v_usdAmtCashInHand number := 0;
      v_eurAmtCashInHand number := 0;
      v_sgdAmtCashInHand number := 0;
      v_jpyAmtCashInHand number := 0;
      v_myrAmtCashInHand number := 0;
      v_thbAmtCashInHand number := 0;
      
      v_usdMMKAmtCashInHand number := 0;
      v_eurMMKAmtCashInHand number := 0;
      v_sgdMMKAmtCashInHand number := 0;
      v_jpyMMKAmtCashInHand number := 0;
      v_myrMMKAmtCashInHand number := 0;
      v_thbMMKAmtCashInHand number := 0;
      
      v_usdAmtAccWithCBM number := 0;
      v_eurAmtAccWithCBM number := 0;
      v_sgdAmtAccWithCBM number := 0;
      v_jpyAmtAccWithCBM number := 0;
      v_myrAmtAccWithCBM number := 0;
      v_thbAmtAccWithCBM number := 0;
      
      v_usdMMKAmtAccWithCBM number := 0;
      v_eurMMKAmtAccWithCBM number := 0;
      v_sgdMMKAmtAccWithCBM number := 0;
      v_jpyMMKAmtAccWithCBM number := 0;
      v_myrMMKAmtAccWithCBM number := 0;
      v_thbMMKAmtAccWithCBM number := 0;
      
      v_usdAmtAccWithMFTB number := 0;
      v_eurAmtAccWithMFTB number := 0;
      v_sgdAmtAccWithMFTB number := 0;
      v_jpyAmtAccWithMFTB number := 0;
      v_myrAmtAccWithMFTB number := 0;
      v_thbAmtAccWithMFTB number := 0;
      
      v_usdMMKAmtAccWithMFTB number := 0;
      v_eurMMKAmtAccWithMFTB number := 0;
      v_sgdMMKAmtAccWithMFTB number := 0;
      v_jpyMMKAmtAccWithMFTB number := 0;
      v_myrMMKAmtAccWithMFTB number := 0;
      v_thbMMKAmtAccWithMFTB number := 0;
      
      v_usdAmtAccWithMICB number := 0;
      v_eurAmtAccWithMICB number := 0;
      v_sgdAmtAccWithMICB number := 0;
      v_jpyAmtAccWithMICB number := 0;
      v_myrAmtAccWithMICB number := 0;
      v_thbAmtAccWithMICB number := 0;
      
      v_usdMMKAmtAccWithMICB number := 0;
      v_eurMMKAmtAccWithMICB number := 0;
      v_sgdMMKAmtAccWithMICB number := 0;
      v_jpyMMKAmtAccWithMICB number := 0;
      v_myrMMKAmtAccWithMICB number := 0;
      v_thbMMKAmtAccWithMICB number := 0;
      
      TYPE cashInHand IS TABLE OF ExtractDataCashInHand%ROWTYPE INDEX BY BINARY_INTEGER;
      l_cashInHand cashInHand;
      
      TYPE accWithCBM IS TABLE OF ExtractDataAccWithCBM%ROWTYPE INDEX BY BINARY_INTEGER;
      l_accWithCBM accWithCBM;
      
      TYPE accWithMFTB IS TABLE OF ExtractDataAccWithMFTB%ROWTYPE INDEX BY BINARY_INTEGER;
      l_accWithMFTB accWithMFTB;
      
      TYPE accWithMICB IS TABLE OF ExtractDataAccWithMICB%ROWTYPE INDEX BY BINARY_INTEGER;
      l_accWithMICB accWithMICB;
      
  BEGIN
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    Vi_Startdate  :=  Outarr(0);		
    --vi_endDate    :=  outArr(1);	
   
   -----------------------------------------------------------------------------
  if( vi_startDate is null /*or vi_endDate is null*/  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
                   0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 );
				  
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
   
   
   
   -------------------------------------------------------------------------------
   
    
    IF NOT ExtractDataCashInHand%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataCashInHand (vi_startDate );
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataCashInHand%ISOPEN THEN
		--{
			FETCH	ExtractDataCashInHand	BULK COLLECT INTO l_CashInHand LIMIT limitsize;
      FOR x IN 1 .. l_CashInHand.COUNT
      LOOP
        --dbms_output.put_line(l_CashInHand(x).bal_date);
        IF l_CashInHand(x).crncy_code = 'USD' THEN
        v_usdAmtCashInHand := v_usdAmtCashInHand + l_CashInHand(x).total;
        BEGIN        
            SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_usdMMKAmtCashInHand := v_usdMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_usdMMKAmtCashInHand := v_usdMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        ELSIF l_CashInHand(x).crncy_code = 'EUR' THEN
        v_eurAmtCashInHand := v_eurAmtCashInHand + l_CashInHand(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_eurMMKAmtCashInHand := v_eurMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_eurMMKAmtCashInHand := v_eurMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        ELSIF l_CashInHand(x).crncy_code = 'SGD' THEN
        v_sgdAmtCashInHand := v_sgdAmtCashInHand + l_CashInHand(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_sgdMMKAmtCashInHand := v_sgdMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_sgdMMKAmtCashInHand := v_sgdMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        ELSIF l_CashInHand(x).crncy_code = 'JPY' THEN
        v_jpyAmtCashInHand := v_jpyAmtCashInHand + l_CashInHand(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_jpyMMKAmtCashInHand := v_jpyMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_jpyMMKAmtCashInHand := v_jpyMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        ELSIF l_CashInHand(x).crncy_code = 'THB' THEN
        v_thbAmtCashInHand := v_thbAmtCashInHand + l_CashInHand(x).total;
         BEGIN
           SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_thbMMKAmtCashInHand := v_thbMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_thbMMKAmtCashInHand := v_thbMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        ELSE 
        v_myrAmtCashInHand := v_myrAmtCashInHand + l_CashInHand(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS INTO v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(l_CashInHand(x).crncy_code) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_myrMMKAmtCashInHand := v_myrMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_myrMMKAmtCashInHand := v_myrMMKAmtCashInHand + (l_CashInHand(x).total * v_rate);
        END;
        END IF;
      END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataCashInHand%NOTFOUND THEN
			--{
				CLOSE ExtractDataCashInHand;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
--------------------------------------------------------------------------------
 IF NOT ExtractDataAccWithCBM%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAccWithCBM (vi_startDate);
			--}
			END;

		--}
		END IF;
 IF ExtractDataAccWithCBM%ISOPEN THEN
		--{
			FETCH	ExtractDataAccWithCBM	BULK COLLECT INTO l_AccWithCBM LIMIT limitsize;
      FOR x IN 1 .. l_AccWithCBM.COUNT
      LOOP
        IF l_AccWithCBM(x).crncy_code = 'USD' THEN
        v_usdAmtAccWithCBM := v_usdAmtAccWithCBM + l_AccWithCBM(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_usdMMKAmtAccWithCBM := v_usdMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_usdMMKAmtAccWithCBM := v_usdMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        ELSIF l_AccWithCBM(x).crncy_code = 'EUR' THEN
        v_eurAmtAccWithCBM := v_eurAmtAccWithCBM + l_AccWithCBM(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_eurMMKAmtAccWithCBM := v_eurMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_eurMMKAmtAccWithCBM := v_eurMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        ELSIF l_AccWithCBM(x).crncy_code = 'SGD' THEN
        v_sgdAmtAccWithCBM := v_sgdAmtAccWithCBM + l_AccWithCBM(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_sgdMMKAmtAccWithCBM := v_sgdMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_sgdMMKAmtAccWithCBM := v_sgdMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        ELSIF l_AccWithCBM(x).crncy_code = 'JPY' THEN
        v_jpyAmtAccWithCBM := v_jpyAmtAccWithCBM + l_AccWithCBM(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_jpyMMKAmtAccWithCBM := v_jpyMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_jpyMMKAmtAccWithCBM := v_jpyMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        ELSIF l_AccWithCBM(x).crncy_code = 'THB' THEN
        v_thbAmtAccWithCBM := v_thbAmtAccWithCBM + l_AccWithCBM(x).total;
         BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_thbMMKAmtAccWithCBM := v_thbMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_thbMMKAmtAccWithCBM := v_thbMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        ELSE 
        v_myrAmtAccWithCBM := v_myrAmtAccWithCBM + l_AccWithCBM(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithCBM(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_myrMMKAmtAccWithCBM := v_myrMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_myrMMKAmtAccWithCBM := v_myrMMKAmtAccWithCBM + (l_AccWithCBM(x).total * v_rate);
        END;
        END IF;
      END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAccWithCBM%NOTFOUND THEN
			--{
				CLOSE ExtractDataAccWithCBM;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
--------------------------------------------------------------------------------
IF NOT ExtractDataAccWithMFTB%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAccWithMFTB(vi_startDate);
			--}
			END;

		--}
		END IF;
IF ExtractDataAccWithMFTB%ISOPEN THEN
		--{
			FETCH	ExtractDataAccWithMFTB	BULK COLLECT INTO l_AccWithMFTB LIMIT limitsize;
      FOR x IN 1 .. l_AccWithMFTB.COUNT
      LOOP
        IF l_AccWithMFTB(x).crncy_code = 'USD' THEN
        v_usdAmtAccWithMFTB := v_usdAmtAccWithMFTB + l_AccWithMFTB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_usdMMKAmtAccWithMFTB := v_usdMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_usdMMKAmtAccWithMFTB := v_usdMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        ELSIF l_AccWithMFTB(x).crncy_code = 'EUR' THEN
        v_eurAmtAccWithMFTB := v_eurAmtAccWithMFTB + l_AccWithMFTB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_eurMMKAmtAccWithMFTB := v_eurMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_eurMMKAmtAccWithMFTB := v_eurMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        ELSIF l_AccWithMFTB(x).crncy_code = 'SGD' THEN
        v_sgdAmtAccWithMFTB := v_sgdAmtAccWithMFTB + l_AccWithMFTB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_sgdMMKAmtAccWithMFTB := v_sgdMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_sgdMMKAmtAccWithMFTB := v_sgdMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        ELSIF l_AccWithMFTB(x).crncy_code = 'JPY' THEN
        v_jpyAmtAccWithMFTB := v_jpyAmtAccWithMFTB + l_AccWithMFTB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_jpyMMKAmtAccWithMFTB := v_jpyMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_jpyMMKAmtAccWithMFTB := v_jpyMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        ELSIF l_AccWithMFTB(x).crncy_code = 'THB' THEN
        v_thbAmtAccWithMFTB := v_thbAmtAccWithMFTB + l_AccWithMFTB(x).total;
         BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_thbMMKAmtAccWithMFTB := v_thbMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_thbMMKAmtAccWithMFTB := v_thbMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        ELSE 
        v_myrAmtAccWithMFTB := v_myrAmtAccWithMFTB + l_AccWithMFTB(x).total;
        BEGIN
         SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMFTB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_myrMMKAmtAccWithMFTB := v_myrMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_myrMMKAmtAccWithMFTB := v_myrMMKAmtAccWithMFTB + (l_AccWithMFTB(x).total * v_rate);
        END;
        END IF;
      END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAccWithMFTB%NOTFOUND THEN
			--{
				CLOSE ExtractDataAccWithMFTB;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
--------------------------------------------------------------------------------
IF NOT ExtractDataAccWithMICB%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAccWithMICB (vi_startDate);
			--}
			END;

		--}
		END IF;
IF ExtractDataAccWithMICB%ISOPEN THEN
		--{
			FETCH	ExtractDataAccWithMICB	BULK COLLECT INTO l_AccWithMICB LIMIT limitsize;
      FOR x IN 1 .. l_AccWithMICB.COUNT
      LOOP
        IF l_AccWithMICB(x).crncy_code = 'USD' THEN
        v_usdAmtAccWithMICB := v_usdAmtAccWithMICB + l_AccWithMICB(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_usdMMKAmtAccWithMICB := v_usdMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_usdMMKAmtAccWithMICB := v_usdMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        ELSIF l_AccWithMICB(x).crncy_code = 'EUR' THEN
        v_eurAmtAccWithMICB := v_eurAmtAccWithMICB + l_AccWithMICB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_eurMMKAmtAccWithMICB := v_eurMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_eurMMKAmtAccWithMICB := v_eurMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        ELSIF l_AccWithMICB(x).crncy_code = 'SGD' THEN
        v_sgdAmtAccWithMICB := v_sgdAmtAccWithMICB + l_AccWithMICB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_sgdMMKAmtAccWithMICB := v_sgdMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_sgdMMKAmtAccWithMICB := v_sgdMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        ELSIF l_AccWithMICB(x).crncy_code = 'JPY' THEN
        v_jpyAmtAccWithMICB := v_jpyAmtAccWithMICB + l_AccWithMICB(x).total;
        BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_jpyMMKAmtAccWithMICB := v_jpyMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_jpyMMKAmtAccWithMICB := v_jpyMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        ELSIF l_AccWithMICB(x).crncy_code = 'THB' THEN
        v_thbAmtAccWithMICB := v_thbAmtAccWithMICB + l_AccWithMICB(x).total;
         BEGIN
          SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_thbMMKAmtAccWithMICB := v_thbMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_thbMMKAmtAccWithMICB := v_thbMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        ELSE 
        v_myrAmtAccWithMICB := v_myrAmtAccWithMICB + l_AccWithMICB(x).total;
        BEGIN
           SELECT r.VAR_CRNCY_UNITS into v_rate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim( l_AccWithMICB(x).crncy_code ) and r.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
          v_myrMMKAmtAccWithMICB := v_myrMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
          EXCEPTION WHEN NO_DATA_FOUND THEN
          v_rate := 1;
          v_myrMMKAmtAccWithMICB := v_myrMMKAmtAccWithMICB + (l_AccWithMICB(x).total * v_rate);
        END;
        END IF;
      END LOOP;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAccWithMICB%NOTFOUND THEN
			--{
				CLOSE ExtractDataAccWithMICB;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
--------------------------------------------------------------------------------   
    IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData;
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO	 v_Currency;
          
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
    
    v_usdMMKAmtCashInHand := v_usdMMKAmtCashInHand / 1000000;
    v_eurMMKAmtCashInHand := v_eurMMKAmtCashInHand / 1000000;
    v_sgdMMKAmtCashInHand := v_sgdMMKAmtCashInHand / 1000000;
    v_jpyMMKAmtCashInHand := v_jpyMMKAmtCashInHand / 1000000;
    v_myrMMKAmtCashInHand := v_myrMMKAmtCashInHand / 1000000;
    v_thbMMKAmtCashInHand := v_thbMMKAmtCashInHand / 1000000;
    v_usdMMKAmtAccWithCBM := v_usdMMKAmtAccWithCBM / 1000000;
    v_eurMMKAmtAccWithCBM := v_eurMMKAmtAccWithCBM / 1000000;
    v_sgdMMKAmtAccWithCBM := v_sgdMMKAmtAccWithCBM / 1000000;
    v_jpyMMKAmtAccWithCBM := v_jpyMMKAmtAccWithCBM / 1000000;
    v_myrMMKAmtAccWithCBM := v_myrMMKAmtAccWithCBM / 1000000;
    v_thbMMKAmtAccWithCBM := v_thbMMKAmtAccWithCBM / 1000000;
    v_usdMMKAmtAccWithMFTB := v_usdMMKAmtAccWithMFTB / 1000000;
    v_eurMMKAmtAccWithMFTB := v_eurMMKAmtAccWithMFTB / 1000000;
    v_sgdMMKAmtAccWithMFTB := v_sgdMMKAmtAccWithMFTB / 1000000;
    v_jpyMMKAmtAccWithMFTB := v_jpyMMKAmtAccWithMFTB / 1000000;
    v_myrMMKAmtAccWithMFTB := v_myrMMKAmtAccWithMFTB / 1000000;
    v_thbMMKAmtAccWithMFTB := v_thbMMKAmtAccWithMFTB / 1000000;
    v_usdMMKAmtAccWithMICB := v_usdMMKAmtAccWithMICB / 1000000;
    v_eurMMKAmtAccWithMICB := v_eurMMKAmtAccWithMICB / 1000000;
    v_sgdMMKAmtAccWithMICB := v_sgdMMKAmtAccWithMICB / 1000000;
    v_jpyMMKAmtAccWithMICB := v_jpyMMKAmtAccWithMICB / 1000000;
    v_myrMMKAmtAccWithMICB := v_myrMMKAmtAccWithMICB / 1000000;
    v_thbMMKAmtAccWithMICB := v_thbMMKAmtAccWithMICB / 1000000;
    
    Out_Rec:=	(Abs(V_Usdamtcashinhand) || '|' ||
              Abs(V_Euramtcashinhand) || '|' ||
              Abs(V_Sgdamtcashinhand) || '|' ||
              Abs(V_Jpyamtcashinhand) || '|' ||
              Abs(V_Myramtcashinhand) || '|' ||
             Abs(V_Thbamtcashinhand) || '|' ||
              Abs(V_Usdamtaccwithcbm) || '|' ||
              Abs(V_Euramtaccwithcbm) || '|' ||
              Abs(V_Sgdamtaccwithcbm) || '|' ||
              Abs(V_Jpyamtaccwithcbm) || '|' ||
              Abs(V_Myramtaccwithcbm) || '|' ||
              Abs(V_Thbamtaccwithcbm) || '|' ||
              Abs(V_Usdamtaccwithmftb) || '|' ||
              Abs(V_Euramtaccwithmftb) || '|' ||
              Abs(V_Sgdamtaccwithmftb) || '|' ||
              Abs(V_Jpyamtaccwithmftb) || '|' ||
              Abs(V_Myramtaccwithmftb) || '|' ||
              Abs(V_Thbamtaccwithmftb) || '|' ||
              Abs(V_Usdamtaccwithmicb) || '|' ||
              Abs(V_Euramtaccwithmicb) || '|' ||
             Abs( V_Sgdamtaccwithmicb) || '|' ||
              Abs(V_Jpyamtaccwithmicb) || '|' ||
             Abs( V_Myramtaccwithmicb) || '|' ||
              Abs(V_Thbamtaccwithmicb) || '|' ||
              Abs(V_Usdmmkamtcashinhand) || '|' ||
             Abs( V_Eurmmkamtcashinhand) || '|' ||
             Abs( V_Sgdmmkamtcashinhand) || '|' ||
             Abs( V_Jpymmkamtcashinhand )|| '|' ||
             Abs( V_Myrmmkamtcashinhand) || '|' ||
             Abs( V_Thbmmkamtcashinhand) || '|' ||
             Abs( V_Usdmmkamtaccwithcbm) || '|' ||
             Abs( V_Eurmmkamtaccwithcbm) || '|' ||
             Abs( V_Sgdmmkamtaccwithcbm) || '|' ||
             Abs( V_Jpymmkamtaccwithcbm) || '|' ||
             Abs( V_Myrmmkamtaccwithcbm) || '|' ||
             Abs( V_Thbmmkamtaccwithcbm) || '|' ||
             Abs( V_Usdmmkamtaccwithmftb) || '|' ||
             Abs( V_Eurmmkamtaccwithmftb) || '|' ||
             Abs( V_Sgdmmkamtaccwithmftb) || '|' ||
             Abs( V_Jpymmkamtaccwithmftb) || '|' ||
             Abs( V_Myrmmkamtaccwithmftb) || '|' ||
             Abs( V_Thbmmkamtaccwithmftb) || '|' ||
             Abs( V_Usdmmkamtaccwithmicb) || '|' ||
             Abs( V_Eurmmkamtaccwithmicb) || '|' ||
             Abs( V_Sgdmmkamtaccwithmicb) || '|' ||
              Abs(V_Jpymmkamtaccwithmicb) || '|' ||
             Abs( V_Myrmmkamtaccwithmicb) || '|' ||
             abs( v_thbMMKAmtAccWithMICB) );
    dbms_output.put_line(out_rec);
    
  END FIN_FCY_POS_ALL_MC_BR;

END FIN_FCY_POS_ALL_MC_BR;
/
