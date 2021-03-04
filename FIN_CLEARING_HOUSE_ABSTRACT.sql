CREATE OR REPLACE PACKAGE        FIN_CLEARING_HOUSE_ABSTRACT AS 

 PROCEDURE FIN_CLEARING_HOUSE_ABSTRACT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CLEARING_HOUSE_ABSTRACT;
 
/


CREATE OR REPLACE PACKAGE BODY                             FIN_CLEARING_HOUSE_ABSTRACT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
	vi_TransactionDate		Varchar2(10);		    	    -- Input to procedure
  --vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_SchemeType		Varchar2(3);		    	    -- Input to procedure

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_TransactionDate VARCHAR2,ci_branchCode VARCHAR2,ci_currency VARCHAR2)
  IS
   SELECT  CASE WHEN Q.TRAN_SUB_TYPE = 'O' THEN 1 else 0 END AS OutCheq,
         CASE WHEN Q.TRAN_SUB_TYPE = 'I' THEN 1 else 0 END AS IntCheq,
         case when q.tran_sub_type = 'O'  then q.tran_amt else 0 end as OutAmt,
         case when q.tran_sub_type = 'I'  then q.tran_amt else 0 end as InAmt, 
         BCT.BR_NAME AS Branch
        
  FROM
      (select ctd.TRAN_SUB_TYPE,
      cpt.TRAN_AMT,
      ICI.ISS_BANK_CODE,
      ICI.ISS_BR_CODE
      from custom.CUSTOM_CTD_DTD_ACLI_VIEW ctd,TBAADM.INW_CLG_PART_TRAN_TABLE CPT,TBAADM.INW_CLG_ZONE_HDR_TABLE CZH,TBAADM.INW_CLG_INST_TABLE ICI--,TBAADM.BRANCH_CODE_TABLE BCT
      where CTD.TRAN_DATE = TO_DATE(CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
      AND ICI.ZONE_CODE = CPT.ZONE_CODE
      AND CPT.ZONE_CODE = CZH.ZONE_CODE
      AND ICI.ZONE_SRL_NUM = CPT.ZONE_SRL_NUM
      AND CTD.TRAN_ID = CPT.TRAN_ID
      AND CPT.TRAN_ID = CZH.TRAN_ID
      and CPT.ZONE_DATE = CZH.ZONE_DATE
      and czh.zone_date = ICI.ZONE_DATE
      --AND BCT.BANK_CODE = CZH.CLG_SEC_BANK_CODE
      --AND BCT.BR_CODE = CZH.CLG_SEC_DP_CODE
      AND CPT.ZONE_CODE = CPT.ZONE_CODE
      AND ctd.PSTD_FLG ='Y'
      and ctd.DEL_FLG = 'N'
      and ctd.PART_TRAN_SRL_NUM like '%1'
      and CZH.ZONE_STAT = 'Z'
      --and CPT.ZONE_SRL_NUM LIKE '%1'
      AND CZH.POSTING_STAT = 'P'
      AND CZH.VALIDATION_STAT = 'V'
      AND cpt.SOL_ID = ci_branchCode
      AND CPT.CRNCY_CODE = Upper(ci_currency)
      
      UNION all
      
      SELECT  --OCPT.SET_NUM as "CheqNo",
                ctd.TRAN_SUB_TYPE AS "Outward",
                OCPT.TRAN_AMT as "TranAmt", 
                OCI.BANK_CODE as "BankCode",
                 OCI.BR_CODE as "BankName"
                 
      FROM  TBAADM.OUT_ZONE_HDR_TABLE OZH,
              TBAADM.OUT_CLG_INSTRMNT_TABLE OCI,
              TBAADM.OUT_CLG_PART_TRAN_TABLE OCPT,
              custom.CUSTOM_CTD_DTD_ACLI_VIEW ctd
             -- TBAADM.BRANCH_CODE_TABLE BCT
              
      WHERE OZH.CLG_ZONE_CODE = OCI.CLG_ZONE_CODE
      and OCI.SET_NUM = OCPT.SET_NUM
      AND   OCI.CLG_ZONE_CODE= OCPT.CLG_ZONE_CODE
      AND  CTD.TRAN_ID = OCPT.TRAN_ID
      AND ctd.PSTD_FLG ='Y'
      and ctd.DEL_FLG = 'N'
      and ctd.PART_TRAN_SRL_NUM like '%1'
      AND   OZH.ZONE_STAT =  'C'
      and  OCPT.CLG_ZONE_DATE = OCI.CLG_ZONE_DATE
      --AND OCI.CLG_ZONE_DATE = OZH.CLG_ZONE_DATE
      AND OCPT.TRAN_DATE  = OZH.TRAN_DATE2
      AND   OZH.CLG_ZONE_DATE = TO_DATE(CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
    --AND   OCI.BANK_CODE = BCT.BANK_CODE
   -- AND   OCI.BR_CODE = BCT.BR_CODE
      AND   OCPT.ACCT_CRNCY_CODE = UPPER(ci_currency)
      AND    OCPT.SOL_ID = ci_branchCode
      AND   OCPT.DEL_FLG = 'N'
      AND   OCI.DEL_FLG = 'N'
      AND   OZH.DEL_FLG = 'N')q,
      TBAADM.BRANCH_CODE_TABLE BCT
  WHERE Q.ISS_BANK_CODE = BCT.BANK_CODE
  AND  Q.ISS_BR_CODE  = BCT.BR_CODE
  order by BCT.BR_NAME;
 -- group by q.clg_sec_dp_code,q.tran_sub_type,BCT.BR_NAME;
  
  PROCEDURE FIN_CLEARING_HOUSE_ABSTRACT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      
    v_OutCheq Number(4);
    v_IntCheq Number(4);
    v_OutAmt  Number(20,2);
    v_InAmt  Number(20,2);
    v_Branch    TBAADM.BRANCH_CODE_TABLE.BR_NAME%type;
    
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
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
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_TransactionDate :=outArr(0);
    vi_branchCode :=outArr(2);
    vi_currency :=outArr(1);		
  
  ----------------------------------------------------------------------------------------------------
  if( vi_TransactionDate is null or vi_currency is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
      out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  
  
  
  
  --------------------------------------------------------------------------------------------------
 
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_TransactionDate, vi_branchCode,vi_currency);
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_OutCheq, v_IntCheq,
            v_OutAmt ,v_InAmt, v_Branch;
   

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
      select 
         BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;

     out_rec:=	(
					v_OutCheq         || '|' ||  
          v_IntCheq         || '|' ||
          v_OutAmt          || '|' ||
          v_InAmt           || '|' ||
          v_Branch          || '|' ||
					v_BranchName	    || '|' ||
					v_BankAddress     || '|' ||
					v_BankPhone       || '|' ||
          v_BankFax );
  
          dbms_output.put_line(out_rec);
 
 
  END FIN_CLEARING_HOUSE_ABSTRACT;

END FIN_CLEARING_HOUSE_ABSTRACT;
/
