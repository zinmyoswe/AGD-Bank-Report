CREATE OR REPLACE PACKAGE        FIN_FOREIGN_CURR_FCYBANK AS 

 PROCEDURE FIN_FOREIGN_CURR_FCYBANK(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FOREIGN_CURR_FCYBANK;
/


CREATE OR REPLACE PACKAGE BODY                                                  FIN_FOREIGN_CURR_FCYBANK AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  vi_branchCode	   	Varchar2(10);               -- Input to procedure
	vi_startDate		Varchar2(20);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2--, ci_endDate VARCHAR2, ci_branchCode VARCHAR2 
      )
  IS
    SELECT  'AGD',
           sum(q.CountUSD),
           sum(q.USD),
           sum(q.CountEUR),
           sum(q.EUR),
           sum(q.CountTHB),
           sum(q.THB),
           sum(q.CountJPY),
           sum(q.JPY),
           sum(q.CountINR),
           sum(q.INR),
           sum(q.CountMYR),
           sum(q.MYR),
           sum(q.CountSGD),
           sum(q.SGD)
    From (Select 
          gam.Gl_Sub_Head_Code,
          Case  When  Gam.Acct_Crncy_Code = 'USD'  Then 1 Else 0 End As Countusd,
          case  when  GAM.ACCT_CRNCY_CODE = 'USD' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as USD,
          case  when  GAM.ACCT_CRNCY_CODE = 'EUR' then 1 else 0 end as CountEUR,
          case  when  GAM.ACCT_CRNCY_CODE = 'EUR' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as EUR,
          case  when  GAM.ACCT_CRNCY_CODE = 'THB' then 1 else 0 end as CountTHB,
          case  when  GAM.ACCT_CRNCY_CODE = 'THB' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as THB,
          case  when  GAM.ACCT_CRNCY_CODE = 'JPY' then 1 else 0 end as CountJPY,
          case  when  GAM.ACCT_CRNCY_CODE = 'JPY' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as JPY,
          case  when  GAM.ACCT_CRNCY_CODE = 'INR' then 1 else 0 end as CountINR,
          case  when  GAM.ACCT_CRNCY_CODE = 'INR' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as INR,
          case  when  GAM.ACCT_CRNCY_CODE = 'MYR' then 1 else 0 end as CountMYR,
          case  when  GAM.ACCT_CRNCY_CODE = 'MYR' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as MYR,
          case  when  GAM.ACCT_CRNCY_CODE = 'SGD' then 1 else 0 end as CountSGD,
          case  when  GAM.ACCT_CRNCY_CODE = 'SGD' then (Select tran_amt
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
                                                                                          group by ctd.tran_date,ctd.acid)) else 0 end as SGD
         
          From Tbaadm.Gam Gam-- , Custom.Custom_Ctd_Dtd_Acli_View ccc
          Where  Gam.Acct_Opn_Date = To_Date( Cast (Ci_Startdate As Varchar(10) ) , 'dd-MM-yyyy' )
        --  And     Gam.Acct_Opn_Date = Ccc.Tran_Date
        --  and    gam.acid = ccc.acid
   --       And     Gam.Acct_Crncy_Code = Ccc.Ref_Crncy_Code
          --And     ccc.Tran_Particular_Code in ('CHD','TRD')
          AND   gam.GL_SUB_HEAD_CODE in ('70103','70313','70311')
          And   Gam.Del_Flg = 'N'
          And   Gam.Entity_Cre_Flg = 'Y'
         /* AND     (GAM.FORACID,GAM.ACCT_OPN_DATE,ccc.TRAN_ID) IN  (SELECT  P.FORACID,P.ACCT_OPN_DATE,MIN(P.TRAN_ID)     
                                                                            From  (
                                                                                     Select  Gam.Acct_Opn_Date,Gam.Foracid,Ctd1.Tran_Id
                                                                                     FROM    CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW ctd1,tbaadm.gam gam
                                                                                     Where   Ctd1.Acid = Gam.Acid
                                                                                     And     Ctd1.Tran_Date = Gam.Acct_Opn_Date
     --                                                                                and     gam.ACCT_CRNCY_CODE = ctd1.ref_crncy_code
                                                                                     And     Gam.Acct_Opn_Date =  To_Date( Cast (ci_startDate As Varchar(10) ) , 'dd-MM-yyyy' )
                                                                                   And     ctd1.Tran_Particular_Code in ('CHD','TRD')
                                                                                     and     gam.Gl_Sub_Head_Code in ('70103','70311','70313')
                                                                                     AND     GAM.DEL_FLG = 'N'
                                                                                     And     Gam.Entity_Cre_Flg = 'Y'
                                                                                     --AND     gam.ACCT_CLS_FLG   = 'N'
                                                                                     ORDER BY CTD1.TRAN_DATE,CTD1.TRAN_ID
                                                                                     )P
                                                                                Group By  P.Foracid,P.Acct_Opn_Date  
            )*/
          )Q     
  GROUP BY 'AGD';
  
  PROCEDURE FIN_FOREIGN_CURR_FCYBANK(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
    

          v_GLSH tbaadm.gam.GL_SUB_HEAD_CODE%type;
          v_CountUSD Number(20,2);
          v_USD TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountEUR Number(20,2);
          v_EUR TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountTHB Number(20,2);
          v_THB TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountJPY Number(20,2);
          v_JPY TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountINR Number(20,2);
          v_INR TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountMYR Number(20,2);
          v_MYR TBAADM.GAM.CLR_BAL_AMT%TYPE;
          v_CountSGD Number(20,2);
          v_SGD TBAADM.GAM.CLR_BAL_AMT%TYPE;
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
   -- vi_endDate    :=  outArr(1);		
   -- vi_branchCode :=  outArr(2);	
 --------------------------------------------------------------------------------------
 
 if( vi_startDate is null) then --or vi_endDate is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 
		            
                   0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||  0  || '|' ||  0  || '|' ||
		          
				   '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||  0  || '|' ||
		           0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' || 0
                   		|| '|' || 0 || '|' || 0 || '|' || '-'  );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

 
 
 ------------------------------------------------------------------------------------------
   
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate );--, vi_endDate  , vi_branchCode );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_GLSH,
            v_CountUSD,v_USD,v_CountEUR,v_EUR,v_CountTHB,v_THB,v_CountJPY,v_JPY,v_CountINR,v_INR,v_CountMYR,v_MYR,
            v_CountSGD,v_SGD;
      

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
    select 
         BRANCH_CODE_TABLE.BR_Name     INTO
         v_BranchName 
      from
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      where
         SERVICE_OUTLET_TABLE.SOL_ID = '20300'
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         and SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         and SERVICE_OUTLET_TABLE.BANK_ID = '01';
    END;  
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_GLSH     			|| '|' ||
					v_CountUSD      || '|' ||
          v_USD  			    || '|' ||
          v_CountEUR    	|| '|' ||
          v_EUR    			  || '|' ||
          v_CountTHB      || '|' ||
          v_THB           || '|' ||
					v_CountJPY	    || '|' ||
					v_JPY      		  || '|' ||
					v_CountINR      || '|' ||
          v_INR           || '|' ||
          v_CountMYR      || '|' ||
          v_MYR           || '|' ||
          v_CountSGD      || '|' ||
          v_SGD           || '|' ||
           v_BranchName );
  
			dbms_output.put_line(out_rec);
  END FIN_FOREIGN_CURR_FCYBANK;

END FIN_FOREIGN_CURR_FCYBANK;
/
