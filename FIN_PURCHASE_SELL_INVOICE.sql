CREATE OR REPLACE PACKAGE FIN_PURCHASE_SELL_INVOICE AS 

PROCEDURE FIN_PURCHASE_SELL_INVOICE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_PURCHASE_SELL_INVOICE;
/


CREATE OR REPLACE PACKAGE BODY                      FIN_PURCHASE_SELL_INVOICE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
  -- Coding By Moe Htet 
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_BSType	          	Varchar2(20);               -- Input to procedure
	vi_TransactionDate		Varchar2(10);		    	    -- Input to procedure
  vi_CustomerName		    Varchar2(200);		    	    -- Input to procedure
  vi_NRC		        Varchar2(200);		    	    -- Input to procedure
  vi_Address	        Varchar2(200);		    	    -- Input to procedure
  vi_branchCode	      	Varchar2(5);		    	    -- Input to procedure
  vi_TranId             Varchar2(20);
  
    
-----------------------------------------------------------------------------
-- CURSOR declaration 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_TranId VARCHAR2,ci_TransactionDate VARCHAR2, ci_branchCode VARCHAR2 , ci_BSType varchar2
     )
  IS
        SELECT * 
        FROM(
            (SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC10000 NOT LIKE '(null)' then 10000  ELSE 0 END AS NOTE,
                   CDCM.N10000 AS QTY,
                   CDCM.R10000 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC1000 NOT LIKE '(null)' then 1000 ELSE 0 END AS NOTE,
                   CDCM.N1000 AS QTY,
                   CDCM.R1000 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 1  as  GroupCode  ,     
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC500 NOT LIKE '(null)' then 500 ELSE 0 END AS NOTE,
                   CDCM.N500 AS QTY,
                   CDCM.R500 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC200 NOT LIKE '(null)' then 200 ELSE 0 END AS NOTE,
                   CDCM.N200 AS QTY,
                   CDCM.R200 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC100 NOT LIKE '(null)' then 100 ELSE 0 END AS NOTE,
                   CDCM.N100 AS QTY,
                   CDCM.R100 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC50 NOT LIKE '(null)' then 50 ELSE 0 END AS NOTE,
                   CDCM.N50 AS QTY,
                   CDCM.R50 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC25 NOT LIKE '(null)' then 25 ELSE 0 END AS NOTE,
                   CDCM.N25 AS QTY,
                   CDCM.R25 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              --and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              --AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC20 NOT LIKE '(null)' then 20 ELSE 0 END AS NOTE,
                   CDCM.N20 AS QTY,
                   CDCM.R20 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC10 NOT LIKE '(null)' then 10 ELSE 0 END AS NOTE,
                   CDCM.N10 AS QTY,
                   CDCM.R10 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
              UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC5 NOT LIKE '(null)' then 5 ELSE 0 END AS NOTE,
                   CDCM.N5 AS QTY,
                   CDCM.R5 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
               UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC2 NOT LIKE '(null)' then 2 ELSE 0 END AS NOTE,
                   CDCM.N2 AS QTY,
                   CDCM.R2 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 1  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC1 NOT LIKE '(null)' then 1 ELSE 0 END AS NOTE,
                   CDCM.N1 AS QTY,
                   CDCM.R1 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID) = ci_TranId)
    UNION ALL
            (SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC10000 NOT LIKE '(null)' then 10000  ELSE 0 END AS NOTE,
                   CDCM.N10000 AS QTY,
                   CDCM.R10000 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC1000 NOT LIKE '(null)' then 1000 ELSE 0 END AS NOTE,
                   CDCM.N1000 AS QTY,
                   CDCM.R1000 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 2  as  GroupCode  ,     
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC500 NOT LIKE '(null)' then 500 ELSE 0 END AS NOTE,
                   CDCM.N500 AS QTY,
                   CDCM.R500 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC200 NOT LIKE '(null)' then 200 ELSE 0 END AS NOTE,
                   CDCM.N200 AS QTY,
                   CDCM.R200 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC100 NOT LIKE '(null)' then 100 ELSE 0 END AS NOTE,
                   CDCM.N100 AS QTY,
                   CDCM.R100 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
            
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC50 NOT LIKE '(null)' then 50 ELSE 0 END AS NOTE,
                   CDCM.N50 AS QTY,
                   CDCM.R50 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC25 NOT LIKE '(null)' then 25 ELSE 0 END AS NOTE,
                   CDCM.N25 AS QTY,
                   CDCM.R25 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              --and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              --AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC20 NOT LIKE '(null)' then 20 ELSE 0 END AS NOTE,
                   CDCM.N20 AS QTY,
                   CDCM.R20 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC10 NOT LIKE '(null)' then 10 ELSE 0 END AS NOTE,
                   CDCM.N10 AS QTY,
                   CDCM.R10 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
              UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC5 NOT LIKE '(null)' then 5 ELSE 0 END AS NOTE,
                   CDCM.N5 AS QTY,
                   CDCM.R5 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
               UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC2 NOT LIKE '(null)' then 2 ELSE 0 END AS NOTE,
                   CDCM.N2 AS QTY,
                   CDCM.R2 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID ) = ci_TranId
              
            UNION ALL
            
            SELECT 2  as  GroupCode  ,      
                   FOREIGN_EXCHANGE AS BS,
                   CDCM.REF_CRNCY_CODE AS Particular,
                   CASE WHEN CDCM.RC1 NOT LIKE '(null)' then 1 ELSE 0 END AS NOTE,
                   CDCM.N1 AS QTY,
                   CDCM.R1 AS RATE           
            FROM 
              CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM, TBAADM.GAM GAM
            WHERE 
              FOREIGN_EXCHANGE LIKE '%' || vi_BSType || '%' 
              and CDCM.tran_date = TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND CDCM.REF_CRNCY_CODE in ('USD', 'EUR', 'SGD', 'THB', 'JPY', 'MYR')
              AND CDCM.BANK_ID = '01'
              AND GAM.SOL_ID = ci_branchCode  
              AND CDCM.DEBIT_FORACID =  GAM.FORACID
              AND TRIM(TRAN_ID) = ci_TranId
          )
          )
        WHERE qty > 0
        ORDER BY GROUPCODE,NOTE DESC
        ;
  
  PROCEDURE FIN_PURCHASE_SELL_INVOICE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
     

    BuySell     Varchar2(20);
    Particular  Varchar2(20);
    Note        Varchar2(20);
    QTY         Number(20,2);
    Rate        Number(20,2);
    GroupCode   VARCHAR2(20);
    v_BranchName   TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress  TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
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
    
    vi_CustomerName    :=  outArr(0);		
    vi_NRC             :=  outArr(1);		
    vi_Address         :=  outArr(2);		
    vi_TranId          :=  outArr(3);		
    vi_TransactionDate :=  outArr(4);	
    vi_BSType          :=  outArr(5);
    vi_branchCode      :=  outArr(6);
   
   IF vi_BSType like 'Buying%' then
       vi_BSType := 'B' ;
   ELSIF vi_BSType like 'Selling%' then
       vi_BSType := 'S';
   ELSE
       vi_BSType := '';
   END IF;
   
   
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			upper(vi_TranId) , vi_TransactionDate  , vi_branchCode ,vi_BSType
      );
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 GroupCode,BuySell,Particular,Note,QTY,Rate;
      

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
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(   		
          BuySell    			       || '|' ||
          Particular    			   || '|' ||
          Note                   || '|' ||
          QTY                    || '|' ||
          Rate                   || '|' ||
					v_BranchName	         || '|' ||
					v_BankAddress      		 || '|' ||
					v_BankPhone            || '|' ||
          v_BankFax              || '|' ||
          GroupCode);
  
			dbms_output.put_line(out_rec);
  END FIN_PURCHASE_SELL_INVOICE;

END FIN_PURCHASE_SELL_INVOICE;
/
