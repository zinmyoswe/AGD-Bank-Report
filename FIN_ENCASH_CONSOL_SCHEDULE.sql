CREATE OR REPLACE PACKAGE               FIN_ENCASH_CONSOL_SCHEDULE AS 

PROCEDURE FIN_ENCASH_CONSOL_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );


END FIN_ENCASH_CONSOL_SCHEDULE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                          FIN_ENCASH_CONSOL_SCHEDULE AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_other_bank		Varchar2(30);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractData(ci_TranDate Varchar2 ,ci_other_bank Varchar2)
IS
select q.SOL_ID,
        q.AGD,
        q.Other_Bank,
        q.Payee,
        q.Amount,
        q.br_open_date,
        q.tran_id
  from
(select 
      ctd.dth_init_sol_id as SOL_ID,
      sol.sol_desc as AGD, 
      bct.br_name as Other_Bank,
      ctd.tran_rmks as Payee, 
      sum(ctd.tran_amt) as Amount,
      sol.br_open_date,
      ctd.tran_id
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol
where
    ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and (ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI')
    and  ctd.rpt_code in ('IBREM','REMIB')
    and ctd.bank_code = ci_other_bank
    and ctd.dth_init_sol_id !='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.dth_init_sol_id = sol.sol_id
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
    and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  group by sol.br_open_date,ctd.dth_init_sol_id,sol.sol_desc,
bct.br_name,ctd.tran_rmks,ctd.tran_amt,ctd.tran_id
--order by sol.br_open_date,ctd.dth_init_sol_id
union all
select 
      ctd.dth_init_sol_id as SOL_ID,
      sol.sol_desc as AGD, 
      bct.br_name as Other_Bank,
      ctd.tran_rmks as Payee, 
      sum(ctd.tran_amt) as Amount,
      sol.br_open_date,
      ctd.tran_id
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol
where
    ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and ctd.part_tran_type = 'D'
    and  ctd.rpt_code in ('IBREM','REMIB')
    and ctd.bank_code = ci_other_bank
    and ctd.dth_init_sol_id ='20300'
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.dth_init_sol_id = sol.sol_id
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
    and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
  group by sol.br_open_date,ctd.dth_init_sol_id,sol.sol_desc,
bct.br_name,ctd.tran_rmks,ctd.tran_amt,ctd.tran_id
--order by sol.br_open_date,ctd.dth_init_sol_id
) q
order by q.br_open_date,q.SOL_ID;

  PROCEDURE FIN_ENCASH_CONSOL_SCHEDULE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_sol_id  tbaadm.sol.sol_id%type;
    v_AGD_BR_name tbaadm.sol.sol_desc%type;
    v_other_Br_name tbaadm.bct.br_name%type;
    v_payee_name CUSTOM.custom_ctd_dtd_acli_view.TRAN_RMKS%type;
    v_drawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_open_date tbaadm.sol.br_open_date%type;
    v_tran_id CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
     
     
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
     vi_TranDate := outArr(0);
     vi_other_bank := outArr(1);
     
     -------------------------------------------------------------------------
     
     if( vi_TranDate is null or vi_other_bank is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0);
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
     
     ------------------------------------------------------------------------
     
     IF vi_other_bank ='KBZ' then
       vi_other_bank := '109';
    ELSIf vi_other_bank ='AYA' then
        vi_other_bank := '117';
    ELSIf vi_other_bank ='GTB' then
        vi_other_bank := '112';
    ELSIf vi_other_bank ='MWD' then
        vi_other_bank := '104';
    ELSIf vi_other_bank ='CB' then
        vi_other_bank := '115';
    ELSIf vi_other_bank ='SMIDB' then
        vi_other_bank := '111';
    ELSIf vi_other_bank ='RDB' then
        vi_other_bank := '113';
    ELSIf vi_other_bank ='CHDB' then
        vi_other_bank := '121';
    ELSIf vi_other_bank ='Innwa' then
        vi_other_bank := '114';
    ELSIf vi_other_bank ='Shwe' then
        vi_other_bank := '123';
    ELSIf vi_other_bank ='MABL' then
        vi_other_bank := '118';
    ELSIf vi_other_bank ='May(MALAYSIA)' then
        vi_other_bank := 'MY02';
    ELSIf vi_other_bank ='May(SINGAPORE)' then
        vi_other_bank := 'MY01';
    ELSIf vi_other_bank ='UOB' then
        vi_other_bank := 'UO01';
    ELSIf vi_other_bank ='DBS' then
        vi_other_bank := 'DB01';
    ELSIf vi_other_bank ='BKK' then
        vi_other_bank := 'BK03';
    ELSIf vi_other_bank ='OCBC' then
        vi_other_bank := 'OC01';
    ELSIf vi_other_bank ='SIAM' then
        vi_other_bank := 'SC03';
    ELSE 
        vi_other_bank := '' ;
    END IF;
    
     IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData (vi_TranDate, vi_other_bank );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  v_sol_id, v_AGD_BR_name, v_other_Br_name, v_payee_name,v_drawing_amt,v_open_date,v_tran_id;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractData%NOTFOUND THEN
          --{
            CLOSE ExtractData;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
        
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (     v_sol_id             || '|' ||
                    v_AGD_BR_name      || '|' ||
                    v_other_Br_name           || '|' ||
                    v_payee_name          || '|' ||
                    v_drawing_amt         || '|' ||
                    v_tran_id
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_ENCASH_CONSOL_SCHEDULE;

END FIN_ENCASH_CONSOL_SCHEDULE;
/
