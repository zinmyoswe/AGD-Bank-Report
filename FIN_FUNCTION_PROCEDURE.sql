CREATE OR REPLACE PACKAGE        FIN_FUNCTION_PROCEDURE AS 
  subtype limited_string_1 is varchar2(350);
  subtype limited_string_2 is varchar2(2000);
  type b_list is varray(58) of VARCHAR2(50);
  type sol_list is varray(58) of VARCHAR2(50);
  PROCEDURE FIN_PNL_MONTHLY_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string_1 );

   FUNCTION TEMP (solId_list_1 sol_list, branch_list_1 b_list) 
      RETURN limited_string_2; 

END FIN_FUNCTION_PROCEDURE;
 
/


CREATE OR REPLACE PACKAGE BODY               FIN_FUNCTION_PROCEDURE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_estimateDate		Varchar2(20);		    	     -- Input to procedure

  PROCEDURE FIN_PNL_MONTHLY_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string_1 ) IS
      
      v_solId VARCHAR2(350);
      v_solIdAndAmt VARCHAR2(2000);
      v_glSubHeadCode TBAADM.GL_SUB_HEAD_TRAN_TABLE.GL_SUB_HEAD_CODE%TYPE;
      v_description_40002 CUSTOM.CUST_RPTCUST_PARAM_PNLT.DESCRIPTION%TYPE;
      type b_list is varray(58) of VARCHAR2(50);
      branch_list b_list := b_list();
      counter integer := 0;
      type sol_list is varray(58) of VARCHAR2(50);
      solId_list sol_list := sol_list();
      i integer := 0;
      v_solAndAmount_40002 VARCHAR2(2000);
      
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
        solId_list.extend;
        solId_list(i) := x.SOL_ID;
        v_solId := x.SOL_ID ||'|'|| v_solId;
     END LOOP;
     dbms_output.put_line(SUBSTR(v_solId, 1, LENGTH(v_solId) - 1));
     --dbms_output.put_line(v_solId);
-------------------------------------------------------------------------------
  FOR x IN (select
    gstt.SOL_ID, 
    gstt.GL_SUB_HEAD_CODE , 
    case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
    then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
    else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total,  
    gstt.CRNCY_CODE 
  from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_PARAM_PNLT RPT
  where to_char(tbaadm.gstt.bal_date,'MM-YYYY') = to_char(to_date(cast
  ('16-09-2016' as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
  and gstt.GL_SUB_HEAD_CODE = RPT.VARIABLE_VALUE
  and RPT.VARIABLE_NAME IN ('INT_INVES')
  AND RPT.BANK_ID = '01'
  AND RPT.MODULE_NAME = 'REPORT'
  AND RPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  GROUP BY gstt.SOL_ID,gstt.GL_SUB_HEAD_CODE, gstt.CRNCY_CODE, RPT.DESCRIPTION
  ORDER BY gstt.GL_SUB_HEAD_CODE) 
  LOOP
    counter := counter + 1;
    branch_list.extend;
    branch_list(counter) := x.SOL_ID ||','|| x.total;
    v_glSubHeadCode := x.GL_SUB_HEAD_CODE;
    v_solIdAndAmt := branch_list(counter) ||'|'|| v_solIdAndAmt;
  END LOOP;
  select DESCRIPTION 
        into v_description_40002
        from CUSTOM.CUST_RPTCUST_PARAM_PNLT
        where VARIABLE_NAME IN ('INT_INVES')
        AND BANK_ID = '01'
        AND MODULE_NAME = 'REPORT'
        AND SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE';
        
        v_solAndAmount_40002 := TEMP (solId_list, branch_list);
-------------------------------------------------------------------------------        
    
-------------------------------------------------------------------------------
  /*insert into custom.CUST_PNL_TEMP_TABLE 
  values ('', 'Income A/C', '', 'GROUP_1',1);
  commit;
  insert into custom.CUST_PNL_TEMP_TABLE 
  values ('1', v_description_40002, v_SOL_ID_AND_AMT, 'GROUP_1',2);
  commit;*/ 
-------------------------------------------------------------------------------
    END;
  END FIN_PNL_MONTHLY_SPBX;

  FUNCTION TEMP (solId_list_1 sol_list, branch_list_1 b_list) 
      RETURN limited_string_2 IS
      
      type sab_list is varray(58) of VARCHAR2(50);
      solIdAndBalance_list sab_list := sab_list();
      solIdTotal integer;
      branchTotal integer;
      temp_1 VARCHAR2(10);
      temp_2 VARCHAR2(20);
      flash boolean := false;
      solIdAndBalanceTotal integer;
      v_solIdAndAmtFinal VARCHAR2(2000);
      v_result VARCHAR2(2000);
      
  BEGIN
   solIdTotal := solId_list_1.count;
    FOR y IN 1.. solIdTotal
    LOOP
      solIdAndBalance_list.extend;
      branchTotal := branch_list_1.count;
       FOR z IN 1.. branchTotal
         LOOP
            temp_1 := regexp_substr(branch_list_1(z), '[^,]+', 1, 1);
            if solId_list_1(y) = temp_1 then
                flash := true;
                temp_2 := branch_list_1(z);
                exit;
            end if;
         END LOOP;
         if flash  then 
          solIdAndBalance_list(y) := temp_2;
          flash := false;
         else
          solIdAndBalance_list(y) := '-,-';
         end if;
         dbms_output.put_line('Branch | Amount('||y ||'):'||solIdAndBalance_list(y));
    END LOOP;
    
    solIdAndBalanceTotal := solIdAndBalance_list.count;
    FOR x IN 1.. solIdAndBalanceTotal
    LOOP
      v_solIdAndAmtFinal := solIdAndBalance_list(x) ||'|'|| v_solIdAndAmtFinal;
    END LOOP;
    v_result := SUBSTR(v_solIdAndAmtFinal, 1, 
    LENGTH(v_solIdAndAmtFinal) - 1);
    RETURN v_result;
  END TEMP;

END FIN_FUNCTION_PROCEDURE;
/
