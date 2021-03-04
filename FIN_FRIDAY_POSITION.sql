CREATE OR REPLACE PACKAGE FIN_FRIDAY_POSITION AS 

  PROCEDURE FIN_FRIDAY_POSITION(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_FRIDAY_POSITION;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                           FIN_FRIDAY_POSITION AS
/******************************************************************************
 NAME:       FIN_FRIDAY_POSITION
 PURPOSE:

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ---------------------------------------
 1.0        11/29/2016      Administrator       1. Created this package body.
******************************************************************************/
--------------------------------------------------------------------------------
    -- Cursor declaration
    -- This cursor will fetch all the data based on the main query
    --- temporary used cust_fcy_asset_liabilities_tmp
--------------------------------------------------------------------------------
  
  outArr            tbaadm.basp0099.ArrayType;  -- Input Parse Array  
  vi_tranDate       VARCHAR2(10);               -- Input to procedure
  vi_currency_code  VARCHAR2(3);               -- Input to procedure
  --vi_currency_type  VARCHAR2(50);               -- Input to procedure
  
--------------------------------------------------------------------------------
-- CURSOR declaration FIN_FRIDAY_POSITION CURSOR
--------------------------------------------------------------------------------
Serial_no   VARCHAR2(20);
Title   VARCHAR2(200);
Closing   NUMBER(20,2);
--------------------------------------------------------------------------------

-----------------cursor------------------
  CURSOR ExtractDataResult IS
select nvl(rpt.NO,' '),DESCRIPTION,AMOUNT
from CUSTOM.cust_friday_position_tmp RPT order by rpt.id;


---------------------------------Function ASSET---------------------------------------
 FUNCTION LCODE(COUNT_NUM VARCHAR2,DESCRIPTION VARCHAR2,ci_tranDate VARCHAR2,ci_currency_code VARCHAR2,GLCODE1 VARCHAR2,GLCODE2 VARCHAR2,GLCODE3 VARCHAR2,GLCODE4 VARCHAR2,GLCODE5 VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(200) := COUNT_NUM;
  BEGIN
     BEGIN
     select COUNT_NUM AS NO,
       DESCRIPTION AS DESCRIPTION,
       (sum(q.Cr_amt)-sum(Dr_amt)) as amount INTO Serial_no,Title,Closing
from
  (select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa--,tbaadm.gsh gsh
where-- gstt.gl_sub_head_code = gsh.gl_sub_head_code
   --and gstt.sol_id=gsh.sol_id
   -- gsh.crncy_code = coa.cur
  -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
    gstt.BAL_DATE <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
  -- and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and (coa.group_code= GLCODE1 or coa.group_code= GLCODE2 or coa.group_code= GLCODE3 or coa.group_code= GLCODE4 or coa.group_code= GLCODE5)) q
group by COUNT_NUM,DESCRIPTION;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       Serial_no   := COUNT_NUM;
       Title := DESCRIPTION;
       Closing := 0.0;
    end;
  INSERT INTO CUSTOM.cust_friday_position_tmp 
  VALUES (Serial_no, Title,Closing,ci_RowNumber);
  RETURN v_returnValue; 
END LCODE;


---------------------------------Function---------------------------------------
 FUNCTION ACODE(COUNT_NUM VARCHAR2,DESCRIPTION VARCHAR2,ci_tranDate VARCHAR2,ci_currency_code VARCHAR2,GLCODE1 VARCHAR2,GLCODE2 VARCHAR2,GLCODE3 VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(200) := COUNT_NUM;
  BEGIN
     BEGIN
      select COUNT_NUM AS NO,
       DESCRIPTION AS DESCRIPTION,
       (sum(q.Dr_amt)-sum(q.Cr_amt)) as amount INTO Serial_no,Title,Closing
from
  (select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa--,tbaadm.gsh gsh
where --gstt.gl_sub_head_code = gsh.gl_sub_head_code
   -- gstt.sol_id=gsh.sol_id
  -- and gsh.crncy_code = coa.cur
  -- and gsh.gl_sub_head_code = coa.gl_sub_head_code
    gstt.BAL_DATE <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
  -- and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and (coa.group_code= GLCODE1 or coa.group_code= GLCODE2 or coa.group_code= GLCODE3)) q
group by COUNT_NUM,DESCRIPTION;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       Serial_no   := COUNT_NUM;
       Title := DESCRIPTION;
       Closing := 0.0;
    end;
  INSERT INTO CUSTOM.cust_friday_position_tmp 
  VALUES (Serial_no, Title,Closing,ci_RowNumber);
  RETURN v_returnValue; 
END ACODE;

----------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION ACODE_FORACID(COUNT_NUM VARCHAR2,DESCRIPTION VARCHAR2,ci_tranDate VARCHAR2,ci_currency_code VARCHAR2,GLCODE1 VARCHAR2,GLCODE2 VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(200) := COUNT_NUM;
  BEGIN
     BEGIN 
     select COUNT_NUM AS NO,
       DESCRIPTION AS DESCRIPTION,
     sum(q.tran_date_bal) as amount INTO Serial_no,Title,Closing
from 
(select eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab, custom.coa_mp coa
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and gam.gl_sub_head_code = coa.gl_sub_head_code
and gam.acct_crncy_code = coa.cur
and gam.acct_crncy_code =upper(ci_currency_code)
and coa.group_code= GLCODE1
and substr(gam.foracid,6,length(gam.foracid)-5)= GLCODE2
and eab.eod_date <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_tranDate, 'dd-MM-yyyy' ))q
group by COUNT_NUM,DESCRIPTION;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       Serial_no   := COUNT_NUM;
       Title := DESCRIPTION;
       Closing := 0.0;
    end;
  INSERT INTO CUSTOM.cust_friday_position_tmp 
  VALUES (Serial_no, Title,Closing,ci_RowNumber);
  RETURN v_returnValue; 
END ACODE_FORACID;
----------------------------------Lia Function----------------------------------

 FUNCTION ACODE_GLSUB(COUNT_NUM VARCHAR2,DESCRIPTION VARCHAR2,ci_tranDate VARCHAR2,ci_currency_code VARCHAR2,GLCODE1 VARCHAR2,GLCODE2 VARCHAR2,GLCODE3 VARCHAR2,ci_RowNumber VARCHAR2)
  RETURN VARCHAR2 AS
   v_returnValue VARCHAR2(200) := COUNT_NUM;
  BEGIN
     BEGIN
     select COUNT_NUM AS NO,
       DESCRIPTION AS DESCRIPTION,
       (sum(q.Dr_amt)-sum(q.Cr_amt)) as amount INTO Serial_no,Title,Closing
from
  (select
   gstt.tot_cr_bal as Cr_amt,
   gstt.tot_dr_bal as Dr_amt
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa--,tbaadm.gsh gsh
where-- gstt.gl_sub_head_code = gsh.gl_sub_head_code
  -- and gstt.sol_id=gsh.sol_id
   --and gsh.crncy_code = coa.cur
   --and gsh.gl_sub_head_code = coa.gl_sub_head_code
    gstt.BAL_DATE <= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.end_bal_date >= TO_DATE( ci_tranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   --and gsh.crncy_code = upper(ci_currency_code)
   and gstt.crncy_code = upper(ci_currency_code)
   and coa.cur= upper(ci_currency_code)
   and coa.group_code= GLCODE1
   and (coa.gl_sub_head_code = GLCODE2 or coa.gl_sub_head_code= GLCODE3)) q
group by COUNT_NUM,DESCRIPTION;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
       Serial_no   := COUNT_NUM;
       Title := DESCRIPTION;
       Closing := 0.0;
    end;
  INSERT INTO CUSTOM.cust_friday_position_tmp 
  VALUES (Serial_no, Title,Closing,ci_RowNumber);
  RETURN v_returnValue; 
END ACODE_GLSUB;
--------------------------------------------------------------------------------  
  
  PROCEDURE FIN_FRIDAY_POSITION(	inp_str      IN  VARCHAR2,
                                            out_retCode  OUT NUMBER,
                                            out_rec      OUT VARCHAR2 ) AS
  v_No VARCHAR2(20);
  v_DESCRIPTION VARCHAR2(200);
  v_AMOUNT  NUMBER(20);
  rate Number;
  out_put Varchar2(60);
  
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
    
    vi_tranDate    :=  outArr(0);
    vi_currency_code := outArr(1);
    --vi_currency_type := outArr(2);
    
    begin
    DELETE FROM CUSTOM.cust_friday_position_tmp;
     INSERT INTO CUSTOM.cust_friday_position_tmp 
   VALUES ('0', '', 0.00,0);
    
    
      out_put := LCODE('1','Demand Deposit in Union of Myanmar',vi_tranDate,vi_currency_code,'','','','','',1);
     -- dbms_output.put_line(out_put);
      
      out_put := LCODE('','(1) Deposits',vi_tranDate,vi_currency_code,'','','','','',2);
     -- dbms_output.put_line(out_put);
      
      out_put := LCODE('','       (a)  Deposit of bank',vi_tranDate,vi_currency_code,'','','','','',3);
      --dbms_output.put_line(out_put);
      
      out_put := LCODE('','             Other Deposits - Current Deposits',vi_tranDate,vi_currency_code,'L11','','','','',4);
      --dbms_output.put_line(out_put);
      out_put := LCODE('','                              Saving Deposits',vi_tranDate,vi_currency_code,'L13','','','','',5);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','                              Special Deposits',vi_tranDate,vi_currency_code,'L15','','','','',6);
      --dbms_output.put_line(out_put);
      out_put := LCODE('','                              Fixed Deposits',vi_tranDate,vi_currency_code,'L17','','','','',7);
      --dbms_output.put_line(out_put);
      out_put := LCODE('','(2) Liabilities except customer deposit',vi_tranDate,vi_currency_code,'','','','','',8);
      --dbms_output.put_line(out_put);
      out_put := LCODE('','       (a) Deposit of private bank',vi_tranDate,vi_currency_code,'L21','L22','L23','L24','L26',9);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','       (b) Other liabilities (P.O)',vi_tranDate,vi_currency_code,'L33','','','','',10);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('2','Time Deposit in Union of Myanmar',vi_tranDate,vi_currency_code,'','','','','',11);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','(1) Deposits',vi_tranDate,vi_currency_code,'','','','','',12);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','       (a)  Deposit of bank',vi_tranDate,vi_currency_code,'','','','','',13);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','               Current Deposit - SBB',vi_tranDate,vi_currency_code,'','','','','',14);
      --dbms_output.put_line(out_put);
      out_put := LCODE('','                               - CB',vi_tranDate,vi_currency_code,'','','','','',15);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','               Saving Deposit - AYA',vi_tranDate,vi_currency_code,'','','','','',16);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','                              - MBL',vi_tranDate,vi_currency_code,'','','','','',17);
   --   dbms_output.put_line(out_put);
      out_put := LCODE('','       (b) Other Deposits (Fixed Deposits)',vi_tranDate,vi_currency_code,'','','','','',18);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','(2) Liabilities except customer deposit',vi_tranDate,vi_currency_code,'','','','','',19);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','        (1) BORROWING FROM (CBM)',vi_tranDate,vi_currency_code,'L31','','','','',20);
    --  dbms_output.put_line(out_put);
      out_put := LCODE('','        (2) BORROWING FROM (MEB)',vi_tranDate,vi_currency_code,'','','','','',21);
    --  dbms_output.put_line(out_put);
      --out_put := ASSETONE('A/C With UOB',vi_tranDate,'10130',22);
      
       out_put := LCODE('','        (3) BORROWING FROM (MBL)',vi_tranDate,vi_currency_code,'','','','','',22);
      --dbms_output.put_line(out_put);
       out_put := LCODE('','        (4) BORROWING FROM (CBM-S.L)',vi_tranDate,vi_currency_code,'','','','','',23);
     -- dbms_output.put_line(out_put);
      out_put := LCODE('','        (3) BORROWING FROM (MBL)',vi_tranDate,vi_currency_code,'','','','','',24);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('3','Cash in hand in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',25);
      --dbms_output.put_line(out_put);
      out_put := ACODE('','(a) Cash in hand',vi_tranDate,vi_currency_code,'A01','A02','A03',26);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('4','Account With Bank Balances',vi_tranDate,vi_currency_code,'','','',27);
     -- dbms_output.put_line(out_put);
       Out_Put := ACODE('','(1) Cash in hand in Central Bank of Myanmar',vi_tranDate,vi_currency_code,'','','',28);
      -- dbms_output.put_line(out_put);
       out_put := ACODE('','       (a)  Account with CBM',vi_tranDate,vi_currency_code,'A04','A05','',29);
      -- dbms_output.put_line(out_put);
       out_put := ACODE('','(2) Account with Foreign Bank Balances',vi_tranDate,vi_currency_code,'A08','','',30);
     --  dbms_output.put_line(out_put);
      out_put := ACODE('','(3) Account with Privates Bank Balances',vi_tranDate,vi_currency_code,'A07','','',31);
    --  dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','               Current Deposit - KBZ',vi_tranDate,vi_currency_code,'A07','10114006011',32);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - MWD',vi_tranDate,vi_currency_code,'A07','10115007011',33);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - GTB',vi_tranDate,vi_currency_code,'A07','10116008011',34);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MCB',vi_tranDate,vi_currency_code,'A07','10117009011',35);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - AYA',vi_tranDate,vi_currency_code,'A07','10118010011',36);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - Innwa',vi_tranDate,vi_currency_code,'A07','10119011011',37);
    --  dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CB',vi_tranDate,vi_currency_code,'A07','10120012011',38);
    --  dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MAB',vi_tranDate,vi_currency_code,'A07','10121013011',39);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SMID',vi_tranDate,vi_currency_code,'A07','10122014011',40);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - RDB',vi_tranDate,vi_currency_code,'A07','10123015011',41);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CHD',vi_tranDate,vi_currency_code,'A07','10124016011',42);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - UAB',vi_tranDate,vi_currency_code,'A07','10125017011',43);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SHWE',vi_tranDate,vi_currency_code,'A07','10126018011',44);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SBTYY',vi_tranDate,vi_currency_code,'A07','10127019011',45);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_GLSUB('','                               - MEB',vi_tranDate,vi_currency_code,'A06','10109','',46);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_GLSUB('','                               - MICB',vi_tranDate,vi_currency_code,'A06','10111','10112',47);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_GLSUB('','                               - MFTB',vi_tranDate,vi_currency_code,'A06','10110','10113',48);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','               Saving Deposit - KBZ',vi_tranDate,vi_currency_code,'A07','10114006021',49);
      --dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - MWD',vi_tranDate,vi_currency_code,'A07','10115007021',50);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - GTB',vi_tranDate,vi_currency_code,'A07','10116008021',51);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MCB',vi_tranDate,vi_currency_code,'A07','10117009021',52);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - AYA',vi_tranDate,vi_currency_code,'A07','10118010021',53);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - Innwa',vi_tranDate,vi_currency_code,'A07','10119011021',54);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CB',vi_tranDate,vi_currency_code,'A07','10120012021',55);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MAB',vi_tranDate,vi_currency_code,'A07','10120013021',56);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SMID',vi_tranDate,vi_currency_code,'A07','10120014021',57);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - RDB',vi_tranDate,vi_currency_code,'A07','10120015021',58);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CHD',vi_tranDate,vi_currency_code,'A07','10124016021',59);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - UAB',vi_tranDate,vi_currency_code,'A07','10125017021',60);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SHWE',vi_tranDate,vi_currency_code,'A07','10126018021',61);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SBTYY',vi_tranDate,vi_currency_code,'A07','10127019021',62);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                Fixed Deposit - KBZ',vi_tranDate,vi_currency_code,'A07','10114006031',63);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - MWD',vi_tranDate,vi_currency_code,'A07','10115007031',64);
     -- dbms_output.put_line(out_put);
      out_put := ACODE_FORACID('','                               - GTB',vi_tranDate,vi_currency_code,'A07','10116008031',65);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MCB',vi_tranDate,vi_currency_code,'A07','10117009031',66);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - AYA',vi_tranDate,vi_currency_code,'A07','10118010031',67);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - Innwa',vi_tranDate,vi_currency_code,'A07','10119011031',68);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CB',vi_tranDate,vi_currency_code,'A07','10120012031',69);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - MAB',vi_tranDate,vi_currency_code,'A07','10121013031',70);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SMID',vi_tranDate,vi_currency_code,'A07','10122014031',71);
      --dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - RDB',vi_tranDate,vi_currency_code,'A07','10123015031',72);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - CHD',vi_tranDate,vi_currency_code,'A07','10124016031',73);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - UAB',vi_tranDate,vi_currency_code,'A07','10125017031',74);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SHWE',vi_tranDate,vi_currency_code,'A07','10126018031',75);
     -- dbms_output.put_line(out_put);
      Out_Put := ACODE_FORACID('','                               - SBTYY',vi_tranDate,vi_currency_code,'A07','10127019031',76);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('5','Demand Loans',vi_tranDate,vi_currency_code,'','','',77);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('6','Loans and Advances in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',78);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','(a) Loans and Advances to Banks',vi_tranDate,vi_currency_code,'A28','','',79);
      --dbms_output.put_line(out_put);
      out_put := ACODE('','(b) Loans and Advances to Customers',vi_tranDate,vi_currency_code,'','','',80);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','       - LOANS ACCOUNT',vi_tranDate,vi_currency_code,'A21','','',81);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','       - OVERDRAFT ACCOUNT',vi_tranDate,vi_currency_code,'A23','','',82);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','       - HIRE PURCHASE ACCOUNT',vi_tranDate,vi_currency_code,'A24','','',83);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','       -STAFF LOANS ACCOUNT',vi_tranDate,vi_currency_code,'A25','','',84);
    --  dbms_output.put_line(out_put);
      out_put := ACODE('7','Purchased or Discounted Payment Orders in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',85);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('8','Investments in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',86);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','(a) Government Securities',vi_tranDate,vi_currency_code,'','','',87);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','       - TREASURY BONDS and BILLS',vi_tranDate,vi_currency_code,'A11','','',88);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','(b) Other Investments',vi_tranDate,vi_currency_code,'','','',89);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','    ?According to Saving Deposits rule no.10',vi_tranDate,vi_currency_code,'','','',90);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','    -Demand deposit(or)other investors in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',91);
     -- dbms_output.put_line(out_put);
      out_put := ACODE('','    -Time deposit(or)other investors in Union of Myanmar',vi_tranDate,vi_currency_code,'','','',92);
     -- dbms_output.put_line(out_put);
--------------------------------------------------------------------------------
     COMMIT;
     
--------------------------------------------------------------------------------
  end;
  --IF vi_currency_type NOT LIKE 'All Currency%' then  
    
    IF NOT ExtractDataResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataResult;
			--}      
			END;
		--}
		END IF;
    
    IF ExtractDataResult%ISOPEN THEN
		--{
			FETCH	ExtractDataResult
			INTO v_No,v_DESCRIPTION,v_AMOUNT;
  ------------------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
  ------------------------------------------------------------------------------
			IF ExtractDataResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataResult;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;
		--}
    END IF;
 
 --end if;
-------------------------------------------------------------------------------
    -- GET EXCHANGE RATE INFORMATION
-------------------------------------------------------------------------------
    /*BEGIN
    IF vi_currency_type          = 'Home Currency' THEN
                if upper(vi_currency_code) = 'MMK' THEN rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_currency_code)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF vi_currency_type          = 'Source Currency' THEN
                  rate := 1;
              ELSE
                  rate := 1;
              END IF;
   end;*/
--------------------------------------------------------------------------------
-- out_rec variable retrieves the data to be sent to LST file with pipe seperation
--------------------------------------------------------------------------------
    out_rec:=	(v_No || '|' ||
               v_DESCRIPTION || '|' ||
               v_AMOUNT || '|' ||
                rate);
  
			dbms_output.put_line(out_rec);
      
  END FIN_FRIDAY_POSITION;

END FIN_FRIDAY_POSITION;
/
