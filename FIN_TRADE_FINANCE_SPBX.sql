CREATE OR REPLACE PACKAGE        FIN_TRADE_FINANCE_SPBX AS 

  PROCEDURE FIN_TRADE_FINANCE_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_TRADE_FINANCE_SPBX;
 
/


CREATE OR REPLACE PACKAGE BODY                                    FIN_TRADE_FINANCE_SPBX AS

  -------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_BranchCode	   	Varchar2(5);              -- Input to procedure
	vi_Currency		    Varchar2(3);		    	    -- Input to procedure
  vi_OpenDate		    Varchar2(10);		    	    -- Input to procedure
  vi_EndDate		    Varchar2(10);		    	    -- Input to procedure

-------------------------------------------------------------------------------
    -- GET LC Outstanding Information
-------------------------------------------------------------------------------
    CURSOR ExtractData (ci_BranchCode	   	Varchar2,
      ci_Currency	   	Varchar2,
      ci_OpenDate	   	Varchar2,	
			ci_EndDate		Varchar2) IS
      select
        dcmmt.date_opnd, 
        dcmmt.applicant_name, 
        dcmmt.dc_ref_num, 
        dcmmt.open_value, 
        dcmmt.DATE_CLSD,
        dcmmt.confirmation_reqd_flg,
        bctt.br_name
      from 
        tbaadm.dcmm dcmmt,
        tbaadm.bct bctt
      where 
        TO_DATE( CAST ( ci_OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) <= dcmmt.date_opnd
        and TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) >= dcmmt.date_opnd
        and dcmmt.actl_crncy_code = upper(ci_Currency)
        and dcmmt.del_flg = 'N'
        and dcmmt.bank_id = '01'
        and dcmmt.sol_id = ci_BranchCode
        and dcmmt.ADVISING_BANK_CODE = bctt.bank_code
        and dcmmt.ADVISING_BRANCH_CODE = bctt.BR_CODE;
        
-------------------------------------------------------------------------------
    -- GET LC Beneficiary's Information
-------------------------------------------------------------------------------
    CURSOR ExtractData1 (ci_BranchCode	   	Varchar2,
      ci_Currency	   	Varchar2,
      ci_OpenDate	   	Varchar2,	
			ci_EndDate		Varchar2) IS
      select
        tfatt.NAME
      from 
        tbaadm.dcmm dcmmt,
        tbaadm.TFAT tfatt
      where 
        TO_DATE( CAST ( ci_OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) <= dcmmt.date_opnd
        and TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) >= dcmmt.date_opnd
        and dcmmt.actl_crncy_code = upper(ci_Currency)
        and dcmmt.del_flg = 'N'
        and dcmmt.bank_id = '01'
        and dcmmt.sol_id = ci_BranchCode
        and tfatt.addr_b2kid = dcmmt.DC_B2KID
        and tfatt.ADDR_TYPE = 'S'
        and tfatt.BANK_ID = '01'
        and tfatt.ADDR_ID = 'DCOUPY';
-------------------------------------------------------------------------------
    -- GET LC COMMODITY's Information
-------------------------------------------------------------------------------
    CURSOR ExtractData2 (ci_BranchCode	   	Varchar2,
      ci_Currency	   	Varchar2,
      ci_OpenDate	   	Varchar2,	
			ci_EndDate		Varchar2) IS
      select
        cdtyy.COMMODITY_DESC || cdtyy.ALT1_COMMODITY_DESC
      from 
        tbaadm.dcmm dcmmt,
        tbaadm.cdty cdtyy
      where 
        TO_DATE( CAST ( ci_OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) <= dcmmt.date_opnd
        and TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) >= dcmmt.date_opnd
        and dcmmt.actl_crncy_code = upper(ci_Currency)
        and dcmmt.del_flg = 'N'
        and dcmmt.bank_id = '01'
        and dcmmt.sol_id = ci_BranchCode
        and dcmmt.COMMODITY_CODE = cdtyy.COMMODITY_CODE
        and cdtyy.BANK_ID = '01';
-------------------------------------------------------------------------------
    -- GET LC bill's Information
-------------------------------------------------------------------------------
    CURSOR ExtractData3 (ci_BranchCode	   	Varchar2,
      ci_Currency	   	Varchar2,
      ci_OpenDate	   	Varchar2,	
			ci_EndDate		Varchar2) IS
        select 
          fbmm.BILL_DATE
        from 
          tbaadm.fei feii,
          tbaadm.fbm fbmm,
          tbaadm.dcmm dcmmt
        where
          TO_DATE( CAST ( ci_OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) <= dcmmt.date_opnd
          and TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) >= dcmmt.date_opnd
          and dcmmt.actl_crncy_code = upper(ci_Currency)
          and dcmmt.del_flg = 'N'
          and dcmmt.bank_id = '01'
          and dcmmt.sol_id = ci_BranchCode
          and feii.lc_number = dcmmt.DC_REF_NUM
          and feii.BILL_ID = fbmm.BILL_ID;        

  PROCEDURE FIN_TRADE_FINANCE_SPBX(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) IS
      
       v_openDate tbaadm.dcmm.date_opnd%type;
       v_appName tbaadm.dcmm.applicant_name%type; 
       v_LCNo tbaadm.dcmm.dc_ref_num%type; 
       v_LCAmt tbaadm.dcmm.open_value%type; 
       v_closeDate tbaadm.dcmm.DATE_CLSD%type;
       v_confimationReqFlg tbaadm.dcmm.confirmation_reqd_flg%type;
       v_advBank tbaadm.bct.br_name%type;
       v_beneficiaryName tbaadm.tfat.name%type;
       v_commdity tbaadm.cdty.COMMODITY_DESC%type;
       v_billDate tbaadm.fbm.BILL_DATE%type;
      
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
    vi_OpenDate:=outArr(0);		    
    vi_EndDate:=outArr(1);
    vi_Currency:=outArr(2);		   
     vi_BranchCode:=outArr(3);
 --------------------------------------------------------------------------------------
 if( vi_OpenDate is null or vi_EndDate is null or vi_Currency is null or vi_BranchCode is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 
 
 ------------------------------------------------------------------------------------
------------------ExtractData---------------------------------------   
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_BranchCode,
      vi_Currency,
      vi_OpenDate,	
			vi_EndDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_openDate, v_appName, v_LCNo, v_LCAmt, 
            v_closeDate, v_confimationReqFlg, v_advBank;
      

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
---------------------ExtractData1----------------------------------------
    IF NOT ExtractData1%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData1 (vi_BranchCode,
      vi_Currency,
      vi_OpenDate,	
			vi_EndDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData1%ISOPEN THEN
		--{
			FETCH	ExtractData1
			INTO	v_beneficiaryName;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData1%NOTFOUND THEN
			--{
				CLOSE ExtractData1;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
---------------------ExtractData2----------------------------------------
    IF NOT ExtractData2%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData2 (vi_BranchCode,
      vi_Currency,
      vi_OpenDate,	
			vi_EndDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData2%ISOPEN THEN
		--{
			FETCH	ExtractData2
			INTO	v_commdity;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData2%NOTFOUND THEN
			--{
				CLOSE ExtractData2;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
---------------------ExtractData3----------------------------------------
    IF NOT ExtractData3%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData3 (vi_BranchCode,
      vi_Currency,
      vi_OpenDate,	
			vi_EndDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData3%ISOPEN THEN
		--{
			FETCH	ExtractData3
			INTO	v_billDate;
      

			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData3%NOTFOUND THEN
			--{
				CLOSE ExtractData2;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    out_rec:=	(v_openDate            || '|' ||
          v_LCNo      			|| '|' ||
					v_appName      			|| '|' ||
          v_beneficiaryName || '|' ||
          v_LCAmt      			|| '|' ||
          v_advBank || '|' ||
          v_confimationReqFlg || '|' ||
          v_commdity || '|' ||
					v_billDate || '|' ||
          v_closeDate	);
  
			dbms_output.put_line(out_rec);
  END FIN_TRADE_FINANCE_SPBX;

END FIN_TRADE_FINANCE_SPBX;
/
