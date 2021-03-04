CREATE OR REPLACE PACKAGE                                           FIN_CASH_INHAND_POSITION_ALL AS

PROCEDURE FIN_CASH_INHAND_POSITION_ALL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CASH_INHAND_POSITION_ALL;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                     FIN_CASH_INHAND_POSITION_ALL AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;      -- Input Parse Array
	v_TranDate		    Varchar2(10);		    	    -- Input to procedure
  v_Currency	   	Varchar2(7);
  v_cur_type	   	Varchar2(25); 
  resultrate varchar(2000);
  vi_rate decimal;
  v_ATMClose Number(20,2);
  TYPE cur_array IS TABLE OF tbaadm.cnc%ROWTYPE
        INDEX BY PLS_INTEGER;
  currency_array cur_array;
   
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData

-----------------------------------------------------------------------------
CURSOR ExtractData (	ci_TranDate VARCHAR2,ci_Currency VARCHAR2)
      IS
      SELECT  sot.SOL_DESC, 
        SUM(R.Valt),
        SUM(R.OpeningBalance), 
        SUM(R.Receive),
        SUM(R.Payment)
      FROM (
          SELECT q.sol as sol_id,0 as Valt,0 as OpeningBalance,sum(q.DR_amt) as Receive,sum(q.CR_amt)  as Payment
          FROM
          (
          SELECT  gsh.SOL_ID  as sol, 
          CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
          CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
           FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
           WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
           AND gsh.gl_sub_head_code = coa.gl_sub_head_code
           --and  coa.cur = gsh.gl_sub_head_code
           AND cdav.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           AND cdav.SOL_ID  like   '%' || '' || '%'
           AND gsh.SOL_ID  like   '%' || '' || '%'
           AND coa.cur= upper(ci_Currency)  
           --AND cdav.ref_crncy_code = upper('MMK')
           AND cdav.tran_crncy_code = upper(ci_Currency)
           AND gsh.crncy_code = upper(ci_Currency)
           --AND cdav.Tran_type = 'C'
           AND cdav.DEL_FLG = 'N' --
           AND gsh.SOL_ID = cdav.SOL_ID
           AND cdav.dth_init_sol_id like   '%' || '' || '%'
           AND cdav.pstd_date is not null
           AND coa.group_code not in ('A01','A02')
           --AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
         ) q group by q.sol, 0 
          /*SELECT q.dth_init_sol_id,0 as Valt,0 as OpeningBalance ,sum(q.DR_amt) as Receive,sum(q.CR_amt) as Payment 
          FROM
          (
          select  distinct cdav.tran_id,coa.group_code ,coa.description, cdav.dth_init_sol_id,
          case cdav.part_tran_type when 'C' then cdav.tran_amt else 0 end as CR_amt,
          case cdav.part_tran_type when 'D' then cdav.tran_amt else 0 end as DR_amt
           FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
           WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
           and gsh.gl_sub_head_code = coa.gl_sub_head_code
           and cdav.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           and cdav.ref_crncy_code = upper(ci_Currency)
           and cdav.tran_crncy_code = upper(ci_Currency)
           and gsh.crncy_code = upper(ci_Currency)
           and cdav.Tran_type = 'C'
           and cdav.DEL_FLG = 'N' --
           and cdav.dth_init_sol_id = cdav.sol_id
           and cdav.pstd_date is not null
           and coa.GROUP_CODE not in ('A01','A02','A03')
           and trim (cdav.tran_id) NOT IN (select CONT_TRAN_ID from TBAADM.ATD atd where atd.tran_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
           --and (gss.schm_code not like 'VAULT%') and (gss.schm_code not like 'TCASH%') and (gss.schm_code not like 'DDDD%')and (gss.schm_code not like 'DDGEN%')
           --and gss.GL_SUB_HEAD_CODE = gsh.GL_SUB_HEAD_CODE
           ) q
          group by q.dth_init_sol_id */
          
          UNION ALL
          
        SELECT    
          gstt.sol_id  as sol_id,0 as Valt,sum(gstt.tot_dr_bal-gstt.tot_cr_bal)as OpeningBalance ,0 as Receive,0 as Payment
        FROM 
           TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
        WHERE
         gstt.gl_sub_head_code = coa.gl_sub_head_code
           and gstt.CRNCY_CODE  = coa.cur
           and gstt.BAL_DATE <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) -1
           and gstt.End_Bal_Date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) -1
           and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
           and gstt.DEL_FLG = 'N' 
           and gstt.BANK_ID = '01'  
           and gstt.crncy_code = upper(ci_Currency)
           --and coa.cur= upper('MMK')
           and coa.group_code in ('A01','A02')
          group by gstt.sol_id
        
          )R ,TBAADM.SERVICE_OUTLET_TABLE sot
    WHERE sot.SOL_ID = R.sol_id
    GROUP BY sot.SOL_DESC
    order by sot.SOL_DESC
;
      
 CURSOR ExtractDataFCY (	ci_TranDate VARCHAR2)
      IS
      SELECT  sot.SOL_DESC, 
        SUM(T.Valt),
        SUM(T.OpeningBalance), 
        SUM(T.Receive),
        SUM(T.Payment)
    FROM (     
        SELECT t.sol_id as sol_id,0 as Valt,0 as OpeningBalance,sum(t.DR_amt) as Receive,sum(t.CR_amt)  as Payment
          FROM
          (
             SELECT q.sol as sol_id,
            CASE WHEN q.tran_crncy_code = 'MMK' THEN q.DR_amt
            ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.tran_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS DR_amt,
            CASE WHEN q.tran_crncy_code = 'MMK' THEN q.cR_amt 
            ELSE q.CR_amt * NVL( (SELECT  VAR_CRNCY_UNITS
                                        FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(q.tran_crncy_code) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                                        and RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                        WHERE module_name = 'FOREIGN_CURRENCY' 
                                        and variable_name = 'RATE_CODE')
                                        --order by rtlist_date desc) WHERE rownum = 1
                                        ),1) END AS CR_amt 
        FROM
          (
          SELECT   cdav.tran_id,coa.group_code, coa.description,dth_init_sol_id  as sol,cdav.tran_crncy_code ,
          CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
          CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
           FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
           WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
           AND gsh.gl_sub_head_code = coa.gl_sub_head_code
           --and  coa.cur = gsh.gl_sub_head_code
           AND cdav.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           AND cdav.SOL_ID  like   '%' || '' || '%'
           AND gsh.SOL_ID  like   '%' || '' || '%'
           AND coa.cur= cdav.tran_crncy_code  
           AND gsh.crncy_code = cdav.tran_crncy_code  
           AND coa.cur not like upper('MMK')  
           --AND cdav.ref_crncy_code = upper('MMK')
           AND cdav.tran_crncy_code not like upper('MMK')
           AND gsh.crncy_code not like upper('MMK')
           --AND cdav.Tran_type = 'C'
           AND cdav.DEL_FLG = 'N' --
           AND gsh.SOL_ID = cdav.SOL_ID
           AND cdav.dth_init_sol_id like   '%' || '' || '%'
           AND cdav.pstd_date is not null
           AND coa.group_code not in ('A01','A02')
          -- AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
         ) q 
         )t
         group by t.sol_id,0, 0
  
       
       UNION ALL
     
    SELECT P.SOL_ID,
           0 AS Valt,
           sum(P.OpeningBalance) as OpeningBalance,
           0 as Receive,
           0 as Payment
    FROM (
      select    
      gstt.sol_id ,
       CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
      ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),1) END   as OpeningBalance
              
    from 
       TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
    where
     gstt.gl_sub_head_code = coa.gl_sub_head_code
      and gstt.CRNCY_CODE = coa.CUR
       and gstt.BAL_DATE <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
       and gstt.End_Bal_Date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
       and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
       and gstt.DEL_FLG = 'N' 
       and gstt.BANK_ID = '01'
       --and gsh.crncy_code not like 'MMK'
       and gstt.crncy_code not like 'MMK'
       and coa.cur not like 'MMK'
       and coa.group_code in ('A01','A02')
       )P 
      GROUP BY P.SOL_ID
   )T,TBAADM.SERVICE_OUTLET_TABLE sot
 WHERE sot.SOL_ID = T.sol_id
 GROUP BY sot.SOL_DESC
  order by sot.SOL_DESC
  ;
  
  CURSOR ExtractDataALL (	ci_TranDate VARCHAR2)
      IS
      SELECT  sot.SOL_DESC, 
        SUM(T.Valt),
        SUM(T.OpeningBalance), 
        SUM(T.Receive),
        SUM(T.Payment)
FROM (          
       SELECT q.sol as sol_id,0 as Valt,0 as OpeningBalance,sum(q.DR_amt) as Receive,sum(q.CR_amt)  as Payment
          FROM
          (
          SELECT  dth_init_sol_id  as sol, 
          CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
          CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
           FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
           WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
           AND gsh.gl_sub_head_code = coa.gl_sub_head_code
           --and  coa.cur = gsh.gl_sub_head_code
           AND cdav.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           AND cdav.SOL_ID  like   '%' || '' || '%'
           AND gsh.SOL_ID  like   '%' || '' || '%'
           AND coa.cur= upper('MMK')  
           --AND cdav.ref_crncy_code = upper('MMK')
           AND cdav.tran_crncy_code = upper('MMK')
           AND gsh.crncy_code = upper('MMK')
          -- AND cdav.Tran_type = 'C'
           AND cdav.DEL_FLG = 'N' --
           AND gsh.SOL_ID = cdav.SOL_ID
           AND cdav.dth_init_sol_id like   '%' || '' || '%'
           AND cdav.pstd_date is not null
           AND coa.group_code not in ('A01','A02')
          -- AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
         ) q group by q.sol, 0 
         
         UNION ALL
             
        SELECT t.sol_id as sol_id,0 as Valt,0 as OpeningBalance,sum(t.DR_amt) as Receive,sum(t.CR_amt)  as Payment
          FROM
          (
             SELECT q.sol as sol_id,
            CASE WHEN q.tran_crncy_code = 'MMK' THEN q.DR_amt
            ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.tran_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS DR_amt,
            CASE WHEN q.tran_crncy_code = 'MMK' THEN q.cR_amt 
            ELSE q.CR_amt * NVL( (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.tran_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                                        ),1) END AS CR_amt 
        FROM
          (
          SELECT   cdav.tran_id,coa.group_code, coa.description,dth_init_sol_id  as sol,cdav.tran_crncy_code ,
          CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
          CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
           FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
           WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
           AND gsh.gl_sub_head_code = coa.gl_sub_head_code
           --and  coa.cur = gsh.gl_sub_head_code
           AND cdav.tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           AND cdav.SOL_ID  like   '%' || '' || '%'
           AND gsh.SOL_ID  like   '%' || '' || '%'
           AND coa.cur= cdav.tran_crncy_code  
           AND gsh.crncy_code = cdav.tran_crncy_code  
           AND coa.cur not like upper('MMK')  
           --AND cdav.ref_crncy_code = upper('MMK')
           AND cdav.tran_crncy_code not like upper('MMK')
           AND gsh.crncy_code not like upper('MMK')
           --AND cdav.Tran_type = 'C'
           AND cdav.DEL_FLG = 'N' --
           AND gsh.SOL_ID = cdav.SOL_ID
           AND cdav.dth_init_sol_id like   '%' || '' || '%'
           AND cdav.pstd_date is not null
           AND coa.group_code not in ('A01','A02')
          -- AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
         ) q 
         )t
         group by t.sol_id,0, 0
         
       UNION ALL
     
    SELECT P.SOL_ID,
           0 AS Valt,
           sum(P.OpeningBalance) as OpeningBalance,
           0 as Receive,
           0 as Payment
    FROM (
            select    
            gstt.sol_id ,
             CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
             ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),1) END   as OpeningBalance                   
          from 
             TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa--,tbaadm.gl_sub_head_table gsh,
          where
             gstt.gl_sub_head_code = coa.gl_sub_head_code
             and  gstt.crncy_code  =coa.cur
             and gstt.BAL_DATE <= TO_DATE( CAST (  ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
             and gstt.End_Bal_Date >= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
             and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
             and gstt.DEL_FLG = 'N' 
             and gstt.BANK_ID = '01'
             and coa.group_code  in ('A01','A02')
             )P 
      GROUP BY P.SOL_ID
  
   )T,TBAADM.SERVICE_OUTLET_TABLE sot
 WHERE sot.SOL_ID = T.sol_id
 GROUP BY sot.SOL_DESC
  order by sot.SOL_DESC
  ;
      
    
--------------------------------------------------------------------------------------
  PROCEDURE FIN_CASH_INHAND_POSITION_ALL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
        v_BranchName      TBAADM.SERVICE_OUTLET_TABLE.SOL_DESC%TYPE;
        v_Valt            NUMBER(20,2);
        v_OpeningBalance  NUMBER(20,2);
        v_Receive         NUMBER(20,2);
        v_Payment         NUMBER(20,2);
        v_ATMBranch      Varchar2(50);
        v_ATMValt         NUMBER(20,2);
        v_ATMOpening     NUMBER(20,2);
        v_ATMReceive     NUMBER(20,2);
        v_ATMPayment     NUMBER(20,2);
        
    
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

    v_TranDate  :=  outArr(0);		
    v_Currency  :=  outArr(1);		
    v_cur_type  :=  outArr(2);	
    
   begin
    IF  v_cur_type NOT LIKE 'All%'  then 
       SELECT E.sol_id as Sol_id,
       e.Valt,
       NVL(abs(SUM(e.OpeningBalance)),0),
       abs(sum(e.Receive)),
       abs(sum(e.Payment)),
       SUM(e.OpeningBalance) - sum(e.Receive)+ sum(e.Payment)  as aa
     --  ,NVL(SUM(e.OpeningBalance),0) - sum(e.Receive)+sum(e.Payment)
     into v_ATMBranch,v_ATMValt,v_ATMOpening,v_ATMReceive,v_ATMPayment,v_ATMClose
        FROM (
              SELECT  
                'Cash AT ATM'  as sol_id,
                  0 as Valt,
                  NVL(sum(gstt.tot_cr_bal-gstt.tot_dr_bal),0)as OpeningBalance ,
                  0 as Receive,
                  0 as Payment
                  
                FROM 
                   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                WHERE
                 gstt.gl_sub_head_code = coa.gl_sub_head_code
                   and gstt.CRNCY_CODE  = coa.cur
                   and gstt.BAL_DATE <= TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) -1
                   and gstt.End_Bal_Date >= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) -1
                   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
                   and gstt.DEL_FLG = 'N' 
                   and gstt.BANK_ID = '01'  
                   and gstt.crncy_code = upper(v_Currency)
                   and coa.group_code in ('A03')
                   
                   UNION ALL
                   
                   SELECT 'Cash AT ATM'  as sol_id,
                   0 as Valt,
                   0 as OpeningBalance,
                   sum(q.DR_amt) as Receive,
                   sum(q.CR_amt)  as Payment
                  FROM
                  (
                  SELECT  gsh.SOL_ID  as sol, 
                  CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
                  CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
                   FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
                   WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
                   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
                   --and  coa.cur = gsh.gl_sub_head_code
                   AND cdav.tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                   AND cdav.SOL_ID  like   '%' || '' || '%'
                   AND gsh.SOL_ID  like   '%' || '' || '%'
                   AND coa.cur= upper(v_Currency)  
                   --AND cdav.ref_crncy_code = upper('MMK')
                   AND cdav.tran_crncy_code = upper(v_Currency)
                   AND gsh.crncy_code = upper(v_Currency)
                   --AND cdav.Tran_type = 'C'
                   and coa.gl_sub_head_code = '10102'
                   AND cdav.DEL_FLG = 'N' --
                   AND gsh.SOL_ID = cdav.SOL_ID
                   AND cdav.dth_init_sol_id like   '%' || '' || '%'
                   AND cdav.pstd_date is not null
          
                   --AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
                 ) q group by q.sol, 0 
                )E
             group by e.sol_id,e.valt;
     
     
    ELSIF v_cur_type  LIKE 'All FCY%'  then 
          SELECT E.sol_id as Sol_id,
       e.Valt,
       NVL(SUM(e.OpeningBalance),0),
       sum(e.Receive),
       sum(e.Payment),
     SUM(e.OpeningBalance) - sum(e.Receive)+ sum(e.Payment)  as aa
     --  ,NVL(SUM(e.OpeningBalance),0) - sum(e.Receive)+sum(e.Payment)
     into v_ATMBranch,v_ATMValt,v_ATMOpening,v_ATMReceive,v_ATMPayment,v_ATMClose
        FROM (
              SELECT 'Cash AT ATM' as sol_id ,
                   0 AS Valt,
                   NVL(sum(P.OpeningBalance),0) as OpeningBalance,
                   0 as Receive,
                   0 as Payment
                  --into v_ATMBranch,v_ATMValt,v_ATMOpening,v_ATMReceive,v_ATMPayment
                  FROM (
                    select    
                    gstt.sol_id ,
                    CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
                    ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                              FROM TBAADM.RTH r
                                              where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                              and  r.RATECODE = 'NOR'
                                              and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                              and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                                    FROM TBAADM.RTH a
                                                                                    where 
                                                                                    a.RATECODE = 'NOR'
                                                                                    and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                                    and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                             FROM TBAADM.RTH a
                                                                                                             where a.Rtlist_date <= TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                             and  a.RATECODE = 'NOR'                                                                                             
                                                                                                             and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                             )
                                                                                    and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                     group by a.fxd_crncy_code)
                                                ),1) END   as OpeningBalance
                            
                  from 
                     TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  where
                   gstt.gl_sub_head_code = coa.gl_sub_head_code
                    and gstt.CRNCY_CODE = coa.CUR
                     and gstt.BAL_DATE <= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                     and gstt.End_Bal_Date >= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                     and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
                     and gstt.DEL_FLG = 'N' 
                     and gstt.BANK_ID = '01'
                     --and gsh.crncy_code not like 'MMK'
                     and gstt.crncy_code not like 'MMK'
                     and coa.cur not like 'MMK'
                     and coa.group_code in ('A03')
                     )P 
                     
                   UNION ALL
                   
                   SELECT t.sol_id as sol_id,
                   0 as Valt,
                   0 as OpeningBalance,
                   sum(t.DR_amt) as Receive,
                   sum(t.CR_amt)  as Payment
                  FROM
                  (
                   SELECT 'Cash AT ATM'  as sol_id,
                    CASE WHEN q.tran_crncy_code = 'MMK' THEN q.DR_amt
                    ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                        FROM TBAADM.RTH r
                                        where trim(r.fxd_crncy_code) = trim(q.tran_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                        and  r.RATECODE = 'NOR'
                                        and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                        and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                              FROM TBAADM.RTH a
                                                                              where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                              and  a.RATECODE = 'NOR'
                                                                              and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                              group by a.fxd_crncy_code
                                            )
                                                ),1) END AS DR_amt,
                    CASE WHEN q.tran_crncy_code = 'MMK' THEN q.cR_amt 
                    ELSE q.CR_amt * NVL( (SELECT  VAR_CRNCY_UNITS
                                                FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(q.tran_crncy_code) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                                                and RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                                WHERE module_name = 'FOREIGN_CURRENCY' 
                                                and variable_name = 'RATE_CODE')
                                                --order by rtlist_date desc) WHERE rownum = 1
                                                ),1) END AS CR_amt 
                FROM
                  (
                  SELECT   cdav.tran_id,coa.group_code, coa.description,dth_init_sol_id  as sol,cdav.tran_crncy_code ,
                  CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
                  CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
                   FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
                   WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
                   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
                   --and  coa.cur = gsh.gl_sub_head_code
                   AND cdav.tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                   AND cdav.SOL_ID  like   '%' || '' || '%'
                   AND gsh.SOL_ID  like   '%' || '' || '%'
                   AND coa.cur= cdav.tran_crncy_code  
                   AND gsh.crncy_code = cdav.tran_crncy_code  
                   AND coa.cur not like upper('MMK')  
                   and coa.gl_sub_head_code = '10102'
                   AND cdav.tran_crncy_code not like upper('MMK')
                   AND gsh.crncy_code not like upper('MMK')
                   --AND cdav.Tran_type = 'C'
                   AND cdav.DEL_FLG = 'N' --
                   AND gsh.SOL_ID = cdav.SOL_ID
                   AND cdav.dth_init_sol_id like   '%' || '' || '%'
                   AND cdav.pstd_date is not null
                  -- AND coa.group_code not in ('A01','A02','A03')
                  -- AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
                 ) q 
                 )t
                 group by t.sol_id,0, 0
                 
                )E
             group by e.sol_id,e.valt;
             
    ELSE
      SELECT E.sol_id as Sol_id,
       e.Valt,
       NVL(SUM(e.OpeningBalance),0),
       sum(e.Receive),
       sum(e.Payment),
       SUM(e.OpeningBalance) - sum(e.Receive)+ sum(e.Payment)  as aa
     --  ,NVL(SUM(e.OpeningBalance),0) - sum(e.Receive)+sum(e.Payment)
     into v_ATMBranch,v_ATMValt,v_ATMOpening,v_ATMReceive,v_ATMPayment,v_ATMClose
        FROM (
              SELECT 'Cash AT ATM' as sol_id ,
                   0 AS Valt,
                   NVL(sum(P.OpeningBalance),0) as OpeningBalance,
                   0 as Receive,
                   0 as Payment
                  --into v_ATMBranch,v_ATMValt,v_ATMOpening,v_ATMReceive,v_ATMPayment
                  FROM (
                    select    
                    gstt.sol_id ,
                    CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_cr_bal-gstt.tot_dr_bal)
                    ELSE (gstt.tot_cr_bal-gstt.tot_dr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                              FROM TBAADM.RTH r
                                              where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                              and  r.RATECODE = 'NOR'
                                              and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                              and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                                    FROM TBAADM.RTH a
                                                                                    where 
                                                                                    a.RATECODE = 'NOR'
                                                                                    and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                                    and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                             FROM TBAADM.RTH a
                                                                                                             where a.Rtlist_date <= TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                                                                                             and  a.RATECODE = 'NOR'                                                                                             
                                                                                                             and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                             )
                                                                                    and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                     group by a.fxd_crncy_code)
                                                ),1) END   as OpeningBalance
                            
                  from 
                     TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
                  where
                   gstt.gl_sub_head_code = coa.gl_sub_head_code
                    and gstt.CRNCY_CODE = coa.CUR
                     and gstt.BAL_DATE <= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                     and gstt.End_Bal_Date >= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                     and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
                     and gstt.DEL_FLG = 'N' 
                     and gstt.BANK_ID = '01'
                     and coa.group_code in ('A03')
                     )P 
                     
                   UNION ALL
                   
                   SELECT t.sol_id as sol_id,
                   0 as Valt,
                   0 as OpeningBalance,
                   sum(t.DR_amt) as Receive,
                   sum(t.CR_amt)  as Payment
                  FROM
                  (
                   SELECT 'Cash AT ATM'  as sol_id,
                    CASE WHEN q.tran_crncy_code = 'MMK' THEN q.DR_amt
                    ELSE q.DR_amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                        FROM TBAADM.RTH r
                                        where trim(r.fxd_crncy_code) = trim(q.tran_crncy_code) and r.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                        and  r.RATECODE = 'NOR'
                                        and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                        and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                              FROM TBAADM.RTH a
                                                                              where a.Rtlist_date = TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                              and  a.RATECODE = 'NOR'
                                                                              and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                              group by a.fxd_crncy_code
                                            )
                                                ),1) END AS DR_amt,
                    CASE WHEN q.tran_crncy_code = 'MMK' THEN q.cR_amt 
                    ELSE q.CR_amt * NVL( (SELECT  VAR_CRNCY_UNITS
                                                FROM tbaadm.RTL  e WHERE TRIM(FXD_CRNCY_CODE) = upper(q.tran_crncy_code) and TRIM(VAR_CRNCY_CODE) = 'MMK' 
                                                and RATECODE = (SELECT variable_value FROM custom.CUST_GENCUST_PARAM_MAINT 
                                                WHERE module_name = 'FOREIGN_CURRENCY' 
                                                and variable_name = 'RATE_CODE')
                                                --order by rtlist_date desc) WHERE rownum = 1
                                                ),1) END AS CR_amt 
                FROM
                  (
                  SELECT   cdav.tran_id,coa.group_code, coa.description,dth_init_sol_id  as sol,cdav.tran_crncy_code ,
                  CASE cdav.part_tran_type when 'C' then cdav.tran_amt ELSE 0 END as CR_amt,
                  CASE cdav.part_tran_type when 'D' then cdav.tran_amt ELSE 0 END as DR_amt
                   FROM custom.custom_ctd_dtd_acli_view cdav,tbaadm.gsh ,custom.coa_mp coa 
                   WHERE cdav.gl_sub_head_code = gsh.gl_sub_head_code
                   AND gsh.gl_sub_head_code = coa.gl_sub_head_code
                   --and  coa.cur = gsh.gl_sub_head_code
                   AND cdav.tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                   AND cdav.SOL_ID  like   '%' || '' || '%'
                   AND gsh.SOL_ID  like   '%' || '' || '%'
                   AND coa.cur= cdav.tran_crncy_code  
                   AND gsh.crncy_code = cdav.tran_crncy_code  
                   and coa.gl_sub_head_code = '10102'
                   --AND cdav.Tran_type = 'C'
                   AND cdav.DEL_FLG = 'N' --
                   AND gsh.SOL_ID = cdav.SOL_ID
                   AND cdav.dth_init_sol_id like   '%' || '' || '%'
                   AND cdav.pstd_date is not null
                  -- AND coa.group_code not in ('A01','A02','A03')
                  -- AND trim (cdav.tran_id) NOT IN (SELECT trim(CONT_TRAN_ID) FROM TBAADM.ATD atd WHERE atd.cont_tran_date = TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
                 ) q 
                 )t
                 group by t.sol_id,0, 0
                 
                )E
             group by e.sol_id,e.valt;
    END IF;
  END; 
 /*---other    
    begin
    IF  v_cur_type NOT LIKE 'All%'  then 
       SELECT    
          --'Cash AT ATM'  as sol_id,0 as Valt,
          NVL(sum(gstt.tot_dr_bal-gstt.tot_cr_bal),0)as OpeningBalance 
          --0 as Receive,
          --0 as Payment
          into v_ATMClose
        FROM 
           TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
        WHERE
         gstt.gl_sub_head_code = coa.gl_sub_head_code
           and gstt.CRNCY_CODE  = coa.cur
           and gstt.BAL_DATE <= TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           and gstt.End_Bal_Date >= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
           and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
           and gstt.DEL_FLG = 'N' 
           and gstt.BANK_ID = '01'  
           and gstt.crncy_code = upper(v_Currency)
           and coa.group_code in ('A03');
    ELSIF v_cur_type  LIKE 'All FCY%'  then 
           SELECT --'Cash AT ATM',
          -- 0 AS Valt,
           NVL(sum(P.OpeningBalance),0) as OpeningBalance
          -- 0 as Receive,
          -- 0 as Payment
           into v_ATMClose
          FROM (
            select    
            gstt.sol_id ,
            CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
            ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                      FROM TBAADM.RTH r
                                      where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                      and  r.RATECODE = 'NOR'
                                      and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                      and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                            FROM TBAADM.RTH a
                                                                            where 
                                                                            a.RATECODE = 'NOR'
                                                                            and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                            and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                                     FROM TBAADM.RTH a
                                                                                                     where a.Rtlist_date <= TO_DATE( CAST (  v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                                     and  a.RATECODE = 'NOR'                                                                                             
                                                                                                     and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                                     )
                                                                            and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                             group by a.fxd_crncy_code)
                                        ),1) END   as OpeningBalance
                    
          from 
             TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
          where
           gstt.gl_sub_head_code = coa.gl_sub_head_code
            and gstt.CRNCY_CODE = coa.CUR
             and gstt.BAL_DATE <= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
             and gstt.End_Bal_Date >= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
             and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
             and gstt.DEL_FLG = 'N' 
             and gstt.BANK_ID = '01'
             --and gsh.crncy_code not like 'MMK'
             and gstt.crncy_code not like 'MMK'
             and coa.cur not like 'MMK'
             and coa.group_code in ('A03')
             )P 
    ;
    ELSE
      SELECT --'Cash AT ATM',
           --- AS Valt,
           NVL(sum(P.OpeningBalance),0) as OpeningBalance
           --0 as Receive,
           --0 as Payment
           into v_ATMClose
    FROM (
            select    
            gstt.sol_id ,
            CASE WHEN  gstt.CRNCY_CODE = 'MMK' THEN (gstt.tot_dr_bal-gstt.tot_cr_bal)
             ELSE (gstt.tot_dr_bal-gstt.tot_cr_bal) * NVL( ( SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where r.fxd_crncy_code = Upper(gstt.CRNCY_CODE) --and r.Rtlist_date = TO_DATE( CAST (  '24-04-2017' AS VARCHAR(10) ) , 'dd-MM-yyyy' )-1
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, Rtlist_date,r.Rtlist_num) in (SELECT a.fxd_crncy_code,max(a.Rtlist_date),max(a.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where 
                                                                      a.RATECODE = 'NOR'
                                                                      and  a.fxd_crncy_code =  Upper(gstt.CRNCY_CODE)
                                                                      and  (a.Rtlist_date) in (SELECT max(a.Rtlist_date)
                                                                                               FROM TBAADM.RTH a
                                                                                               where a.Rtlist_date <= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                               and  a.RATECODE = 'NOR'                                                                                             
                                                                                               and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                                               )
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                       group by a.fxd_crncy_code)
                                  ),1) END   as OpeningBalance
                    
          from 
             TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa--,tbaadm.gl_sub_head_table gsh,
          where
             gstt.gl_sub_head_code = coa.gl_sub_head_code
             and  gstt.crncy_code  =coa.cur
             and gstt.BAL_DATE <= TO_DATE( CAST ( v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
             and gstt.End_Bal_Date >= TO_DATE( CAST (v_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
             and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
             and gstt.DEL_FLG = 'N' 
             and gstt.BANK_ID = '01'
             and coa.group_code  in ('A03')
             )P ;
    END IF;
  END; 
  */
      IF  v_cur_type NOT LIKE 'All%'  then 
        --{
          IF NOT ExtractData%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractData (	
            v_TranDate , v_Currency  );
            --}
            END;
      
          --}
          END IF;
          
          IF ExtractData%ISOPEN THEN
          --{
          
            FETCH	ExtractData
            INTO	 v_BranchName,v_Valt,v_OpeningBalance,v_Payment,v_Receive;
            
      
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
   
    ELSIF v_cur_type  LIKE 'All FCY%'  then 
      --{
          IF NOT ExtractDataFCY%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataFCY (	
            v_TranDate  );
            --}
            END;
      
          --}
          END IF;
          
          IF ExtractDataFCY%ISOPEN THEN
          --{
          
            FETCH	ExtractDataFCY
            INTO	 v_BranchName,v_Valt,v_OpeningBalance,v_Payment,v_Receive;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataFCY%NOTFOUND THEN
            --{
              CLOSE ExtractDataFCY;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
    
    ELSE 
           --{
          IF NOT ExtractDataAll%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataAll (	
            v_TranDate  );
            --}
            END;
      
          --}
          END IF;
          
          IF ExtractDataAll%ISOPEN THEN
          --{
          
            FETCH	ExtractDataAll
            INTO	 v_BranchName,v_Valt,v_OpeningBalance,v_Payment,v_Receive;
            
      
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataAll%NOTFOUND THEN
            --{
              CLOSE ExtractDataAll;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;
          --}
          END IF;
        --}
      END IF;
        ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    if v_cur_type = 'Home Currency' then
      if(upper(v_Currency) = 'MMK') then vi_rate := 1;  
      else select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(v_TranDate, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(v_Currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
      end if;
    else 
     vi_rate := 1;
    end if;
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
          v_BranchName     		    	|| '|' ||
					v_Valt	                  || '|' ||
          v_OpeningBalance          || '|' ||
					v_Receive      			      || '|' ||
          v_Payment                 || '|' ||
          vi_rate                   || '|' ||
          v_ATMBranch               || '|' ||
          v_ATMValt                 || '|' ||
          v_ATMOpening              || '|' ||
          v_ATMReceive              || '|' ||
          v_ATMPayment              || '|' ||
          v_ATMClose
          );
  
			dbms_output.put_line(out_rec);
      
  END FIN_CASH_INHAND_POSITION_ALL;

END FIN_CASH_INHAND_POSITION_ALL;
/
