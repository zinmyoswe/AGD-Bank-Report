CREATE OR REPLACE PACKAGE        FIN_CLEARING_SCROLL_OUTWARD AS 

  PROCEDURE FIN_CLEARING_SCROLL_OUTWARD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ); 

END FIN_CLEARING_SCROLL_OUTWARD;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                              FIN_CLEARING_SCROLL_OUTWARD AS

   -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;       -- Input Parse Array
	vi_BranchCode	   	Varchar2(7);               -- Input to procedure
	vi_TranDate		    Varchar2(10);		    	     -- Input to procedure
  
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_CLEARING_SCROLL_INWARD
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------

  CURSOR ExtractData (	ci_BranchCode VARCHAR2,
			ci_TranDate VARCHAR2)
  IS
  
  select 
    outward.tran_amt,
    outward.partcls,
    outward.tran_rmks,
    gamt.foracid
  from 
    tbaadm.out_clg_part_tran_table outward,
    tbaadm.gam gamt
  where 
    outward.tran_date = TO_DATE(CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
    and outward.sol_id = ci_BranchCode
    and outward.acid = gamt.acid
    --and outward.sol_id = gamt.sol_id
    and outward.del_flg = 'N'
    and gamt.del_flg = 'N'
    and outward.BANK_ID = '01'
    order by outward.tran_id;

  PROCEDURE FIN_CLEARING_SCROLL_OUTWARD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
      -------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_tranAmt tbaadm.out_clg_part_tran_table.tran_amt%TYPE;
    v_tranParticular tbaadm.out_clg_part_tran_table.partcls%TYPE;
    v_tranRemarks tbaadm.out_clg_part_tran_table.tran_rmks%TYPE;
    v_foracid TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%TYPE;
      
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
    -------------------------------------------------------------------------
    
     if( vi_TranDate is null or vi_BranchCode is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-' || '|' || '-' );
		           
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
				OPEN ExtractData(vi_BranchCode,
						vi_TranDate);
			--}
			END;

		--}
		END IF;
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_tranAmt, v_tranParticular, v_tranRemarks, v_foracid;
      

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
    out_rec:=	(v_tranAmt 
    || '|' || v_tranParticular 
    || '|' || v_tranRemarks 
    || '|' || v_foracid);
  
			dbms_output.put_line(out_rec);
  END FIN_CLEARING_SCROLL_OUTWARD;

END FIN_CLEARING_SCROLL_OUTWARD;
/
