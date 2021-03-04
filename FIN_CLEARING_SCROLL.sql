CREATE OR REPLACE PACKAGE                      FIN_CLEARING_SCROLL AS 

   PROCEDURE FIN_CLEARING_SCROLL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CLEARING_SCROLL;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                      FIN_CLEARING_SCROLL AS

  -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;       -- Input Parse Array
	vi_BranchCode	   	Varchar2(7);               -- Input to procedure
	vi_TranDate		    Varchar2(10);		    	     -- Input to procedure
  --vi_ZoneCode		    Varchar2(30);		    	     -- Input to procedure
  
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_BranchCode VARCHAR2)
  IS
  
  SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
 
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = ci_BranchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
  
      
-----------------------------------------------------------------------------
-- CURSOR ExtractData1 (Charges internal remittance)
----------------------------------------------------------------------------

  PROCEDURE FIN_CLEARING_SCROLL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) 
        IS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
   
     v_branchShortName tbaadm.sol.sol_desc%type;
    v_bankAddress varchar(200);
    v_bankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%TYPE;
    v_bankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%TYPE;
    -- v_tranDate TBAADM.CTD_DTD_ACLI_VIEW.TRAN_DATE%TYPE;
    v_totalDelivered TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE := 0;
    v_totalClearingHouseAC TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%TYPE := 0;
      
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
    
    vi_BranchCode:=outArr(1);
		vi_TranDate:=outArr(0);
    --vi_ZoneCode:=outArr(2);
 --------------------------------------------------------------------
 
  if( vi_TranDate is null or vi_BranchCode is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0  );
		           
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
    -----------------------------------------------------
		-- Checking whether the cursor is open if not
		-- it is opened
		-----------------------------------------------------
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData(vi_BranchCode);
			--}
			END;

		--}
		END IF;
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_branchShortName, v_bankAddress, v_bankPhone, v_bankFax;
      

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
    BEGIN
      select 
        sum(outward.tran_amt) into v_totalDelivered
      from 
        tbaadm.out_clg_part_tran_table outward,
        tbaadm.gam gamt
      where 
        outward.tran_date = TO_DATE(CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
        and outward.sol_id = vi_BranchCode
        and outward.acid = gamt.acid
        --and outward.sol_id = gamt.sol_id
        and outward.del_flg = 'N'
        and gamt.del_flg = 'N'
        and outward.BANK_ID = '01'
        order by outward.tran_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        v_totalDelivered := 0;
        
      END; 
    -----------------------------
     BEGIN
      select 
        sum(inward.tran_amt) into v_totalClearingHouseAC
      from 
        tbaadm.inw_clg_part_tran_table inward,
        tbaadm.gam gamt
      where 
        inward.zone_date = TO_DATE(CAST ( vi_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
        and inward.sol_id = vi_BranchCode
        --and inward.zone_code = vi_ZoneCode
        and inward.acid = gamt.acid
       -- and inward.sol_id = gamt.sol_id
        and gamt.del_flg = 'N'
        and inward.BANK_ID = '01'
        order by inward.tran_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        v_totalClearingHouseAC := 0;
    END;
    
    if(v_totalDelivered is null) then
    v_totalDelivered := 0;end if;
    if(v_totalClearingHouseAC is null) then
    v_totalClearingHouseAC := 0; end if;
    
    out_rec:=	(v_branchShortName            || '|' ||
          v_bankAddress      			|| '|' ||
          v_bankPhone      			|| '|' ||
					v_bankFax	|| '|' ||
					--v_tranDate|| '|' ||
					v_totalDelivered|| '|' ||
					v_totalClearingHouseAC);
  
			dbms_output.put_line(out_rec);
  END FIN_CLEARING_SCROLL;

END FIN_CLEARING_SCROLL;
/
