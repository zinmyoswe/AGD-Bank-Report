CREATE OR REPLACE PACKAGE               FIN_DEALER_LISTING AS 

   PROCEDURE FIN_DEALER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DEALER_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_DEALER_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  Vi_Branchcode		Varchar2(5);		    	    -- Input to procedure
	Vi_Currency	   	Varchar2(3);              -- Input to procedure
  Vi_Toddate      varchar2(10);

    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
Cursor Extractdata (	
			 ci_currency VARCHAR2,ci_branchCode VARCHAR2, ci_Date VARCHAR2
      )
  IS
  Select One.Foracid,          
           One.Dealername,
           One.Dealernrc,
           One.Businessname,
           One.Businessaddress,
           One.Commission,
           One.Startdate,
           One.Enddate,
           One.DealerId,
           One.Productname,
           (abs(Nvl(Two.Dis_Amt,0))-Nvl(Three.Tod,0)) As LimitAmt,
           Nvl(Three.Tod,0) As Tod,
           '-' As Depositpercentage,
           '-' As Depositamount,
           (select sol.sol_desc from tbaadm.sol sol where sol.sol_id=Two.sol_id)  as sol_desc
           
    From 
        (Select Tt.Dealer_Id,Gam1.sol_id,Sum(eab.tran_date_bal) As Dis_Amt
        From Tbaadm.Lam Tt, Tbaadm.Gam Gam1,tbaadm.eab eab
        Where Gam1.Acid = Tt.Acid
        and eab.acid = Gam1.acid
        and eab.eab_crncy_code = Gam1.acct_crncy_code
        And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
        and GAM1.acct_crncy_code = upper(ci_currency)
        and eab.eod_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
       and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        --and      Tt.Del_Flg = 'N'
        And   Tt.Entity_Cre_Flg = 'Y'
        And   Tt.Dealer_Id Is Not Null
        group by tt.dealer_id,Gam1.sol_id
        union all 
        Select Tt.Dealer_Id,Gam1.sol_id,Sum(Gam1.clr_bal_amt) As Dis_Amt
        From Tbaadm.Lam Tt, Tbaadm.Gam Gam1
        Where Gam1.Acid = Tt.Acid
        And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
        and GAM1.acct_crncy_code = upper(ci_currency)
        and Gam1.acct_opn_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
        and Gam1.clr_bal_amt <> 0
        --and      Tt.Del_Flg = 'N'
        And   Tt.Entity_Cre_Flg = 'Y'
        And   Tt.Dealer_Id Is Not Null
        and Gam1.acid not in (Select eab.acid
                              From Tbaadm.Lam Tt, Tbaadm.Gam Gam1,tbaadm.eab eab
                              Where Gam1.Acid = Tt.Acid
                              and eab.acid = Gam1.acid
                              and eab.eab_crncy_code = Gam1.acct_crncy_code
                              And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
                              and GAM1.acct_crncy_code = upper(ci_currency)
                              and eab.eod_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                              --and      Tt.Del_Flg = 'N'
                              And   Tt.Entity_Cre_Flg = 'Y'
                              And   Tt.Dealer_Id Is Not Null)
        group by Tt.Dealer_Id,Gam1.sol_id
        )Two
    Left Join 
        (select Lam.Dealer_Id ,
      (sum(ldt.dmd_amt) - sum(ldt.tot_adj_amt)) as Tod,ldt.dmd_date
    from tbaadm.gam gam, tbaadm.ldt ldt,tbaadm.lam lam,tbaadm.eab eab
    where gam.acid = ldt.acid
    and eab.acid = gam.acid
    and lam.acid = gam.acid
    and lam.lam_crncy_code = UPPER(ci_currency)
    and gam.acct_crncy_code = UPPER(ci_currency)
    and ldt.ldt_crncy_code  = UPPER(ci_currency)
    and eab.eab_crncy_code =upper(ci_currency)
    and gam.sol_id like '%' || ci_branchCode|| '%' 
    and eab.eod_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and eab.end_eod_date >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.ACCT_CLS_FLG = 'N'
    AND gam.BANK_ID = '01'
    and gam.clr_bal_amt <0
    and (ldt.dmd_amt - ldt.tot_adj_amt) > 0 
    AND gam.ENTITY_CRE_FLG = 'Y'
    group by Lam.Dealer_Id ,ldt.dmd_date)Three
       On  Two.Dealer_Id =Three.Dealer_Id 
    left join 
    (Select 
       GAM.FORACID as Foracid , 
       LI_DMD.DEALER_NAME as DealerName , 
       ACC.UNIQUEID  as DealerNRC , 
       LI_DMD.DEALER_REMARKS as BusinessName , 
       LI_DMD.DEALER_ADDRESS1 as BusinessAddress , 
       LI_DSD.SUBVENTION_PERCENTAGE as Commission  ,
       LI_DMD.AGREEMENT_START_DATE as StartDate,
       LI_DMD.AGREEMENT_END_DATE as EndDate,
       Li_Dmd.Dealer_Id As Dealerid,
       Li_Dsd.Asset_Code As Productname,
       Gam.Sol_Id
      
    from 
       TBAADM.LI_DMD LI_DMD , 
       TBAADM.GAM GAM , 
       TBAADM.LI_DSD LI_DSD,
       CRMUSER.ACCOUNTS ACC
    
    where
       gam.acct_cls_flg = 'N'
       and gam.del_flg ='N'
       and gam.bank_id ='01'
       And Li_Dmd.Entity_Cre_Flg ='Y'
       --And Gam.Sol_Id like '%' || ci_branchCode|| '%' 
       and GAM.acct_crncy_code = upper(ci_currency )
       And Li_Dmd.Remittance_Account = Gam.Acid 
      -- and li_dmd.remittance_account = '0171600'
       and LI_DSD.DEALER_ID = LI_DMD.DEALER_ID 
       And Gam.Cust_Id = Acc.Core_Cust_Id
       Order By Gam.Foracid)One
       on  Two.Dealer_Id= One.Dealerid
   and abs(Nvl(Two.Dis_Amt,0))<>0
    
    union all
   
   
   Select 
       GAM.FORACID as Foracid , 
       LI_DMD.DEALER_NAME as DealerName , 
       ACC.UNIQUEID  as DealerNRC , 
       LI_DMD.DEALER_REMARKS as BusinessName , 
       LI_DMD.DEALER_ADDRESS1 as BusinessAddress , 
       LI_DSD.SUBVENTION_PERCENTAGE as Commission  ,
       LI_DMD.AGREEMENT_START_DATE as StartDate,
       LI_DMD.AGREEMENT_END_DATE as EndDate,
       Li_Dmd.Dealer_Id As Dealerid,
       Li_Dsd.Asset_Code As Productname,
       0 As LimitAmt,
         0 As Tod,
           '-' As Depositpercentage,
           '-' As Depositamount,
        (select sol.sol_desc from tbaadm.sol sol where sol.sol_id=gam.sol_id)  as sol_desc
      
    from 
       TBAADM.LI_DMD LI_DMD , 
       TBAADM.GAM GAM , 
       TBAADM.LI_DSD LI_DSD,
       CRMUSER.ACCOUNTS ACC
    
    where
       gam.acct_cls_flg = 'N'
       and gam.del_flg ='N'
       and gam.bank_id ='01'
       And Li_Dmd.Entity_Cre_Flg ='Y'
       And Gam.Sol_Id like '%' || ci_branchCode|| '%' 
       and GAM.acct_crncy_code = upper(ci_currency )
       And Li_Dmd.Remittance_Account = Gam.Acid 
      -- and li_dmd.remittance_account = '0171600'
       and LI_DSD.DEALER_ID = LI_DMD.DEALER_ID 
       And Gam.Cust_Id = Acc.Core_Cust_Id
       and  LI_DMD.DEALER_ID not in    (Select Tt.Dealer_Id
                                        From Tbaadm.Lam Tt, Tbaadm.Gam Gam1,tbaadm.eab eab
                                        Where Gam1.Acid = Tt.Acid
                                        and eab.acid = Gam1.acid
                                        and eab.eab_crncy_code = Gam1.acct_crncy_code
                                        And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
                                        and GAM1.acct_crncy_code = upper(ci_currency)
                                        and eab.eod_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                       and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                        --and      Tt.Del_Flg = 'N'
                                        And   Tt.Entity_Cre_Flg = 'Y'
                                        And   Tt.Dealer_Id Is Not Null
                                        group by tt.dealer_id,Gam1.sol_id
                                        union all 
                                        Select Tt.Dealer_Id
                                        From Tbaadm.Lam Tt, Tbaadm.Gam Gam1
                                        Where Gam1.Acid = Tt.Acid
                                        And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
                                        and GAM1.acct_crncy_code = upper(ci_currency)
                                        and Gam1.acct_opn_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                        and Gam1.clr_bal_amt <> 0
                                        --and      Tt.Del_Flg = 'N'
                                        And   Tt.Entity_Cre_Flg = 'Y'
                                        And   Tt.Dealer_Id Is Not Null
                                        and Gam1.acid not in (Select eab.acid
                                                              From Tbaadm.Lam Tt, Tbaadm.Gam Gam1,tbaadm.eab eab
                                                              Where Gam1.Acid = Tt.Acid
                                                              and eab.acid = Gam1.acid
                                                              and eab.eab_crncy_code = Gam1.acct_crncy_code
                                                              And Gam1.Sol_Id like '%' || ci_branchCode|| '%'
                                                              and GAM1.acct_crncy_code = upper(ci_currency)
                                                              and eab.eod_date <= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                              and eab.END_EOD_DATE >= TO_DATE( CAST ( ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                              --and      Tt.Del_Flg = 'N'
                                                              And   Tt.Entity_Cre_Flg = 'Y'
                                                              And   Tt.Dealer_Id Is Not Null)
                                        group by Tt.Dealer_Id,Gam1.sol_id
                                        )

   
   
   order by sol_desc;

  PROCEDURE FIN_DEALER_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    v_DealerAccountNo TBAADM.GAM.FORACID%type;  
    v_DealerName TBAADM.LI_DMD.DEALER_NAME%type;     
    v_DealerNRC  CRMUSER.ACCOUNTS.UNIQUEID%type;   
    v_BusinessName TBAADM.LI_DMD.DEALER_REMARKS%type;   
    v_BusinessAddress TBAADM.LI_DMD.DEALER_ADDRESS1%type;  
    v_Commission TBAADM.LI_DSD.SUBVENTION_PERCENTAGE%type;
    v_StartDate TBAADM.LI_DMD.AGREEMENT_START_DATE%type;
    V_Enddate  Tbaadm.Li_Dmd.Agreement_End_Date%Type;
    
    V_Productname Varchar2(50);
    V_Limitamt    Number(20,2);
    V_Tod         Number(20,2);
    V_Depositper  Varchar2(20);
    V_Depositamt  Varchar2(20);
    V_Soldesc     Varchar2(50);
    
    v_BranchName  TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;   
    v_BankAddress  TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;  
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;  
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;  
    v_DealerId TBAADM.LI_DMD.DEALER_ID%type;
    

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
    Vi_Toddate    := Outarr(0);
    Vi_Currency   := Outarr(1);
    vi_branchCode := outArr(2);
   
    ---------------------------------------------------------------------
    
    if( vi_currency is null or Vi_Toddate is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' ||
		            '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||  '-' );
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    
   IF vi_branchCode IS  NULL or vi_branchCode = '' OR vi_branchCode='10100' THEN
         vi_branchCode := '';
    END IF;
    -----------------------------------------------------------------
 
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				Open Extractdata (	
	  		vi_currency, vi_branchCode ,Vi_Toddate
     );
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			 Fetch	Extractdata
			Into	V_Dealeraccountno, V_Dealername, V_Dealernrc, V_Businessname,
            V_Businessaddress, V_Commission,V_Startdate,V_Enddate,V_Dealerid,
            V_Productname,V_Limitamt,V_Tod,V_Depositper,V_Depositamt,V_Soldesc;
      
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
    
    If Vi_Branchcode Is Null Or Vi_Branchcode = '' Then
      Begin
      V_Branchname := 'ALL Branch';
      End;
    else
          BEGIN
      -------------------------------------------------------------------------------
          -- GET BANK INFORMATION
      -------------------------------------------------------------------------------
            select 
               BRANCH_CODE_TABLE.BR_SHORT_NAME as "BranchName",
               BRANCH_CODE_TABLE.BR_ADDR_1 as "Bank_Address",
               BRANCH_CODE_TABLE.PHONE_NUM as "Bank_Phone",
               BRANCH_CODE_TABLE.FAX_NUM as "Bank_Fax"
               INTO
               v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
            from
               TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
               TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
            where
               SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
               And Service_Outlet_Table.Br_Code = Branch_Code_Table.Br_Code
               And Service_Outlet_Table.Del_Flg = 'N'
               And Service_Outlet_Table.Bank_Id = '01'
               ;
          End;
    end if;
     -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(v_DealerAccountNo      		|| '|' ||
         v_DealerName      			          || '|' ||
          v_DealerNRC      		          	|| '|' ||
					v_BusinessName	                || '|' ||
					v_BusinessAddress      			    || '|' ||
					v_Commission      			        || '|' ||
					v_BranchName	                  || '|' ||
					v_BankAddress      			        || '|' ||
					v_BankPhone                     || '|' ||
          v_BankFax                       || '|' ||
           trim(to_char(to_date(v_StartDate,'dd-Mon-yy'), 'dd/MM/yyyy')  )    			|| '|' ||   
           Trim(To_Char(To_Date(V_Enddate,'dd-Mon-yy'), 'dd/MM/yyyy')  )    			|| '|' ||    
          V_Dealerid                      || '|' ||
          V_Productname                   || '|' ||
          V_Limitamt                      || '|' ||
          V_Tod                           || '|' ||
          V_Depositper                    || '|' ||
          V_Depositamt                    || '|' ||
          V_Soldesc
          );
          
			dbms_output.put_line(out_rec);
  END FIN_DEALER_LISTING;

END FIN_DEALER_LISTING;
/
