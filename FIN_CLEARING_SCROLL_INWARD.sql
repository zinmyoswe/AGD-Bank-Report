CREATE OR REPLACE PACKAGE        FIN_CLEARING_SCROLL_INWARD AS 

   PROCEDURE FIN_CLEARING_SCROLL_INWARD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CLEARING_SCROLL_INWARD;
 
/


CREATE OR REPLACE PACKAGE BODY                                                                                            FIN_CLEARING_SCROLL_INWARD AS

  -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;       -- Input Parse Array
	vi_BranchCode	   	Varchar2(7);               -- Input to procedure
	vi_TranDate		    Varchar2(10);		    	     -- Input to procedure
  vi_ZoneCode		    Varchar2(30);		    	     -- Input to procedure
  vi_ZoneDate		    Varchar2(10);		    	     -- Input to procedure
  
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_CLEARING_SCROLL_INWARD
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_BranchCode VARCHAR2,
			ci_TranDate VARCHAR2
      --, ci_ZoneCode VARCHAR2, ci_ZoneDate VARCHAR2
      )
  IS
    select 
      inward.tran_amt,
      inward.tran_rmks,
      gamt.foracid
    from 
      tbaadm.inw_clg_part_tran_table inward,
      tbaadm.gam gamt
    where 
      inward.zone_date = TO_DATE(CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
      and inward.sol_id = ci_BranchCode
      --and inward.zone_code = ci_ZoneCode
      --and inward.zone_date = TO_DATE(CAST ( ci_ZoneDate AS VARCHAR(10) ) , 'dd-MM-yyyy')
      and inward.acid = gamt.acid
      --and inward.sol_id = gamt.sol_id
      and gamt.del_flg = 'N'
      and inward.BANK_ID = '01'
      order by inward.tran_id;
      
-----------------------------------------------------------------------------
-- CURSOR ExtractData1 (Charges internal remittance)
----------------------------------------------------------------------------

  PROCEDURE FIN_CLEARING_SCROLL_INWARD(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) 
        IS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_tranAmt tbaadm.inw_clg_part_tran_table.TRAN_AMT%TYPE;
    v_tranRemarks tbaadm.inw_clg_part_tran_table.TRAN_RMKS%TYPE;
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
    --vi_ZoneCode:=outArr(2);
    --vi_ZoneDate:=outArr(3);
    -------------------------------------------------------------------
     if( vi_TranDate is null or vi_BranchCode is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-'  );
		           
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
						vi_TranDate
            --, vi_ZoneCode, vi_ZoneDate
            );
			--}
			END;

		--}
		END IF;
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	v_tranAmt, v_tranRemarks, v_foracid;
      

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
    out_rec:=	(
					v_tranAmt      			|| '|' ||
					v_tranRemarks      			|| '|' ||
					v_foracid);
  
			dbms_output.put_line(out_rec);
  END FIN_CLEARING_SCROLL_INWARD;

END FIN_CLEARING_SCROLL_INWARD;
/
