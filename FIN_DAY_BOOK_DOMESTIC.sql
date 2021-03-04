CREATE OR REPLACE PACKAGE                      FIN_DAY_BOOK_DOMESTIC AS 
 
PROCEDURE FIN_DAY_BOOK_DOMESTIC(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAY_BOOK_DOMESTIC;
/


CREATE OR REPLACE PACKAGE BODY                                                         FIN_DAY_BOOK_DOMESTIC AS



-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
	vi_TranDate		Varchar2(10);		    	    -- Input to procedure
  vi_BranchCode		Varchar2(5);		    	    -- Input to procedure
 -- vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_ReversalType varchar2(20);
  --vi_SchemeCode VARCHAR2(10);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData Without Reversal
-----------------------------------------------------------------------------
CURSOR ExtractDataWithoutReversal (	
			ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2)
  IS
select 
   gam.SCHM_TYPE as "Account_Type" , 
  sum( cdav.TRAN_AMT ) as "Amount" , 
  --substr(gam.foracid,6,length(gam.foracid)-5)
  gam.foracid as "Account No." , 
   cdav.TRAN_TYPE as "Tran_Type" , 
   cdav.PART_TRAN_TYPE as "Part_Tran_Type",
   cdav.dth_init_sol_id as "Init_Sol_Id",
   gam.ACCT_NAME AS "Description",
    gam.GL_SUB_HEAD_CODE as "GLSH"
from 
    TBAADM.GENERAL_ACCT_MAST_TABLE gam , 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW cdav 
where
    cdav.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and gam.SCHM_TYPE  in ('OAB','OAP','DDA')
    and gam.ACCT_RPT_CODE not in (Upper ('CASH'),Upper ('TCASH'),Upper('VAULT'))
    and cdav.DEL_FLG = 'N' 
    And Gam.Bank_Id = '01'
   -- and gam.acct_cls_flg = 'N'
    and cdav.TRAN_CRNCY_CODE = Upper(ci_currency )
    and gam.ACID = cdav.ACID 
    and cdav.SOL_ID=ci_branchCode
    and trim(cdav.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd where atd.cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))--Without Reversal
    group by gam.SCHM_TYPE,cdav.TRAN_TYPE, cdav.PART_TRAN_TYPE, cdav.dth_init_sol_id, 
gam.ACCT_NAME, gam.GL_SUB_HEAD_CODE, gam.foracid 
    order by gam.GL_SUB_HEAD_CODE,  substr(gam.foracid,6,length(gam.foracid)-5);
   
   



--------------------------------------------------------------------------------
----------------------------WithReversal----------------------------------------
--------------------------------------------------------------------------------
CURSOR ExtractDataWithReversal (	
			ci_TranDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2)
  IS
select 
   GENERAL_ACCT_MAST_TABLE.SCHM_TYPE as "Account_Type" , 
  sum( CTD_DTD_ACLI_VIEW.TRAN_AMT ) as "Amount" , 
   --substr(GENERAL_ACCT_MAST_TABLE.foracid,6,length(GENERAL_ACCT_MAST_TABLE.foracid)-5) 
   GENERAL_ACCT_MAST_TABLE.foracid as "Account No." , 
   CTD_DTD_ACLI_VIEW.TRAN_TYPE as "Tran_Type" , 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE as "Part_Tran_Type",
   CTD_DTD_ACLI_VIEW.dth_init_sol_id as "Init_Sol_Id",
   GENERAL_ACCT_MAST_TABLE.ACCT_NAME AS "Description",
    GENERAL_ACCT_MAST_TABLE.GL_SUB_HEAD_CODE as "GLSH"
from 
    TBAADM.GENERAL_ACCT_MAST_TABLE GENERAL_ACCT_MAST_TABLE , 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW 
where
    CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and GENERAL_ACCT_MAST_TABLE.SCHM_TYPE  in ('OAB','OAP','DDA')
    and GENERAL_ACCT_MAST_TABLE.ACCT_RPT_CODE not in (Upper ('CASH'),Upper ('TCASH'),Upper('VAULT'))
    and CTD_DTD_ACLI_VIEW.DEL_FLG = 'N' 
    And General_Acct_Mast_Table.Bank_Id = '01'
    --and GENERAL_ACCT_MAST_TABLE.acct_cls_flg = 'N'
    and CTD_DTD_ACLI_VIEW.TRAN_CRNCY_CODE = Upper(ci_currency )
    and GENERAL_ACCT_MAST_TABLE.ACID = CTD_DTD_ACLI_VIEW.ACID 
    and CTD_DTD_ACLI_VIEW.SOL_ID=ci_branchCode
    
    group by GENERAL_ACCT_MAST_TABLE.SCHM_TYPE, --substr(GENERAL_ACCT_MAST_TABLE.foracid,6,length(GENERAL_ACCT_MAST_TABLE.foracid)-5),
    CTD_DTD_ACLI_VIEW.TRAN_TYPE, CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.dth_init_sol_id, 
GENERAL_ACCT_MAST_TABLE.ACCT_NAME, GENERAL_ACCT_MAST_TABLE.GL_SUB_HEAD_CODE, GENERAL_ACCT_MAST_TABLE.foracid 
    order by GENERAL_ACCT_MAST_TABLE.GL_SUB_HEAD_CODE,  
    substr(GENERAL_ACCT_MAST_TABLE.foracid,6,length(GENERAL_ACCT_MAST_TABLE.foracid)-5);



  PROCEDURE FIN_DAY_BOOK_DOMESTIC(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_Account_Type TBAADM.GENERAL_ACCT_MAST_TABLE.SCHM_TYPE%type;
    v_Amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_AccountNumber tbaadm.GENERAL_ACCT_MAST_TABLE.FORACID%type;
     v_Tran_Type tbaadm.CTD_DTD_ACLI_VIEW.TRAN_TYPE%type;
    v_Part_Tran_Type tbaadm.CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE%type;
    v_Description TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_GLSH TBAADM.GENERAL_ACCT_MAST_TABLE.GL_SUB_HEAD_CODE%type;
     v_BranchName tbaadm.sol.sol_desc%type;
    v_BankAddress varchar(200);
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
    v_Init_Sol_Id custom.custom_CTD_DTD_ACLI_VIEW.dth_init_sol_id%type;
      
      
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
    
     vi_TranDate  :=  outArr(0);			
     vi_currency   :=  outArr(1);
     vi_ReversalType := outArr(2);
      vi_BranchCode :=  outArr(3);	
   
   --------------------------------------------------------------------------
   
  if( vi_TranDate is null or vi_currency is null or vi_ReversalType is null or vi_BranchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		            '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
   ----------------------------------------------------------------------------
    
    IF vi_ReversalType like 'Without%' THEN
    --{
   
        IF NOT ExtractDataWithoutReversal%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractDataWithoutReversal (	
          vi_TranDate  , vi_BranchCode  ,vi_currency
         );
          --}
          END;
    
        --}
        END IF;
    
        IF ExtractDataWithoutReversal%ISOPEN THEN
        --{
          FETCH	ExtractDataWithoutReversal
          INTO	 v_Account_Type,v_Amount,
                v_AccountNumber,v_Tran_Type,v_Part_Tran_Type,v_Init_Sol_Id,v_Description,v_GLSH;
          
    
          ------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
          ------------------------------------------------------------------
          IF ExtractDataWithoutReversal%NOTFOUND THEN
          --{
            CLOSE ExtractDataWithoutReversal;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
   
--------------------- With Reversal---------------------------------------------    
    ELSE 
    --{
       
             IF NOT ExtractDataWithReversal%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataWithReversal (	
            vi_TranDate  , vi_BranchCode  ,vi_currency
            );
            --}
            END;
      
          --}
          END IF;
      
          IF ExtractDataWithReversal%ISOPEN THEN
          --{
            FETCH	ExtractDataWithReversal
            INTO	 v_Account_Type,v_Amount,
                  v_AccountNumber,v_Tran_Type,v_Part_Tran_Type,v_Init_Sol_Id,v_Description,v_GLSH;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataWithReversal%NOTFOUND THEN
            --{
              CLOSE ExtractDataWithReversal;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
     --}
    END IF;
    
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into   v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
    END;
    

    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_Account_Type     			|| '|' ||
					v_Amount	|| '|' ||
					v_AccountNumber      			|| '|' ||
          v_Tran_Type    			|| '|' ||
          v_Part_Tran_Type    			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_Init_Sol_Id || '|' ||
          v_Description   || '|' ||
          v_GLSH);
  
			dbms_output.put_line(out_rec);
  END FIN_DAY_BOOK_DOMESTIC;

END FIN_DAY_BOOK_DOMESTIC;
/
