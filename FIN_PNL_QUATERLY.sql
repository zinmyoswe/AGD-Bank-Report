CREATE OR REPLACE PACKAGE        FIN_PNL_QUATERLY AS 

  subtype limited_string is varchar2(350);
  PROCEDURE FIN_PNL_QUATERLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ); 

END FIN_PNL_QUATERLY;
 
/


CREATE OR REPLACE PACKAGE BODY                                                         FIN_PNL_QUATERLY AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_startMonth		Varchar2(20);		    	     -- Input to procedure
  vi_endMonth		  Varchar2(20);		    	     -- Input to procedure
  vi_year     		Varchar2(20);		    	     -- Input to procedure

  TYPE f_month_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE f_mab_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  CURSOR ExtractData
  IS
  SELECT 
    NO, ACCOUNT_NAME, AMT_JAN,AMT_FEB,AMT_MARCH,AMT_APRIL,
    AMT_MAY,AMT_JUNE,AMT_JULY,AMT_AUGUST,AMT_SEP,AMT_OCT,AMT_NOV,
    AMT_DEC,AMT_TOTAL
  FROM CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE
  ORDER BY ID;
--------------------------------------------------------------------------------  
  FUNCTION FUNC_ONE(f_month_list f_month_list) 
  RETURN f_mab_list AS
  
    TYPE month_list IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    m_list month_list;
    
    monthTotal integer;
    monthAndBalance_list f_mab_list;
    f_monthTotal integer;
    temp_1 VARCHAR2(10);
    temp_2 VARCHAR2(2000);
    flash boolean := false;
    
    begin
      m_list(1) := 'January';
      m_list(2) := 'Febuary';
      m_list(3) := 'March';
      m_list(4) := 'April';
      m_list(5) := 'May';
      m_list(6) := 'June';
      m_list(7) := 'July';
      m_list(8) := 'August';
      m_list(9) := 'September';
      m_list(10) := 'October';
      m_list(11) := 'November';
      m_list(12) := 'December';
      monthTotal := m_list.count;
    FOR y IN 1.. m_list.count
    LOOP
      f_monthTotal := f_month_list.count;
       FOR z IN 1.. f_monthTotal
         LOOP
            temp_1 := regexp_substr(f_month_list(z), '[^,]+', 1, 1);
            if m_list(y) = temp_1 then
                flash := true;
                temp_2 := f_month_list(z);
                exit;
            end if;
         END LOOP;
         if flash  then 
          monthAndBalance_list(y) := temp_2;
          flash := false;
         else
          monthAndBalance_list(y) := m_list(y)||',0.00';
         end if;
    END LOOP;
    return monthAndBalance_list;  
  END FUNC_ONE;
-------------------------------------------------------------------------------
  FUNCTION FUNC_TWO(variableName varchar2) 
  RETURN f_month_list AS
  
  counter integer := 0;
  month_list f_month_list;
  v_calculateCurAmt number :=0;
  v_rate number;
  v_jan number :=0;
  v_feb number :=0;
  v_march number :=0;
  v_april number :=0;
  v_may number :=0;
  v_june number :=0;
  v_july number :=0;
  v_august number :=0;
  v_sep number :=0;
  v_oct number :=0;
  v_nov number :=0;
  v_dec number :=0;
  
  BEGIN
      FOR x IN (select
        gstt.bal_date,
        gstt.GL_SUB_HEAD_CODE , 
        case when sum(gstt.TOT_CR_BAL) > sum(gstt.TOT_DR_BAL) 
        then sum(gstt.TOT_CR_BAL) - sum(gstt.TOT_DR_BAL) 
        else sum(gstt.TOT_DR_BAL) - sum(gstt.TOT_CR_BAL) end as total,  
        gstt.CRNCY_CODE 
        from tbaadm.gstt gstt, CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE RPT
        where to_char(tbaadm.gstt.bal_date,'MM-YYYY') >= to_char(to_date(cast
        (vi_startMonth as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
        and to_char(tbaadm.gstt.bal_date,'MM-YYYY') <= to_char(to_date(cast
        (vi_endMonth as varchar(10)), 'dd-MM-yyyy'), 'MM-YYYY')
        and gstt.GL_SUB_HEAD_CODE = RPT.VARIABLE_VALUE
        and RPT.VARIABLE_NAME = variableName
        AND RPT.BANK_ID = '01'
        AND RPT.MODULE_NAME = 'REPORT'
        AND RPT.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
        GROUP BY gstt.GL_SUB_HEAD_CODE, 
        gstt.CRNCY_CODE, RPT.DESCRIPTION, 
        gstt.bal_date
        ORDER BY gstt.GL_SUB_HEAD_CODE) 
        LOOP
          
          begin
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
        
        CASE to_char(to_date(x.bal_date, 'DD-MM-YYYY'), 'MM')
          when '1' then v_jan := v_jan + v_calculateCurAmt;
          when '2' then v_feb := v_feb + v_calculateCurAmt;
          when '3' then v_march := v_march + v_calculateCurAmt;
          when '4' then v_april := v_april + v_calculateCurAmt;
          when '5' then v_may := v_may + v_calculateCurAmt;
          when '6' then v_june := v_june + v_calculateCurAmt;
          when '7' then v_july := v_july + v_calculateCurAmt;
          when '8' then v_august := v_august + v_calculateCurAmt;
          when '9' then v_sep := v_sep + v_calculateCurAmt;
          when '10' then v_oct := v_oct + v_calculateCurAmt;
          when '11' then v_nov := v_nov + v_calculateCurAmt;
          when '12' then v_dec := v_dec + v_calculateCurAmt;
      END CASE;
      END LOOP;
      month_list(1) := 'January' ||','|| v_jan;
        month_list(2) := 'Febuary' ||','|| v_feb;
        month_list(3) := 'March' ||','|| v_march;
        month_list(4) := 'April' ||','|| v_april;
        month_list(5) := 'May' ||','|| v_may;
        month_list(6) := 'June' ||','|| v_june;
        month_list(7) := 'July' ||','|| v_july;
        month_list(8) := 'August' ||','|| v_august;
        month_list(9) := 'September' ||','|| v_sep;
        month_list(10) := 'October' ||','|| v_oct;
        month_list(11) := 'November' ||','|| v_nov;
        month_list(12) := 'December' ||','|| v_dec;
      RETURN month_list;
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
  FUNCTION FUNC_FOUR(num varchar2, monthAndBalance_list f_mab_list, 
  description CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE, groupType varchar2,
  tID number) 
  RETURN BOOLEAN AS
  
  v_returnValue boolean := true;
  v_month varchar2(20);
  amount number;
  
  v_jan number :=0;
  v_feb number :=0;
  v_march number :=0;
  v_april number :=0;
  v_may number :=0;
  v_june number :=0;
  v_july number :=0;
  v_august number :=0;
  v_sep number :=0;
  v_oct number :=0;
  v_nov number :=0;
  v_dec number :=0;
 
  v_total number :=0;
  
  BEGIN
    FOR x IN 1.. monthAndBalance_list.count
    LOOP
      v_month := regexp_substr(monthAndBalance_list(x), '[^,]+', 1, 1);
      amount := regexp_substr(monthAndBalance_list(x), '[^,]+', 1, 2);
      CASE v_month 
          when 'January' then v_jan := amount;
          when 'Febuary' then v_feb := amount;
          when 'March' then v_march := amount;
          when 'April' then v_april := amount;
          when 'May' then v_may := amount;
          when 'June' then v_june := amount;
          when 'July' then v_july := amount;
          when 'August' then v_august := amount;
          when 'September' then v_sep := amount;
          when 'October' then v_oct := amount;
          when 'November' then v_nov := amount;
          when 'December' then v_dec := amount;
      END CASE;
    END LOOP;
    v_total := v_jan + v_feb + v_march + v_april + v_may + v_june + v_july +
    v_august + v_sep + v_oct + v_nov + v_dec;
    insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
      values (num, description,groupType,tID,v_jan, v_feb, v_march, v_april, 
      v_may, v_june, v_july, v_august, v_sep, v_oct, v_nov, v_dec, v_total);
    commit; 
    return v_returnValue;
  END FUNC_FOUR; 
--------------------------------------------------------------------------------
  FUNCTION FUNC_FIVE(title varchar2, groupType varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_jan number :=0;
  v_feb number :=0;
  v_march number :=0;
  v_april number :=0;
  v_may number :=0;
  v_june number :=0;
  v_july number :=0;
  v_august number :=0;
  v_sep number :=0;
  v_oct number :=0;
  v_nov number :=0;
  v_dec number :=0;  
  v_total number :=0;
  
  BEGIN
  select 
  sum(AMT_jan),sum(AMT_feb), sum(AMT_march),
  sum(AMT_april), sum(AMT_may), sum(AMT_june), sum(AMT_july), sum(AMT_august), 
  sum(AMT_sep), sum(AMT_oct), sum(AMT_nov), sum(AMT_dec), sum(amt_Total)
  into 
  v_jan, v_feb, v_march, v_april, v_may, v_june, v_july, v_august, v_sep, v_oct, 
  v_nov, v_dec, v_total
from 
  CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE
where 
  group_type = groupType;
  
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
    values ('', title, groupType||'_TOTAL',tID,v_jan, v_feb, v_march, v_april, 
    v_may, v_june, v_july, v_august, v_sep, v_oct, v_nov, v_dec, v_total);
    commit;
  
    RETURN v_returnValue;
  END FUNC_FIVE;
--------------------------------------------------------------------------------
  FUNCTION FUNC_SIX(title varchar2, groupType1 varchar2,
  groupType2 varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_jan number :=0;
  v_feb number :=0;
  v_march number :=0;
  v_april number :=0;
  v_may number :=0;
  v_june number :=0;
  v_july number :=0;
  v_august number :=0;
  v_sep number :=0;
  v_oct number :=0;
  v_nov number :=0;
  v_dec number :=0;
  v_total number :=0;
  
  BEGIN
  select 
  sum(AMT_jan),sum(AMT_feb), sum(AMT_march),
  sum(AMT_april), sum(AMT_may), sum(AMT_june), sum(AMT_july), sum(AMT_august), 
  sum(AMT_sep), sum(AMT_oct), sum(AMT_nov), sum(AMT_dec), sum(amt_Total)
  INTO v_jan, v_feb, v_march, v_april, v_may, v_june, v_july, v_august, v_sep, v_oct, 
  v_nov, v_dec, v_total
from 
  CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE
where 
  group_type in (groupType1, groupType2);

  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
    values ('', title, title,tID,v_jan, v_feb, v_march, v_april, 
    v_may, v_june, v_july, v_august, v_sep, v_oct, v_nov, v_dec, v_total );
    commit;
  
    RETURN v_returnValue;
  END FUNC_SIX;
--------------------------------------------------------------------------------
FUNCTION FUNC_SEVEN(title varchar2, groupType1 varchar2,
  groupType2 varchar2, tID number) RETURN BOOLEAN AS
  v_returnValue boolean := true;
  
  v_jan number :=0;
  v_feb number :=0;
  v_march number :=0;
  v_april number :=0;
  v_may number :=0;
  v_june number :=0;
  v_july number :=0;
  v_august number :=0;
  v_sep number :=0;
  v_oct number :=0;
  v_nov number :=0;
  v_dec number :=0;
  v_total number :=0;
  
  v1_jan number :=0;
  v1_feb number :=0;
  v1_march number :=0;
  v1_april number :=0;
  v1_may number :=0;
  v1_june number :=0;
  v1_july number :=0;
  v1_august number :=0;
  v1_sep number :=0;
  v1_oct number :=0;
  v1_nov number :=0;
  v1_dec number :=0;
  v1_total number :=0;
  
  vr_jan number :=0;
  vr_feb number :=0;
  vr_march number :=0;
  vr_april number :=0;
  vr_may number :=0;
  vr_june number :=0;
  vr_july number :=0;
  vr_august number :=0;
  vr_sep number :=0;
  vr_oct number :=0;
  vr_nov number :=0;
  vr_dec number :=0;
  vr_total number :=0;
  
  BEGIN
  select 
  AMT_jan,AMT_feb, AMT_march,
  AMT_april, AMT_may, AMT_june, AMT_july, AMT_august, 
  AMT_sep, AMT_oct, AMT_nov, AMT_dec, amt_Total
  INTO v_jan, v_feb, v_march, v_april, v_may, v_june, v_july, v_august, v_sep, v_oct, 
  v_nov, v_dec, v_total
from 
  CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE
where 
  group_type in (groupType1);
  
  select 
  AMT_jan,AMT_feb, AMT_march,
  AMT_april, AMT_may, AMT_june, AMT_july, AMT_august, 
  AMT_sep, AMT_oct, AMT_nov, AMT_dec, amt_Total
  INTO v1_jan, v1_feb, v1_march, v1_april, v1_may, v1_june, v1_july, v1_august,
  v1_sep, v1_oct, v1_nov, v1_dec, v1_total
from 
  CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE
where 
  group_type in (groupType2);

  vr_jan:= v_jan - v1_jan;
  vr_feb:= v_feb - v1_feb;
  vr_march:= v_march - v1_march;
  vr_april:= v_april - v1_april;
  vr_may:= v_may - v1_may;
  vr_june:= v_june - v1_june;
  vr_july:= v_july - v1_july;
  vr_august:= v_august - v1_august;
  vr_sep:= v_sep - v1_sep;
  vr_oct:= v_oct - v1_oct;
  vr_nov:= v_nov - v1_nov;
  vr_dec:= v_dec - v1_dec;
  vr_total:= v_total - v1_total;

  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
    values ('', title, title,tID,vr_jan,vr_feb, vr_march,
  vr_april, vr_may, vr_june, vr_july, vr_august, 
  vr_sep, vr_oct, vr_nov, vr_dec, vr_total );
    commit;
  
    RETURN v_returnValue;
  END FUNC_SEVEN;
--------------------------------------------------------------------------------
  PROCEDURE FIN_PNL_QUATERLY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ) AS
      
      v_description CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%TYPE;
      monthAndAmount_list f_month_list;
      v_result f_mab_list;
      v_returnValue boolean;
      
      v_num varchar2(20);
      v_accountName varchar2(200);
      V_AMT_JAN number := 0;
      V_AMT_FEB number := 0;
      V_AMT_MARCH number := 0;
      V_AMT_APRIL number := 0;
      V_AMT_MAY number := 0;
      V_AMT_JUNE number := 0;
      V_AMT_JULY number := 0;
      V_AMT_AUGUST number := 0;
      V_AMT_SEP number := 0;
      V_AMT_OCT number := 0;
      V_AMT_NOV number := 0;
      V_AMT_DEC number := 0;
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
    case outArr(0) 
      when 'January' then vi_startMonth := '31-01-'||outArr(2);
      when 'Febuary' then vi_startMonth := '28-02-'||outArr(2);
      when 'March' then vi_startMonth := '31-03-'||outArr(2);
      when 'April' then vi_startMonth := '30-04-'||outArr(2);
      when 'May' then vi_startMonth := '31-05-'||outArr(2);
      when 'June' then vi_startMonth := '30-06-'||outArr(2);
      when 'July' then vi_startMonth := '31-07-'||outArr(2);
      when 'August' then vi_startMonth := '31-08-'||outArr(2);
      when 'September' then vi_startMonth := '30-09-'||outArr(2);
      when 'October' then vi_startMonth := '31-10-'||outArr(2);
      when 'November' then vi_startMonth := '30-11-'||outArr(2);
      when 'December' then vi_startMonth := '31-12-'||outArr(2);
    end case;
    case outArr(1) 
      when 'January' then vi_endMonth := '31-01-'||outArr(2);
      when 'Febuary' then vi_endMonth := '28-02-'||outArr(2);
      when 'March' then vi_endMonth := '31-03-'||outArr(2);
      when 'April' then vi_endMonth := '30-04-'||outArr(2);
      when 'May' then vi_endMonth := '31-05-'||outArr(2);
      when 'June' then vi_endMonth := '30-06-'||outArr(2);
      when 'July' then vi_endMonth := '31-07-'||outArr(2);
      when 'August' then vi_endMonth := '31-08-'||outArr(2);
      when 'September' then vi_endMonth := '30-09-'||outArr(2);
      when 'October' then vi_endMonth := '31-10-'||outArr(2);
      when 'November' then vi_endMonth := '30-11-'||outArr(2);
      when 'December' then vi_endMonth := '31-12-'||outArr(2);
    end case;
    vi_year :=outArr(2) ;
  -------------------------------------------------------------------------------------  
if( vi_startMonth is null or vi_endMonth is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0
                 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

    
    ------------------------------------------------------------------------------------------
-------------------------------40002--------------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  delete from CUSTOM.CUST_PNL_QUATERLY_TEMP_TABLE;
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Income A/C', 'GROUP_1',1,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('1', v_result, 
  v_description, 'GROUP_1',
  2);
-------------------------------40016--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('2', v_result, v_description,'GROUP_1',3);
-------------------------------40011--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('3', 'Interest on loans advance & overdraft', 'GROUP_1',4,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit; 
  v_returnValue := FUNC_FOUR('',v_result, 
  v_description,'GROUP_1',5);
-------------------------------40012--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_OVERDRAFT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_OVERDRAFT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
-------------------------------------------------------------------------------- 
  v_returnValue := FUNC_FOUR('',v_result, 
  v_description,'GROUP_1',6);
-------------------------------40015--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_STAFF_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_STAFF_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_1',7);
-------------------------------40021--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('REN_CHR_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REN_CHR_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('4', v_result, 
  v_description,'GROUP_1',8);
-------------------------------40003--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_DEPOSIT_AUT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_DEPOSIT_AUT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('5', v_result, 
  v_description,'GROUP_1',9);
-------------------------------40004--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_MIS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_MIS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('6', v_result, 
  v_description,'GROUP_1',10);
-------------------------------40014--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
  --solId_list := FUNC_FOUR;
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('INT_OTH_ADV');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('INT_OTH_ADV');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('7', v_result, 
  v_description,'GROUP_1',11);
  ------------------------------GROUP_1_TOTOAL------------------------------------
  v_returnValue := FUNC_FIVE( 'Total interest income ', 'GROUP_1', 12);
-------------------------------50101--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SAVE_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SAVE_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Interest expenses', 'GROUP_2',13,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('1', v_result, 
  v_description,'GROUP_2',14);
-------------------------------50103--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SPEC_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SPEC_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('2', v_result, 
  v_description,'GROUP_2',15);
-------------------------------50104--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FIX_DEPOSIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIX_DEPOSIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('3', v_result, 
  v_description,'GROUP_2',16);
-------------------------------50104--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ATM_DEBIT_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_DEBIT_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('4', v_result, 
  v_description,'GROUP_2',17);
-------------------------------50105--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BOR_FRM_CBM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BOR_FRM_CBM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('5', v_result, 
  v_description,'GROUP_2',18);
------------------------------GROUP_2_TOTOAL------------------------------------
  v_returnValue := FUNC_FIVE('Total interest expenses' , 'GROUP_2', 19);
-------------------------------40031--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_INT_REMT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Other income', 'GROUP_3',20,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('1', 'Exchange transaction', 'GROUP_3',21,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',22);
-------------------------------40032--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_INT_REMT_LINK');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT_LINK');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',23);
-------------------------------40033--------------------------------------------    
---------------------------SubProgram FOUR--------------------------------------
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_OTH_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_OTH_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',24);
-------------------------------40101--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_FORE_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_FORE_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',25);
-------------------------------40034--------------------------------------------    
---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_ON_ATM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_ON_ATM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',26);
-------------------------------40060--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SER_COM_CHR_EBK');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_COM_CHR_EBK');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('2', 'Other commission & service charges  ', 'GROUP_3',27,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',28);
-------------------------------40045--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_SER_COM_CHR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_SER_COM_CHR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',29);
-------------------------------40052--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COM_CER_CHEQ');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_CER_CHEQ');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',30);
-------------------------------40042--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COM_CRE_GUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_CRE_GUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',31);
-------------------------------40049--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COM_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('3', v_result, 
  v_description,'GROUP_3',32);
-------------------------------40102--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COM_FORE_CUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_FORE_CUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('4', 'Comission on Foreign Currency', 'GROUP_3',33,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',34);
-------------------------------40104--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('WORKER_REM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('WORKER_REM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',35);
-------------------------------40050--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SER_CHRG_LOAN_OD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_CHRG_LOAN_OD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('5', v_result, 
  v_description,'GROUP_3',36);
-------------------------------40056--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('IN_SER_CHRG_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('IN_SER_CHRG_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('6', 'Service charges and late fees on Hire Purchase', 'GROUP_3',37,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',38);
-------------------------------40057--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('IN_LATE_FEE_HP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('IN_LATE_FEE_HP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',39);
-------------------------------40058--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LATE_FEE_STAFF_LOAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LATE_FEE_STAFF_LOAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',40);
-------------------------------40103--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SER_CHRG_FE_TRAN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_CHRG_FE_TRAN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('7', 'Service charges on foreign transaction', 'GROUP_3',41,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',42);
-------------------------------40051--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_CHRG_LOAN_OD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_CHRG_LOAN_OD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('8', v_result, 
  v_description,'GROUP_3',43);
-------------------------------40041--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('9', v_result, 
  v_description,'GROUP_3',44);
-------------------------------10301--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SALES_PROC_1');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SALES_PROC_1');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('10', v_result, 
  v_description,'GROUP_3',45);
-------------------------------40091--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DIS_INV_IN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIS_INV_IN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('11', v_result, 
  v_description,'GROUP_3',46);
-------------------------------40111--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('RENT_IN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('RENT_IN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('12', v_result, 
  v_description,'GROUP_3',47);
-------------------------------40071--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COST_CRE_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COST_CRE_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('13', 'Miscellaneous', 'GROUP_3',48,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',49);
-------------------------------40072--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ANN_FEE_CRE_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANN_FEE_CRE_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',50);
-------------------------------40073--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FEE_LATE_SET_CR_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FEE_LATE_SET_CR_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',51);
-------------------------------40082--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_ITEMS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ITEMS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',52);
-------------------------------40074--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ANN_FEE_ATM_CARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANN_FEE_ATM_CARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',53);
-------------------------------40075--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ATM_NEW_CARD_ISSE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_NEW_CARD_ISSE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',54);
-------------------------------40081--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FEE_ONLINE_PAY_BILL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FEE_ONLINE_PAY_BILL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',55);
-------------------------------40076--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ATM_CARD_DEPT_REC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ATM_CARD_DEPT_REC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_3',56);
------------------------------Total other income -------------------------------
  v_returnValue := FUNC_FIVE('Total other income ', 'GROUP_3', 57);
------------------------------Total income -------------------------------------
  v_returnValue := FUNC_SIX('Total income', 'GROUP_1',
  'GROUP_3', 58);
----------------------------Total net income ------------------------------------
  v_returnValue := FUNC_SEVEN('Total net income', 'Total income',
  'GROUP_2_TOTAL', 59);
-------------------------------50121--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('REMTT_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REMTT_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Expenditure A/C', 'GROUP_4',60,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('1', 'Currency Expenses', 'GROUP_4',61,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',62);
-------------------------------50122--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TRPT_HAN_CHRG');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_HAN_CHRG');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',63);
-------------------------------50123--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_INT_REMT_CUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_INT_REMT_CUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',64);
-------------------------------50131--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LEG_EXP_STAMP_DUTY');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEG_EXP_STAMP_DUTY');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('2', 'Legal Expenses And Stamp Duty', 'GROUP_4',65,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',66);
-------------------------------50141--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_CRE_GUARA');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_CRE_GUARA');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('3', 'Commission Expense', 'GROUP_4',67,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',68);
-------------------------------50142--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_BILL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_BILL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',69);
-------------------------------50143--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_SALE_PUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_SALE_PUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',70);
-------------------------------50144--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMM_PAID_OTH_SER');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMM_PAID_OTH_SER');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',71);
-------------------------------50145--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_COMM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_COMM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',72);
-------------------------------50161--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('STAFF_SALARY');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_SALARY');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('4', 'Salaries and Benefits', 'GROUP_4',73,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',74);
-------------------------------50162--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('MEAL_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',75);
-------------------------------50163--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OT_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OT_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',76);
-------------------------------50164--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('UNI_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('UNI_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',77);
-------------------------------50165--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('HOUSE_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HOUSE_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',78);
-------------------------------50166--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TECH_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TECH_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',79);
-------------------------------50167--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SPEC_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SPEC_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',80);
-------------------------------50168--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TRPT_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',81);
-------------------------------50169--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('MED_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MED_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',82);
-------------------------------50170--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('STAFF_WALFARE_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_WALFARE_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',83);
-------------------------------50171--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('STAFF_WALFARE_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_WALFARE_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',84);
-------------------------------50172--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('STAFF_IN_TAX_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_IN_TAX_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',85);
-------------------------------50173--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('STAFF_SOC_SEC_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('STAFF_SOC_SEC_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',86);
-------------------------------50177--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DAILY_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DAILY_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',87);
-------------------------------50174--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BONUS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BONUS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',88);
-------------------------------50175--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('PROV_FUN_CON');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PROV_FUN_CON');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',89);
-------------------------------50176--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COST_LIV_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COST_LIV_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',90);
-------------------------------50178--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_ALLOW');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ALLOW');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',91);
-------------------------------50191--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BUILD_GODOWN');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_GODOWN');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('5', 'Rent', 'GROUP_4',92,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',93);
-------------------------------50192--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('HIRE_MECH_ELEC_EQUP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HIRE_MECH_ELEC_EQUP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',94);
-------------------------------50193--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CAR_RENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_RENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',95);
-------------------------------50195--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_RENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_RENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',96);
-------------------------------50201--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TELE_FAX_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TELE_FAX_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('6', 'Telephone', 'GROUP_4',97,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',98);
-------------------------------50202--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COMMU_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COMMU_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',99);
-------------------------------50211--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('POL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('7', 'Travel and Entertainment', 'GROUP_4',100,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',101);
-------------------------------50211--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('POL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',102);
-------------------------------50212--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('HOTEL');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HOTEL');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',103);
-------------------------------50213--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TRPT_TRAVEL_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRPT_TRAVEL_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',104);
-------------------------------50214--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('PER_DIEM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PER_DIEM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',105);
-------------------------------50215--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_TRAVEL_ENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_TRAVEL_ENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',106);
-------------------------------50216--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ENTERTAINMENT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ENTERTAINMENT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',107);
-------------------------------50231--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DIR_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIR_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('8', 'Professional Fees', 'GROUP_4',108,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',109);
-------------------------------50232--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('AUDITOR_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('AUDITOR_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',110);
-------------------------------50233--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LEGAL_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEGAL_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',111);
-------------------------------50234--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('TRAIN_FEE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('TRAIN_FEE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',112);
-------------------------------50235--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ANNUAL_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ANNUAL_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',113);
-------------------------------50236--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_ITEM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_ITEM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',114);
-------------------------------50237--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('HONO_LEC_ADV');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('HONO_LEC_ADV');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',115);
-------------------------------50238--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_HONO');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_HONO');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',116);
-------------------------------50251--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BUILD_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('9', 'Insurance', 'GROUP_4',117,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',118);
-------------------------------50252--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OFFI_MECH_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFFI_MECH_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',119);
-------------------------------50253--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FUR_FIX_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',120);
-------------------------------50254--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ELEC_COMP_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_COMP_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',121);
-------------------------------50255--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CAR_CYCLE_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',122);
-------------------------------50256--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CASH_TRANSIT_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CASH_TRANSIT_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',123);
-------------------------------50257--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CASH_VAULT_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CASH_VAULT_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',124);
-------------------------------50258--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FIE_BOND_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIE_BOND_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',125);
-------------------------------50259--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FIRE_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIRE_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',126);
-------------------------------50260--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_INSUR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_INSUR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',127);
-------------------------------50271--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('PRO_EVE_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PRO_EVE_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('10', 'Sales and Marketing Exp', 'GROUP_4',128,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',129);
-------------------------------50272--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ADVERTISTING');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ADVERTISTING');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',130);
-------------------------------50273--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('GIFT_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',131);
-------------------------------50273--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('GIFT_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',132);
-------------------------------50274--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('MEAL_ALLOW_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',133);
-------------------------------50275--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('MEAL_ALLOW_SALE_MRKT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('MEAL_ALLOW_SALE_MRKT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',134);
-------------------------------50281--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LAND_BUILD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LAND_BUILD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('11', 'Repairs and Maintenance Expense', 'GROUP_4',135,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',136);
-------------------------------50282--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OFF_MECH_OTH_MECH');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFF_MECH_OTH_MECH');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',137);
-------------------------------50283--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FUR_FIX_FIT');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_FIT');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',138);
-------------------------------50284--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ELEC_ACCESS_COM');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_ACCESS_COM');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',139);
-------------------------------50285--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CAR_CYCLE_REP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_REP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',140);
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Other Maintainance and Repair', 'GROUP_4',141,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
-------------------------------50291--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('PRI_STA_OFF_SUP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('PRI_STA_OFF_SUP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('12', 'Supply and Services', 'GROUP_4',142,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',143);
-------------------------------50292--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('POSTAGE_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('POSTAGE_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',144);
-------------------------------50293--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SER_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SER_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',145);
-------------------------------50301--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LICENCE_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LICENCE_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('13', 'Rate and Tax', 'GROUP_4',146,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',147);
-------------------------------50301--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('REG_FEE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('REG_FEE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',148);
-------------------------------50303--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('YCDC_TAX');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('YCDC_TAX');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',149);
-------------------------------50304--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('COM_ACC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('COM_ACC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',150);
-------------------------------50305--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_RATE_TAX');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_RATE_TAX');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',151);
-------------------------------50306--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LIGHT_PWR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LIGHT_PWR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',152);
-------------------------------50311--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BOOK_NEWPAPER');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BOOK_NEWPAPER');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('14', 'Other', 'GROUP_4',153,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',154);
-------------------------------50312--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DONATION');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DONATION');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',155);
-------------------------------50313--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('GIFT_REWARD');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('GIFT_REWARD');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',156);
-------------------------------50314--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_MISC');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_MISC');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',157);
-------------------------------50315--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('WAGES');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('WAGES');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',158);
-------------------------------50321--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('BUILD_DEPRE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('BUILD_DEPRE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('15', 'Deprecitaion', 'GROUP_4',159,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',160);
-------------------------------50322--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OFF_OTH_MECH_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OFF_OTH_MECH_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',161);
-------------------------------50323--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FUR_FIX_FIT_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FUR_FIX_FIT_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',162);
-------------------------------50324--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ELEC_COM_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ELEC_COM_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',163);
-------------------------------50325--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('CAR_CYCLE_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('CAR_CYCLE_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',164);
-------------------------------50326--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('LEASE_IMP_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('LEASE_IMP_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',165);
	insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Amortization', 'GROUP_4',166,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
-------------------------------50341--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('SW_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('SW_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',167);
-------------------------------50342--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('NETWORK_DEPR');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('NETWORK_DEPR');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',168);
-------------------------------50352--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('FIX_ASSET');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('FIX_ASSET');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('16', 'Loss & Write Off', 'GROUP_4',169,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('', 'Loans and Advences', 'GROUP_4',170,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',171);
-------------------------------50353--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DEFER_EXP');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DEFER_EXP');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',172);
-------------------------------50354--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('OTH_LOSS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('OTH_LOSS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',173);
-------------------------------50361--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('DIS_BILL_BOND');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('DIS_BILL_BOND');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('17', 'Discount  Expense', 'GROUP_4',174,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',175);
-------------------------------50361--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_REVALUE');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_REVALUE');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  insert into custom.CUST_PNL_QUATERLY_TEMP_TABLE 
  values ('18', 'Foreign Currency Gain/(loss)', 'GROUP_4',176,'','', '',
    '', '', '', '', '', '', '', '', '', '');
  commit;
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',177);
-------------------------------50361--------------------------------------------    

---------------------------SubProgram TWO---------------------------------------
  monthAndAmount_list := FUNC_TWO('ECH_FORE_TRANS');
---------------------------SubProgram THREE-------------------------------------
  v_description := FUNC_THREE('ECH_FORE_TRANS');
-------------------------SubProgram ONE-----------------------------------------        
  v_result := FUNC_ONE(monthAndAmount_list);
--------------------------------------------------------------------------------
  v_returnValue := FUNC_FOUR('', v_result, 
  v_description,'GROUP_4',178);
------------------------------GROUP_4_TOTAL------------------------------------
  v_returnValue := FUNC_FIVE( 'Total other expenses', 'GROUP_4', 179);
  v_returnValue := FUNC_SIX('Total expenses', 'GROUP_4',
  'GROUP_2', 180);
  v_returnValue := FUNC_SEVEN('Excess of expenditure over income',
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
			INTO	 v_num, v_accountName, V_AMT_JAN,V_AMT_FEB,V_AMT_MARCH,
      V_AMT_APRIL,V_AMT_MAY,V_AMT_JUNE,V_AMT_JULY,V_AMT_AUGUST,V_AMT_SEP,
      V_AMT_OCT,V_AMT_NOV,V_AMT_DEC, V_AMT_TOTAL;
      

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
    
    out_rec:=	(v_num|| '|' || v_accountName|| '|' || V_AMT_JAN|| '|' ||
    V_AMT_FEB|| '|' ||V_AMT_MARCH|| '|' ||V_AMT_APRIL|| '|' ||V_AMT_MAY|| '|' ||
    V_AMT_JUNE|| '|' ||V_AMT_JULY|| '|' ||V_AMT_AUGUST|| '|' ||V_AMT_SEP|| '|' ||
    V_AMT_OCT|| '|' ||V_AMT_NOV|| '|' ||V_AMT_DEC|| '|' ||V_AMT_TOTAL);
    
    dbms_output.put_line(out_rec);
  
  END FIN_PNL_QUATERLY;

END FIN_PNL_QUATERLY;
/
