CREATE OR REPLACE PACKAGE        FIN_USER_REPORT AS 

  PROCEDURE FIN_USER_REPORT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_USER_REPORT;
/


CREATE OR REPLACE PACKAGE BODY          FIN_USER_REPORT
AS
  -------------------------------------------------------------------------------------
  --Update User -Saung Hnin Oo--------------------------------------
  ---Update Date - 2-5-2017------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType ; -- Input Parse Array
  
  vi_roleID VARCHAR2(10);
  vi_workClass  VARCHAR2(15);                 -- Input to procedure
  vi_SOLID  VARCHAR2(5); -- Input to procedure
  -- vi_zoneCode   VARCHAR(6);           -- Input to procedure
  -----------------------------------------------------------------------------
 
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData
  -----------------------------------------------------------------------------
  CURSOR ExtractData (ci_roleID VARCHAR2,ci_workClass VARCHAR2, ci_SOLID VARCHAR2)
  IS
   select upr.user_id as "Emp_id", 
get.emp_name AS "EMP_name", 
get.emp_short_name as "Emp_short_name",
get.sol_id AS "Sol_id",
get.is_head_teller AS "teller_allow",
upr.role_id AS "Role_id", 
upr.user_work_class as "Work_class" ,
(select res_id from SSOADM.sso_resource_access_tbl tbl where tbl.user_id = upr.user_id and tbl.res_id in ('CRMServer')) as crm_server,
(select res_id from SSOADM.sso_resource_access_tbl tbl where tbl.user_id = upr.user_id and tbl.res_id in ('SVSServer')) as svs_server

from tbaadm.get get , tbaadm.upr upr 
where 
upr.user_emp_id = get.emp_id
and upr.role_id like '%'||ci_roleID || '%'
and upr.user_work_class like '%' ||ci_workClass||'%'
and get.sol_id like '%'||ci_SOLID||'%'
and upr.del_flg ='N'
and get.del_flg ='N'
order by upr.user_work_class desc,upr.user_id asc,upr.role_id asc;
    
PROCEDURE FIN_USER_REPORT(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
AS
  v_User_ID tbaadm.upr.user_id%type;
  v_Full_Name tbaadm.get.emp_name%type;
  v_Short_Name tbaadm.get.emp_short_name%type;
  v_Sol_ID tbaadm.get.sol_id%type;
  v_Teller_Allowed tbaadm.get.is_head_teller%type;
  v_Role_ID tbaadm.upr.role_id%type;
  v_Work_Class tbaadm.upr.user_work_class%type;
  v_CRM_Server SSOADM.sso_resource_access_tbl.res_id%type;
  v_SVS_Server SSOADM.sso_resource_access_tbl.res_id%type;
  v_BranchName tbaadm.sol.sol_desc%type;
  v_BankAddress varchar(200);
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
 
 
BEGIN
  -------------------------------------------------------------
  -- Out Ret code is the code which controls
  -- the while loop,it can have values 0,1
  -- 0 - The while loop is being executed
  -- 1 - Exit
  -------------------------------------------------------------
  out_retCode := 0;
  out_rec     := NULL;
  tbaadm.basp0099.formInputArr(inp_str, outArr);
  --------------------------------------
  -- Parsing the i/ps from the string
  --------------------------------------
  vi_roleID  := outArr(0);
  vi_workClass  := outArr(1);
  vi_SOLID := outArr(2); 
  

  ---------------------------------------------------------
  IF vi_roleID IS NULL OR vi_roleID = '' THEN
    vi_roleID  := '';
  END IF;
  ------------------------------------------------------------
  IF vi_workClass IS NULL OR vi_workClass = '' THEN
    vi_workClass  := '';
  END IF;
  ----------------------------------------------------------------
  IF vi_SOLID IS NULL OR vi_SOLID = '' THEN
    vi_SOLID  := '';
  END IF;
  ---------------------------------------------------------------
  IF NOT ExtractData%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractData (vi_roleID,vi_workClass,vi_SOLID );
      --}
    END;
    --}
  END IF;
  IF ExtractData%ISOPEN THEN
    --{
    FETCH ExtractData
    INTO   v_User_ID, 
  v_Full_Name, 
  v_Short_Name ,
  v_Sol_ID, 
  v_Teller_Allowed ,
  v_Role_ID ,
  v_Work_Class, 
  v_CRM_Server,
  v_SVS_Server ;
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
 ------------------------------------------------------------------------------
  BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
if vi_SOLID is not null or vi_SOLID !=' ' then
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into  v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_SOLID AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
end if;
    END;
 
 
 -------------------------------------------------------------------------
  IF v_Teller_Allowed IS NULL OR v_Teller_Allowed = '' THEN
    v_Teller_Allowed  := 'N';
  END IF;
 
  -----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  ------------------------------------------------------------------------------------
  out_rec:= ( v_User_ID || '|' ||
  v_Full_Name || '|' ||
  v_Short_Name || '|' ||
  v_Sol_ID || '|' ||
  v_Teller_Allowed || '|' ||
  v_Role_ID || '|' ||
  v_Work_Class || '|' ||
  v_CRM_Server || '|' ||
  v_SVS_Server|| '|' ||
  v_BranchName	|| '|' ||
  v_BankAddress  || '|' ||
  v_BankPhone   || '|' ||
  v_BankFax);
  dbms_output.put_line(out_rec);
END FIN_USER_REPORT;
END FIN_USER_REPORT;
/
