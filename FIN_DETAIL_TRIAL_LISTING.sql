CREATE OR REPLACE PACKAGE                                    FIN_DETAIL_TRIAL_LISTING AS 

 PROCEDURE FIN_DETAIL_TRIAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_DETAIL_TRIAL_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                            FIN_DETAIL_TRIAL_LISTING AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
	vi_EOD_DATE	   	Varchar2(20);               -- Input to procedure
  vi_cur		Varchar2(10);		    	    -- Input to procedure
  vi_Cur_Type varchar (50);  -- Input to procedure
  vi_SOL_ID		Varchar2(10);		    	    -- Input to procedure
  
  sdate date;
   rate decimal(18,2);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractDataForToday (ci_EOD_DATE VARCHAR2, ci_cur VARCHAR2, ci_SOL_ID VARCHAR2) IS
 select    
   gam.FORACID as "Account Code" , 
   gam.ACCT_NAME as "Account Name",
   gam.clr_bal_amt as "Bal"
from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam
where
   gam.acct_opn_date = TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' ) 
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and gam.acct_crncy_code = upper(ci_cur) 
   and gam.acct_cls_flg = 'N' 
   and gam.schm_type in ('OAB','OAP','OAD');
   
CURSOR ExtractData(ci_EOD_DATE VARCHAR2, ci_cur VARCHAR2, ci_SOL_ID VARCHAR2) IS
select T.group_code,
  T.foracid,
  T.ACCT_NAME,
  sum(T.amount)
  from
  (
  select  q.group_code, q.foracid,q.ACCT_NAME,
  CASE WHEN q.crncy_code = 'MMK'  THEN q.Tran_date_bal ELSE q.Tran_date_bal END AS amount
 from(select 
   gsh.crncy_code,
   gsh.gl_sub_head_code,
   coa.group_code ,
   substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
   --gam.foracid , 
   gam.ACCT_NAME as ACCT_NAME, 
   --gam.ACCT_NAME, 
   eab.Tran_date_bal 
from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and coa.gl_sub_head_code = gsh.gl_sub_head_code
   and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and eab.bank_id = '01'
   and coa.cur =  upper(ci_cur)
   and gam.acct_crncy_code = upper(ci_cur)
   and gsh.crncy_code = upper(ci_cur)
   --and gam.acct_cls_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   and gam.schm_type in ('OAB','OAP','OAD','DDA')
   union  all
select
   gsh.crncy_code,
   gsh.gl_sub_head_code,
   coa.group_code,
   gsh.gl_sub_head_code , 
  gsh.gl_sub_head_desc  as  gl_sub_head_desc,
   sum(eab.Tran_date_bal) 
   from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE(ci_EOD_DATE, 'dd-MM-yyyy' ) 
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' ) 
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and coa.cur =  upper(ci_cur)
   and eab.Tran_date_bal <> 0
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and eab.bank_id = '01'
   and gam.acct_crncy_code = upper(ci_cur)
   and gsh.crncy_code = upper(ci_cur)
   --and gam.acct_cls_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   --and gam.schm_type in ('OAB','OAP','OAD');
   and gam.acct_ownership in ('C','E')   
   group by gsh.gl_sub_head_code, gsh.gl_sub_head_desc, coa.group_code,gsh.crncy_code
   )q
   )T group by T.group_code, T.foracid, T.ACCT_NAME order by T.group_code;
   
CURSOR ExtractData_All_FCY(ci_EOD_DATE VARCHAR2, ci_SOL_ID VARCHAR2) IS
 select T.group_code,
  T.foracid,
  T.ACCT_NAME,
  sum(T.amount)
  from
  (
  select  q.group_code, q.foracid,q.ACCT_NAME,
  CASE WHEN q.crncy_code = 'MMK'  THEN q.Tran_date_bal
  when  q.gl_sub_head_code = '70002' and  q.Tran_date_bal <> 0 THEN TO_NUMBER('4138000000')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='18282678.36' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='1259531.25' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='653408.19' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='874441.97' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='29894' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Tran_date_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
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
                              ),1) END AS amount
 from( 
 select 
 gsh.crncy_code,
  gsh.gl_sub_head_code,
   coa.group_code ,
   substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
   --gam.foracid , 
   --gam.ACCT_NAME, 
  gam.ACCT_NAME as ACCT_NAME, 
   eab.Tran_date_bal 
from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and eab.Tran_date_bal <> 0
   and gam.sol_id = gsh.sol_id
   and coa.gl_sub_head_code = gsh.gl_sub_head_code
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and eab.bank_id = '01'
   and coa.cur not like 'MMK'
   and gam.acct_crncy_code not like 'MMK'
   and gsh.crncy_code not like 'MMK'
   and eab.eab_crncy_code not like 'MMK'
   and gsh.crncy_code = eab.eab_crncy_code
   and gam.acct_crncy_code = coa.cur
   --and gam.acct_cls_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   and gam.schm_type in ('OAB','OAP','OAD') 
   UNION ALL
select 
gsh.crncy_code,
 gsh.gl_sub_head_code,
   coa.group_code,
   gsh.gl_sub_head_code , 
   gsh.gl_sub_head_desc as  gl_sub_head_desc, 
   sum(eab.Tran_date_bal)
   from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' ) 
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and eab.Tran_date_bal <> 0
   and gsh.sol_id = gam.sol_id
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and eab.bank_id = '01'
   and gam.acct_crncy_code not like 'MMK'
   and gsh.crncy_code not like 'MMK'
   and coa.cur not like 'MMK'
   and eab.eab_crncy_code not like 'MMK'
   and gsh.crncy_code = eab.eab_crncy_code
   and gam.acct_crncy_code = coa.cur
    and gsh.bank_id = '01'
   and gsh.del_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   and gam.acct_ownership in ('C','E')   
   group by gsh.gl_sub_head_code, gsh.gl_sub_head_desc, coa.group_code,gsh.crncy_code
   )q
   )T group by T.group_code, T.foracid, T.ACCT_NAME order by T.group_code;
   
CURSOR ExtractData_All(ci_EOD_DATE VARCHAR2,ci_SOL_ID VARCHAR2) IS
select T.group_code,
  T.foracid,
  T.ACCT_NAME,
  sum(T.amount)
  from
  (
  select  q.group_code, q.foracid,q.ACCT_NAME,
  CASE WHEN q.crncy_code = 'MMK'  THEN q.Tran_date_bal
  when  q.gl_sub_head_code = '70002' and  q.Tran_date_bal <> 0 THEN TO_NUMBER('4138000000')
 when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='18282678.36' and q.crncy_code = 'USD' THEN TO_NUMBER('27479877212.88')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='1259531.25' and q.crncy_code = 'EUR' THEN TO_NUMBER('1825060781.25')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='653408.19' and q.crncy_code = 'SGD' THEN TO_NUMBER('633152536.11')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='874441.97' and q.crncy_code = 'THB' THEN TO_NUMBER('34103236.83')
  when  q.gl_sub_head_code = '60161' and  q.Tran_date_bal ='29894' and q.crncy_code = 'JPY' THEN TO_NUMBER('367397.26')
  ELSE q.Tran_date_bal * NVL((SELECT r.VAR_CRNCY_UNITS 
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
                              ),1) END AS amount
 from( 
 select 
 gsh.crncy_code,
 gsh.gl_sub_head_code,
   coa.group_code ,
   substr(gam.foracid,6,length(gam.foracid)-5) as foracid,
   --gam.foracid , 
   --gam.ACCT_NAME,
   gam.ACCT_NAME as ACCT_NAME, 
   eab.Tran_date_bal 
from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE( ci_EOD_DATE, 'dd-MM-yyyy' )
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and eab.Tran_date_bal <> 0
   and gam.sol_id = gsh.sol_id
   and gam.acct_crncy_code = gsh.crncy_code
   and gsh.crncy_code = coa.cur
   and coa.gl_sub_head_code = gsh.gl_sub_head_code
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
   and eab.bank_id = '01'
   --and gam.acct_cls_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   and gam.schm_type in ('OAB','OAP','OAD','DDA') 
   UNION ALL
select 
gsh.crncy_code,
 gsh.gl_sub_head_code,
   coa.group_code,
   gsh.gl_sub_head_code , 
   gsh.gl_sub_head_desc as gl_sub_head_desc, 
   sum(eab.Tran_date_bal)
   from 
   TBAADM.EOD_ACCT_BAL_TABLE eab , 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam,tbaadm.gl_sub_head_table gsh,custom.coa_mp coa
where
   eab.EOD_DATE <= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' ) 
   and eab.end_eod_date >= TO_DATE(ci_EOD_DATE , 'dd-MM-yyyy' )
   and gam.SOL_ID like   '%' || ci_SOL_ID || '%'
   and eab.Tran_date_bal <> 0
   and gsh.sol_id = gam.sol_id
   and gsh.crncy_code = eab.eab_crncy_code
   and gam.acct_crncy_code = coa.cur
   and gsh.gl_sub_head_code = coa.gl_sub_head_code
   and gam.DEL_FLG = 'N' 
   and gam.BANK_ID = '01' 
    and gsh.bank_id = '01'
   and gsh.del_flg = 'N'
   and eab.bank_id = '01'
   --and gam.acct_cls_flg = 'N'
   and eab.acid = gam.acid 
   and gam.sol_id=gsh.sol_id
   and gam.gl_sub_head_code=gsh.gl_sub_head_code
   and gam.acct_ownership in ('C','E')   
   group by gsh.gl_sub_head_code, gsh.gl_sub_head_desc, coa.group_code,gsh.crncy_code
   )q
   )T group by T.group_code, T.foracid, T.ACCT_NAME order by T.group_code;
   
   ---------------------------------------HO------------------------------------
   

   
  PROCEDURE FIN_DETAIL_TRIAL_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
      
    v_FreeCode TBAADM.gl_sub_head_table.free_code1%type;
    v_Bal TBAADM.GL_SUB_HEAD_TRAN_TABLE.TOT_DR_BAL%type ; 
    v_Account_Code TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_Clr_Bal_Amt TBAADM.GENERAL_ACCT_MAST_TABLE.clr_bal_amt%type;
    v_Date_Flg TBAADM.GENERAL_ACCT_MAST_TABLE.del_flg%type;
    v_Account_Name varchar(200);
    v_BranchName TBAADM.sol.sol_desc%type;
    v_BankAddress Varchar(100);
    v_BankPhone TBAADM.BRANCH_CODE_TABLE.PHONE_NUM%type;
    v_BankFax TBAADM.BRANCH_CODE_TABLE.FAX_NUM%type;
    v_group custom.coa_mp.group_code%type;
    
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
    vi_Cur_Type    :=  outArr(2);
     vi_SOL_ID    :=  outArr(3);		
     
     --------------------------------------------------------------------------------------
  /*   
     if( vi_EOD_DATE is null or vi_Cur_Type is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  || '|' || '-' || '|' ||
                 '-' || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

     */
     -------------------------------------------------------------------------------------
     
     
     if( vi_EOD_DATE is null or vi_cur_type is null) then
        --resultstr := 'No Data For Report';
       out_rec:=	(
           0  || '|' || '-'  || '|' ||  '-'  || '|' ||
					 '-' 	|| '|' ||
					 '-'       			|| '|' ||
					 '-'  || '|' ||
           '-'  ||'|'||  '-'  || '|' || 0);
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
    IF(v_Date_Flg = 'Y') THEN
    IF NOT ExtractDataForToday%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForToday ( vi_EOD_DATE, vi_cur,	vi_SOL_ID);
			--}
			END;

		--}
		END IF;
    
    IF ExtractDataForToday%ISOPEN THEN
		--{
			FETCH	ExtractDataForToday
			INTO	 v_Account_Code ,v_Account_Name ,v_Bal;
      

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
    
    ELSE -------------------Back Date    
  

  if vi_cur_type not like 'All%' then
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData ( vi_EOD_DATE, vi_cur,	vi_SOL_ID);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN THEN
		--{
			FETCH	ExtractData
			INTO	 v_group,v_Account_Code ,v_Account_Name,  v_Bal;
      

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
    end if; -- source / home
    
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
			INTO	 v_group,v_Account_Code ,v_Account_Name,  v_Bal;
      

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
    
    if vi_cur_type =  'All Currency' then
    
    IF NOT ExtractData_All%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData_All ( vi_EOD_DATE, vi_SOL_ID);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData_All%ISOPEN THEN
		--{
			FETCH	ExtractData_All
			INTO	v_group,v_Account_Code ,v_Account_Name,  v_Bal;
      

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
    end if; 
   
  END IF;  --------- End of Back Date
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
 if vi_SOL_ID is not null then
   SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = vi_SOL_ID AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
    end if;  

 
   
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
    
    
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(
           v_Bal  || '|' || v_Account_Code  || '|' || v_Account_Name || '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax ||'|'|| v_group || '|' || rate);
  
			dbms_output.put_line(out_rec);
    
  END FIN_DETAIL_TRIAL_LISTING;

END FIN_DETAIL_TRIAL_LISTING;
/
