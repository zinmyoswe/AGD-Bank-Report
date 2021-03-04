CREATE OR REPLACE PACKAGE                      FIN_INTER_BRANCH_HOME_TRAN AS 

 
 PROCEDURE FIN_INTER_BRANCH_HOME_TRAN(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
      
END FIN_INTER_BRANCH_HOME_TRAN;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_INTER_BRANCH_HOME_TRAN AS

-------------------------------------------------------------------------------------
  -- Update Date - 21-03-2017
  -- Update User - Moe Htet
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	      Varchar2(3);               -- Input to procedure
	vi_StartDate	      	Varchar2(10);		    	    -- Input to procedure
  vi_EndDate		        Varchar2(10);		    	    -- Input to procedure
  vi_branchCode	      	Varchar2(5);		    	    -- Input to procedure
  vi_TransactionType    varchar2(20);
  vi_HomeActive         VARCHAR2(20);
  vi_TranType           VARCHAR2(10);
  vi_PartTranType       VARCHAR2(10);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData Home
-----------------------------------------------------------------------------
CURSOR ExtractDataHome (	
			ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2,
      ci_TransactionType VARCHAR2,ci_TranType VARCHAR2,ci_PartTranType VARCHAR2
      )
  IS
  SELECT q.gl_sub_head_code as code,
         q.gl_sub_head_desc,
         q.DTH_INIT_SOL_ID as SolId,
         q.FORACID as ForAcid,
         bct.BR_SHORT_NAME AS BankName,
         q.TRAN_PARTICULAR_CODE as TType,
         q.ENTRY_USER_ID as TellerName,
         q.Credit_amt as Credit_TranAmt,
         q.Debit_amt as Debit_TranAmt,
         q.TRAN_TYPE as TranType,
         q.ACCT_NAME as AccName,
         q.TRAN_id as TranId,
         sum(q.commission) as Commission,
         sum(q.Communicaton) as Communication
         
  FROM    TBAADM.SERVICE_OUTLET_TABLE sot,
         TBAADM.BRANCH_CODE_TABLE bct,
          (SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_Date,CTD.DTH_INIT_SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_id,
                  case  when cxl.SRL_NUM =  1  then cxl.ACTUAL_AMT_COLL else 0 end as commission,
                  case  when cxl.SRL_NUM =  2  then cxl.ACTUAL_AMT_COLL else 0 end as Communicaton
                  
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,TBAADM.CXL CXL,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CXL.CHRG_TRAN_ID = CTD.TRAN_ID
          AND CXL.CHRG_TRAN_DATE  = CTD.TRAN_DATE
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.SOL_ID LIKE '%' || ci_BranchCode || '%'  
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code 
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          AND CTD.TRAN_TYPE = ci_TranType--
          --AND CTD.PART_TRAN_TYPE = ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          AND CTD.TRAN_PARTICULAR_CODE LIKE ci_TransactionType|| '%'
          
          UNION ALL
          
          SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_DATE,CTD.DTH_INIT_SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_ID, 0 , 0
          
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code 
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          AND CTD.TRAN_TYPE = ci_TranType ---
          --AND CTD.PART_TRAN_TYPE = ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          AND CTD.TRAN_PARTICULAR_CODE LIKE ci_TransactionType || '%'
          AND (CTD.TRAN_ID,CTD.TRAN_DATE) NOT IN (SELECT DISTINCT(CHRG_TRAN_ID),CXL.CHRG_TRAN_DATE 
                                  FROM  TBAADM.CXL CXL
                                  WHERE CXL.CHRG_TRAN_DATE >=TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                  AND  CXL.CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  AND service_sol_id LIKE '%' || ci_BranchCode || '%'
                                  )
          )q
    WHERE  sot.SOL_ID = q.DTH_INIT_SOL_ID
    AND sot.BR_CODE = bct.BR_CODE
  GROUP BY q.gl_sub_head_code,
         q.gl_sub_head_desc,q.TRAN_DATE,q.TRAN_ID,q.DTH_INIT_SOL_ID,q.FORACID,bct.BR_SHORT_NAME,q.TRAN_PARTICULAR_CODE,q.ENTRY_USER_ID
  ,q.Credit_amt,q.Debit_amt,q.TRAN_TYPE,q.ACCT_NAME
    order by q.gl_sub_head_code,q.FORACID;
  
  -----------------------------------------------------------------------------
-- CURSOR ExtractData Active
-----------------------------------------------------------------------------
CURSOR ExtractDataActive (	
			ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2 ,
      ci_TransactionType VARCHAR2,ci_TranType VARCHAR2,ci_PartTranType VARCHAR2
      )
  IS
  SELECT q.gl_sub_head_code as code,
         q.gl_sub_head_desc,
         q.SOL_ID as SolId,
         q.FORACID as ForAcid,
         bct.BR_SHORT_NAME AS BankName,
         q.TRAN_PARTICULAR_CODE as TType,
         q.ENTRY_USER_ID as TellerName,
         q.Credit_amt as Credit_TranAmt,
         q.Debit_amt as Debit_TranAmt,
         q.TRAN_TYPE as TranType,
         q.ACCT_NAME as AccName,
         q.TRAN_id as TranId,
         sum(q.commission) as Commission,
         sum(q.Communicaton) as Communication
         
  FROM    TBAADM.SERVICE_OUTLET_TABLE sot,
         TBAADM.BRANCH_CODE_TABLE bct,
          (SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_Date,CTD.SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_id,
                  case  when cxl.SRL_NUM =  1  then cxl.ACTUAL_AMT_COLL else 0 end as commission,
                  case  when cxl.SRL_NUM =  2  then cxl.ACTUAL_AMT_COLL else 0 end as Communicaton
                  
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,TBAADM.CXL CXL,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CXL.CHRG_TRAN_ID = CTD.TRAN_ID
          AND CXL.CHRG_TRAN_DATE  = CTD.TRAN_DATE
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.DTH_INIT_SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          AND CTD.TRAN_TYPE = ci_TranType--
         -- AND CTD.PART_TRAN_TYPE = ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          AND CTD.TRAN_PARTICULAR_CODE LIKE  ci_TransactionType || '%'
          
          UNION ALL
          
          SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_DATE,CTD.SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_ID, 0 , 0
          
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.DTH_INIT_SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          AND CTD.TRAN_TYPE = ci_TranType ---
         -- AND CTD.PART_TRAN_TYPE =ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          AND CTD.TRAN_PARTICULAR_CODE LIKE ci_TransactionType || '%'
          AND (CTD.TRAN_ID,CTD.TRAN_DATE) NOT IN (SELECT DISTINCT(CHRG_TRAN_ID),CXL.CHRG_TRAN_DATE 
                                  FROM  TBAADM.CXL CXL
                                  WHERE CXL.CHRG_TRAN_DATE >=TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                  AND  CXL.CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  AND service_sol_id LIKE '%' || ci_BranchCode || '%'
                                  )
          )q
    WHERE  sot.SOL_ID = q.SOL_ID
    AND sot.BR_CODE = bct.BR_CODE
  GROUP BY q.gl_sub_head_code,
         q.gl_sub_head_desc,
  q.TRAN_DATE,q.TRAN_ID,q.SOL_ID,q.FORACID,bct.BR_SHORT_NAME,q.TRAN_PARTICULAR_CODE,q.ENTRY_USER_ID,q.Credit_amt,q.Debit_amt,q.TRAN_TYPE,q.ACCT_NAME
      order by q.gl_sub_head_code,q.FORACID;
  
  -----------------------------------------------------------------------------
-- CURSOR ExtractData Home ALL 
-----------------------------------------------------------------------------
CURSOR ExtractDataHomeAll (	
			ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2,
      ci_TransactionType VARCHAR2
      )
  IS
  SELECT q.gl_sub_head_code as code,
         q.gl_sub_head_desc,
         q.DTH_INIT_SOL_ID as SolId,
         q.FORACID as ForAcid,
         bct.BR_SHORT_NAME AS BankName,
         q.TRAN_PARTICULAR_CODE as TType,
         q.ENTRY_USER_ID as TellerName,
         q.Credit_amt as Credit_TranAmt,
         q.Debit_amt as Debit_TranAmt,
         q.TRAN_TYPE as TranType,
         q.ACCT_NAME as AccName,
         q.TRAN_id as TranId,
         sum(q.commission) as Commission,
         sum(q.Communicaton) as Communication
         
  FROM    TBAADM.SERVICE_OUTLET_TABLE sot,
         TBAADM.BRANCH_CODE_TABLE bct,
          (SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_Date,CTD.DTH_INIT_SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_id,
                  case  when cxl.SRL_NUM =  1  then cxl.ACTUAL_AMT_COLL else 0 end as commission,
                  case  when cxl.SRL_NUM =  2  then cxl.ACTUAL_AMT_COLL else 0 end as Communicaton
                  
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,TBAADM.CXL CXL,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CXL.CHRG_TRAN_ID = CTD.TRAN_ID
          AND CXL.CHRG_TRAN_DATE  = CTD.TRAN_DATE
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          --AND CTD.TRAN_PARTICULAR_CODE = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3))--
          
          UNION ALL
          
          SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_DATE,CTD.DTH_INIT_SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
         case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_ID, 0 , 0
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          --AND CTD.TRAN_TYPE = ci_TranType ---
         -- AND CTD.PART_TRAN_TYPE = ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          --AND CTD.TRAN_PARTICULAR_CODE = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3))
          AND (CTD.TRAN_ID,CTD.TRAN_DATE) NOT IN (SELECT DISTINCT(CHRG_TRAN_ID),CXL.CHRG_TRAN_DATE 
                                  FROM  TBAADM.CXL CXL
                                  WHERE CXL.CHRG_TRAN_DATE >=TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                  AND  CXL.CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  AND service_sol_id LIKE '%' || ci_BranchCode || '%'
                                  )
          )q
    WHERE  sot.SOL_ID = q.DTH_INIT_SOL_ID
    AND sot.BR_CODE = bct.BR_CODE
  GROUP BY q.gl_sub_head_code,
         q.gl_sub_head_desc,
  q.TRAN_DATE,q.TRAN_ID,q.DTH_INIT_SOL_ID,q.FORACID,bct.BR_SHORT_NAME,q.TRAN_PARTICULAR_CODE,q.ENTRY_USER_ID,
  q.Credit_amt,q.Debit_amt,q.TRAN_TYPE,q.ACCT_NAME
    order by q.gl_sub_head_code,q.FORACID
;


-----------------------------------------------------------------------------
-- CURSOR ExtractData Active All
-----------------------------------------------------------------------------
CURSOR ExtractDataActiveAll (	
			ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_branchCode VARCHAR2 ,ci_currency VARCHAR2 ,
      ci_TransactionType VARCHAR2
      )
  IS
  SELECT q.gl_sub_head_code as code,
         q.gl_sub_head_desc,
         q.SOL_ID as SolId,
         q.FORACID as ForAcid,
         bct.BR_SHORT_NAME AS BankName,
         q.TRAN_PARTICULAR_CODE as TType,
         q.ENTRY_USER_ID as TellerName,
         q.Credit_amt as Credit_TranAmt,
         q.Debit_amt as Debit_TranAmt,
         q.TRAN_TYPE as TranType,
         q.ACCT_NAME as AccName,
         q.TRAN_id as TranId,
         sum(q.commission) as Commission,
         sum(q.Communicaton) as Communication
         
  FROM    TBAADM.SERVICE_OUTLET_TABLE sot,
         TBAADM.BRANCH_CODE_TABLE bct,
          (SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_Date,CTD.SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_id,
                  case  when cxl.SRL_NUM =  1  then cxl.ACTUAL_AMT_COLL else 0 end as commission,
                  case  when cxl.SRL_NUM =  2  then cxl.ACTUAL_AMT_COLL else 0 end as Communicaton
                  
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,TBAADM.CXL CXL,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CXL.CHRG_TRAN_ID = CTD.TRAN_ID
          AND CXL.CHRG_TRAN_DATE  = CTD.TRAN_DATE
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.DTH_INIT_SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          --AND CTD.TRAN_TYPE = ci_TranType--
          --AND CTD.PART_TRAN_TYPE = ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          --AND CTD.TRAN_PARTICULAR_CODE  = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3))
          
          UNION ALL
          
          SELECT gsh.gl_sub_head_code, gsh.gl_sub_head_desc,
          CTD.TRAN_DATE,CTD.SOL_ID,GAM.FORACID,CTD.TRAN_PARTICULAR_CODE,ctd.ENTRY_USER_ID,
          case when ctd.part_tran_type ='C' then ctd.tran_amt else 0 end as Credit_amt,
          case when ctd.part_tran_type ='D' then ctd.tran_amt else 0 end as Debit_amt,
          CTD.TRAN_TYPE,GAM.ACCT_NAME,CTD.TRAN_ID, 0 , 0
          
          FROM custom.custom_CTD_DTD_ACLI_VIEW CTD,TBAADM.GAM GAM,tbaadm.gsh gsh
          WHERE CTD.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          AND CTD.TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
          AND CTD.TRAN_CRNCY_CODE = UPPER(ci_Currency)
          AND GAM.ACID = CTD.ACID
          AND CTD.DTH_INIT_SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.SOL_ID LIKE '%' || ci_BranchCode || '%'
          and gsh.gl_sub_head_code =GAM.gl_sub_head_code
          AND CTD.SOL_ID<> CTD.DTH_INIT_SOL_ID
          --AND CTD.TRAN_PARTICULAR LIKE 'CASH DEPOSIT'
          --AND CTD.TRAN_TYPE = ci_TranType ---
         -- AND CTD.PART_TRAN_TYPE =ci_PartTranType
          AND CTD.PSTD_FLG = 'Y'
          AND CTD.DEL_FLG = 'N'
          --AND CTD.TRAN_PARTICULAR_CODE  = ANY(SUBSTR(ci_TransactionType,1,3),SUBSTR(ci_TransactionType,4,3),SUBSTR(ci_TransactionType,7,3),SUBSTR(ci_TransactionType,10,3))
          AND (CTD.TRAN_ID,CTD.TRAN_DATE) NOT IN (SELECT DISTINCT(CHRG_TRAN_ID),CXL.CHRG_TRAN_DATE 
                                  FROM  TBAADM.CXL CXL
                                  WHERE CXL.CHRG_TRAN_DATE >=TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                  AND  CXL.CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                  AND service_sol_id LIKE '%' || ci_BranchCode || '%'
                                  )
          )q
    WHERE  sot.SOL_ID = q.SOL_ID
    AND sot.BR_CODE = bct.BR_CODE
  GROUP BY q.gl_sub_head_code,
         q.gl_sub_head_desc,
  q.TRAN_DATE,q.TRAN_ID,q.SOL_ID,q.FORACID,bct.BR_SHORT_NAME,q.TRAN_PARTICULAR_CODE,q.ENTRY_USER_ID,
  q.Credit_amt,q.Debit_amt,q.TRAN_TYPE,q.ACCT_NAME
    order by q.gl_sub_head_code,q.FORACID
;
     PROCEDURE FIN_INTER_BRANCH_HOME_TRAN(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

       
     
         v_BranchCode      custom.custom_CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID%type;
         v_ForAcid         TBAADM.GAM.FORACID%TYPE;
         v_BankName        TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
         v_TType           TBAADM.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_CODE%TYPE;
         v_TellerName      TBAADM.CTD_DTD_ACLI_VIEW.ENTRY_USER_ID%TYPE;
         v_Credit_Amount         TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE;
         v_Debit_Amount         TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE;
         v_TranType        TBAADM.CTD_DTD_ACLI_VIEW.TRAN_TYPE%TYPE;
         v_AccName         TBAADM.GAM.ACCT_NAME%TYPE;
         v_TranId          TBAADM.CTD_DTD_ACLI_VIEW.TRAN_id%TYPE;
         v_Commission      TBAADM.CXL.ACTUAL_AMT_COLL%TYPE;
         v_Communication   TBAADM.CXL.ACTUAL_AMT_COLL%TYPE;
         v_gl_code          TBAADM.gsh.gl_sub_head_code%Type;
         v_gl_desc          TBAADM.gsh.gl_sub_head_desc%Type;
         v_branchName      TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
         v_bankAddress     TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
         v_bankPhone       TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
         v_bankFax         TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
      
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
    
     vi_StartDate       :=  outArr(0);			
     vi_EndDate         :=  outArr(1);	
     vi_currency	      :=  outArr(2);
     vi_TransactionType := outArr(3);
     vi_HomeActive      := outArr(4);
      vi_branchCode      :=  outArr(5);
 ------------------------------------------------------------------------------------------------------
 
 
if( vi_StartDate is null or vi_EndDate is null or vi_currency is null or vi_TransactionType is null or vi_HomeActive is null
     ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-'|| '|' || '-' || '|' || '-' || '|' || '-' || '|' || 
		          '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
				  0 || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 
				  0 || '|' || '-' || '|' || '-' || '-' || '|' || '-' || '|' || '-' );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 ---------------------------------------------------------------------------------------
     begin
      IF vi_TransactionType like 'Deposit%' then
        vi_TransactionType := 'CHD';
        vi_TranType        := 'C';
       -- vi_PartTranType    := 'C';
      
      ELSIF vi_TransactionType like 'Withdrawal%' then
        vi_TransactionType := 'CHW';
        vi_TranType       := 'C';
       -- vi_PartTranType    := 'D';
        
      ELSIF vi_TransactionType like 'Transfer%' then
        vi_TransactionType := 'TR';
        vi_TranType        := 'T';
        --vi_PartTranType    := 'D';
      ELSE
        vi_TransactionType := 'TRWCHDCHWTRD';
        
      END IF;
      end;
      
      IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
    
      IF vi_HomeActive like 'Home%' THEN
      --{
         IF vi_TransactionType NOT like 'TRWCHDCHWTRD' THEN
          --{
           IF NOT ExtractDataHome%ISOPEN THEN
                --{
                  BEGIN
                  --{
                    OPEN ExtractDataHome (	
                  vi_StartDate , vi_EndDate  , vi_branchCode , vi_currency,vi_TransactionType, vi_TranType,vi_PartTranType);
                  --}
                  END;
            
                --}
                END IF;
            
                IF ExtractDataHome%ISOPEN THEN
                --{
                  FETCH	ExtractDataHome
                  INTO	v_gl_code,v_gl_desc,v_BranchCode, v_ForAcid,v_BankName,v_TType,v_TellerName,v_Credit_Amount,v_Debit_Amount,v_TranType,
                        v_AccName ,v_TranId ,v_Commission,v_Communication;
                  
            
                  ------------------------------------------------------------------
                  -- Here it is checked whether the cursor has fetched
                  -- something or not if not the cursor is closed
                  -- and the out ret code is made equal to 1
                  ------------------------------------------------------------------
                  IF ExtractDataHome%NOTFOUND THEN
                  --{
                    CLOSE ExtractDataHome;
                    out_retCode:= 1;
                    RETURN;
                  --}
                  END IF;
                --}
               END IF;
              --}
            ELSE --------------vi_TransactionType like 'TRWCHDCHWTRD' THEN
              
                IF NOT ExtractDataHomeAll%ISOPEN THEN
                --{
                  BEGIN
                  --{
                    OPEN ExtractDataHomeAll (	
                  vi_StartDate , vi_EndDate  , vi_branchCode , vi_currency,vi_TransactionType);
                  --}
                  END;
            
                --}
                END IF;
            
                IF ExtractDataHomeAll%ISOPEN THEN
                --{
                  FETCH	ExtractDataHomeAll
                  INTO	v_gl_code,v_gl_desc,v_BranchCode, v_ForAcid,v_BankName,v_TType,v_TellerName,v_Credit_Amount,v_Debit_Amount,v_TranType,
                        v_AccName ,v_TranId ,v_Commission,v_Communication;
                  
            
                  ------------------------------------------------------------------
                  -- Here it is checked whether the cursor has fetched
                  -- something or not if not the cursor is closed
                  -- and the out ret code is made equal to 1
                  ------------------------------------------------------------------
                  IF ExtractDataHomeAll%NOTFOUND THEN
                  --{
                    CLOSE ExtractDataHomeAll;
                    out_retCode:= 1;
                    RETURN;
                  --}
                  END IF;
                --}
               END IF;
              --}
            END IF;
          
          ELSE  ------------Active Transaction
          --{
              IF vi_TransactionType NOT like 'TRWCHDCHWTRD' THEN -- TRWCHDCHWTRD
               --{
                 IF NOT ExtractDataActive%ISOPEN THEN
                      --{
                        BEGIN
                        --{
                          OPEN ExtractDataActive (	
                        vi_StartDate , vi_EndDate  , vi_branchCode , vi_currency,vi_TransactionType, vi_TranType,vi_PartTranType);
                        --}
                        END;
                  
                      --}
                      END IF;
                  
                      IF ExtractDataActive%ISOPEN THEN
                      --{
                        FETCH	ExtractDataActive
                        INTO	v_gl_code,v_gl_desc,v_BranchCode, v_ForAcid,v_BankName,v_TType,v_TellerName,v_Credit_Amount,v_Debit_Amount,v_TranType,
                        v_AccName ,v_TranId ,v_Commission,v_Communication;
                        
                  
                        ------------------------------------------------------------------
                        -- Here it is checked whether the cursor has fetched
                        -- something or not if not the cursor is closed
                        -- and the out ret code is made equal to 1
                        ------------------------------------------------------------------
                        IF ExtractDataActive%NOTFOUND THEN
                        --{
                          CLOSE ExtractDataActive;
                          out_retCode:= 1;
                          RETURN;
                        --}
                        END IF;
                      --}
                     END IF;
                    --} 
                ELSE --------
                    
                    IF NOT ExtractDataActiveAll%ISOPEN THEN
                      --{
                        BEGIN
                        --{
                          OPEN ExtractDataActiveAll (	
                        vi_StartDate , vi_EndDate  , vi_branchCode , vi_currency,vi_TransactionType);
                        --}
                        END;
                  
                      --}
                      END IF;
                  
                      IF ExtractDataActiveAll%ISOPEN THEN
                      --{
                        FETCH	ExtractDataActiveAll
                        INTO	v_gl_code,v_gl_desc,v_BranchCode, v_ForAcid,v_BankName,v_TType,v_TellerName,v_Credit_Amount,v_Debit_Amount,v_TranType,
                        v_AccName ,v_TranId ,v_Commission,v_Communication;
                        
                  
                        ------------------------------------------------------------------
                        -- Here it is checked whether the cursor has fetched
                        -- something or not if not the cursor is closed
                        -- and the out ret code is made equal to 1
                        ------------------------------------------------------------------
                        IF ExtractDataActiveAll%NOTFOUND THEN
                        --{
                          CLOSE ExtractDataActiveAll;
                          out_retCode:= 1;
                          RETURN;
                        --}
                        END IF;
                      --}
                     END IF;
                    --} 
                  END IF;
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
         v_branchName, v_bankAddress, v_bankPhone, v_bankFax
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
          v_gl_code    || '|' ||
          v_gl_desc    || '|' ||
					v_BranchCode      		|| '|' ||
          trim(v_ForAcid )     			  || '|' ||
          v_BankName            || '|' ||		
					v_TType      		    	|| '|' ||
					v_TellerName      		|| '|' ||
					v_Credit_Amount             || '|' ||
          v_Debit_Amount        || '|' ||
          v_AccName             || '|' ||
          Trim(v_TranId)        || '|' ||
          v_Commission          || '|' ||
          v_Communication       || '|' ||
          v_branchName          || '|' ||
          v_bankAddress         || '|' ||
          v_bankPhone           || '|' ||
					v_bankFax             || '|' ||
          v_TranType
                );
  
			dbms_output.put_line(out_rec);
  
  END FIN_INTER_BRANCH_HOME_TRAN;

END FIN_INTER_BRANCH_HOME_TRAN;
/
