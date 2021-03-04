CREATE OR REPLACE PACKAGE FIN_MONEY_CHANGER_IBD AS 


PROCEDURE FIN_MONEY_CHANGER_IBD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_MONEY_CHANGER_IBD;
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_MONEY_CHANGER_IBD AS

-------------------------------------------------------------------------------------
  -- ORIGINAL CODER     -  MOE HTET KYAW KYAW
  -- FINISHED DATE      -  31-03-2017
  -- CORRECTED BY       -   -
  -- CORRECTED DATE     -   -
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  
	vi_TransactionDate	   	Varchar2(10);             -- Input to procedure
  vi_UserID		            Varchar2(20);		    	    -- Input to procedure
  vi_BranchCode		        Varchar2(6);		    	    -- Input to procedure
  vi_Option	              Varchar2(10);		    	    -- Input to procedure
  

  
  ----------------------------------CURSOR----------------------------------------
  CURSOR ExtractData(ci_TransactionDate VARCHAR2, ci_UserID VARCHAR2, ci_option VARCHAR2) 
  IS
    
            SELECT  1 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R1,GAM.SOL_ID,SUM(CDCM.N1) AS  TotalNote,sum(cdcm.v1) as Amount
                   
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, 1, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R1, 
GAM.SOL_ID
            HAVING   SUM(CDCM.N1) > 0
             

          Union all
          
            SELECT  2 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R2,GAM.SOL_ID,SUM(CDCM.N2) AS  TotalNote,sum(cdcm.v2) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
           -- AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R2, GAM.SOL_ID, 
2
            HAVING   SUM(CDCM.N2) > 0
            

        Union all
 
            SELECT  5 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R5,GAM.SOL_ID,SUM(CDCM.N5) AS  TotalNote,sum(cdcm.v5) as Amount
                
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
           -- AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R5, GAM.SOL_ID, 
5
            HAVING   SUM(CDCM.N5) > 0
             
      
       Union all
       
            SELECT  10 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R10,GAM.SOL_ID,SUM(CDCM.N10) AS  TotalNote,sum(cdcm.v10) as Amount
                 
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R10, GAM.SOL_ID, 
10
            HAVING   SUM(CDCM.N10) > 0
             
      
      Union all
           
            SELECT  20 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R20,GAM.SOL_ID,SUM(CDCM.N20) AS  TotalNote,sum(cdcm.v20) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R20, GAM.SOL_ID
            HAVING   SUM(CDCM.N20) > 0
             
            
            Union all
      
      
            SELECT  25 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R25,GAM.SOL_ID,SUM(CDCM.N25) AS  TotalNote,sum(cdcm.v25) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
           -- AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R25, GAM.SOL_ID, 
25
            HAVING   SUM(CDCM.N25) > 0
             
            
            Union all
      
            SELECT  50 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R50,GAM.SOL_ID,SUM(CDCM.N50) AS  TotalNote,sum(cdcm.v50) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10)) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
           -- AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R50, GAM.SOL_ID, 
50
            HAVING   SUM(CDCM.N50) > 0
             
            
            Union all
      
            SELECT  100 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R100,GAM.SOL_ID,SUM(CDCM.N100) AS  TotalNote,sum(cdcm.v100) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10 )) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01' 
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R100, GAM.SOL_ID, 
100
            HAVING   SUM(CDCM.N100) > 0
             
            
            Union all
      
            SELECT  200 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R200,GAM.SOL_ID,SUM(CDCM.N200) AS  TotalNote,sum(cdcm.v200) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10 )) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R200, GAM.SOL_ID, 
200
            HAVING   SUM(CDCM.N200) > 0
             
     
     Union all
     
            SELECT  500 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R500,GAM.SOL_ID,SUM(CDCM.N500) AS  TotalNote,sum(cdcm.v500) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10 )) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R500, GAM.SOL_ID, 
500
            HAVING   SUM(CDCM.N500) > 0
             
            
            Union all
      
            SELECT  1000 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R1000,GAM.SOL_ID,SUM(CDCM.N1000) AS  TotalNote,sum(cdcm.v1000) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10 )) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
            --AND     GAM.SOL_ID = '10100'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R1000, GAM.SOL_ID, 
1000
            HAVING   SUM(CDCM.N1000) > 0
             
            
            Union all
      
            SELECT  10000 as  Note,
                    CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE,
                    CDCM.R10000 ,GAM.SOL_ID,SUM(CDCM.N10000) AS  TotalNote,sum(cdcm.v10000) as Amount
                  
            FROM    CUSTOM.C_DENOM_CASH_MAINTENANCE CDCM,TBAADM.GAM GAM
            WHERE   CDCM.TRAN_DATE = TO_DATE(CAST(ci_TransactionDate AS VARCHAR(10 )) ,'dd-MM-yyyy'  )
            AND     CDCM.TELLER_ID LIKE '%' || upper(ci_UserID) || '%'
            AND     CDCM.DEBIT_FORACID = GAM.FORACID
            AND     CDCM.FOREIGN_EXCHANGE  LIKE '%' || ci_option || '%'
            AND     CDCM.BANK_ID = '01'
            --AND     GAM.SOL_ID = '10100'
            AND     CDCM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.ENTITY_CRE_FLG = 'Y'
            AND     GAM.DEL_FLG = 'N'
            AND     CDCM.DEL_FLG = 'N'
            and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TransactionDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
            GROUP BY CDCM.TELLER_ID, CDCM.FOREIGN_EXCHANGE, CDCM.REF_CRNCY_CODE, CDCM.R10000, GAM.SOL_ID, 
10000
            HAVING   SUM(CDCM.N10000) > 0
            
            order by ref_crncy_code,Note
    
    ;
  
  
  
  PROCEDURE FIN_MONEY_CHANGER_IBD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
       
    v_Teller_ID CUSTOM.C_DENOM_CASH_MAINTENANCE.TELLER_ID%TYPE;
    v_FE        CUSTOM.C_DENOM_CASH_MAINTENANCE.FOREIGN_EXCHANGE%TYPE;
    v_Curr      CUSTOM.C_DENOM_CASH_MAINTENANCE.REF_CRNCY_CODE%TYPE;
    v_N         NUMBER(10);
    v_TN        NUMBER(20);
    v_R         NUMBER(20,2);
    v_Amount    NUMBER(20,2);
    v_Branch    TBAADM.GAM.SOL_ID%TYPE;
    v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
    v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  
      
  BEGIN
  
    out_retCode := 0;
		out_rec := NULL;
    
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);
     --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    vi_TransactionDate	  :=outArr(0);			  
    vi_Option	            :=outArr(2);	
    vi_UserID 	          :=outArr(1);   
 
  
  IF vi_UserID IS  NULL or vi_UserID = ''  THEN
      vi_UserID := '';
  END IF;
  IF vi_Option LIKE 'Buying%'  THEN
      vi_Option := 'B';
  END IF;
  
  IF vi_Option LIKE 'Selling%'  THEN
      vi_Option := 'S';
  END IF;

     
  
      ----------------------------------EXTRACT---------------------------------------
      IF NOT ExtractData%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractData(vi_TransactionDate,vi_UserID,vi_Option) ;
            --}
            END;
      
          --}
          END IF;
          IF ExtractData%ISOPEN Then

           -- dobal := dobal + OpeningAmount;
            FETCH	ExtractData INTO	v_N, v_Teller_ID, v_FE,v_Curr,v_R,v_Branch,v_TN,v_Amount;
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
   Begin  
     
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
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;

     out_rec:=	(
                v_Teller_ID    || '|' || 
                v_FE           || '|' ||
                v_Curr         || '|' ||
                v_N            || '|' ||
                v_TN           || '|' ||
                v_R            || '|' ||
                v_Branch       || '|' ||
                v_BranchName   || '|' ||
                v_BankAddress  || '|' ||
                v_BankPhone    || '|' ||
                v_BankFax      || '|' ||
                v_Amount
              );
  
			dbms_output.put_line(out_rec);
      
  END FIN_MONEY_CHANGER_IBD;

END FIN_MONEY_CHANGER_IBD;
/
