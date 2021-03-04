CREATE OR REPLACE PACKAGE        FIN_PNL_MONTHLY AS 

  subtype limited_string is varchar2(350);
  
  PROCEDURE FIN_PNL_MONTHLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ); 

END FIN_PNL_MONTHLY;
 
/


CREATE OR REPLACE PACKAGE BODY   
FIN_PNL_MONTHLY AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_estimateDate		Varchar2(20);		    	     -- Input to procedure
  TYPE f_sol_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE f_b_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE sab_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  
  CURSOR ExtractData
  IS
  SELECT 
   NO,ACCOUNT_NAME, AMT_10100,AMT_20100,AMT_20300,AMT_30100,
    AMT_30200,AMT_30201,AMT_30300,AMT_30301,AMT_30302,AMT_30400,AMT_30500,
    AMT_30600,AMT_30700,AMT_30800,AMT_30900,AMT_31000,AMT_31001,AMT_31100,
    AMT_31200,AMT_31300,AMT_31400,AMT_31500,AMT_31600,AMT_31700,AMT_31800,
    AMT_31801,AMT_31900,AMT_31901,AMT_32000,AMT_32100,AMT_32200,AMT_32201,
    AMT_32300,AMT_32400,AMT_32401,AMT_32402,AMT_32500,AMT_32501,AMT_32502,
    AMT_32600,AMT_32700,AMT_32800,AMT_32900,AMT_33000,AMT_33400,AMT_33500,
    AMT_33501,AMT_33502,AMT_33800,AMT_33801,AMT_34400,AMT_34500,
    AMT_34600,AMT_34700,AMT_34800,AMT_34900,AMT_35000,AMT_35100,
    AMT_35300,
    AMT_35400,
    AMT_35500,
    AMT_35600,
    AMT_35700,
    AMT_35800,
    AMT_32403,
    AMT_32404,
    AMT_32503,
    AMT_31201,
    AMT_30401,
    AMT_30402,
    AMT_31202,
    AMT_35301,
    AMT_35401,
    AMT_TOTAL
  FROM CUSTOM.CUST_PNL_TEMP_TABLE
  ORDER BY ID;
    
    --------------------------------------------------------------------------------  
  FUNCTION FUNC_ONE(f_solId_list f_sol_list, f_branch_list f_b_list) 
  RETURN sab_list AS
  
    solIdTotal integer;
    --TYPE sab_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    solIdAndBalance_list sab_list;-- := sab_list();
    branchTotal integer;
    temp_1 VARCHAR2(10);
    temp_2 VARCHAR2(2000);
    flash boolean := false;
    solIdAndBalanceTotal integer;
    v_solIdAndAmtFinal VARCHAR2(2000);
    finalResult VARCHAR2(2000);
    
    begin
      solIdTotal := f_solId_list.count;
    FOR y IN 1.. solIdTotal
    LOOP
      --solIdAndBalance_list.extend;
      branchTotal := f_branch_list.count;
       FOR z IN 1.. branchTotal
         LOOP
            temp_1 := regexp_substr(f_branch_list(z), '[^,]+', 1, 1);
            if f_solId_list(y) = temp_1 then
                flash := true;
                temp_2 := f_branch_list(z);
                exit;
            end if;
         END LOOP;
         if flash  then 
          solIdAndBalance_list(y) := temp_2;
          flash := false;
         else
          solIdAndBalance_list(y) := f_solId_list(y)||',0.00';
         end if;
    END LOOP;
    return solIdAndBalance_list;  
  END FUNC_ONE;
-------------------------------------------------------------------------------
  FUNCTION FUNC_TWO(variableName varchar2) 
  RETURN f_b_list AS
  
  counter integer := 0;
  branch_list f_b_list;
  --v_solIdAndAmt VARCHAR2(50);
  v_calculateCurAmt number :=0;
  v_rate number;
  
  v_10100 number :=0;
  v_20100 number :=0;
  v_20300 number :=0;
  v_30100 number :=0;
  v_30200 number :=0;
  v_30201 number :=0;
  v_30300 number :=0;
  v_30301 number :=0;
  v_30302 number :=0;
  v_30400 number :=0;
  v_30500 number :=0;
  v_30600 number :=0;
  v_30700 number :=0;
  v_30800 number :=0;
  v_30900 number :=0;
  v_31000 number :=0;
  v_31001 number :=0;
  v_31100 number :=0;
  v_31200 number :=0;
  v_31300 number :=0;
  v_31400 number :=0;
  v_31500 number :=0;
  v_31600 number :=0;
  v_31700 number :=0;
  v_31800 number :=0;
  v_31801 number :=0;
  v_31900 number :=0;
  v_31901 number :=0;
  v_32000 number :=0;
  v_32100 number :=0;
  v_32200 number :=0;
  v_32201 number :=0;
  v_32300 number :=0;
  v_32400 number :=0;
  v_32401 number :=0;
  v_32402 number :=0;
  v_32500 number :=0;
  v_32501 number :=0;
  v_32502 number :=0;
  v_32600 number :=0;
  v_32700 number :=0;
  v_32800 number :=0;
  v_32900 number :=0;
  v_33000 number :=0;
  v_33400 number :=0;
  v_33500 number :=0;
  v_33501 number :=0;
  v_33502 number :=0;
  v_33800 number :=0;
  v_33801 number :=0;
  v_34400 number :=0;
  v_34500 number :=0;
  v_34600 number :=0;
  v_34700 number :=0;
  v_34800 number :=0;
  v_34900 number :=0;
  v_35000 number :=0;
  v_35100 number :=0;
  v_35300 number :=0;
  v_35400 number :=0;
  v_35500 number :=0;
  v_35600 number :=0;
  v_35700 number :=0;
  v_35800 number :=0;
  v_32403 number :=0;
  v_32404 number :=0;
  v_32503 number :=0;
  v_31201 number :=0;
  v_30401 number :=0;
  v_30402 number :=0;
  v_31202 number :=0;
  v_35301 number :=0;
  v_35401 number :=0;
  
   BEGIN
      FOR x IN (select
        gstt.SOL_ID, 
        gstt.bal_date,
        gstt.GL_SUB_HEAD_CODE , 
        case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
        then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
        else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total,  
        gstt.CRNCY_CODE 
        from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE RPT
        where to_char(tbaadm.gstt.bal_date,'MM-YYYY') = to_char(to_date(cast
        (vi_estimateDate as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
        and gstt.GL_SUB_HEAD_CODE = RPT.VARIABLE_VALUE
        and RPT.VARIABLE_NAME = variableName
        AND RPT.BANK_ID = '01'
        AND RPT.MODULE_NAME = 'REPORT'
        AND RPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
        GROUP BY gstt.SOL_ID,gstt.GL_SUB_HEAD_CODE, 
        gstt.CRNCY_CODE, RPT.DESCRIPTION, gstt.bal_date
        ORDER BY gstt.GL_SUB_HEAD_CODE) 
        LOOP
          
          begin
          --v_solId := x.SOL_ID;
          counter := counter + 1;
          if (x.CRNCY_CODE = 'MMK') THEN v_rate := 1;
          v_calculateCurAmt := x.total * v_rate;
          else 
          SELECT  VAR_CRNCY_UNITS into v_rate
          FROM tbaadm.RTL  e where TRIM(FXD_CRNCY_CODE) = x.CRNCY_CODE 
          and TRIM(VAR_CRNCY_CODE) = 'MMK' 
          --and rtlist_date <= x.bal_date
          and RATECODE = (select variable_value 
          from custom.CUST_GENCUST_PARAM_MAINT 
          where module_name = 'FOREIGN_CURRENCY' 
          and variable_name = 'RATE_CODE')
          and rownum =1
          order by rtlist_date desc;
            v_calculateCurAmt := x.total * v_rate;
          end if;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_rate := 1;
            v_calculateCurAmt := x.total * v_rate;
        end;
        
        CASE x.SOL_ID 
          when '10100' then v_10100 := v_10100+ v_calculateCurAmt;
          when '20100' then v_20100 := v_20100+ v_calculateCurAmt;
          when '20300' then v_20300 := v_20300+ v_calculateCurAmt;
          when '30100' then v_30100 := v_30100+ v_calculateCurAmt;
          when '30200' then v_30200 := v_30200+ v_calculateCurAmt;
          when '30201' then v_30201 := v_30201+ v_calculateCurAmt;
          when '30300' then v_30300 := v_30300+ v_calculateCurAmt;
          when '30301' then v_30301 := v_30301+ v_calculateCurAmt;
          when '30302' then v_30302 := v_30302+ v_calculateCurAmt;
          when '30400' then v_30400 := v_30400+ v_calculateCurAmt;
          when '30500' then v_30500 := v_30500+ v_calculateCurAmt;
          when '30600' then v_30600 := v_30600+ v_calculateCurAmt;
          when '30700' then v_30700 := v_30700+ v_calculateCurAmt;
          when '30800' then v_30800 := v_30800+ v_calculateCurAmt;
          when '30900' then v_30900 := v_30900+ v_calculateCurAmt;
          when '31000' then v_31000 := v_31000+ v_calculateCurAmt;
          when '31001' then v_31001 := v_31001+ v_calculateCurAmt;
          when '31100' then v_31100 := v_31100+ v_calculateCurAmt;
          when '31200' then v_31200 := v_31200+ v_calculateCurAmt;
          when '31300' then v_31300 := v_31300+ v_calculateCurAmt;
          when '31400' then v_31400 := v_31400+ v_calculateCurAmt;
          when '31500' then v_31500 := v_31500+ v_calculateCurAmt;
          when '31600' then v_31600 := v_31600+ v_calculateCurAmt;
          when '31700' then v_31700 := v_31700+ v_calculateCurAmt;
          when '31800' then v_31800 := v_31800+ v_calculateCurAmt;
          when '31801' then v_31801 := v_31801+ v_calculateCurAmt;
          when '31900' then v_31900 := v_31900+ v_calculateCurAmt;
          when '31901' then v_31901 := v_31901+ v_calculateCurAmt;
          when '32000' then v_32000 := v_32000+ v_calculateCurAmt;
          when '32100' then v_32100 := v_32100+ v_calculateCurAmt;
          when '32200' then v_32200 := v_32200+ v_calculateCurAmt;
          when '32201' then v_32201 := v_32201+ v_calculateCurAmt;
          when '32300' then v_32300 := v_32300+ v_calculateCurAmt;
          when '32400' then v_32400 := v_32400+ v_calculateCurAmt;
          when '32401' then v_32401 := v_32401+ v_calculateCurAmt;
          when '32402' then v_32402 := v_32402+ v_calculateCurAmt;
          when '32500' then v_32500 := v_32500+ v_calculateCurAmt;
          when '32501' then v_32501 := v_32501+ v_calculateCurAmt;
          when '32502' then v_32502 := v_32502+ v_calculateCurAmt;
          when '32600' then v_32600 := v_32600+ v_calculateCurAmt;
          when '32700' then v_32700 := v_32700+ v_calculateCurAmt;
          when '32800' then v_32800 := v_32800+ v_calculateCurAmt;
          when '32900' then v_32900 := v_32900+ v_calculateCurAmt;
          when '33000' then v_33000 := v_33000+ v_calculateCurAmt;
          when '33400' then v_33400 := v_33400+ v_calculateCurAmt;
          when '33500' then v_33500 := v_33500+ v_calculateCurAmt;
          when '33501' then v_33501 := v_33501+ v_calculateCurAmt;
          when '33502' then v_33502 := v_33502+ v_calculateCurAmt;
          when '33800' then v_33800 := v_33800+ v_calculateCurAmt;
          when '33801' then v_33801 := v_33801+ v_calculateCurAmt;
          when '34400' then v_34400 := v_34400+ v_calculateCurAmt;
          when '34500' then v_34500 := v_34500+ v_calculateCurAmt;
          when '34600' then v_34600 := v_34600+ v_calculateCurAmt;
          when '34700' then v_34700 := v_34700+ v_calculateCurAmt;
          when '34800' then v_34800 := v_34800+ v_calculateCurAmt;
          when '34900' then v_34900 := v_34900+ v_calculateCurAmt;
          when '35000' then v_35000 := v_35000+ v_calculateCurAmt;
          when '35100' then v_35100 := v_35100+ v_calculateCurAmt;
          when '35300' then v_35300 := v_35300+ v_calculateCurAmt;
          when '35400' then v_35400 := v_35400+ v_calculateCurAmt;
          when '35500' then v_35500 := v_35500+ v_calculateCurAmt;
          when '35600' then v_35600 := v_35600+ v_calculateCurAmt;
          when '35700' then v_35700 := v_35700+ v_calculateCurAmt;
          when '35800' then v_35800 := v_35800+ v_calculateCurAmt;
          when '32403' then v_32403 := v_32403+ v_calculateCurAmt;
          when '32404' then v_32404 := v_32404+ v_calculateCurAmt;
          when '32503' then v_32503 := v_32503+ v_calculateCurAmt;
          when '31201' then v_31201 := v_31201+ v_calculateCurAmt;
          when '30401' then v_30401 := v_30401+ v_calculateCurAmt;
          when '30402' then v_30402 := v_30402+ v_calculateCurAmt;
          when '31202' then v_31202 := v_31202+ v_calculateCurAmt;
          when '35301' then v_35301 := v_35301+ v_calculateCurAmt;
          when '35401' then v_35401 := v_35401+ v_calculateCurAmt;




          
         -- else v_35100 := v_35100+ v_calculateCurAmt;
      END CASE;
        --v_solIdAndAmt := branch_list(counter) ||'|'|| v_solIdAndAmt;
      END LOOP;
      branch_list(1) := '10100' ||','|| v_10100;
        branch_list(2) := '20100' ||','|| v_20100;
        branch_list(3) := '20300' ||','|| v_20300;
        branch_list(4) := '30100' ||','|| v_30100;
        branch_list(5) := '30200' ||','|| v_30200;
        branch_list(6) := '30201' ||','|| v_30201;
        branch_list(7) := '30300' ||','|| v_30300;
        branch_list(8) := '30301' ||','|| v_30301;
        branch_list(9) := '30302' ||','|| v_30302;
        branch_list(10) := '30400' ||','|| v_30400;
        branch_list(11) := '30500' ||','|| v_30500;
        branch_list(12) := '30600' ||','|| v_30600;
        branch_list(13) := '30700' ||','|| v_30700;
        branch_list(14) := '30800' ||','|| v_30800;
        branch_list(15) := '30900' ||','|| v_30900;
        branch_list(16) := '31000' ||','|| v_31000;
        branch_list(17) := '31001' ||','|| v_31001;
        branch_list(18) := '31100' ||','|| v_31100;
        branch_list(19) := '31200' ||','|| v_31200;
        branch_list(20) := '31300' ||','|| v_31300;
        branch_list(21) := '31400' ||','|| v_31400;
        branch_list(22) := '31500' ||','|| v_31500;
        branch_list(23) := '31600' ||','|| v_31600;
        branch_list(24) := '31700' ||','|| v_31700;
        branch_list(25) := '31800' ||','|| v_31800;
        branch_list(26) := '31801' ||','|| v_31801;
        branch_list(27) := '31900' ||','|| v_31900;
        branch_list(28) := '31901' ||','|| v_31901;
        branch_list(29) := '32000' ||','|| v_32000;
        branch_list(30) := '32100' ||','|| v_32100;
        branch_list(31) := '32200' ||','|| v_32200;
        branch_list(32) := '32201' ||','|| v_32201;
        branch_list(33) := '32300' ||','|| v_32300;
        branch_list(34) := '32400' ||','|| v_32400;
        branch_list(35) := '32401' ||','|| v_32401;
        branch_list(36) := '32402' ||','|| v_32402;
        branch_list(37) := '32500' ||','|| v_32500;
        branch_list(38) := '32501' ||','|| v_32501;
        branch_list(39) := '32502' ||','|| v_32502;
        branch_list(40) := '32600' ||','|| v_32600;
        branch_list(41) := '32700' ||','|| v_32700;
        branch_list(42) := '32800' ||','|| v_32800;
        branch_list(43) := '32900' ||','|| v_32900;
        branch_list(44) := '33000' ||','|| v_33000;
        branch_list(45) := '33400' ||','|| v_33400;
        branch_list(46) := '33500' ||','|| v_33500;
        branch_list(47) := '33501' ||','|| v_33501;
        branch_list(48) := '33502' ||','|| v_33502;
        branch_list(49) := '33800' ||','|| v_33800;
        branch_list(50) := '33801' ||','|| v_33801;
        branch_list(51) := '34400' ||','|| v_34400;
        branch_list(52) := '34500' ||','|| v_34500;
        branch_list(53) := '34600' ||','|| v_34600;
        branch_list(54) := '34700' ||','|| v_34700;
        branch_list(55) := '34800' ||','|| v_34800;
        branch_list(56) := '34900' ||','|| v_34900;
        branch_list(57) := '35000' ||','|| v_35000;
        branch_list(58) := '35100' ||','|| v_35100;
        branch_list(59) := '35300' ||','|| v_35300;
        branch_list(60) := '35400' ||','|| v_35400;
        branch_list(61) := '35500' ||','|| v_35500;
        branch_list(62) := '35600' ||','|| v_35600;
        branch_list(63) := '35700' ||','|| v_35700;
        branch_list(64) := '35800' ||','|| v_35800;
        branch_list(65) := '32403' ||','|| v_32403;
        branch_list(66) := '32404' ||','|| v_32404;
        branch_list(67) := '32503' ||','|| v_32503;
        branch_list(68) := '31201' ||','|| v_31201;
        branch_list(69) := '30401' ||','|| v_30401;
        branch_list(70) := '30402' ||','|| v_30402;
        branch_list(71) := '31202' ||','|| v_31202;
        branch_list(72) := '35301' ||','|| v_35301;
        branch_list(73) := '35401' ||','|| v_35401;
        
      RETURN branch_list;
  END FUNC_TWO;
--------------------------------------------------------------------------------
  FUNCTION FUNC_THREE(variableName varchar2) 
  RETURN CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE AS
  
  v_description CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE;
  
  BEGIN
    select DESCRIPTION 
        into v_description
        from CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE
        where VARIABLE_NAME = variableName
        AND BANK_ID = '01'
        AND MODULE_NAME = 'REPORT'
        AND SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE';
        RETURN v_description;
  END FUNC_THREE;
--------------------------------------------------------------------------------
  FUNCTION FUNC_FOUR 
  RETURN f_sol_list AS
  
  i integer := 0;
  solId_list f_sol_list;
  v_solId VARCHAR2(700);
  BEGIN
------------------------------GET SOL_ID----------------------------------------
      FOR x IN (
        SELECT SOL_ID 
        FROM TBAADM.SOL
        WHERE DEL_FLG = 'N'
        ORDER BY SOL_ID asc
        )
      LOOP
        i := i + 1;
        --solId_list.extend; -- BRANCH LIST
        solId_list(i) := x.SOL_ID;
        v_solId := x.SOL_ID ||'|'|| v_solId;
     END LOOP;
     RETURN solId_list;
  END;
--------------------------------------------------------------------------------
  FUNCTION FUNC_FIVE(num varchar2, f_sab_list sab_list, 
  description CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE, groupType varchar2,
  tID number) 
  RETURN BOOLEAN AS
  
  v_returnValue boolean := true;
  solId varchar2(10);
  amount number;
  
  v_10100 number :=0;
  v_20100 number :=0;
  v_20300 number :=0;
  v_30100 number :=0;
  v_30200 number :=0;
  v_30201 number :=0;
  v_30300 number :=0;
  v_30301 number :=0;
  v_30302 number :=0;
  v_30400 number :=0;
  v_30500 number :=0;
  v_30600 number :=0;
  v_30700 number :=0;
  v_30800 number :=0;
  v_30900 number :=0;
  v_31000 number :=0;
  v_31001 number :=0;
  v_31100 number :=0;
  v_31200 number :=0;
  v_31300 number :=0;
  v_31400 number :=0;
  v_31500 number :=0;
  v_31600 number :=0;
  v_31700 number :=0;
  v_31800 number :=0;
  v_31801 number :=0;
  v_31900 number :=0;
  v_31901 number :=0;
  v_32000 number :=0;
  v_32100 number :=0;
  v_32200 number :=0;
  v_32201 number :=0;
  v_32300 number :=0;
  v_32400 number :=0;
  v_32401 number :=0;
  v_32402 number :=0;
  v_32500 number :=0;
  v_32501 number :=0;
  v_32502 number :=0;
  v_32600 number :=0;
  v_32700 number :=0;
  v_32800 number :=0;
  v_32900 number :=0;
  v_33000 number :=0;
  v_33400 number :=0;
  v_33500 number :=0;
  v_33501 number :=0;
  v_33502 number :=0;
  v_33800 number :=0;
  v_33801 number :=0;
  v_34400 number :=0;
  v_34500 number :=0;
  v_34600 number :=0;
  v_34700 number :=0;
  v_34800 number :=0;
  v_34900 number :=0;
  v_35000 number :=0;
  v_35100 number :=0;
  v_35300 number :=0;
  v_35400 number :=0;
  v_35500 number :=0;
  v_35600 number :=0;
  v_35700 number :=0;
  v_35800 number :=0;
  v_32403 number :=0;
  v_32404 number :=0;
  v_32503 number :=0;
  v_31201 number :=0;
  v_30401 number :=0;
  v_30402 number :=0;
  v_31202 number :=0;
  v_35301 number :=0;
  v_35401 number :=0;
  v_total number :=0;
  
  
  BEGIN
    FOR x IN 1.. f_sab_list.count
    LOOP
      solId := regexp_substr(f_sab_list(x), '[^,]+', 1, 1);
      amount := regexp_substr(f_sab_list(x), '[^,]+', 1, 2);
      CASE solId 
          when '10100' then v_10100 := amount;
          when '20100' then v_20100 := amount;
          when '20300' then v_20300 := amount;
          when '30100' then v_30100 := amount;
          when '30200' then v_30200 := amount;
          when '30201' then v_30201 := amount;
          when '30300' then v_30300 := amount;
          when '30301' then v_30301 := amount;
          when '30302' then v_30302 := amount;
          when '30400' then v_30400 := amount;
          when '30500' then v_30500 := amount;
          when '30600' then v_30600 := amount;
          when '30700' then v_30700 := amount;
          when '30800' then v_30800 := amount;
          when '30900' then v_30900 := amount;
          when '31000' then v_31000 := amount;
          when '31001' then v_31001 := amount;
          when '31100' then v_31100 := amount;
          when '31200' then v_31200 := amount;
          when '31300' then v_31300 := amount;
          when '31400' then v_31400 := amount;
          when '31500' then v_31500 := amount;
          when '31600' then v_31600 := amount;
          when '31700' then v_31700 := amount;
          when '31800' then v_31800 := amount;
          when '31801' then v_31801 := amount;
          when '31900' then v_31900 := amount;
          when '31901' then v_31901 := amount;
          when '32000' then v_32000 := amount;
          when '32100' then v_32100 := amount;
          when '32200' then v_32200 := amount;
          when '32201' then v_32201 := amount;
          when '32300' then v_32300 := amount;
          when '32400' then v_32400 := amount;
          when '32401' then v_32401 := amount;
          when '32402' then v_32402 := amount;
          when '32500' then v_32500 := amount;
          when '32501' then v_32501 := amount;
          when '32502' then v_32502 := amount;
          when '32600' then v_32600 := amount;
          when '32700' then v_32700 := amount;
          when '32800' then v_32800 := amount;
          when '32900' then v_32900 := amount;
          when '33000' then v_33000 := amount;
          when '33400' then v_33400 := amount;
          when '33500' then v_33500 := amount;
          when '33501' then v_33501 := amount;
          when '33502' then v_33502 := amount;
          when '33800' then v_33800 := amount;
          when '33801' then v_33801 := amount;
          when '34400' then v_34400 := amount;
          when '34500' then v_34500 := amount;
          when '34600' then v_34600 := amount;
          when '34700' then v_34700 := amount;
          when '34800' then v_34800 := amount;
          when '34900' then v_34900 := amount;
          when '35000' then v_35000 := amount;
          when '35100' then v_35100 := amount;
          when '35300' then v_35300 := amount;
          when '35400' then v_35400 := amount;
          when '35500' then v_35500:= amount;
          when '35600' then v_35600:= amount;
          when '35700' then v_35700 := amount;
          when '35800' then v_35800:= amount;
          when '32403' then v_32403 := amount;
          when '32404' then v_32404 := amount;
          when '32503' then v_32503 := amount;
          when '31201' then v_31201 := amount;
          when '30401' then v_30401 := amount;
          when '30402' then v_30402 := amount;
          when '31202' then v_31202 := amount;
          when '35301' then v_35301 := amount;
          when '35401' then v_35401 := amount;
          
          else v_35100 := amount;
      END CASE;
    END LOOP;
    v_total := v_10100 + v_20100+ v_20300+
    v_30100+ v_30200+ v_30201+ v_30300+ v_30301+ v_30302+ 
    v_30400+ v_30500+ v_30600+ v_30700+ v_30800+ v_30900+ v_31000+ 
    v_31001+ v_31100+ v_31200+ v_31300+ v_31400+ v_31500+ v_31600+ 
    v_31700+ v_31800+ v_31801+ v_31900+ v_31901+ v_32000+ v_32100+ 
    v_32200+ v_32201+ v_32300+ v_32400+ v_32401+ v_32402+ v_32500+ 
    v_32501+ v_32502+ v_32600+ v_32700+ v_32800+ v_32900+ v_33000+ 
    v_33400+ v_33500+ v_33501+ v_33502+ v_33800+ v_33801+ v_34400+ 
    v_34500+ v_34600+ v_34700+ v_34800+ v_34900+ v_35000+ v_35100+
    v_35300+ v_35400+ v_35500+ v_35600+ v_35700+ v_35800 + v_32403+
    v_32404 + v_32503 + v_31201+v_30401 +v_30402+v_31202+v_35301+v_35401+v_total;
    
    insert into custom.CUST_PNL_TEMP_TABLE 
      values (num, description,groupType,tID,v_10100,v_20100,v_20300,v_30100,
    v_30200,v_30201,v_30300,v_30301,v_30302,v_30400,v_30500,
    v_30600,v_30700,v_30800,v_30900,v_31000,v_31001,v_31100,
    v_31200,v_31300,v_31400,v_31500,v_31600,v_31700,v_31800,
    v_31801,v_31900,v_31901,v_32000,v_32100,v_32200,v_32201,
    v_32300,v_32400,v_32401,v_32402,v_32500,v_32501,v_32502,
    v_32600,v_32700,v_32800,v_32900,v_33000,v_33400,v_33500,
    v_33501,v_33502,v_33800,v_33801,v_34400,v_34500,
    v_34600,v_34700,v_34800,v_34900,v_35000,v_35100,
    v_35300,v_35400,v_35500,v_35600,v_35700,v_35800,
    v_32403,v_32404,v_32503,v_31201,v_30401,v_30402,
    v_31202,v_35301,v_35401,v_TOTAL );
    commit; 
    return v_returnValue;
  END FUNC_FIVE;
--------------------------------------------------------------------------------
  FUNCTION FUNC_SIX(title varchar2, groupType varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_Total10100 number :=0;
  v_Total20100 number :=0;
  v_Total20300 number :=0;
  v_Total30100 number :=0;
  v_Total30200 number :=0;
  v_Total30201 number :=0;
  v_Total30300 number :=0;
  v_Total30301 number :=0;
  v_Total30302 number :=0;
  v_Total30400 number :=0;
  v_Total30500 number :=0;
  v_Total30600 number :=0;
  v_Total30700 number :=0;
  v_Total30800 number :=0;
  v_Total30900 number :=0;
  v_Total31000 number :=0;
  v_Total31001 number :=0;
  v_Total31100 number :=0;
  v_Total31200 number :=0;
  v_Total31300 number :=0;
  v_Total31400 number :=0;
  v_Total31500 number :=0;
  v_Total31600 number :=0;
  v_Total31700 number :=0;
  v_Total31800 number :=0;
  v_Total31801 number :=0;
  v_Total31900 number :=0;
  v_Total31901 number :=0;
  v_Total32000 number :=0;
  v_Total32100 number :=0;
  v_Total32200 number :=0;
  v_Total32201 number :=0;
  v_Total32300 number :=0;
  v_Total32400 number :=0;
  v_Total32401 number :=0;
  v_Total32402 number :=0;
  v_Total32500 number :=0;
  v_Total32501 number :=0;
  v_Total32502 number :=0;
  v_Total32600 number :=0;
  v_Total32700 number :=0;
  v_Total32800 number :=0;
  v_Total32900 number :=0;
  v_Total33000 number :=0;
  v_Total33400 number :=0;
  v_Total33500 number :=0;
  v_Total33501 number :=0;
  v_Total33502 number :=0;
  v_Total33800 number :=0;
  v_Total33801 number :=0;
  v_Total34400 number :=0;
  v_Total34500 number :=0;
  v_Total34600 number :=0;
  v_Total34700 number :=0;
  v_Total34800 number :=0;
  v_Total34900 number :=0;
  v_Total35000 number :=0;
  v_Total35100 number :=0;
  v_Total35300 number :=0;
  v_Total35400 number :=0;
  v_Total35500 number :=0;
  v_Total35600 number :=0;
  v_Total35700 number :=0;
  v_Total35800 number :=0;
  v_Total32403 number :=0;
  v_Total32404 number :=0;
  v_Total32503 number :=0;
  v_Total31201 number :=0;
  v_Total30401 number :=0;
  v_Total30402 number :=0;
  v_Total31202 number :=0;
  v_Total35301 number :=0;
  v_Total35401 number :=0;
  
  
  v_total number :=0;
  
  BEGIN
  select 
  sum(amt_10100),sum(amt_20100), sum(amt_20300),
  sum(amt_30100), sum(amt_30200), sum(amt_30201), sum(amt_30300), sum(amt_30301), 
  sum(amt_30302), sum(amt_30400), sum(amt_30500), sum(amt_30600), sum(amt_30700), 
  sum(amt_30800), sum(amt_30900), sum(amt_31000), sum(amt_31001), sum(amt_31100), 
  sum(amt_31200), sum(amt_31300), sum(amt_31400), sum(amt_31500), sum(amt_31600), 
  sum(amt_31700), sum(amt_31800), sum(amt_31801), sum(amt_31900), sum(amt_31901), 
  sum(amt_32000), sum(amt_32100), sum(amt_32200), sum(amt_32201), sum(amt_32300), 
  sum(amt_32400), sum(amt_32401), sum(amt_32402), sum(amt_32500), sum(amt_32501), 
  sum(amt_32502), sum(amt_32600), sum(amt_32700), sum(amt_32800), sum(amt_32900), 
  sum(amt_33000), sum(amt_33400), sum(amt_33500), sum(amt_33501), sum(amt_33502), 
  sum(amt_33800), sum(amt_33801), sum(amt_34400), sum(amt_34500), sum(amt_34600), 
  sum(amt_34700), sum(amt_34800), sum(amt_34900), sum(amt_35000), sum(amt_35100),
  sum(amt_35300),sum(amt_35400),sum(amt_35500),sum(amt_35600),sum(amt_35700),
  sum(amt_35800),sum(amt_32403),sum(amt_32404),sum(amt_32503),sum(amt_31201),
  sum(amt_30401),sum(amt_30402),sum(amt_31202),sum(amt_35301),sum(amt_35401)
  
  INTO v_Total10100,v_Total20100, v_Total20300,
  v_Total30100, v_Total30200, v_Total30201, v_Total30300, v_Total30301, 
  v_Total30302, v_Total30400, v_Total30500, v_Total30600, v_Total30700, 
  v_Total30800, v_Total30900, v_Total31000, v_Total31001, v_Total31100, 
  v_Total31200, v_Total31300, v_Total31400, v_Total31500, v_Total31600, 
  v_Total31700, v_Total31800, v_Total31801, v_Total31900, v_Total31901, 
  v_Total32000, v_Total32100, v_Total32200, v_Total32201, v_Total32300, 
  v_Total32400, v_Total32401, v_Total32402, v_Total32500, v_Total32501, 
  v_Total32502, v_Total32600, v_Total32700, v_Total32800, v_Total32900, 
  v_Total33000, v_Total33400, v_Total33500, v_Total33501, v_Total33502, 
  v_Total33800, v_Total33801, v_Total34400, v_Total34500, v_Total34600, 
  v_Total34700, v_Total34800, v_Total34900, v_Total35000, v_Total35100,
  v_Total35300, v_Total35400, v_Total35500, v_Total35600,v_Total35700,
  v_Total35800 ,v_Total32403 ,v_Total32404 ,v_Total32503 ,v_Total31201 ,
  v_Total30401 ,v_Total30402 ,v_Total31202 ,v_Total35301 ,v_Total35401 
from 
  CUSTOM.CUST_PNL_TEMP_TABLE
where 
  group_type = groupType;
  
  v_total := v_Total10100+v_Total20100+ v_Total20300+
  v_Total30100+ v_Total30200+ v_Total30201+ v_Total30300+ v_Total30301+ 
  v_Total30302+ v_Total30400+ v_Total30500+ v_Total30600+ v_Total30700+ 
  v_Total30800+ v_Total30900+ v_Total31000+ v_Total31001+ v_Total31100+ 
  v_Total31200+ v_Total31300+ v_Total31400+ v_Total31500+ v_Total31600+ 
  v_Total31700+ v_Total31800+ v_Total31801+ v_Total31900+ v_Total31901+ 
  v_Total32000+ v_Total32100+ v_Total32200+ v_Total32201+ v_Total32300+ 
  v_Total32400+ v_Total32401+ v_Total32402+ v_Total32500+ v_Total32501+ 
  v_Total32502+ v_Total32600+ v_Total32700+ v_Total32800+ v_Total32900+ 
  v_Total33000+ v_Total33400+ v_Total33500+ v_Total33501+ v_Total33502+ 
  v_Total33800+ v_Total33801+ v_Total34400+ v_Total34500+ v_Total34600+ 
  v_Total34700+ v_Total34800+ v_Total34900+ v_Total35000+ v_Total35100+
  v_Total35300+ v_Total35400+ v_Total35500+ v_Total35600+v_Total35700+
  v_Total35800 +v_Total32403 +v_Total32404 +v_Total32503 +v_Total31201 +
  v_Total30401 +v_Total30402 +v_Total31202 +v_Total35301 +v_Total35401 ;
  
  insert into custom.CUST_PNL_TEMP_TABLE 
    values ('', title, groupType||'_TOTAL',tID,v_Total10100,
    v_Total20100, v_Total20300,v_Total30100, v_Total30200, v_Total30201, 
    v_Total30300, v_Total30301, v_Total30302, v_Total30400, v_Total30500, 
    v_Total30600, v_Total30700, v_Total30800, v_Total30900, v_Total31000, 
    v_Total31001, v_Total31100, v_Total31200, v_Total31300, v_Total31400, 
    v_Total31500, v_Total31600, v_Total31700, v_Total31800, v_Total31801, 
    v_Total31900, v_Total31901, v_Total32000, v_Total32100, v_Total32200, 
    v_Total32201, v_Total32300, v_Total32400, v_Total32401, v_Total32402, 
    v_Total32500, v_Total32501, v_Total32502, v_Total32600, v_Total32700, 
    v_Total32800, v_Total32900, v_Total33000, v_Total33400, v_Total33500, 
    v_Total33501, v_Total33502, v_Total33800, v_Total33801, v_Total34400, 
    v_Total34500, v_Total34600, v_Total34700, v_Total34800, v_Total34900, 
    v_Total35000, v_Total35100,
    v_Total35300, v_Total35400, v_Total35500, v_Total35600,v_Total35700,
    v_Total35800 ,v_Total32403 ,v_Total32404 ,v_Total32503 ,v_Total31201,
    v_Total30401 ,v_Total30402 ,v_Total31202 ,v_Total35301 ,v_Total35401 ,v_total );
    commit;
  
    RETURN v_returnValue;
  END FUNC_SIX;
--------------------------------------------------------------------------------
  FUNCTION FUNC_SEVEN(title varchar2, groupType1 varchar2,
  groupType2 varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_Total10100 number :=0;
  v_Total20100 number :=0;
  v_Total20300 number :=0;
  v_Total30100 number :=0;
  v_Total30200 number :=0;
  v_Total30201 number :=0;
  v_Total30300 number :=0;
  v_Total30301 number :=0;
  v_Total30302 number :=0;
  v_Total30400 number :=0;
  v_Total30500 number :=0;
  v_Total30600 number :=0;
  v_Total30700 number :=0;
  v_Total30800 number :=0;
  v_Total30900 number :=0;
  v_Total31000 number :=0;
  v_Total31001 number :=0;
  v_Total31100 number :=0;
  v_Total31200 number :=0;
  v_Total31300 number :=0;
  v_Total31400 number :=0;
  v_Total31500 number :=0;
  v_Total31600 number :=0;
  v_Total31700 number :=0;
  v_Total31800 number :=0;
  v_Total31801 number :=0;
  v_Total31900 number :=0;
  v_Total31901 number :=0;
  v_Total32000 number :=0;
  v_Total32100 number :=0;
  v_Total32200 number :=0;
  v_Total32201 number :=0;
  v_Total32300 number :=0;
  v_Total32400 number :=0;
  v_Total32401 number :=0;
  v_Total32402 number :=0;
  v_Total32500 number :=0;
  v_Total32501 number :=0;
  v_Total32502 number :=0;
  v_Total32600 number :=0;
  v_Total32700 number :=0;
  v_Total32800 number :=0;
  v_Total32900 number :=0;
  v_Total33000 number :=0;
  v_Total33400 number :=0;
  v_Total33500 number :=0;
  v_Total33501 number :=0;
  v_Total33502 number :=0;
  v_Total33800 number :=0;
  v_Total33801 number :=0;
  v_Total34400 number :=0;
  v_Total34500 number :=0;
  v_Total34600 number :=0;
  v_Total34700 number :=0;
  v_Total34800 number :=0;
  v_Total34900 number :=0;
  v_Total35000 number :=0;
  v_Total35100 number :=0;
    v_Total35300 number :=0;
  v_Total35400 number :=0;
  v_Total35500  number :=0;
  v_Total35600 number :=0;
  v_Total35700 number :=0;
  v_Total35800 number :=0;
  v_Total32403 number :=0;
  v_Total32404 number :=0;
  v_Total32503 number :=0;
  v_Total31201 number :=0;
  v_Total30401 number :=0;
  v_Total30402 number :=0;
  v_Total31202 number :=0;
  v_Total35301 number :=0;
  v_Total35401 number :=0;
  v_total number :=0;
  
  BEGIN
  select 
  sum(amt_10100),sum(amt_20100), sum(amt_20300),
  sum(amt_30100), sum(amt_30200), sum(amt_30201), sum(amt_30300), sum(amt_30301), 
  sum(amt_30302), sum(amt_30400), sum(amt_30500), sum(amt_30600), sum(amt_30700), 
  sum(amt_30800), sum(amt_30900), sum(amt_31000), sum(amt_31001), sum(amt_31100), 
  sum(amt_31200), sum(amt_31300), sum(amt_31400), sum(amt_31500), sum(amt_31600), 
  sum(amt_31700), sum(amt_31800), sum(amt_31801), sum(amt_31900), sum(amt_31901), 
  sum(amt_32000), sum(amt_32100), sum(amt_32200), sum(amt_32201), sum(amt_32300), 
  sum(amt_32400), sum(amt_32401), sum(amt_32402), sum(amt_32500), sum(amt_32501), 
  sum(amt_32502), sum(amt_32600), sum(amt_32700), sum(amt_32800), sum(amt_32900), 
  sum(amt_33000), sum(amt_33400), sum(amt_33500), sum(amt_33501), sum(amt_33502), 
  sum(amt_33800), sum(amt_33801), sum(amt_34400), sum(amt_34500), sum(amt_34600), 
  sum(amt_34700), sum(amt_34800), sum(amt_34900), sum(amt_35000), sum(amt_35100),
  sum(amt_35300),sum(amt_35400),sum(amt_35500),sum(amt_35600),sum(amt_35700),
  sum(amt_35800),sum(amt_32403),sum(amt_32404),sum(amt_32503),sum(amt_31201),
  sum(amt_30401),sum(amt_30402),sum(amt_31202),sum(amt_35301), sum(amt_35401),sum(amt_total)
  INTO v_Total10100,v_Total20100, v_Total20300,
  v_Total30100, v_Total30200, v_Total30201, v_Total30300, v_Total30301, 
  v_Total30302, v_Total30400, v_Total30500, v_Total30600, v_Total30700, 
  v_Total30800, v_Total30900, v_Total31000, v_Total31001, v_Total31100, 
  v_Total31200, v_Total31300, v_Total31400, v_Total31500, v_Total31600, 
  v_Total31700, v_Total31800, v_Total31801, v_Total31900, v_Total31901, 
  v_Total32000, v_Total32100, v_Total32200, v_Total32201, v_Total32300, 
  v_Total32400, v_Total32401, v_Total32402, v_Total32500, v_Total32501, 
  v_Total32502, v_Total32600, v_Total32700, v_Total32800, v_Total32900, 
  v_Total33000, v_Total33400, v_Total33500, v_Total33501, v_Total33502, 
  v_Total33800, v_Total33801, v_Total34400, v_Total34500, v_Total34600, 
  v_Total34700, v_Total34800, v_Total34900, v_Total35000, v_Total35100,
  v_Total35300, v_Total35400, v_Total35500, v_Total35600,v_Total35700,
  v_Total35800 ,v_Total32403 ,v_Total32404 ,v_Total32503 ,v_Total31201,
  v_Total30401 ,v_Total30402 ,v_Total31202,v_Total35301,v_Total35401,v_total
from 
  CUSTOM.CUST_PNL_TEMP_TABLE
where 
  group_type in (groupType1, groupType2);

  insert into custom.CUST_PNL_TEMP_TABLE 
    values ('', title, title,tID,v_Total10100,
    v_Total20100, v_Total20300,v_Total30100, v_Total30200, v_Total30201, 
    v_Total30300, v_Total30301, v_Total30302, v_Total30400, v_Total30500, 
    v_Total30600, v_Total30700, v_Total30800, v_Total30900, v_Total31000, 
    v_Total31001, v_Total31100, v_Total31200, v_Total31300, v_Total31400, 
    v_Total31500, v_Total31600, v_Total31700, v_Total31800, v_Total31801, 
    v_Total31900, v_Total31901, v_Total32000, v_Total32100, v_Total32200, 
    v_Total32201, v_Total32300, v_Total32400, v_Total32401, v_Total32402, 
    v_Total32500, v_Total32501, v_Total32502, v_Total32600, v_Total32700, 
    v_Total32800, v_Total32900, v_Total33000, v_Total33400, v_Total33500, 
    v_Total33501, v_Total33502, v_Total33800, v_Total33801, v_Total34400, 
    v_Total34500, v_Total34600, v_Total34700, v_Total34800, v_Total34900, 
    v_Total35000, v_Total35100,
    v_Total35300, v_Total35400, v_Total35500, v_Total35600,v_Total35700,
    v_Total35800 ,v_Total32403 ,v_Total32404 ,v_Total32503 ,v_Total31201,
    v_Total30401 ,v_Total30402 ,v_Total31202,v_Total35301,v_Total35401,v_total );
    commit;
  
    RETURN v_returnValue;
  END FUNC_SEVEN;
--------------------------------------------------------------------------------
FUNCTION FUNC_EIGHT(title varchar2, groupType1 varchar2,
  groupType2 varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_Total10100 number :=0;v_Total20100 number :=0;v_Total20300 number :=0;
  v_Total30100 number :=0;v_Total30200 number :=0;v_Total30201 number :=0;
  v_Total30300 number :=0;v_Total30301 number :=0;v_Total30302 number :=0;
  v_Total30400 number :=0;v_Total30500 number :=0;v_Total30600 number :=0;
  v_Total30700 number :=0;v_Total30800 number :=0;v_Total30900 number :=0;
  v_Total31000 number :=0;v_Total31001 number :=0;v_Total31100 number :=0;
  v_Total31200 number :=0;v_Total31300 number :=0;v_Total31400 number :=0;
  v_Total31500 number :=0;v_Total31600 number :=0;v_Total31700 number :=0;
  v_Total31800 number :=0;v_Total31801 number :=0;v_Total31900 number :=0;
  v_Total31901 number :=0;v_Total32000 number :=0;v_Total32100 number :=0;
  v_Total32200 number :=0;v_Total32201 number :=0;v_Total32300 number :=0;
  v_Total32400 number :=0;v_Total32401 number :=0;v_Total32402 number :=0;
  v_Total32500 number :=0;v_Total32501 number :=0;v_Total32502 number :=0;
  v_Total32600 number :=0;v_Total32700 number :=0;v_Total32800 number :=0;
  v_Total32900 number :=0;v_Total33000 number :=0;v_Total33400 number :=0;
  v_Total33500 number :=0;v_Total33501 number :=0;v_Total33502 number :=0;
  v_Total33800 number :=0;v_Total33801 number :=0;v_Total34400 number :=0;
  v_Total34500 number :=0;v_Total34600 number :=0;v_Total34700 number :=0;
  v_Total34800 number :=0;v_Total34900 number :=0;v_Total35000 number :=0;
  v_Total35100 number :=0;  v_Total35300 number :=0;v_Total35400 number :=0;
 v_Total35500  number :=0;v_Total35600 number :=0;v_Total35700 number :=0;
v_Total35800 number :=0;v_Total32403 number :=0;v_Total32404 number :=0;
v_Total32503 number :=0;v_Total31201 number :=0; v_Total30401 number :=0; 
v_Total30402 number :=0; v_Total31202 number :=0; v_Total35301 number :=0;
v_Total35401 number :=0; v_total number :=0;
  
  v1_Total10100 number :=0;v1_Total20100 number :=0;v1_Total20300 number :=0;
  v1_Total30100 number :=0;v1_Total30200 number :=0;v1_Total30201 number :=0;
  v1_Total30300 number :=0;v1_Total30301 number :=0;v1_Total30302 number :=0;
  v1_Total30400 number :=0;v1_Total30500 number :=0;v1_Total30600 number :=0;
  v1_Total30700 number :=0;v1_Total30800 number :=0;v1_Total30900 number :=0;
  v1_Total31000 number :=0;v1_Total31001 number :=0;v1_Total31100 number :=0;
  v1_Total31200 number :=0;v1_Total31300 number :=0;v1_Total31400 number :=0;
  v1_Total31500 number :=0;v1_Total31600 number :=0;v1_Total31700 number :=0;
  v1_Total31800 number :=0;v1_Total31801 number :=0;v1_Total31900 number :=0;
  v1_Total31901 number :=0;v1_Total32000 number :=0;v1_Total32100 number :=0;
  v1_Total32200 number :=0;v1_Total32201 number :=0;v1_Total32300 number :=0;
  v1_Total32400 number :=0;v1_Total32401 number :=0;v1_Total32402 number :=0;
  v1_Total32500 number :=0;v1_Total32501 number :=0;v1_Total32502 number :=0;
  v1_Total32600 number :=0;v1_Total32700 number :=0;v1_Total32800 number :=0;
  v1_Total32900 number :=0;v1_Total33000 number :=0;v1_Total33400 number :=0;
  v1_Total33500 number :=0;v1_Total33501 number :=0;v1_Total33502 number :=0;
  v1_Total33800 number :=0;v1_Total33801 number :=0;v1_Total34400 number :=0;
  v1_Total34500 number :=0;v1_Total34600 number :=0;v1_Total34700 number :=0;
  v1_Total34800 number :=0;v1_Total34900 number :=0;v1_Total35000 number :=0;
  v1_Total35100 number :=0; v1_Total35300 number :=0;v1_Total35400 number :=0;
 v1_Total35500  number :=0;v1_Total35600 number :=0;v1_Total35700 number :=0;
v1_Total35800 number :=0;v1_Total32403 number :=0;v1_Total32404 number :=0;
v1_Total32503 number :=0;v1_Total31201 number :=0; v1_Total30401 number :=0;
v1_Total30402 number :=0;v1_Total31202 number :=0;v1_Total35301 number :=0;
v1_Total35401 number :=0;v1_total number :=0;
  
  vr_Total10100 number :=0;vr_Total20100 number :=0;vr_Total20300 number :=0;
  vr_Total30100 number :=0;vr_Total30200 number :=0;vr_Total30201 number :=0;
  vr_Total30300 number :=0;vr_Total30301 number :=0;vr_Total30302 number :=0;
  vr_Total30400 number :=0;vr_Total30500 number :=0;vr_Total30600 number :=0;
  vr_Total30700 number :=0;vr_Total30800 number :=0;vr_Total30900 number :=0;
  vr_Total31000 number :=0;vr_Total31001 number :=0;vr_Total31100 number :=0;
  vr_Total31200 number :=0;vr_Total31300 number :=0;vr_Total31400 number :=0;
  vr_Total31500 number :=0;vr_Total31600 number :=0;vr_Total31700 number :=0;
  vr_Total31800 number :=0;vr_Total31801 number :=0;vr_Total31900 number :=0;
  vr_Total31901 number :=0;vr_Total32000 number :=0;vr_Total32100 number :=0;
  vr_Total32200 number :=0;vr_Total32201 number :=0;vr_Total32300 number :=0;
  vr_Total32400 number :=0;vr_Total32401 number :=0;vr_Total32402 number :=0;
  vr_Total32500 number :=0;vr_Total32501 number :=0;vr_Total32502 number :=0;
  vr_Total32600 number :=0;vr_Total32700 number :=0;vr_Total32800 number :=0;
  vr_Total32900 number :=0;vr_Total33000 number :=0;vr_Total33400 number :=0;
  vr_Total33500 number :=0;vr_Total33501 number :=0;vr_Total33502 number :=0;
  vr_Total33800 number :=0;vr_Total33801 number :=0;vr_Total34400 number :=0;
  vr_Total34500 number :=0;vr_Total34600 number :=0;vr_Total34700 number :=0;
  vr_Total34800 number :=0;vr_Total34900 number :=0;vr_Total35000 number :=0;
  vr_Total35100 number :=0; vr_Total35300 number :=0;vr_Total35400 number :=0;
  vr_Total35500  number :=0;vr_Total35600 number :=0;vr_Total35700 number :=0;
  vr_Total35800 number :=0;vr_Total32403 number :=0;vr_Total32404 number :=0;
  vr_Total32503 number :=0;vr_Total31201 number :=0;vr_Total30401 number :=0;
  vr_Total30402 number :=0;vr_Total31202 number :=0;vr_Total35301 number :=0;
  vr_Total35401 number :=0;vr_total number :=0;
  
  BEGIN
  select 
  amt_10100,amt_20100, amt_20300,
  amt_30100, amt_30200, amt_30201, amt_30300, amt_30301, 
  amt_30302, amt_30400, amt_30500, amt_30600, amt_30700, 
  amt_30800, amt_30900, amt_31000, amt_31001, amt_31100, 
  amt_31200, amt_31300, amt_31400, amt_31500, amt_31600, 
  amt_31700, amt_31800, amt_31801, amt_31900, amt_31901, 
  amt_32000, amt_32100, amt_32200, amt_32201, amt_32300, 
  amt_32400, amt_32401, amt_32402, amt_32500, amt_32501, 
  amt_32502, amt_32600, amt_32700, amt_32800, amt_32900, 
  amt_33000, amt_33400, amt_33500, amt_33501, amt_33502, 
  amt_33800, amt_33801, amt_34400, amt_34500, amt_34600, 
  amt_34700, amt_34800, amt_34900, amt_35000, amt_35100,
  amt_35300, amt_35400, amt_35500 , amt_35600 ,amt_35700, 
  amt_35800,amt_32403 ,amt_32404 ,amt_32503, amt_31201,
  amt_30401,amt_30402,amt_31202,amt_35301,amt_35401,
  amt_total
  INTO v_Total10100,v_Total20100, v_Total20300,
  v_Total30100, v_Total30200, v_Total30201, v_Total30300, v_Total30301, 
  v_Total30302, v_Total30400, v_Total30500, v_Total30600, v_Total30700, 
  v_Total30800, v_Total30900, v_Total31000, v_Total31001, v_Total31100, 
  v_Total31200, v_Total31300, v_Total31400, v_Total31500, v_Total31600, 
  v_Total31700, v_Total31800, v_Total31801, v_Total31900, v_Total31901, 
  v_Total32000, v_Total32100, v_Total32200, v_Total32201, v_Total32300, 
  v_Total32400, v_Total32401, v_Total32402, v_Total32500, v_Total32501, 
  v_Total32502, v_Total32600, v_Total32700, v_Total32800, v_Total32900, 
  v_Total33000, v_Total33400, v_Total33500, v_Total33501, v_Total33502, 
  v_Total33800, v_Total33801, v_Total34400, v_Total34500, v_Total34600, 
  v_Total34700, v_Total34800, v_Total34900, v_Total35000, v_Total35100,
  v_Total35300, v_Total35400 ,v_Total35500 ,v_Total35600 ,v_Total35700, 
  v_Total35800, v_Total32403, v_Total32404, v_Total32503, v_Total31201,
  v_Total30401 ,v_Total30402, v_Total31202 ,v_Total35301,v_Total35401,
  v_total
from 
  CUSTOM.CUST_PNL_TEMP_TABLE
where 
  group_type in (groupType1);
  
  select 
  amt_10100,amt_20100, amt_20300,
  amt_30100, amt_30200, amt_30201, amt_30300, amt_30301, 
  amt_30302, amt_30400, amt_30500, amt_30600, amt_30700, 
  amt_30800, amt_30900, amt_31000, amt_31001, amt_31100, 
  amt_31200, amt_31300, amt_31400, amt_31500, amt_31600, 
  amt_31700, amt_31800, amt_31801, amt_31900, amt_31901, 
  amt_32000, amt_32100, amt_32200, amt_32201, amt_32300, 
  amt_32400, amt_32401, amt_32402, amt_32500, amt_32501, 
  amt_32502, amt_32600, amt_32700, amt_32800, amt_32900, 
  amt_33000, amt_33400, amt_33500, amt_33501, amt_33502, 
  amt_33800, amt_33801, amt_34400, amt_34500, amt_34600, 
  amt_34700, amt_34800, amt_34900, amt_35000, amt_35100,
  amt_35300, amt_35400, amt_35500 , amt_35600 ,amt_35700,
  amt_35800,amt_32403 ,amt_32404 ,amt_32503, amt_31201,
  amt_30401,amt_30402,amt_31202,amt_35301,amt_35401,
  amt_total
  INTO v1_Total10100,v1_Total20100, v1_Total20300,
  v1_Total30100, v1_Total30200, v1_Total30201, v1_Total30300, v1_Total30301, 
  v1_Total30302, v1_Total30400, v1_Total30500, v1_Total30600, v1_Total30700, 
  v1_Total30800, v1_Total30900, v1_Total31000, v1_Total31001, v1_Total31100, 
  v1_Total31200, v1_Total31300, v1_Total31400, v1_Total31500, v1_Total31600, 
  v1_Total31700, v1_Total31800, v1_Total31801, v1_Total31900, v1_Total31901, 
  v1_Total32000, v1_Total32100, v1_Total32200, v1_Total32201, v1_Total32300, 
  v1_Total32400, v1_Total32401, v1_Total32402, v1_Total32500, v1_Total32501, 
  v1_Total32502, v1_Total32600, v1_Total32700, v1_Total32800, v1_Total32900, 
  v1_Total33000, v1_Total33400, v1_Total33500, v1_Total33501, v1_Total33502, 
  v1_Total33800, v1_Total33801, v1_Total34400, v1_Total34500, v1_Total34600, 
  v1_Total34700, v1_Total34800, v1_Total34900, v1_Total35000, v1_Total35100, 
  v1_Total35300, v1_Total35400 ,v1_Total35500 ,v1_Total35600 ,v1_Total35700, 
  v1_Total35800, v1_Total32403, v1_Total32404, v1_Total32503, v1_Total31201,
   v1_Total30401 ,v1_Total30402 ,v1_Total31202 ,v1_Total35301 ,v1_Total35401,
  v1_total
from 
  CUSTOM.CUST_PNL_TEMP_TABLE
where 
  group_type in (groupType2);

  vr_Total10100:= v_Total10100 - v1_Total10100;
  vr_Total20100:= v_Total20100 - v1_Total20100;
  vr_Total20300:= v_Total20300 - v1_Total20300;
  vr_Total30100:= v_Total30100 - v1_Total30100;
  vr_Total30200:= v_Total30200 - v1_Total30200;
  vr_Total30201:= v_Total30201 - v1_Total30201;
  vr_Total30300:= v_Total30300 - v1_Total30300;
  vr_Total30301:= v_Total30301 - v1_Total30301;
  vr_Total30302:= v_Total30302 - v1_Total30302;
  vr_Total30400:= v_Total30400 - v1_Total30400;
  vr_Total30500:= v_Total30500 - v1_Total30500;
  vr_Total30600:= v_Total30600 - v1_Total30600;
  vr_Total30700:= v_Total30700 - v1_Total30700;
  vr_Total30800:= v_Total30800 - v1_Total30800;
  vr_Total30900:= v_Total30900 - v1_Total30900;
  vr_Total31000:= v_Total31000 - v1_Total31000;
  vr_Total31001:= v_Total31001 - v1_Total31001;
  vr_Total31100:= v_Total31100 - v1_Total31100;
  vr_Total31200:= v_Total31200 - v1_Total31200;
  vr_Total31300:= v_Total31300 - v1_Total31300;
  vr_Total31400:= v_Total31400 - v1_Total31400;
  vr_Total31500:= v_Total31400 - v1_Total31500;
  vr_Total31600:= v_Total31600 - v1_Total31600;
  vr_Total31700:= v_Total31700 - v1_Total31700;
  vr_Total31800:= v_Total31800 - v1_Total31800;
  vr_Total31801:= v_Total31801 - v1_Total31801;
  vr_Total31900:= v_Total31900 - v1_Total31900;
  vr_Total31901:= v_Total31901 - v1_Total31901;
  vr_Total32000:= v_Total32000 - v1_Total32000;
  vr_Total32100:= v_Total32100 - v1_Total32100;
  vr_Total32200:= v_Total32200 - v1_Total32200;
  vr_Total32201:= v_Total32201 - v1_Total32201;
  vr_Total32300:= v_Total32300 - v1_Total32300;
  vr_Total32400:= v_Total32400 - v1_Total32400;
  vr_Total32401:= v_Total32401 - v1_Total32401;
  vr_Total32402:= v_Total32402 - v1_Total32402;
  vr_Total32500:= v_Total32500 - v1_Total32500;
  vr_Total32501:= v_Total32501 - v1_Total32501;
  vr_Total32502:= v_Total32502 - v1_Total32502;
  vr_Total32600:= v_Total32600 - v1_Total32600;
  vr_Total32700:= v_Total32700 - v1_Total32700;
  vr_Total32800:= v_Total32800 - v1_Total32800;
  vr_Total32900:= v_Total32900 - v1_Total32900;
  vr_Total33000:= v_Total33000 - v1_Total33000;
  vr_Total33400:= v_Total33400 - v1_Total33400;
  vr_Total33500:= v_Total33500 - v1_Total33500;
  vr_Total33501:= v_Total33501 - v1_Total33501;
  vr_Total33502:= v_Total33502 - v1_Total33502;
  vr_Total33800:= v_Total33800 - v1_Total33800;
  vr_Total33801:= v_Total33801 - v1_Total33801;
  vr_Total34400:= v_Total34400 - v1_Total34400;
  vr_Total34500:= v_Total34500 - v1_Total34500;
  vr_Total34600:= v_Total34600 - v1_Total34600;
  vr_Total34700:= v_Total34700 - v1_Total34700;
  vr_Total34800:= v_Total34800 - v1_Total34800;
  vr_Total35000:= v_Total35000 - v1_Total35000;
  vr_Total35100:= v_Total35100 - v1_Total35100;  
  vr_Total35300:= v_Total35300 - v1_Total35300;
  vr_Total35400:= v_Total35400 - v1_Total35400;
  vr_Total35500:= v_Total35500 - v1_Total35500;
  vr_Total35600:= v_Total35600 - v1_Total35600;
  vr_Total35700:= v_Total35700 - v1_Total35700;
  vr_Total35800:= v_Total35800 - v1_Total35800;
  vr_Total32403:= v_Total35100 - v1_Total35100;
  vr_Total32404:= v_Total32404 - v1_Total32404;
  vr_Total32503:= v_Total32503 - v1_Total32503;
  vr_Total31201:= v_Total31201 - v1_Total31201;
  vr_Total30401 :=v_Total30401 -v1_Total30401; 
  vr_Total30402 :=v_Total30402 -v1_Total30402;
  vr_Total31202 :=v_Total31202 - v1_Total31202;
  vr_Total35301 :=v_Total35301 - v1_Total35301; 
  vr_Total35401 :=v_Total35401 - v1_Total35401;
  vr_total:= v_total - v1_total;

  insert into custom.CUST_PNL_TEMP_TABLE 
    values ('', title, title,tID,vr_Total10100,vr_Total20100, vr_Total20300,
  vr_Total30100, vr_Total30200, vr_Total30201, vr_Total30300, vr_Total30301, 
  vr_Total30302, vr_Total30400, vr_Total30500, vr_Total30600, vr_Total30700, 
  vr_Total30800, vr_Total30900, vr_Total31000, vr_Total31001, vr_Total31100, 
  vr_Total31200, vr_Total31300, vr_Total31400, vr_Total31500, vr_Total31600, 
  vr_Total31700, vr_Total31800, vr_Total31801, vr_Total31900, vr_Total31901, 
  vr_Total32000, vr_Total32100, vr_Total32200, vr_Total32201, vr_Total32300, 
  vr_Total32400, vr_Total32401, vr_Total32402, vr_Total32500, vr_Total32501, 
  vr_Total32502, vr_Total32600, vr_Total32700, vr_Total32800, vr_Total32900, 
  vr_Total33000, vr_Total33400, vr_Total33500, vr_Total33501, vr_Total33502, 
  vr_Total33800, vr_Total33801, vr_Total34400, vr_Total34500, vr_Total34600, 
  vr_Total34700, vr_Total34800, vr_Total34900, vr_Total35000, vr_Total35100,
   vr_Total35300,vr_Total35400,vr_Total35500, vr_Total35600,vr_Total35700,
   vr_Total35800,vr_Total32403,vr_Total32404,vr_Total32503,vr_Total31201,
   vr_Total30401 ,vr_Total30402 ,vr_Total31202 ,vr_Total35301 ,vr_Total35401,
    vr_total );
    commit;
  
    RETURN v_returnValue;
  END FUNC_EIGHT;
  
    
  PROCEDURE FIN_PNL_MONTHLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ) IS
      
      branch_list f_b_list;  
      solId_list f_sol_list;        
      
      v_result sab_list;-- VARCHAR2(2000);
      v_description CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE;
      v_g1ReturnValue BOOLEAN;
      
      v_num varchar2(20);
      v_accountName varchar2(200);
      V_AMT_10100 number := 0;
      V_AMT_20100 number := 0;
      V_AMT_20300 number := 0;
      V_AMT_30100 number := 0;
      V_AMT_30200 number := 0;
      V_AMT_30201 number := 0;
      V_AMT_30300 number := 0;
      V_AMT_30301 number := 0;
      V_AMT_30302 number := 0;
      V_AMT_30400 number := 0;
      V_AMT_30500 number := 0;
      V_AMT_30600 number := 0;
      V_AMT_30700 number := 0;
      V_AMT_30800 number := 0;
      V_AMT_30900 number := 0;
      V_AMT_31000 number := 0;
      V_AMT_31001 number := 0;
      V_AMT_31100 number := 0;
      V_AMT_31200 number := 0;
      V_AMT_31300 number := 0;
      V_AMT_31400 number := 0;
      V_AMT_31500 number := 0;
      V_AMT_31600 number := 0;
      V_AMT_31700 number := 0;
      V_AMT_31800 number := 0;
      V_AMT_31801 number := 0;
      V_AMT_31900 number := 0;
      V_AMT_31901 number := 0;
      V_AMT_32000 number := 0;
      V_AMT_32100 number := 0;
      V_AMT_32200 number := 0;
      V_AMT_32201 number := 0;
      V_AMT_32300 number := 0;
      V_AMT_32400 number := 0;
      V_AMT_32401 number := 0;
      V_AMT_32402 number := 0;
      V_AMT_32500 number := 0;
      V_AMT_32501 number := 0;
      V_AMT_32502 number := 0;
      V_AMT_32600 number := 0;
      V_AMT_32700 number := 0;
      V_AMT_32800 number := 0;
      V_AMT_32900 number := 0;
      V_AMT_33000 number := 0;
      V_AMT_33400 number := 0;
      V_AMT_33500 number := 0;
      V_AMT_33501 number := 0;
      V_AMT_33502 number := 0;
      V_AMT_33800 number := 0;
      V_AMT_33801 number := 0;
      V_AMT_34400 number := 0;
      V_AMT_34500 number := 0;
      V_AMT_34600 number := 0;
      V_AMT_34700 number := 0;
      V_AMT_34800 number := 0;
      V_AMT_34900 number := 0;
      V_AMT_35000 number := 0;
      V_AMT_35100 number := 0;
      V_AMT_35300 number := 0;
      V_AMT_35400 number := 0;
      V_AMT_35500 number := 0;
      V_AMT_35600 number := 0;
      V_AMT_35700 number := 0;
      V_AMT_35800 number := 0;
      V_AMT_32403 number := 0;
      V_AMT_32404 number := 0;
      V_AMT_32503 number := 0;
      V_AMT_31201 number := 0;
      V_AMT_30401 number := 0;
      V_AMT_30402 number := 0;
      V_AMT_31202 number := 0;
      V_AMT_35301 number := 0;
      V_AMT_35401 number := 0;
      V_AMT_TOTAL number := 0;
      
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
    
    vi_estimateDate:=outArr(0);
   -----------------------------------------------------------------------------------------------------------------
   
   
if( vi_estimateDate is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || 0 || '|' || 
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
				   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
				     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
					   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
					     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
						   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
						     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
							   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
							     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
								   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
								     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
									   0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||
									     0 || '|' || 0 || '|' || 0 || '|' || 0|| '|' ||  0 || '|' || 0 || '|' ||
                       0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0);
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

   
   
   ------------------------------------------------------------------------------------------------------------------
-------------------------------40002--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_INVES');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_INVES');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  delete from CUSTOM.CUST_PNL_TEMP_TABLE;
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Income A/C', 'GROUP_1',1,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('1', v_result, 
  v_description,'GROUP_1',2);
-------------------------------40016--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('2', v_description, v_result, 'GROUP_1',3);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('2', v_result, v_description,'GROUP_1',3);
-------------------------------40011--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('3', 'Interest on loans advance & overdraft', 'GROUP_1',4,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('', v_description, v_result, 'GROUP_1',5);
  --commit; 
  v_g1ReturnValue := FUNC_FIVE('',v_result, 
  v_description,'GROUP_1',5);
-------------------------------40012--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_OVERDRAFT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_OVERDRAFT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('', v_description, v_result, 'GROUP_1',6);
  --commit; 
  v_g1ReturnValue := FUNC_FIVE('',v_result, 
  v_description,'GROUP_1',6);
-------------------------------40015--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_STAFF_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_STAFF_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('', v_description, v_result, 'GROUP_1',7);
  --commit; 
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_1',7);
-------------------------------40021--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('REN_CHR_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REN_CHR_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('4', v_description, v_result, 'GROUP_1',8);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('4', v_result, 
  v_description,'GROUP_1',8);
-------------------------------40003--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_DEPOSIT_AUT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_DEPOSIT_AUT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('5', v_description, v_result, 'GROUP_1',9);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('5', v_result, 
  v_description,'GROUP_1',9);
-------------------------------40004--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_MIS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_MIS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('6', v_description, v_result, 'GROUP_1',10);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('6', v_result, 
  v_description,'GROUP_1',10);
-------------------------------40014--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('INT_OTH_ADV');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_OTH_ADV');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('7', v_description, v_result, 'GROUP_1',11);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('7', v_result, 
  v_description,'GROUP_1',11);
------------------------------GROUP_1_TOTOAL------------------------------------
  v_g1ReturnValue := FUNC_SIX( 'Total interest income ', 'GROUP_1', 12);
-------------------------------50101--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SAVE_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SAVE_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Interest expenses', 'GROUP_2',13,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  --insert into custom.CUST_PNL_TEMP_TABLE 
  --values ('1', v_description, v_result, 'GROUP_1',2);
  --commit;
  v_g1ReturnValue := FUNC_FIVE('1', v_result, 
  v_description,'GROUP_2',14);
-------------------------------50103--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SPEC_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SPEC_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('2', v_result, 
  v_description,'GROUP_2',15);
-------------------------------50104--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FIX_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIX_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('3', v_result, 
  v_description,'GROUP_2',16);
-------------------------------50104--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ATM_DEBIT_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_DEBIT_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('4', v_result, 
  v_description,'GROUP_2',17);
-------------------------------50105--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BOR_FRM_CBM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BOR_FRM_CBM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('5', v_result, 
  v_description,'GROUP_2',18);
------------------------------GROUP_2_TOTOAL------------------------------------
  v_g1ReturnValue := FUNC_SIX('Total interest expenses' , 'GROUP_2', 19);
-------------------------------40031--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_INT_REMT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Other income', 'GROUP_3',20,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('1', 'Exchange transaction', 'GROUP_3',21,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',22);
-------------------------------40032--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_INT_REMT_LINK');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT_LINK');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',23);
-------------------------------40033--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_OTH_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_OTH_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',24);
-------------------------------40101--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_FORE_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_FORE_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',25);
-------------------------------40034--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_ON_ATM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_ON_ATM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',26);
-------------------------------40060--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SER_COM_CHR_EBK');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_COM_CHR_EBK');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('2', 'Other commission & service charges  ', 'GROUP_3',27,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',28);
-------------------------------40045--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_SER_COM_CHR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_SER_COM_CHR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',29);
-------------------------------40052--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COM_CER_CHEQ');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_CER_CHEQ');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',30);
-------------------------------40042--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COM_CRE_GUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_CRE_GUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',31);
-------------------------------40049--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COM_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('3', v_result, 
  v_description,'GROUP_3',32);
-------------------------------40102--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COM_FORE_CUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_FORE_CUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('4', 'Comission on Foreign Currency', 'GROUP_3',33,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',34);
-------------------------------40104--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('WORKER_REM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('WORKER_REM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',35);
-------------------------------40050--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SER_CHRG_LOAN_OD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_CHRG_LOAN_OD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('5', v_result, 
  v_description,'GROUP_3',36);
-------------------------------40056--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('IN_SER_CHRG_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('IN_SER_CHRG_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('6', 'Service charges and late fees on Hire Purchase', 'GROUP_3',37,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',38);
-------------------------------40057--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('IN_LATE_FEE_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('IN_LATE_FEE_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',39);
-------------------------------40058--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LATE_FEE_STAFF_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LATE_FEE_STAFF_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',40);
-------------------------------40103--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SER_CHRG_FE_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_CHRG_FE_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('7', 'Service charges on foreign transaction', 'GROUP_3',41,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',42);
-------------------------------40051--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_CHRG_LOAN_OD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_CHRG_LOAN_OD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('8', v_result, 
  v_description,'GROUP_3',43);
-------------------------------40041--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('9', v_result, 
  v_description,'GROUP_3',44);
-------------------------------10301--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SALES_PROC_1');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SALES_PROC_1');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('10', v_result, 
  v_description,'GROUP_3',45);
-------------------------------40091--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DIS_INV_IN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIS_INV_IN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('11', v_result, 
  v_description,'GROUP_3',46);
-------------------------------40111--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('RENT_IN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('RENT_IN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('12', v_result, 
  v_description,'GROUP_3',47);
-------------------------------40071--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COST_CRE_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COST_CRE_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('13', 'Miscellaneous', 'GROUP_3',48,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',49);
-------------------------------40072--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ANN_FEE_CRE_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANN_FEE_CRE_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',50);
-------------------------------40073--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FEE_LATE_SET_CR_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FEE_LATE_SET_CR_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',51);
-------------------------------40082--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_ITEMS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ITEMS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',52);
-------------------------------40074--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ANN_FEE_ATM_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANN_FEE_ATM_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',53);
-------------------------------40075--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ATM_NEW_CARD_ISSE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_NEW_CARD_ISSE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',54);
-------------------------------40081--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FEE_ONLINE_PAY_BILL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FEE_ONLINE_PAY_BILL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',55);
-------------------------------40076--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ATM_CARD_DEPT_REC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_CARD_DEPT_REC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_3',56);
------------------------------Total other income -------------------------------
  v_g1ReturnValue := FUNC_SIX('Total other income ', 'GROUP_3', 57);
------------------------------Total income -------------------------------------
  v_g1ReturnValue := FUNC_SEVEN('Total income', 'GROUP_1',
  'GROUP_3', 58);
----------------------------Total net income ------------------------------------
  v_g1ReturnValue := FUNC_EIGHT('Total net income', 'Total income',
  'GROUP_2_TOTAL', 59);
-------------------------------50121--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('REMTT_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REMTT_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Expenditure A/C', 'GROUP_4',60,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('1', 'Currency Expenses', 'GROUP_4',61,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',62);
-------------------------------50122--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TRPT_HAN_CHRG');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_HAN_CHRG');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',63);
-------------------------------50123--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_INT_REMT_CUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT_CUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',64);
-------------------------------50131--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LEG_EXP_STAMP_DUTY');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEG_EXP_STAMP_DUTY');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('2', 'Legal Expenses And Stamp Duty', 'GROUP_4',65,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',66);
-------------------------------50141--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_CRE_GUARA');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_CRE_GUARA');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('3', 'Commission Expense', 'GROUP_4',67,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',68);
-------------------------------50142--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_BILL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_BILL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',69);
-------------------------------50143--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_SALE_PUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_SALE_PUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',70);
-------------------------------50144--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMM_PAID_OTH_SER');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_PAID_OTH_SER');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',71);
-------------------------------50145--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_COMM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_COMM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',72);
-------------------------------50161--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('STAFF_SALARY');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_SALARY');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('4', 'Salaries and Benefits', 'GROUP_4',73,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',74);
-------------------------------50162--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('MEAL_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',75);
-------------------------------50163--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OT_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OT_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',76);
-------------------------------50164--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('UNI_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('UNI_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',77);
-------------------------------50165--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('HOUSE_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HOUSE_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',78);
-------------------------------50166--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TECH_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TECH_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',79);
-------------------------------50167--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SPEC_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SPEC_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',80);
-------------------------------50168--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TRPT_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',81);
-------------------------------50169--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('MED_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MED_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',82);
-------------------------------50170--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('STAFF_WALFARE_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_WALFARE_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',83);
-------------------------------50171--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('STAFF_WALFARE_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_WALFARE_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',84);
-------------------------------50172--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('STAFF_IN_TAX_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_IN_TAX_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',85);
-------------------------------50173--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('STAFF_SOC_SEC_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_SOC_SEC_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',86);
-------------------------------50177--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DAILY_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DAILY_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',87);
-------------------------------50174--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BONUS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BONUS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',88);
-------------------------------50175--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('PROV_FUN_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PROV_FUN_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',89);
-------------------------------50176--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COST_LIV_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COST_LIV_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',90);
-------------------------------50178--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',91);
-------------------------------50191--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BUILD_GODOWN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_GODOWN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('5', 'Rent', 'GROUP_4',92,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',93);
-------------------------------50192--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('HIRE_MECH_ELEC_EQUP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HIRE_MECH_ELEC_EQUP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',94);
-------------------------------50193--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CAR_RENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_RENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',95);
-------------------------------50195--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_RENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_RENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',96);
-------------------------------50201--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TELE_FAX_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TELE_FAX_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('6', 'Telephone', 'GROUP_4',97,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',98);
-------------------------------50202--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COMMU_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMMU_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',99);
-------------------------------50211--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('POL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('7', 'Travel and Entertainment', 'GROUP_4',100,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',101);
-------------------------------50211--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('POL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',102);
-------------------------------50212--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('HOTEL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HOTEL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',103);
-------------------------------50213--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TRPT_TRAVEL_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_TRAVEL_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',104);
-------------------------------50214--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('PER_DIEM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PER_DIEM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',105);
-------------------------------50215--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_TRAVEL_ENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_TRAVEL_ENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',106);
-------------------------------50216--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ENTERTAINMENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ENTERTAINMENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',107);
-------------------------------50231--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DIR_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIR_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('8', 'Professional Fees', 'GROUP_4',108,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',109);
-------------------------------50232--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('AUDITOR_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('AUDITOR_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',110);
-------------------------------50233--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LEGAL_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEGAL_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',111);
-------------------------------50234--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('TRAIN_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRAIN_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',112);
-------------------------------50235--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ANNUAL_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANNUAL_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',113);
-------------------------------50236--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_ITEM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ITEM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',114);
-------------------------------50237--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('HONO_LEC_ADV');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HONO_LEC_ADV');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',115);
-------------------------------50238--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_HONO');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_HONO');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',116);
-------------------------------50251--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BUILD_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('9', 'Insurance', 'GROUP_4',117,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',118);
-------------------------------50252--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OFFI_MECH_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFFI_MECH_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',119);
-------------------------------50253--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FUR_FIX_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',120);
-------------------------------50254--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ELEC_COMP_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_COMP_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',121);
-------------------------------50255--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CAR_CYCLE_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',122);
-------------------------------50256--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CASH_TRANSIT_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CASH_TRANSIT_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',123);
-------------------------------50257--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CASH_VAULT_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CASH_VAULT_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',124);
-------------------------------50258--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FIE_BOND_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIE_BOND_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',125);
-------------------------------50259--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FIRE_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIRE_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',126);
-------------------------------50260--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',127);
-------------------------------50271--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('PRO_EVE_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PRO_EVE_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('10', 'Sales and Marketing Exp', 'GROUP_4',128,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',129);
-------------------------------50272--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ADVERTISTING');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ADVERTISTING');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',130);
-------------------------------50273--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('GIFT_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',131);
-------------------------------50273--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('GIFT_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',132);
-------------------------------50274--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('MEAL_ALLOW_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',133);
-------------------------------50275--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('MEAL_ALLOW_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',134);
-------------------------------50281--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LAND_BUILD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LAND_BUILD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('11', 'Repairs and Maintenance Expense', 'GROUP_4',135,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',136);
-------------------------------50282--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OFF_MECH_OTH_MECH');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFF_MECH_OTH_MECH');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',137);
-------------------------------50283--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FUR_FIX_FIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_FIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',138);
-------------------------------50284--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ELEC_ACCESS_COM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_ACCESS_COM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',139);
-------------------------------50285--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CAR_CYCLE_REP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_REP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',140);
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Other Maintainance and Repair', 'GROUP_4',141,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
-------------------------------50291--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('PRI_STA_OFF_SUP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PRI_STA_OFF_SUP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('12', 'Supply and Services', 'GROUP_4',142,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',143);
-------------------------------50292--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('POSTAGE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POSTAGE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',144);
-------------------------------50293--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SER_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',145);
-------------------------------50301--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LICENCE_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LICENCE_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('13', 'Rate and Tax', 'GROUP_4',146,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',147);
-------------------------------50301--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('REG_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REG_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',148);
-------------------------------50303--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('YCDC_TAX');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('YCDC_TAX');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',149);
-------------------------------50304--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('COM_ACC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_ACC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',150);
-------------------------------50305--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_RATE_TAX');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_RATE_TAX');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',151);
-------------------------------50306--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LIGHT_PWR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LIGHT_PWR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',152);
-------------------------------50311--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BOOK_NEWPAPER');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BOOK_NEWPAPER');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('14', 'Other', 'GROUP_4',153,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',154);
-------------------------------50312--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DONATION');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DONATION');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',155);
-------------------------------50313--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('GIFT_REWARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_REWARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',156);
-------------------------------50314--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_MISC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_MISC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',157);
-------------------------------50315--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('WAGES');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('WAGES');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',158);
-------------------------------50321--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('BUILD_DEPRE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_DEPRE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('15', 'Deprecitaion', 'GROUP_4',159,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',160);
-------------------------------50322--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OFF_OTH_MECH_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFF_OTH_MECH_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',161);
-------------------------------50323--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FUR_FIX_FIT_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_FIT_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',162);
-------------------------------50324--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ELEC_COM_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_COM_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',163);
-------------------------------50325--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('CAR_CYCLE_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',164);
-------------------------------50326--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('LEASE_IMP_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEASE_IMP_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',165);
	insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Amortization', 'GROUP_4',166,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
-------------------------------50341--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('SW_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SW_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',167);
-------------------------------50342--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('NETWORK_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('NETWORK_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',168);
-------------------------------50352--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('FIX_ASSET');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIX_ASSET');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('16', 'Loss & Write Off', 'GROUP_4',169,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Loans and Advences', 'GROUP_4',170,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',171);
-------------------------------50353--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DEFER_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DEFER_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',172);
-------------------------------50354--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('OTH_LOSS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_LOSS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',173);
-------------------------------50361--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('DIS_BILL_BOND');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIS_BILL_BOND');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('17', 'Discount  Expense', 'GROUP_4',174,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',175);
-------------------------------50361--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_REVALUE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_REVALUE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('18', 'Foreign Currency Gain/(loss)', 'GROUP_4',176,'','', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','','','','','','','','','','','','','','');
  commit;
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',177);
-------------------------------50361--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  branch_list := FUNC_TWO('ECH_FORE_TRANS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_FORE_TRANS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(solId_list, branch_list);
--------------------------------------------------------------------------------
  v_g1ReturnValue := FUNC_FIVE('', v_result, 
  v_description,'GROUP_4',178);
------------------------------GROUP_4_TOTAL------------------------------------
  v_g1ReturnValue := FUNC_SIX( 'Total other expenses', 'GROUP_4', 179);
  v_g1ReturnValue := FUNC_SEVEN('Total expenses', 'GROUP_4',
  'GROUP_2', 180);
  v_g1ReturnValue := FUNC_EIGHT('Excess of expenditure over income',
  'Total income', 'Total expenses', 181);
      
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
			INTO	 v_num, v_accountName, V_AMT_10100,V_AMT_20100,V_AMT_20300,
      V_AMT_30100,V_AMT_30200,V_AMT_30201,V_AMT_30300,V_AMT_30301,V_AMT_30302,V_AMT_30400,
      V_AMT_30500,V_AMT_30600,V_AMT_30700,V_AMT_30800,V_AMT_30900,V_AMT_31000,V_AMT_31001,
      V_AMT_31100,V_AMT_31200,V_AMT_31300,V_AMT_31400,V_AMT_31500,V_AMT_31600,V_AMT_31700,
      V_AMT_31800,V_AMT_31801,V_AMT_31900,V_AMT_31901,V_AMT_32000,V_AMT_32100,V_AMT_32200,
      V_AMT_32201,V_AMT_32300,V_AMT_32400,V_AMT_32401,V_AMT_32402,V_AMT_32500,V_AMT_32501,
      V_AMT_32502,V_AMT_32600,V_AMT_32700,V_AMT_32800,V_AMT_32900,V_AMT_33000,V_AMT_33400,
      V_AMT_33500,V_AMT_33501,V_AMT_33502,V_AMT_33800,V_AMT_33801,V_AMT_34400,V_AMT_34500,
      V_AMT_34600,V_AMT_34700,V_AMT_34800,V_AMT_34900,V_AMT_35000,V_AMT_35100,
      V_AMT_35300 ,V_AMT_35400 ,V_AMT_35500 ,V_AMT_35600 ,V_AMT_35700 ,V_AMT_35800 ,
      V_AMT_32403,V_AMT_32404 ,V_AMT_32503,V_AMT_31201, 
      V_AMT_30401,V_AMT_30402,V_AMT_31202,V_AMT_35301,V_AMT_35401,
      V_AMT_TOTAL;
      

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
    
    out_rec:=	(v_num|| '|' || v_accountName|| '|' || V_AMT_10100|| '|' ||
    V_AMT_20100|| '|' ||V_AMT_20300|| '|' ||V_AMT_30100|| '|' ||V_AMT_30200|| '|' ||
    V_AMT_30201|| '|' ||V_AMT_30300|| '|' ||V_AMT_30301|| '|' ||V_AMT_30302|| '|' ||
    V_AMT_30400|| '|' ||V_AMT_30500|| '|' ||V_AMT_30600|| '|' ||V_AMT_30700|| '|' ||
    V_AMT_30800|| '|' ||V_AMT_30900|| '|' ||V_AMT_31000|| '|' ||V_AMT_31001|| '|' ||
    V_AMT_31100|| '|' ||V_AMT_31200|| '|' ||V_AMT_31300|| '|' ||V_AMT_31400|| '|' ||
    V_AMT_31500|| '|' ||V_AMT_31600|| '|' ||V_AMT_31700|| '|' ||V_AMT_31800|| '|' ||
    V_AMT_31801|| '|' ||V_AMT_31900|| '|' ||V_AMT_31901|| '|' ||V_AMT_32000|| '|' ||
    V_AMT_32100|| '|' ||V_AMT_32200|| '|' ||V_AMT_32201|| '|' ||V_AMT_32300|| '|' ||
    V_AMT_32400|| '|' ||V_AMT_32401|| '|' ||V_AMT_32402|| '|' ||V_AMT_32500|| '|' ||
    V_AMT_32501|| '|' ||V_AMT_32502|| '|' ||V_AMT_32600|| '|' ||V_AMT_32700|| '|' ||
    V_AMT_32800|| '|' ||V_AMT_32900|| '|' ||V_AMT_33000|| '|' ||V_AMT_33400|| '|' ||
    V_AMT_33500|| '|' ||V_AMT_33501|| '|' ||V_AMT_33502|| '|' ||V_AMT_33800|| '|' ||
    V_AMT_33801|| '|' ||V_AMT_34400|| '|' ||V_AMT_34500|| '|' ||V_AMT_34600|| '|' ||
    V_AMT_34700|| '|' ||V_AMT_34800|| '|' ||V_AMT_34900|| '|' ||V_AMT_35000|| '|' ||
    V_AMT_35100|| '|' ||V_AMT_35300 || '|' ||V_AMT_35400 || '|' ||V_AMT_35500 || '|' ||
    V_AMT_35600 || '|' ||V_AMT_35700 || '|' ||V_AMT_35800 || '|' ||V_AMT_32403 || '|' ||
    V_AMT_32404 || '|' ||V_AMT_32503 || '|' ||V_AMT_31201 || '|' ||  V_AMT_30401|| '|' || 
    V_AMT_30402 || '|' ||V_AMT_31202|| '|' || V_AMT_35301|| '|' ||V_AMT_35401|| '|' ||
    V_AMT_TOTAL);
    
    dbms_output.put_line(out_rec);
  END FIN_PNL_MONTHLY;
END FIN_PNL_MONTHLY;
/
