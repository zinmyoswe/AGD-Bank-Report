CREATE OR REPLACE PACKAGE               FIN_STAT_NEW_OPCL_CURRENT_ACC AS 

   PROCEDURE FIN_STAT_NEW_OPCL_CURRENT_ACC(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_STAT_NEW_OPCL_CURRENT_ACC;
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_STAT_NEW_OPCL_CURRENT_ACC AS


-------------------------------------------------------------------------------------
  -- Original Written -  Moe Htet
  -- Corrected Person -  Moe Htet
  -- Corrected Date   -  23-03-2017
	-- Cursor declaration 
	-- This cursor will fetch all the data based on the main query
  -- This Stored Procedural Use With a Temp Table ( custom.CUST_STAT_OPCL_TMP)
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_beforeDate   Varchar2(10);
  limitsize       INTEGER := 500;
  BDUSD              NUMBER;
  BDEUR              NUMBER;
  BDTHB              NUMBER;
  BDJPY              NUMBER;
  BDINR              NUMBER;
  BDMYR              NUMBER;
  BDSGD              NUMBER;

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_beforeDate VARCHAR2)
  IS
  SELECT T.OPENCLOSEDATE AS OPENCLOSEDATE,
      SUM(T.OPENUSD) AS OPENUSD,
      SUM(T.CLOSEUSD) AS CLOSEUSD,
      SUM(T.USDTOTAL) AS USDTOTAL,
      SUM(T.OPENEUR) AS OPENEUR,
      SUM(T.CLOSEEUR) AS CLOSEEUR,
      SUM(T.EURTOTAL) AS EURTOTAL,
      SUM(T.OPENTHB) AS OPENTHB,
      SUM(T.CLOSETHB) AS CLOSETHB,
      SUM(T.THBTOTAL) AS THBTOTAL,
      SUM(T.OPENJPY) AS OPENJPY,
      SUM(T.CLOSEJPY) AS CLOSEJPY,
      SUM(T.JPYTOTAL) AS JPYTOTAL,
      SUM(T.OPENINR) AS OPENINR,
      SUM(T.CLOSEINR) AS CLOSEINR,
      SUM(T.INRTOTAL) AS INRTOTAL,
      SUM(T.OPENMYR) AS OPENMYR,
      SUM(T.CLOSEMYR) AS CLOSEMYR,
      SUM(T.MYRTOTAL) AS MYRTOTAL,
      SUM(T.OPENSGD) AS OPENSGD,
      SUM(T.CLOSESGD) AS CLOSESGD,
      SUM(T.SGDTOTAL) AS SGDTOTAL
      
FROM (
     SELECT                                                                           ----- Before Date Data
              TO_DATE( CAST ( ci_beforeDate AS VARCHAR(10) ) , 'dd-MON-yyyy' )  AS OPENCLOSEDATE,
              0 AS OPENUSD,
              0 AS CLOSEUSD,
              (SUM(q.OpenUSD) -SUM(q.CloseUSD)) as USDTOTAL,
              0 AS OPENEUR,
              0 AS CLOSEEUR,
             (SUM(q.OpenEUR) - SUM(q.CloseEUR) ) as EURTOTAL,
              0 AS OPENTHB,
              0 AS CLOSETHB,
            (SUM(q.OpenTHB)-SUM(q.CloseTHB)) as THBTOTAL,
              0 AS OPENJPY,
              0 AS CLOSEJPY,
             (SUM(q.OpenJPY)-SUM(q.CLOSEJPY)) as JPYTOTAL,
             0 AS OPENINR,
             0 AS CLOSEINR,
             (SUM(q.OpenINR)-SUM(q.CloseINR)) as INRTOTAL,
             0 AS OPENMYR,
             0 AS CLOSEMYR,
            (SUM(q.OpenMYR)-SUM(q.CloseMYR)) as MYRTOTAL,
             0 AS OPENSGD,
             0 AS CLOSESGD,
            (SUM(q.OpenSGD)-SUM(q.CloseSGD)) as SGDTOTAL
            
      FROM (
                SELECT GAM.ACCT_OPN_DATE AS OpenCloseDate,
                
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD'  THEN  1 ELSE 0 END AS OpenUSD,
                       0 AS CloseUSD,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR'  THEN  1 ELSE 0 END AS OpenEUR,
                       0 AS CloseEUR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  1 ELSE 0 END AS OpenTHB,
                       0 AS CloseTHB,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  1 ELSE 0 END AS OpenJPY,
                       0 AS CloseJPY,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR'  THEN  1 ELSE 0 END AS OpenINR,
                       0 AS CloseINR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN  1 ELSE 0 END AS OpenMYR,
                       0 AS CloseMYR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD'  THEN  1 ELSE 0 END AS OpenSGD,
                       0 As Closesgd      
                FROM  TBAADM.GAM GAM, tbaadm.eab
                Where GAM.acct_opn_date < (select max(gg.acct_opn_date)
                                       from tbaadm.gam gg
                                       where gg.acct_opn_date <=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_opn_date >=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
                and     eab.acid = gam.acid
                AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
                 And    Gam.Schm_Code In ('AGCAR','AGDFC')
                 --and    gam.CLR_BAL_AMT <> 0
                And Gam.Acct_Cls_Flg   = 'N'
                AND   gam.del_flg = 'N'
                AND   gam.bank_id ='01'
                
                union all
                
               SELECT GAM.ACCT_OPN_DATE AS OpenCloseDate,
                
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD'  THEN  1 ELSE 0 END AS OpenUSD,
                       0 AS CloseUSD,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR'  THEN  1 ELSE 0 END AS OpenEUR,
                       0 AS CloseEUR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  1 ELSE 0 END AS OpenTHB,
                       0 AS CloseTHB,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  1 ELSE 0 END AS OpenJPY,
                       0 AS CloseJPY,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR'  THEN  1 ELSE 0 END AS OpenINR,
                       0 AS CloseINR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN  1 ELSE 0 END AS OpenMYR,
                       0 AS CloseMYR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD'  THEN  1 ELSE 0 END AS OpenSGD,
                       0 As Closesgd      
                FROM  TBAADM.GAM GAM, tbaadm.eab
                Where    GAM.Acct_Opn_Date = (select max(gg.Acct_Opn_Date)
                                       from tbaadm.gam gg
                                       where gg.Acct_Opn_Date <=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.Acct_Opn_Date >=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
                and     eab.acid = gam.acid
                AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
                 And    Gam.Schm_Code In ('AGCAR','AGDFC')
                 --and    gam.CLR_BAL_AMT <> 0
               -- And Gam.Acct_Cls_Flg   = 'N'
                AND   gam.del_flg = 'N'
                AND   gam.bank_id ='01'
                
                 union all
                
               SELECT GAM.ACCT_OPN_DATE AS OpenCloseDate,
                
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD'  THEN  -1 ELSE 0 END AS OpenUSD,
                       0 AS CloseUSD,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR'  THEN  -1 ELSE 0 END AS OpenEUR,
                       0 AS CloseEUR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  -1 ELSE 0 END AS OpenTHB,
                       0 AS CloseTHB,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN  -1 ELSE 0 END AS OpenJPY,
                       0 AS CloseJPY,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR'  THEN  -1 ELSE 0 END AS OpenINR,
                       0 AS CloseINR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN  -1 ELSE 0 END AS OpenMYR,
                       0 AS CloseMYR,
                       CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD'  THEN  -1 ELSE 0 END AS OpenSGD,
                       0 As Closesgd      
                FROM  TBAADM.GAM GAM, tbaadm.eab
                Where    GAM.acct_cls_date = (select max(gg.acct_cls_date)
                                       from tbaadm.gam gg
                                       where gg.acct_cls_date <=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                                       and gg.acct_cls_date >=TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-4
                                       )
                and     eab.acid = gam.acid
                AND    EAB.EOD_DATE <= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                AND    EAB.END_EOD_DATE >= TO_DATE(CAST(ci_startDate AS VARCHAR(10)), 'dd-MM-yyyy')-1
                And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
                 And    Gam.Schm_Code In ('AGCAR','AGDFC')
                 --and    gam.CLR_BAL_AMT <> 0
               -- And Gam.Acct_Cls_Flg   = 'N'
                AND   gam.del_flg = 'N'
                AND   gam.bank_id ='01')q
                
          UNION ALL 
                                                                            ----- Between Start Date and End Date Data
        SELECT q.OpenCloseDate AS ABC,
            SUM(q.OpenUSD) AS OPENUSD,
           SUM(q.CloseUSD) AS CLOSEUSD,
           (SUM(q.OpenUSD)-SUM(q.CloseUSD)) as USDTOTAL,
            SUM(q.OpenEUR) AS OPENEUR,
           SUM(q.CloseEUR) AS CLOSEEUR,
          ( SUM(q.OpenEUR)- SUM(q.CloseEUR) ) as EURTOTAL,
            SUM(q.OpenTHB) AS  OPENTHB,
           SUM(q.CloseTHB) AS CLOSETHB,
          (SUM(q.OpenTHB)-SUM(q.CloseTHB)) as THBTOTAL,
           SUM(Q.OpenJPY) AS OPENJPY,
           SUM(Q.CLOSEJPY) AS CLOSEJPY,
          (SUM(q.OpenJPY)-SUM(q.CLOSEJPY)) as JPYTOTAL,
           SUM(q.OpenINR) AS OPENINR,
           SUM(q.CloseINR) AS CLOSEINR,
           (SUM(q.OpenINR)-SUM(q.CloseINR)) as INRTOTAL,
           SUM(q.OpenMYR) AS OPENMYR,
           SUM(q.CloseMYR) AS CLOSEMYR,
          (SUM(q.OpenMYR)-SUM(q.CloseMYR)) as MYRTOTAL,
            SUM(q.OpenSGD) AS OPENSGD,
           SUM(q.CloseSGD) AS CLOSESGD,
          (SUM(q.OpenSGD)-SUM(q.CloseSGD)) as SGDTOTAL
    FROM (
              SELECT GAM.ACCT_OPN_DATE AS OpenCloseDate,
              
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD'  THEN  1 ELSE 0 END AS OpenUSD,
                     0 AS CloseUSD,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR'  THEN  1 ELSE 0 END AS OpenEUR,
                     0 AS CloseEUR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB'  THEN  1 ELSE 0 END AS OpenTHB,
                     0 AS CloseTHB,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY'  THEN  1 ELSE 0 END AS OpenJPY,
                     0 AS CloseJPY,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR'  THEN  1 ELSE 0 END AS OpenINR,
                     0 AS CloseINR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR'  THEN  1 ELSE 0 END AS OpenMYR,
                     0 AS CloseMYR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD'  THEN  1 ELSE 0 END AS OpenSGD,
                     0 AS CloseSGD        
              FROM  TBAADM.GAM GAM
              Where   Gam.Acct_Opn_Date >= To_Date( Cast ( Ci_Startdate As Varchar(10) ) , 'dd-MM-yyyy' )
              And   Gam.Acct_Opn_Date <=  To_Date( Cast ( Ci_Enddate As Varchar(10) ) , 'dd-MM-yyyy' )
             And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
              And    Gam.Schm_Code In ('AGCAR','AGDFC')
             --and GAM.ACCT_CLS_FLG   = 'N'
             --and    gam.CLR_BAL_AMT <> 0
              AND   gam.del_flg = 'N'
              AND   gam.bank_id ='01'
             
              
              UNION All
             
              SELECT GAM.ACCT_CLS_date AS OpenCloseDate,
                     0 AS OpenUSD,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD'  THEN  1 ELSE 0 END AS CloseUSD,
                     0 AS OpenEUR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  1 ELSE 0 END AS CloseEUR,
                      0 AS OpenTHB,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB'  THEN  1 ELSE 0 END AS CloseTHB,
                     0 AS OpenJPY,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY'  THEN  1 ELSE 0 END AS CloseJPY,
                     0 AS OpenINR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR'  THEN  1 ELSE 0 END AS CloseINR,
                     0 AS OpenMYR,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR'  THEN  1 ELSE 0 END AS CloseMYR,
                     0 AS OpenSGD,
                     CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD'   THEN  1 ELSE 0 END AS CloseSGD
                     
              FROM  TBAADM.GAM GAM
              Where  Gam.Acct_Cls_Date >= To_Date( Cast ( Ci_Startdate As Varchar(10) ) , 'dd-MM-yyyy' )
              AND   GAM.ACCT_CLS_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
              And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
               and    gam.schm_code in ('AGCAR','AGDFC')
              And Gam.Acct_Cls_Flg   = 'Y'
              --and    gam.CLR_BAL_AMT <> 0
              AND   gam.del_flg = 'N'
              AND   gam.bank_id ='01'
             )q
  Group By q.OpenCloseDate
  HAVING      SUM(q.OpenUSD)  > 0
   OR         SUM(q.CloseUSD) > 0
   OR         (SUM(q.OpenUSD)-SUM(q.CloseUSD)) > 0
   OR         SUM(q.OpenEUR)  > 0
   OR         SUM(q.CloseEUR) > 0
   OR        (SUM(q.OpenEUR)- SUM(q.CloseEUR) ) > 0
   OR         SUM(q.OpenTHB)  > 0
   OR         SUM(q.CloseTHB) > 0
   OR        (SUM(q.OpenTHB)-SUM(q.CloseTHB)) > 0
   OR         SUM(Q.OpenJPY)  > 0
   OR         SUM(Q.CLOSEJPY) > 0
   OR        (SUM(q.OpenJPY)-SUM(q.CLOSEJPY)) > 0
   OR         SUM(q.OpenINR)  > 0
   OR         SUM(q.CloseINR) > 0
   OR         (SUM(q.OpenINR)-SUM(q.CloseINR))> 0
   OR         SUM(q.OpenMYR)  > 0
   OR         SUM(q.CloseMYR) > 0
   OR        (SUM(q.OpenMYR)-SUM(q.CloseMYR)) > 0
   OR         SUM(q.OpenSGD)  > 0
   OR         SUM(q.CloseSGD) > 0 
   OR        (SUM(q.OpenSGD)-SUM(q.CloseSGD))> 0
   --order by q.OpenCloseDate
)T
GROUP BY T.OpenCloseDate
ORDER BY T.OpenCloseDate
 ;
 
 CURSOR ExtractDataForResult IS
SELECT OPENCLOSEDATE,OPENUSD, CLOSEUSD, USDTOTAL,OPENEUR , CLOSEEUR, EURTOTAL,OPENTHB , CLOSETHB, 
        THBTOTAL,OPENJPY , CLOSEJPY, JPYTOTAL, OPENINR, CLOSEINR, INRTOTAL, OPENMYR, CLOSEMYR, MYRTOTAL,OPENSGD,CLOSESGD,SGDTOTAL 
from custom.CUST_STAT_OPCL_TMP ORDER BY ID ;
  
 
  TYPE StatOpClTable IS TABLE OF ExtractData%ROWTYPE INDEX BY BINARY_INTEGER;
   ptStatOpClTable        StatOpClTable;
   
   
  PROCEDURE FIN_STAT_NEW_OPCL_CURRENT_ACC(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
        v_OpenCloseDate  TBAADM.GAM.ACCT_OPN_DATE%TYPE;
        v_OpenUSD        Number(20);
        v_CloseUSD       Number(20);
        v_USD            Number(20); 
        v_OpenEUR        Number(20); 
        v_CloseEUR       Number(20); 
        v_EUR            Number(20);
        v_OpenTHB        Number(20); 
        v_CloseTHB       Number(20); 
        v_THB            Number(20); 
        v_OpenJPY        Number(20); 
        v_CloseJPY       Number(20); 
        v_JPY            Number(20); 
        v_OpenINR        Number(20); 
        v_CloseINR       Number(20); 
        v_INR            Number(20); 
        v_OpenMYR        Number(20); 
        v_CloseMYR       Number(20); 
        v_MYR            Number(20); 
        v_OpenSGD        Number(20); 
        v_CloseSGD       Number(20); 
        v_SGD            Number(20); 
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
    Vi_Enddate    :=  Outarr(1);		
    --vi_branchCode :=  outArr(3);	
    --vi_SchemeType	:=  outArr(2);
    
    if( vi_startDate is null or vi_endDate is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' 
                     || 0 || '|' || 0 || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    /*IF vi_SchemeType IS  NULL or vi_SchemeType = '' THEN
         vi_SchemeType := '';
    END IF;
  
    IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
         vi_branchCode := '';
    END IF;
    */

BEGIN
    SELECT Q.ACCT_OPN_DATE INTO vi_beforeDate
    FROM (
      SELECT   GAM.ACCT_OPN_DATE                
      FROM     TBAADM.GAM
      Where    (Gam.Acct_Opn_Date < To_Date( Cast ( Vi_Startdate As Varchar(10) ) , 'dd-MM-yyyy' ))
      and  (Gam.Acct_Opn_Date >= To_Date( Cast (  Vi_Startdate As Varchar(10) ) , 'dd-MM-yyyy' )-30)
      And    Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
       and    gam.schm_code in ('AGDFC','AGCAR')
      AND      gam.del_flg = 'N'
      AND      gam.bank_id ='01'
      ORDER BY GAM.ACCT_OPN_DATE DESC)Q
     WHERE ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vi_beforeDate := '';   
END;    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_beforeDate);
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			 BEGIN
            DELETE FROM custom.CUST_STAT_OPCL_TMP ; commit;
            
                 FETCH	ExtractData	BULK COLLECT INTO ptStatOpClTable LIMIT limitsize; -- CONTEXT SWITCH METHOD OF ORACLE
            --outer Cursor
                dbms_output.put_line(ptStatOpClTable.count);
                IF  ptStatOpClTable.count > 0 then
                   INSERT INTO custom.CUST_STAT_OPCL_TMP( OPENCLOSEDATE,OPENUSD, CLOSEUSD, USDTOTAL,OPENEUR , CLOSEEUR, EURTOTAL,OPENTHB , CLOSETHB, 
                   THBTOTAL,OPENJPY , CLOSEJPY, JPYTOTAL, OPENINR, CLOSEINR, INRTOTAL, OPENMYR, CLOSEMYR, MYRTOTAL,OPENSGD,CLOSESGD,SGDTOTAL,ID)
 
                     VALUES(
                     ptStatOpClTable(1).OPENCLOSEDATE,
                     ptStatOpClTable(1).OPENUSD,
                     ptStatOpClTable(1).CLOSEUSD,
                     ptStatOpClTable(1).USDTOTAL,
                     ptStatOpClTable(1).OPENEUR,
                     ptStatOpClTable(1).CLOSEEUR,
                     ptStatOpClTable(1).EURTOTAL,
                     ptStatOpClTable(1).OPENTHB,
                     ptStatOpClTable(1).CLOSETHB,
                     ptStatOpClTable(1).THBTOTAL,
                     ptStatOpClTable(1).OPENJPY,
                     ptStatOpClTable(1).CLOSEJPY,
                     ptStatOpClTable(1).JPYTOTAL,                    
                     ptStatOpClTable(1).OPENINR,
                     ptStatOpClTable(1).CLOSEINR,
                     ptStatOpClTable(1).INRTOTAL,
                     ptStatOpClTable(1).OPENMYR,
                     ptStatOpClTable(1).CLOSEMYR,
                     ptStatOpClTable(1).MYRTOTAL,
                     ptStatOpClTable(1).OPENSGD,
                     ptStatOpClTable(1).CLOSESGD,
                     ptStatOpClTable(1).SGDTOTAL,1);
                
                                    
                    FOR X IN 2 .. ptStatOpClTable.COUNT           --outer For loop
                    LOOP  
                          --dbms_output.put_line('before dobal :' + dobal); 
                    BEGIN
                      SELECT CC.USDTOTAL,CC.EURTOTAL,CC.THBTOTAL, CC.JPYTOTAL , CC.INRTOTAL ,CC.MYRTOTAL, CC.SGDTOTAL
                      into BDUSD, BDEUR, BDTHB, BDJPY, BDINR, BDMYR, BDSGD
                      FROM custom.CUST_STAT_OPCL_TMP CC
                      WHERE ID = X-1;
                      EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        BDUSD  := 0; 
                        BDEUR  := 0; 
                        BDTHB  := 0; 
                        BDJPY  := 0; 
                        BDINR  := 0; 
                        BDMYR  := 0; 
                        BDSGD  := 0; 
                    END;
                
                    v_OpenCloseDate := ptStatOpClTable(X).OPENCLOSEDATE;
                    v_OpenUSD       := ptStatOpClTable(X).OPENUSD;
                    v_CloseUSD      := ptStatOpClTable(X).CLOSEUSD;
                    v_USD           := ptStatOpClTable(X).USDTOTAL + BDUSD;
                    v_OpenEUR       := ptStatOpClTable(X).OPENEUR;
                    v_CloseEUR      := ptStatOpClTable(X).CLOSEEUR;
                    v_EUR           := ptStatOpClTable(X).EURTOTAL + BDEUR;
                    v_OpenTHB       := ptStatOpClTable(X).OPENTHB;
                    v_CloseTHB      := ptStatOpClTable(X).CLOSETHB;
                    v_THB           := ptStatOpClTable(X).THBTOTAL + BDTHB;
                    v_OpenJPY       := ptStatOpClTable(X).OPENJPY;
                    v_CloseJPY      := ptStatOpClTable(X).CLOSEJPY;
                    v_JPY           := ptStatOpClTable(X).JPYTOTAL + BDJPY;
                    v_OpenINR       := ptStatOpClTable(X).OPENINR;
                    v_CloseINR      := ptStatOpClTable(X).CLOSEINR;
                    v_INR           := ptStatOpClTable(X).INRTOTAL + BDINR;
                    v_OpenMYR       := ptStatOpClTable(X).OPENMYR;
                    v_CloseMYR      := ptStatOpClTable(X).CLOSEMYR;
                    v_MYR           := ptStatOpClTable(X).MYRTOTAL + BDMYR;
                    v_OpenSGD       := ptStatOpClTable(X).OPENSGD;
                    v_CloseSGD      := ptStatOpClTable(X).CLOSESGD;
                    v_SGD           := ptStatOpClTable(X).SGDTOTAL + BDSGD;
                    
         INSERT INTO custom.CUST_STAT_OPCL_TMP( OPENCLOSEDATE,OPENUSD, CLOSEUSD, USDTOTAL,OPENEUR , CLOSEEUR, EURTOTAL,OPENTHB , CLOSETHB, 
                   THBTOTAL,OPENJPY , CLOSEJPY, JPYTOTAL, OPENINR, CLOSEINR, INRTOTAL, OPENMYR, CLOSEMYR, MYRTOTAL,OPENSGD,CLOSESGD,SGDTOTAL,ID)
         VALUES(v_OpenCloseDate,v_OpenUSD ,v_CloseUSD,v_USD,v_OpenEUR,v_CloseEUR,v_EUR
               ,v_OpenTHB,v_CloseTHB,v_THB,v_OpenJPY ,v_CloseJPY  ,v_JPY ,v_OpenINR ,v_CloseINR,v_INR,
               v_OpenMYR,v_CloseMYR ,v_MYR,v_OpenSGD,v_CloseSGD,v_SGD,X);
        
         
       END LOOP;
       COMMIT;
       dbms_output.put_line('Commit 1'); 
       END  IF;
       END;
     
    

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;
		--}
    END IF;
    
    IF NOT ExtractDataForResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForResult ;
			--}
			END;

		--}
		END IF;
    IF ExtractDataForResult%ISOPEN Then
   
     -- dobal := dobal + OpeningAmount;
      FETCH	ExtractDataForResult INTO	 v_OpenCloseDate,v_OpenUSD ,v_CloseUSD,v_USD,v_OpenEUR,v_CloseEUR,v_EUR
               ,v_OpenTHB,v_CloseTHB,v_THB,v_OpenJPY ,v_CloseJPY  ,v_JPY ,v_OpenINR ,v_CloseINR,v_INR,
               v_OpenMYR,v_CloseMYR ,v_MYR,v_OpenSGD,v_CloseSGD,v_SGD;
     	------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataForResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataForResult;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    
    
  
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
    BEGIN
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      Where
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;  
    

    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
 
    out_rec:=	(
              v_OpenCloseDate || '|' ||
              v_OpenUSD       || '|' ||
              v_CloseUSD      || '|' ||
              v_USD           || '|' ||
              v_OpenEUR       || '|' ||
              v_CloseEUR      || '|' ||
              v_EUR           || '|' ||
              v_OpenTHB       || '|' ||
              v_CloseTHB      || '|' ||
              v_THB           || '|' ||
              v_OpenJPY       || '|' ||
              v_CloseJPY      || '|' ||
              v_JPY           || '|' ||
              v_OpenINR       || '|' ||
              v_CloseINR      || '|' ||
              v_INR           || '|' ||
              v_OpenMYR       || '|' ||
              v_CloseMYR      || '|' ||
              v_MYR           || '|' ||
              v_OpenSGD       || '|' ||
              v_CloseSGD      || '|' ||
              v_SGD           || '|' ||
              v_BranchName 
            );
  
			dbms_output.put_line(out_rec);
  
		
  END FIN_STAT_NEW_OPCL_CURRENT_ACC;

END FIN_STAT_NEW_OPCL_CURRENT_ACC;
/
