CREATE OR REPLACE PACKAGE        FIN_PCAPITAL_FASSETS_STATEMENT AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_PCAPITAL_FASSETS_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_PCAPITAL_FASSETS_STATEMENT;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_PCAPITAL_FASSETS_STATEMENT AS
--------------------------------------------------------------------------------
--update User- Saung Hnin OO------------------------------------
--Update Date - 20-4-2017-----------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  --vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_currencyType	   	Varchar2(7);              -- Input to procedure
    
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractDataMMK
--------------------------------------------------------------------------------
CURSOR ExtractDataMMK (
			ci_startDate VARCHAR2, ci_endDate VARCHAR2
      )
  IS
  
   SELECT BAL_DATE, SOL_ID, CRNCY_CODE, NVL((Paid_Up_Capital+4138000000)/1000000,0) Paid_Up_Capital
  , NVL(Land_N_Building,0) Land_N_Building
  , NVL(Off_Machine_N_Ele_Equipment,0) Off_Machine_N_Ele_Equipment
  , NVL(Furn_Fixture_N_Fitting,0) Furn_Fixture_N_Fitting , NVL(Motor_Vehicles,0)Motor_Vehicles
  FROM
  (SELECT 0 AS IDNo, BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building, Off_Machine_N_Ele_Equipment
  , Furn_Fixture_N_Fitting, Motor_Vehicles 
  FROM
  (
     SELECT BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building
      , Off_Machine_N_Ele_Equipment, Furn_Fixture_N_Fitting, Motor_Vehicles
      FROM
      (SELECT CASE WHEN GSTT.GL_SUB_HEAD_CODE = '70001' THEN '1'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10301','10302') THEN '2'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10303','10305','10308','10309') THEN '3'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10304') THEN '4'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10306') THEN '5' 
      ELSE '6' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      --AND GST.SOL_ID = ci_branchCode
      AND GSTT.CRNCY_CODE = UPPER('mmk')
      AND (GSTT.GL_SUB_HEAD_CODE LIKE '7000%' OR GSTT.GL_SUB_HEAD_CODE LIKE '1030%')
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS Paid_Up_Capital, '2' AS Land_N_Building, '3' AS Off_Machine_N_Ele_Equipment
      , '4' AS Furn_Fixture_N_Fitting, '5' AS Motor_Vehicles, '6' AS Other)) WHERE BAL_DATE IS NOT NULL 
  ) T
  WHERE TRUNC(T.BAL_DATE) = (SELECT NVL(MAX(BAL_DATE), TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')- 1) 
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE 
  WHERE BAL_DATE < TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy'))
  --AND T.SOL_ID = ci_branchCode
  --AND T.CRNCY_CODE = UPPER('mmk')
  UNION ALL
  SELECT DISTINCT 1 AS IDNo,(SELECT NVL(MAX(BAL_DATE), TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy') - 1) 
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE
  WHERE BAL_DATE < TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')) AS BAL_DATE,'-','-',
  0,0,0,0,0
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE
  )TMP WHERE ROWNUM = 1
  UNION ALL
  SELECT BAL_DATE, SOL_ID, CRNCY_CODE, NVL(Paid_Up_Capital/1000000,0) Paid_Up_Capital
  , NVL(Land_N_Building,0) Land_N_Building
  , NVL(Off_Machine_N_Ele_Equipment,0) Off_Machine_N_Ele_Equipment
  , NVL(Furn_Fixture_N_Fitting,0) Furn_Fixture_N_Fitting , NVL(Motor_Vehicles,0)Motor_Vehicles 
  FROM
  (
     SELECT BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building
      , Off_Machine_N_Ele_Equipment, Furn_Fixture_N_Fitting, Motor_Vehicles
      FROM
      (SELECT CASE WHEN  GSTT.GL_SUB_HEAD_CODE = '70001'  THEN '1'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10301','10302') THEN '2'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10303','10305','10308','10309') THEN '3'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10304') THEN '4'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10306') THEN '5' 
      ELSE '6' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      --AND GST.SOL_ID = ci_branchCode
      AND GSTT.CRNCY_CODE = UPPER('mmk')
      AND (GSTT.GL_SUB_HEAD_CODE LIKE '7000%' OR GSTT.GL_SUB_HEAD_CODE LIKE '1030%')
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS Paid_Up_Capital, '2' AS Land_N_Building, '3' AS Off_Machine_N_Ele_Equipment
      , '4' AS Furn_Fixture_N_Fitting, '5' AS Motor_Vehicles, '6' AS Other)) WHERE BAL_DATE IS NOT NULL 
  ) T
  WHERE TRUNC(T.BAL_DATE) 
  BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')
  AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy');
  --AND T.SOL_ID = ci_branchCode
  --AND T.CRNCY_CODE = UPPER('mmk');
---------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractDataALL
--------------------------------------------------------------------------------
CURSOR ExtractDataAll (
			ci_startDate VARCHAR2
      )
  IS
  
  SELECT sum(NVL((Paid_Up_Capital+4138000000)/1000000,0)) Paid_Up_Capital
  , sum(NVL(Land_N_Building,0) ) Land_N_Building
  , sum(NVL(Off_Machine_N_Ele_Equipment,0)) Off_Machine_N_Ele_Equipment
  , sum(NVL(Furn_Fixture_N_Fitting,0)) Furn_Fixture_N_Fitting , sum(NVL(Motor_Vehicles,0)) Motor_Vehicles
  FROM
  (SELECT BAL_DATE, SOL_ID,
   CASE WHEN CRNCY_CODE = 'MMK' THEN Paid_Up_Capital
  ELSE Paid_Up_Capital * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS Paid_Up_Capital,
  CASE WHEN CRNCY_CODE = 'MMK' THEN Land_N_Building
  ELSE Land_N_Building * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS Land_N_Building,
   CASE WHEN CRNCY_CODE = 'MMK' THEN Off_Machine_N_Ele_Equipment
  ELSE Off_Machine_N_Ele_Equipment * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Off_Machine_N_Ele_Equipment,
  CASE WHEN CRNCY_CODE = 'MMK' THEN Furn_Fixture_N_Fitting
  ELSE Furn_Fixture_N_Fitting * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Furn_Fixture_N_Fitting,
                              CASE WHEN CRNCY_CODE = 'MMK' THEN Motor_Vehicles
  ELSE Motor_Vehicles * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Motor_Vehicles
  
  FROM
  (
  select q.BAL_DATE, q.SOL_ID, q.CRNCY_CODE, Paid_Up_Capital
  , q.Land_N_Building
  ,q.Off_Machine_N_Ele_Equipment
  , q.Furn_Fixture_N_Fitting , q.Motor_Vehicles
from (
      SELECT BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building
      , Off_Machine_N_Ele_Equipment, Furn_Fixture_N_Fitting, Motor_Vehicles,'A' as temp
      FROM
      (SELECT CASE WHEN  GSTT.GL_SUB_HEAD_CODE = '70001'  THEN '1'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10301','10302') THEN '2'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10303','10305','10308','10309') THEN '3'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10304') THEN '4'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10306') THEN '5' 
      ELSE '6' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      and TRUNC(gstt.BAL_DATE)  <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')
     and  TRUNC(gstt.END_BAL_DATE)  >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')
      --AND GST.SOL_ID = ci_branchCode
     -- AND GSTT.CRNCY_CODE = UPPER('mmk')
      AND (GSTT.GL_SUB_HEAD_CODE LIKE '7000%' OR GSTT.GL_SUB_HEAD_CODE LIKE '1030%')
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS Paid_Up_Capital, '2' AS Land_N_Building, '3' AS Off_Machine_N_Ele_Equipment
      , '4' AS Furn_Fixture_N_Fitting, '5' AS Motor_Vehicles, '6' AS Other)) WHERE BAL_DATE IS NOT NULL 
     )q
  ));-- group by BAL_DATE;
------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- CURSOR ExtractDataALLFCY
--------------------------------------------------------------------------------
CURSOR ExtractDataAllFCY (
			ci_startDate VARCHAR2, ci_endDate VARCHAR2
      )
  IS
  
  SELECT BAL_DATE, SOL_ID, CRNCY_CODE, NVL((Paid_Up_Capital+4138000000)/1000000,0) Paid_Up_Capital
  , NVL(Land_N_Building,0) Land_N_Building
  , NVL(Off_Machine_N_Ele_Equipment,0) Off_Machine_N_Ele_Equipment
  , NVL(Furn_Fixture_N_Fitting,0) Furn_Fixture_N_Fitting , NVL(Motor_Vehicles,0)Motor_Vehicles
  FROM
  (SELECT 0 AS IDNo, BAL_DATE, SOL_ID, CRNCY_CODE, 
   CASE WHEN CRNCY_CODE = 'MMK' THEN Paid_Up_Capital
  ELSE Paid_Up_Capital * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS Paid_Up_Capital,
  CASE WHEN CRNCY_CODE = 'MMK' THEN Land_N_Building
  ELSE Land_N_Building * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS Land_N_Building,
   CASE WHEN CRNCY_CODE = 'MMK' THEN Off_Machine_N_Ele_Equipment
  ELSE Off_Machine_N_Ele_Equipment * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Off_Machine_N_Ele_Equipment,
  CASE WHEN CRNCY_CODE = 'MMK' THEN Furn_Fixture_N_Fitting
  ELSE Furn_Fixture_N_Fitting * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Furn_Fixture_N_Fitting,
                              CASE WHEN CRNCY_CODE = 'MMK' THEN Motor_Vehicles
  ELSE Motor_Vehicles * NVL((SELECT  VAR_CRNCY_UNITS
                              FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(CRNCY_CODE) AND TRIM(VAR_CRNCY_CODE) = 'MMK' 
                              AND RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                              WHERE module_name = 'FOREIGN_CURRENCY' 
                              AND variable_name = 'RATE_CODE')
                              --order by rtlist_date desc) WHERE rownum = 1
                              ),1) END AS     Motor_Vehicles
  
  FROM
  (
     SELECT BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building
      , Off_Machine_N_Ele_Equipment, Furn_Fixture_N_Fitting, Motor_Vehicles
      FROM
      (SELECT CASE WHEN GSTT.GL_SUB_HEAD_CODE = '70001' THEN '1'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10301','10302') THEN '2'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10303','10305','10308','10309') THEN '3'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10304') THEN '4'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10306') THEN '5' 
      ELSE '6' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      --AND GST.SOL_ID = ci_branchCode
     -- AND GSTT.CRNCY_CODE = UPPER('mmk')
      AND (GSTT.GL_SUB_HEAD_CODE LIKE '7000%' OR GSTT.GL_SUB_HEAD_CODE LIKE '1030%')
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS Paid_Up_Capital, '2' AS Land_N_Building, '3' AS Off_Machine_N_Ele_Equipment
      , '4' AS Furn_Fixture_N_Fitting, '5' AS Motor_Vehicles, '6' AS Other)) WHERE BAL_DATE IS NOT NULL 
  ) T
  WHERE TRUNC(T.BAL_DATE) = (SELECT NVL(MAX(BAL_DATE), TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')- 1) 
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE 
  WHERE BAL_DATE < TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy'))
  --AND T.SOL_ID = ci_branchCode
  AND T.CRNCY_CODE != UPPER('mmk')
  UNION ALL
  SELECT DISTINCT 1 AS IDNo,(SELECT NVL(MAX(BAL_DATE), TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy') - 1) 
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE
  WHERE BAL_DATE < TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')) AS BAL_DATE,'-','-',
  0,0,0,0,0
  FROM TBAADM.GL_SUB_HEAD_TRAN_TABLE
  )TMP WHERE ROWNUM = 1
  UNION ALL
  SELECT BAL_DATE, SOL_ID, CRNCY_CODE, NVL(Paid_Up_Capital/1000000,0) Paid_Up_Capital
  , NVL(Land_N_Building,0) Land_N_Building
  , NVL(Off_Machine_N_Ele_Equipment,0) Off_Machine_N_Ele_Equipment
  , NVL(Furn_Fixture_N_Fitting,0) Furn_Fixture_N_Fitting , NVL(Motor_Vehicles,0)Motor_Vehicles 
  FROM
  (
      SELECT BAL_DATE, SOL_ID, CRNCY_CODE, Paid_Up_Capital, Land_N_Building
      , Off_Machine_N_Ele_Equipment, Furn_Fixture_N_Fitting, Motor_Vehicles
      FROM
      (SELECT CASE WHEN  GSTT.GL_SUB_HEAD_CODE = '70001' THEN '1'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10301','10302') THEN '2'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10303','10305','10308','10309') THEN '3'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10304') THEN '4'
      WHEN GSTT.GL_SUB_HEAD_CODE IN('10306') THEN '5' 
      ELSE '6' END AS GL_CODE,GSTT.BAL_DATE,GSTT.SOL_ID,GSTT.CRNCY_CODE
      ,NVL((GSTT.TOT_CR_BAL - GSTT.TOT_DR_BAL),0) AS BAL 
      FROM 
      TBAADM.GL_SUB_HEAD_TRAN_TABLE GSTT,custom.coa_mp coa 
      WHERE 
      gstt.gl_sub_head_code = coa.gl_sub_head_code
     and gstt.crncy_code = coa.cur
     and GSTT.DEL_FLG = 'N'
      AND GSTT.BANK_ID = '01'
      --AND GST.SOL_ID = ci_branchCode
     -- AND GSTT.CRNCY_CODE = UPPER('mmk')
      AND (GSTT.GL_SUB_HEAD_CODE LIKE '7000%' OR GSTT.GL_SUB_HEAD_CODE LIKE '1030%')
      ORDER BY GL_CODE)
      PIVOT (SUM(NVL(BAL,0)) FOR (GL_CODE) 
      IN ('1' AS Paid_Up_Capital, '2' AS Land_N_Building, '3' AS Off_Machine_N_Ele_Equipment
      , '4' AS Furn_Fixture_N_Fitting, '5' AS Motor_Vehicles, '6' AS Other)) WHERE BAL_DATE IS NOT NULL 
  ) T
  WHERE TRUNC(T.BAL_DATE) 
  BETWEEN TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')
  AND TO_DATE(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy')
  --AND T.SOL_ID = ci_branchCode
  AND T.CRNCY_CODE != UPPER('mmk');
------------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE FIN_PCAPITAL_FASSETS_STATEMENT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
     v_BalDate TBAADM.GL_SUB_HEAD_TRAN_TABLE.BAL_DATE%type;
     v_SolID TBAADM.GL_SUB_HEAD_TRAN_TABLE.SOL_ID%type;
     v_Currency TBAADM.GL_SUB_HEAD_TRAN_TABLE.CRNCY_CODE%type;
     v_PCBal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_CR_BAL%type;
     v_LBBal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_CR_BAL%type;
     v_OMEEBal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_CR_BAL%type;
     v_FFFBal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_CR_BAL%type;
     v_MVBal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_CR_BAL%type;
     v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
     v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
     v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
     v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  BEGIN
--------------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
--------------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_startDate :=outArr(0);		
   --vi_branchCode :=outArr(3);
   
   -----------------------------------------------------------------------------
   
   
if( vi_startDate is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 
		           0 || '|' || 0 || '|' || 0 );
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

   
   
--------------------------------------------------------------------------------
  
      IF NOT ExtractDataAll%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAll (vi_startDate);
			--}
			END;
		--}
		END IF;   
    IF ExtractDataAll%ISOPEN THEN
		--{
			FETCH	ExtractDataAll
			INTO	v_PCBal, v_LBBal, v_OMEEBal
      , v_FFFBal, v_MVBal;
--------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
--------------------------------------------------------------------------------
			IF ExtractDataAll%NOTFOUND THEN
			--{
				CLOSE ExtractDataAll;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    

--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
   
    out_rec:=	(to_char(to_date(v_BalDate,'dd/Mon/yy'), 'dd-MM-yyyy')  || '|' ||
					v_PCBal	      || '|' ||
					v_LBBal      	|| '|' ||
          v_OMEEBal 	  || '|' ||
          v_FFFBal      || '|' ||
          v_MVBal );     /* || '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress || '|' ||
					v_BankPhone   || '|' ||
          v_BankFax );*/
  
			dbms_output.put_line(out_rec);
  END FIN_PCAPITAL_FASSETS_STATEMENT;

END FIN_PCAPITAL_FASSETS_STATEMENT;
/
