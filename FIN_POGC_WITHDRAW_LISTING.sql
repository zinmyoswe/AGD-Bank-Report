CREATE OR REPLACE PACKAGE                             FIN_POGC_WITHDRAW_LISTING AS 

 PROCEDURE FIN_POGC_WITHDRAW_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_POGC_WITHDRAW_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                           FIN_POGC_WITHDRAW_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_StartDate	   	Varchar2(10);               -- Input to procedure
  vi_EndDate        Varchar2(10);               -- Input to procedure
  vi_SchmCode        Varchar2(20);
  vi_SOL_ID		      Varchar2(5);		    	            -- Input to procedure
  vi_currency		    Varchar2(3);		    	          -- Input to procedure
  
 
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (ci_StartDate VARCHAR2,ci_EndDate VARCHAR2,ci_SchmCode VARCHAR2, ci_SOL_ID VARCHAR2, ci_currency VARCHAR2) IS

SELECT    
          CTD.TRAN_SUB_TYPE AS "TranSubType",
          CTD.Tran_type as "TranType",
          trim(dst.INSTRMNT_ALPHA) || trim(dst.INSTRMNT_NUM) as "PONumber",
          DST.DD_AMT as "TranAmt",
          CTD.instrmnt_date AS "TranDate",
          DST.ISSU_BR_CODE AS "IssueBrCode",
          DST.PAYEE_BR_CODE AS "PayeeBrCode",
          DST.PAYING_BR_CODE as "PayingBrCode",
          ctd.tran_date
--, CTD.TRAN_AMT
FROM      TBAADM.CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM, TBAADM.DDD DDD, TBAADM.DST DST
WHERE     CTD.ACID = GAM.ACID
AND       ddd.part_tran_srl_num = ctd.part_tran_srl_num
AND       trim(DDD.TRAN_ID) = trim(CTD.TRAN_ID)
AND       GAM.SCHM_CODE = UPPER(ci_SchmCode)
AND       DST.SCHM_CODE = Upper(ci_SchmCode)
AND       TRIM(DDD.DD_NUM) = TRIM(DST.DD_NUM)
AND       DST.issue_date = DDD.DD_DATE
--AND       DST.DD_STATUS_DATE = DDD.DD_DATE
and       CTD.TRAN_DATE = DDD.TRAN_DATE
AND       CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
AND       CTD.TRAN_DATE <= TO_DATE( CAST (  ci_EndDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
and       CTD.PART_TRAN_TYPE = 'D'
and       dst.DD_STATUS = 'P'
AND       CTD.DTH_INIT_SOL_ID= ci_SOL_ID
AND       GAM.ENTITY_CRE_FLG = 'Y'
AND       GAM.DEL_FLG = 'N'
and       DST.DEL_FLG = 'N'
and ctd.instrmnt_date is not null
--and DST.INSTRMNT_TYPE is not null
ORDER BY CTD.TRAN_DATE,DDD.DD_NUM;


  PROCEDURE FIN_POGC_WITHDRAW_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
 

     v_TranSubType  TBAADM.CTD_DTD_ACLI_VIEW.TRAN_SUB_TYPE%type;
      v_TranType     TBAADM.CTD_DTD_ACLI_VIEW.Tran_type%type;
      v_TranAmt      TBAADM.DST.DD_AMT%type;
      v_PONumber     TBAADM.DST.DD_NUM%type;
      v_TranDate     TBAADM.CTD_DTD_ACLI_VIEW.TRAN_DATE%type;
      v_inst_Date     TBAADM.CTD_DTD_ACLI_VIEW.TRAN_DATE%type;
       v_IssueBrCode  TBAADM.DST.ISSU_BR_CODE%type;
      v_PayeeBrCode  TBAADM.DST.PAYEE_BR_CODE%type;
      v_PayingBrCode TBAADM.DST.PAYING_BR_CODE%type;
        v_BranchName tbaadm.sol.sol_desc%type;
       v_BankAddress varchar(200);
      v_BankPhone    TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
      v_BankFax      TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
        
        
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
    
    vi_StartDate  :=  outArr(0);	
    vi_EndDate    :=  outArr(1);   
    vi_SOL_ID     :=  outArr(4);		
    vi_currency   :=  outArr(2);
    vi_SchmCode   :=  outArr(3);
----------------------------------------------------------------------------------------------------
if( vi_StartDate is null or vi_EndDate is null or vi_currency is null or vi_SchmCode is null or vi_SOL_ID is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;



-------------------------------------------------------------------------------------------
   IF vi_SchmCode like 'Gift%' then
      vi_SchmCode := 'DDGC';
    END IF;
    IF vi_SchmCode like 'Payment%' then
      vi_SchmCode := 'DDPO';
    END IF;
   
       IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData ( vi_StartDate,vi_EndDate,vi_SchmCode,	vi_SOL_ID,vi_currency);
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO	v_TranSubType,v_TranType,v_PONumber,v_TranAmt,v_TranDate,v_IssueBrCode,v_PayeeBrCode,v_PayingBrCode,v_inst_Date;
          
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
        
        BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into  v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_SOL_ID AND bct.br_code = sol.br_code
   and bct.bank_code = '116';

    END;
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_TranSubType   || '|' ||
          v_TranType      || '|' ||
          v_TranAmt       || '|' ||
          v_PONumber      || '|' ||
          to_char(to_date(v_TranDate,'dd/Mon/yy'), 'dd/MM/yyyy')       || '|' ||
          v_IssueBrCode   || '|' ||
					v_BranchName	  || '|' ||
					v_BankAddress   || '|' ||
					v_BankPhone     || '|' ||
          v_BankFax       || '|' ||
          v_PayeeBrCode  || '|' ||
          v_PayingBrCode ||'|'|| to_char(to_date(v_inst_Date,'dd/Mon/yy'), 'dd/MM/yyyy') );
  
			dbms_output.put_line(out_rec);
  END FIN_POGC_WITHDRAW_LISTING;

END FIN_POGC_WITHDRAW_LISTING;
/
