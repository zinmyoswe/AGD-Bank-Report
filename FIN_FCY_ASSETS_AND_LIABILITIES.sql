CREATE OR REPLACE PACKAGE        FIN_FCY_ASSETS_AND_LIABILITIES AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_FCY_ASSETS_AND_LIABILITIES(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 );

END FIN_FCY_ASSETS_AND_LIABILITIES;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                        FIN_FCY_ASSETS_AND_LIABILITIES AS
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
    --- temporary used cust_fcy_asset_liabilities_tmp
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
--------------------------------------------------------------------------------

-----------------cursor------------------
  CURSOR ExtractDataResult IS
select GLNAME ,abs(AUSD), abs(AEURO) ,abs(ASGD), abs(AJPY), abs(ATHB) ,abs(AMYR), abs(LUSD) ,abs(LEURO), abs(LSGD), abs(LJPY), abs(LTHB), abs(LMYR)
from CUSTOM.cust_fcy_asset_liabilities_tmp RPT order by rpt.id;


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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, 0.00,  0.00, 0.00, 0.00, 0.00, 0.00,ci_RowNumber);
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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, 0.00,  0.00, 0.00, 0.00, 0.00, 0.00,ci_RowNumber);
  RETURN v_returnValue; 
END ASSETGROUP;



FUNCTION ASSETALL(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ABC;
  BEGIN
     BEGIN
     SELECT ABC as GL,
         ABS(SUM(USD)),ABS(SUM(EUR)),ABS(SUM(SGD)),ABS(SUM(JPY)),ABS(SUM(THB)),ABS(SUM(MYR))
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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL,AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, 0.00,  0.00, 0.00, 0.00, 0.00, 0.00,ci_RowNumber);
  RETURN v_returnValue; 
END ASSETALL;

--------------------------------------------------------------------------------


----------------------------------Lia Function----------------------------------

 FUNCTION LIAONE(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL,0.00,  0.00, 0.00, 0.00, 0.00, 0.00, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, ci_RowNumber);
  RETURN v_returnValue; 
END LIAONE;



 FUNCTION LIAGROUP(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL,0.00,  0.00, 0.00, 0.00, 0.00, 0.00, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, ci_RowNumber);
  RETURN v_returnValue; 
END LIAGROUP;



FUNCTION LIAALL(ABC VARCHAR2,ci_TranDate VARCHAR2,GLCODE VARCHAR2,ci_RowNumber VARCHAR2)
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
  INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
  VALUES (GL,0.00,  0.00, 0.00, 0.00, 0.00, 0.00, AUSD, AEUR,ASGD,AJPY, ATHB, AMYR, ci_RowNumber);
  RETURN v_returnValue; 
END LIAALL;
--------------------------------------------------------------------------------  
  
  PROCEDURE FIN_FCY_ASSETS_AND_LIABILITIES(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_glName VARCHAR2(254);
  v_aUSD number := 0;
  v_aEUR number := 0;
  v_aSGD number := 0;
  v_aMYR number := 0;
  v_aTHB number := 0;
  v_aJPY number := 0;
  v_aTOTAL number := 0;
  v_lUSD number := 0;
  v_lEUR number := 0;
  v_lSGD number := 0;
  v_lMYR number := 0;
  v_lTHB number := 0;
  v_lJPY number := 0;
  v_lTOTAL number := 0;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  v_usdRate number := 1;
  v_eurRate number := 1;
  v_sgdRate number := 1;
  v_jpyRate number := 1;
  v_thbRate number := 1;
  v_myrRate number := 1;
  out_put Varchar2(60);
  
  BEGIN
  ------------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
  ------------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);    
  ------------------------------------------------------------------------------
		-- Parsing the i/ps from the string
	------------------------------------------------------------------------------
    
    vi_tranDate    :=  outArr(0);
    DELETE FROM CUSTOM.cust_fcy_asset_liabilities_tmp;
     INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
    VALUES ('ASSET', 0.00, 0.00,0.00,0.00, 0.00, 0.00, 0.00,  0.00, 0.00, 0.00, 0.00, 0.00,0);
    
    
      out_put := ASSETALL('Cash In Hand Foreign Currency',vi_tranDate,'A02',1);
      
      out_put := ASSETONE('Cash In Hand At Agencies',vi_tranDate,'10104',2);
      
      out_put := ASSETONE('Cash In Transit',vi_tranDate,'10105',3);
      
      out_put := ASSETONE('A/C With CBM',vi_tranDate,'10107',4);
      
      out_put := ASSETONE('A/C With MFTB',vi_tranDate,'10113',5);
      
      out_put := ASSETONE('A/C With MICB',vi_tranDate,'10112',6);
      
      out_put := ASSETONE('A/C With CB',vi_tranDate,'10145',7);
      
      out_put := ASSETONE('A/C With UAB',vi_tranDate,'10146',8);
      
      out_put := ASSETONE('A/C With AYA',vi_tranDate,'10147',9);
      
      out_put := ASSETONE('A/C With KBZ',vi_tranDate,'10148',10);
      
      out_put := ASSETONE('A/C With KasiKon',vi_tranDate,'10133',11);
      
      out_put := ASSETGROUP('A/C With May Bank(Malaysia)',vi_tranDate,'2030010131023012',12);
      
      out_put := ASSETGROUP('A/C With May Bank(Singapoor)',vi_tranDate,'203001013102302',13);
      
      out_put := ASSETONE('A/C With OCBC',vi_tranDate,'10135',14);
      
      out_put := ASSETONE('A/C With OCBC(North Branch)',vi_tranDate,'10136',15);
      
      out_put := ASSETONE('A/C With CIMB(Islamic)',vi_tranDate,'10137',16);
      
      out_put := ASSETONE('A/C With CIMB',vi_tranDate,'10132',17);
      
      out_put := ASSETONE('A/C With Bangkok Bank',vi_tranDate,'10134',18);
      
      out_put := ASSETALL('Charges A/C',vi_tranDate,'A50',19);
      
      out_put := ASSETONE('A/C With KBZ (CPU Settlement)',vi_tranDate,'10128',20);
      
      out_put := ASSETONE('A/C With MOB(JCB Card Settlement)',vi_tranDate,'10129',21);
      
      --out_put := ASSETONE('A/C With UOB',vi_tranDate,'10130',22);
      
       out_put := ASSETGROUP('A/C With UOB',vi_tranDate,'203001013002201',22);
       
       out_put := ASSETGROUP('A/C With UOB BANK(UPI)',vi_tranDate,'203001013002202',23);
      
      out_put := ASSETONE('A/C With Commerz(Germany)',vi_tranDate,'10141',24);
      
      out_put := ASSETONE('A/C With Siam Commerical Bank',vi_tranDate,'10139',25);
      
      out_put := ASSETONE('A/C With DBS',vi_tranDate,'10140',26);
      
      out_put := ASSETONE('Prepaid Deposit A/c',vi_tranDate,'10319',26);
      
       Out_Put := Assetgroup('A/C With INDIA BANK',Vi_Trandate,'203001016003301',27);
      
       Out_Put := Assetgroup('Nostro A/C With KOOKMIN BANK',Vi_Trandate,'2030010162035012',27);
      
       out_put := ASSETGROUP('A/C With SHINHAN BANK(YGN BR)',vi_tranDate,'2030010161034012',28);
       
       out_put := ASSETGROUP('A/C With MAY BANK(YGN BR)',vi_tranDate,'2030010131023032',28);
       
      out_put := ASSETONE('Guarantee Deposit',vi_tranDate,'10142',28);
      
      out_put := ASSETGROUP('Guarantee External (FC) Contra A/C',vi_tranDate,'203009000603001',29);
      
      out_put := ASSETGROUP('Import Credit (External) Contra A/C',vi_tranDate,'203009000602001',30);
      
      out_put := ASSETONE('Trade Finance',vi_tranDate,'10313',31);
      
      Out_Put := Assetone('Trade Finance(TT)',Vi_Trandate,'10314',32);
      
      
      
--------------------------------------------------------------------------------
      INSERT INTO CUSTOM.cust_fcy_asset_liabilities_tmp 
     VALUES ('Liabilities', 0.00, 0.00,0.00,0.00, 0.00, 0.00, 0.00,  0.00, 0.00, 0.00, 0.00, 0.00,33);
     
     out_put := LIAONE('Current A/C(Customer)',vi_tranDate,'70103',34);
     
     out_put := LIAONE('Current A/C(Other Bank)',vi_tranDate,'70311',35);
     
     out_put := LIAONE('Sundry A/C',vi_tranDate,'30001',36);
     
     Out_Put := Liaone('Marginal Deposit',Vi_Trandate,'30012',37);
     
      out_put := LIAGROUP('Borrwoing From Other Banks',vi_tranDate,'2030070142010012',38);
     
     out_put := LIAGROUP('Payable May Bank A/C',vi_tranDate,'203007030101014',38);
     
     out_put := LIAGROUP('Accrual A/C(Interest on Other Banks Borrowing',vi_tranDate,'2030070171010102',38);
        
     out_put := LIAGROUP('Guarantee External (F/C) A/C',vi_tranDate,'203008000101001',39);
     
     out_put := LIAGROUP('Import Credit (External) A/C',vi_tranDate,'2030080001010022',40);--2030080001010014
     
     out_put := LIAALL('Income A/C',vi_tranDate,'L40',41);    ---
     
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
			INTO v_glName, v_aUSD, v_aEUR, v_aSGD,v_aJPY, v_aTHB, v_aMYR,
      v_lUSD, v_lEUR, v_lSGD, v_LJPY, v_lTHB, v_LMYR;
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
    --BEGIN
      --IF v_usdAmt IS NULL THEN v_usdAmt := 0.00;END IF;
      --IF v_eurAmt IS NULL THEN v_eurAmt := 0.00;END IF;
      --IF v_sgdAmt IS NULL THEN v_sgdAmt := 0.00;END IF;
      --IF v_jpyAmt IS NULL THEN v_jpyAmt := 0.00;END IF;
      --IF v_thbAmt IS NULL THEN v_thbAmt := 0.00;END IF;
      --IF v_myrAmt IS NULL THEN v_myrAmt := 0.00;END IF;
    --END;
    
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(
                v_glName	          || '|' ||
                v_aUSD              || '|' ||
                v_aEUR              || '|' ||
                v_aSGD	            || '|' ||
                v_aMYR 	            || '|' ||
                v_aTHB 	            || '|' ||
                v_aJPY 	            || '|' ||
                v_aTOTAL 	          || '|' ||
                v_lUSD              || '|' ||
                v_lEUR              || '|' ||
                v_lSGD	            || '|' ||
                v_lMYR 	            || '|' ||
                v_lTHB 	            || '|' ||
                v_lJPY 	            || '|' ||
                v_lTOTAL 	          || '|' ||              
                v_BranchName        || '|' ||
                v_BankAddress       || '|' ||
                v_BankPhone         || '|' ||
                v_BankFax           || '|' ||
                v_usdRate      			|| '|' ||
                v_eurRate           || '|' ||
                v_sgdRate           || '|' ||
                v_jpyRate           || '|' ||
                v_thbRate           || '|' ||
                v_myrRate);
  
			dbms_output.put_line(out_rec);
      
  END FIN_FCY_ASSETS_AND_LIABILITIES;

END FIN_FCY_ASSETS_AND_LIABILITIES;
/
