CREATE OR REPLACE PACKAGE FIN_PROFIT_LOSS_MONTH_BRANCH AS 

  PROCEDURE FIN_PROFIT_LOSS_MONTH_BRANCH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_PROFIT_LOSS_MONTH_BRANCH;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                   FIN_PROFIT_LOSS_MONTH_BRANCH AS

-----------------------------------------------------------------------
--Update User - Yin Win Phyu
-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_TranDate	   	Varchar2(20);              -- Input to procedure
  vi_Type       Varchar2(50);		    	     -- Input to procedure
	vi_currency_code		Varchar2(3);		    	     -- Input to procedure
  vi_currency_type Varchar2(50);		    	     -- Input to procedure
  vi_branch_code Varchar2(5);	                   -- Input to procedure
-------------------------------------------------------------------------------
    -- GET Remittance Information
-------------------------------------------------------------------------------

Cursor ExtractData(ci_TranDate Varchar2) IS
select H.Header,H.temp,H.gl_sub_head_code,H.no,H.description,H.gl_sub_head_desc,H.foracid,
       H.AMT_10100,H.AMT_20100,H.AMT_20300,H.AMT_30100,H.AMT_30200,H.AMT_30201,H.AMT_30300,H.AMT_30301,H.AMT_30302,H.AMT_30400,
       H.AMT_30401,H.AMT_30402,H.AMT_30500,H.AMT_30600,H.AMT_30700,H.AMT_30800,H.AMT_30900,H.AMT_31000,H.AMT_31001,H.AMT_31100,
       H.AMT_31200,H.AMT_31201,H.AMT_31202,H.AMT_31300,H.AMT_31400,H.AMT_31500,H.AMT_31600,H.AMT_31700,H.AMT_31800,H.AMT_31801,
       H.AMT_31900,H.AMT_31901,H.AMT_32000,H.AMT_32100,H.AMT_32200,H.AMT_32201,H.AMT_32300,H.AMT_32400,H.AMT_32401,H.AMT_32402,
       H.AMT_32403,H.AMT_32404,H.AMT_32500,H.AMT_32501,H.AMT_32502,H.AMT_32503,H.AMT_32600,H.AMT_32700,H.AMT_32800,H.AMT_32900,
       H.AMT_33000,H.AMT_33400,H.AMT_33500,H.AMT_33501,H.AMT_33502,H.AMT_33800,H.AMT_33801,H.AMT_34400,H.AMT_34500,H.AMT_34600,
       H.AMT_34700,H.AMT_34800,H.AMT_34900,H.AMT_35000,H.AMT_35100,H.AMT_35300,H.AMT_35301,H.AMT_35400,H.AMT_35401,H.AMT_35500,
       H.AMT_35600,H.AMT_35700,H.AMT_35800
from 
(select Heading.Header,Heading.temp,Heading.gl_sub_head_code,Heading.no,Heading.description,Heading.gl_sub_head_desc,Heading.foracid,
        sum(Heading.AMT_10100) as AMT_10100,sum(Heading.AMT_20100) as AMT_20100,sum(Heading.AMT_20300) as AMT_20300,
        sum(Heading.AMT_30100) as AMT_30100,sum(Heading.AMT_30200) as AMT_30200,sum(Heading.AMT_30201) as AMT_30201,
        sum(Heading.AMT_30300) as AMT_30300,sum(Heading.AMT_30301) as AMT_30301,sum(Heading.AMT_30302) as AMT_30302,
        sum(Heading.AMT_30400) as AMT_30400,sum(Heading.AMT_30401) as AMT_30401,sum(Heading.AMT_30402) as AMT_30402,
        sum(Heading.AMT_30500) as AMT_30500,sum(Heading.AMT_30600) as AMT_30600,sum(Heading.AMT_30700) as AMT_30700,
sum(Heading.AMT_30800) as AMT_30800,sum(Heading.AMT_30900) as AMT_30900,sum(Heading.AMT_31000) as AMT_31000,
sum(Heading.AMT_31001) as AMT_31001,sum(Heading.AMT_31100) as AMT_31100,sum(Heading.AMT_31200) as AMT_31200,
sum(Heading.AMT_31201) as AMT_31201,sum(Heading.AMT_31202) as AMT_31202,sum(Heading.AMT_31300) as AMT_31300,
sum(Heading.AMT_31400) as AMT_31400,sum(Heading.AMT_31500) as AMT_31500,sum(Heading.AMT_31600) as AMT_31600,
sum(Heading.AMT_31700) as AMT_31700,sum(Heading.AMT_31800) as AMT_31800,sum(Heading.AMT_31801) as AMT_31801,
sum(Heading.AMT_31900) as AMT_31900,sum(Heading.AMT_31901) as AMT_31901,sum(Heading.AMT_32000) as AMT_32000,
sum(Heading.AMT_32100) as AMT_32100,sum(Heading.AMT_32200) as AMT_32200,sum(Heading.AMT_32201) as AMT_32201,
sum(Heading.AMT_32300) as AMT_32300,sum(Heading.AMT_32400) as AMT_32400,sum(Heading.AMT_32401) as AMT_32401,
sum(Heading.AMT_32402) as AMT_32402,sum(Heading.AMT_32403) as AMT_32403,sum(Heading.AMT_32404) as AMT_32404,
sum(Heading.AMT_32500) as AMT_32500,sum(Heading.AMT_32501) as AMT_32501,sum(Heading.AMT_32502) as AMT_32502,
sum(Heading.AMT_32503) as AMT_32503,sum(Heading.AMT_32600) as AMT_32600,sum(Heading.AMT_32700) as AMT_32700,
sum(Heading.AMT_32800) as AMT_32800,sum(Heading.AMT_32900) as AMT_32900,sum(Heading.AMT_33000) as AMT_33000,
sum(Heading.AMT_33400) as AMT_33400,sum(Heading.AMT_33500) as AMT_33500,sum(Heading.AMT_33501) as AMT_33501,
sum(Heading.AMT_33502) as AMT_33502,sum(Heading.AMT_33800) as AMT_33800,sum(Heading.AMT_33801) as AMT_33801,
sum(Heading.AMT_34400) as AMT_34400,sum(Heading.AMT_34500) as AMT_34500,sum(Heading.AMT_34600) as AMT_34600,
sum(Heading.AMT_34700) as AMT_34700,sum(Heading.AMT_34800) as AMT_34800,sum(Heading.AMT_34900) as AMT_34900,
sum(Heading.AMT_35000) as AMT_35000,sum(Heading.AMT_35100) as AMT_35100,sum(Heading.AMT_35300) as AMT_35300,
sum(Heading.AMT_35301) as AMT_35301,sum(Heading.AMT_35400) as AMT_35400,sum(Heading.AMT_35401) as AMT_35401,
sum(Heading.AMT_35500) as AMT_35500,sum(Heading.AMT_35600) as AMT_35600,sum(Heading.AMT_35700) as AMT_35700,
sum(Heading.AMT_35800) as AMT_35800
from
(select  HEAD.Header,HEAD.temp,HEAD.gl_sub_head_code,HEAD.no,HEAD.description,HEAD.gl_sub_head_desc,HEAD.cur,HEAD.foracid,
         HEAD.AMT_10100,HEAD.AMT_20100,HEAD.AMT_20300,HEAD.AMT_30100,HEAD.AMT_30200,HEAD.AMT_30201,HEAD.AMT_30300,HEAD.AMT_30301,HEAD.AMT_30302,HEAD.AMT_30400,
         HEAD.AMT_30401,HEAD.AMT_30402,HEAD.AMT_30500,HEAD.AMT_30600,HEAD.AMT_30700,HEAD.AMT_30800,HEAD.AMT_30900,HEAD.AMT_31000,HEAD.AMT_31001,HEAD.AMT_31100,
        HEAD.AMT_31200,HEAD.AMT_31201,HEAD.AMT_31202,HEAD.AMT_31300,HEAD.AMT_31400,HEAD.AMT_31500,HEAD.AMT_31600,HEAD.AMT_31700,HEAD.AMT_31800,HEAD.AMT_31801,
        HEAD.AMT_31900,HEAD.AMT_31901,HEAD.AMT_32000,HEAD.AMT_32100,HEAD.AMT_32200,HEAD.AMT_32201,HEAD.AMT_32300,HEAD.AMT_32400,HEAD.AMT_32401,HEAD.AMT_32402,
        HEAD.AMT_32403,HEAD.AMT_32404,HEAD.AMT_32500,HEAD.AMT_32501,HEAD.AMT_32502,HEAD.AMT_32503,HEAD.AMT_32600,HEAD.AMT_32700,HEAD.AMT_32800,HEAD.AMT_32900,
        HEAD.AMT_33000,HEAD.AMT_33400,HEAD.AMT_33500,HEAD.AMT_33501,HEAD.AMT_33502,HEAD.AMT_33800,HEAD.AMT_33801,HEAD.AMT_34400,HEAD.AMT_34500,HEAD.AMT_34600,
        HEAD.AMT_34700,HEAD.AMT_34800,HEAD.AMT_34900,HEAD.AMT_35000,HEAD.AMT_35100,HEAD.AMT_35300,HEAD.AMT_35301,HEAD.AMT_35400,HEAD.AMT_35401,HEAD.AMT_35500,
        HEAD.AMT_35600,HEAD.AMT_35700,HEAD.AMT_35800
from
(select 'Income' as Header,'Interest Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,1 as no,'Interest on Investment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40001','40002','40003','40004')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Investment' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40001','40002','40003','40004'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
union all
select 'Income' as Header,'Interest Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
       B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
       B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,2 as no,'Interest on Loans and Advanced' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40011','40012','40014','40015','40021')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40011','40012','40014','40015','40021'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur=GL.cur) B
   
   union all
select 'Income' as Header,'Interest Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,3 as no,'Interest on Deposits' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40016','40017')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest on Deposits' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40016','40017'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur= GL.cur) B
   union all
select 'Income' as Header,'Interest Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,4 as no,'Interest Expense' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50105')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Interest Expense' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50101','50103','50104','50106','50107','50105'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,5 as no,'Income on Remittance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40031','40032','40033','40034')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Remittance' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40031','40032','40033','40034'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
 union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,6 as no,'Commission' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40051','40061','40049','40041','40043','40044','40047','40048','40052','40059')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Commission' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40051','40061','40049','40041','40043','40044','40047','40048','40052','40059'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,7 as no,'Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40057','40046','40065','40062','40058','40053','40054','40066','40067'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
  union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,8 as no,'Income on Services Charges' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40050','40063','40056','40060')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Services Charges' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40050','40063','40056','40060'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,9 as no,'Income on Cards Fees' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Income on Cards Fees' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40071','40072','40073','40074','40075','40105','40106','40064','40076'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
    union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,10 as no,'Miscellaneous Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40081','40114')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Miscellaneous Income' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40081','40114'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
 union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
       B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
       B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,11 as no,'Disount Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40091','40092')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Disount Income' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40091','40092'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   union all
select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,13 as no,'Rental Income' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('40111','40112','40113')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Cr_amt) - sum(T.Dr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rental Income' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('40111','40112','40113'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
--------------------------------------------------------------Expenditure---------------------------------------------------------------------------------------
union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,14 as no,'Establishment Salaries and Allowances' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Establishment Salaries and Allowances' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50161','50162','50163','50164','50165','50166','50167','50168','50169','50170','50172','50173','50174','50175','50176','50177','50178'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,15 as no,'Travel and Entertainment' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50212','50214','50215','50216')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Travel and Entertainment' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50212','50214','50215','50216'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,16 as no,'Fees and Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50231','50232','50233','50235','50237','50238')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Fees and Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50231','50232','50233','50235','50237','50238'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
   union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,17 as no,'Sales and Marketing Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50271','50272','50274','50275')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50271','50272','50274','50275'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,18 as no,'Repair and Maintenance Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50211','50281','50282','50283','50284','50285'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,19 as no,'Supply and Services Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50121','50201','50202','50291','50292')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50121','50201','50202','50291','50292'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,21 as no,'ICT Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50295')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'ICT Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50295'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,22 as no,'Misceallenous Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50142','50311','50312','50313','50315')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Misceallenous Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50142','50311','50312','50313','50315'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,23 as no,'Rent' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rent' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50191','50197','50192','50193','50194','50195'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,24 as no,'Rate and Tax' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50131','50303','50304','50305','50306')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Rate and Tax' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50131','50303','50304','50305','50306'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

     union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,25 as no,'Insurance' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Insurance' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50251','50252','50253','50254','50255','50256','50257','50258','50259','50260'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
        union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,26 as no,'Deprecitaion' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Deprecitaion' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50321','50326','50322','50323','50324','50341','50342','50325'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

        union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,27 as no,'Loss and Write Off' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50351','50352','50354','50196')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Loss and Write Off' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50351','50352','50354','50196'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B

        union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,28 as no,'Discount  Expenses' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50361')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Discount  Expenses' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50361'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
   
        union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,'99999999999' as foracid,
        B.AMT_10100,B.AMT_20100,B.AMT_20300,B.AMT_30100,B.AMT_30200,B.AMT_30201,B.AMT_30300,B.AMT_30301,B.AMT_30302,B.AMT_30400,
        B.AMT_30401,B.AMT_30402,B.AMT_30500,B.AMT_30600,B.AMT_30700,B.AMT_30800,B.AMT_30900,B.AMT_31000,B.AMT_31001,B.AMT_31100,
        B.AMT_31200,B.AMT_31201,B.AMT_31202,B.AMT_31300,B.AMT_31400,B.AMT_31500,B.AMT_31600,B.AMT_31700,B.AMT_31800,B.AMT_31801,
        B.AMT_31900,B.AMT_31901,B.AMT_32000,B.AMT_32100,B.AMT_32200,B.AMT_32201,B.AMT_32300,B.AMT_32400,B.AMT_32401,B.AMT_32402,
        B.AMT_32403,B.AMT_32404,B.AMT_32500,B.AMT_32501,B.AMT_32502,B.AMT_32503,B.AMT_32600,B.AMT_32700,B.AMT_32800,B.AMT_32900,
        B.AMT_33000,B.AMT_33400,B.AMT_33500,B.AMT_33501,B.AMT_33502,B.AMT_33800,B.AMT_33801,B.AMT_34400,B.AMT_34500,B.AMT_34600,
        B.AMT_34700,B.AMT_34800,B.AMT_34900,B.AMT_35000,B.AMT_35100,B.AMT_35300,B.AMT_35301,B.AMT_35400,B.AMT_35401,B.AMT_35500,
        B.AMT_35600,B.AMT_35700,B.AMT_35800
from 
(select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,
 case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
from
(select coa.gl_sub_head_code,29 as no,'Foreign Currency Gain/(loss)' as description,coa.gl_sub_head_desc,coa.cur
  from custom.coa_mp coa
  where coa.gl_sub_head_code in ('50371','50372','50373','50374','50375','50376')) GL
left join 
(select T.gl_sub_head_code,
       T.description,
       T.gl_sub_head_desc,T.sol_id,T.cur,
       (sum(T.Dr_amt) - sum(T.Cr_amt)) as Closing
from 
(
   select q.gl_sub_head_code ,
   q.description ,
   q.gl_sub_head_desc,q.sol_id,q.cur,
   sum(q.tot_dr_bal) as Dr_amt,
   sum(q.tot_cr_bal) as Cr_amt
from(
  select coa.gl_sub_head_code,
   'Foreign Currency Gain/(loss)' as description,
   coa.gl_sub_head_desc, gstt.sol_id,coa.cur,
   gstt.tot_dr_bal as tot_dr_bal,
  gstt.tot_cr_bal as tot_cr_bal
from
   TBAADM.GL_SUB_HEAD_TRAN_TABLE gstt ,custom.coa_mp coa
where gstt.gl_sub_head_code = coa.gl_sub_head_code
   and gstt.crncy_code = coa.cur
   and gstt.BAL_DATE <=TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.END_BAL_DATE >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
   and gstt.DEL_FLG = 'N'
   and gstt.BANK_ID = '01'
   and coa.gl_sub_head_code in ('50371','50372','50373','50374','50375','50376'))q 
   group by q.gl_sub_head_code, q.description,q.gl_sub_head_desc,q.sol_id,q.cur) T
   group by T.gl_sub_head_code,T.description,T.gl_sub_head_desc,T.sol_id,T.cur
   order by T.gl_sub_head_code)x -- Interest on Loans and Advanced
   on x.gl_sub_head_code = GL.gl_sub_head_code
   and x.cur = GL.cur) B
---------------------------------------------------------------Account Number Income MMK Rate--------------------------------------------------------------------------   
   union all
 select 'Income' as Header,'Interest Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        sum(B.AMT_10100) as AMT_10100,sum(B.AMT_20100) as AMT_20100,sum(B.AMT_20300) as AMT_20300,
        sum(B.AMT_30100) as AMT_30100,sum(B.AMT_30200) as AMT_30200,sum(B.AMT_30201) as AMT_30201,
        sum(B.AMT_30300) as AMT_30300,sum(B.AMT_30301) as AMT_30301,sum(B.AMT_30302) as AMT_30302,
        sum(B.AMT_30400) as AMT_30400,sum(B.AMT_30401) as AMT_30401,sum(B.AMT_30402) as AMT_30402,
        sum(B.AMT_30500) as AMT_30500,sum(B.AMT_30600) as AMT_30600,sum(B.AMT_30700) as AMT_30700,
        sum(B.AMT_30800) as AMT_30800,sum(B.AMT_30900) as AMT_30900,sum(B.AMT_31000) as AMT_31000,
sum(B.AMT_31001) as AMT_31001,sum(B.AMT_31100) as AMT_31100,sum(B.AMT_31200) as AMT_31200,
sum(B.AMT_31201) as AMT_31201,sum(B.AMT_31202) as AMT_31202,sum(B.AMT_31300) as AMT_31300,
sum(B.AMT_31400) as AMT_31400,sum(B.AMT_31500) as AMT_31500,sum(B.AMT_31600) as AMT_31600,
sum(B.AMT_31700) as AMT_31700,sum(B.AMT_31800) as AMT_31800,sum(B.AMT_31801) as AMT_31801,
sum(B.AMT_31900) as AMT_31900,sum(B.AMT_31901) as AMT_31901,sum(B.AMT_32000) as AMT_32000,
sum(B.AMT_32100) as AMT_32100,sum(B.AMT_32200) as AMT_32200,sum(B.AMT_32201) as AMT_32201,
sum(B.AMT_32300) as AMT_32300,sum(B.AMT_32400) as AMT_32400,sum(B.AMT_32401) as AMT_32401,
sum(B.AMT_32402) as AMT_32402,sum(B.AMT_32403) as AMT_32403,sum(B.AMT_32404) as AMT_32404,
sum(B.AMT_32500) as AMT_32500,sum(B.AMT_32501) as AMT_32501,sum(B.AMT_32502) as AMT_32502,
sum(B.AMT_32503) as AMT_32503,sum(B.AMT_32600) as AMT_32600,sum(B.AMT_32700) as AMT_32700,
sum(B.AMT_32800) as AMT_32800,sum(B.AMT_32900) as AMT_32900,sum(B.AMT_33000) as AMT_33000,
sum(B.AMT_33400) as AMT_33400,sum(B.AMT_33500) as AMT_33500,sum(B.AMT_33501) as AMT_33501,
sum(B.AMT_33502) as AMT_33502,sum(B.AMT_33800) as AMT_33800,sum(B.AMT_33801) as AMT_33801,
sum(B.AMT_34400) as AMT_34400,sum(B.AMT_34500) as AMT_34400,sum(B.AMT_34600) as AMT_34600,
sum(B.AMT_34700) as AMT_34700,sum(B.AMT_34800) as AMT_34800,sum(B.AMT_34900) as AMT_34900,
sum(B.AMT_35000) as AMT_35000,sum(B.AMT_35100) as AMT_35100,sum(B.AMT_35300) as AMT_35300,
sum(B.AMT_35301) as AMT_35301,sum(B.AMT_35400) as AMT_35400,sum(B.AMT_35401) as AMT_35401,
sum(B.AMT_35500) as AMT_35500,sum(B.AMT_35600) as AMT_35600,sum(B.AMT_35700) as AMT_35700,
sum(B.AMT_35800) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
 case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,2 as no,'Interest on Loans and Advanced' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('40018020011','40018030011','40018040011','40018050011','40018060011','40018070011',
 '40018010011','40018010012','40018010013','40018010014','40018010015','40018010016','40018010017',
 '40019020011','40019030011','40019040011','40019050011','40019060011','40019070011',
 '40019010011','40019010012','40019010013','40019010014','40019010015','40019010016','40019010017')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Interest on Loans and Advanced' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('40018020011','40018030011','40018040011','40018050011','40018060011','40018070011',
   '40018010011','40018010012','40018010013','40018010014','40018010015','40018010016','40018010017',
   '40019020011','40019030011','40019040011','40019050011','40019060011','40019070011',
   '40019010011','40019010012','40019010013','40019010014','40019010015','40019010016','40019010017')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Income' as Header,'Interest Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
       sum(B.AMT_10100) as AMT_10100,sum(B.AMT_20100) as AMT_20100,sum(B.AMT_20300) as AMT_20300,
       sum(B.AMT_30100) as AMT_30100,sum(B.AMT_30200) as AMT_30200,sum(B.AMT_30201) as AMT_30201,
       sum(B.AMT_30300) as AMT_30300,sum(B.AMT_30301) as AMT_30301,sum(B.AMT_30302) as AMT_30302,
       sum(B.AMT_30400) as AMT_30400,sum(B.AMT_30401) as AMT_30401,sum(B.AMT_30402) as AMT_30402,
       sum(B.AMT_30500) as AMT_30500,sum(B.AMT_30600) as AMT_30600,sum(B.AMT_30700) as AMT_30700,
sum(B.AMT_30800) as AMT_30800,sum(B.AMT_30900) as AMT_30900,sum(B.AMT_31000) as AMT_31000,
sum(B.AMT_31001) as AMT_31001,sum(B.AMT_31100) as AMT_31100,sum(B.AMT_31200) as AMT_31200,
sum(B.AMT_31201) as AMT_31201,sum(B.AMT_31202) as AMT_31202,sum(B.AMT_31300) as AMT_31300,
sum(B.AMT_31400) as AMT_31400,sum(B.AMT_31500) as AMT_31500,sum(B.AMT_31600) as AMT_31600,
sum(B.AMT_31700) as AMT_31700,sum(B.AMT_31800) as AMT_31800,sum(B.AMT_31801) as AMT_31801,
sum(B.AMT_31900) as AMT_31900,sum(B.AMT_31901) as AMT_31901,sum(B.AMT_32000) as AMT_32000,
sum(B.AMT_32100) as AMT_32100,sum(B.AMT_32200) as AMT_32200,sum(B.AMT_32201) as AMT_32201,
sum(B.AMT_32300) as AMT_32300,sum(B.AMT_32400) as AMT_32400,sum(B.AMT_32401) as AMT_32401,
sum(B.AMT_32402) as AMT_32402,sum(B.AMT_32403) as AMT_32403,sum(B.AMT_32404) as AMT_32404,
sum(B.AMT_32500) as AMT_32500,sum(B.AMT_32501) as AMT_32501,sum(B.AMT_32502) as AMT_32502,
sum(B.AMT_32503) as AMT_32503,sum(B.AMT_32600) as AMT_32600,sum(B.AMT_32700) as AMT_32700,
sum(B.AMT_32800) as AMT_32800,sum(B.AMT_32900) as AMT_32900,sum(B.AMT_33000) as AMT_33000,
sum(B.AMT_33400) as AMT_33400,sum(B.AMT_33500) as AMT_33500,sum(B.AMT_33501) as AMT_33501,
sum(B.AMT_33502) as AMT_33502,sum(B.AMT_33800) as AMT_33800,sum(B.AMT_33801) as AMT_33801,
sum(B.AMT_34400) as AMT_34400,sum(B.AMT_34500) as AMT_34400,sum(B.AMT_34600) as AMT_34600,
sum(B.AMT_34700) as AMT_34700,sum(B.AMT_34800) as AMT_34800,sum(B.AMT_34900) as AMT_34900,
sum(B.AMT_35000) as AMT_35000,sum(B.AMT_35100) as AMT_35100,sum(B.AMT_35300) as AMT_35300,
sum(B.AMT_35301) as AMT_35301,sum(B.AMT_35400) as AMT_35400,sum(B.AMT_35401) as AMT_35401,
sum(B.AMT_35500) as AMT_35500,sum(B.AMT_35600) as AMT_35600,sum(B.AMT_35700) as AMT_35700,
sum(B.AMT_35800) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,4 as no,'Interest Expense' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50109010011','50109010012','50109010013','50109010014')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Interest Expense' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50109010011','50109010012','50109010013','50109010014')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        sum(B.AMT_10100) as AMT_10100,sum(B.AMT_20100) as AMT_20100,sum(B.AMT_20300) as AMT_20300,
        sum(B.AMT_30100) as AMT_30100,sum(B.AMT_30200) as AMT_30200,sum(B.AMT_30201) as AMT_30201,
        sum(B.AMT_30300) as AMT_30300,sum(B.AMT_30301) as AMT_30301,sum(B.AMT_30302) as AMT_30302,
        sum(B.AMT_30400) as AMT_30400,sum(B.AMT_30401) as AMT_30401,sum(B.AMT_30402) as AMT_30402,
        sum(B.AMT_30500) as AMT_30500,sum(B.AMT_30600) as AMT_30600,sum(B.AMT_30700) as AMT_30700,
sum(B.AMT_30800) as AMT_30800,sum(B.AMT_30900) as AMT_30900,sum(B.AMT_31000) as AMT_31000,
sum(B.AMT_31001) as AMT_31001,sum(B.AMT_31100) as AMT_31100,sum(B.AMT_31200) as AMT_31200,
sum(B.AMT_31201) as AMT_31201,sum(B.AMT_31202) as AMT_31202,sum(B.AMT_31300) as AMT_31300,
sum(B.AMT_31400) as AMT_31400,sum(B.AMT_31500) as AMT_31500,sum(B.AMT_31600) as AMT_31600,
sum(B.AMT_31700) as AMT_31700,sum(B.AMT_31800) as AMT_31800,sum(B.AMT_31801) as AMT_31801,
sum(B.AMT_31900) as AMT_31900,sum(B.AMT_31901) as AMT_31901,sum(B.AMT_32000) as AMT_32000,
sum(B.AMT_32100) as AMT_32100,sum(B.AMT_32200) as AMT_32200,sum(B.AMT_32201) as AMT_32201,
sum(B.AMT_32300) as AMT_32300,sum(B.AMT_32400) as AMT_32400,sum(B.AMT_32401) as AMT_32401,
sum(B.AMT_32402) as AMT_32402,sum(B.AMT_32403) as AMT_32403,sum(B.AMT_32404) as AMT_32404,
sum(B.AMT_32500) as AMT_32500,sum(B.AMT_32501) as AMT_32501,sum(B.AMT_32502) as AMT_32502,
sum(B.AMT_32503) as AMT_32503,sum(B.AMT_32600) as AMT_32600,sum(B.AMT_32700) as AMT_32700,
sum(B.AMT_32800) as AMT_32800,sum(B.AMT_32900) as AMT_32900,sum(B.AMT_33000) as AMT_33000,
sum(B.AMT_33400) as AMT_33400,sum(B.AMT_33500) as AMT_33500,sum(B.AMT_33501) as AMT_33501,
sum(B.AMT_33502) as AMT_33502,sum(B.AMT_33800) as AMT_33800,sum(B.AMT_33801) as AMT_33801,
sum(B.AMT_34400) as AMT_34400,sum(B.AMT_34500) as AMT_34400,sum(B.AMT_34600) as AMT_34600,
sum(B.AMT_34700) as AMT_34700,sum(B.AMT_34800) as AMT_34800,sum(B.AMT_34900) as AMT_34900,
sum(B.AMT_35000) as AMT_35000,sum(B.AMT_35100) as AMT_35100,sum(B.AMT_35300) as AMT_35300,
sum(B.AMT_35301) as AMT_35301,sum(B.AMT_35400) as AMT_35400,sum(B.AMT_35401) as AMT_35401,
sum(B.AMT_35500) as AMT_35500,sum(B.AMT_35600) as AMT_35600,sum(B.AMT_35700) as AMT_35700,
sum(B.AMT_35800) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,6 as no,'Commission' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('40042020011','40042030011','40042040011','40042050011','40042060011','40042070011',
 '40042010011','40042010012','40042010013','40042010014','40042010015','40042010016','40042010017',
 '40045020011','40045030011','40045040011','40045050011','40045060011','40045070011',
 '40045010011','40045010012','40045010013','40045010014','40045010015','40045010016','40045010017')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Interest Expense' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('40042020011','40042030011','40042040011','40042050011','40042060011','40042070011',
'40042010011','40042010012','40042010013','40042010014','40042010015','40042010016','40042010017',
'40045020011','40045030011','40045040011','40045050011','40045060011','40045070011',
'40045010011','40045010012','40045010013','40045010014','40045010015','40045010016','40045010017')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        sum(B.AMT_10100) as AMT_10100,sum(B.AMT_20100) as AMT_20100,sum(B.AMT_20300) as AMT_20300,
        sum(B.AMT_30100) as AMT_30100,sum(B.AMT_30200) as AMT_30200,sum(B.AMT_30201) as AMT_30201,
        sum(B.AMT_30300) as AMT_30300,sum(B.AMT_30301) as AMT_30301,sum(B.AMT_30302) as AMT_30302,
        sum(B.AMT_30400) as AMT_30400,sum(B.AMT_30401) as AMT_30401,sum(B.AMT_30402) as AMT_30402,
        sum(B.AMT_30500) as AMT_30500,sum(B.AMT_30600) as AMT_30600,sum(B.AMT_30700) as AMT_30700,
sum(B.AMT_30800) as AMT_30800,sum(B.AMT_30900) as AMT_30900,sum(B.AMT_31000) as AMT_31000,
sum(B.AMT_31001) as AMT_31001,sum(B.AMT_31100) as AMT_31100,sum(B.AMT_31200) as AMT_31200,
sum(B.AMT_31201) as AMT_31201,sum(B.AMT_31202) as AMT_31202,sum(B.AMT_31300) as AMT_31300,
sum(B.AMT_31400) as AMT_31400,sum(B.AMT_31500) as AMT_31500,sum(B.AMT_31600) as AMT_31600,
sum(B.AMT_31700) as AMT_31700,sum(B.AMT_31800) as AMT_31800,sum(B.AMT_31801) as AMT_31801,
sum(B.AMT_31900) as AMT_31900,sum(B.AMT_31901) as AMT_31901,sum(B.AMT_32000) as AMT_32000,
sum(B.AMT_32100) as AMT_32100,sum(B.AMT_32200) as AMT_32200,sum(B.AMT_32201) as AMT_32201,
sum(B.AMT_32300) as AMT_32300,sum(B.AMT_32400) as AMT_32400,sum(B.AMT_32401) as AMT_32401,
sum(B.AMT_32402) as AMT_32402,sum(B.AMT_32403) as AMT_32403,sum(B.AMT_32404) as AMT_32404,
sum(B.AMT_32500) as AMT_32500,sum(B.AMT_32501) as AMT_32501,sum(B.AMT_32502) as AMT_32502,
sum(B.AMT_32503) as AMT_32503,sum(B.AMT_32600) as AMT_32600,sum(B.AMT_32700) as AMT_32700,
sum(B.AMT_32800) as AMT_32800,sum(B.AMT_32900) as AMT_32900,sum(B.AMT_33000) as AMT_33000,
sum(B.AMT_33400) as AMT_33400,sum(B.AMT_33500) as AMT_33500,sum(B.AMT_33501) as AMT_33501,
sum(B.AMT_33502) as AMT_33502,sum(B.AMT_33800) as AMT_33800,sum(B.AMT_33801) as AMT_33801,
sum(B.AMT_34400) as AMT_34400,sum(B.AMT_34500) as AMT_34400,sum(B.AMT_34600) as AMT_34600,
sum(B.AMT_34700) as AMT_34700,sum(B.AMT_34800) as AMT_34800,sum(B.AMT_34900) as AMT_34900,
sum(B.AMT_35000) as AMT_35000,sum(B.AMT_35100) as AMT_35100,sum(B.AMT_35300) as AMT_35300,
sum(B.AMT_35301) as AMT_35301,sum(B.AMT_35400) as AMT_35400,sum(B.AMT_35401) as AMT_35401,
sum(B.AMT_35500) as AMT_35500,sum(B.AMT_35600) as AMT_35600,sum(B.AMT_35700) as AMT_35700,
sum(B.AMT_35800) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,10 as no,'Miscellaneous Income' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('40082010021','40082010031','40082010041','40082010051','40082010061','40082010071',
 '40082010011','40082010022','40082010033','40082010044','40082010055','40082010066','40082010077')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Miscellaneous Income' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('40082010021','40082010031','40082010041','40082010051','40082010061','40082010071',
'40082010011','40082010022','40082010033','40082010044','40082010055','40082010066','40082010077')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Income' as Header,'Other Income' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        sum(B.AMT_10100) as AMT_10100,sum(B.AMT_20100) as AMT_20100,sum(B.AMT_20300) as AMT_20300,
        sum(B.AMT_30100) as AMT_30100,sum(B.AMT_30200) as AMT_30200,sum(B.AMT_30201) as AMT_30201,
        sum(B.AMT_30300) as AMT_30300,sum(B.AMT_30301) as AMT_30301,sum(B.AMT_30302) as AMT_30302,
        sum(B.AMT_30400) as AMT_30400,sum(B.AMT_30401) as AMT_30401,sum(B.AMT_30402) as AMT_30402,
        sum(B.AMT_30500) as AMT_30500,sum(B.AMT_30600) as AMT_30600,sum(B.AMT_30700) as AMT_30700,
sum(B.AMT_30800) as AMT_30800,sum(B.AMT_30900) as AMT_30900,sum(B.AMT_31000) as AMT_31000,
sum(B.AMT_31001) as AMT_31001,sum(B.AMT_31100) as AMT_31100,sum(B.AMT_31200) as AMT_31200,
sum(B.AMT_31201) as AMT_31201,sum(B.AMT_31202) as AMT_31202,sum(B.AMT_31300) as AMT_31300,
sum(B.AMT_31400) as AMT_31400,sum(B.AMT_31500) as AMT_31500,sum(B.AMT_31600) as AMT_31600,
sum(B.AMT_31700) as AMT_31700,sum(B.AMT_31800) as AMT_31800,sum(B.AMT_31801) as AMT_31801,
sum(B.AMT_31900) as AMT_31900,sum(B.AMT_31901) as AMT_31901,sum(B.AMT_32000) as AMT_32000,
sum(B.AMT_32100) as AMT_32100,sum(B.AMT_32200) as AMT_32200,sum(B.AMT_32201) as AMT_32201,
sum(B.AMT_32300) as AMT_32300,sum(B.AMT_32400) as AMT_32400,sum(B.AMT_32401) as AMT_32401,
sum(B.AMT_32402) as AMT_32402,sum(B.AMT_32403) as AMT_32403,sum(B.AMT_32404) as AMT_32404,
sum(B.AMT_32500) as AMT_32500,sum(B.AMT_32501) as AMT_32501,sum(B.AMT_32502) as AMT_32502,
sum(B.AMT_32503) as AMT_32503,sum(B.AMT_32600) as AMT_32600,sum(B.AMT_32700) as AMT_32700,
sum(B.AMT_32800) as AMT_32800,sum(B.AMT_32900) as AMT_32900,sum(B.AMT_33000) as AMT_33000,
sum(B.AMT_33400) as AMT_33400,sum(B.AMT_33500) as AMT_33500,sum(B.AMT_33501) as AMT_33501,
sum(B.AMT_33502) as AMT_33502,sum(B.AMT_33800) as AMT_33800,sum(B.AMT_33801) as AMT_33801,
sum(B.AMT_34400) as AMT_34400,sum(B.AMT_34500) as AMT_34400,sum(B.AMT_34600) as AMT_34600,
sum(B.AMT_34700) as AMT_34700,sum(B.AMT_34800) as AMT_34800,sum(B.AMT_34900) as AMT_34900,
sum(B.AMT_35000) as AMT_35000,sum(B.AMT_35100) as AMT_35100,sum(B.AMT_35300) as AMT_35300,
sum(B.AMT_35301) as AMT_35301,sum(B.AMT_35400) as AMT_35400,sum(B.AMT_35401) as AMT_35401,
sum(B.AMT_35500) as AMT_35500,sum(B.AMT_35600) as AMT_35600,sum(B.AMT_35700) as AMT_35700,
sum(B.AMT_35800) as AMT_35800

 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,12 as no,'Foreign Transaction Income' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('40101010011','40101010031','40101010021','40101010041','40101010051','40101010061',
 '40102020011','40102030011','40102040011','40102050011','40102060011','40102070011','40103020011','40103030011','40103040011',
 '40103050011','40103060011','40103070011','40104020011','40104030011','40104040011','40104050011','40104060011','40104070011',
 '40101010012','40101010013','40101010014','40101010015','40101010016','40101010017','40102010011','40102010012','40102010013',
 '40102010014','40102010015','40102010016','40102010017','40103010011','40103010012','40103010013','40103010014','40103010015','40103010016','40103010017',
 '40104010011','40104010012','40104010013','40104010014','40104010015','40104010016','40104010017')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Foreign Transaction Income' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('40101010011','40101010031','40101010021','40101010041','40101010051','40101010061',
 '40102020011','40102030011','40102040011','40102050011','40102060011','40102070011','40103020011','40103030011','40103040011',
 '40103050011','40103060011','40103070011','40104020011','40104030011','40104040011','40104050011','40104060011','40104070011',
 '40101010012','40101010013','40101010014','40101010015','40101010016','40101010017','40102010011','40102010012','40102010013',
 '40102010014','40102010015','40102010016','40102010017','40103010011','40103010012','40103010013','40103010014','40103010015','40103010016','40103010017',
 '40104010011','40104010012','40104010013','40104010014','40104010015','40104010016','40104010017')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid
-------------------------------------------------------Account Number Expense MMK Rate------------------------------------------------------
union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800

 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,15 as no,'Travel and Entertainment' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50213010021','50213010031','50213010041','50213010051','50213010061','50213010071',
 '50213010011','50213010022','50213010033','50213010044','50213010055','50213010066','50213010077')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Travel and Entertainment' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50213010021','50213010031','50213010041','50213010051','50213010061','50213010071',
'50213010011','50213010022','50213010033','50213010044','50213010055','50213010066','50213010077')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,16 as no,'Fees and Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50234010021','50234010031','50234010041','50234010051','50234010061','50234010071',
 '50236010021','50236010031','50236010041','50236010051','50236010061','50236010071',
 '50234010011','50234010022','50234010033','50234010044','50234010055','50234010066','50234010077',
 '50236010011','50236010022','50236010033','50236010044','50236010055','50236010066','50236010077')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Fees and Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50234010021','50234010031','50234010041','50234010051','50234010061','50234010071',
 '50236010021','50236010031','50236010041','50236010051','50236010061','50236010071',
 '50234010011','50234010022','50234010033','50234010044','50234010055','50234010066','50234010077',
 '50236010011','50236010022','50236010033','50236010044','50236010055','50236010066','50236010077')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,17 as no,'Sales and Marketing Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50273010011','50273010021')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Sales and Marketing Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50273010011','50273010021')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,18 as no,'Repair and Maintenance Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50286010021','50286010031','50286010041','50286010051','50286010061','50286010071',
 '50286010011','50286010022','50286010033','50286010044','50286010055','50286010066','50286010077')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Repair and Maintenance Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50286010021','50286010031','50286010041','50286010051','50286010061','50286010071',
'50286010011','50286010022','50286010033','50286010044','50286010055','50286010066','50286010077')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,19 as no,'Supply and Services Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50122020011','50122030011','50122040011','50122050011','50122060011','50122070011',
 '50293020011','50293030011','50293040011','50293050011','50293060011','50293070011',
 '50296020011','50296030011','50296040011','50296050011','50296060011','50296070011',
 '50122010011','50122010012','50122010013','50122010014','50122010015','50122010016','50122010017',
 '50293010011','50293010012','50293010013','50293010014','50293010015','50293010016','50293010017',
 '50296010011','50296010012','50296010013','50296010014','50296010015','50296010016','50296010017')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Supply and Services Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50122020011','50122030011','50122040011','50122050011','50122060011','50122070011',
'50293020011','50293030011','50293040011','50293050011','50293060011','50293070011',
 '50296020011','50296030011','50296040011','50296050011','50296060011','50296070011',
 '50122010011','50122010012','50122010013','50122010014','50122010015','50122010016','50122010017',
 '50293010011','50293010012','50293010013','50293010014','50293010015','50293010016','50293010017',
 '50296010011','50296010012','50296010013','50296010014','50296010015','50296010016','50296010017')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,20 as no,'Card Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50294010011','50294010021')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Card Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50294010011','50294010021')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,22 as no,'Misceallenous Expenses' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50145010011','50145010022','50145010021','50145010033','50145010031','50145010044',
 '50145010041','50145010055','50145010051','50145010066','50145010061','50145010077','50145010071',
 '50314010011','50314010022','50314010021','50314010033','50314010031','50314010044',
 '50314010041','50314010055','50314010051','50314010066','50314010061','50314010077','50314010071')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Card Expenses' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50145010011','50145010022','50145010021','50145010033','50145010031','50145010044',
 '50145010041','50145010055','50145010051','50145010066','50145010061','50145010077','50145010071',
 '50314010011','50314010022','50314010021','50314010033','50314010031','50314010044',
 '50314010041','50314010055','50314010051','50314010066','50314010061','50314010077','50314010071')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid

union all
 select 'Expenture' as Header,'Other Expenses' as temp,B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid,
        abs(sum(B.AMT_10100)) as AMT_10100,abs(sum(B.AMT_20100)) as AMT_20100,abs(sum(B.AMT_20300)) as AMT_20300,
        abs(sum(B.AMT_30100)) as AMT_30100,abs(sum(B.AMT_30200)) as AMT_30200,abs(sum(B.AMT_30201)) as AMT_30201,
        abs(sum(B.AMT_30300)) as AMT_30300,abs(sum(B.AMT_30301)) as AMT_30301,abs(sum(B.AMT_30302)) as AMT_30302,
        abs(sum(B.AMT_30400)) as AMT_30400,abs(sum(B.AMT_30401)) as AMT_30401,abs(sum(B.AMT_30402)) as AMT_30402,
        abs(sum(B.AMT_30500)) as AMT_30500,abs(sum(B.AMT_30600)) as AMT_30600,abs(sum(B.AMT_30700)) as AMT_30700,
abs(sum(B.AMT_30800)) as AMT_30800,abs(sum(B.AMT_30900)) as AMT_30900,abs(sum(B.AMT_31000)) as AMT_31000,
abs(sum(B.AMT_31001)) as AMT_31001,abs(sum(B.AMT_31100)) as AMT_31100,abs(sum(B.AMT_31200)) as AMT_31200,
abs(sum(B.AMT_31201)) as AMT_31201,abs(sum(B.AMT_31202)) as AMT_31202,abs(sum(B.AMT_31300)) as AMT_31300,
abs(sum(B.AMT_31400)) as AMT_31400,abs(sum(B.AMT_31500)) as AMT_31500,abs(sum(B.AMT_31600)) as AMT_31600,
abs(sum(B.AMT_31700)) as AMT_31700,abs(sum(B.AMT_31800)) as AMT_31800,abs(sum(B.AMT_31801)) as AMT_31801,
abs(sum(B.AMT_31900)) as AMT_31900,abs(sum(B.AMT_31901)) as AMT_31901,abs(sum(B.AMT_32000)) as AMT_32000,
abs(sum(B.AMT_32100)) as AMT_32100,abs(sum(B.AMT_32200)) as AMT_32200,abs(sum(B.AMT_32201)) as AMT_32201,
abs(sum(B.AMT_32300)) as AMT_32300,abs(sum(B.AMT_32400)) as AMT_32400,abs(sum(B.AMT_32401)) as AMT_32401,
abs(sum(B.AMT_32402)) as AMT_32402,abs(sum(B.AMT_32403)) as AMT_32403,abs(sum(B.AMT_32404)) as AMT_32404,
abs(sum(B.AMT_32500)) as AMT_32500,abs(sum(B.AMT_32501)) as AMT_32501,abs(sum(B.AMT_32502)) as AMT_32502,
abs(sum(B.AMT_32503)) as AMT_32503,abs(sum(B.AMT_32600)) as AMT_32600,abs(sum(B.AMT_32700)) as AMT_32700,
abs(sum(B.AMT_32800)) as AMT_32800,abs(sum(B.AMT_32900)) as AMT_32900,abs(sum(B.AMT_33000)) as AMT_33000,
abs(sum(B.AMT_33400)) as AMT_33400,abs(sum(B.AMT_33500)) as AMT_33500,abs(sum(B.AMT_33501)) as AMT_33501,
abs(sum(B.AMT_33502)) as AMT_33502,abs(sum(B.AMT_33800)) as AMT_33800,abs(sum(B.AMT_33801)) as AMT_33801,
abs(sum(B.AMT_34400)) as AMT_34400,abs(sum(B.AMT_34500)) as AMT_34400,abs(sum(B.AMT_34600)) as AMT_34600,
abs(sum(B.AMT_34700)) as AMT_34700,abs(sum(B.AMT_34800)) as AMT_34800,abs(sum(B.AMT_34900)) as AMT_34900,
abs(sum(B.AMT_35000)) as AMT_35000,abs(sum(B.AMT_35100)) as AMT_35100,abs(sum(B.AMT_35300)) as AMT_35300,
abs(sum(B.AMT_35301)) as AMT_35301,abs(sum(B.AMT_35400)) as AMT_35400,abs(sum(B.AMT_35401)) as AMT_35401,
abs(sum(B.AMT_35500)) as AMT_35500,abs(sum(B.AMT_35600)) as AMT_35600,abs(sum(B.AMT_35700)) as AMT_35700,
abs(sum(B.AMT_35800)) as AMT_35800
 from 
( select GL.gl_sub_head_code,GL.no,GL.description,GL.gl_sub_head_desc,GL.cur,substr(GL.foracid,6,length(GL.foracid)-5) as foracid,
       case when X.sol_id ='10100' then x.Closing else 0 end as AMT_10100,
       case when X.sol_id ='20100' then x.Closing else 0 end as AMT_20100,
 case when X.sol_id ='20300' then x.Closing else 0 end as AMT_20300,
 case when X.sol_id ='30100' then x.Closing else 0 end as AMT_30100,
 case when X.sol_id ='30200' then x.Closing else 0 end as AMT_30200,
 case when X.sol_id ='30201' then x.Closing else 0 end as AMT_30201,
 case when X.sol_id ='30300' then x.Closing else 0 end as AMT_30300,
 case when X.sol_id ='30301' then x.Closing else 0 end as AMT_30301,
 case when X.sol_id ='30302' then x.Closing else 0 end as AMT_30302,
 case when X.sol_id ='30400' then x.Closing else 0 end as AMT_30400,
 case when X.sol_id ='30401' then x.Closing else 0 end as AMT_30401,
 case when X.sol_id ='30402' then x.Closing else 0 end as AMT_30402,
 case when X.sol_id ='30500' then x.Closing else 0 end as AMT_30500,
 case when X.sol_id ='30600' then x.Closing else 0 end as AMT_30600,
 case when X.sol_id ='30700' then x.Closing else 0 end as AMT_30700,
 case when X.sol_id ='30800' then x.Closing else 0 end as AMT_30800,
 case when X.sol_id ='30900' then x.Closing else 0 end as AMT_30900,
 case when X.sol_id ='31000' then x.Closing else 0 end as AMT_31000,
 case when X.sol_id ='31001' then x.Closing else 0 end as AMT_31001,
 case when X.sol_id ='31100' then x.Closing else 0 end as AMT_31100,
 case when X.sol_id ='31200' then x.Closing else 0 end as AMT_31200,
 case when X.sol_id ='31201' then x.Closing else 0 end as AMT_31201,
 case when X.sol_id ='31202' then x.Closing else 0 end as AMT_31202,
 case when X.sol_id ='31300' then x.Closing else 0 end as AMT_31300,
 case when X.sol_id ='31400' then x.Closing else 0 end as AMT_31400,
 case when X.sol_id ='31500' then x.Closing else 0 end as AMT_31500,
 case when X.sol_id ='31600' then x.Closing else 0 end as AMT_31600,
 case when X.sol_id ='31700' then x.Closing else 0 end as AMT_31700,
 case when X.sol_id ='31800' then x.Closing else 0 end as AMT_31800,
 case when X.sol_id ='31801' then x.Closing else 0 end as AMT_31801,
 case when X.sol_id ='31900' then x.Closing else 0 end as AMT_31900,
 case when X.sol_id ='31901' then x.Closing else 0 end as AMT_31901,
 case when X.sol_id ='32000' then x.Closing else 0 end as AMT_32000,
 case when X.sol_id ='32100' then x.Closing else 0 end as AMT_32100,
 case when X.sol_id ='32200' then x.Closing else 0 end as AMT_32200,
 case when X.sol_id ='32201' then x.Closing else 0 end as AMT_32201,
 case when X.sol_id ='32300' then x.Closing else 0 end as AMT_32300,
 case when X.sol_id ='32400' then x.Closing else 0 end as AMT_32400,
 case when X.sol_id ='32401' then x.Closing else 0 end as AMT_32401,
 case when X.sol_id ='32402' then x.Closing else 0 end as AMT_32402,
 case when X.sol_id ='32403' then x.Closing else 0 end as AMT_32403,
 case when X.sol_id ='32404' then x.Closing else 0 end as AMT_32404,
 case when X.sol_id ='32500' then x.Closing else 0 end as AMT_32500,
 case when X.sol_id ='32501' then x.Closing else 0 end as AMT_32501,
 case when X.sol_id ='32502' then x.Closing else 0 end as AMT_32502,
 case when X.sol_id ='32503' then x.Closing else 0 end as AMT_32503,
 case when X.sol_id ='32600' then x.Closing else 0 end as AMT_32600,
 case when X.sol_id ='32700' then x.Closing else 0 end as AMT_32700,
 case when X.sol_id ='32800' then x.Closing else 0 end as AMT_32800,
 case when X.sol_id ='32900' then x.Closing else 0 end as AMT_32900,
 case when X.sol_id ='33000' then x.Closing else 0 end as AMT_33000,
 case when X.sol_id ='33400' then x.Closing else 0 end as AMT_33400,
 case when X.sol_id ='33500' then x.Closing else 0 end as AMT_33500,
 case when X.sol_id ='33501' then x.Closing else 0 end as AMT_33501,
 case when X.sol_id ='33502' then x.Closing else 0 end as AMT_33502,
 case when X.sol_id ='33800' then x.Closing else 0 end as AMT_33800,
 case when X.sol_id ='33801' then x.Closing else 0 end as AMT_33801,
 case when X.sol_id ='34400' then x.Closing else 0 end as AMT_34400,
 case when X.sol_id ='34500' then x.Closing else 0 end as AMT_34500,
 case when X.sol_id ='34600' then x.Closing else 0 end as AMT_34600,
 case when X.sol_id ='34700' then x.Closing else 0 end as AMT_34700,
 case when X.sol_id ='34800' then x.Closing else 0 end as AMT_34800,
 case when X.sol_id ='34900' then x.Closing else 0 end as AMT_34900,
 case when X.sol_id ='35000' then x.Closing else 0 end as AMT_35000,
 case when X.sol_id ='35100' then x.Closing else 0 end as AMT_35100,
 case when X.sol_id ='35300' then x.Closing else 0 end as AMT_35300,
 case when X.sol_id ='35301' then x.Closing else 0 end as AMT_35301,
 case when X.sol_id ='35400' then x.Closing else 0 end as AMT_35400,
 case when X.sol_id ='35401' then x.Closing else 0 end as AMT_35401,
 case when X.sol_id ='35500' then x.Closing else 0 end as AMT_35500,
 case when X.sol_id ='35600' then x.Closing else 0 end as AMT_35600,
 case when X.sol_id ='35700' then x.Closing else 0 end as AMT_35700,
 case when X.sol_id ='35800' then x.Closing else 0 end as AMT_35800
 from
 (select gam.gl_sub_head_code,24 as no,'Rate and Tax' as description,gam.acct_name as gl_sub_head_desc ,gam.acct_crncy_code as cur,gam.foracid as foracid
 from tbaadm.gam 
 where substr(gam.foracid,6,length(gam.foracid)-5) in ('50301010011','50301010012','50301020011','50301010013','50301030011','50301010014',
 '50301040011','50301010015','50301050011','50301010016','50301060011','50301010017','50301070011',
 '50301010021','50301010022','50301020021','50301010023','50301030021','50301010024',
 '50301040021','50301010025','50301050021','50301010026','50301060021','50301010027','50301070021')) GL 
  left join 
  ( select q.gl_sub_head_code,
        q.description,
        q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid,
        sum(q.tran_date_bal) as Closing
from
(select gam.gl_sub_head_code,
   'Rate and Tax' as description,
   gam.acct_name as gl_sub_head_desc, gam.sol_id,gam.acct_crncy_code as cur,gam.foracid as foracid,
   eab.tran_date_bal
from tbaadm.gam gam, tbaadm.eab eab
where gam.acid = eab.acid
and gam.acct_crncy_code = eab.eab_crncy_code
and substr(gam.foracid,6,length(gam.foracid)-5) in ('50301010011','50301010012','50301020011','50301010013','50301030011','50301010014',
 '50301040011','50301010015','50301050011','50301010016','50301060011','50301010017','50301070011',
 '50301010021','50301010022','50301020021','50301010023','50301030021','50301010024',
 '50301040021','50301010025','50301050021','50301010026','50301060021','50301010027','50301070021')
and eab.eod_date <= TO_DATE( ci_TranDate, 'dd-MM-yyyy' )
and eab.end_eod_date >= TO_DATE( ci_TranDate, 'dd-MM-yyyy' ))q
group by q.gl_sub_head_code,q.description,q.gl_sub_head_desc,q.sol_id,q.cur,q.foracid) X
on X.gl_sub_head_code = GL.gl_sub_head_code
and X.cur = GL.cur
and X.foracid = GL.foracid) B
group by B.gl_sub_head_code,B.no,B.description,B.gl_sub_head_desc,B.cur,B.foracid
) HEAD) Heading
group by Heading.Header,Heading.gl_sub_head_code,Heading.no,Heading.description,Heading.gl_sub_head_desc,Heading.temp,Heading.foracid)H
order by H.No,H.gl_sub_head_code,H.foracid;
-------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE FIN_PROFIT_LOSS_MONTH_BRANCH(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
-------------------------------------------------------------
	--Variable declaration
-------------------------------------------------------------
    V_Header Varchar(100);
v_gl_sub_head_code tbaadm.gam.gl_sub_head_code%type;
v_no Number;
V_description Varchar(200);
v_gl_sub_head_desc Varchar(200);
v_foracid tbaadm.gam.foracid%type;
V_AMT_10100 tbaadm.eab.tran_date_bal%type;
V_AMT_20100 tbaadm.eab.tran_date_bal%type;
V_AMT_20300 tbaadm.eab.tran_date_bal%type;
V_AMT_30100 tbaadm.eab.tran_date_bal%type;
V_AMT_30200 tbaadm.eab.tran_date_bal%type;
V_AMT_30201 tbaadm.eab.tran_date_bal%type;
V_AMT_30300 tbaadm.eab.tran_date_bal%type;
V_AMT_30301 tbaadm.eab.tran_date_bal%type;
V_AMT_30302 tbaadm.eab.tran_date_bal%type;
V_AMT_30400 tbaadm.eab.tran_date_bal%type;
V_AMT_30401 tbaadm.eab.tran_date_bal%type;
V_AMT_30402 tbaadm.eab.tran_date_bal%type;
V_AMT_30500 tbaadm.eab.tran_date_bal%type;
V_AMT_30600 tbaadm.eab.tran_date_bal%type;
V_AMT_30700 tbaadm.eab.tran_date_bal%type;
V_AMT_30800 tbaadm.eab.tran_date_bal%type;
V_AMT_30900 tbaadm.eab.tran_date_bal%type;
V_AMT_31000 tbaadm.eab.tran_date_bal%type;
V_AMT_31001 tbaadm.eab.tran_date_bal%type;
V_AMT_31100 tbaadm.eab.tran_date_bal%type;
V_AMT_31200 tbaadm.eab.tran_date_bal%type;
V_AMT_31201 tbaadm.eab.tran_date_bal%type;
V_AMT_31202 tbaadm.eab.tran_date_bal%type;
V_AMT_31300 tbaadm.eab.tran_date_bal%type;
V_AMT_31400 tbaadm.eab.tran_date_bal%type;
V_AMT_31500 tbaadm.eab.tran_date_bal%type;
V_AMT_31600 tbaadm.eab.tran_date_bal%type;
V_AMT_31700 tbaadm.eab.tran_date_bal%type;
V_AMT_31800 tbaadm.eab.tran_date_bal%type;
V_AMT_31801 tbaadm.eab.tran_date_bal%type;
V_AMT_31900 tbaadm.eab.tran_date_bal%type;
V_AMT_31901 tbaadm.eab.tran_date_bal%type;
V_AMT_32000 tbaadm.eab.tran_date_bal%type;
V_AMT_32100 tbaadm.eab.tran_date_bal%type;
V_AMT_32200 tbaadm.eab.tran_date_bal%type;
V_AMT_32201 tbaadm.eab.tran_date_bal%type;
V_AMT_32300 tbaadm.eab.tran_date_bal%type;
V_AMT_32400 tbaadm.eab.tran_date_bal%type;
V_AMT_32401 tbaadm.eab.tran_date_bal%type;
V_AMT_32402 tbaadm.eab.tran_date_bal%type;
V_AMT_32403 tbaadm.eab.tran_date_bal%type;
V_AMT_32404 tbaadm.eab.tran_date_bal%type;
V_AMT_32500 tbaadm.eab.tran_date_bal%type;
V_AMT_32501 tbaadm.eab.tran_date_bal%type;
V_AMT_32502 tbaadm.eab.tran_date_bal%type;
V_AMT_32503 tbaadm.eab.tran_date_bal%type;
V_AMT_32600 tbaadm.eab.tran_date_bal%type;
V_AMT_32700 tbaadm.eab.tran_date_bal%type;
V_AMT_32800 tbaadm.eab.tran_date_bal%type;
V_AMT_32900 tbaadm.eab.tran_date_bal%type;
V_AMT_33000 tbaadm.eab.tran_date_bal%type;
V_AMT_33400 tbaadm.eab.tran_date_bal%type;
V_AMT_33500 tbaadm.eab.tran_date_bal%type;
V_AMT_33501 tbaadm.eab.tran_date_bal%type;
V_AMT_33502 tbaadm.eab.tran_date_bal%type;
V_AMT_33800 tbaadm.eab.tran_date_bal%type;
V_AMT_33801 tbaadm.eab.tran_date_bal%type;
V_AMT_34400 tbaadm.eab.tran_date_bal%type;
V_AMT_34500 tbaadm.eab.tran_date_bal%type;
V_AMT_34600 tbaadm.eab.tran_date_bal%type;
V_AMT_34700 tbaadm.eab.tran_date_bal%type;
V_AMT_34800 tbaadm.eab.tran_date_bal%type;
V_AMT_34900 tbaadm.eab.tran_date_bal%type;
V_AMT_35000 tbaadm.eab.tran_date_bal%type;
V_AMT_35100 tbaadm.eab.tran_date_bal%type;
V_AMT_35300 tbaadm.eab.tran_date_bal%type;
V_AMT_35301 tbaadm.eab.tran_date_bal%type;
V_AMT_35400 tbaadm.eab.tran_date_bal%type;
V_AMT_35401 tbaadm.eab.tran_date_bal%type;
V_AMT_35500 tbaadm.eab.tran_date_bal%type;
V_AMT_35600 tbaadm.eab.tran_date_bal%type;
V_AMT_35700 tbaadm.eab.tran_date_bal%type;
V_AMT_35800 tbaadm.eab.tran_date_bal%type;
V_temp Varchar(100);
     
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
     
     -----------------------------------------------------------------
     if(vi_TranDate  is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || 0 );
		
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
 -----------------------------------------------------------------------------------------------------------    
    
     IF NOT ExtractData%ISOPEN THEN  -- for today date
        --{
          BEGIN
          --{
            OPEN ExtractData ( vi_TranDate);
          --}      
          END;
        --}
        END IF;
      
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO  V_Header ,V_temp,v_gl_sub_head_code,v_no,V_description,v_gl_sub_head_desc,v_foracid,
V_AMT_10100,V_AMT_20100,V_AMT_20300,V_AMT_30100,V_AMT_30200,V_AMT_30201,V_AMT_30300,V_AMT_30301,V_AMT_30302,V_AMT_30400,
V_AMT_30401,V_AMT_30402,V_AMT_30500,V_AMT_30600,V_AMT_30700,V_AMT_30800,V_AMT_30900,V_AMT_31000,V_AMT_31001,V_AMT_31100,
V_AMT_31200,V_AMT_31201,V_AMT_31202,V_AMT_31300,V_AMT_31400,V_AMT_31500,V_AMT_31600,V_AMT_31700,V_AMT_31800,V_AMT_31801,
V_AMT_31900,V_AMT_31901,V_AMT_32000,V_AMT_32100,V_AMT_32200,V_AMT_32201,V_AMT_32300,V_AMT_32400,V_AMT_32401,V_AMT_32402,
V_AMT_32403,V_AMT_32404,V_AMT_32500,V_AMT_32501,V_AMT_32502,V_AMT_32503,V_AMT_32600,V_AMT_32700,V_AMT_32800,V_AMT_32900,
V_AMT_33000,V_AMT_33400,V_AMT_33500,V_AMT_33501,V_AMT_33502,V_AMT_33800,V_AMT_33801,V_AMT_34400,V_AMT_34500,V_AMT_34600,
V_AMT_34700,V_AMT_34800,V_AMT_34900,V_AMT_35000,V_AMT_35100,V_AMT_35300,V_AMT_35301,V_AMT_35400,V_AMT_35401,V_AMT_35500,
V_AMT_35600,V_AMT_35700,V_AMT_35800;
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

    out_rec:= ( V_Header || '|' ||
                V_temp|| '|' ||
              v_gl_sub_head_code|| '|' ||
              v_no|| '|' ||
              V_description|| '|' ||
              v_gl_sub_head_desc|| '|' ||
              v_foracid|| '|' ||
              V_AMT_10100|| '|' ||
              V_AMT_20100|| '|' ||
              V_AMT_20300|| '|' ||
              V_AMT_30100|| '|' ||
              V_AMT_30200|| '|' ||
              V_AMT_30201|| '|' ||
              V_AMT_30300|| '|' ||
              V_AMT_30301|| '|' ||
              V_AMT_30302|| '|' ||
              V_AMT_30400|| '|' ||
              V_AMT_30401|| '|' ||
              V_AMT_30402|| '|' ||
              V_AMT_30500|| '|' ||
              V_AMT_30600|| '|' ||
              V_AMT_30700|| '|' ||
              V_AMT_30800|| '|' ||
              V_AMT_30900|| '|' ||
              V_AMT_31000|| '|' ||
              V_AMT_31001|| '|' ||
              V_AMT_31100|| '|' ||
              V_AMT_31200|| '|' ||
              V_AMT_31201|| '|' ||
              V_AMT_31202|| '|' ||
              V_AMT_31300|| '|' ||
              V_AMT_31400|| '|' ||
              V_AMT_31500|| '|' ||
              V_AMT_31600|| '|' ||
              V_AMT_31700|| '|' ||
              V_AMT_31800|| '|' ||
              V_AMT_31801|| '|' ||
              V_AMT_31900|| '|' ||
              V_AMT_31901|| '|' ||
              V_AMT_32000|| '|' ||
              V_AMT_32100|| '|' ||
              V_AMT_32200|| '|' ||
              V_AMT_32201|| '|' ||
              V_AMT_32300|| '|' ||
              V_AMT_32400|| '|' ||
              V_AMT_32401|| '|' ||
              V_AMT_32402|| '|' ||
              V_AMT_32403|| '|' ||
              V_AMT_32404|| '|' ||
              V_AMT_32500|| '|' ||
              V_AMT_32501|| '|' ||
              V_AMT_32502|| '|' ||
              V_AMT_32503|| '|' ||
              V_AMT_32600|| '|' ||
              V_AMT_32700|| '|' ||
              V_AMT_32800|| '|' ||
              V_AMT_32900|| '|' ||
              V_AMT_33000|| '|' ||
              V_AMT_33400|| '|' ||
              V_AMT_33500|| '|' ||
              V_AMT_33501|| '|' ||
              V_AMT_33502|| '|' ||
              V_AMT_33800|| '|' ||
              V_AMT_33801|| '|' ||
              V_AMT_34400|| '|' ||
              V_AMT_34500|| '|' ||
              V_AMT_34600|| '|' ||
              V_AMT_34700|| '|' ||
              V_AMT_34800|| '|' ||
              V_AMT_34900|| '|' ||
              V_AMT_35000|| '|' ||
              V_AMT_35100|| '|' ||
              V_AMT_35300|| '|' ||
              V_AMT_35301|| '|' ||
              V_AMT_35400|| '|' ||
              V_AMT_35401|| '|' ||
              V_AMT_35500|| '|' ||
              V_AMT_35600|| '|' ||
              V_AMT_35700|| '|' ||
              V_AMT_35800); 
  
			dbms_output.put_line(out_rec);
     
  END FIN_PROFIT_LOSS_MONTH_BRANCH;

END FIN_PROFIT_LOSS_MONTH_BRANCH;
/
