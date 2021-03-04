CREATE OR REPLACE PACKAGE                      FIN_CONDITION_FCY_ACC_OPENING AS 


 PROCEDURE FIN_CONDITION_FCY_ACC_OPENING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CONDITION_FCY_ACC_OPENING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                FIN_CONDITION_FCY_ACC_OPENING AS

-------------------------------------------------------------------------------------
  -- Original Coder - Moe Htet
  -- Corrected      - Moe Htet
  -- Corrected Date - 21-3-2017
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
 -- vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  --vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  --vi_SchemCode    Varchar2(10);
  vi_CountBD        Number := 0;
  limitsize  INTEGER := 200;
  BD    number;
-----------------------------------------------------------------------------
-- CURSOR declaration 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData(	ci_startDate VARCHAR2, ci_endDate VARCHAR2)
  IS
    SELECT R.OPENCLOSEDATE as OPENCLOSEDATE ,
        R.COUNTUSD AS COUNTUSD,
        R.USDAMT AS USDAMT,
        R.CountEUR AS COUNTEUR,
        R.EURAmt AS EURAMT,
        R.CountTHB AS COUNTTHB,
        R.THBAmt AS THBAMT,
        R.CountJPY AS COUNTJPY,
        R.JPYAmt AS JPYAMT,
        R.CountINR AS COUNTINR,
        R.INRAmt AS INRAMT,
          R.CountMYR AS COUNTMYR,
        R.MYRAmt AS MYRAMT,     
        R.CountSGD AS COUNTSGD,
        R.SGDAMT AS SGDAMT,  
    R.CountUSD+R.CountEUR+R.CountTHB+R.CountJPY+R.CountINR+R.CountMYR+R.CountSGD AS TOTAL
    FROM (  
        
            SELECT q.ACCT_OPN_DATE as OPENCLOSEDATE ,
                SUM(Q.CountUSD) as CountUSD,
                SUM(Q.USDAmt) as USDAmt,
                SUM(Q.CountEUR) as CountEUR,
                SUM(Q.EURAmt) as EURAmt,
                SUM(Q.CountTHB) AS CountTHB,
                SUM(Q.THBAmt)as THBAmt,
                SUM(Q.CountJPY) AS CountJPY,
                SUM(Q.JPYAmt)as  JPYAmt,
                SUM(Q.CountINR) AS CountINR,
                SUM(Q.INRAmt)as  INRAmt,
                SUM(Q.CountMYR) AS CountMYR,
                SUM(Q.MYRAmt)as  MYRAmt,
                SUM(Q.CountSGD) AS CountSGD,
                SUM(Q.SGDAmt) as SGDAMT--USD , EUR,THB,JPY,INR,MYR,SGD
           FROM   (
                
                  SELECT  gam.ACCT_OPN_DATE  ,gam.foracid,
         
                 case  when  GAM.ACCT_CRNCY_CODE = 'USD'  then 1 else 0 end as CountUSD,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'USD' THEN t.USDAmt ELSE 0 END AS USDAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'EUR'  then 1 else 0 end as CountEUR,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  t.EURAmt ELSE 0 END AS EURAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'THB' then 1 else 0 end as CountTHB,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'THB' THEN  t.THBAmt ELSE 0 END AS THBAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'JPY' then 1 else 0 end as CountJPY,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'JPY' THEN t.JPYAmt ELSE 0 END AS JPYAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'INR' then 1 else 0 end as CountINR,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN t.INRAmt ELSE 0 END AS INRAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'MYR' then 1 else 0 end as CountMYR,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'MYR' THEN t.MYRAmt ELSE 0 END AS MYRAmt,
                 case  when  GAM.ACCT_CRNCY_CODE = 'SGD' then 1 else 0 end as CountSGD,
                 CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN t.SGDAmt  ELSE 0 END AS SGDAmt
         
         
                 FROM    TBAADM.GAM gam
                 LEFT JOIN(
                    SELECT  gam.ACCT_OPN_DATE,gam.foracid,
                   
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'USD'  then 1 else 0 end as CountUSD,
                   Case  When  Gam.Acct_Crncy_Code = 'USD' Then  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid))
                                                      Else 0 End As Usdamt,
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'EUR' then 1 else 0 end as CountEUR,
                   CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'EUR' THEN  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) ELSE 0 END AS EURAmt,
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'THB'  then 1 else 0 end as CountTHB,
                   Case  When  Gam.Acct_Crncy_Code = 'THB' Then (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) Else 0 End As Thbamt,
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'JPY'  then 1 else 0 end as CountJPY,
                   Case  When  Gam.Acct_Crncy_Code = 'JPY' Then  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) Else 0 End As Jpyamt,
                   --case  when  GAM.ACCT_CRNCY_CODE = 'INR'  then 1 else 0 end as CountINR,
                   CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'INR' THEN  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) ELSE 0 END AS INRAmt,
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'MYR'  then 1 else 0 end as CountMYR,
                   Case  When  Gam.Acct_Crncy_Code = 'MYR' Then  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) Else 0 End As Myramt,
                  -- case  when  GAM.ACCT_CRNCY_CODE = 'SGD'  then 1 else 0 end as CountSGD,
                   CASE  WHEN  GAM.ACCT_CRNCY_CODE = 'SGD' THEN  (Select tran_amt
                                                              From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                              Where    Ctd.Del_Flg = 'N'
                                                               And Ctd.Gl_Sub_Head_Code In ('70103','70311','70313')
                                                              And    Ctd.Bank_Id = '01'
                                                              And    Ctd.Acid = gam.acid
                                                              And    (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) In (
                                                                                          select  ctd.tran_date,min(tran_id),ctd.acid
                                                                                          From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                          Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                          And    Ctd.Del_Flg = 'N'      -- and    ctd.tran_date >= 
                                                                                          And    Ctd.Bank_Id = '01'
                                                                                          And    Ctd.Acid = gam.acid
                                                                                          And    (Ctd.Tran_Date,Ctd.Acid) In (
                                                                                                            select  min(ctd.tran_date),ctd.acid
                                                                                                            From    Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                                                            Where    ctd.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                                            And    Ctd.Del_Flg = 'N'
                                                                                                            And    Ctd.Acid = gam.acid
                                                                                                            and    ctd.tran_date >= gam.ACCT_OPN_DATE
                                                                                                            And    Ctd.Bank_Id = '01'
                                                                                                            Group By Acid)
                                                                                          group by ctd.tran_date,ctd.acid)) ELSE 0 END AS SGDAmt
                   
                   
                   FROM    tbaadm.gam gam
                   Where   Gam.Acct_Opn_Date >=  To_Date( Cast ( ci_startDate As Varchar(10) ) , 'dd-MM-yyyy' )
                   And     Gam.Acct_Opn_Date <=  To_Date( Cast ( ci_endDate As Varchar(10) ) , 'dd-MM-yyyy' )
                   AND    GAM.DEL_FLG = 'N'
                   AND    gam.ENTITY_CRE_FLG = 'Y'
                   And     Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
                   and     gam.schm_code in ('AGDFC','AGCAR'))T
                    ON      T.FORACID = GAM.FORACID 
                    where   GAM.DEL_FLG = 'N'
                    And     Gam.Entity_Cre_Flg = 'Y'
                   -- And     Gam.Acct_Cls_Flg   = 'N'
                   And     Gam.Gl_Sub_Head_Code In ('70103','70311','70313')
                   and     gam.schm_code in ('AGDFC','AGCAR')
                    AND     gam.ACCT_OPN_DATE >=  TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                    AND     gam.ACCT_OPN_DATE <=  TO_DATE( CAST (ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
                   Q
              GROUP BY Q.ACCT_OPN_DATE
             having sum(Q.COUNTUSD) > 0
              or      sum(Q.CountEUR) > 0
              or      sum(Q.CountTHB) > 0
              or      sum(Q.CountJPY) > 0
              or      sum(Q.CountINR) > 0
              or      sum(Q.CountMYR) > 0
              or      sum(Q.CountSGD) > 0
            
              
              
              )R
          --,R.CountEUR,R.CountTHB,R.CountJPY , R.CountINR, R.CountMYR, R.CountSGD
    ORDER BY R.OPENCLOSEDATE  
;

CURSOR ExtractDataForResult IS
select  OPENCLOSEDATE,COUNTUSD, USDAMT, COUNTEUR, EURAMT, COUNTTHB, THBAMT, COUNTJPY, JPYAMT, COUNTINR, INRAMT, COUNTMYR, MYRAMT, COUNTSGD, SGDAMT, ALLCOUNT, COUNTBD, TOTAL from custom.cust_condition_fcy_acc ORDER BY ID ;
  
   TYPE mainretailtable IS TABLE OF ExtractData%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtable         mainretailtable;
 
  PROCEDURE FIN_CONDITION_FCY_ACC_OPENING(	inp_str      IN  VARCHAR2,
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
       v_BranchName     TBAADM.BRANCH_CODE_TABLE.BR_Name%type;
       --v_AllTotal       Number;
       v_CountTotal     Number;
       --v_BFTotal        Number;
       v_Total          Number;
     
   
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
    --vi_SchemeType	:=  outArr(2);
   -- vi_SchemCode  :=  outArr(3);
   -- vi_branchCode :=  outArr(4);
      
      
  -------------------------------------------------------------
     if( vi_startDate is null or vi_endDate is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
		            0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||
					0 || '|' || 0|| '|' || 0 || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0  );
				
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
  
     
  /*  IF vi_SchemCode IS  NULL or vi_SchemCode = '' THEN
         vi_SchemCode := '';
    END IF;
    
    IF vi_SchemeType IS  NULL or vi_SchemeType = '' THEN
         vi_SchemeType := '';
    END IF;
  
    IF vi_branchCode IS  NULL or vi_branchCode = '' OR vi_branchCode='10100' THEN
         vi_branchCode := '';
    END IF;
    
    if vi_branchCode IS NULL OR vi_branchCode = '' then
      begin
      v_BranchName := 'ALL Branch';
      end;
    else*/
      BEGIN
    
--------GET BANKINFORMATION--------------- 
    SELECT 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
    FROM
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    Where
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;  
      -----------Get Before Date Count all account
    Begin
         Select  Count(gam.acid) + 50269 as aa  INTO vi_CountBD    -- Manually count by bank at 01-06-2017  the count must be 50269
         From    Tbaadm.Gam Gam, Custom.Coa_Mp Coa 
         Where   Gam.Acct_Opn_Date >=  To_Date( Cast ( '01-06-2017' As Varchar(10) ) , 'dd-MM-yyyy' )
         and     Gam.Acct_Opn_Date <  To_Date( Cast ( vi_startDate As Varchar(10) ) , 'dd-MM-yyyy' )
         And     Gam.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
         And     Gam.Acct_Crncy_Code = Coa.Cur
         And     Coa.Gl_Sub_Head_Code In ('70103','70311','70313')
         and     gam.schm_code in ('AGDFC','AGCAR')
         AND     GAM.DEL_FLG = 'N'
         And     Gam.Entity_Cre_Flg = 'Y';
       EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vi_CountBD := 0;   
     END;
     

      
      IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData (	
          vi_startDate , vi_endDate   );
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractData%ISOPEN THEN
        --{
            
          begin
            delete from custom.CUST_CONDITION_FCY_ACC ; commit;  
       
       
					v_Total := 0;
      
        
      FETCH	ExtractData	BULK COLLECT INTO ptmainretailtable LIMIT limitsize; 
      --outer Cursor
      dbms_output.put_line(ptmainretailtable.count);
      if  ptmainretailtable.count > 0 then
         INSERT INTO custom.CUST_CONDITION_FCY_ACC( OPENCLOSEDATE,COUNTUSD, USDAMT, COUNTEUR, EURAMT, COUNTTHB, THBAMT, COUNTJPY, JPYAMT, COUNTINR, INRAMT, COUNTMYR, MYRAMT, COUNTSGD, SGDAMT, ALLCOUNT, COUNTBD, TOTAL ,ID)
           VALUES(ptmainretailtable(1).OPENCLOSEDATE,
           ptmainretailtable(1).COUNTUSD,
           ptmainretailtable(1).USDAMT,
           ptmainretailtable(1).COUNTEUR,
           ptmainretailtable(1).EURAMT,
           ptmainretailtable(1).COUNTTHB,
           ptmainretailtable(1).THBAMT,
           ptmainretailtable(1).COUNTJPY,
           ptmainretailtable(1).JPYAMT,
           ptmainretailtable(1).COUNTINR,
           ptmainretailtable(1).INRAMT,
           ptmainretailtable(1).COUNTMYR,
           ptmainretailtable(1).MYRAMT,
           ptmainretailtable(1).COUNTSGD,
           ptmainretailtable(1).SGDAMT,
           ptmainretailtable(1).TOTAL ,
          VI_COUNTBD,
         ( ptmainretailtable(1).TOTAL+VI_COUNTBD),1);
           
      FOR x IN 2 .. ptmainretailtable.COUNT           --outer For loop
      Loop  
           
      
         v_OpenCloseDate := ptmainretailtable(x).OPENCLOSEDATE;
        v_CountUSD  := ptmainretailtable(x).COUNTUSD;
        v_USDAmount := ptmainretailtable(x).USDAMT;
        v_CountEUR     := ptmainretailtable (x).COUNTEUR;
        v_EURAmount := ptmainretailtable (x).EURAMT;
        v_CountTHB  := ptmainretailtable (x).COUNTTHB;
       v_THBAmount := ptmainretailtable (x).THBAMT;
        v_CountJPY  := ptmainretailtable (x).COUNTJPY;
        v_JPYAmount := ptmainretailtable (x).JPYAMT;
        v_CountINR := ptmainretailtable (x).COUNTINR;
       v_INRAmount := ptmainretailtable (x).INRAMT;
        v_CountMYR := ptmainretailtable (x).COUNTMYR;
        v_MYRAmount := ptmainretailtable (x).MYRAMT;
         begin
            SELECT CC.TOTAL into bd 
            FROM custom.CUST_CONDITION_FCY_ACC CC
            WHERE ID = x-1;
        end;
        v_CountSGD := ptmainretailtable (x).COUNTSGD;
        v_SGDAmount := ptmainretailtable (x).SGDAMT;
        v_CountTotal := ptmainretailtable (x).TOTAL;       
        v_Total    := ptmainretailtable (x).TOTAL + bd ;
        Vi_Countbd :=     Bd;
        
        insert into custom.CUST_CONDITION_FCY_ACC( OPENCLOSEDATE,COUNTUSD, USDAMT, COUNTEUR, EURAMT, COUNTTHB, THBAMT, COUNTJPY, JPYAMT, COUNTINR, INRAMT, COUNTMYR, MYRAMT, COUNTSGD, SGDAMT, ALLCOUNT, COUNTBD, TOTAL,ID) 
        values(v_OpenCloseDate,v_CountUSD ,v_USDAmount,v_CountEUR,v_EURAmount,v_CountTHB,
          v_THBAmount,v_CountJPY,v_JPYAmount,v_CountINR, v_INRAmount, v_CountMYR , v_MYRAmount,v_CountSGD ,v_SGDAmount,
          v_CountTotal, vi_CountBD,v_Total,x);
        commit;
                          
      End Loop;
      Else 
        Begin 
           Select To_Date( Cast ( vi_startDate As Varchar(10) ) , 'dd-MM-yyyy' ) INTO  v_OpenCloseDate  
           FROM DUAL;
        END;
        V_Total := vi_CountBD+V_Total;
         insert into custom.CUST_CONDITION_FCY_ACC( OPENCLOSEDATE,COUNTUSD, USDAMT, COUNTEUR, EURAMT, COUNTTHB, THBAMT, COUNTJPY, JPYAMT, COUNTINR, INRAMT, COUNTMYR, MYRAMT, COUNTSGD, SGDAMT, ALLCOUNT, COUNTBD, TOTAL,ID) 
        values(v_OpenCloseDate,0 ,0,0,0,0,
          0,0,0,0, 0, 0 , 0,0 ,0,
          0, Vi_Countbd,V_Total,1);
           Dbms_Output.Put_Line(V_Usdamount); 
        dbms_output.put_line(v_OpenCloseDate); 
        commit;
      
      end if;
      end;
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
      FETCH	ExtractDataForResult INTO	 v_OpenCloseDate,v_CountUSD ,v_USDAmount,v_CountEUR,v_EURAmount,v_CountTHB,
          v_THBAmount,v_CountJPY,v_JPYAmount,v_CountINR, v_INRAmount, v_CountMYR , v_MYRAmount,v_CountSGD ,v_SGDAmount,
          v_CountTotal, vi_CountBD,v_Total;
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
          v_BranchName       || '|' ||
          v_CountTotal       || '|' ||
          vi_CountBD         || '|' ||
          v_Total         
            
          );
  
			dbms_output.put_line(out_rec);
      
  END FIN_CONDITION_FCY_ACC_OPENING;

END FIN_CONDITION_FCY_ACC_OPENING;
/
