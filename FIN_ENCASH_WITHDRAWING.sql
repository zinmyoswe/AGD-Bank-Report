CREATE OR REPLACE PACKAGE                             FIN_ENCASH_WITHDRAWING AS 

  PROCEDURE FIN_ENCASH_WITHDRAWING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );
      
END FIN_ENCASH_WITHDRAWING;
/


CREATE OR REPLACE PACKAGE BODY                                                                FIN_ENCASH_WITHDRAWING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_branchCode		Varchar2(5);		    	            -- Input to procedure
  vi_startDate Varchar2(10);
  vi_endDate   Varchar2(10);

-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------
 CURSOR ExtractData (	ci_branchCode		Varchar2 , ci_startDate Varchar2, ci_endDate Varchar2) IS
  
        SELECT TCT.CONTRA_TRAN_ID AS "TranId",
 TCT.tran_id  || '/' || tct.part_tran_srl_num as "Old_Tran_Id",
              TCT.AMT_OFFSET AS "TranAmt"
              ,CTH.REMARKS AS "Fax No",
              TCT.TRAN_DATE AS "Assign Date" , 
              TCT.CONTRA_TRAN_DATE AS "Withdraw Date",
              (select bct.br_name from CUSTOM.custom_ctd_dtd_acli_view cdav , tbaadm.bct bct
        where trim(cdav.tran_id) =trim(tct.contra_tran_id) 
        and cdav.branch_code= bct.br_code and rownum = 1
        and cdav.bank_code = bct.bank_code
        and cdav.tran_date= tct.contra_tran_date
        and cdav.part_tran_type= 'D') as Drawing_branch_Name
       FROM TBAADM.TCT TCT , custom.custom_CTH_DTH_VIEW CTH
       WHERE TCT.ENTITY_CRE_FLG = 'Y'
       AND TCT.DEL_FLG = 'N'
       AND trim(TCT.CONTRA_TRAN_ID)= trim(CTH.TRAN_ID)
       and TCT.CONTRA_TRAN_DATE >=TO_DATE( ci_startDate , 'dd-MM-yyyy' ) 
       AND TCT.CONTRA_TRAN_DATE <= TO_DATE( ci_endDate , 'dd-MM-yyyy' )
       AND  TCT.sol_id  = ci_branchCode
       and tct.contra_tran_date = cth.tran_date
       and tct.sol_id = CTH.init_sol_id 
       AND (trim(TCT.CONTRA_TRAN_ID),TCT.contra_tran_date)  in (select trim(TRAN_ID),Tran_date
                                                 from TBAADM.CTD_DTD_ACLI_VIEW
                                                 where Tran_Date >= TO_DATE(ci_startDate , 'dd-MM-yyyy' ) 
                                                 and Tran_Date  <= TO_DATE( ci_endDate , 'dd-MM-yyyy' )
                                                 and DTH_INIT_SOL_ID = ci_branchCode
                                                 --and tran_sub_type not in( 'NR','BI')
                                                 and DEL_FLG = 'N' 
                                                 and PSTD_FLG = 'Y')
         AND (trim(TCT.TRAN_ID),TCT.tran_date,trim(tct.part_tran_srl_num)  )
       in (select trim(cdav.TRAN_ID),cdav.Tran_date,trim(cdav.part_tran_srl_num)
                                                 from TBAADM.CTD_DTD_ACLI_VIEW cdav
                                                 where --cdav.rpt_code in ( 'REMIT','IBREM')
                                                    bank_code is not null
                                                 and  branch_code is not null
                                                 and 
                                                 cdav.DEL_FLG = 'N' 
                                                 and cdav.PSTD_FLG = 'Y'
                                                )    
        AND (trim(TCT.contra_TRAN_ID),TCT.contra_tran_date,trim(tct.contra_part_tran_srl_num)  )
       not in (select trim(atd.cont_tran_id),atd.cont_tran_date,trim(atd.cont_part_tran_srl_num)
                                                 from TBAADM.atd atd
                                                 where atd.cont_tran_date >= TO_DATE(ci_startDate, 'dd-MM-yyyy' ) 
                                                 and atd.cont_tran_date <= TO_DATE(ci_endDate, 'dd-MM-yyyy' ) 
                                                )   
        order by  TCT.CONTRA_TRAN_ID;
 
  PROCEDURE FIN_ENCASH_WITHDRAWING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
 
 
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
     v_tran_id TBAADM.TCT.CONTRA_TRAN_ID%type; 
     v_old_tran_id varchar2(20);
     v_TranAmt TBAADM.TCT.AMT_OFFSET%type;
     v_TranDate TBAADM.TCT.TRAN_DATE%type;
     v_WithDate TBAADM.TCT.CONTRA_TRAN_DATE%type;
      v_faxNo TBAADM.CTH.REMARKS%type;
      v_drawing_branch tbaadm.bct.br_name%type;
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
    
  
		
    vi_startDate := outArr(0);
    vi_endDate   := outArr(1);
    vi_branchCode:=outArr(2);
  
  --------------------------------------------------------------------------
  
  if( vi_startDate is null or vi_endDate is null or vi_branchCode is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  -------------------------------------------------------------------------
   
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ( vi_branchCode, vi_startDate, vi_endDate);	
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	  v_tran_id,v_old_tran_id,v_TranAmt,v_faxNo,v_TranDate, v_WithDate,v_drawing_branch;
      
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
   into    v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_branchCode AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
   
    END;
-----------------------------------------------------------------------------------
--  out_rec variable retrieves the data to be sent to LST file with pipe seperation
------------------------------------------------------------------------------------

    out_rec:=	(
          v_tran_id   || '|' ||
          v_old_tran_id   || '|' ||
					v_TranAmt      			|| '|' ||
          to_char(to_date(v_TranDate,'dd/Mon/yy'), 'dd/MM/yyyy')       	|| '|' ||
          v_faxNo   || '|' ||
           to_char(to_date(v_WithDate ,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' ||
          v_BranchName  || '|' ||
          v_BankAddress || '|' ||
          v_BankPhone || '|' ||
          v_BankFax || '|' ||
          v_drawing_branch
        );
  
			dbms_output.put_line(out_rec);
  END FIN_ENCASH_WITHDRAWING;

END FIN_ENCASH_WITHDRAWING;
/
