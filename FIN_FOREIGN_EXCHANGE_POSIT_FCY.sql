CREATE OR REPLACE PACKAGE FIN_FOREIGN_EXCHANGE_POSIT_FCY AS 

   PROCEDURE FIN_FOREIGN_EXCHANGE_POSIT_FCY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 
 

END FIN_FOREIGN_EXCHANGE_POSIT_FCY;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         FIN_FOREIGN_EXCHANGE_POSIT_FCY AS

-----for CBM Report------with two tempt  CUSTOM.CUST_FOREIGN_EXCHANGE_TMP & CUSTOM.CUST_OPEN_FOREI_EXCH_POSIT
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;      -- Input Parse Array
	v_TranDate		  Varchar2(14);		    	    -- Input to procedure
  v_Currency_Type varchar2(30);
  vi_id  NUMBER(10) :=  0;
  
  vi_USDRate DECIMAL;
  vi_EURRate DECIMAL;
  vi_SGDRate DECIMAL;
  vi_INRRate DECIMAL;
  vi_THBRate DECIMAL;
  vi_MYRRate DECIMAL;
  Vi_Jpyrate Decimal;

  
  /*TIC_SubHeader VARCHAR2(100);
  TIC_USD       number(20,2);
  TIC_EUR       number(20,2);
  TIC_THB       number(20,2);
  TIC_JPY       number(20,2); 
  TIC_INR       number(20,2); 
  TIC_MYR       number(20,2);
  TIC_SGD       number(20,2);
  TIC_ABC       Varchar2(30);*/
  Tic_Abc       Varchar2(30);
  TIC_amt       number(20,2);
  
  TotalUSD       number(20,2);
  TotalEUR       number(20,2);
  TotalTHB       number(20,2);
  TotalJPY       number(20,2);
  TotalINR       number(20,2);
  TotalMYR       number(20,2);
  TotalSGD       number(20,2);
  

  -----------------cursor------------------
  CURSOR ExtractDataForResult IS
select  rpt.ASSET_TYPE,
Rpt.Header,
Rpt.Sub_Header,
Rpt.Usd * Vi_Usdrate,
Rpt.Eur * Vi_Eurrate,
Rpt.Thb * Vi_Thbrate,
Rpt.Jpy * Vi_Jpyrate,
Rpt.Inr * Vi_Inrrate,
Rpt.Myr * Vi_Myrrate,
Rpt.Sgd * vi_SGDRate,
RPT.COUNTROW
from CUSTOM.CUST_FOREIGN_EXCHANGE_TMP RPT order by rpt.id;


  --------Insert Into Temp Declaration-------
  vi_Type      VARCHAR2(100);
  vi_Header    VARCHAR2(100);
  vi_SubHeader VARCHAR2(100);
  vi_USD       NUMBER(20,2);
  vi_EUR       NUMBER(20,2);
  vi_THB       NUMBER(20,2);
  vi_JPY       NUMBER(20,2);
  vi_INR       NUMBER(20,2);
  vi_MYR       NUMBER(20,2);
  vi_SGD       NUMBER(20,2);
-------------------------------Asset Type---------------------------------------

  -------------function for Monetary ASSETS for Only one GL----------------
  FUNCTION ASSETONE(ci_GroupCode VARCHAR2,ci_title VARCHAR2,ci_subtitle VARCHAR2,ci_TranDate VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(50) := ci_GroupCode;
  BEGIN
     BEGIN
     Select 'MONETARY ASSET' As Asset,
            Ci_Title As Title,
            Ci_Subtitle As Subtitle,
            Abs(Sum(Q.Usd)),
            Abs(Sum(Q.Eur)),
            Abs(Sum(Q.Thb)),
            Abs(Sum(Q.Jpy)),
            Abs(Sum(Q.Inr)),
            Abs(Sum(Q.Myr)),
            abs(SUM(Q.SGD))
            INTO vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD
      FROM(
            SELECT  
                    case GSTT.CRNCY_CODE when 'USD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as USD,
                    case GSTT.CRNCY_CODE when 'EUR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as EUR,
                    case GSTT.CRNCY_CODE when 'THB' then TOT_CR_BAL-TOT_DR_BAL else 0 end as THB,
                    case GSTT.CRNCY_CODE when 'JPY' then TOT_CR_BAL-TOT_DR_BAL else 0 end as JPY,
                    case GSTT.CRNCY_CODE when 'INR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as INR,
                    case GSTT.CRNCY_CODE when 'MYR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as MYR,
                    case GSTT.CRNCY_CODE when 'SGD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as SGD
                    
            From   Tbaadm.Gstt Gstt, Custom.coa_mp coa
            Where  Gstt.Bal_Date <= To_Date( Cast (V_Trandate As Varchar(10) ) , 'dd-MM-yyyy' )
            and    GSTT.end_BAL_DATE >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND    GSTT.DEL_FLG = 'N'
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            and    gstt.CRNCY_CODE     = coa.cur
            And    Gstt.Bank_Id = '01'
            and    coa.group_code = ci_GroupCode       
          )Q
     ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Vi_Type      := 'MONETARY ASSET';
        Vi_Header    :=  Ci_Title;
        vi_SubHeader :=  ci_subtitle;
        vi_USD       := 0.00;
        vi_EUR       := 0.00;
        vi_THB       := 0.00;
        vi_JPY       := 0.00;
        vi_INR       := 0.00;
        vi_MYR       := 0.00;
        vi_SGD       := 0.00;
end;
 INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
 VALUES (vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD,ci_RowNumber,vi_id);
 COMMIT;
      vi_id := vi_id +1;
  RETURN v_returnValue; 
  END;
--------------------------------------------------------------------------------  
 
-------------------------------------------------------------------------------- 

  -------------function for Monetary ASSETS for Group GL----------------
  FUNCTION ASSETGROUP(ci_GroupCode VARCHAR2,ci_title VARCHAR2,ci_subtitle VARCHAR2,ci_TranDate VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(100) := ci_GroupCode;
  BEGIN
     BEGIN
     SELECT 'MONETARY ASSET' AS ASSET,
            Ci_Title,
            Ci_Subtitle,
            Nvl(Abs(Sum(Q.Usd)),0),
            Nvl(Abs(Sum(Q.Eur)),0),
            Nvl(Abs(Sum(Q.Thb)),0),
            Nvl(Abs(Sum(Q.Jpy)),0),
            Nvl(Abs(Sum(Q.Inr)),0),
            Nvl(Abs(Sum(Q.Myr)),0),
            Nvl(abs(Sum(Q.Sgd)),0)
            INTO vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD
      FROM(
            SELECT  
                    Case Gstt.Crncy_Code When 'USD' Then Tot_Cr_Bal-Tot_Dr_Bal Else 0 End As Usd,
                    case GSTT.CRNCY_CODE when 'EUR' then tOT_CR_BAL-TOT_DR_BAL else 0 end as EUR,
                    case GSTT.CRNCY_CODE when 'THB' then TOT_CR_BAL-TOT_DR_BAL else 0 end as THB,
                    Case Gstt.Crncy_Code When 'JPY' Then Tot_Cr_Bal-Tot_Dr_Bal Else 0 End As Jpy,
                    case GSTT.CRNCY_CODE when 'INR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as INR,
                    case GSTT.CRNCY_CODE when 'MYR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as MYR,
                    case GSTT.CRNCY_CODE when 'SGD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as SGD
                    
            FROM   tbaadm.GSTT GSTT, CUSTOM.coa_mp coa
            WHERE  Gstt.Bal_Date <= To_Date( Cast (V_Trandate As Varchar(10) ) , 'dd-MM-yyyy' )
            and    GSTT.end_BAL_DATE >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            And    Gstt.Del_Flg = 'N'
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            and    gstt.CRNCY_CODE   = coa.cur
            And    Gstt.Bank_Id = '01'
            AND    coa.group_code in  (substr(ci_GroupCode,0,3),substr(ci_GroupCode,4,7))
          )Q

     ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vi_Type      := 'MONETARY ASSET';
        vi_Header    := ci_title;
        vi_SubHeader := ci_subtitle;
        vi_USD       := 0.00;
        vi_EUR       := 0.00;
        vi_THB       := 0.00;
        vi_JPY       := 0.00;
        vi_INR       := 0.00;
        vi_MYR       := 0.00;
        vi_SGD       := 0.00;
  End;
 -- vi_SubHeader := ABC;
    INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
    VALUES (vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD,ci_RowNumber,vi_id);
    COMMIT;
    vi_id := vi_id +1;
  RETURN v_returnValue; 
  END;


---------------------------------------------------* Monetary Liabilities * ----------------------------------------------------------

-----------------------------------------function for Monetary LIABILITIES for Only one GL---------------------------------------
 
  FUNCTION LIAONE(ci_GroupCode VARCHAR2,ci_title VARCHAR2,ci_subtitle VARCHAR2,ci_TranDate VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(100) := ci_GroupCode;
  BEGIN
     BEGIN
     SELECT 'MONETARY LIABILITIES' AS LIA,
            ci_title,
            Ci_Subtitle ,
            Nvl(Sum(Q.Usd),0),
            Nvl(Sum(Q.Eur),0),
            Nvl(Sum(Q.Thb),0),
            Nvl(Sum(Q.Jpy),0),
            Nvl(Sum(Q.Inr),0),
            Nvl(Sum(Q.Myr),0),
            nvl(SUM(Q.SGD),0)
            Into Vi_Type, Vi_Header, Vi_Subheader,Vi_Usd,Vi_Eur, Vi_Thb, Vi_Jpy, Vi_Inr, Vi_Myr,Vi_Sgd
      FROM(
            SELECT  
                    case GSTT.CRNCY_CODE when 'USD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as USD,
                    case GSTT.CRNCY_CODE when 'EUR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as EUR,
                    case GSTT.CRNCY_CODE when 'THB' then TOT_CR_BAL-TOT_DR_BAL else 0 end as THB,
                    case GSTT.CRNCY_CODE when 'JPY' then TOT_CR_BAL-TOT_DR_BAL else 0 end as JPY,
                    case GSTT.CRNCY_CODE when 'INR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as INR,
                    case GSTT.CRNCY_CODE when 'MYR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as MYR,
                    case GSTT.CRNCY_CODE when 'SGD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as SGD
                    
            FROM   tbaadm.GSTT GSTT, CUSTOM.coa_mp coa
            WHERE  Gstt.Bal_Date <= To_Date( Cast (V_Trandate As Varchar(10) ) , 'dd-MM-yyyy' )
            and    GSTT.end_BAL_DATE >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND    GSTT.DEL_FLG = 'N'
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            and    gstt.CRNCY_CODE   = coa.cur
            And    Gstt.Bank_Id = '01'
            AND    coa.group_code in  (ci_GroupCode)
          )Q
     ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Vi_Type      := 'MONETARY LIABILITIES';
        Vi_Header    := ci_title;
        vi_SubHeader := ci_subtitle;
        vi_USD       := 0.00;
        vi_EUR       := 0.00;
        vi_THB       := 0.00;
        vi_JPY       := 0.00;
        vi_INR       := 0.00;
        vi_MYR       := 0.00;
        vi_SGD       := 0.00;
end;
 INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
 VALUES (vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD,ci_RowNumber,vi_id);
 COMMIT;
 vi_id := vi_id +1;
  RETURN v_returnValue; 
  END;
--------------------------------------------------------------------------------  
  
------------------function for Monetary LIABILITIES NO GL NO DATA----------------------
  FUNCTION LIA(ABC VARCHAR2,ci_TranDate VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(100) := ABC;
  BEGIN
     BEGIN
     SELECT 'MONETARY LIABILITIES' AS LIA,
            Q.VARIABLE_NAME,
            Q.DESCRIPTION ,
            SUM(Q.USD),
            SUM(Q.EUR),
            SUM(Q.THB),
            SUM(Q.JPY),
            SUM(Q.INR),
            SUM(Q.MYR),
            SUM(Q.SGD)
            INTO vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD
      FROM(
            SELECT  RPT.DESCRIPTION AS DESCRIPTION, RPT.VARIABLE_NAME AS VARIABLE_NAME,
                    case GSTT.CRNCY_CODE when 'USD' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as USD,
                    case GSTT.CRNCY_CODE when 'EUR' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as EUR,
                    case GSTT.CRNCY_CODE when 'THB' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as THB,
                    case GSTT.CRNCY_CODE when 'JPY' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as JPY,
                    case GSTT.CRNCY_CODE when 'INR' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as INR,
                    case GSTT.CRNCY_CODE when 'MYR' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as MYR,
                    case GSTT.CRNCY_CODE when 'SGD' then ABS(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) else 0 end as SGD
                    
            FROM   tbaadm.GSTT GSTT, CUSTOM.CUST_OPEN_FOREI_EXCH_POSIT RPT
            WHERE  Gstt.Bal_Date <= To_Date( Cast (V_Trandate As Varchar(10) ) , 'dd-MM-yyyy' )
            and    GSTT.end_BAL_DATE >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND    GSTT.DEL_FLG = 'N'
            AND    GSTT.GL_SUB_HEAD_CODE = RPT.VARIABLE_VALUE
            AND    GSTT.BANK_ID = '01'
            AND    GSTT.GL_SUB_HEAD_CODE in  (SELECT VARIABLE_VALUE FROM CUSTOM.CUST_OPEN_FOREI_EXCH_POSIT RPT
                                                WHERE description = ABC
                                                AND GROUP_NAME = 'LIA')
          )Q
      GROUP BY  Q.VARIABLE_NAME,Q.DESCRIPTION
     ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vi_Type      := 'MONETARY LIABILITIES';
         BEGIN
        SELECT RPT.VARIABLE_NAME  INTO vi_Header 
        FROM CUSTOM.CUST_OPEN_FOREI_EXCH_POSIT RPT
        WHERE  RPT.DESCRIPTION = ABC
        AND GROUP_NAME = 'LIA';
        END;
      
        vi_SubHeader := ABC;
        vi_USD       := 0.00;
        vi_EUR       := 0.00;
        vi_THB       := 0.00;
        vi_JPY       := 0.00;
        vi_INR       := 0.00;
        vi_MYR       := 0.00;
        vi_SGD       := 0.00;
END;
      --vi_Header      := ABC;
 INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
 VALUES (vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD,ci_RowNumber,vi_id);
 COMMIT;
 vi_id := vi_id +1;
  RETURN v_returnValue; 
  END;
-------------------------------------------------------------------------------- 

  ------------- function for Monetary LIABILITIES for Group GL----------------
  FUNCTION LIAGROUP(ci_GroupCode VARCHAR2,ci_title VARCHAR2,ci_subtitle VARCHAR2,ci_TranDate VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(100) := ci_GroupCode;
  BEGIN
     BEGIN
     SELECT 'MONETARY LIABILITIES' AS LIA,
            Ci_Title,
            Ci_Subtitle,
           Nvl(  Sum(Q.Usd),0),
           Nvl(  Sum(Q.Eur),0),
           Nvl(  Sum(Q.Thb),0),
           Nvl(  Sum(Q.Jpy),0),
           Nvl(  Sum(Q.Inr),0),
           Nvl(  Sum(Q.Myr),0),
           nvl(  Sum(Q.Sgd),0)
            INTO vi_Type, vi_Header,vi_SubHeader, vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD
      FROM(
            SELECT  
                    case GSTT.CRNCY_CODE when 'USD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as USD,
                    case GSTT.CRNCY_CODE when 'EUR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as EUR,
                    case GSTT.CRNCY_CODE when 'THB' then TOT_CR_BAL-TOT_DR_BAL else 0 end as THB,
                    case GSTT.CRNCY_CODE when 'JPY' then TOT_CR_BAL-TOT_DR_BAL else 0 end as JPY,
                    case GSTT.CRNCY_CODE when 'INR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as INR,
                    case GSTT.CRNCY_CODE when 'MYR' then TOT_CR_BAL-TOT_DR_BAL else 0 end as MYR,
                    case GSTT.CRNCY_CODE when 'SGD' then TOT_CR_BAL-TOT_DR_BAL else 0 end as SGD
                    
            FROM   tbaadm.GSTT GSTT, custom.coa_mp coa
            WHERE  Gstt.Bal_Date <= To_Date( Cast (V_Trandate As Varchar(10) ) , 'dd-MM-yyyy' )
            and    GSTT.end_BAL_DATE >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND    GSTT.DEL_FLG = 'N'
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            and    gstt.CRNCY_CODE   = coa.cur
            And    Gstt.Bank_Id = '01'
            AND    coa.group_code in  (  substr(ci_GroupCode,0,3),substr(ci_GroupCode,4,7))
          )Q
     ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vi_Type      := 'MONETARY LIABILITIES';
        vi_Header    := Ci_Title;
        vi_SubHeader := ci_subtitle;
        vi_USD       := 0.00;
        vi_EUR       := 0.00;
        vi_THB       := 0.00;
        vi_JPY       := 0.00;
        vi_INR       := 0.00;
        vi_MYR       := 0.00;
        vi_SGD       := 0.00;
  END;
    INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
    VALUES (vi_Type, vi_Header, vi_SubHeader,vi_USD,vi_EUR, vi_THB, vi_JPY, vi_INR, vi_MYR,vi_SGD,ci_RowNumber,vi_id);
    COMMIT;
    vi_id := vi_id +1;
  RETURN v_returnValue; 
  END;
  

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE FIN_FOREIGN_EXCHANGE_POSIT_FCY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      
        ASSETLIABILITIES VARCHAR2(100);
        TitleName  VARCHAR(100);
        SubTitleName  VARCHAR(100);
        USD NUMBER(20,2);
        EUR NUMBER(20,2);
        THB NUMBER(20,2);
        JPY NUMBER(20,2);
        INR NUMBER(20,2);
        MYR NUMBER(20,2);
        SGD NUMBER(20,2);
        OUTPUT VARCHAR(100);
        RowNumber VARCHAR(50);
        
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
    
    V_Trandate  :=  Outarr(0);
   v_Currency_Type := outArr(1);
----------------------------------------------------------------------------------

if( v_TranDate is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 
		            0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||  0  || '|' ||  0  || '|' ||
		          
				   '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' ||  0  || '|' ||
		           '-' || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' ||  0 || '|' || 0
                   		|| '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0 || '|' || 0   );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;


--------------------------------------------------------------------------------------
        
        DELETE FROM CUSTOM.CUST_FOREIGN_EXCHANGE_TMP;

--IF NO DATA USE ASSET OR LIA FUNTION
        
-------------------------------------ASSET--------------------------------------

        INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
        VALUES ('MONETARY ASSET', 'Cash And Cash Equivalents',  'Cash And Cash Equivalents',0.00,0.00, 0.00, 0.00, 0.00, 0.00,0.00,'1.',vi_id);
        Commit;
        
        vi_id := vi_id +1; 
        OUTPUT  :=  ASSETONE('A02','Cash and Cash Equivalents','Cash In Vault',v_TranDate, '    1.a.');
        
        OUTPUT  :=  ASSETONE('A05','Cash and Cash Equivalents','Due From CBM',v_TranDate, '    1.b.');
        
        Output  :=  Assetone('AA', 'Cash and Cash Equivalents','Cash Items In Process Of Collection',V_Trandate, '    1.c.');
        
 -------------------------------------------------------------------------------  
        vi_id := vi_id +1;
        INSERT INTO CUSTOM.CUST_FOREIGN_EXCHANGE_TMP 
        VALUES ('MONETARY ASSET', 'CLaims on Financial Institutions',  'CLaims on Financial Institutions',0.00,0.00, 0.00, 0.00, 0.00, 0.00,0.00,'2.',vi_id);
        Commit;
         vi_id := vi_id +1;   
        OUTPUT  :=  ASSETGROUP('A06A07','CLaims on Financial Institutions','Domestic Financial Institutions',v_TranDate, '    2.a.' );

        OUTPUT  :=  ASSETONE('A08','CLaims on Financial Institutions','Foreign Financial Institution',v_TranDate, '    2.b.' );
        
        OUTPUT  :=  ASSETONE('Nothing','Investments', 'Investments',v_TranDate, '3');
    
        OUTPUT  :=  ASSETONE('Nothing','Bill Purchased','Bill Purchased',v_TranDate, '4');

        OUTPUT  :=  ASSETONE('Nothing','Loans to NFIs and Other Clients','Loans to NFIs and Other Clients',v_TranDate, '5');
        
        OUTPUT  :=  ASSETONE('Nothing','Accrued Int Receivable and other Monetary Assets','Accrued Int Receivable and other Monetary Assets',v_TranDate, '6');
        
        OUTPUT  :=  ASSETONE('Nothing','Balance Held Against Forward Sales','Balance Held Against Forward Sales',v_TranDate, '7');

        OUTPUT  :=  ASSETONE('Nothing','Off Balance Sheet Items(Asset)','Off Balance Sheet Items(Asset)',v_TranDate, '8');
        
        OUTPUT  :=  ASSETONE('Nothing','Off Balance Sheet Items(Asset)','Undelivered Spot Purchases',v_TranDate, '    8.a.');

        OUTPUT  :=  ASSETONE('Nothing','Off Balance Sheet Items(Asset)','Forward Purchases',v_TranDate, '    8.b.');
  
        OUTPUT  :=  ASSETONE('A90','Off Balance Sheet Items(Asset)','Others Asset',v_TranDate, '    8.c.');
   
-----------------------------LIABILITIES---------------------------------------------------------------------------------------------------------------------------------
        
        OUTPUT  :=  LIAONE('L21','Claims of Financial Institutions','Claims of Financial Institutions',v_TranDate, '10.');
    
        OUTPUT  :=  LIAONE('L11','Deposits of NFIs and Other Clients','Deposits of NFIs and Other Clients',v_TranDate, '11.');
        
        OUTPUT  :=  LIAONE('Nothing','Short-term and Long-term Borrowings','Short-term and Long-term Borrowings',v_TranDate, '12.');
        
        OUTPUT  :=  LIAGROUP('L51L57','Accrued Int: Payable and other Monetary Liabilities','Accrued Int: Payable and other Monetary Liabilities',v_TranDate, '13.');
        
        OUTPUT  :=  LIAONE('Nothing','Off Balance Sheet Items(Liabilities)','Off Balance Sheet Items(Liabilities)',v_TranDate, '14.');

        OUTPUT  :=  LIAONE('Nothing','Off Balance Sheet Items(Liabilities)','Undelivered Spot Sales',v_TranDate, '    14.a.');
        
        OUTPUT  :=  LIAONE('Nothing','Off Balance Sheet Items(Liabilities)','Forward Sales',v_TranDate, '    14.b.');
        
        OUTPUT  :=  LIAONE('L80','Off Balance Sheet Items(Liabilities)','Others Liability',v_TranDate, '    14.c.');
        
  BEGIN
      Select   
          'Tier I Capitacal' as T1,
          Sum(L01) As Total
          into Tic_Abc, TIC_amt
      From(
            Select TOT_CR_BAL-TOT_DR_BAL as L01   ----Paid up Capital(kyats)
            FROM   tbaadm.GSTT GSTT , custom.coa_mp coa
            WHERE  Gstt.Bal_Date <= To_Date( Cast (v_TranDate As Varchar(10) ) , 'dd-MM-yyyy' )
            And    Gstt.End_Bal_Date >= To_Date( Cast (v_TranDate As Varchar(10) ) , 'dd-MM-yyyy' )
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            And    Coa.Group_Code = 'L01'
            and    coa.cur = 'MMK'
            and    gstt.CRNCY_CODE    = coa.cur
            AND    GSTT.DEL_FLG = 'N'
            And    Gstt.Bank_Id = '01'
            
            Union All
            
            Select sum(abs(TOT_CR_BAL)-abs(TOT_DR_BAL)) as L01  --dif:Income and Expenditure
            FROM   tbaadm.GSTT GSTT , custom.coa_mp coa
            WHERE  Gstt.Bal_Date <= To_Date( Cast (v_TranDate As Varchar(10) ) , 'dd-MM-yyyy' )
            And    Gstt.End_Bal_Date >= To_Date( Cast (v_TranDate As Varchar(10) ) , 'dd-MM-yyyy' )
            And    Gstt.Gl_Sub_Head_Code = Coa.Gl_Sub_Head_Code
            And    Coa.Group_Code In ( 'L40','A50')
            and    coa.cur = 'MMK'
            and    gstt.CRNCY_CODE    = coa.cur
            And    Gstt.Del_Flg = 'N'
            And    Gstt.Bank_Id = '01'
            
            union all
            
                    Select  
                      Tran_date_bal as L01
                     FROM  TBAADM.EAB EAB, TBAADM.GAM GAM
                     WHERE EAB.ACID = GAM.ACID 
                     AND   EAB.EOD_DATE <= TO_DATE(CAST(v_TranDate AS VARCHAR(10)),'dd-MM-yyyy')
                     And   Eab.End_Eod_Date >=  To_Date(Cast(v_TranDate As Varchar(10)),'dd-MM-yyyy')
                     AND   GAM.FORACID LIKE '%70021010011%'
                     AND   GAM.DEL_FLG = 'N'
                     AND   GAM.ENTITY_CRE_FLG = 'Y'
                     And   Eab.Bank_Id = '01'
                     AND   GAM.BANK_ID = '01'
                     
                     union all
                     
              Select  
                      4138000000 as L01 --Paid up capital FE
                     FROM dual
                  
         )Q

    ;
  END;
        
If  v_Currency_Type like 'Converted FCY%'  then  

    Vi_Usdrate := 1 ;
    Vi_Eurrate := 1 ;
    vi_SGDRate := 1 ;
    vi_INRRate := 1 ;
    vi_THBRate := 1 ;
    Vi_Myrrate := 1 ;
    Vi_Jpyrate := 1 ;
  --------------------------------------------------------------------------------
  ----------------------------------cursor call-----------------------------------
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
        FETCH	ExtractDataForResult INTO	ASSETLIABILITIES, TitleName,SubTitleName, USD, EUR, THB, JPY ,INR ,MYR, SGD, RowNumber ;
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
      End If;
END IF;

 
----------------------------------USD Rate--------------------------------------
        BEGIN  
                SELECT r.VAR_CRNCY_UNITS INTO vi_USDRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('USD') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
              EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_USDRate       := 0.00;
  END;
       
        
----------------------------------EUR Rate--------------------------------------
         BEGIN  
                  SELECT r.VAR_CRNCY_UNITS INTO vi_EURRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('EUR') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_EURRate       := 0.00;
         END;

----------------------------------SGD Rate--------------------------------------
         Begin  
                  SELECT r.VAR_CRNCY_UNITS INTO vi_SGDRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('SGD') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
                 EXCEPTION
                     When No_Data_Found Then
                     vi_SGDRate       := 0.00;
         END;
----------------------------------INR Rate--------------------------------------
        Begin  
                  SELECT r.VAR_CRNCY_UNITS INTO vi_INRRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('INR') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_INRRate       := 0.00;
         END;
        
----------------------------------THB Rate--------------------------------------
         Begin  
                   SELECT r.VAR_CRNCY_UNITS INTO vi_thbRate
                                From Tbaadm.Rth R
                                where trim(r.fxd_crncy_code) = trim('THB') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_THBRate       := 0.00;
         END;
         
----------------------------------MYR Rate--------------------------------------
         Begin  
                   SELECT r.VAR_CRNCY_UNITS INTO vi_MYRRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('MYR') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_MYRRate       := 0.00;
         END;               
----------------------------------JPY Rate--------------------------------------
         BEGIN  
                  SELECT r.VAR_CRNCY_UNITS INTO vi_JPYRate
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim('JPY') and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    );
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     vi_JPYRate       := 0.00;
         END; 
      
      
If  v_Currency_Type like 'Converted MMK%'  then  
  --------------------------------------------------------------------------------
  ----------------------------------cursor call-----------------------------------
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
        FETCH	ExtractDataForResult INTO	ASSETLIABILITIES, TitleName,SubTitleName, USD, EUR, THB, JPY ,INR ,MYR, SGD, RowNumber ;
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
      End If;
END IF;    
         
    begin 
    select q.AUSD - q.LUSD,
        q.AEUR - q.LEUR ,
        q.ATHB - q.LTHB,
        q.AJPY - q.LJPY,
        q.AINR- q.LINR,
        q.AMYR - q.LMYR,
        q.ASGD - q.LSGD 
       into TotalUSD,TotalEUR,TotalTHB,TotalJPY,TotalINR,TotalMYR,TotalSGD
    from (
      select sum(t.AUSD) as AUSD,sum(t.AEUR)as AEUR,sum(t.ATHB)as ATHB,sum(t.AJPY)as AJPY,
      sum(t.AINR)as AINR,sum(t.AMYR)as AMYR,sum(t.ASGD)as ASGD,
      sum(t.LUSD)as LUSD,sum(t.LEUR)as LEUR,sum(t.LTHB)as LTHB,sum(t.LJPY)as LJPY,
      sum(t.LINR)as LINR,sum(t.LMYR)as LMYR,sum(t.LSGD)as LSGD
             
      from (
          select ASSET_TYPE,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(usd) else 0 end as AUSD,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(eur) else 0 end as AEUR,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(thb) else 0 end as ATHB,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(jpy) else 0 end as AJPY,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(inr) else 0 end as AINR,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(myr) else 0 end as AMYR,
                 case ASSET_TYPE when 'MONETARY ASSET' then sum(sgd) else 0 end as ASGD,
                  case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(usd) else 0 end as LUSD,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(eur) else 0 end as LEUR,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(thb) else 0 end as LTHB,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(jpy) else 0 end as LJPY,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(inr) else 0 end as LINR,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(myr) else 0 end as LMYR,
                 case ASSET_TYPE when 'MONETARY LIABILITIES' then sum(sgd) else 0 end as LSGD
                
          
          from CUSTOM.CUST_FOREIGN_EXCHANGE_TMP
          group by ASSET_TYPE
          )t
)q;
    end;
      Vi_Id := 0;
   
-----------------------------------------------------------------------------------
 -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------
    out_rec:=	(
          ASSETLIABILITIES    || '|' ||
					TitleName	          || '|' ||
          SubTitleName        || '|' ||
          USD                 || '|' ||
					EUR      			      || '|' ||
          THB   			        || '|' ||
          JPY    			        || '|' ||
          INR    			        || '|' ||
          MYR                 || '|' ||
          SGD                 || '|' ||
          RowNumber           || '|' ||
          vi_USDRate          || '|' ||
          vi_EURRate          || '|' ||
          vi_SGDRate          || '|' ||
          vi_INRRate          || '|' ||
          vi_THBRate          || '|' ||
          vi_MYRRate          || '|' ||
          Vi_Jpyrate          || '|' ||
          TotalUSD               || '|' ||
          TotalEUR               || '|' ||
          TotalTHB               || '|' ||
          TotalJPY               || '|' ||
          TotalINR               || '|' ||
          Totalmyr               || '|' ||
          Totalsgd               || '|' ||
          Tic_Abc               || '|' ||
          TIC_amt
				 );
  
			dbms_output.put_line(out_rec);
        
  END FIN_FOREIGN_EXCHANGE_POSIT_FCY;

END FIN_FOREIGN_EXCHANGE_POSIT_FCY;
/
