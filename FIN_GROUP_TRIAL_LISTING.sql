CREATE OR REPLACE PACKAGE               FIN_GROUP_TRIAL_LISTING AS

 PROCEDURE FIN_GROUP_TRIAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_GROUP_TRIAL_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                          FIN_GROUP_TRIAL_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------

  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_EOD_DATE	   	Varchar2(10);               -- Input to procedure
  vi_SOL_ID		Varchar2(5);		    	    -- Input to procedure
  vi_cur		Varchar2(3);		    	    -- Input to procedure
  vi_cur_type		Varchar2(20);		    	    -- Input to procedure
  sdate date;
  rate decimal(18,2);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------

CURSOR ExtractDataForToday (ci_EOD_DATE VARCHAR2, ci_SOL_ID VARCHAR2, ci_cur VARCHAR2) IS
 select
   gam.GL_SUB_HEAD_CODE as "Account Code" ,
   gam.ACCT_NAME as "Account Name",
   gam.clr_bal_amt as "Bal"
from
   TBAADM.GENERAL_ACCT_MAST_TABLE gam
where
   gam.LAST_MODIFIED_DATE = TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and gam.DEL_FLG = 'N'
   and gam.BANK_ID = '01'
   and gam.acct_crncy_code = upper(ci_cur)
   and gam.acct_cls_flg = 'N'
   and gam.schm_type in ('OAB','OAP','OAD')
   and (gam.gl_sub_head_code not like '5%' or gam.gl_sub_head_code not like '4%');

CURSOR ExtractData (	ci_EOD_DATE VARCHAR2, ci_SOL_ID VARCHAR2, ci_cur VARCHAR2)IS
select
   q.group_code as "Account Code" ,
   q.description as "Account Name",
   sum(q.tot_cr_bal) as "CBal" ,
   sum(q.tot_dr_bal) as "DBal"
from(
select
   coa.group_code,
   coa.description,
   /*CASE WHEN gstt.crncy_code = 'MMK'  THEN gstt.tot_dr_bal
  when  gstt.gl_sub_head_code = '70002' and  gstt.tot_dr_bal <> 0 THEN TO_NUMBER('4138000000')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_dr_bal ='15089438.9599998' and gstt.crncy_code = 'USD' THEN TO_NUMBER('23223815863.52')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_dr_bal ='1438192.92' and gstt.crncy_code = 'EUR' THEN TO_NUMBER('2106952627.8')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_dr_bal ='549914.189999998' and gstt.crncy_code = 'SGD' THEN TO_NUMBER('536166335.249998')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_dr_bal ='1245739.91999999' and gstt.crncy_code = 'THB' THEN TO_NUMBER('48583856.8799995')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_dr_bal ='43894' and gstt.crncy_code = 'JPY' THEN TO_NUMBER('526728')
  ELSE gstt.tot_dr_bal end as tot_dr_bal,
   CASE WHEN gstt.crncy_code = 'MMK'  THEN gstt.tot_cr_bal
  when  gstt.gl_sub_head_code = '70002' and  gstt.tot_cr_bal <> 0 THEN TO_NUMBER('4138000000')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_cr_bal ='15089438.96' and gstt.crncy_code = 'USD' THEN TO_NUMBER('23223815863.52')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_cr_bal ='1438192.92' and gstt.crncy_code = 'EUR' THEN TO_NUMBER('2106952627.8')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_cr_bal ='549914.19' and gstt.crncy_code = 'SGD' THEN TO_NUMBER('536166335.249998')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_cr_bal ='1245739.92' and gstt.crncy_code = 'THB' THEN TO_NUMBER('48583856.8799995')
  when  gstt.gl_sub_head_code = '60161' and  gstt.tot_cr_bal ='43894' and gstt.crncy_code = 'JPY' THEN TO_NUMBER('526728')
  ELSE gstt.tot_cr_bal end as tot_cr_bal*/
  gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_SOL_ID || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = upper(ci_cur)
   and gstt.crncy_code = upper(ci_cur)
   and coa.cur= upper(ci_cur)
   order by gsh.free_code1
   )q group by q.group_code, q.description order by q.group_code;

CURSOR ExtractData_All (	ci_EOD_DATE VARCHAR2, ci_SOL_ID VARCHAR2)IS
select T.group_code,
  T.description,
  sum(T.CR_amt),
  sum(T.DR_amt)
  from
  (
  select  q.group_code, q.description,
  CASE WHEN q.crncy_code = 'MMK'  THEN q.tot_dr_bal
  when  q.gl_sub_head_code = '70002' and  q.tot_dr_bal <> 0 THEN TO_NUMBER('4138000000')
 /* when  q.gl_sub_head_code = '60161' and  q.tot_dr_bal ='18282678.36' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.tot_dr_bal ='1259531.25' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.tot_dr_bal ='653408.19' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.tot_dr_bal ='874441.97' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.tot_dr_bal ='29894' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')*/
  ELSE q.tot_dr_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  CASE WHEN q.crncy_code = 'MMK' THEN q.tot_cr_bal
   when  q.gl_sub_head_code = '70002' and  q.tot_cr_bal <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.tot_cr_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt
     -- q.tot_cr_bal As CR_amt,
      --q.tot_dr_bal As Dr_amt
 from(
 select gstt.crncy_code,
 gsh.gl_sub_head_code,
   coa.group_code,
   coa.description,
   gstt.tot_cr_bal ,
   gstt.tot_dr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_SOL_ID || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code = gstt.crncy_code
   )q
   )T group by T.group_code, T.description order by T.group_code;

CURSOR ExtractData_All_FCY (	ci_EOD_DATE VARCHAR2, ci_SOL_ID VARCHAR2)IS
select T.group_code,
  T.description,
  sum(T.CR_amt),
  sum(T.DR_amt)
  from
  (
  select  q.group_code, q.description,
  CASE WHEN q.crncy_code = 'MMK' THEN q.tot_dr_bal
  /* when  q.gl_sub_head_code = '70002' and  q.tot_dr_bal <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')*/
  ELSE q.tot_dr_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS DR_amt,
  CASE WHEN q.crncy_code = 'MMK' THEN q.tot_cr_bal
  when  q.gl_sub_head_code = '70002' and  q.tot_cr_bal <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')--27479877212.88+2652000000
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.tot_cr_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.crncy_code) and r.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_EOD_DATE AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS CR_amt
 from(
 select gstt.crncy_code,
  gsh.gl_sub_head_code,
    coa.group_code,
   coa.description,
   gstt.tot_cr_bal ,
   gstt.tot_dr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
  gstt.gl_sub_head_code = gsh.gl_sub_head_code
   and gstt.sol_id=gsh.sol_id
   and gsh.crncy_code = coa.cur
   and gsh.crncy_code = gstt.crncy_code
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.BAL_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and gstt.SOL_ID like   '%' || ci_SOL_ID || '%'
   and (gstt.tot_cr_bal > 0 or gstt.tot_dr_bal > 0)
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and gsh.crncy_code not like 'MMK'
   and gstt.crncy_code not like 'MMK'
   and coa.cur not like 'MMK'
   )q
   )T group by T.group_code, T.description order by T.group_code;

  PROCEDURE FIN_GROUP_TRIAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS

    v_GL_SUB_HEAD_CODE TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_GL_SUB_HEAD_DESC TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
    v_TRAN_DR_BAL TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type ;
    v_TRAN_CR_BAL TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type ;
    v_BAL TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type ;
    v_Date_Flg TBAADM.GENERAL_ACCT_MAST_TABLE.del_flg%type;
    v_BranchName TBAADM.sol.sol_desc%type;
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

    vi_EOD_DATE  :=  outArr(0);
    vi_cur  :=  outArr(1);
    vi_cur_type    :=  outArr(2);
    vi_SOL_ID    :=  outArr(3);

  if( vi_EOD_DATE is null or vi_cur_type is null) then
        --resultstr := 'No Data For Report';
       out_rec:=	(
           '-'  || '|' ||  '-'   || '|' ||  0  || '|' ||
            0  || '|' ||
					 '-' 	|| '|' ||
					 '-'       			|| '|' ||
					 '-'  || '|' ||
           '-'  || '|'||
          0);
        out_retCode:= 1;
        RETURN;
  end if;

  IF vi_SOL_ID IS  NULL or vi_SOL_ID = ''  THEN
  vi_SOL_ID := '';
  END IF;
    --------------------------------------
		-- Checking ToDay or Not
		--------------------------------------
    select Db_Stat_Date into sdate from tbaadm.SOL_GROUP_CONTROL_TABLE where sol_group_id = '01';
    if( TO_DATE( sysdate, 'dd-MM-yyyy' ) = TO_DATE( vi_EOD_DATE, 'dd-MM-yyyy' ) ) then
        v_Date_Flg := 'Y';
    else
        v_Date_Flg := 'N';
    end if;
    ----------------------
    IF (v_Date_Flg = 'Y') then
    IF NOT ExtractDataForToday%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForToday ( vi_EOD_DATE,	vi_SOL_ID,vi_cur);
			--}
			END;

		--}
		END IF;

    IF ExtractDataForToday%ISOPEN THEN
		--{
			FETCH	ExtractDataForToday
			INTO	 v_GL_SUB_HEAD_CODE , v_GL_SUB_HEAD_DESC  ,v_BAL;


			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractDataForToday%NOTFOUND THEN
			--{
				CLOSE ExtractDataForToday;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;

    ELSE --------------Back Date ------------------------
   if vi_cur_type not like 'All%' then
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ( vi_EOD_DATE,	vi_SOL_ID,vi_cur);
			--}
			END;

		--}
		END IF;

    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_GL_SUB_HEAD_CODE , v_GL_SUB_HEAD_DESC  ,v_TRAN_CR_BAL,v_TRAN_DR_BAL;


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
    end if;
    if vi_cur_type like 'All%(FCY)' then

    IF NOT ExtractData_All_FCY%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All_FCY ( vi_EOD_DATE,	vi_SOL_ID);
			--}
			END;

		--}
		END IF;

    IF ExtractData_All_FCY%ISOPEN THEN
		--{
			FETCH	ExtractData_All_FCY
			INTO	 v_GL_SUB_HEAD_CODE , v_GL_SUB_HEAD_DESC  ,v_TRAN_CR_BAL,v_TRAN_DR_BAL;


			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All_FCY%NOTFOUND THEN
			--{
				CLOSE ExtractData_All_FCY;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
    end if;
    if vi_cur_type like 'All Currency' then

    IF NOT ExtractData_All%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All ( vi_EOD_DATE,	vi_SOL_ID);
			--}
			END;

		--}
		END IF;

    IF ExtractData_All%ISOPEN THEN
		--{
			FETCH	ExtractData_All
			INTO	 v_GL_SUB_HEAD_CODE , v_GL_SUB_HEAD_DESC  ,v_TRAN_CR_BAL,v_TRAN_DR_BAL;


			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
			IF ExtractData_All%NOTFOUND THEN
			--{
				CLOSE ExtractData_All;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;

   --- end if; -----------For Each Branch


    end if;
    ------------------------

    END IF;--Back / Today end

     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------

---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
  if vi_cur_type = 'Home Currency' then
      if(upper(vi_cur) = 'MMK') then rate := 1;
      else select VAR_CRNCY_UNITS into rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE(vi_EOD_DATE, 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_cur)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
      end if;
    else
     rate := 1;
    end if;

   if vi_SOL_ID is not null then
   SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_SOL_ID AND bct.br_code = sol.br_code
   and bct.bank_code = '116';

  end if;

    END;


    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
           v_GL_SUB_HEAD_CODE  || '|' || v_GL_SUB_HEAD_DESC  || '|' || v_TRAN_DR_BAL  || '|' ||
           v_TRAN_CR_BAL || '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax || '|'||
          rate);

			dbms_output.put_line(out_rec);

  END FIN_GROUP_TRIAL_LISTING;

END FIN_GROUP_TRIAL_LISTING;
/
