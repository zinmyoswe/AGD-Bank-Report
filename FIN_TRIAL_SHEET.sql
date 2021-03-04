CREATE OR REPLACE PACKAGE        FIN_TRIAL_SHEET AS 

  PROCEDURE FIN_TRIAL_SHEET(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_TRIAL_SHEET;
 
/


CREATE OR REPLACE PACKAGE BODY                      FIN_TRIAL_SHEET AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  vi_TranDate		    Varchar2(10);		    	    -- Input to procedure
  vi_Currency		    Varchar2(3);		    	    -- Input to procedure
  limitsize         INTEGER := 200;

  CURSOR ExtractData IS
    SELECT 
      DR_CASH, DR_TRANSFER, DR_CLEARING,
      CR_CASH, CR_TRANSFER, CR_CLEARING, ACCOUNT_HEAD, DR_TOTAL, CR_TOTAL
    FROM CUSTOM.CUST_TRIAL_SHEET_TEMP_TABLE;

  CURSOR ExtractDataChargesAC (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('CHARGE_AC_50101', 
  'CHARGE_AC_50102', 'CHARGE_AC_50103', 'CHARGE_AC_50104', 'CHARGE_AC_50105', 
  'CHARGE_AC_50106', 'CHARGE_AC_50107', 'CHARGE_AC_50108', 'CHARGE_AC_50109', 
  'CHARGE_AC_50121', 'CHARGE_AC_50122', 'CHARGE_AC_50123', 'CHARGE_AC_50131', 
  'CHARGE_AC_50141', 'CHARGE_AC_50142', 'CHARGE_AC_50143', 'CHARGE_AC_50144', 
  'CHARGE_AC_50145', 'CHARGE_AC_50161', 'CHARGE_AC_50162', 'CHARGE_AC_50163', 
  'CHARGE_AC_50164', 'CHARGE_AC_50165', 'CHARGE_AC_50166', 'CHARGE_AC_50167', 
  'CHARGE_AC_50168', 'CHARGE_AC_50169', 'CHARGE_AC_50170', 'CHARGE_AC_50171', 
  'CHARGE_AC_50172', 'CHARGE_AC_50173', 'CHARGE_AC_50174', 'CHARGE_AC_50175', 
  'CHARGE_AC_50176', 'CHARGE_AC_50177', 'CHARGE_AC_50178', 'CHARGE_AC_50191', 
  'CHARGE_AC_50192', 'CHARGE_AC_50193', 'CHARGE_AC_50194', 'CHARGE_AC_50195', 
  'CHARGE_AC_50196', 'CHARGE_AC_50197', 'CHARGE_AC_50201', 'CHARGE_AC_50202',
  'CHARGE_AC_50211', 'CHARGE_AC_50212', 'CHARGE_AC_50213', 'CHARGE_AC_50214',
  'CHARGE_AC_50215', 'CHARGE_AC_50216', 'CHARGE_AC_50231', 'CHARGE_AC_50232',
  'CHARGE_AC_50233', 'CHARGE_AC_50234', 'CHARGE_AC_50235', 'CHARGE_AC_50236',
  'CHARGE_AC_50237', 'CHARGE_AC_50238', 'CHARGE_AC_50251', 'CHARGE_AC_50252',
  'CHARGE_AC_50253', 'CHARGE_AC_50254', 'CHARGE_AC_50255', 'CHARGE_AC_50256',
  'CHARGE_AC_50257', 'CHARGE_AC_50258', 'CHARGE_AC_50259', 'CHARGE_AC_50260',
  'CHARGE_AC_50271', 'CHARGE_AC_50272', 'CHARGE_AC_50273', 'CHARGE_AC_50274', 
  'CHARGE_AC_50275', 'CHARGE_AC_50281', 'CHARGE_AC_50282', 'CHARGE_AC_50283', 
  'CHARGE_AC_50284', 'CHARGE_AC_50285', 'CHARGE_AC_50286', 'CHARGE_AC_50291', 
  'CHARGE_AC_50292', 'CHARGE_AC_50293', 'CHARGE_AC_50294', 'CHARGE_AC_50295',
  'CHARGE_AC_50301', 'CHARGE_AC_50303', 'CHARGE_AC_50304', 'CHARGE_AC_50305',
  'CHARGE_AC_50306', 'CHARGE_AC_50311', 'CHARGE_AC_50312', 'CHARGE_AC_50313', 
  'CHARGE_AC_50314', 'CHARGE_AC_50315', 'CHARGE_AC_50321', 'CHARGE_AC_50322', 
  'CHARGE_AC_50323', 'CHARGE_AC_50324', 'CHARGE_AC_50325', 'CHARGE_AC_50326',
  'CHARGE_AC_50341', 'CHARGE_AC_50342', 'CHARGE_AC_50351', 'CHARGE_AC_50352',
  'CHARGE_AC_50353', 'CHARGE_AC_50354', 'CHARGE_AC_50361', 'CHARGE_AC_50371',
  'CHARGE_AC_50372' )
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataCurrentDeposit (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('CURRENT_DEPOSIT_10551',
  'CURRENT_DEPOSIT_10552','CURRENT_DEPOSIT_10553','CURRENT_DEPOSIT_10554',
  'CURRENT_DEPOSIT_10556','CURRENT_DEPOSIT_10557','CURRENT_DEPOSIT_30001',
  'CURRENT_DEPOSIT_70101','CURRENT_DEPOSIT_70102','CURRENT_DEPOSIT_70103')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataSavingDeposit (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('SAVING_DEPOSIT_70111')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataSpecialDeposit (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('SPECIAL_DEPOSIT_70121')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataFixedDeposit (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('FIXED_DEPOSIT_70131')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataOverdraft (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('OVERDRAFT_10581')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataInternalRemittance (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('INT_REMIT_70281', 'INT_REMIT_70282')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataSundryDepositAC (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('SUNDRY_DEPOSIT_30001', 
  'SUNDRY_DEPOSIT_30011','SUNDRY_DEPOSIT_30012', 'SUNDRY_DEPOSIT_30013')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataAccuLiabAC (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('ACCU_LIAB_AC_70171')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataCashInHandFCY (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('CASH_IN_HAND_10103',
'CASH_IN_HAND_10104')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataSuspenseAC (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('SUSPENSE_AC_20001','SUSPENSE_AC_20011')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataIncomeAC (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('INCOME_AC_40001',
	'INCOME_AC_40002','INCOME_AC_40003','INCOME_AC_40004','INCOME_AC_40011',
	'INCOME_AC_40012','INCOME_AC_40013','INCOME_AC_40014','INCOME_AC_40015',
	'INCOME_AC_40016','INCOME_AC_40017','INCOME_AC_40018','INCOME_AC_40019',
	'INCOME_AC_40021','INCOME_AC_40031','INCOME_AC_40032','INCOME_AC_40033',
	'INCOME_AC_40034','INCOME_AC_40041','INCOME_AC_40042','INCOME_AC_40043',
	'INCOME_AC_40044','INCOME_AC_40045','INCOME_AC_40046','INCOME_AC_40047',
	'INCOME_AC_40048','INCOME_AC_40049','INCOME_AC_40050','INCOME_AC_40051',
	'INCOME_AC_40052','INCOME_AC_40053','INCOME_AC_40054','INCOME_AC_40056',
	'INCOME_AC_40057','INCOME_AC_40058','INCOME_AC_40059','INCOME_AC_40060',
	'INCOME_AC_40061','INCOME_AC_40062','INCOME_AC_40063','INCOME_AC_40064',
	'INCOME_AC_40065','INCOME_AC_40066','INCOME_AC_40067','INCOME_AC_40071',
	'INCOME_AC_40072','INCOME_AC_40073','INCOME_AC_40074','INCOME_AC_40075',
	'INCOME_AC_40076','INCOME_AC_40081','INCOME_AC_40082','INCOME_AC_40091',
	'INCOME_AC_40092','INCOME_AC_40101','INCOME_AC_40102','INCOME_AC_40103',
	'INCOME_AC_40104','INCOME_AC_40105','INCOME_AC_40106','INCOME_AC_40111',
	'INCOME_AC_40112','INCOME_AC_40113','INCOME_AC_40114','INCOME_AC_40121',
	'INCOME_AC_40122','INCOME_AC_40123','INCOME_AC_40124','INCOME_AC_40125',
	'INCOME_AC_40126')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;
  
  CURSOR ExtractDataHP (ci_TranDate	   	Varchar2,
      ci_Currency	   	Varchar2) IS
      SELECT  
   sum(CTD_DTD_ACLI_VIEW.TRAN_AMT) AS TOTAL, 
   CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE ,
   CTD_DTD_ACLI_VIEW.TRAN_TYPE,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION AS DESCRIPTION,
   CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE
  FROM 
    custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW,
    CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE CUST_RPTCUST_GL_SUB_HEAD_TABLE
  WHERE
    CTD_DTD_ACLI_VIEW.GL_SUB_HEAD_CODE = CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE
    AND CTD_DTD_ACLI_VIEW.REF_CRNCY_CODE = ci_Currency
  AND CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_NAME in ('HP_AC_10571')
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.BANK_ID = '01'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.MODULE_NAME = 'REPORT'
  AND CUST_RPTCUST_GL_SUB_HEAD_TABLE.SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
  AND CTD_DTD_ACLI_VIEW.tran_id NOT IN (select CONT_TRAN_ID 
  from TBAADM.ATD atd 
  where atd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
  group by 
  CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION, CUST_RPTCUST_GL_SUB_HEAD_TABLE.GROUP_CODE,
  CTD_DTD_ACLI_VIEW.PART_TRAN_TYPE, CTD_DTD_ACLI_VIEW.TRAN_TYPE;

  PROCEDURE FIN_TRIAL_SHEET(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_creditCashAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_creditTransferAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_creditClearingAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_debitCashAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_debitTransferAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_debitClearingAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_debitTotal custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_creditTotal custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_accountHead custom.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%type;
      
      v_crCashAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_crTransferAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_crClearingAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_drCashAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_drTransferAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_drClearingAmt custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_drTotal custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_crTotal custom.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%type := 0;
      v_acHead custom.CUST_RPTCUST_GL_SUB_HEAD_TABLE.DESCRIPTION%type;
      
      v_openingamount NUMBER := 0;
      
      TYPE chargesACTable IS TABLE OF ExtractDataChargesAC%ROWTYPE INDEX BY BINARY_INTEGER;
      l_chargesACTable chargesACTable;
      
      TYPE currentDepositTable IS TABLE OF ExtractDataCurrentDeposit%ROWTYPE INDEX BY BINARY_INTEGER;
      l_currentDepositTable currentDepositTable;
      
      TYPE savingDepositTable IS TABLE OF ExtractDataSavingDeposit%ROWTYPE INDEX BY BINARY_INTEGER;
      l_savingDepositTable savingDepositTable;
      
      TYPE specialDepositTable IS TABLE OF ExtractDataSpecialDeposit%ROWTYPE INDEX BY BINARY_INTEGER;
      l_specialDepositTable specialDepositTable;
      
      TYPE fixedDepositTable IS TABLE OF ExtractDataFixedDeposit%ROWTYPE INDEX BY BINARY_INTEGER;
      l_fixedDepositTable fixedDepositTable;
      
      TYPE overdraftTable IS TABLE OF ExtractDataOverdraft%ROWTYPE INDEX BY BINARY_INTEGER;
      l_overdraftTable overdraftTable;
      
      TYPE intRemitTable IS TABLE OF ExtractDataInternalRemittance%ROWTYPE INDEX BY BINARY_INTEGER;
      l_intRemitTable intRemitTable;
      
      TYPE sundryDepositACTable IS TABLE OF ExtractDataSundryDepositAC%ROWTYPE INDEX BY BINARY_INTEGER;
      l_sundryDepositACTable sundryDepositACTable;     
      
      TYPE accuLiabACTable IS TABLE OF ExtractDataAccuLiabAC%ROWTYPE INDEX BY BINARY_INTEGER;
      l_accuLiabACTable accuLiabACTable;     
      
      TYPE cashInHandFCYTable IS TABLE OF ExtractDataCashInHandFCY%ROWTYPE INDEX BY BINARY_INTEGER;
      l_cashInHandFCY cashInHandFCYTable;
      
      TYPE SuspenseACTable IS TABLE OF ExtractDataSuspenseAC%ROWTYPE INDEX BY BINARY_INTEGER;
      l_SuspenseACTable SuspenseACTable;
      
      TYPE incomeACTable IS TABLE OF ExtractDataIncomeAC%ROWTYPE INDEX BY BINARY_INTEGER;
      l_incomeACTable incomeACTable;
      
      TYPE hpTable IS TABLE OF ExtractDataHP%ROWTYPE INDEX BY BINARY_INTEGER;
      l_hpTable hpTable;
      
  BEGIN
    out_retCode := 0;
		out_rec := NULL;
    
     tbaadm.basp0099.formInputArr(inp_str, outArr);
    
    --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    
    vi_TranDate  :=  outArr(0);		
    vi_Currency    :=  outArr(1);
  -------------------------------------------------------------------------------------------------
  if( vi_TranDate is null or vi_Currency is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

  
  
  
  ------------------------------------------------------------------------------------------------------
    delete from CUSTOM.CUST_TRIAL_SHEET_TEMP_TABLE;
    
     IF NOT ExtractDataChargesAC%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataChargesAC (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataChargesAC%ISOPEN THEN
		--{
			FETCH	ExtractDataChargesAC	BULK COLLECT INTO l_chargesACTable LIMIT limitsize;
      FOR x IN 1 .. l_chargesACTable.COUNT
      LOOP
            IF l_chargesACTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_chargesACTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_chargesACTable(x).TOTAL;
              ELSIF l_chargesACTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_chargesACTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_chargesACTable(x).TOTAL;
              END IF;
            ELSE
              IF l_chargesACTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_chargesACTable(x).TOTAL;
              ELSIF l_chargesACTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_chargesACTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_chargesACTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_chargesACTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'CHARGES A/C', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_chargesACTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataChargesAC%NOTFOUND THEN
			--{
				CLOSE ExtractDataChargesAC;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataCurrentDeposit%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataCurrentDeposit (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataCurrentDeposit%ISOPEN THEN
		--{
			FETCH	ExtractDataCurrentDeposit	BULK COLLECT INTO l_currentDepositTable LIMIT limitsize;
      FOR x IN 1 .. l_currentDepositTable.COUNT
      LOOP
            IF l_currentDepositTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_currentDepositTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_currentDepositTable(x).TOTAL;
              ELSIF l_currentDepositTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_currentDepositTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_currentDepositTable(x).TOTAL;
              END IF;
            ELSE
              IF l_currentDepositTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_currentDepositTable(x).TOTAL;
              ELSIF l_currentDepositTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_currentDepositTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_currentDepositTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_currentDepositTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'CURRENT DEPOSIT', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_currentDepositTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataCurrentDeposit%NOTFOUND THEN
			--{
				CLOSE ExtractDataCurrentDeposit;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataSavingDeposit%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataSavingDeposit (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataSavingDeposit%ISOPEN THEN
		--{
			FETCH	ExtractDataSavingDeposit	BULK COLLECT INTO l_savingDepositTable LIMIT limitsize;
      FOR x IN 1 .. l_savingDepositTable.COUNT
      LOOP
            IF l_savingDepositTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_savingDepositTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_savingDepositTable(x).TOTAL;
              ELSIF l_savingDepositTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_savingDepositTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_savingDepositTable(x).TOTAL;
              END IF;
            ELSE
              IF l_savingDepositTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_savingDepositTable(x).TOTAL;
              ELSIF l_savingDepositTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_savingDepositTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_savingDepositTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_savingDepositTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'SAVING DEPOSIT', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_savingDepositTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataSavingDeposit%NOTFOUND THEN
			--{
				CLOSE ExtractDataSavingDeposit;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataSpecialDeposit%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataSpecialDeposit (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataSpecialDeposit%ISOPEN THEN
		--{
			FETCH	ExtractDataSpecialDeposit	BULK COLLECT INTO l_specialDepositTable LIMIT limitsize;
      FOR x IN 1 .. l_specialDepositTable.COUNT
      LOOP
            IF l_specialDepositTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_specialDepositTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_specialDepositTable(x).TOTAL;
              ELSIF l_specialDepositTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_specialDepositTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_specialDepositTable(x).TOTAL;
              END IF;
            ELSE
              IF l_specialDepositTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_specialDepositTable(x).TOTAL;
              ELSIF l_specialDepositTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_specialDepositTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_specialDepositTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_specialDepositTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'SPECIAL DEPOSIT', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_specialDepositTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataSpecialDeposit%NOTFOUND THEN
			--{
				CLOSE ExtractDataSpecialDeposit;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataFixedDeposit%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataFixedDeposit (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataFixedDeposit%ISOPEN THEN
		--{
			FETCH	ExtractDataFixedDeposit	BULK COLLECT INTO l_fixedDepositTable LIMIT limitsize;
      FOR x IN 1 .. l_fixedDepositTable.COUNT
      LOOP
            IF l_fixedDepositTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_fixedDepositTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_fixedDepositTable(x).TOTAL;
              ELSIF l_fixedDepositTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_fixedDepositTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_fixedDepositTable(x).TOTAL;
              END IF;
            ELSE
              IF l_fixedDepositTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_fixedDepositTable(x).TOTAL;
              ELSIF l_fixedDepositTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_fixedDepositTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_fixedDepositTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_fixedDepositTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'FIXED DEPOSIT', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_fixedDepositTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataFixedDeposit%NOTFOUND THEN
			--{
				CLOSE ExtractDataFixedDeposit;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataOverdraft%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataOverdraft (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataOverdraft%ISOPEN THEN
		--{
			FETCH	ExtractDataOverdraft	BULK COLLECT INTO l_overdraftTable LIMIT limitsize;
      FOR x IN 1 .. l_overdraftTable.COUNT
      LOOP
            IF l_overdraftTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_overdraftTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_overdraftTable(x).TOTAL;
              ELSIF l_overdraftTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_overdraftTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_overdraftTable(x).TOTAL;
              END IF;
            ELSE
              IF l_overdraftTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_overdraftTable(x).TOTAL;
              ELSIF l_overdraftTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_overdraftTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_overdraftTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_overdraftTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'Overdraft A/C', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_overdraftTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataOverdraft%NOTFOUND THEN
			--{
				CLOSE ExtractDataOverdraft;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataInternalRemittance%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataInternalRemittance (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataInternalRemittance%ISOPEN THEN
		--{
			FETCH	ExtractDataInternalRemittance	BULK COLLECT INTO l_intRemitTable LIMIT limitsize;
      FOR x IN 1 .. l_intRemitTable.COUNT
      LOOP
            IF l_intRemitTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_intRemitTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_intRemitTable(x).TOTAL;
              ELSIF l_intRemitTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_intRemitTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_intRemitTable(x).TOTAL;
              END IF;
            ELSE
              IF l_intRemitTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_intRemitTable(x).TOTAL;
              ELSIF l_intRemitTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_intRemitTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_intRemitTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_intRemitTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'INTERNAL REMITTANCE', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_intRemitTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataInternalRemittance%NOTFOUND THEN
			--{
				CLOSE ExtractDataInternalRemittance;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataAccuLiabAC%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAccuLiabAC (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataAccuLiabAC%ISOPEN THEN
		--{
			FETCH	ExtractDataAccuLiabAC	BULK COLLECT INTO l_accuLiabACTable LIMIT limitsize;
      FOR x IN 1 .. l_accuLiabACTable.COUNT
      LOOP
            IF l_accuLiabACTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_accuLiabACTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_accuLiabACTable(x).TOTAL;
              ELSIF l_accuLiabACTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_accuLiabACTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_accuLiabACTable(x).TOTAL;
              END IF;
            ELSE
              IF l_accuLiabACTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_accuLiabACTable(x).TOTAL;
              ELSIF l_accuLiabACTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_accuLiabACTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_accuLiabACTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_accuLiabACTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'ACCUREED LIABILTIES A/C', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_accuLiabACTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataAccuLiabAC%NOTFOUND THEN
			--{
				CLOSE ExtractDataAccuLiabAC;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataCashInHandFCY%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataCashInHandFCY (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataCashInHandFCY%ISOPEN THEN
		--{
			FETCH	ExtractDataCashInHandFCY	BULK COLLECT INTO l_cashInHandFCY LIMIT limitsize;
      FOR x IN 1 .. l_cashInHandFCY.COUNT
      LOOP
            IF l_cashInHandFCY(x).PART_TRAN_TYPE = 'C' THEN
              IF l_cashInHandFCY(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_cashInHandFCY(x).TOTAL;
              ELSIF l_cashInHandFCY(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_cashInHandFCY(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_cashInHandFCY(x).TOTAL;
              END IF;
            ELSE
              IF l_cashInHandFCY(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_cashInHandFCY(x).TOTAL;
              ELSIF l_cashInHandFCY(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_cashInHandFCY(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_cashInHandFCY(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_cashInHandFCY.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'Cash in Hand (Foreign Currency)', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_cashInHandFCY(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataCashInHandFCY%NOTFOUND THEN
			--{
				CLOSE ExtractDataCashInHandFCY;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataSuspenseAC%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataSuspenseAC (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataSuspenseAC%ISOPEN THEN
		--{
			FETCH	ExtractDataSuspenseAC	BULK COLLECT INTO l_SuspenseACTable LIMIT limitsize;
      FOR x IN 1 .. l_SuspenseACTable.COUNT
      LOOP
            IF l_SuspenseACTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_SuspenseACTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_SuspenseACTable(x).TOTAL;
              ELSIF l_SuspenseACTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_SuspenseACTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_SuspenseACTable(x).TOTAL;
              END IF;
            ELSE
              IF l_SuspenseACTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_SuspenseACTable(x).TOTAL;
              ELSIF l_SuspenseACTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_SuspenseACTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_SuspenseACTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_SuspenseACTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'Suspense A/C', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_SuspenseACTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataSuspenseAC%NOTFOUND THEN
			--{
				CLOSE ExtractDataSuspenseAC;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataIncomeAC%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataIncomeAC (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataIncomeAC%ISOPEN THEN
		--{
			FETCH	ExtractDataIncomeAC	BULK COLLECT INTO l_incomeACTable LIMIT limitsize;
      FOR x IN 1 .. l_incomeACTable.COUNT
      LOOP
            IF l_incomeACTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_incomeACTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_incomeACTable(x).TOTAL;
              ELSIF l_incomeACTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_incomeACTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_incomeACTable(x).TOTAL;
              END IF;
            ELSE
              IF l_incomeACTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_incomeACTable(x).TOTAL;
              ELSIF l_incomeACTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_incomeACTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_incomeACTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_incomeACTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'INCOME A/C', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_incomeACTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataIncomeAC%NOTFOUND THEN
			--{
				CLOSE ExtractDataIncomeAC;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataHP%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataHP (vi_TranDate, vi_Currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataHP%ISOPEN THEN
		--{
			FETCH	ExtractDataHP	BULK COLLECT INTO l_hpTable LIMIT limitsize;
      FOR x IN 1 .. l_hpTable.COUNT
      LOOP
            IF l_hpTable(x).PART_TRAN_TYPE = 'C' THEN
              IF l_hpTable(x).TRAN_TYPE = 'C' THEN
                v_creditCashAmt := v_creditCashAmt + l_hpTable(x).TOTAL;
              ELSIF l_hpTable(x).TRAN_TYPE = 'T' THEN
                v_creditTransferAmt := v_creditTransferAmt + l_hpTable(x).TOTAL;
              ELSE
                v_creditClearingAmt := v_creditClearingAmt + l_hpTable(x).TOTAL;
              END IF;
            ELSE
              IF l_hpTable(x).TRAN_TYPE = 'D' THEN
                v_debitCashAmt := v_creditCashAmt + l_hpTable(x).TOTAL;
              ELSIF l_hpTable(x).TRAN_TYPE = 'T' THEN
                v_debitTransferAmt := v_creditTransferAmt + l_hpTable(x).TOTAL;
              ELSE
                v_debitClearingAmt := v_creditClearingAmt + l_hpTable(x).TOTAL;
              END IF;
            END IF;
      END LOOP;
      v_debitTotal := v_debitCashAmt + v_debitTransferAmt + v_debitClearingAmt;
      v_creditTotal := v_creditCashAmt + v_creditTransferAmt + v_creditClearingAmt;
      IF l_hpTable.COUNT = 0 THEN 
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      'Hire-Purchase Account', v_debitTotal, v_creditTotal);
      ELSE
      insert into custom.CUST_TRIAL_SHEET_TEMP_TABLE 
      values (v_debitCashAmt, v_debitTransferAmt, v_debitClearingAmt,
      v_creditCashAmt, v_creditTransferAmt, v_creditClearingAmt, 
      l_hpTable(1).DESCRIPTION, v_debitTotal, v_creditTotal);
      END IF;
      commit;
      v_debitCashAmt := 0;
      v_debitTransferAmt := 0;
      v_debitClearingAmt := 0;
      v_creditCashAmt := 0;
      v_creditTransferAmt := 0;
      v_creditClearingAmt := 0;
      v_debitTotal := 0;
      v_creditTotal := 0;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataHP%NOTFOUND THEN
			--{
				CLOSE ExtractDataHP;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ;
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_drCashAmt,v_drTransferAmt,v_drClearingAmt,
            v_crCashAmt,v_crTransferAmt,v_crClearingAmt,v_acHead,v_drTotal,v_crTotal;
      

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
      select ABS(sum(eab.value_date_tot_tran))
            into v_openingamount
            from tbaadm.eab,custom.custom_ctd_dtd_acli_view cdav
            where cdav.acid = tbaadm.eab.acid
            and eod_date = ( 
            select  eod_date   
            from(
              select eod_date
              from tbaadm.eab,custom.custom_ctd_dtd_acli_view cdav
              where tbaadm.eab.eod_date < TO_DATE( CAST ( '18-11-2016' AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              --and cdav.SOL_ID =  v_BranchCode
              and cdav.acid = tbaadm.eab.acid
              and cdav.REF_CRNCY_CODE = upper('MMK')
              and cdav.gl_sub_head_code = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'Report' 
                              and variable_name = 'Cash in Hand (Vault)')
              --and rownum =1
              order by eod_date desc)  where rownum =1
              )
              and cdav.gl_sub_head_code = (select variable_value from custom.CUST_GENCUST_PARAM_MAINT 
                              where module_name = 'Report' 
                              and variable_name = 'Cash in Hand (Vault)');
    END;
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(v_drCashAmt     			|| '|' ||
          v_drTransferAmt     			|| '|' ||
					v_drClearingAmt	          || '|' ||
          v_crCashAmt               || '|' ||
					v_crTransferAmt      			|| '|' ||
          v_crClearingAmt    			  || '|' ||
          v_acHead                  || '|' ||
          v_drTotal                 || '|' ||
          v_crTotal                 || '|' ||
          v_openingamount);
  
			dbms_output.put_line(out_rec);
    
  END FIN_TRIAL_SHEET;

END FIN_TRIAL_SHEET;
/
