CREATE OR REPLACE PACKAGE FIN_DEALER AS 

   PROCEDURE FIN_DEALER(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_DEALER;
/


CREATE OR REPLACE PACKAGE BODY                                                                                     FIN_DEALER AS

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
			 ci_currency VARCHAR2)
  IS
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
       Order By Gam.Foracid;

  PROCEDURE FIN_DEALER(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    v_Foracid TBAADM.GAM.FORACID%type;  
    v_DealerName TBAADM.LI_DMD.DEALER_NAME%type;     
    v_DealerNRC  CRMUSER.ACCOUNTS.UNIQUEID%type;   
    v_BusinessName TBAADM.LI_DMD.DEALER_REMARKS%type;   
    v_BusinessAddress TBAADM.LI_DMD.DEALER_ADDRESS1%type;  
    v_Commission TBAADM.LI_DSD.SUBVENTION_PERCENTAGE%type;
    v_StartDate TBAADM.LI_DMD.AGREEMENT_START_DATE%type;
    V_Enddate  Tbaadm.Li_Dmd.Agreement_End_Date%Type;
    v_DealerId TBAADM.LI_DMD.DEALER_ID%type;
    V_Productname Varchar2(50);
    v_sol_id tbaadm.sol.sol_id%type;
    

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
   
    Vi_Currency   := Outarr(0);
    
   
    ---------------------------------------------------------------------
    
    if( Vi_Currency is null) then
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
				Open Extractdata (vi_currency);
			--}
			END;

		--}
		END IF;
 
    IF ExtractData%ISOPEN THEN
		--{
			 Fetch	Extractdata
			Into	v_Foracid ,v_DealerName,v_DealerNRC,v_BusinessName,v_BusinessAddress,
    v_Commission,v_StartDate,V_Enddate,v_DealerId, V_Productname,v_sol_id;
      
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
    
    
     -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(v_Foracid || '|' ||
               v_DealerName|| '|' ||
               v_DealerNRC|| '|' ||
               v_BusinessName|| '|' ||
               v_BusinessAddress|| '|' ||
               v_Commission|| '|' ||
               trim(to_char(to_date(v_StartDate,'dd-Mon-yy'), 'dd-MM-yyyy')  )    			|| '|' ||   
           Trim(To_Char(To_Date(V_Enddate,'dd-Mon-yy'), 'dd-MM-yyyy')  )    			|| '|' ||    
               v_DealerId|| '|' ||
               V_Productname|| '|' ||
               v_sol_id
          );
          
			dbms_output.put_line(out_rec);
  END FIN_DEALER;

END FIN_DEALER;
/
