CREATE OR REPLACE PACKAGE        FIN_OD_LEDGER_BALANCE_LISTING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
PROCEDURE FIN_OD_LEDGER_BALANCE_LISTING(    inp_str      IN  VARCHAR2,
            out_retCode  OUT NUMBER,
            out_rec      OUT VARCHAR2 );
END FIN_OD_LEDGER_BALANCE_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                 FIN_OD_LEDGER_BALANCE_LISTING AS
/******************************************************************************
 NAME:       FIN_OD_LEDGER_BALANCE_LISTING
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_Date		    Varchar2(10);		    	    -- Input to procedure
--  vi_endDate		      Varchar2(10);		    	    -- Input to procedure
  vi_branchCode       Varchar2(5);              -- Input to procedure
  vi_currency         Varchar2(3);              -- Input to procedure
  
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_OD_LEDGER_BALANCE_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractData (    
      ci_Date VARCHAR2, ci_branchCode VARCHAR2, ci_currency VARCHAR2)
IS  
   select q.openDate as openDate,
       q.expDate as expDate,
       q.accNo as accNo,
       q.odNo as odNo,
       q.accName as accName,
       q.interestrate as interestrate,
       q.odLimit as odLimit,
       q.odAmount as odAmount,
       q.depositAmount as depositAmount,
       q.odOverLimitAmount as odOverLimitAmount,
       q.odInterest as odInterest,
       q.groupDate as groupDate,
       q.serviceCharges as serviceCharges,
       q.Commission as Commission,
       q.Commitment as Commitment,
       q.lateFees as lateFees,
       case when q.odLimit = 0 then q.odLimit 
           when q.odLimit >q.odAmount then (q.odLimit-q.odAmount)
       else 0 end as unused_Limit
from
  (SELECT  TMP.ACCT_OPN_DATE AS openDate,
  TMP.LIM_EXP_DATE AS expDate,
  TMP.FORACID AS accNo,
  TMP.SANCT_REF_NUM AS odNo,
  TMP.ACCT_NAME AS accName,
  (select -- NVL((interest_rate * -1),0) 
  case when interest_rate < 1 then NVL((interest_rate * -1),0) else interest_rate end 
  from tbaadm.eit where entity_id = TMP.acid ) as interestrate,
  NVL(TMP.SANCT_LIM,0) AS odLimit,
  case when TMP.TRAN_DATE_BAL < 0 then NVL((TMP.TRAN_DATE_BAL * -1),0) else 0 end AS odAmount,
  case when TMP.TRAN_DATE_BAL > 0 then NVL((TMP.TRAN_DATE_BAL),0) else 0 end AS depositAmount,
  NVL(TMP.SANCT_LIM - (TMP.TRAN_DATE_BAL * -1),0) AS odOverLimitAmount,
  NVL(TMP.ODINTEREST,0) AS odInterest,
  TMP.ODate AS groupDate,
  NVL(CH.M7,0) AS serviceCharges,
  NVL(CH.M6,0) AS Commission,
  ' ' AS Commitment,
  TMP.Late_fee AS lateFees
  FROM
  (
      SELECT  GA.ACID,GA.ACCT_OPN_DATE,
      (select SANCT_REF_NUM from tbaadm.lht where GA.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = GA.acid)) as SANCT_REF_NUM,
      /*(select LIM_EXP_DATE from tbaadm.lht where GA.acid = lht.acid and serial_num = 
      (select max(serial_num) from tbaadm.lht where acid = GA.acid)) as LIM_EXP_DATE,*/
      (select max(LIM_EXP_DATE) from tbaadm.lht where lht.acid = GA.acid
       and lht.status='A') as LIM_EXP_DATE,
      GA.FORACID,GA.ACCT_NAME,
      T.TRAN_DATE_BAL,GA.SANCT_LIM as SANCT_LIM,GA.drwng_power as drwng_power,
     (EI.NRML_ACCRUED_AMOUNT_DR - EI.NRML_INTEREST_AMOUNT_DR) AS ODINTEREST,
      GA.SOL_ID,T.ODate,T.EOD_DATE,EI.penal_booked_amount_dr as Late_fee        
      FROM TBAADM.GENERAL_ACCT_MAST_TABLE GA
      INNER JOIN 
      (
        SELECT t1.ACID, t2.TRAN_DATE_BAL, t2.EOD_DATE, 
        TO_CHAR(t2.EOD_DATE,'Mon-YYYY') AS ODate
        FROM
        (
            SELECT ACID, MAX(EOD_DATE) AS MDate 
            FROM TBAADM.EOD_ACCT_BAL_TABLE
          --  WHERE EOD_DATE BETWEEN TRUNC(to_date(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy'),'MM')
          --  AND LAST_DAY(to_date(CAST(ci_endDate AS VARCHAR(10)), 'dd-MM-yyyy'))
          WHERE 
          EOD_DATE <= TO_DATE(CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy')
            GROUP BY ACID
            ORDER BY MDATE
        )t1 INNER JOIN TBAADM.EOD_ACCT_BAL_TABLE t2 
        ON t1.MDate = t2.EOD_DATE AND t1.ACID = t2.ACID
       -- ORDER BY t2.EOD_DATE
      )T ON GA.ACID = T.ACID
      INNER JOIN TBAADM.ENTITY_INTEREST_TABLE EI ON GA.ACID = EI.ENTITY_ID
      WHERE (GA.Schm_Type='CAA' and GA.Schm_code='AGDOD')
      AND GA.ACCT_CLS_FLG = 'N' AND GA.DEL_FLG = 'N'
      AND GA.SOL_ID like '%' || ci_branchCode || '%'
      AND GA.ACCT_CRNCY_CODE = upper(ci_currency)
      --AND LH.SANCT_REF_NUM IS NOT NULL
     -- AND LH.STATUS ='A'
      --AND LH.LIM_PENALTY_MONTH !=0
      --AND T.TRAN_DATE_BAL <0
   --   GROUP BY GA.ACID,GA.ACCT_OPN_DATE,LH.LIM_EXP_DATE,GA.FORACID,GA.ACCT_NAME,
     -- T.TRAN_DATE_BAL,LH.SANCT_LIM,LH.SANCT_REF_NUM,GA.SOL_ID,T.ODate,T.EOD_DATE
  ) TMP
  LEFT JOIN 
  (
  SELECT ACID, NVL(M1,0) AS M1, NVL(M2,0) AS M2
        , NVL(M3,0) AS M3, NVL(M4,0) AS M4, NVL(M5,0) AS M5
        ,(NVL(M1,0)- NVL(M3,0)) AS M6
        ,(NVL(M2,0)- NVL(M4,0)) AS M7
  FROM 
  (
      SELECT ACID,SYS_CALC_CHRGE_AMT,CHARGE_TYPE 
      FROM TBAADM.CHAT
  ) 
  PIVOT (SUM(NVL(SYS_CALC_CHRGE_AMT,0)) FOR (CHARGE_TYPE) 
  IN ('MISC1' AS M1, 'MISC2' AS M2, 'MISC3' AS M3, 'MISC4' AS M4, 'LATEF' AS M5))
  )CH ON TMP.ACID = CH.ACID)q;
  
  PROCEDURE FIN_OD_LEDGER_BALANCE_LISTING( inp_str  IN  VARCHAR2,
            out_retCode  OUT NUMBER,
            out_rec      OUT VARCHAR2 ) AS
      
  v_openDate DATE;
  v_expDate DATE;
  v_accNo TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_odNo TBAADM.LIM_HISTORY_TABLE.SANCT_REF_NUM%type;
  v_accName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_interest decimal(18,2);
  v_odLimit TBAADM.LIM_HISTORY_TABLE.SANCT_LIM%type;
  v_odAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_DepositAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_odOverLimitAmount TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_odInterest TBAADM.ENTITY_INTEREST_TABLE.NRML_INTEREST_AMOUNT_DR%type;
  v_groupDate TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_serviceCharges TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Commission TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_Commitment VARCHAR2(50);
  v_lateFees TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type;
  v_unused_Limit tbaadm.gam.SANCT_LIM%type;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
    
  BEGIN
    ----------------------------------------------------------------------------
    -- Out Ret code is the code which controls
    -- the while loop,it can have values 0,1
    -- 0 - The while loop is being executed
    -- 1 - Exit
    ----------------------------------------------------------------------------
    out_retCode := 0;
    out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);    
    ----------------------------------------------------------------------------
    -- Parsing the i/ps from the string
    ----------------------------------------------------------------------------
    vi_Date  :=  outArr(0);		
   -- vi_endDate    :=  outArr(1);
    vi_currency   :=  outArr(1);
      vi_branchCode :=  outArr(2);
    
    IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
  vi_branchCode := '';
  END IF; 
  
    IF NOT ExtractData%ISOPEN THEN
        --{
            BEGIN
            --{
                OPEN ExtractData (    
                vi_Date , vi_branchCode, vi_currency);
            --}
            END;
        --}
        END IF;
    
    IF ExtractData%ISOPEN THEN
        --{
            FETCH    ExtractData
            INTO    v_openDate, v_expDate, v_accNo, v_odNo, 
            v_accName,v_interest, v_odLimit, v_odAmount,v_DepositAmount, v_odOverLimitAmount, 
            v_odInterest, v_groupDate, v_serviceCharges,
            v_Commission, v_Commitment, v_lateFees,v_unused_Limit;
            --------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            --------------------------------------------------------------------
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
If vi_branchCode is not null then
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
  end if;
    END;
-----------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
-----------------------------------------------------------------------------------
    out_rec:= (to_char(to_date(v_openDate,'dd/Mon/yy'), 'dd/MM/yyyy')            || '|' ||
          to_char(to_date(v_expDate,'dd/Mon/yy'), 'dd/MM/yyyy')                  || '|' ||
                    v_accNo         || '|' ||
                    v_odNo          || '|' ||
                    v_accName                  || '|' ||
                    v_odLimit                  || '|' ||
                    v_odAmount                 || '|' ||
                    v_DepositAmount   || '|' ||
                    v_odOverLimitAmount        || '|' ||
                    v_odInterest               || '|' ||
                    v_BranchName      || '|' ||
                    v_BankAddress     || '|' ||
                    v_BankPhone       || '|' ||
                    v_BankFax         || '|' ||
                    v_groupDate       || '|' ||
                    v_serviceCharges  || '|' ||
                    v_Commission      || '|' ||
                    v_Commitment      || '|' ||
                    v_lateFees ||'|'||
                    v_interest ||'|'||
                    v_unused_Limit);
  
            dbms_output.put_line(out_rec);
  END FIN_OD_LEDGER_BALANCE_LISTING;

END FIN_OD_LEDGER_BALANCE_LISTING;
/
