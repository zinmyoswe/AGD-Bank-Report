CREATE OR REPLACE PACKAGE               FIN_FCY_ACCOUNT_OPENING AS 

 PROCEDURE FIN_FCY_ACCOUNT_OPENING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
END FIN_FCY_ACCOUNT_OPENING;
/


CREATE OR REPLACE PACKAGE BODY                                    FIN_FCY_ACCOUNT_OPENING AS

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
CURSOR ExtractData(	ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2)
  IS
  SELECT TO_DATE( CAST ( '01-01-1990' AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AS OPENCLOSE,
        SUM(t.CountUSD),
        SUM(t.USDAmount),
        SUM(t.CountEUR),
        SUM(t.EURAmount),
        SUM(t.CountTHB),
        SUM(t.THBAmount),
        SUM(t.CountJPY),
        SUM(t.JPYAmount),
        SUM(t.CountINR),
        SUM(t.INRAmount),
        SUM(t.CountMYR),
        SUM(t.MYRAmount),
        SUM(t.CountSGD),
        SUM(t.SGDAmount) --USD , EUR,THB,JPY,INR,MYR,SGD
 FROM   (
    SELECT  gam.ACCT_OPN_DATE  ,gam.foracid ,
         
         case  when  GAM.ACCT_CRNCY_CODE = 'USD'  then 1 else 0 end as CountUSD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN r.usd ELSE 0 END AS USDAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'EUR'  then 1 else 0 end as CountEUR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  r.eur ELSE 0 END AS EURAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'THB' then 1 else 0 end as CountTHB,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  r.thb ELSE 0 END AS THBAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'JPY' then 1 else 0 end as CountJPY,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  r.jpy ELSE 0 END AS JPYAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'INR' then 1 else 0 end as CountINR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN r.inr ELSE 0 END AS INRAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'MYR' then 1 else 0 end as CountMYR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN r.myr ELSE 0 END AS MYRAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'SGD' then 1 else 0 end as CountSGD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN r.sgd  ELSE 0 END AS SGDAmount
         
         
         FROM    TBAADM.GAM gam
        
         
       LEFT JOIN
        
        (SELECT  gam.ACCT_OPN_DATE,gam.foracid as foracid,
         
         case  when  GAM.ACCT_CRNCY_CODE = 'USD' AND  ctd.tran_amt > 0 then 1 else 0 end as CountUSD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN  ctd.tran_amt ELSE 0 END AS USD,
         case  when  GAM.ACCT_CRNCY_CODE = 'EUR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountEUR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  ctd.tran_amt ELSE 0 END AS EUR,
         case  when  GAM.ACCT_CRNCY_CODE = 'THB' AND  ctd.tran_amt > 0 then 1 else 0 end as CountTHB,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  ctd.tran_amt ELSE 0 END AS THB,
         case  when  GAM.ACCT_CRNCY_CODE = 'JPY' AND  ctd.tran_amt > 0 then 1 else 0 end as CountJPY,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  ctd.tran_amt ELSE 0 END AS JPY,
         case  when  GAM.ACCT_CRNCY_CODE = 'INR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountINR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN  ctd.tran_amt ELSE 0 END AS INR,
         case  when  GAM.ACCT_CRNCY_CODE = 'MYR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountMYR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN  ctd.tran_amt ELSE 0 END AS MYR,
         case  when  GAM.ACCT_CRNCY_CODE = 'SGD' AND  ctd.tran_amt > 0 then 1 else 0 end as CountSGD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN  ctd.tran_amt ELSE 0 END AS SGD
         
         
         FROM    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,TBAADM.GAM gam
         WHERE   ctd.acid = gam.acid
         AND     ctd.tran_date = gam.ACCT_OPN_DATE
         AND     gam.ACCT_OPN_DATE <  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         --AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST ( '13-11-2015' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         AND     ctd.TRAN_PARTICULAR_CODE LIKE 'CHD%'
         AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
         AND    GAM.DEL_FLG = 'N'
         AND    gam.ENTITY_CRE_FLG = 'Y'
         AND    gam.ACCT_CLS_FLG   = 'N'
         AND     (GAM.FORACID,GAM.ACCT_OPN_DATE,CTD.TRAN_ID) IN  (SELECT  P.FORACID,P.ACCT_OPN_DATE,MIN(P.TRAN_ID)     
                                                                  FROM  (
                                                                           SELECT  gam.ACCT_OPN_DATE,gam.foracid,CTD.TRAN_ID
                                                                           FROM    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,tbaadm.gam gam
                                                                           WHERE   ctd.acid = gam.acid
                                                                           AND     ctd.tran_date = gam.ACCT_OPN_DATE
                                                                           AND     gam.ACCT_OPN_DATE < TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                           --AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST ( '13-11-2015' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                           AND     ctd.TRAN_PARTICULAR_CODE LIKE 'CHD%'
                                                                           AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
                                                                           AND     GAM.DEL_FLG = 'N'
                                                                           AND     gam.ENTITY_CRE_FLG = 'Y'
                                                                           AND     gam.ACCT_CLS_FLG   = 'N'
                                                                           ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
                                                                           )P
                                                                      GROUP BY  P.FORACID,P.ACCT_OPN_DATE  
                                                                         )
         ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
         )r
         on r.foracid = gam.foracid
        where      GAM.DEL_FLG = 'N'
         AND    gam.ENTITY_CRE_FLG = 'Y'
         AND    gam.ACCT_CLS_FLG   = 'N'
         AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
         AND     gam.ACCT_OPN_DATE <  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        -- AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST ('13-11-2015' AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      )t

         
  UNION ALL
  
 SELECT t.ACCT_OPN_DATE,
        SUM(t.CountUSD),
        SUM(t.USDAmount),
        SUM(t.CountEUR),
        SUM(t.EURAmount),
        SUM(t.CountTHB),
        SUM(t.THBAmount),
        SUM(t.CountJPY),
        SUM(t.JPYAmount),
        SUM(t.CountINR),
        SUM(t.INRAmount),
        SUM(t.CountMYR),
        SUM(t.MYRAmount),
        SUM(t.CountSGD),
        SUM(t.SGDAmount) --USD , EUR,THB,JPY,INR,MYR,SGD
 FROM   (
    SELECT  gam.ACCT_OPN_DATE,gam.foracid,
         
         case  when  GAM.ACCT_CRNCY_CODE = 'USD'  then 1 else 0 end as CountUSD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN r.usd ELSE 0 END AS USDAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'EUR'  then 1 else 0 end as CountEUR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  r.eur ELSE 0 END AS EURAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'THB' then 1 else 0 end as CountTHB,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  r.thb ELSE 0 END AS THBAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'JPY' then 1 else 0 end as CountJPY,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  r.jpy ELSE 0 END AS JPYAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'INR' then 1 else 0 end as CountINR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN r.inr ELSE 0 END AS INRAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'MYR' then 1 else 0 end as CountMYR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN r.myr ELSE 0 END AS MYRAmount,
         case  when  GAM.ACCT_CRNCY_CODE = 'SGD' then 1 else 0 end as CountSGD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN r.sgd  ELSE 0 END AS SGDAmount
         
         
         FROM    TBAADM.GAM gam
        
         
       LEFT JOIN
        
        (SELECT  gam.ACCT_OPN_DATE,gam.foracid as foracid,
         
         case  when  GAM.ACCT_CRNCY_CODE = 'USD' AND  ctd.tran_amt > 0 then 1 else 0 end as CountUSD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN  ctd.tran_amt ELSE 0 END AS USD,
         case  when  GAM.ACCT_CRNCY_CODE = 'EUR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountEUR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  ctd.tran_amt ELSE 0 END AS EUR,
         case  when  GAM.ACCT_CRNCY_CODE = 'THB' AND  ctd.tran_amt > 0 then 1 else 0 end as CountTHB,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  ctd.tran_amt ELSE 0 END AS THB,
         case  when  GAM.ACCT_CRNCY_CODE = 'JPY' AND  ctd.tran_amt > 0 then 1 else 0 end as CountJPY,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  ctd.tran_amt ELSE 0 END AS JPY,
         case  when  GAM.ACCT_CRNCY_CODE = 'INR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountINR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN  ctd.tran_amt ELSE 0 END AS INR,
         case  when  GAM.ACCT_CRNCY_CODE = 'MYR' AND  ctd.tran_amt > 0 then 1 else 0 end as CountMYR,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN  ctd.tran_amt ELSE 0 END AS MYR,
         case  when  GAM.ACCT_CRNCY_CODE = 'SGD' AND  ctd.tran_amt > 0 then 1 else 0 end as CountSGD,
         CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN  ctd.tran_amt ELSE 0 END AS SGD
         
         
         FROM    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,TBAADM.GAM gam
         WHERE   ctd.acid = gam.acid
         AND     ctd.tran_date = gam.ACCT_OPN_DATE
         AND     gam.ACCT_OPN_DATE >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         AND     ctd.TRAN_PARTICULAR_CODE LIKE 'CHD%'
         AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
         AND    GAM.DEL_FLG = 'N'
         AND    gam.ENTITY_CRE_FLG = 'Y'
         AND    gam.ACCT_CLS_FLG   = 'N'
         AND     (GAM.FORACID,GAM.ACCT_OPN_DATE,CTD.TRAN_ID) IN  (SELECT  P.FORACID,P.ACCT_OPN_DATE,MIN(P.TRAN_ID)     
                                                                  FROM  (
                                                                           SELECT  gam.ACCT_OPN_DATE,gam.foracid,CTD.TRAN_ID
                                                                           FROM    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd,tbaadm.gam gam
                                                                           WHERE   ctd.acid = gam.acid
                                                                           AND     ctd.tran_date = gam.ACCT_OPN_DATE
                                                                           AND     gam.ACCT_OPN_DATE >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                           AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                           AND     ctd.TRAN_PARTICULAR_CODE LIKE 'CHD%'
                                                                           AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
                                                                           AND     GAM.DEL_FLG = 'N'
                                                                           AND     gam.ENTITY_CRE_FLG = 'Y'
                                                                           AND     gam.ACCT_CLS_FLG   = 'N'
                                                                           ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
                                                                           )P
                                                                      GROUP BY  P.FORACID,P.ACCT_OPN_DATE  
                                                                         )
         ORDER BY CTD.TRAN_DATE,CTD.TRAN_ID
         )r
         on r.foracid = gam.foracid
        where      GAM.DEL_FLG = 'N'
         AND    gam.ENTITY_CRE_FLG = 'Y'
         AND    gam.ACCT_CLS_FLG   = 'N'
         AND     GAM.SOL_ID LIKE '%' || ci_branchCode || '%'
         AND     gam.ACCT_OPN_DATE >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST (ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
         and    (r.usd >= 0 or r.eur >=0 or r.thb >= 0 or r.jpy >=0 or r.inr >= 0 or r.myr >= 0 or r.sgd >= 0)
      )t
    group by t.ACCT_OPN_DATE
 ;
  
  PROCEDURE FIN_FCY_ACCOUNT_OPENING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
     

       v_OpenCloseDate  TBAADM.GAM.ACCT_OPN_DATE%type;
       v_CountUSD       Number;
       v_USDAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountEUR       Number;
       v_EURAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountTHB       Number;
       v_THBAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountJPY       Number;
       v_JPYAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountINR       Number;
       v_INRAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountMYR       Number;
       v_MYRAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
       v_CountSGD       Number;
       v_SGDAmount      CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;   
       v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_Name%type;
   
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
 
   -----------------------------------------------------------------------------
   
   if( vi_startDate is null or vi_endDate is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||
		         0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  '-' );	
					
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

   IF vi_branchCode IS  NULL or vi_branchCode = '' OR vi_branchCode='10100' THEN
         vi_branchCode := '';
    END IF;
   -------------------------------------------------------------------------------
    
    
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
			INTO	 v_OpenCloseDate,v_CountUSD,v_USDAmount,v_CountEUR,v_EURAmount,v_CountTHB,v_THBAmount,
            v_CountJPY,v_JPYAmount, v_CountINR,v_INRAmount,v_CountMYR,v_MYRAmount,v_CountSGD,v_SGDAmount
           ;
      

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
    
    if vi_branchCode IS NULL OR vi_branchCode = '' then
      begin
      v_BranchName := 'ALL Branch';
      end;
    else
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
    
  end if;
  end;
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
  
    out_rec:=	(
          v_OpenCloseDate    || '|' ||
					v_CountUSD         || '|' ||
          v_USDAmount  			 || '|' ||
          v_CountEUR         || '|' ||
          v_EURAmount    		 || '|' ||
          v_CountTHB         || '|' ||
          v_THBAmount        || '|' ||
					v_CountJPY	       || '|' ||
					v_JPYAmount      	 || '|' ||
					v_CountINR         || '|' ||
          v_INRAmount        || '|' ||
          v_CountMYR         || '|' ||
          v_MYRAmount        || '|' ||
          v_CountSGD         || '|' ||
          v_SGDAmount        || '|' ||
           v_BranchName );
  
			dbms_output.put_line(out_rec);
      
  END FIN_FCY_ACCOUNT_OPENING;

END FIN_FCY_ACCOUNT_OPENING;
/
