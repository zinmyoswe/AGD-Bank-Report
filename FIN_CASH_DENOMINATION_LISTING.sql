CREATE OR REPLACE PACKAGE        FIN_CASH_DENOMINATION_LISTING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE FIN_CASH_DENOMINATION_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 );
                                            
END FIN_CASH_DENOMINATION_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                      FIN_CASH_DENOMINATION_LISTING AS
/******************************************************************************
 NAME:       FIN_CASH_DENOMINATION_LISTING
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_tranDate       VARCHAR2(10);               -- Input to procedure
  vi_userID         VARCHAR2(15);               -- Input to procedure
  vi_currency        VARCHAR2(3);               -- Input to procedure
  vi_Type            VARCHAR2(15);               -- Input to procedure
  vi_branchCode     VARCHAR2(5);                -- Input to procedure
  
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_CASH_DENOMINATION_LISTING CURSOR
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CURSOR ExtractData
--------------------------------------------------------------------------------
CURSOR ExtractDataAll (ci_tranDate VARCHAR2, ci_userID VARCHAR2, ci_branchCode VARCHAR2, ci_currency varchar2)
IS
  select distinct deno.TRAN_ID,
        case when deno.foreign_exchange='B' then deno.debit_foracid else deno.credit_foracid end as foracid, 
        gam.ACCT_NAME,deno.TELLER_ID, 
        deno.N10000, deno.N1000, deno.N500, deno.N200,deno.N100,deno.N50,deno.N25,deno.N20,deno.N10,deno.N5,deno.N2,deno.N1,
         (deno.N10000+ deno.N1000+ deno.N500+ deno.N200+deno.N100+deno.N50+deno.N25+deno.N20+deno.N10+deno.N5+deno.N2+deno.N1)as Deno_Count, 
         deno.TRAN_AMT,deno.foreign_exchange
  FROM tbaadm.gam gam, CUSTOM.c_denom_cash_maintenance deno
  where (gam.foracid= deno.debit_foracid or gam.foracid= deno.credit_foracid)
  and deno.teller_id =UPPER(ci_userID)
  and deno.ref_crncy_code =UPPER(ci_currency)
  and gam.sol_id = ci_branchCode
  and deno.tran_date =TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  and deno.bank_id ='01'
  and gam.bank_id ='01'
  and deno.del_flg='N'
  and gam.del_flg='N'
  and trim (deno.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by trim(deno.TRAN_ID); 
-------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataBuying (ci_tranDate VARCHAR2, ci_userID VARCHAR2, ci_branchCode VARCHAR2, ci_currency varchar2)
IS
select distinct deno.TRAN_ID,
      deno.debit_foracid,
          gam.ACCT_NAME,deno.TELLER_ID, 
        deno.N10000, deno.N1000, deno.N500, deno.N200,deno.N100,deno.N50,deno.N25,deno.N20,deno.N10,deno.N5,deno.N2,deno.N1,
         (deno.N10000+ deno.N1000+ deno.N500+ deno.N200+deno.N100+deno.N50+deno.N25+deno.N20+deno.N10+deno.N5+deno.N2+deno.N1)as Deno_Count, 
         deno.TRAN_AMT,deno.foreign_exchange
  FROM tbaadm.gam gam, CUSTOM.c_denom_cash_maintenance deno
  where gam.foracid= deno.debit_foracid 
  and deno.teller_id =UPPER(ci_userID)
  and deno.ref_crncy_code =UPPER(ci_currency)
  and deno.foreign_exchange= 'B'
  and gam.sol_id = ci_branchCode
  and deno.tran_date =TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  and deno.bank_id ='01'
  and gam.bank_id ='01'
  and deno.del_flg='N'
  and gam.del_flg='N'
  and trim (deno.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by trim(deno.TRAN_ID); 
-------------------------------------------------------------------------------------------------------------------------------------
CURSOR ExtractDataSelling (ci_tranDate VARCHAR2, ci_userID VARCHAR2, ci_branchCode VARCHAR2, ci_currency varchar2)
IS
select distinct deno.TRAN_ID,
      deno.credit_foracid,
          gam.ACCT_NAME,deno.TELLER_ID, 
        deno.N10000, deno.N1000, deno.N500, deno.N200,deno.N100,deno.N50,deno.N25,deno.N20,deno.N10,deno.N5,deno.N2,deno.N1,
         (deno.N10000+ deno.N1000+ deno.N500+ deno.N200+deno.N100+deno.N50+deno.N25+deno.N20+deno.N10+deno.N5+deno.N2+deno.N1)as Deno_Count, 
         deno.TRAN_AMT,deno.foreign_exchange
  FROM tbaadm.gam gam, CUSTOM.c_denom_cash_maintenance deno
  where gam.foracid= deno.debit_foracid 
  and deno.teller_id =UPPER(ci_userID)
  and deno.ref_crncy_code =UPPER(ci_currency)
  and deno.foreign_exchange= 'S'
  and gam.sol_id = ci_branchCode
  and deno.tran_date =TO_DATE(CAST(ci_tranDate AS VARCHAR(10)),'dd-MM-yyyy')
  and deno.bank_id ='01'
  and gam.bank_id ='01'
  and deno.del_flg='N'
  and gam.del_flg='N'
  and trim (deno.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  order by trim(deno.TRAN_ID);
  
-------------------------------------------------------------------------------------------------------------------------------------  
  PROCEDURE FIN_CASH_DENOMINATION_LISTING(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS  
  v_EntryNo CUSTOM.c_denom_cash_maintenance.tran_id%type;
  v_AccNo CUSTOM.c_denom_cash_maintenance.debit_foracid%type;
  v_AccName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_Cashier CUSTOM.c_denom_cash_maintenance.TELLER_ID%type;
  v_F10000 CUSTOM.c_denom_cash_maintenance.N10000%type;
  --v_F5000 CUSTOM.c_denom_cash_maintenance.N1000%type;
  v_F1000 CUSTOM.c_denom_cash_maintenance.N1000%type;
  v_F500 CUSTOM.c_denom_cash_maintenance.N500%type;
  v_F200 CUSTOM.c_denom_cash_maintenance.N200%type;
  v_F100 CUSTOM.c_denom_cash_maintenance.N100%type;
  v_F50 CUSTOM.c_denom_cash_maintenance.N50%type;
  v_F25 CUSTOM.c_denom_cash_maintenance.N25%type;
  v_F20 CUSTOM.c_denom_cash_maintenance.N20%type;
  v_F10 CUSTOM.c_denom_cash_maintenance.N10%type;
  v_F5 CUSTOM.c_denom_cash_maintenance.N5%type;
  v_F2 CUSTOM.c_denom_cash_maintenance.N2%type;
  v_F1 CUSTOM.c_denom_cash_maintenance.N1%type;
  --v_Coins TBAADM.TRAN_CASH_DENOM_TBL.DENOM_COUNT%type;
  v_TotalCount Number;
  v_TranAmount CUSTOM.c_denom_cash_maintenance.TRAN_AMT%type;
  v_exchange CUSTOM.c_denom_cash_maintenance.foreign_exchange%type;
  --v_Refund TBAADM.GENERAL_ACCT_MAST_TABLE.CLR_BAL_AMT%type; 
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
  v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
  v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
  BEGIN
  ------------------------------------------------------------------------------
          -- Out Ret code is the code which controls
          -- the while loop,it can have values 0,1
          -- 0 - The while loop is being executed
          -- 1 - Exit
  ------------------------------------------------------------------------------
		out_retCode := 0;
		out_rec := NULL;
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);    
  ------------------------------------------------------------------------------
		-- Parsing the i/ps from the string
	------------------------------------------------------------------------------
    
    vi_tranDate    :=  outArr(0);
    vi_userID      :=  outArr(1);
    vi_currency    := outArr(2);
    vi_Type        := outArr(3);
    vi_branchCode  :=  outArr(4);
 ----------------------------------------------------------------------------
 
 if( vi_tranDate is null or vi_userID is null or vi_branchCode is null or vi_currency is null or vi_Type is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-'  || '|' ||
                '-' || '|' ||
                '-' || '|' ||
                0  || '|' ||
                0 	 || '|' ||
                0 	            || '|' ||
                0 	            || '|' ||
                0	            || '|' ||
                0 	            || '|' ||
                0 	            || '|' ||
                0 	            || '|' ||
                0	              || '|' ||
                0 	              || '|' ||
                0 	              || '|' ||
                0	              || '|' ||
                0 	      || '|' ||  
                 0 	      || '|' ||             
                '-'         || '|' ||
                '-'         || '|' ||
                '-'        || '|' ||
                '-'          || '|' ||
                '-'    );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
 
 ---------------------------------------------------------------------------------------------
  If vi_Type   like 'All' then
    IF NOT ExtractDataAll%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataAll (vi_tranDate, vi_userID, vi_branchCode,vi_currency);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataAll%ISOPEN THEN
		--{
			FETCH	ExtractDataAll
			INTO v_EntryNo,v_AccNo, v_AccName, v_Cashier, v_F10000,
           v_F1000, v_F500, v_F200, v_F100, v_F50,v_F25, v_F20,
          v_F10, v_F5,v_F2, v_F1, v_TotalCount,v_TranAmount,v_exchange;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataAll%NOTFOUND THEN
			--{
				CLOSE ExtractDataAll;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    ELSIF vi_Type   like 'Buying' then
      IF NOT ExtractDataBuying%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataBuying (vi_tranDate, vi_userID, vi_branchCode,vi_currency);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataBuying%ISOPEN THEN
		--{
			FETCH	ExtractDataBuying
			INTO v_EntryNo,v_AccNo, v_AccName, v_Cashier, v_F10000,
           v_F1000, v_F500, v_F200, v_F100, v_F50,v_F25, v_F20,
          v_F10, v_F5,v_F2, v_F1, v_TotalCount,v_TranAmount,v_exchange;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataBuying%NOTFOUND THEN
			--{
				CLOSE ExtractDataBuying;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    ELSE
        IF NOT ExtractDataSelling%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataSelling (vi_tranDate, vi_userID, vi_branchCode,vi_currency);
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataSelling%ISOPEN THEN
		--{
			FETCH	ExtractDataSelling
			INTO v_EntryNo,v_AccNo, v_AccName, v_Cashier, v_F10000,
           v_F1000, v_F500, v_F200, v_F100, v_F50,v_F25, v_F20,
          v_F10, v_F5,v_F2, v_F1, v_TotalCount,v_TranAmount,v_exchange;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataSelling%NOTFOUND THEN
			--{
				CLOSE ExtractDataSelling;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    
    end If;
-------------------------------------------------------------------------------
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
      SELECT 
         BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
         BRANCH_CODE_TABLE.BR_ADDR_1 AS "Bank_Address",
         BRANCH_CODE_TABLE.PHONE_NUM AS "Bank_Phone",
         BRANCH_CODE_TABLE.FAX_NUM AS "Bank_Fax"
         INTO
         v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
      FROM
         TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
         TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
      WHERE
         SERVICE_OUTLET_TABLE.SOL_ID = vi_BranchCode
         AND SERVICE_OUTLET_TABLE.BR_CODE = BRANCH_CODE_TABLE.BR_CODE
         AND SERVICE_OUTLET_TABLE.DEL_FLG = 'N'
         AND SERVICE_OUTLET_TABLE.BANK_ID = '01'
         and BRANCH_CODE_TABLE.bank_code = '116';
    END;
    
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(
                v_EntryNo           || '|' ||
                v_AccNo          || '|' ||
                v_AccName 	        || '|' ||
                v_Cashier 	        || '|' ||
                v_F10000 	          || '|' ||
                v_F1000 	          || '|' ||
                v_F500 	            || '|' ||
                v_F200 	            || '|' ||
                v_F100	            || '|' ||
                v_F50 	            || '|' ||
                v_F25 	            || '|' ||
                v_F20 	            || '|' ||
                v_F10	              || '|' ||
                v_F5 	              || '|' ||
                v_F2 	              || '|' ||
                v_F1	              || '|' ||
                v_TotalCount 	      || '|' ||
                v_TranAmount 	      || '|' || 
                v_exchange          || '|' ||
                v_BranchName        || '|' ||
                v_BankAddress       || '|' ||
                v_BankPhone         || '|' ||
                v_BankFax           );
  
			dbms_output.put_line(out_rec);
      
  END FIN_CASH_DENOMINATION_LISTING;

END FIN_CASH_DENOMINATION_LISTING;
/
