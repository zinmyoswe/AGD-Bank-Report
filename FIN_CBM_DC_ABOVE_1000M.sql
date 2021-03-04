CREATE OR REPLACE PACKAGE                      FIN_CBM_DC_ABOVE_1000M AS 

 PROCEDURE FIN_CBM_DC_ABOVE_1000M (	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CBM_DC_ABOVE_1000M;
 
/


CREATE OR REPLACE PACKAGE BODY                                           FIN_CBM_DC_ABOVE_1000M AS



-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
	vi_StartDate		Varchar2(10);		    	    -- Input to procedure
  vi_EndDate		Varchar2(10);		    	    -- Input to procedure


-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData 
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_StartDate VARCHAR2 ,ci_EndDate VARCHAR2,ci_currency VARCHAR2)
  IS
  select GAM.ACCT_NAME AS "AccountName" ,
         GAM.FORACID AS "FORACID",
         CTD.TRAN_AMT as "TranAmt",  
         CTD.TRAN_TYPE as "Tran_Type" , 
         CTD.PART_TRAN_TYPE as "Part_Tran_Type",
         CTD.dth_init_sol_id as "Init_Sol_Id",
         CTD.sol_id as "BranchName"
  from   custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD, TBAADM.GAM GAM
  WHERE  CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and    CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and    GAM.SCHM_TYPE = 'LAA'
  AND    CTD.ACID = GAM.ACID
  and    CTD.TRAN_AMT >= 100000000
  and    CTD.TRAN_CRNCY_CODE = Upper(ci_currency )
  and    GAM.ENTITY_CRE_FLG = 'Y'
  and    GAM.DEL_FLG ='N'
  and    GAM.BANK_ID = '01'
  ORDER BY GAM.FORACID;
  
  PROCEDURE FIN_CBM_DC_ABOVE_1000M (	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_Amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_Tran_Type TBAADM.CTD_DTD_ACLI_VIEW.TRAN_TYPE%type;
    v_Part_Tran_Type TBAADM.CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE%type; 
    v_Init_Sol_Id TBAADM.CTD_DTD_ACLI_VIEW.dth_init_sol_id%type;
    v_BranchName TBAADM.CTD_DTD_ACLI_VIEW.SOL_ID%type;  
      
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
     vi_currency   :=  outArr(2);
   
-----------------------------------------------------------------------------------------------------


if( vi_StartDate is null or vi_EndDate is null or vi_currency is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;


-------------------------------------------------------------------------------
   
        IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData(	
          vi_StartDate, vi_EndDate    ,vi_currency
         );
          --}
          END;
    
        --}
        END IF;
    
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO	 v_AccountName,v_AccountNumber,v_Amount,
               v_Tran_Type,v_Part_Tran_Type,v_Init_Sol_Id,v_BranchName;
          
  
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
     --} 

     
     
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_AccountName     			|| '|' ||
          v_AccountNumber      			|| '|' ||
					v_Amount	|| '|' ||
          v_Tran_Type    			|| '|' ||
          v_Part_Tran_Type    			|| '|' ||
					v_BranchName	|| '|' ||
          v_Init_Sol_Id 
         );
  
			dbms_output.put_line(out_rec);
  END FIN_CBM_DC_ABOVE_1000M;

END FIN_CBM_DC_ABOVE_1000M;
/
