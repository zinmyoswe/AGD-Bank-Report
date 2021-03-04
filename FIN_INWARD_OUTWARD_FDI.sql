CREATE OR REPLACE PACKAGE               FIN_INWARD_OUTWARD_FDI AS 

    PROCEDURE FIN_INWARD_OUTWARD_FDI(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_INWARD_OUTWARD_FDI;
/


CREATE OR REPLACE PACKAGE BODY        FIN_INWARD_OUTWARD_FDI AS
    
  
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_ToToDayDate	   	Varchar2(10);              -- Input to procedure

  vi_USDRate DECIMAL;
  vi_EURRate DECIMAL;
  vi_SGDRate DECIMAL;
  vi_INRRate DECIMAL;
  vi_THBRate DECIMAL;
  vi_MYRRate DECIMAL;
  vi_JPYRate DECIMAL;
  
  NUSD   NUMBER(20,2);          
  NEUR   NUMBER(20,2);           
  NTHB   NUMBER(20,2);            
  NJPY   NUMBER(20,2);             
  NINR   NUMBER(20,2);             
  NMYR   NUMBER(20,2);             
  NSGD   NUMBER(20,2);
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	 ToTodayDate varchar2)
  IS
  SELECT Q.RCODE,
       SUM(Q.COUNTUSD),
       SUM(Q.USD),
       SUM(Q.COUNTEUR),
       SUM(Q.EUR),
       SUM(Q.COUNTTHB),
       SUM(Q.THB),
       SUM(Q.COUNTJPY),
       SUM(Q.JPY),
       SUM(Q.COUNTINR),
       SUM(Q.INR),
       SUM(Q.COUNTMYR),
       SUM(Q.MYR),
       SUM(Q.COUNTSGD),
       SUM(Q.SGD)
FROM  (
    SELECT CGM.COLLECTION_CODE AS RCODE,
           CASE CGM.COLLECTION_CRNCY  when 'USD' then 1 else 0 end as COUNTUSD,
           CASE CGM.COLLECTION_CRNCY  when 'USD' then CGM.COLLECTION_AMT else 0 end as USD,
           CASE CGM.COLLECTION_CRNCY  when 'EUR' then 1 else 0 end as COUNTEUR,
           CASE CGM.COLLECTION_CRNCY  when 'EUR' then CGM.COLLECTION_AMT else 0 end as EUR,
           CASE CGM.COLLECTION_CRNCY  when 'THB' then 1 else 0 end as COUNTTHB,
           CASE CGM.COLLECTION_CRNCY  when 'THB' then CGM.COLLECTION_AMT else 0 end as THB,
           CASE CGM.COLLECTION_CRNCY  when 'JPY' then 1 else 0 end as COUNTJPY,
           CASE CGM.COLLECTION_CRNCY  when 'JPY' then CGM.COLLECTION_AMT else 0 end as JPY,
           CASE CGM.COLLECTION_CRNCY  when 'INR' then 1 else 0 end as COUNTINR,
           CASE CGM.COLLECTION_CRNCY  when 'INR' then CGM.COLLECTION_AMT else 0 end as INR,
           CASE CGM.COLLECTION_CRNCY  when 'MYR' then 1 else 0 end as COUNTMYR,
           CASE CGM.COLLECTION_CRNCY  when 'MYR' then CGM.COLLECTION_AMT else 0 end as MYR,
           CASE CGM.COLLECTION_CRNCY  when 'SGD' then 1 else 0 end as COUNTSGD,
           CASE CGM.COLLECTION_CRNCY  when 'SGD' then CGM.COLLECTION_AMT else 0 end as SGD
    
    FROM   tbaadm.cgm CGM
    WHERE  CGM.LODG_DATE <=  TO_DATE( CAST (ToTodayDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND    CGM.CLS_FLG = 'Y'
    AND    CGM.ENTITY_CRE_FLG = 'Y'
    AND    CGM.DEL_FLG = 'N'
    )Q
GROUP BY Q.RCODE;
  
  PROCEDURE FIN_INWARD_OUTWARD_FDI(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
       
       RCODE    VARCHAR2(20);
       CountUSD Number(20);
       USD      Number(20,2);
       CountEUR Number(20);
       EUR      Number(20,2);
       CountTHB Number(20);
       THB      Number(20,2);
       CountJPY Number(20);
       JPY      Number(20,2);
       CountINR Number(20);
       INR      Number(20,2);
       CountMYR Number(20);
       MYR      Number(20,2);
       CountSGD Number(20);
       SGD      Number(20,2);
       
  
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
    
  
   vi_ToToDayDate  := outArr(0);
   
    	
   
    
     IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	vi_ToToDayDate  );
			--}
			END;

		--}
		END IF;
   
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	RCODE, CountUSD,  USD,  CountEUR, 
            EUR, CountTHB, THB, CountJPY, JPY, CountINR,INR, CountMYR, MYR, CountSGD, SGD;
      

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
 
----------------------------------USD Rate--------------------------------------
        BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_USDRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'USD') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
              EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_USDRate       := 0.00;
  END;
       
        
----------------------------------EUR Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_EURRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'EUR') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_EURRate       := 0.00;
         END;

----------------------------------SGD Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_SGDRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'SGD') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
              
         END;
----------------------------------INR Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_INRRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'INR') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_INRRate       := 0.00;
         END;
        
----------------------------------THB Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_THBRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'THB') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_THBRate       := 0.00;
         END;
         
----------------------------------MYR Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_MYRRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'MYR') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_MYRRate       := 0.00;
         END;               
----------------------------------JPY Rate--------------------------------------
         BEGIN  
                 SELECT  VAR_CRNCY_UNITS INTO vi_JPYRate
                 FROM (SELECT VAR_CRNCY_UNITS 
                       FROM   tbaadm.RTL  e 
                       WHERE  TRIM(FXD_CRNCY_CODE) in (SELECT CRNCY_CODE FROM tbaadm.cnc WHERE CRNCY_CODE = 'JPY') 
                       AND    TRIM(VAR_CRNCY_CODE) = 'MMK' 
                       AND     RATECODE = ( SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                            WHERE module_name = 'FOREIGN_CURRENCY' 
                                            AND variable_name = 'RATE_CODE')
                      ORDER BY rtlist_date desc)where rownum = 1;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_JPYRate       := 0.00;
         END;  
         
         BEGIN
          SELECT
                 SUM(Q.IUSD)-SUM(Q.OUSD),
                 SUM(Q.IEUR)-SUM(Q.OEUR),
                 SUM(Q.ITHB)-SUM(Q.OTHB),
                 SUM(Q.IJPY)-SUM(Q.OJPY),
                 SUM(Q.IINR)-SUM(Q.OINR),
                 SUM(Q.IMYR)-SUM(Q.OMYR),
                 SUM(Q.ISGD)-SUM(Q.OSGD)
                 INTO NUSD , NEUR, NTHB, NJPY, NINR, NMYR, NSGD
          FROM  (
              SELECT --CGM.COLLECTION_CODE AS RCODE,
                     CASE  when CGM.COLLECTION_CRNCY = 'USD' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as IUSD,
                     CASE  when CGM.COLLECTION_CRNCY = 'USD' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OUSD,
                     CASE  when CGM.COLLECTION_CRNCY = 'EUR' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as IEUR,
                     CASE  when CGM.COLLECTION_CRNCY = 'EUR' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OEUR,
                     CASE  when CGM.COLLECTION_CRNCY = 'THB' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as ITHB,
                     CASE  when CGM.COLLECTION_CRNCY = 'THB' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OTHB,
                     CASE  when CGM.COLLECTION_CRNCY = 'JPY' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as IJPY,
                     CASE  when CGM.COLLECTION_CRNCY = 'JPY' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OJPY,
                     CASE  when CGM.COLLECTION_CRNCY = 'INR' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as IINR,
                     CASE  when CGM.COLLECTION_CRNCY = 'INR' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OINR,
                     CASE  when CGM.COLLECTION_CRNCY = 'MYR' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as IMYR,
                     CASE  when CGM.COLLECTION_CRNCY = 'MYR' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OMYR,
                     CASE  when CGM.COLLECTION_CRNCY = 'SGD' AND  CGM.COLLECTION_CODE = 'TTIUS' then CGM.COLLECTION_AMT else  0 end as ISGD,
                     CASE  when CGM.COLLECTION_CRNCY = 'SGD' AND  CGM.COLLECTION_CODE = 'TTOUS' then CGM.COLLECTION_AMT else 0 end as  OSGD
              
              FROM   tbaadm.cgm CGM
              WHERE  CGM.LODG_DATE <=  TO_DATE( CAST (vi_ToToDayDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              AND    CGM.CLS_FLG = 'Y'
              AND    CGM.ENTITY_CRE_FLG = 'Y'
              AND    CGM.DEL_FLG = 'N'
           )Q
          ;
         END;
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
 
    out_rec:=	(
           RCODE      			|| '|' ||
					 CountUSD         || '|' ||
           USD      			  || '|' ||
					 CountEUR      		|| '|' ||
					 EUR	            || '|' ||
           CountTHB         || '|' ||
					 THB      		  	|| '|' ||
					 CountJPY         || '|' ||
           JPY              || '|' ||
           CountINR         || '|' ||
           INR              || '|' ||
           CountMYR         || '|' ||
           MYR              || '|' ||
           CountSGD         || '|' ||
           SGD              || '|' ||
           vi_USDRate       || '|' ||
           vi_EURRate       || '|' ||
           vi_SGDRate       || '|' ||
           vi_INRRate       || '|' ||
           vi_THBRate       || '|' ||
           vi_MYRRate       || '|' ||
           vi_JPYRate       || '|' ||
           NUSD             || '|' ||
           NEUR             || '|' ||
           NTHB             || '|' ||
           NJPY             || '|' ||
           NINR             || '|' ||
           NMYR             || '|' ||
           NSGD);
  
			dbms_output.put_line(out_rec);

  END FIN_INWARD_OUTWARD_FDI;

END FIN_INWARD_OUTWARD_FDI;
/
