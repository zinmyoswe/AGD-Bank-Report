CREATE OR REPLACE PACKAGE        FIN_IBD_ACCOUNT_OPENING AS 

 PROCEDURE FIN_IBD_ACCOUNT_OPENING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_IBD_ACCOUNT_OPENING;
/


CREATE OR REPLACE PACKAGE BODY        FIN_IBD_ACCOUNT_OPENING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure

    
-----------------------------------------------------------------------------
-- CURSOR declaration 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2
      )
  IS
  SELECT q.cust_type,q.pan,
         sum(CountUSD),
         sum(CountEUR),
         SUM(CountTHB),
         SUM(CountJPY),
         SUM(CountINR),
         SUM(CountMYR),
         SUM(CountSGD)
  FROM  (   SELECT    distinct(gam.cust_id),ACCOUNTS.CUST_TYPE as cust_type,
                       ACCOUNTS.UNIQUEIDTYPE as pan,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'USD'  THEN  1  ELSE 0 END AS CountUSD,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'EUR'  THEN  1  ELSE 0 END AS CountEUR,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'THB'  THEN  1  ELSE 0 END AS CountTHB,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'JPY'  THEN  1  ELSE 0 END AS CountJPY,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'INR'  THEN  1  ELSE 0 END AS CountINR,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'MYR'  THEN  1  ELSE 0 END AS CountMYR,
                       CASE  WHEN ACCOUNTS.CRNCY_CODE = 'SGD'  THEN  1  ELSE 0 END AS CountSGD
              FROM     crmuser.accounts accounts ,tbaadm.gam gam
              WHERE    accounts.cust_type = 'INDIV'
              and      gam.cust_id = accounts.CORE_CUST_ID
              AND      GAM.SOL_ID  = ci_branchCode
              and      gam.ACCT_OPN_DATE >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              and      gam.ACCT_OPN_DATE <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
              AND      accounts.UNIQUEIDTYPE in ('PAN','Passport Number'))q
group by q.cust_type,q.Pan--Passport Number PAN

UNION ALL

    SELECT q.cust_type,q.pan,
           sum(CountUSD),
           sum(CountEUR),
           SUM(CountTHB),
           SUM(CountJPY),
           SUM(CountINR),
           SUM(CountMYR),
           SUM(CountSGD)
    FROM ( 
           SELECT ass.acid,
           CASE  WHEN gam.cif_id  like 'C%'  THEN  cast('COMP' as NVARCHAR2(50))  ELSE cast('JOINT' as NVARCHAR2(50))  END AS CUST_TYPE,
           ACCOUNTS.UNIQUEIDTYPE AS PAN,
                    CASE  WHEN gam.ACCT_CRNCY_CODE  = 'USD'  THEN  1  ELSE 0 END AS CountUSD,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'EUR'  THEN  1  ELSE 0 END AS CountEUR,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'THB'  THEN  1  ELSE 0 END AS CountTHB,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'JPY'  THEN  1  ELSE 0 END AS CountJPY,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'INR'  THEN  1  ELSE 0 END AS CountINR,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'MYR'  THEN  1  ELSE 0 END AS CountMYR,
                     CASE  WHEN gam.ACCT_CRNCY_CODE = 'SGD'  THEN  1  ELSE 0 END AS CountSGD
            FROM     tbaadm.aas ass,tbaadm.gam gam,crmuser.accounts accounts
            WHERE    ACCT_POA_AS_SRL_NUM = '002'
            AND      GAM.ACID = ASS.ACID
            AND      GAM.SOL_ID = ci_branchCode
            AND      GAM.CUST_ID = ACCOUNTS.CORE_CUST_ID
            AND      ass.start_Date >= TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
            AND      ass.start_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND      accounts.UNIQUEIDTYPE in ('PAN','Passport Number'))Q
        GROUP BY     q.cust_type,q.Pan;
        
  PROCEDURE FIN_IBD_ACCOUNT_OPENING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      

      v_cust_type  crmuser.accounts.CUST_TYPE%type;
      v_pan        crmuser.accounts.UNIQUEIDTYPE%type;
      v_CountUSD   Number;
      v_CountEUR   Number;
      v_CountTHB   Number;
      v_CountJPY   Number;
      v_CountINR   Number;
      v_CountMYR   Number;
      v_CountSGD   Number;
       v_BranchName  TBAADM.BRANCH_CODE_TABLE.BR_Name%type;  
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
    vi_branchCode :=  outArr(2);	

 -------------------------------------------------------------------------------------
 		  
if( vi_startDate is null or vi_endDate is null or vi_branchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || '-'    );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 ------------------------------------------------------------------------------------
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode );
			--}
			END;

		--}
		END IF;
    
  
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_cust_type, v_pan, v_CountUSD,v_CountEUR, v_CountTHB,v_CountJPY,v_CountINR,v_CountMYR,v_CountSGD;
      

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
--------------------------------------------------------------------------------
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
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
          v_cust_type   			 || '|' ||
					v_pan	               || '|' ||
          v_CountUSD           || '|' ||
					v_CountEUR      		 || '|' ||
          v_CountTHB   			   || '|' ||
          v_CountJPY    			 || '|' ||
          v_CountINR    			 || '|' ||
          v_CountMYR           || '|' ||
          v_CountSGD           || '|' ||
					v_BranchName	           
		);
  
			dbms_output.put_line(out_rec);
      
  END FIN_IBD_ACCOUNT_OPENING;

END FIN_IBD_ACCOUNT_OPENING;
/
