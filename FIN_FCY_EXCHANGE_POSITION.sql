CREATE OR REPLACE PACKAGE        FIN_FCY_EXCHANGE_POSITION AS 

  PROCEDURE FIN_FCY_EXCHANGE_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FCY_EXCHANGE_POSITION;
/


CREATE OR REPLACE PACKAGE BODY                                           FIN_FCY_EXCHANGE_POSITION AS
/******************************************************************************
 NAME:       FIN_FCY_ASSETS_AND_LIABILITIES
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
    --- temporary used CUST_FOREIGN_EP
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_tranDate       VARCHAR2(10);               -- Input to procedure
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_FCY_ASSETS_AND_LIABILITIES CURSOR
--------------------------------------------------------------------------------
AUSD   NUMBER(20,2);
AEUR   NUMBER(20,2);
ASGD   NUMBER(20,2);
AJPY   NUMBER(20,2);
ATHB   NUMBER(20,2);
AMYR   NUMBER(20,2);
GL     VARCHAR2(60);

v_glName VARCHAR2(254);
      v_aUSD number := 0;
      v_aEUR number := 0;
      v_aSGD number := 0;
      v_aMYR number := 0;
      v_aTHB number := 0;
      v_aJPY number := 0;
v_description VARCHAR2(20);
increase Number;
--------------------------------------------------------------------------------
 
----------------cursor for Result------------------
CURSOR ExtractDataResult IS
select GLNAME ,abs(AUSD), abs(AEURO) ,abs(ASGD), abs(AJPY), abs(ATHB) ,abs(AMYR)
from CUSTOM.CUST_FOREIGN_EP RPT order by rpt.GLNAME;

---------------------------------Function ASSET---------------------------------------
 FUNCTION ASSETONE(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
     BEGIN
     SELECT ABC as GL,
        SUM(ABS(USD)),SUM(ABS(EUR)),SUM(ABS(SGD)),SUM(ABS(JPY)),SUM(ABS(THB)),SUM(ABS(MYR))
        INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
    FROM (
      SELECT  GSTT.GL_SUB_HEAD_CODE ,
              case when  GSTT.CRNCY_CODE = 'USD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as USD,
              case when  GSTT.CRNCY_CODE = 'EUR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as EUR,
              case when  GSTT.CRNCY_CODE = 'SGD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as SGD,
              case when  GSTT.CRNCY_CODE = 'JPY' then   abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as JPY,
              case when  GSTT.CRNCY_CODE = 'THB' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as THB,
              case when  GSTT.CRNCY_CODE = 'MYR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as INR
      FROM    TBAADM.GSTT GSTT
      WHERE   GSTT.GL_SUB_HEAD_CODE  = GLCODE 
      AND     gstt.BAL_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND     GSTT.END_BAL_DATE >=TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      
    )Q
  GROUP BY ABC
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       GL   := ABC;
       AUSD := 0.0;
       AEUR := 0.0;
       ASGD := 0.0;
       AJPY := 0.0;
       ATHB := 0.0;
       AMYR := 0.0;
    end;
  INSERT INTO CUSTOM.CUST_FOREIGN_EP 
  VALUES (GL, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR,ci_RowNumber);
  RETURN v_returnValue; 
END ASSETONE;


---------------------------------Function---------------------------------------
 FUNCTION ASSETGROUP(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
     BEGIN
     SELECT ABC as GL,
          sum(USD), SUM(EUR), SUM(SGD), SUM(JPY), SUM(THB),SUM(MYR)
          INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
     FROM (
         SELECT  
              case when  GAM.ACCT_CRNCY_CODE = 'USD' then   Tran_date_bal else 0 end as USD,
              case when  GAM.ACCT_CRNCY_CODE = 'EUR' then   Tran_date_bal else 0 end as EUR,
              case when  GAM.ACCT_CRNCY_CODE = 'SGD' then   Tran_date_bal else 0 end as SGD,
              case when  GAM.ACCT_CRNCY_CODE = 'JPY' then   Tran_date_bal else 0 end as JPY,
              case when  GAM.ACCT_CRNCY_CODE = 'THB' then   Tran_date_bal else 0 end as THB,
              case when  GAM.ACCT_CRNCY_CODE = 'MYR' then   Tran_date_bal else 0 end as MYR,
                    case when  GAM.ACCT_CRNCY_CODE= 'INR' then    Tran_date_bal else 0 end as INR
                    --TRAN_DATE_TOT_TRAN--TRAN_DATE_TOT_TRAN
         FROM  TBAADM.EAB EAB, TBAADM.GAM GAM
         WHERE EAB.ACID = GAM.ACID 
         AND   EAB.EOD_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
         AND   EAB.END_EOD_DATE >=  TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
         AND   GAM.FORACID LIKE GLCODE || '%'
         AND   GAM.DEL_FLG = 'N'
         AND   GAM.ENTITY_CRE_FLG = 'Y'
         AND   EAB.BANK_ID = '01'
         AND   GAM.BANK_ID = '01'
         )Q
   GROUP BY ABC
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       GL   := ABC;
       AUSD := 0.0;
       AEUR := 0.0;
       ASGD := 0.0;
       AJPY := 0.0;
       ATHB := 0.0;
       AMYR := 0.0;
    end;
  INSERT INTO CUSTOM.CUST_FOREIGN_EP 
  VALUES (GL, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR,ci_RowNumber);
  RETURN v_returnValue; 
END ASSETGROUP;



FUNCTION ASSETALL(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
     BEGIN
     SELECT ABC as GL,
        SUM(ABS(USD)),SUM(ABS(EUR)),SUM(ABS(SGD)),SUM(ABS(JPY)),SUM(ABS(THB)),SUM(ABS(MYR))
        INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
    FROM (
      SELECT  GSTT.GL_SUB_HEAD_CODE ,
              case when  GSTT.CRNCY_CODE = 'USD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as USD,
              case when  GSTT.CRNCY_CODE = 'EUR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as EUR,
              case when  GSTT.CRNCY_CODE = 'SGD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as SGD,
              case when  GSTT.CRNCY_CODE = 'JPY' then   abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as JPY,
              case when  GSTT.CRNCY_CODE = 'THB' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as THB,
              case when  GSTT.CRNCY_CODE = 'MYR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as INR
      FROM    TBAADM.GSTT GSTT
      WHERE   GSTT.GL_SUB_HEAD_CODE  in ( select gl_sub_head_code from custom.coa_mp where group_code = GLCODE and cur <>  'MMK')
      AND     gstt.BAL_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND     GSTT.END_BAL_DATE >=TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      
    )Q
  GROUP BY ABC
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       GL   := ABC;
       AUSD := 0.0;
       AEUR := 0.0;
       ASGD := 0.0;
       AJPY := 0.0;
       ATHB := 0.0;
       AMYR := 0.0;
    end;
  INSERT INTO CUSTOM.CUST_FOREIGN_EP 
  VALUES (GL,AUSD, AEUR,ASGD,AJPY, ATHB, AMYR,ci_RowNumber);
  RETURN v_returnValue; 
END ASSETALL;


FUNCTION CashInHand(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
      BEGIN
     SELECT ABC as GL,
        SUM(ABS(USD)),SUM(ABS(EUR)),SUM(ABS(SGD)),SUM(ABS(JPY)),SUM(ABS(THB)),SUM(ABS(MYR))
        INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
    FROM (
      SELECT  GSTT.GL_SUB_HEAD_CODE ,
              case when  GSTT.CRNCY_CODE = 'USD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as USD,
              case when  GSTT.CRNCY_CODE = 'EUR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as EUR,
              case when  GSTT.CRNCY_CODE = 'SGD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as SGD,
              case when  GSTT.CRNCY_CODE = 'JPY' then   abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as JPY,
              case when  GSTT.CRNCY_CODE = 'THB' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as THB,
              case when  GSTT.CRNCY_CODE = 'MYR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as INR
      FROM    TBAADM.GSTT GSTT
      WHERE   (GSTT.GL_SUB_HEAD_CODE,GSTT.CRNCY_CODE)  in ( select gl_sub_head_code,CUR from custom.coa_mp where group_code = 'A02' and cur <>  'MMK')
      AND     gstt.sol_id <> '20300'
      AND     gstt.BAL_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND     GSTT.END_BAL_DATE >=TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      
    )Q
  GROUP BY ABC
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       GL   := ABC;
       AUSD := 0.0;
       AEUR := 0.0;
       ASGD := 0.0;
       AJPY := 0.0;
       ATHB := 0.0;
       AMYR := 0.0;
    end;
  INSERT INTO CUSTOM.CUST_FOREIGN_EP 
  VALUES (GL,AUSD, AEUR,ASGD,AJPY, ATHB, AMYR,ci_RowNumber);
  RETURN v_returnValue; 
END CashInHand;

FUNCTION CashInHandIBD(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
      BEGIN
     SELECT ABC as GL,
        SUM(ABS(USD)),SUM(ABS(EUR)),SUM(ABS(SGD)),SUM(ABS(JPY)),SUM(ABS(THB)),SUM(ABS(MYR))
        INTO GL,AUSD,AEUR,ASGD,AJPY,ATHB,AMYR
    FROM (
      SELECT  GSTT.GL_SUB_HEAD_CODE ,
              case when  GSTT.CRNCY_CODE = 'USD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as USD,
              case when  GSTT.CRNCY_CODE = 'EUR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as EUR,
              case when  GSTT.CRNCY_CODE = 'SGD' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as SGD,
              case when  GSTT.CRNCY_CODE = 'JPY' then   abs(gstt.TOT_CR_BAL)-    abs(gstt.TOT_DR_BAL) else 0 end as JPY,
              case when  GSTT.CRNCY_CODE = 'THB' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as THB,
              case when  GSTT.CRNCY_CODE = 'MYR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as MYR
              --case when  GSTT.CRNCY_CODE = 'INR' then   abs(gstt.TOT_CR_BAL) -   abs(gstt.TOT_DR_BAL) else 0 end as INR
      FROM    TBAADM.GSTT GSTT
      WHERE   (GSTT.GL_SUB_HEAD_CODE,GSTT.CRNCY_CODE)  in ( select gl_sub_head_code,CUR from custom.coa_mp where group_code = 'A02' and cur <>  'MMK')
      AND     gstt.sol_id = '20300'
      AND     gstt.BAL_DATE <= TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      AND     GSTT.END_BAL_DATE >=TO_DATE(CAST(ci_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
      
    )Q
  GROUP BY ABC
    ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       GL   := ABC;
       AUSD := 0.0;
       AEUR := 0.0;
       ASGD := 0.0;
       AJPY := 0.0;
       ATHB := 0.0;
       AMYR := 0.0;
    end;
  INSERT INTO CUSTOM.CUST_FOREIGN_EP 
  VALUES (GL,AUSD, AEUR,ASGD,AJPY, ATHB, AMYR,ci_RowNumber);
  RETURN v_returnValue; 
END CashInHandIBD;
--------------------------------------------------------------------------------

 

  PROCEDURE FIN_FCY_EXCHANGE_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
      
      v_aTOTAL number := 0;
      v_usdRate number := 1;
      v_eurRate number := 1;
      v_sgdRate number := 1;
      v_jpyRate number := 1;
      v_thbRate number := 1;
      v_myrRate number := 1;
       out_put Varchar2(60);
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
    
    vi_tranDate :=outArr(0);			    	
 
 ------------------------------------------------------------------
 if( vi_tranDate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
                   0 || '|' || 0 );
					
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

-------------------------------you can add new account code here ******------------------------------------  
     increase  := 0;
     DELETE FROM CUSTOM.CUST_FOREIGN_EP;
     
      out_put := ASSETONE('A/C With CBM',vi_tranDate,'10107',increase);
      increase := increase + 1;
      
      out_put := ASSETONE('A/C With MFTB',vi_tranDate,'10113',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With MICB',vi_tranDate,'10112',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With CB',vi_tranDate,'10145',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With UAB',vi_tranDate,'10146',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With AYA',vi_tranDate,'10147',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With KBZ',vi_tranDate,'10148',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With KasiKon',vi_tranDate,'10133',increase);
       increase := increase + 1;
      
      out_put := ASSETGROUP('A/C With May Bank(Malaysia)',vi_tranDate,'2030010131023012',increase);
       increase := increase + 1;
       
       Out_Put := Assetgroup('A/C With SHINHAN BANK(YGN BR)',Vi_Trandate,'2030010161034012',Increase);
       increase := increase + 1;
      
      out_put := ASSETGROUP('A/C With May Bank(Singapoor)',vi_tranDate,'203001013102302',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With OCBC',vi_tranDate,'10135',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With OCBC(North Branch)',vi_tranDate,'10136',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With CIMB(Islamic)',vi_tranDate,'10137',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With CIMB',vi_tranDate,'10132',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With Bangkok Bank',vi_tranDate,'10134',increase);
       increase := increase + 1;
      
     -- out_put := ASSETALL('Charges A/C',vi_tranDate,'A50',increase);
       --increase := increase + 1;
      
      out_put := ASSETONE('A/C With KBZ (CPU Settlement)',vi_tranDate,'10128',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With MOB(JCB Card Settlement)',vi_tranDate,'10129',increase);
       increase := increase + 1;
       
       Out_Put := Assetgroup('A/C With UOB',Vi_Trandate,'203001013002201',Increase);
       increase := increase + 1;
       
       Out_Put := Assetgroup('A/C With UOB UPI',Vi_Trandate,'2030010130022022',Increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With Commerz(Germany)',vi_tranDate,'10141',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With Siam Commerical Bank',vi_tranDate,'10139',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('A/C With DBS',vi_tranDate,'10140',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('Guarantee Deposit',vi_tranDate,'10142',increase);
       increase := increase + 1;
      
      out_put := ASSETONE('Trade Finance',vi_tranDate,'10313',increase);
      increase := increase + 1;
      
      out_put := ASSETONE('Trade Finance(TT)',vi_tranDate,'10314',increase);
     -- out_put := ASSETGROUP('Guarantee (FC) Contra A/C',vi_tranDate,'203009000603001',increase);
      -- increase := increase + 1;
      
      --out_put := ASSETGROUP('Import Credit (External) Contra A/C',vi_tranDate,'203009000602001',increase);
      -- increase := increase + 1;
      
      --out_put := ASSETONE('Trade Finance',vi_tranDate,'10313',increase);
      -- increase := increase + 1;
      
      --out_put := ASSETONE('Cash In Hand At Agencies',vi_tranDate,'10104',2);
      
      out_put := ASSETONE('Cash In Transit',vi_tranDate,'10105',increase);
      increase := increase + 1;
      
      out_put := CashInHand('Cash In Money Changer Counter',vi_tranDate,'A02',increase);
      increase := increase + 1;
      
      out_put := CashInHandIBD('Cash In Vault',vi_tranDate,'A02',increase);
      increase := increase + 1;
      
      Out_Put := Assetgroup('A/C WITH GTEEDEP OCBC VISA',Vi_Trandate,'203001014201001',Increase);
       Increase := Increase + 1;
       
       Out_Put := Assetgroup('A/C WITH GTEEDEP UOB Master',Vi_Trandate,'2030010142010032',Increase);
       increase := increase + 1;
       
       Out_Put := Assetgroup('A/C WITH GTEEDEP UOB(UPI)',Vi_Trandate,'2030010142010033',Increase);
       increase := increase + 1;
      
--------------------------------------------------------------------------------
      COMMIT;
      
--------------------------------------------------------------------------------    
    
    IF NOT ExtractDataResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataResult;
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataResult%ISOPEN THEN
		--{
			FETCH	ExtractDataResult
			INTO v_glName, v_aUSD, v_aEUR, v_aSGD,v_aJPY, v_aTHB,v_aMYR;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataResult;
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
      SELECT 
         BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 AS "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM AS "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM AS "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      FROM
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         AND SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         AND SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         AND SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;
-------------------------------------------------------------------------------
    -- GET EXCHANGE RATE INFORMATION
-------------------------------------------------------------------------------
    BEGIN
SELECT r.VAR_CRNCY_UNITS INTO v_usdRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('USD') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
     
                                      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_aUSD := 0;
    END;
    BEGIN

           SELECT r.VAR_CRNCY_UNITS INTO v_eurRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('EUR') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
                                      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_eurRate := 0;
    END;
    BEGIN

            SELECT r.VAR_CRNCY_UNITS INTO v_sgdRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('SGD') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
                                                                        EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_sgdRate := 0;
    END;
    BEGIN
 
            SELECT r.VAR_CRNCY_UNITS INTO v_jpyRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('JPY') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
                                                                      
                                                                      
                      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_jpyRate := 0;
    END;
    BEGIN
     
             SELECT r.VAR_CRNCY_UNITS INTO v_thbRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('THB') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
                                                                        EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_thbRate := 0;
    END;
    BEGIN
            SELECT r.VAR_CRNCY_UNITS INTO v_myrRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('MYR') and r.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code  );
                                                                        EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_myrRate := 0;
    END;
    
    out_rec:=	(
                v_glName 		      	|| '|' ||
                v_aUSD      		  	|| '|' ||
                v_aEUR	            || '|' ||
                v_aSGD              || '|' ||
                v_aJPY              || '|' ||
                v_aTHB              || '|' ||
                v_aMYR              || '|' ||
                v_usdRate      			|| '|' ||
                v_eurRate	          || '|' ||
                v_sgdRate           || '|' ||
                v_jpyRate           || '|' ||
                v_thbRate            || '|' ||
                v_myrRate);
         
			dbms_output.put_line(out_rec);
  END FIN_FCY_EXCHANGE_POSITION;

END FIN_FCY_EXCHANGE_POSITION;
/
