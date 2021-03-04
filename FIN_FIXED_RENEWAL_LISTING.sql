CREATE OR REPLACE PACKAGE                                    FIN_FIXED_RENEWAL_LISTING AS 

   PROCEDURE FIN_FIXED_RENEWAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FIXED_RENEWAL_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                       FIN_FIXED_RENEWAL_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_startDate		Varchar2(20);		    	    -- Input to procedure
  vi_endDate		  Varchar2(20);		    	    -- Input to procedure
  vi_branchCode		Varchar2(10);		    	    -- Input to procedure	
  vi_cur	   	Varchar2(5);               -- Input to procedure
    
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	
			ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_branchCode VARCHAR2, ci_cur VARCHAR2)
  IS
 select 
   gam.FORACID as "Account No." , 
   gam.acct_name as "Account Name" ,
   tam.REN_SRL_NUM as "Reg. No." , 
   reno.renewal_bod  as "Reg. Date" , 
   tam.DEPOSIT_PERIOD_MTHS as "Duration",
   tam.MATURITY_DATE as "Mature Date" ,  
   tam.deposit_amount as "DepositAmount" ,
   tam.deposit_amount as "TotalAmount" ,
   (tam.maturity_amount - tam.deposit_amount) as "InterestAmount", 
   tam.ACCT_STATUS as "Renewal Status" , 
   reno.renewal_option,
   (select trim(foracid) from tbaadm.gam where acid = tam.repayment_acid) as "To Account"
from TBAADM.GENERAL_ACCT_MAST_TABLE gam ,tbaadm.reno reno, tbaadm.TD_ACCT_MASTER_TABLE tam
where gam.SCHM_TYPE = 'TDA'   
and gam.SOL_ID = ci_branchCode
and gam.sol_id = tam.sol_id
And Gam.Bank_Id = '01'
and gam.acct_cls_date is null
And Gam.Del_Flg = 'N'
--and   Tam.Open_Effective_Date <> Gam.Acct_Opn_Date
and gam.ACID = reno.ACID 
and tam.acid = reno.ACID 
and gam.acct_crncy_code = upper(ci_cur)
and tam.open_effective_date BETWEEN TO_DATE(ci_startDate,'dd/mm/yyyy') AND TO_DATE(ci_endDate, 'dd/mm/yyyy')
order by gam.FORACID asc,gam.ACCT_OPN_DATE asc;  
  
  PROCEDURE FIN_FIXED_RENEWAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
   
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
   v_AccountName TBAADM.GENERAL_ACCT_MAST_TABLE.acct_name%type;
    v_RegNo TBAADM.tam.REN_SRL_NUM%type;
    v_RegDate tbaadm.reno.renewal_bod%type;
    v_duration tbaadm.tam.DEPOSIT_PERIOD_MTHS%type;
    v_MatureDate tbaadm.tam.MATURITY_DATE%type;
    Deposit_Amount tbaadm.TD_ACCT_MASTER_TABLE.deposit_amount%type;
    Total_Amount tbaadm.TD_ACCT_MASTER_TABLE.MATURITY_AMOUNT%type;
    Interest_Amount tbaadm.TD_ACCT_MASTER_TABLE.MATURITY_AMOUNT%type;
    Renewal_Option tbaadm.reno.Renewal_Option%type;
    v_Status TBAADM.tam.ACCT_STATUS%type;
    v_ToAccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
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
    vi_cur :=  outArr(2);
     vi_branchCode :=  outArr(3);   
    
    -------------------------------------------------------------------------------------------
    
    if( vi_startDate is null or vi_endDate is null or vi_cur is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || 
		            '-' || '|' || '-' || '|' || '-' || '|' || 
                    0 || '|' || 0 || '|' || 0 || '|' ||
				   '-' || '|' ||  '-' || '|' ||  '-'  || '|' ||  '-'  || '|' ||
		          
				   '-' || '|' || '-' || '|' || '-' );
                    
				   
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    
    ---------------------------------------------------------------------------------
    
    
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (	
			vi_startDate , vi_endDate  , vi_branchCode, vi_cur );
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	  v_AccountNumber ,v_AccountName, v_RegNo, v_RegDate,
      v_duration
      ,v_MatureDate ,Deposit_Amount ,Total_Amount,Interest_Amount ,
      v_Status,Renewal_Option,v_ToAccountNumber
      ;
      

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
          v_AccountNumber || '|' ||
          v_AccountName || '|' ||
          v_RegNo || '|' ||
          to_char(to_date(v_RegDate,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' || 
          v_duration || '|' || 
          to_char(to_date(v_MatureDate,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' || 
          Deposit_Amount  || '|' ||
          Total_Amount  || '|' ||
          Interest_Amount  || '|' ||
          Renewal_Option  || '|' ||
          v_Status || '|' ||
          v_ToAccountNumber 			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax );
  
			dbms_output.put_line(out_rec);
    
  END FIN_FIXED_RENEWAL_LISTING;

END FIN_FIXED_RENEWAL_LISTING;
/
