CREATE OR REPLACE PACKAGE                             FIN_DAILY_DRAWING_REMMITTANCE AS 

  PROCEDURE FIN_DAILY_DRAWING_REMMITTANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DAILY_DRAWING_REMMITTANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                        FIN_DAILY_DRAWING_REMMITTANCE AS


-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

  vi_StartDate  Varchar2(20);		    	            -- Input to procedure
  	vi_EndDate	Varchar2(20);		    	            -- Input to procedure
  vi_BranchCode  Varchar2(20);		    	            -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------
    CURSOR ExtractData (	 ci_StartDate  Varchar2,ci_EndDate		Varchar2,ci_BranchCode  Varchar2) IS
     
     SELECT 
            q.ReportCode,
           -- q.BankCode,
            bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name,
            -- q.EventId,
            q.tran_amt,
            q.nrc,
            q.FName,
            q.address,
            q.FaxNo,      
            q.tran_id,
            sum(q.Commisson + q.Commisson1),
           -- sum(q.Commisson1),
            sum(q.Fax)
           
          
           
     FROM  (SELECT 
            CTH_DTH_VIEW.TRAN_ID as tran_id,  
            CTD_DTD_ACLI_VIEW.RPT_CODE as ReportCode,
            CTD_DTD_ACLI_VIEW.TRAN_AMT as tran_amt, 
            CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as nrc, 
            CTD_DTD_ACLI_VIEW.TRAN_RMKS as FName, 
            CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as address ,  
            CTH_DTH_VIEW.REMARKS AS FaxNo ,
            case  when  CXL.CHRG_RPT_CODE  = 'COMCH'  then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson,
            case  when  CXL.CHRG_RPT_CODE is null then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson1,
            Case  When  Cxl.Chrg_Rpt_Code  = 'TXLCG'  Then Cxl.Actual_Amt_Coll  Else 0 End As Fax,
           Case  When  Ctd_Dtd_Acli_View.Bank_Code is null Then (Select
                                                                  bank.BANK_code
                                                              From
                                                                  CUSTOM.CCHRG_TBL CCHRG_TBL,TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE,tbaadm.BANK_CODE_TABLE bank
                                                              where 
                                                                  CCHRG_TBL.chrgevt = (select distinct event_id from tbaadm.cxl 
                                                                  Where Chrg_Tran_Date = To_Date( Cast ( CTD_DTD_ACLI_VIEW.TRAN_DATE As Varchar(10) ) , 'dd-MM-yyyy' )
                                                                  And Chrg_Tran_Id = CTD_DTD_ACLI_VIEW.TRAN_ID)
                                                                  and bank.BANK_CODE =BRANCH_CODE_TABLE.BANK_CODE
                                                                  And Cchrg_Tbl.Bankcode = Branch_Code_Table.Bank_Code
                                                                  and CCHRG_TBL.BRANCHCODE = BRANCH_CODE_TABLE.BR_CODE)
                                                                  Else Ctd_Dtd_Acli_View.Bank_Code End As Bankcode,
            Case When Ctd_Dtd_Acli_View.Branch_Code is null Then (Select
                                                                  BRANCH_CODE_TABLE.br_code                                                           From
                                                                  CUSTOM.CCHRG_TBL CCHRG_TBL,TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE,tbaadm.BANK_CODE_TABLE bank
                                                              where 
                                                                  CCHRG_TBL.chrgevt = (select distinct event_id from tbaadm.cxl 
                                                                  Where Chrg_Tran_Date = To_Date( Cast ( CTD_DTD_ACLI_VIEW.TRAN_DATE As Varchar(10) ) , 'dd-MM-yyyy' )
                                                                  And Chrg_Tran_Id = CTD_DTD_ACLI_VIEW.TRAN_ID)
                                                                  and bank.BANK_CODE =BRANCH_CODE_TABLE.BANK_CODE
                                                                  And Cchrg_Tbl.Bankcode = Branch_Code_Table.Bank_Code
                                                                  and CCHRG_TBL.BRANCHCODE = BRANCH_CODE_TABLE.BR_CODE) else CTD_DTD_ACLI_VIEW.BRANCH_CODE end as BranchCode
           -- CTD_DTD_ACLI_VIEW.BANK_CODE  as BankCode,
            --CTD_DTD_ACLI_VIEW.BRANCH_CODE as BranchCode
             FROM 
                  custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
                   custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW,
                   TBAADM.CXL CXL
                 
             WHERE 
                 -- CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST (  ci_TranDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  CTD_DTD_ACLI_VIEW.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                   AND CTD_DTD_ACLI_VIEW.TRAN_DATE  <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' )
                    AND CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID           = ci_BranchCode
                  AND trim(CTH_DTH_VIEW.TRAN_ID) = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                  AND trim(CXL.CHRG_TRAN_ID)  = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                  AND CXL.CHRG_TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
                  and ctd_dtd_acli_view.tran_sub_type in ('RI','CI')
                  --and ctd_dtd_acli_view.part_tran_type  = 'C'
                  AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N'
                  and CTD_DTD_ACLI_VIEW.TRAN_DATE = CTH_DTH_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.BANK_ID = '01'
                  and CTD_DTD_ACLI_VIEW.uad_module_key is not null
                  and CTD_DTD_ACLI_VIEW.uad_module_id is not null
                  and  CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIT','IBREM','REMIB')
                  and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                  and cont_tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
                 
           Union all
           
             SELECT 
                    CTH_DTH_VIEW.TRAN_ID as tran_id,  
                    CTD_DTD_ACLI_VIEW.RPT_CODE as ReportCode,
                    CTD_DTD_ACLI_VIEW.TRAN_AMT as tran_amt, 
                    CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as nrc, 
                    CTD_DTD_ACLI_VIEW.TRAN_RMKS as FName, 
                    CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as address ,  
                    CTH_DTH_VIEW.REMARKS AS FaxNo ,
                   0,
                   0,-- case  when  CXL.CHRG_RPT_CODE  = 'COMCH'  then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson,
                    0,--case  when  CXL.CHRG_RPT_CODE  = 'TXLCG'  then CXL.ACTUAL_AMT_COLL  else 0 end as Fax,
                    CTD_DTD_ACLI_VIEW.BANK_CODE  as BankCode,
                    CTD_DTD_ACLI_VIEW.BRANCH_CODE as BranchCode
             FROM 
                  custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
                   custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW--,
                  -- TBAADM.CXL CXL
                 
             WHERE 
                 -- CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST (  ci_TranDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  CTD_DTD_ACLI_VIEW.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                   AND CTD_DTD_ACLI_VIEW.TRAN_DATE  <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' )
                    AND CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID           = ci_BranchCode
                  AND trim(CTH_DTH_VIEW.TRAN_ID) = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                 -- AND trim(CXL.CHRG_TRAN_ID)  = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                 -- AND CXL.CHRG_TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
                  and ctd_dtd_acli_view.tran_sub_type in ('RI','CI')
                  --and ctd_dtd_acli_view.part_tran_type  = 'C'
                  AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N'
                 -- and  CTD_DTD_ACLI_VIEW.tran_id like '%AG7938'
                  and CTD_DTD_ACLI_VIEW.TRAN_DATE = CTH_DTH_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.BANK_ID = '01'
                  and  CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIT','REMIB')
                  and CTD_DTD_ACLI_VIEW.uad_module_key is not null
                  and CTD_DTD_ACLI_VIEW.uad_module_id is not null
                  and (CTD_DTD_ACLI_VIEW.TRAN_ID,CTD_DTD_ACLI_VIEW.TRAN_DATE) NOT IN (SELECT CHRG_TRAN_ID,CHRG_TRAN_DATE FROM TBAADM.CXL 
                                                                                    WHERE
                                                                                    SERVICE_SOL_ID = ci_BranchCode
                                                                                    AND CHRG_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                    AND CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                    )
                  and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date)not IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date >= TO_DATE( CAST (ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                  and cont_tran_date <= TO_DATE( CAST ( ci_EndDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' ))                                 
                                                  
                                              )q,
                   TBAADM.BRANCH_CODE_TABLE bct ,tbaadm.BANK_CODE_TABLE bank
                   
      WHERE bct.BANK_CODE  = q.BankCode
      AND  bct.BR_CODE   = q.BranchCode
      AND bank.BANK_CODE = q.BankCode
      AND bank.DEL_FLG = 'N'
      AND bank.BANK_ID = '01'
      group by 
           
            q.ReportCode,
           -- q.BankCode,
            bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name,
            q.tran_amt,
            q.nrc,
            q.FName,
            q.address,
            q.FaxNo,      
            q.tran_id 
        order by bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name, bct.br_name;
--------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataIBD (	 ci_StartDate  Varchar2,ci_EndDate		Varchar2,ci_BranchCode  Varchar2) IS
SELECT 
            q.ReportCode,
           -- q.BankCode,
            bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name,
            -- q.EventId,
            q.tran_amt,
            q.nrc,
            q.FName,
            q.address,
            q.FaxNo,      
            q.tran_id,
            sum(q.Commisson + q.Commisson1),
           -- sum(q.Commisson1),
            sum(q.Fax)
           
          
           
     FROM  (SELECT 
            CTH_DTH_VIEW.TRAN_ID as tran_id,  
            CTD_DTD_ACLI_VIEW.RPT_CODE as ReportCode,
            CTD_DTD_ACLI_VIEW.TRAN_AMT as tran_amt, 
            CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as nrc, 
            CTD_DTD_ACLI_VIEW.TRAN_RMKS as FName, 
            CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as address ,  
            CTH_DTH_VIEW.REMARKS AS FaxNo ,
            case  when  CXL.CHRG_RPT_CODE  = 'COMCH' then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson,
            case  when  CXL.CHRG_RPT_CODE is null then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson1,
            Case  When  Cxl.Chrg_Rpt_Code  = 'TXLCG'  Then Cxl.Actual_Amt_Coll  Else 0 End As Fax,
           Case  When  Ctd_Dtd_Acli_View.Bank_Code is null Then (Select
                                                                  bank.BANK_code
                                                              From
                                                                  CUSTOM.CCHRG_TBL CCHRG_TBL,TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE,tbaadm.BANK_CODE_TABLE bank
                                                              where 
                                                                  CCHRG_TBL.chrgevt = (select distinct event_id from tbaadm.cxl 
                                                                  Where Chrg_Tran_Date = To_Date( Cast ( CTD_DTD_ACLI_VIEW.TRAN_DATE As Varchar(10) ) , 'dd-MM-yyyy' )
                                                                  And Chrg_Tran_Id = CTD_DTD_ACLI_VIEW.TRAN_ID)
                                                                  and bank.BANK_CODE =BRANCH_CODE_TABLE.BANK_CODE
                                                                  And Cchrg_Tbl.Bankcode = Branch_Code_Table.Bank_Code
                                                                  and CCHRG_TBL.BRANCHCODE = BRANCH_CODE_TABLE.BR_CODE)
                                                                  Else Ctd_Dtd_Acli_View.Bank_Code End As Bankcode,
            Case When Ctd_Dtd_Acli_View.Branch_Code is null Then (Select
                                                                  BRANCH_CODE_TABLE.br_code                                                           From
                                                                  CUSTOM.CCHRG_TBL CCHRG_TBL,TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE,tbaadm.BANK_CODE_TABLE bank
                                                              where 
                                                                  CCHRG_TBL.chrgevt = (select distinct event_id from tbaadm.cxl 
                                                                  Where Chrg_Tran_Date = To_Date( Cast ( CTD_DTD_ACLI_VIEW.TRAN_DATE As Varchar(10) ) , 'dd-MM-yyyy' )
                                                                  And Chrg_Tran_Id = CTD_DTD_ACLI_VIEW.TRAN_ID)
                                                                  and bank.BANK_CODE =BRANCH_CODE_TABLE.BANK_CODE
                                                                  And Cchrg_Tbl.Bankcode = Branch_Code_Table.Bank_Code
                                                                  and CCHRG_TBL.BRANCHCODE = BRANCH_CODE_TABLE.BR_CODE) else CTD_DTD_ACLI_VIEW.BRANCH_CODE end as BranchCode
           -- CTD_DTD_ACLI_VIEW.BANK_CODE  as BankCode,
            --CTD_DTD_ACLI_VIEW.BRANCH_CODE as BranchCode
             FROM 
                  custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
                   custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW,
                   TBAADM.CXL CXL
                 
             WHERE 
                 -- CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST (  ci_TranDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  CTD_DTD_ACLI_VIEW.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                   AND CTD_DTD_ACLI_VIEW.TRAN_DATE  <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' )
                    AND CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID           = '20300'
                  AND trim(CTH_DTH_VIEW.TRAN_ID) = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                  AND trim(CXL.CHRG_TRAN_ID)  = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                  AND CXL.CHRG_TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
                  and ctd_dtd_acli_view.tran_sub_type in ('BI','RI')
                  --and ctd_dtd_acli_view.part_tran_type  = 'C'
                  AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N'
                  and CTD_DTD_ACLI_VIEW.TRAN_DATE = CTH_DTH_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.BANK_ID = '01'
                  and CTD_DTD_ACLI_VIEW.uad_module_key is not null
                  and CTD_DTD_ACLI_VIEW.uad_module_id is not null
                  and  CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIT','IBREM','REMIB')
                  and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date) NOT IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                  and cont_tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ))
                 
           Union all
           
             SELECT 
                    CTH_DTH_VIEW.TRAN_ID as tran_id,  
                    CTD_DTD_ACLI_VIEW.RPT_CODE as ReportCode,
                    CTD_DTD_ACLI_VIEW.TRAN_AMT as tran_amt, 
                    CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR as nrc, 
                    CTD_DTD_ACLI_VIEW.TRAN_RMKS as FName, 
                    CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2 as address ,  
                    CTH_DTH_VIEW.REMARKS AS FaxNo ,
                   0,
                   0,-- case  when  CXL.CHRG_RPT_CODE  = 'COMCH'  then CXL.ACTUAL_AMT_COLL  else 0 end as Commisson,
                    0,--case  when  CXL.CHRG_RPT_CODE  = 'TXLCG'  then CXL.ACTUAL_AMT_COLL  else 0 end as Fax,
                    CTD_DTD_ACLI_VIEW.BANK_CODE  as BankCode,
                    CTD_DTD_ACLI_VIEW.BRANCH_CODE as BranchCode
             FROM 
                  custom.CUSTOM_CTD_DTD_ACLI_VIEW CTD_DTD_ACLI_VIEW ,
                   custom.CUSTOM_CTH_DTH_VIEW CTH_DTH_VIEW--,
                  -- TBAADM.CXL CXL
                 
             WHERE 
                 -- CTD_DTD_ACLI_VIEW.TRAN_DATE = TO_DATE( CAST (  ci_TranDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  CTD_DTD_ACLI_VIEW.TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                   AND CTD_DTD_ACLI_VIEW.TRAN_DATE  <= TO_DATE( CAST ( ci_EndDate AS   VARCHAR(10) ) , 'dd-MM-yyyy' )
                    AND CTD_DTD_ACLI_VIEW.DTH_INIT_SOL_ID           = '20300'
                  AND trim(CTH_DTH_VIEW.TRAN_ID) = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                 -- AND trim(CXL.CHRG_TRAN_ID)  = trim(CTD_DTD_ACLI_VIEW.TRAN_ID)
                 -- AND CXL.CHRG_TRAN_DATE = CTD_DTD_ACLI_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.PSTD_FLG = 'Y'
                  and ctd_dtd_acli_view.tran_sub_type in ('BI','RI')
                  --and ctd_dtd_acli_view.part_tran_type  = 'C'
                  AND CTD_DTD_ACLI_VIEW.DEL_FLG = 'N'
                 -- and  CTD_DTD_ACLI_VIEW.tran_id like '%AG7938'
                  and CTD_DTD_ACLI_VIEW.TRAN_DATE = CTH_DTH_VIEW.TRAN_DATE
                  and CTD_DTD_ACLI_VIEW.BANK_ID = '01'
                  and  CTD_DTD_ACLI_VIEW.RPT_CODE in ('REMIT','REMIB')
                  and CTD_DTD_ACLI_VIEW.uad_module_key is not null
                  and CTD_DTD_ACLI_VIEW.uad_module_id is not null
                  and (CTD_DTD_ACLI_VIEW.TRAN_ID,CTD_DTD_ACLI_VIEW.TRAN_DATE) NOT IN (SELECT CHRG_TRAN_ID,CHRG_TRAN_DATE FROM TBAADM.CXL 
                                                                                    WHERE
                                                                                    SERVICE_SOL_ID = '20300'
                                                                                    AND CHRG_TRAN_DATE >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                    AND CHRG_TRAN_DATE <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                    )
                  and (trim(CTD_DTD_ACLI_VIEW.tran_id),CTD_DTD_ACLI_VIEW.tran_date)not IN 
                                                  (select trim(CONT_TRAN_ID),cont_tran_date 
                                                  from TBAADM.ATD atd 
                                                  where cont_tran_date >= TO_DATE( CAST (ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                  and cont_tran_date <= TO_DATE( CAST ( ci_EndDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' ))                                 
                                                  
                                              )q,
                   TBAADM.BRANCH_CODE_TABLE bct ,tbaadm.BANK_CODE_TABLE bank
                   
      WHERE bct.BANK_CODE  = q.BankCode
      AND  bct.BR_CODE   = q.BranchCode
      AND bank.BANK_CODE = q.BankCode
      AND bank.DEL_FLG = 'N'
      AND bank.BANK_ID = '01'
      group by 
           
            q.ReportCode,
           -- q.BankCode,
            bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name,
            q.tran_amt,
            q.nrc,
            q.FName,
            q.address,
            q.FaxNo,      
            q.tran_id 
        order by bank.BANK_NAME,
           -- q.BranchCode,
            bct.br_name, bct.br_name;
--------------------------------------------------------------------------------------------------------------------------
    PROCEDURE FIN_DAILY_DRAWING_REMMITTANCE(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2)

    IS
-------------------------------------------------------------
	--Variable declaration
------------------------------------------------------------
           
     v_tran_id tbaadm.CTH_DTH_VIEW.TRAN_ID%type; 
     v_Rpt_Code TBAADM.CTD_DTD_ACLI_VIEW.RPT_CODE%type;
     v_actualTranAmt TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
     v_nrc TBAADM.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR%type;
     v_payeeName TBAADM.CTD_DTD_ACLI_VIEW.TRAN_RMKS%type;
     v_address tbaadm.CTD_DTD_ACLI_VIEW.TRAN_PARTICULAR_2%type;
     v_faxNo custom.CUSTOM_CTH_DTH_VIEW.REMARKS%type;
     v_EventId   TBAADM.CXL.EVENT_ID%TYPE;
     v_Commission TBAADM.CXL.ACTUAL_AMT_COLL%TYPE;
     v_FaxAmount  TBAADM.CXL.ACTUAL_AMT_COLL%TYPE;
     v_BankCode custom.cchrg_tbl.BANKCODE%TYPE;
     v_BranchCode custom.cchrg_tbL.BRANCHCODE%TYPE;
     v_BrShortName  TBAADM.BRANCH_CODE_TABLE.br_name%TYPE;
     v_BankName    tbaadm.BANK_CODE_TABLE.BANK_NAME%TYPE;
      v_BranchName tbaadm.sol.sol_desc%type;
    v_BankAddress varchar(200);
     v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
     v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
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
    
  
	 vi_StartDate :=outArr(0);
   vi_EndDate :=outArr(1);
    vi_BranchCode:=outArr(2);
    
    -----------------------------------------------------------------------
    if( vi_StartDate is null or vi_EndDate is null or vi_BranchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' ||
		            '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' ||
					'-' || '|' || '-' );
				
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
----------------------------------------------------------------------------------------------------------------------------------------------
    IF vi_BranchCode = '20300' then
      IF NOT ExtractDataIBD%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataIBD (  vi_StartDate,vi_EndDate ,vi_BranchCode);	
			--}
			END;

		--}
		END IF;
  
           
    IF ExtractDataIBD%ISOPEN THEN
		--{
			FETCH	ExtractDataIBD
			INTO	 v_Rpt_Code,/*v_BankCode,*/ v_BankName, /*v_BranchCode,*/ v_BrShortName, --v_EventId,
             v_actualTranAmt,v_nrc,v_payeeName,v_address,v_faxNo,v_tran_id,v_Commission,v_FaxAmount;
      
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataIBD%NOTFOUND THEN
			--{
				CLOSE ExtractDataIBD;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
    ELSE
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (  vi_StartDate,vi_EndDate ,vi_BranchCode);	
			--}
			END;

		--}
		END IF;
  
           
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_Rpt_Code,/*v_BankCode,*/ v_BankName, /*v_BranchCode,*/ v_BrShortName, --v_EventId,
             v_actualTranAmt,v_nrc,v_payeeName,v_address,v_faxNo,v_tran_id,v_Commission,v_FaxAmount;
      
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
  END IF;
    
  
    BEGIN

      
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
    END;
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------

    out_rec:=	(
				
       
					v_Rpt_Code	              || '|' ||
					v_BankName      		|| '|' ||
          trim(v_BrShortName)           || '|' ||
          v_actualTranAmt           || '|' ||
          v_nrc          || '|' ||
          v_payeeName        || '|' ||
          v_address         || '|' ||
          v_faxNo           || '|' ||
         --
          v_Commission     || '|' ||
          v_FaxAmount      		|| '|' ||  

          --v_EventId           || '|' ||
          --v_BankCode          || '|' ||
          --v_BranchCode        || '|' ||
         -- v_BrShortName       || '|' ||
         -- v_BankName              || '|' ||   
         -- v_tran_id || '|' ||  
         v_BranchName       || '|' || 
         v_BankAddress       || '|' || 
         v_BankPhone       || '|' || 
         v_BankFax          || '|' ||
          v_tran_id       
          
        );
  
			dbms_output.put_line(out_rec);
  END FIN_DAILY_DRAWING_REMMITTANCE;

END FIN_DAILY_DRAWING_REMMITTANCE;
/
