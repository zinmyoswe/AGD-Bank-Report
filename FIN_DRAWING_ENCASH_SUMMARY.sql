CREATE OR REPLACE PACKAGE        FIN_DRAWING_ENCASH_SUMMARY AS 
PROCEDURE FIN_DRAWING_ENCASH_SUMMARY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DRAWING_ENCASH_SUMMARY;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                 FIN_DRAWING_ENCASH_SUMMARY AS

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
select T.Drawing_id,
        T.Encash_id,
        T.dth_init_sol_id,
        T.sol_desc,
        T.Drawing_Amount,
        T.Encash_Amount,
        T.Commission_Amount
        
  from
(select count(q.Drawing_id) as Drawing_id,
       count(q.Encash_id) as Encash_id,
      q.dth_init_sol_id ,
      q.sol_desc ,
      sum(q.Drawing_amt) as Drawing_Amount ,
      sum(q.Encash_amt) as Encash_Amount,
      q.br_open_date,
      sum(q.Commission) as Commission_Amount
from 
 (select 
      case when ctd.tran_sub_type = 'RI' then ctd.tran_id else '' end as Drawing_id,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI' then ctd.tran_id else '' end as Encash_id,
      ctd.dth_init_sol_id ,
      sol.sol_desc ,
      case when ctd.tran_sub_type = 'RI' then ctd.tran_amt else 0 end as Drawing_amt,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI' then ctd.tran_amt else 0 end as Encash_amt,
     sol.br_open_date,
     0 as Commission
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol
where
   ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and  ctd.rpt_code in ('IBREM','REMIT','REMIB')
    and ctd.bank_code = ci_other_bank
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.dth_init_sol_id != '20300'
    and ctd.dth_init_sol_id = sol.sol_id  --   AG7345
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
   and trim(ctd.tran_id) not in (  select trim(cxl.chrg_tran_id) from tbaadm.cxl cxl , CUSTOM.custom_ctd_dtd_acli_view ctd 
                                   where cxl.chrg_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                   and trim(cxl.CHRG_TRAN_ID)  = trim(ctd.TRAN_ID)
                                  AND cxl.CHRG_TRAN_DATE = ctd.TRAN_DATE
                                  and ctd.tran_sub_type = 'RI') 
  and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
union 
   select 
      case when ctd.tran_sub_type = 'RI' then ctd.tran_id else '' end as Drawing_id,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI' then ctd.tran_id else '' end as Encash_id,
      ctd.dth_init_sol_id ,
      sol.sol_desc ,
      case when ctd.tran_sub_type = 'RI' then ctd.tran_amt else 0 end as Drawing_amt,
      case when ctd.tran_sub_type = 'BI' or ctd.tran_sub_type = 'CI' then ctd.tran_amt else 0 end as Encash_amt,
     sol.br_open_date,
     cxl.ACTUAL_AMT_COLL as Commission
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol,tbaadm.cxl cxl
where
   ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and  ctd.rpt_code in ('IBREM','REMIT','REMIB')
    and ctd.bank_code = ci_other_bank
    --and CXL.CHRG_RPT_CODE  = 'COMCH' 
    AND trim(cxl.CHRG_TRAN_ID)  = trim(ctd.TRAN_ID)
    AND cxl.CHRG_TRAN_DATE = ctd.TRAN_DATE
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ((ctd.branch_code = cxl.event_id and cxl.chrg_rpt_code='COMCH')or cxl.event_id = 'ZERO')
    and cxl.chrg_acid in (select acid from tbaadm.gam where gam.sol_id ='10100')
    and ctd.dth_init_sol_id != '20300'
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
    and ctd.dth_init_sol_id = sol.sol_id
    and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ))q
   group by q.br_open_date,q.dth_init_sol_id,q.sol_desc 
  order by q.br_open_date,q.dth_init_sol_id)T
  union all
 select T.Drawing_id,
        T.Encash_id,
        T.dth_init_sol_id,
        T.sol_desc,
        T.Drawing_Amount,
        T.Encash_Amount,
        T.Commission_Amount
        
  from
(select count(q.Drawing_id) as Drawing_id,
       count(q.Encash_id) as Encash_id,
      q.dth_init_sol_id ,
      q.sol_desc ,
      sum(q.Drawing_amt) as Drawing_Amount ,
      sum(q.Encash_amt) as Encash_Amount,
      q.br_open_date,
      sum(q.Commission) as Commission_Amount
from 
 (select 
      case when ctd.part_tran_type='C'  then ctd.tran_id else '' end as Drawing_id,
      case when ctd.part_tran_type='D'  then ctd.tran_id else '' end as Encash_id,
      ctd.dth_init_sol_id ,
      sol.sol_desc ,
      case when ctd.part_tran_type='C' then ctd.tran_amt else 0 end as Drawing_amt,
      case when ctd.part_tran_type='D'  then ctd.tran_amt else 0 end  as Encash_amt,
     sol.br_open_date,
     0 as Commission
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol
where
   ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and  ctd.rpt_code in ('IBREM','REMIT','REMIB')
    and ctd.bank_code = ci_other_bank
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ctd.dth_init_sol_id = '20300'
    and ctd.dth_init_sol_id = sol.sol_id  --   AG7345
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
   and trim(ctd.tran_id) not in (  select trim(cxl.chrg_tran_id) from tbaadm.cxl cxl , CUSTOM.custom_ctd_dtd_acli_view ctd 
                                   where cxl.chrg_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                   and trim(cxl.CHRG_TRAN_ID)  = trim(ctd.TRAN_ID)
                                  AND cxl.CHRG_TRAN_DATE = ctd.TRAN_DATE
                                  and (ctd.tran_sub_type = 'RI')) 
  and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )
union 
   select 
      case when ctd.part_tran_type='C'  then ctd.tran_id else '' end as Drawing_id,
      case when ctd.part_tran_type='D'  then ctd.tran_id else '' end as Encash_id,
      ctd.dth_init_sol_id ,
      sol.sol_desc ,
      case when ctd.part_tran_type='C' then ctd.tran_amt else 0 end as Drawing_amt,
      case when ctd.part_tran_type='D'  then ctd.tran_amt else 0 end as Encash_amt,
     sol.br_open_date,
     cxl.ACTUAL_AMT_COLL as Commission
from 
    CUSTOM.custom_ctd_dtd_acli_view ctd, tbaadm.bct bct,tbaadm.sol sol,tbaadm.cxl cxl
where
   ctd.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    and  ctd.rpt_code in ('IBREM','REMIT','REMIB')
    and ctd.bank_code = ci_other_bank
    --and (CXL.CHRG_RPT_CODE  = 'COMCH'  or CXL.CHRG_RPT_CODE  !='TXLCG' or CXL.CHRG_RPT_CODE  is null)
    AND trim(cxl.CHRG_TRAN_ID)  = trim(ctd.TRAN_ID)
    AND cxl.CHRG_TRAN_DATE = ctd.TRAN_DATE
    and bct.bank_code = ctd.bank_code
    and bct.br_code = ctd.branch_code
    and ((ctd.branch_code = cxl.event_id and cxl.chrg_rpt_code='COMCH') or cxl.event_id = 'ZERO')
    and cxl.chrg_acid in (select acid from tbaadm.gam where gam.sol_id ='10100')
    --and cxl.srl_num= '3'
    and ctd.dth_init_sol_id = '20300'
    and ctd.dth_init_sol_id = sol.sol_id
    and ctd.uad_module_key is not null
   and ctd.uad_module_id is not null
    and trim (ctd.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
        where atd.cont_tran_date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and atd.cont_tran_date <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ))q
   group by q.br_open_date,q.dth_init_sol_id,q.sol_desc 
  order by q.br_open_date,q.dth_init_sol_id)T ;

  PROCEDURE FIN_DRAWING_ENCASH_SUMMARY(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_drawing_Count CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_Encash_Count CUSTOM.custom_ctd_dtd_acli_view.tran_id%type;
    v_sol_id  tbaadm.sol.sol_id%type;
    v_AGD_BR_name tbaadm.sol.sol_desc%type;
    v_drawing_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_Encash_amt CUSTOM.custom_ctd_dtd_acli_view.tran_amt%type;
    v_Commission TBAADM.CXL.ACTUAL_AMT_COLL%type;
     
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
     -----------------------------------------------------------------------------
     
     if( vi_TranDate is null or vi_other_bank is null) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || 0 || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 || '|' || 0);
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
     
     ---------------------------------------------------------------------------------
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
          INTO  v_drawing_Count, v_Encash_Count, v_sol_id, v_AGD_BR_name,v_drawing_amt,v_Encash_amt,v_Commission;
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

    out_rec:= (    
                   v_drawing_Count || '|' ||
                   v_Encash_Count || '|' || 
                   v_sol_id || '|' ||
                   v_AGD_BR_name|| '|' ||
                   v_drawing_amt|| '|' ||
                   v_Encash_amt   || '|' || 
                   v_Commission
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_DRAWING_ENCASH_SUMMARY;

END FIN_DRAWING_ENCASH_SUMMARY;
/
