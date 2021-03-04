CREATE OR REPLACE PACKAGE FIN_GL_CODE_BALANCE AS 

  PROCEDURE FIN_GL_CODE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_GL_CODE_BALANCE;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_GL_CODE_BALANCE AS

-----------------------------------------------------------------------
--Update User - Yin Win Phyu
--Update Date - 23/3/2017
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
	vi_acct_id		Varchar2(100);		    	     -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractDataTodayDate(ci_acct_id Varchar2) IS
select distinct T.foracid,T.acct_name,T.Gl_code,T.sol_desc,T.cur,T.Balance, T.MMKRateBlance,T.rate
from
(select q.foracid,q.acct_name,q.Gl_code,q.sol_desc,q.cur,q.Balance,
       CASE WHEN q.cur = 'MMK'  THEN q.Balance
      when  q.Gl_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
      when  q.Gl_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.Gl_code = '60161' and  q.Balance ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.Gl_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.Gl_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.Gl_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                --and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where --a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      --and  
                                                                      a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS MMKRateBlance,
      (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                --and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where --a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      --and 
                                                                      a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ) as rate
from 
(select  gam.foracid, gam.acct_name,
gam.gl_sub_head_code as Gl_code ,
--(select sol.sol_desc from tbaadm.sol where sol.sol_id =gam.sol_id ) as sol_desc,
sol.sol_desc as sol_desc ,
gam.acct_crncy_code as cur,
gam.clr_bal_amt as Balance
from tbaadm.gam gam ,Custom.coa_mp coa ,tbaadm.sol sol
where
coa.gl_sub_head_code = gam.gl_sub_head_code
and sol.sol_id =gam.sol_id
and gam.acct_crncy_code = coa.cur
and coa.group_code like '%' ||ci_acct_id || '%'
and gam.del_flg ='N'
--and gam.acct_cls_flg = 'N'
and gam.bank_id ='01'
and sol.del_flg ='N'
and sol.bank_id ='01'
order by gam.foracid)q
order by q.foracid)T
order by T.foracid;

-----------------------------------------------------------------------------------------------------------------------------------------
Cursor ExtractDataBackDate(ci_TranDate Varchar2 ,ci_acct_id Varchar2)
IS
SELECT T.foracid,
  T.acct_name,
  T.Gl_code,
  T.sol_desc,
  T.cur,
  T.Balance,
  T.MMKRateBlance,
  T.rate
FROM
  (SELECT q.foracid,
    q.acct_name,
    q.Gl_code ,
    q.sol_desc,
    q.cur,
    q.Balance,
    CASE WHEN q.cur = 'MMK'  THEN q.Balance
      when  q.gl_sub_head_code = '70002' and  q.Balance <> 0 THEN TO_NUMBER('4138000000')
      when  q.gl_sub_head_code = '60161' and  q.Balance ='18282678.36' and q.cur = 'USD' THEN TO_NUMBER('27479877212.88')
      when  q.gl_sub_head_code = '60161' and  q.Balance ='1259531.25' and q.cur= 'EUR' THEN TO_NUMBER('1825060781.25')
      when  q.gl_sub_head_code = '60161' and  q.Balance ='653408.19' and q.cur = 'SGD' THEN TO_NUMBER('633152536.11')
      when  q.gl_sub_head_code = '60161' and  q.Balance ='874441.97' and q.cur = 'THB' THEN TO_NUMBER('34103236.83')
      when  q.gl_sub_head_code = '60161' and  q.Balance ='29894' and q.cur = 'JPY' THEN TO_NUMBER('367397.26')
      ELSE q.Balance * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS MMKRateBlance,
    (SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) 
                                and r.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date =TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ) AS rate
  FROM
    (SELECT  gam.foracid,
              gam.acct_name,
              gam.gl_sub_head_code as Gl_code,
             (SELECT sol.sol_desc FROM tbaadm.sol WHERE sol.sol_id =gam.sol_id )               AS sol_desc,
              eab.eab_crncy_code               AS cur,
              (eab.tran_date_bal) AS Balance,gam.sol_id,gam.gl_sub_head_code,eab.eod_date
            FROM tbaadm.gam gam,
              tbaadm.eab eab,
              custom.coa_mp coa
           
            WHERE gam.acid = eab.acid
            and coa.gl_sub_head_code = gam.gl_sub_head_code
            and coa.cur = gam.acct_crncy_code
            and eab.eab_crncy_code = gam.acct_crncy_code
            AND eab.eod_date         <= TO_DATE( CAST ( ci_TranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND eab.END_eod_DATE     >=TO_DATE( CAST ( ci_TranDate AS  VARCHAR(10) ) , 'dd-MM-yyyy' )
            AND coa.group_code like '%' ||ci_acct_id || '%'
            and gam.del_flg ='N'            AND gam.bank_id            ='01'
            AND eab.bank_id           = '01'    --and gam.acct_cls_flg = 'N'           
                )q
  ORDER BY q.foracid
  )T
ORDER BY T.foracid;



-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_GL_CODE_BALANCE(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    v_foracid  tbaadm.gam.foracid%type;
    v_acct_name tbaadm.gam.acct_name%type;
    v_gl_sub_head_code tbaadm.gam.gl_sub_head_code%type;
    v_sol_id tbaadm.gam.sol_id%type;
    v_sol_desc tbaadm.sol.sol_desc%type;
    v_cur custom.coa_mp.cur%type;
    v_balance tbaadm.gam.clr_bal_amt%type;
    v_MMKBalance tbaadm.gam.clr_bal_amt%type;
    v_rate tbaadm.RTL.VAR_CRNCY_UNITS%type;
    sdate tbaadm.SOL_GROUP_CONTROL_TABLE.Db_Stat_Date%type;
    v_Date_Flg TBAADM.GENERAL_ACCT_MAST_TABLE.del_flg%type;
     
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
   --  vi_TranDate := outArr(0);
   vi_TranDate := outArr(0);
     vi_acct_id := outArr(1);
     
     -----------------------------------------------------------------
     if(vi_TranDate  is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
     ------------------------------------------------------------
    IF vi_acct_id IS  NULL or vi_acct_id = ''  THEN
         vi_acct_id := '';
    END IF;
     -------------------------------------------------------------------
   select Db_Stat_Date into sdate from tbaadm.SOL_GROUP_CONTROL_TABLE where sol_group_id = '01';
    if( TO_DATE( sysdate, 'dd-MM-yyyy' ) = TO_DATE( vi_TranDate, 'dd-MM-yyyy' ) ) then
        v_Date_Flg := 'Y';
    else 
        v_Date_Flg := 'N';
    end if;  
 -----------------------------------------------------------------------------------------------------------    
    IF(v_Date_Flg = 'Y') THEN
     IF NOT ExtractDataTodayDate%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractDataTodayDate ( vi_acct_id );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataTodayDate%ISOPEN THEN
        --{
          FETCH	ExtractDataTodayDate
          INTO  v_foracid, v_acct_name,v_gl_sub_head_code, v_sol_desc, v_cur,v_balance,v_MMKBalance,v_rate;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataTodayDate%NOTFOUND THEN
          --{
            CLOSE ExtractDataTodayDate;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
----------------------------------------------------------------------------------
ELSE

IF NOT ExtractDataBackDate%ISOPEN THEN  --forbackdate
        --{
          BEGIN
          --{
            OPEN ExtractDataBackDate (vi_TranDate, vi_acct_id );
          --}      
          END;
        --}
        END IF;
      
        IF ExtractDataBackDate%ISOPEN THEN
        --{
          FETCH	ExtractDataBackDate
          INTO  v_foracid, v_acct_name,v_gl_sub_head_code,v_sol_desc, v_cur,v_balance,v_MMKBalance,v_rate;
      ------------------------------------------------------------------------------
          -- Here it is checked whether the cursor has fetched
          -- something or not if not the cursor is closed
          -- and the out ret code is made equal to 1
      ------------------------------------------------------------------------------
          IF ExtractDataBackDate%NOTFOUND THEN
          --{
            CLOSE ExtractDataBackDate;
            out_retCode:= 1;
            RETURN;
          --}
          END IF;
        --}
        END IF;
     --}
        END IF;    
 
        
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------

    out_rec:= (     trim(v_foracid) || '|' ||
                    v_acct_name|| '|' ||
                    v_gl_sub_head_code || '|' ||
                    v_sol_desc|| '|' ||
                    v_cur|| '|' ||
                    v_balance|| '|' ||
                    v_MMKBalance || '|' ||
                    v_rate
                    
               ); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_GL_CODE_BALANCE;

END FIN_GL_CODE_BALANCE;
/
