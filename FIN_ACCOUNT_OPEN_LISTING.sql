CREATE OR REPLACE PACKAGE                             FIN_ACCOUNT_OPEN_LISTING AS 

   PROCEDURE FIN_ACCOUNT_OPEN_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_ACCOUNT_OPEN_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                      FIN_ACCOUNT_OPEN_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_currency	   	Varchar2(3);               -- Input to procedure
	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_branchCode		Varchar2(5);		    	    -- Input to procedure
  vi_SchemeType		Varchar2(5);		    	    -- Input to procedure
  vi_SchemCode		Varchar2(10);		    	    -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, 
      ci_SchemeType VARCHAR2,ci_SchemeCode VARCHAR2 ,ci_currency VARCHAR2)
  IS
   Select q.AccountNumber as AccountNumber,
        q.AcountName As AcountName,
        Nvl(Accounts.Uniqueid,'-') As Nrcnumber,
         nvl(Address.Address_Line1 || Address.Address_Line2 || Address.Address_Line3 ||','|| Address.City ||','|| Address.State ||','|| Address.Country,'-') As Address,
         Q.Opendate ,
          NVL(( SELECT Pe.Phoneno FROM Crmuser.Phoneemail PE 
            WHERE Pe.Phoneoremail  = 'PHONE'
           and Pe.Preferredflag = 'Y'
           AND  PE.ORGKEY = Q.Cif_Id),'-') As Phonenumber, 
         --Nvl(Pe.Phoneno,'-') As Phonenumber, 
         nvl(Address.Faxnolocalcode|| Address.Faxnocountrycode||Address.Faxnocitycode||Address.Faxno,'-') As Faxnumber,
         Q.Currency,
         q.opening_amount
         
  From (Select 
          Gam.Foracid As Accountnumber,
          Gam.Acct_Name As Acountname,
          gam.acct_opn_date as OpenDate,
          Gam.Acct_Crncy_Code As Currency,
          Gam.Cif_Id   As Cif_Id,
           nvl((SELECT tran_amt
          FROM Custom.Custom_Ctd_Dtd_Acli_View Ctd
          WHERE Ctd.Del_Flg                         = 'N'
          AND Ctd.Bank_Id                           = '01'
          AND Ctd.Acid                              = gam.acid
          AND (Ctd.Tran_Date,Ctd.Tran_Id,Ctd.Acid) IN
                                                  (SELECT ctd.tran_date,MIN(tran_id),ctd.acid
                                                   From Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                   Where  Ctd.Del_Flg               = 'N' -- and    ctd.tran_date >=
                                                   AND Ctd.Bank_Id               = '01'
                                                   And Ctd.Acid                  = Gam.Acid
                                                   AND (Ctd.Tran_Date,Ctd.Acid) IN
                                                                (SELECT MIN(ctd.tran_date),ctd.acid
                                                                FROM Custom.Custom_Ctd_Dtd_Acli_View Ctd
                                                                WHERE 
                                                                Ctd.Del_Flg             = 'N'
                                                                AND Ctd.Acid            = gam.acid
                                                                AND ctd.tran_date      >= gam.ACCT_OPN_DATE
                                                                AND Ctd.Bank_Id         = '01'
                                                                GROUP BY Acid
                                                               )
                                                  GROUP BY ctd.tran_date,
                                                    ctd.acid
                                                  )
                                                   and rownum =1
        ),0) as opening_amount
    

from 
  tbaadm.general_acct_mast_table gam
where 
  gam.schm_type=UPPER(ci_SchemeType)
  and gam.schm_code = upper(ci_SchemeCode)
  and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg = 'N'
  and gam.bank_id ='01'
  and gam.acct_crncy_code = UPPER(ci_currency)
  and gam.SOL_ID  = ci_branchCode
)Q
Left Join  Crmuser.Accounts Accounts On Accounts.Orgkey = Q.Cif_Id
--Left Join  Crmuser.Phoneemail Pe On Q.Cif_Id = Pe.Orgkey
Left Join    Crmuser.Address Address On Q.Cif_Id  = Address.Orgkey
Where  -- Pe.Phoneoremail  = 'PHONE'
--And Pe.Preferredflag = 'Y'
 (Address.Addresscategory = 'Mailing' Or Address.Addresscategory = 'Registered')
and    (address.ADDRESSID,q.AccountNumber) in (  select min(address.ADDRESSID),gam.foracid
                                             from CRMUSER.address address,tbaadm.gam gam
                                             where gam.cif_id = address.ORGKEY
                                              And Gam.Del_Flg = 'N'
                                              --and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'
                                              and  gam.SOL_ID  = ci_branchCode
                                              and gam.schm_type=UPPER(ci_SchemeType)
                                              and gam.schm_code = upper(ci_SchemeCode)  
                                              and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
                                              And Gam.Acct_Opn_Date Between To_Date( Cast (ci_startDate As Varchar(10) ) , 'dd-MM-yyyy' ) 
                                              And To_Date( Cast ( ci_endDate As Varchar(10) ) , 'dd-MM-yyyy' )
                                              Group By Gam.Foracid)
  Order By Q.Opendate,Q.Accountnumber                                      
      ;
 /* select *
  from (select 
  gam.foracid as "AccountNumber",
  gam.acct_name as "AcountName",
  accounts.uniqueid as "NRC Number",
  address.address_line1 || 
  address.address_line2 || 
  address.address_line3 ||','|| 
  address.city ||','||
  address.state ||','||
  address.country as "Address",
  gam.acct_opn_date as "OpenDate",
  (select phoneno from crmuser.phoneemail pe where gam.cif_id = pe.orgkey and pe.PHONEOREMAIL  = 'PHONE'
  and PE.PREFERREDFLAG = 'Y')  as "PhoneNumber",
  address.faxnolocalcode||
  address.faxnocountrycode||
  address.faxnocitycode||
  address.faxno as "FaxNumber",
  gam.acct_crncy_code as "Currency",
  detail.tran_amt as "Open Amount"

from 
  tbaadm.general_acct_mast_table gam,
  CRMUSER.address address,
  CRMUSER.accounts accounts,
  custom.CUSTOM_CTD_DTD_ACLI_VIEW detail
where 
  gam.schm_type=UPPER(ci_SchemeType)
  and gam.schm_code = upper(ci_SchemeCode)
  and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg = 'N'
  --and gam.acct_cls_flg = 'N'
  and gam.bank_id ='01'
  and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
  --AND PE.PREFERREDFLAG = 'Y'
  and gam.acct_crncy_code = UPPER(ci_currency)
  and gam.SOL_ID  = ci_branchCode
   and detail.tran_date= gam.acct_opn_date
  and (detail.tran_particular_code in ('CHD','TRD') or detail.tran_particular_code is null)
  and gam.cif_id     = address.orgkey
  and gam.CIF_ID = accounts.ORGKEY
  and detail.acid         = gam.acid
   and (address.ADDRESSID,gam.foracid) in (  select min(address.ADDRESSID),gam.foracid
                                             from CRMUSER.address address,tbaadm.gam gam
                                             where gam.cif_id = address.ORGKEY
                                              and gam.del_flg = 'N'
                                              and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'
                                              and  gam.SOL_ID  = ci_branchCode
                                              and gam.schm_type=UPPER(ci_SchemeType)
                                              and gam.schm_code = upper(ci_SchemeCode)  
                                              and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
                                              and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                              and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                              group by gam.foracid)
  and (detail.tran_id, detail.tran_date) in ( select
                                                   min( detail.tran_id),detail.tran_date
                                              from 
                                              tbaadm.general_acct_mast_table gam,
                                              custom.CUSTOM_CTD_DTD_ACLI_VIEW detail
                                              where 
                                              gam.schm_type=UPPER(ci_SchemeType)
                                              and gam.schm_code = upper(ci_SchemeCode)
                                              and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                              and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                              and gam.del_flg = 'N'
                                              and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'
                                              --AND PE.PREFERREDFLAG = 'Y'
                                              and gam.acct_crncy_code = UPPER(ci_currency)
                                              and gam.SOL_ID  = ci_branchCode
                                               and detail.tran_date= gam.acct_opn_date
                                              and (detail.tran_particular_code in ('CHD','TRD') or detail.tran_particular_code is null)
                                              and detail.acid         = gam.acid
                                               group by tran_date,foracid)

 union all
   
   select 
  gam.foracid as "AccountNumber",
  gam.acct_name as "AcountName",
  accounts.uniqueid as "NRC Number",
  address.address_line1 || 
  address.address_line2 || 
  address.address_line3 ||','|| 
  address.city ||','||
  address.state ||','||
  address.country as "Address",
  gam.acct_opn_date as "OpenDate",
  (select phoneno from crmuser.phoneemail pe where gam.cif_id = pe.orgkey and pe.PHONEOREMAIL  = 'PHONE'
  and PE.PREFERREDFLAG = 'Y')  as "PhoneNumber",
  address.faxnolocalcode ||
  address.faxnocountrycode ||
  address.faxnocitycode ||
  address.faxno as "FaxNumber",
  gam.acct_crncy_code as "Currency"
  ,gam.clr_bal_amt
 

from 
  tbaadm.general_acct_mast_table gam,
  CRMUSER.address address,
  CRMUSER.accounts accounts

where 
  gam.schm_type=UPPER(ci_SchemeType)
  and gam.schm_code = upper(ci_SchemeCode)
  and gam.acct_opn_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
  and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  and gam.del_flg = 'N'
  and gam.acct_cls_flg = 'N'
  and gam.bank_id ='01'
  and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
  and gam.acct_crncy_code = UPPER(ci_currency)
  and gam.SOL_ID  = ci_branchCode
  and gam.clr_bal_amt  = 0
  and gam.cif_id     = address.orgkey
  and gam.CIF_ID = accounts.ORGKEY
     and (address.ADDRESSID,gam.foracid) in (  select min(address.ADDRESSID),gam.foracid
                                             from CRMUSER.address address,tbaadm.gam gam
                                             where gam.cif_id = address.ORGKEY
                                              and gam.del_flg = 'N'
                                              and gam.acct_cls_flg = 'N'
                                              and gam.bank_id ='01'
                                              and  gam.SOL_ID  = ci_branchCode
                                              and gam.schm_type=UPPER(ci_SchemeType)
                                              and gam.schm_code = upper(ci_SchemeCode)  
                                              and (address.addresscategory = 'Mailing' or address.addresscategory = 'Registered')
                                              and gam.acct_opn_date between TO_DATE( CAST (ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                                              and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                              group by gam.foracid)
)Q
where q."Open Amount" <> 0
  order by 
  q."OpenDate" ASC,q."AccountNumber" asc  ;*/
  
  /*select stu_reg_no, unit_code, exam_unit, exam_semester, student_year,  
(select sum(per_centage_score) from student_results_master t2 where t2.exam_unit = t1.exam_unit)
/(select count(per_centage_score) from student_results_master t2 where t2.exam_unit = t1.exam_unit)
from student_results_master t1
group by unit_code, exam_unit, stu_reg_no,  exam_semester, student_year;*/
  
  PROCEDURE FIN_ACCOUNT_OPEN_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
 
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_NRC_Number CRMUSER.accounts.uniqueid%type;
    v_Address varchar2(100);
    v_OpenDate tbaadm.general_acct_mast_table.acct_opn_date%type;
     v_PhoneNumber varchar2(50);
    v_FaxNumber varchar2(20);
    v_Currency tbaadm.general_acct_mast_table.acct_crncy_code%type;
    v_OpenAmount custom.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
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
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);	
     vi_currency   :=  outArr(2);
    vi_SchemeType	:=  outArr(3);
    vi_SchemCode  :=  outArr(4);
     vi_branchCode :=  outArr(5);	
   
 --------------------------------------------------------------------------------------------------------------
 
  if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_SchemeType is null or vi_SchemCode is null or
         vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
         out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
            '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-'|| '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
 ------------------------------------------------------------------------------------------------------------------
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode , 
      vi_SchemeType ,vi_SchemCode,vi_currency);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_AccountNumber,v_AccountName,v_NRC_Number,
            v_Address,v_OpenDate,v_PhoneNumber,v_FaxNumber,v_Currency,v_OpenAmount;
      

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
-------------------------------------------------------------------------------
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into  v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
    END;
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          trim(v_AccountNumber)     			|| '|' ||
					v_AccountName	            || '|' ||
          v_NRC_Number              || '|' ||
					v_Address      			      || '|' ||
          trim(to_char(to_date(v_OpenDate,'dd/Mon/yy'), 'dd/MM/yyyy')  )    			|| '|' ||
          v_PhoneNumber    			    || '|' ||
          v_FaxNumber    			      || '|' ||
          v_Currency                || '|' ||
          v_OpenAmount              || '|' ||
					v_BranchName	            || '|' ||
					v_BankAddress      			  || '|' ||
					v_BankPhone               || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_ACCOUNT_OPEN_LISTING;

END FIN_ACCOUNT_OPEN_LISTING;
/
