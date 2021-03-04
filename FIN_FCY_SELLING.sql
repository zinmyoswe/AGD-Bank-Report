CREATE OR REPLACE PACKAGE         FIN_FCY_SELLING
AS
PROCEDURE FIN_FCY_SELLING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
END FIN_FCY_SELLING;
 
/


CREATE OR REPLACE PACKAGE BODY                                          FIN_FCY_SELLING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;      -- Input Parse Array
	Tran_Date		    Varchar2(10);		    	  -- Input to procedure

-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData

-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_Tran_Date VARCHAR2)
      IS
select q.sol_desc "BranchName",
q.teller_id "teller_id",
sum(q.INR) as INR,
sum(q.MMK) as MMK,
sum(q.USD) as USD,
sum(q.EUR) as EUR,
sum(q.SGD) as SGD,
sum(q.THB) as THB,
sum(q.MYR) as MYR,
sum(q.JPY) as JPY,
sum(q.INR_Kyats) as INR_Kyats,
sum(q.MMK_Kyats) as MMK_Kyats,
sum(q.USD_Kyats) as USD_Kyats,
sum(q.EUR_Kyats) as EUR_Kyats,
sum(q.SGD_Kyats) as SGD_Kyats,
sum(q.THB_Kyats) as THB_Kyats,
sum(q.MYR_Kyats) as MYR_Kyats,
sum(q.JPY_Kyats) as JPY_Kyats
from
(select 
sol.sol_desc  ,
deno.teller_id  , 
case deno.REF_CRNCY_CODE when 'USD' then deno.tran_amt else 0 end as  "USD" ,
case deno.REF_CRNCY_CODE when 'INR' then deno.tran_amt else 0 end as  "INR" ,
case deno.REF_CRNCY_CODE when 'EUR' then deno.tran_amt else 0 end as  "EUR" ,
case deno.REF_CRNCY_CODE when 'SGD' then deno.tran_amt else 0 end as  "SGD" ,
case deno.REF_CRNCY_CODE when 'THB' then deno.tran_amt else 0 end as  "THB" ,
case deno.REF_CRNCY_CODE when 'MYR' then deno.tran_amt else 0 end as  "MYR" ,
case deno.REF_CRNCY_CODE when 'JPY' then deno.tran_amt else 0 end as  "JPY" ,
case deno.REF_CRNCY_CODE when 'MMK' then deno.tran_amt else 0 end as  "MMK" ,

case deno.REF_CRNCY_CODE when 'USD' then deno.ref_amt else 0 end as  USD_Kyats ,
case deno.REF_CRNCY_CODE when 'INR' then deno.ref_amt else 0 end as  INR_Kyats,
case deno.REF_CRNCY_CODE when 'EUR' then deno.ref_amt else 0 end as  EUR_Kyats ,
case deno.REF_CRNCY_CODE when 'SGD' then deno.ref_amt else 0 end as  SGD_Kyats ,
case deno.REF_CRNCY_CODE when 'THB' then deno.ref_amt else 0 end as  THB_Kyats ,
case deno.REF_CRNCY_CODE when 'MYR' then deno.ref_amt else 0 end as  MYR_Kyats ,
case deno.REF_CRNCY_CODE when 'JPY' then deno.ref_amt else 0 end as  JPY_Kyats ,
case deno.REF_CRNCY_CODE when 'MMK' then deno.ref_amt else 0 end as  MMK_Kyats 
FROM CUSTOM.C_DENOM_CASH_MAINTENANCE deno ,tbaadm.sol sol  
WHERE sol.sol_id = substr(deno.debit_foracid,1,5)
and deno.TRAN_DATE = TO_DATE( ci_Tran_Date ,'dd-mm-yyyy')
and trim(deno.FOREIGN_EXCHANGE) = 'S'
and deno.del_flg = 'N'
AND deno.BANK_ID =  '01')q 
group by  q.sol_desc, q.teller_id;
   
PROCEDURE FIN_FCY_SELLING(	inp_str     IN VARCHAR2,
				out_retCode OUT NUMBER,
				out_rec     OUT VARCHAR2) IS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
BranchName tbaadm.sol.sol_desc%type;
  Teller CUSTOM.C_DENOM_CASH_MAINTENANCE.teller_id%type;
  INR CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  MMK CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  USD CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  EUR CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  SGD CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  THB CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  MYR CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  JPY CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  
  INR_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  MMK_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  USD_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  EUR_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  SGD_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  THB_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  MYR_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
  JPY_Kyats CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%type;
 
  
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
    
    Tran_Date :=outArr(0);
   
    -----------------------------------------------------
		-- Checking whether the cursor is open if not
		-- it is opened
		-----------------------------------------------------

if( Tran_Date is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || 0 || '|' || 
		            0 || '|' || 0 || '|' || 0 || '|' || 
                    0 || '|' || 0 || '|' || 0 || '|' ||
					 0 || '|' || 0 || '|' || 0 || '|' ||
					  0 || '|' || 0 || '|' || 0 || '|' ||
					 0 || '|' || 0 || '|' || 0 || '|' ||0 || '|' ||0 );
				  
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;


----------------------------------------------------------------------------------------
    
  IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(Tran_Date);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	BranchName,Teller,
      INR,MMK,USD,EUR,SGD,THB,MYR,JPY,INR_Kyats,MMK_Kyats,USD_Kyats,EUR_Kyats,SGD_Kyats,THB_Kyats,MYR_Kyats,JPY_Kyats;     

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
      -----------------------------------------------------------------------------------
			--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
			------------------------------------------------------------------------------------
		--}
    END IF;
  
    out_rec:=	( BranchName ||'|'|| Teller ||'|'||
      INR ||'|'|| MMK ||'|'|| USD ||'|'|| EUR ||'|'|| SGD ||'|'|| THB ||'|'|| MYR ||'|'|| JPY ||'|'|| 
      INR_Kyats ||'|'|| MMK_Kyats ||'|'|| USD_Kyats ||'|'|| EUR_Kyats ||'|'|| SGD_Kyats ||'|'|| THB_Kyats ||'|'|| MYR_Kyats ||'|'|| JPY_Kyats);
  
			dbms_output.put_line(out_rec);
      --dbms_output.put_line( nodata);
  END FIN_FCY_SELLING;

END FIN_FCY_SELLING;
/
