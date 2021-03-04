CREATE OR REPLACE PACKAGE                             FIN_ACCRUAL_CUST_LIST_FOR_BR AS

  PROCEDURE FIN_ACCRUAL_CUST_LIST_FOR_BR(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ACCRUAL_CUST_LIST_FOR_BR;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                 FIN_ACCRUAL_CUST_LIST_FOR_BR AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);              -- Input to procedure
	vi_InterestDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(3);		    	    -- Input to procedure
  vi_SchemeCode   Varchar2(6);              -- Input to procedure
  vi_branchCode   vARCHAR2(10);
  
 
    
    
     CURSOR ExtractDataSBA (	
			 ci_InterestDate VARCHAR2,
      ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,ci_currency VARCHAR2, ci_branchCode VARCHAR2)
  Is
    Select *
    FROM  (SELECT
         tO_DATE( ci_InterestDate,'dd-MM-yyyy') as TranDate,
          GAM.FORACID as "Account_ID" ,
          GAM.ACCT_NAME as "Account_Name" , 
           NVL((SELECT tRAN_DATE_bAL FROM TBAADM.EAB EAB
           WHERE EAB.EOD_DATE <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
           AND   EAB.END_EOD_DATE >= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
           And   Acid =Gam.Acid ),0) As Aa,     
          --round((idt.INTEREST_AMOUNT/((idt.end_date - idt.start_date)+1)),8) AS AccuredCR ,  
          case when gam.schm_code =  'SAREG'  then idt.INTEREST_AMOUNT else Round((Idt.Interest_Amount/((Idt.End_Date - Idt.Start_Date)+1)),8) end As Accuredcr ,
          SERVICE_OUTLET_TABLE.SOL_ID,
          BRANCH_CODE_TABLE.BR_NAME as "BranchName",
          (select NRML_INT_PCNT AS A from tbaadm.ivs 
          where INT_TBL_CODE=idt.int_table_code
          AND  ROWNUM = 1
          AND (INT_TBL_VER_NUM,int_slab_srl_num) IN (SELECT MAX(INT_TBL_VER_NUM),max(int_slab_srl_num) FROM TBAADM.IVS WHERE INT_TBL_CODE=idt.int_table_code) 
          ) AS InterestRate,
          '-' as opacid,
           gam.acct_opn_date
        
      FROM
         TBAADM.GAM GAM,
         tbaadm.idt idt,
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         idt.start_date <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         and idt.end_date >= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         and idt.entity_id = gam.acid
         and GAM.SCHM_TYPE LIKE '%' ||UPPER(ci_SchemeType) || '%' --39725
         and GAM.SOL_ID  LIKE '%' || ci_branchCode|| '%' --39725
         and gam.schm_code  LIKE '%' ||UPPER(ci_SchemeCode) || '%'  
         and gam.acct_crncy_code = upper(ci_currency)
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         AND SERVICE_OUTLET_TABLE.SOL_ID = GAM.SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         AND SERVICE_OUTLET_TABLE.BANK_CODE = BRANCH_CODE_TABLE.BANK_CODE
         And ( Idt.Interest_Amount > 0 )
         Order By Service_Outlet_Table.Sol_Id)T
         Where T.Aa <> 0 
         ORDER BY T.SOL_ID;
         
     CURSOR ExtractDataTDA (	ci_InterestDate VARCHAR2,
      ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,ci_currency VARCHAR2, ci_branchCode VARCHAR2)
    Is
       Select *
       FROM  (SELECT
         tO_DATE( ci_InterestDate,'dd-MM-yyyy') as TranDate,
         GAM.FORACID as "Account_ID" ,
         GAM.ACCT_NAME as "Account_Name" , 
          NVL((SELECT tRAN_DATE_bAL FROM TBAADM.EAB EAB
           WHERE EAB.EOD_DATE <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
           And   Eab.End_Eod_Date >= To_Date(Ci_Interestdate,'dd-MM-yyyy')
           and  eab.tran_date_bal <> 0
           AND   ACID =GAM.ACID ),0) AS AA,  
         round((idt.INTEREST_AMOUNT/((idt.end_date - idt.start_date)+1)),8) AS AccuredCR ,  
         --idt.INTEREST_AMOUNT,
         SERVICE_OUTLET_TABLE.SOL_ID,
         BRANCH_CODE_TABLE.BR_NAME as "BranchName",
        (select NRML_INT_PCNT from tbaadm.tvs where MAX_CONTRACTED_MTHS = tam.DEPOSIT_PERIOD_MTHS 
        and INT_TBL_VER_NUM in (select max(INT_TBL_VER_NUM) from tbaadm.tvs where MAX_CONTRACTED_MTHS = tam.DEPOSIT_PERIOD_MTHS)) AS InterestRate,
        '-' as opacid,
         gam.acct_opn_date
        
      FROM
         TBAADM.IDT IDT , 
         TBAADM.GAM GAM ,
         tbaadm.tam tam,
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         IDT.ENTITY_ID = GAM.ACID 
         and tam.acid = gam.acid
         AND idt.START_DATE <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         and idt.end_date >= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         AND GAM.SCHM_TYPE LIKE '%' ||UPPER(ci_SchemeType) || '%' 
         and GAM.SOL_ID  LIKE '%' || ci_branchCode || '%' --39725
         and gam.schm_code  LIKE '%' ||UPPER(ci_SchemeCode) || '%'
         and gam.acct_crncy_code = upper(ci_currency)
         and GAM.DEL_FLG = 'N' 
         --and GAM.ACCT_CLS_FLG = 'N' 
         and GAM.Bank_id = '01'
         and ( idt.INTEREST_AMOUNT > 0 )
         AND SERVICE_OUTLET_TABLE.SOL_ID = GAM.SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         And Service_Outlet_Table.Bank_Code = Branch_Code_Table.Bank_Code
         Order By Service_Outlet_Table.Sol_Id)T
         Where T.Aa <> 0
         ORDER BY T.Sol_Id;
         
      CURSOR ExtractDataLAA (	
		ci_InterestDate VARCHAR2,
      ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2,ci_currency VARCHAR2, ci_branchCode VARCHAR2)
    Is
    Select 
        T.Aa,
        T."Account_ID",
        T."Account_Name",
        T.Bb,
        sum(T.Accuredcr),
        T.Sol_Id,
        T."BranchName",
        T.Interest_Rate,
        T.Opacid,
        t.acct_opn_date
    from (
          Select
          tO_DATE( ci_InterestDate,'dd-MM-yyyy') as aa,
          GAM.FORACID as "Account_ID" ,
          GAM.ACCT_NAME as "Account_Name" , 
           NVL((SELECT tRAN_DATE_bAL FROM TBAADM.EAB EAB
           WHERE EAB.EOD_DATE <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
           AND   EAB.END_EOD_DATE >= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
           AND   ACID =GAM.ACID ),0) AS bb,   
         round((idt.INTEREST_AMOUNT/((idt.end_date - idt.start_date)+1)),8) AS AccuredCR , 
         --IDT.INTEREST_AMOUNT,
         --IDT.END_DATE - IDT.START_DATE +1,
         SERVICE_OUTLET_TABLE.SOL_ID,        
         BRANCH_CODE_TABLE.BR_NAME as "BranchName",
         eit.interest_rate,
         (select op_acid from tbaadm.lam where acid = gam.acid) as opacid,
          gam.acct_opn_date
      
      FROM
         TBAADM.EIT EIT , 
         TBAADM.GAM GAM ,
         TBAADM.IDT IDT,
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         EIT.ENTITY_ID = GAM.ACID 
         AND IDT.ENTITY_ID = GAM.ACID
         AND idt.START_DATE <= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         and idt.end_date >= tO_DATE( ci_InterestDate,'dd-MM-yyyy')
         and GAM.SCHM_TYPE   LIKE '%' ||UPPER(ci_SchemeType) || '%' 
         and GAM.SOL_ID     LIKE '%' || ci_branchCode || '%' --39725
         and gam.schm_code  LIKE '%' ||UPPER(ci_SchemeCode) || '%'
         and gam.acct_crncy_code = upper(ci_currency)
         and GAM.DEL_FLG = 'N' 
         and GAM.ACCT_CLS_FLG = 'N' 
         and ( idt.INTEREST_AMOUNT > 0 )
         and GAM.Bank_id = '01'
         AND SERVICE_OUTLET_TABLE.SOL_ID = GAM.SOL_ID
         and SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         And Service_Outlet_Table.Bank_Code = Branch_Code_Table.Bank_Code
         Order By  Eit.Accrued_Upto_Date_Dr,Service_Outlet_Table.Sol_Id)T
         WHERE  T.BB <> 0
        group by T.Aa,
        T."Account_ID",
        T."Account_Name",
        T.Bb,
        T.Sol_Id,
        T."BranchName",
        T.Interest_Rate,
        T.Opacid,
        T.Acct_Opn_Date
        order by T.Acct_Opn_Date,T.Sol_Id
         ;
  
  PROCEDURE FIN_ACCRUAL_CUST_LIST_FOR_BR(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
      v_AccountID   TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
      v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
      v_valueDateBal TBAADM.EAB.VALUE_DATE_BAL%type;
      v_tranAmount CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE;
      v_tranDate CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.TRAN_DATE%TYPE;
      v_branchName TBAADM.BRANCH_CODE_TABLE.BR_NAME%type;
      v_solId TBAADM.SERVICE_OUTLET_TABLE.SOL_ID%type;
      v_subTitle varchar2(200);
      v_interestRate tbaadm.eit.interest_rate%type;
       opacid         TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;  
       v_OpenDate varchar2(30);
      
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
    
    vi_InterestDate  :=outArr(0);		
    --vi_endDate    :=outArr(1);		
    vi_SchemeType	:=outArr(1);
    vi_SchemeCode :=outArr(2);
    vi_currency   :=outArr(3);
    vi_branchCode :=outArr(4);
    
    
     
  IF vi_branchCode IS  NULL or vi_branchCode = ''  THEN
  vi_branchCode := '';
  END IF;
   
  IF vi_SchemeCode IS  NULL or vi_SchemeCode = ''  THEN
  vi_SchemeCode := '';
  END IF;
    
    IF UPPER(vi_SchemeType) = 'SBA' or UPPER(vi_SchemeType)='TDA'  THEN
     --{
     v_subTitle := 'ACCRUAL PAYABLE FOR BRANCH';
       IF UPPER(vi_SchemeType) = 'SBA' THEN
       --{
          IF NOT ExtractDataSBA%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataSBA (	vi_InterestDate,
            --vi_startDate , vi_endDate  , 
            vi_SchemeType, vi_SchemeCode ,vi_currency,vi_branchCode);
            --}
            END;
      
          --}
          END IF;
         
          IF ExtractDataSBA%ISOPEN THEN
          --{
            FETCH	ExtractDataSBA
            INTO	v_tranDate, v_AccountID,
                  v_AccountName ,v_valueDateBal, v_tranAmount, v_solId, v_branchName,v_interestRate,opacid,v_OpenDate;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataSBA%NOTFOUND THEN
            --{
              CLOSE ExtractDataSBA;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
        --}
        ELSE
            IF NOT ExtractDataTDA%ISOPEN THEN
          --{
            BEGIN
            --{
            dbms_output.put_line(vi_SchemeType);
              OPEN ExtractDataTDA (	vi_InterestDate,
           -- vi_startDate , vi_endDate  , 
            vi_SchemeType, vi_SchemeCode ,vi_currency,vi_branchCode);
            --}
            END;
      
          --}
          END IF;
         
          IF ExtractDataTDA%ISOPEN THEN
          --{
            FETCH	ExtractDataTDA
            INTO	v_tranDate, v_AccountID,
                  v_AccountName ,v_valueDateBal, v_tranAmount, v_solId, v_branchName,v_interestRate,opacid,v_OpenDate;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataTDA%NOTFOUND THEN
            --{
              CLOSE ExtractDataTDA;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
          END IF;
                
      -----------FOR Receivable ----------
   ELSE
   v_subTitle := 'ACCRUAL RECEIVABLE FOR BRANCH';
          IF NOT ExtractDataLAA%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataLAA (		vi_InterestDate,
           -- vi_startDate , vi_endDate  , 
            vi_SchemeType , vi_SchemeCode,vi_currency,vi_branchCode);
            --}
            END;
      
          --}
          END IF;
          
          IF ExtractDataLAA%ISOPEN THEN
          --{
            FETCH	ExtractDataLAA
            INTO	v_tranDate, v_AccountID,
                  v_AccountName ,v_valueDateBal, v_tranAmount, v_solId, v_branchName,v_interestRate,opacid,v_OpenDate;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataLAA%NOTFOUND THEN
            --{
              CLOSE ExtractDataLAA;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
    --}  
  END IF;  
    out_rec:=	(
					v_tranDate          || '|' ||  
					v_AccountID      	  || '|' ||
          v_AccountName       || '|' ||
          v_valueDateBal      || '|' ||
					v_tranAmount	      || '|' ||
          v_solId	            || '|' ||
          v_branchName	      || '|' ||
					v_subTitle          || '|' ||
          v_interestRate      || '|' ||
          opacid              || '|' ||
          v_OpenDate);
  
			dbms_output.put_line(out_rec);
  END FIN_ACCRUAL_CUST_LIST_FOR_BR;

END FIN_ACCRUAL_CUST_LIST_FOR_BR;
/
