CREATE OR REPLACE PACKAGE               FIN_DL_CASH_IN_HAND_CONDITION AS 

PROCEDURE FIN_DL_CASH_IN_HAND_CONDITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DL_CASH_IN_HAND_CONDITION;
 
/


CREATE OR REPLACE PACKAGE BODY               FIN_DL_CASH_IN_HAND_CONDITION AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure

    
-----------------------------------------------------------------------------
-- CURSOR declaration 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
  SELECT 
        T.EDDate,
         SUM(T.CAA)/1000000,
         SUM(T.SBA)/1000000,
         SUM(T.TDA1)/1000000,
         SUM(T.TDA3)/1000000,
         SUM(T.TDA6)/1000000,
         SUM(T.TDA9)/1000000,
         SUM(T.TDA12)/1000000,
         SUM(T.FCYUSD)/1000000,
         SUM(T.FCYEUR)/1000000,
         SUM(T.FCYSGD)/1000000,
         SUM(T.FCYTHB)/1000000,
         SUM(T.FCYMYR)/1000000,
         SUM(T.LOAN)/1000000,
         SUM(T.OD)/1000000,
         SUM(T.HP)/1000000,
         SUM(T.SL)/1000000,
         SUM(T.CashInHand)/1000000,
         SUM(T.CBM)/1000000,
         SUM(T.DOMESTIC)/1000000,
         SUM(T.ABROAD)/1000000
FROM (
 Select P.EDDate AS EDDate,
         SUM(P.CAA) as CAA ,
         SUM(P.SBA) AS SBA,
         SUM(P.TDA1) AS TDA1,
         SUM(P.TDA3) AS TDA3,
         SUM(P.TDA6) AS TDA6,
         SUM(P.TDA9) AS TDA9,
         SUM(P.TDA12)AS TDA12,
         SUM(P.FCYUSD) AS FCYUSD,
         SUM(P.FCYEUR) AS FCYEUR,
         SUM(P.FCYSGD)AS FCYSGD,
         SUM(P.FCYTHB)AS FCYTHB ,
         SUM(P.FCYMYR)AS FCYMYR,
         SUM(P.LOAN)AS LOAN,
         SUM(P.OD)AS OD,
         SUM(P.HP)AS HP,
         SUM(P.SL)AS SL,
         SUM(P.CashInHand)AS CashInHand,
         SUM(P.CBM)AS CBM,
         SUM(P.DOMESTIC)AS DOMESTIC,
         SUM(P.ABROAD) AS ABROAD
      
FROM (
      SELECT EAB.EOD_DATE as EDDate,
              case  when  GAM.SCHM_TYPE = 'CAA' then ABS(EAB.TRAN_DATE_BAL) else 0 end as CAA,
              CASE  WHEN  GAM.SCHM_TYPE = 'SBA' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS SBA,
              0 AS TDA1,
               0 AS TDA3,
               0 AS TDA6,
               0 AS TDA9,
               0 AS TDA12,
              CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS FCYUSD,
              CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS FCYEUR,
              CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS FCYSGD,
              CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS FCYTHB,
              CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS FCYMYR,
              CASE  WHEN  GAM.SCHM_CODE LIKE 'AGDNL' OR GAM.ACCT_CRNCY_CODE = 'MMK'  THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS LOAN,
              CASE  WHEN  GAM.SCHM_CODE LIKE 'AGDOD' OR GAM.ACCT_CRNCY_CODE = 'MMK'  THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS OD,
              CASE  WHEN  GAM.SCHM_CODE LIKE 'AGDHP' OR GAM.ACCT_CRNCY_CODE = 'MMK' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS HP,
              CASE  WHEN  GAM.SCHM_CODE LIKE 'AGDS%' OR GAM.ACCT_CRNCY_CODE = 'MMK'  THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS SL,
              CASE  WHEN  GAM.GL_SUB_HEAD_CODE ='10101' or GAM.GL_SUB_HEAD_CODE ='10105' or GAM.GL_SUB_HEAD_CODE ='10143'  THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS CashInHand,
              CASE  WHEN  GAM.GL_SUB_HEAD_CODE ='10106'  THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS CBM,
              CASE  WHEN  (GAM.GL_SUB_HEAD_CODE ='10109' OR  GAM.GL_SUB_HEAD_CODE ='10111' OR
              GAM.GL_SUB_HEAD_CODE ='10112' OR GAM.GL_SUB_HEAD_CODE ='10110' OR GAM.GL_SUB_HEAD_CODE ='10113')AND GAM.ACCT_CRNCY_CODE = 'MMK' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS DOMESTIC,
               CASE  WHEN  (gam.GL_SUB_HEAD_CODE like  '1013_' OR  GAM.GL_SUB_HEAD_CODE ='10140' OR
              GAM.GL_SUB_HEAD_CODE ='10141' OR GAM.GL_SUB_HEAD_CODE ='10142')AND GAM.ACCT_CRNCY_CODE = 'MMK' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS ABROAD
              
      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM 
      WHERE  EAB.ACID = GAM.ACID
      AND    EAB.EOD_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
      AND    EAB.EOD_DATE <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
      AND    gam.del_flg = 'N'
      and    gam.acct_cls_flg = 'N'
      and    gam.bank_id ='01'
      )P
  GROUP BY P.EDDate
      
      UNION ALL
    Select Q.EDDate,
         SUM(Q.CAA),
         SUM(Q.SBA),
         SUM(Q.TDA1),
         SUM(Q.TDA3),
         SUM(Q.TDA6),
         SUM(Q.TDA9),
         SUM(Q.TDA12),
         SUM(Q.FCYUSD),
         SUM(Q.FCYEUR),
         SUM(Q.FCYSGD),
         SUM(Q.FCYTHB),
         SUM(Q.FCYMYR),
         SUM(Q.LOAN),
         SUM(Q.OD),
         SUM(Q.HP),
         SUM(Q.SL),
         SUM(Q.CashInHand),
         SUM(Q.CBM),
         SUM(Q.DOMESTIC),
         SUM(Q.ABROAD)
      
FROM (  
      SELECT EAB.EOD_DATE as EDDate,
              0 as CAA,
              0 AS SBA,
               CASE  WHEN  GAM.SCHM_TYPE = 'TDA' AND TD.DEPOSIT_PERIOD_MTHS = '1' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS TDA1,
               CASE  WHEN  GAM.SCHM_TYPE = 'TDA' AND TD.DEPOSIT_PERIOD_MTHS = '3' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS TDA3,
               CASE  WHEN  GAM.SCHM_TYPE = 'TDA' AND TD.DEPOSIT_PERIOD_MTHS = '6' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS TDA6,
               CASE  WHEN  GAM.SCHM_TYPE = 'TDA' AND TD.DEPOSIT_PERIOD_MTHS = '9' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS TDA9,
               CASE  WHEN  GAM.SCHM_TYPE = 'TDA' AND TD.DEPOSIT_PERIOD_MTHS = '12' THEN ABS(EAB.TRAN_DATE_BAL) ELSE 0 END AS TDA12,
              0 AS FCYUSD,
              0 AS FCYEUR,
              0 AS FCYSGD,
              0 AS FCYTHB,
              0 AS FCYMYR,
              0 AS LOAN,
              0 AS OD,
              0 AS HP,
              0 AS SL,
              0 AS CashInHand,
              0 AS CBM,
              0 AS DOMESTIC,
              0 AS ABROAD
              
      FROM   TBAADM.EAB EAB, TBAADM.GAM GAM ,TBAADM.TD_ACCT_MASTER_TABLE TD
      WHERE  EAB.ACID = GAM.ACID
      AND    GAM.ACID = TD.ACID
      AND    EAB.EOD_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
      AND    EAB.EOD_DATE <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
      AND    gam.del_flg = 'N'
      and    gam.acct_cls_flg = 'N'
      and    gam.bank_id ='01'
      )Q
    GROUP BY Q.EDDATE
  )T
  GROUP BY T.EDDATE;

  PROCEDURE FIN_DL_CASH_IN_HAND_CONDITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
         v_EDDate   TBAADM.EAB.EOD_DATE%TYPE;
         v_CAA      NUMBER(20,2);--TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_SBA      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_TDA1      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_TDA3      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_TDA6      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_TDA9      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_TDA12      TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_FCYUSD   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_FCYEUR   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_FCYSGD   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_FCYTHB   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_FCYMYR   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_LOAN     TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_OD       TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_HP       TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_SL         TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_CashInHand TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_CBM        TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_DOMESTIC   TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         v_ABROAD     TBAADM.EAB.TRAN_DATE_BAL%TYPE;
         
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
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);		
  
 ---------------------------------------------------------------------------------------------------
 if( vi_startDate is null or vi_endDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0  || '|' || 0 || '|' ||
                 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0  || '|' || 0 || '|' ||
                    0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0  || '|' || 0 );
		
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
			vi_startDate , vi_endDate  );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{

			FETCH	ExtractData
			INTO	 v_EDDate,v_CAA,v_SBA,v_TDA1,v_TDA3,v_TDA6,v_TDA9,v_TDA12
            ,v_FCYUSD,v_FCYEUR,v_FCYSGD,v_FCYTHB,v_FCYMYR,v_LOAN,v_OD,v_HP,v_SL,v_CashInHand,v_CBM,
            v_DOMESTIC,v_ABROAD;
      

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
    /* BEGIN
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
         SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
    */
 
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_EDDate     			|| '|' ||
					v_CAA	            || '|' ||
          v_SBA             || '|' ||
					v_TDA1      			|| '|' ||
          v_FCYUSD   			  || '|' ||
          v_FCYEUR    			|| '|' ||
          v_FCYSGD    			|| '|' ||
          v_FCYTHB          || '|' ||
          v_FCYMYR          || '|' ||
					v_LOAN	          || '|' ||
					v_OD      			  || '|' ||
					v_HP              || '|' ||
          v_SL              || '|' ||
          v_CashInHand      || '|' ||
          v_CBM             || '|' ||
          v_DOMESTIC        || '|' ||
          v_ABROAD          || '|' ||
           v_TDA3           || '|' ||
          v_TDA6            || '|' ||
          v_TDA9            || '|' ||
          v_TDA12           
          );
  
			dbms_output.put_line(out_rec);
  END FIN_DL_CASH_IN_HAND_CONDITION;

END FIN_DL_CASH_IN_HAND_CONDITION;
/
