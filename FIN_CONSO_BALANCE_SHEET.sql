CREATE OR REPLACE PACKAGE                      FIN_CONSO_BALANCE_SHEET AS 

subtype limited_string is varchar2(20000);

  PROCEDURE FIN_CONSO_BALANCE_SHEET(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string );

END FIN_CONSO_BALANCE_SHEET;
/


CREATE OR REPLACE PACKAGE BODY                                                             FIN_CONSO_BALANCE_SHEET
AS
  -------------------------------------------------------------------------------------
  --Update User -Saung Hnin Oo--------------------------------------
  ---Update Date - 2-5-2017------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType ; -- Input Parse Array
  
  vi_Date VARCHAR2(20);
   vi_Currency  VARCHAR2(15);                 -- Input to procedure
  vi_CurType  VARCHAR2(20); -- Input to procedure
  -- vi_zoneCode   VARCHAR(6);           -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  
    CURSOR ExtractData (ci_Date VARCHAR2,ci_Currency VARCHAR2)
  IS
  select sum (T.Capital_amt+4138000000),
        sum (T.Reserves_amt),
        sum (T.RetainProfit_amt),
        sum (T.CurrentDeposit_amt),
        sum (T.CurrentDepositFCY_amt),
        sum (T.SavingDeposit_amt),
        sum (T.SpecialDeposit_amt),
        sum (T.FixedDepoist_amt),
        sum (T.DOBCurrentDeposit_amt),
        sum (T.DOBCurrentDepositFCY_amt),
        sum (T.DOBSavingDeposit_amt),
        sum (T.DOBFixedDepoist_amt),
        sum (T.BorrowStateBank_amt),
        sum (T.BorrowPrivateBank_amt),
        sum (T.BillPayables_amt),
        sum (T.OtherLiabilities_amt),
        sum (T.Acceptances_amt),
       sum (T.AIncome_amt),
         abs(sum (T.CashInHand)),
        abs( sum (T.CashInHandFCY_amt)),
          abs( sum (T.CashAtATM_amt)),
          abs(  sum (T.CashInTransit_amt)),
           abs(  sum (T.AccCBM_amt)),
            abs(  sum (T.AccCBMFCY_amt)),
             abs(  sum (T.AccStateBank_amt)),
             abs(   sum (T.AccPrivateBank_amt)),
               abs(  sum (T.AccForeignBank_amt)),
               abs(   sum (T.Government_amt)),
                abs(   sum (T.Public_amt)),
                 abs(  sum (T.DepositAuction_amt)),
                  abs(  sum (T.ShortLAB_amt)),
                    abs( sum (T.LAB_amt)),
                    abs(  sum (T.BillsReceivables_amt)),
                     abs(  sum (T.FixedAssets_amt)),
                       abs( sum (T.OtherAssets_amt)),
                      abs(   sum (T.AGuarantees_amt)),
                       abs(   sum (T.Charges_amt))
                           


from (select 
CASE WHEN q.g_code ='L01'   THEN (q.amt)                    END as Capital_amt,
CASE WHEN q.g_code ='L02'   THEN q.amt                                 END as Reserves_amt,
CASE WHEN q.g_code ='L03'   THEN q.amt                                 END as RetainProfit_amt,
CASE WHEN q.g_code ='L11' and q.gl_head_code ='70101'  THEN q.amt      END as CurrentDeposit_amt,
CASE WHEN q.g_code ='L11' and q.gl_head_code ='70103'  THEN q.amt      END as CurrentDepositFCY_amt,
CASE WHEN q.g_code ='L13'   THEN q.amt                                 END as SavingDeposit_amt,
CASE WHEN q.g_code ='L15'   THEN q.amt                                 END as SpecialDeposit_amt,
CASE WHEN q.g_code ='L17'   THEN q.amt                                 END as FixedDepoist_amt,
CASE WHEN q.g_code in ('L21','L22' )  THEN q.amt                       END as DOBCurrentDeposit_amt,
CASE WHEN q.g_code ='L23'   THEN q.amt                                 END as DOBCurrentDepositFCY_amt,
CASE WHEN q.g_code ='L24'   THEN q.amt                                 END as DOBSavingDeposit_amt,
CASE WHEN q.g_code ='L26'   THEN q.amt                                 END as DOBFixedDepoist_amt,
CASE WHEN q.g_code ='L31' and q.gl_head_code ='70141'    THEN q.amt    END as BorrowStateBank_amt,
CASE WHEN q.g_code ='L31' and q.gl_head_code ='70142'   THEN q.amt     END as BorrowPrivateBank_amt,
CASE WHEN q.g_code in ('L33','L34','L35','L36','L39')   THEN q.amt     END as BillPayables_amt,
CASE WHEN q.g_code not in ('L01' , 'L02' ,'L03','L11','L13',
'L15' ,'L17','L21','L22','L23','L24','L26','L31','L33','L34','L35',
'L36','L39','L80','L40') and q.gl_head_code 
not in ('70101','70103','70141','70142','60131','60161','60133') 
and q.g_code not like 'A%' THEN q.amt                  END as OtherLiabilities_amt,
CASE WHEN q.g_code ='L80'   THEN q.amt                                 END as Acceptances_amt,
CASE WHEN q.g_code ='L40'   THEN q.amt                                 END as AIncome_amt,
CASE WHEN q.g_code ='A01'   THEN q.amt                                 END as   CashInHand,
CASE WHEN q.g_code ='A02'   THEN q.amt                                 END as CashInHandFCY_amt,
CASE WHEN q.g_code ='A03'   THEN q.amt                                 END as CashAtATM_amt,
CASE WHEN q.g_code ='A55'   THEN q.amt                                 END as CashInTransit_amt,
CASE WHEN q.g_code ='A04'  and q.gl_head_code ='10106'   THEN q.amt    END as AccCBM_amt,
CASE WHEN q.g_code ='A05'   THEN q.amt                                 END as AccCBMFCY_amt,
CASE WHEN q.g_code ='A06'   THEN q.amt                                 END as AccStateBank_amt,
CASE WHEN q.g_code ='A07'   THEN q.amt                                 END as AccPrivateBank_amt,
CASE WHEN q.g_code ='A08'   THEN q.amt                                 END as AccForeignBank_amt,
CASE WHEN q.g_code ='A11'   THEN q.amt                                 END as Government_amt,
CASE WHEN q.g_code ='A12'   THEN q.amt                                 END as Public_amt,
CASE WHEN q.g_code ='A04'  and q.gl_head_code ='10108'  THEN q.amt     END as DepositAuction_amt,
CASE WHEN q.g_code in ('A21','A23','A24','A25','A26' )   THEN q.amt    END as ShortLAB_amt,
CASE WHEN q.g_code ='A28'   THEN q.amt                                 END as LAB_amt,
CASE WHEN q.g_code  in ('A31','A32','A22' )  THEN q.amt                END as BillsReceivables_amt,
CASE WHEN q.g_code ='A41'   THEN q.amt                                 END as FixedAssets_amt,
CASE WHEN q.g_code not in ('A01','A02','A03','A55','A04','A05',
'A06','A07','A08','A11','A12','A04','A21','A23','A24','A25','A26',
'A28','A31','A32','A22','A41','A90','A50','A67')and q.g_code like '%A%'  and 
q.gl_head_code  not in ('10106','10108')   THEN q.amt                  END as OtherAssets_amt,
CASE WHEN q.g_code ='A90'   THEN q.amt                                 END as AGuarantees_amt,
CASE WHEN q.g_code ='A50'   THEN q.amt                                 END as Charges_amt

from (
select coa.group_code as g_code,coa.gl_sub_head_code as gl_head_code,  abs(gstt.tot_dr_bal-gstt.tot_cr_bal) as amt , coa.cur  as cur
from custom.coa_mp coa , tbaadm.gstt gstt
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and gstt.BAL_DATE <= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and gstt.END_BAL_DATE >= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and coa.cur =Upper(ci_Currency)
and gstt.crncy_code = coa.cur
and GSTT.DEL_FLG = 'N'
AND GSTT.BANK_ID = '01')q)T;
  
  
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData for All Currency---------------------------------------
  -----------------------------------------------------------------------------
  CURSOR ExtractDataAll (ci_Date VARCHAR2)
  IS
  select sum (P.Capital_amt),
        sum (P.Reserves_amt),
        sum (P.RetainProfit_amt),
        sum (P.CurrentDeposit_amt),
        sum (P.CurrentDepositFCY_amt),
        sum (P.SavingDeposit_amt),
        sum (P.SpecialDeposit_amt),
        sum (P.FixedDepoist_amt),
        sum (P.DOBCurrentDeposit_amt),
        sum (P.DOBCurrentDepositFCY_amt),
        sum (P.DOBSavingDeposit_amt),
        sum (P.DOBFixedDepoist_amt),
        sum (P.BorrowStateBank_amt),
        sum (P.BorrowPrivateBank_amt),
        sum (P.BillPayables_amt),
        sum (P.OtherLiabilities_amt),
        sum (P.Acceptances_amt),
       sum (P.AIncome_amt),
         abs(sum (P.CashInHand)),
        abs( sum (P.CashInHandFCY_amt)),
          abs( sum (P.CashAtATM_amt)),
          abs(  sum (P.CashInTransit_amt)),
            abs( sum (P.AccCBM_amt)),
            abs(  sum (P.AccCBMFCY_amt)),
              abs( sum (P.AccStateBank_amt)),
              abs(  sum (P.AccPrivateBank_amt)),
               abs(  sum (P.AccForeignBank_amt)),
                abs(  sum (P.Government_amt)),
                 abs(  sum (P.Public_amt)),
                 abs(  sum (P.DepositAuction_amt)),
                  abs(  sum (P.ShortLAB_amt)),
                   abs(  sum (P.LAB_amt)),
                     abs( sum (P.BillsReceivables_amt)),
                      abs( sum (P.FixedAssets_amt)),
                      abs(  sum (P.OtherAssets_amt)),
                       abs(  sum (P.AGuarantees_amt)),
                         abs( sum (P.Charges_amt))


from (select 
CASE WHEN T.g_code ='L01'   THEN (T.amt)  END as Capital_amt,
CASE WHEN T.g_code ='L02'   THEN T.amt  END as Reserves_amt,
CASE WHEN T.g_code ='L03'   THEN T.amt  END as RetainProfit_amt,
CASE WHEN T.g_code ='L11' and T.gl_head_code ='70101'  THEN T.amt  END as CurrentDeposit_amt,
CASE WHEN T.g_code ='L11' and T.gl_head_code ='70103'  THEN T.amt  END as CurrentDepositFCY_amt,
CASE WHEN T.g_code ='L13'   THEN T.amt  END as SavingDeposit_amt,
CASE WHEN T.g_code ='L15'   THEN T.amt  END as SpecialDeposit_amt,
CASE WHEN T.g_code ='L17'   THEN T.amt  END as FixedDepoist_amt,
CASE WHEN T.g_code in ('L21','L22' )  THEN T.amt  END as DOBCurrentDeposit_amt,
CASE WHEN T.g_code ='L23'   THEN T.amt  END as DOBCurrentDepositFCY_amt,
CASE WHEN T.g_code ='L24'   THEN T.amt  END as DOBSavingDeposit_amt,
CASE WHEN T.g_code ='L26'   THEN T.amt  END as DOBFixedDepoist_amt,
CASE WHEN T.g_code ='L31' and T.gl_head_code ='70141'    THEN T.amt  END as BorrowStateBank_amt,
CASE WHEN T.g_code ='L31' and T.gl_head_code ='70142'   THEN T.amt  END as BorrowPrivateBank_amt,
CASE WHEN T.g_code in ('L33','L34','L35','L36','L39')   THEN T.amt  END as BillPayables_amt,
--CASE WHEN T.g_code in     ('L70')  THEN T.amt  END as OtherLiabilities_amt,
CASE WHEN T.g_code not in ('L01' , 'L02' ,'L03','L11','L13','L15' ,'L17','L21','L22',
'L23','L24','L26','L31','L33','L34','L35','L36','L39','L80','L40')and T.g_code like 'L%'
and T.gl_head_code not in ('70101','70103','70141','70142','60131','60161','60133')   THEN T.amt  END as OtherLiabilities_amt, 

CASE WHEN T.g_code ='L80'   THEN T.amt  END as Acceptances_amt,
CASE WHEN T.g_code ='L40'   THEN T.amt  END as AIncome_amt,
--Cash------
CASE WHEN T.g_code ='A01'   THEN T.amt END as   CashInHand,
CASE WHEN T.g_code ='A02'   THEN T.amt  END as CashInHandFCY_amt,
CASE WHEN T.g_code ='A03'   THEN T.amt  END as CashAtATM_amt,
CASE WHEN T.g_code ='A55'   THEN T.amt  END as CashInTransit_amt,
CASE WHEN T.g_code ='A04'  and T.gl_head_code ='10106'   THEN T.amt  END as AccCBM_amt,
CASE WHEN T.g_code ='A05'   THEN T.amt  END as AccCBMFCY_amt,
CASE WHEN T.g_code ='A06'   THEN T.amt  END as AccStateBank_amt,
CASE WHEN T.g_code ='A07'   THEN T.amt  END as AccPrivateBank_amt,
CASE WHEN T.g_code ='A08'   THEN T.amt  END as AccForeignBank_amt,
--Investment--
CASE WHEN T.g_code ='A11'   THEN T.amt  END as Government_amt,
CASE WHEN T.g_code ='A12'   THEN T.amt  END as Public_amt,
CASE WHEN T.g_code ='A04'  and T.gl_head_code ='10108'  THEN T.amt  END as DepositAuction_amt,

CASE WHEN T.g_code in ('A21','A23','A24','A25','A26' )   THEN T.amt  END as ShortLAB_amt,

CASE WHEN T.g_code ='A28'   THEN T.amt  END as LAB_amt,

CASE WHEN T.g_code  in ('A31','A32','A22','A67' )  THEN T.amt  END as BillsReceivables_amt,
CASE WHEN T.g_code ='A41'   THEN T.amt  END as FixedAssets_amt,

CASE WHEN T.g_code not in ('A01','A02','A03','A55','A04','A05','A06','A07','A08',
'A11','A12','A04','A21','A23','A24','A25','A26',
'A28','A31','A32','A22','A41','A90','A50','A67') and T.g_code like '%A%' and T.gl_head_code  not in ('10106','10108')   THEN T.amt  END as OtherAssets_amt,

CASE WHEN T.g_code ='A90'   THEN T.amt  END as AGuarantees_amt,

CASE WHEN T.g_code ='A50'   THEN T.amt  END as Charges_amt

from(

select  q.g_code, q.gl_head_code,
  CASE WHEN q.cur = 'MMK' THEN q.amt 
   when  q.gl_head_code = '70002' and  q.amt <> 0 THEN TO_NUMBER('4138000000')
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt



from (
select coa.group_code as g_code,
coa.gl_sub_head_code as gl_head_code,
(gstt.tot_cr_bal-gstt.tot_dr_bal )as amt , 
coa.cur  as cur
from custom.coa_mp coa , tbaadm.gstt gstt
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and gstt.BAL_DATE <= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and gstt.END_BAL_DATE >= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and GSTT.DEL_FLG = 'N'
and gstt.crncy_code = coa.cur
AND GSTT.BANK_ID = '01'

)q)T)P;

-------------------------------------------------------------------------------------
 -- CURSOR ExtractData for All Currency FCY---------------------------------------
  -----------------------------------------------------------------------------
  CURSOR ExtractDataAllFCY (ci_Date VARCHAR2)
  IS
 select sum (P.Capital_amt),
        sum (P.Reserves_amt),
        sum (P.RetainProfit_amt),
        sum (P.CurrentDeposit_amt),
        sum (P.CurrentDepositFCY_amt),
        sum (P.SavingDeposit_amt),
        sum (P.SpecialDeposit_amt),
        sum (P.FixedDepoist_amt),
        sum (P.DOBCurrentDeposit_amt),
        sum (P.DOBCurrentDepositFCY_amt),
        sum (P.DOBSavingDeposit_amt),
        sum (P.DOBFixedDepoist_amt),
        sum (P.BorrowStateBank_amt),
        sum (P.BorrowPrivateBank_amt),
        sum (P.BillPayables_amt),
        sum (P.OtherLiabilities_amt),
        sum (P.Acceptances_amt),
       sum (P.AIncome_amt),
        abs( sum (P.CashInHand)),
        abs(  sum (P.CashInHandFCY_amt)),
         abs(   sum (P.CashAtATM_amt)),
          abs(   sum (P.CashInTransit_amt)),
           abs(   sum (P.AccCBM_amt)),
            abs(   sum (P.AccCBMFCY_amt)),
             abs(   sum (P.AccStateBank_amt)),
              abs(   sum (P.AccPrivateBank_amt)),
                abs(  sum (P.AccForeignBank_amt)),
                abs(   sum (P.Government_amt)),
                abs(    sum (P.Public_amt)),
                 abs(   sum (P.DepositAuction_amt)),
                 abs(    sum (P.ShortLAB_amt)),
                  abs(    sum (P.LAB_amt)),
                  abs(     sum (P.BillsReceivables_amt)),
                     abs(   sum (P.FixedAssets_amt)),
                    abs(     sum (P.OtherAssets_amt)),
                      abs(    sum (P.AGuarantees_amt)),
                       abs(    sum (P.Charges_amt))

                           


from (select 
CASE WHEN T.g_code ='L01'   THEN (T.amt)  END as Capital_amt,
CASE WHEN T.g_code ='L02'   THEN T.amt  END as Reserves_amt,
CASE WHEN T.g_code ='L03'   THEN T.amt  END as RetainProfit_amt,
CASE WHEN T.g_code ='L11' and T.gl_head_code ='70101'  THEN T.amt  END as CurrentDeposit_amt,
CASE WHEN T.g_code ='L11' and T.gl_head_code ='70103'  THEN T.amt  END as CurrentDepositFCY_amt,
CASE WHEN T.g_code ='L13'   THEN T.amt  END as SavingDeposit_amt,
CASE WHEN T.g_code ='L15'   THEN T.amt  END as SpecialDeposit_amt,
CASE WHEN T.g_code ='L17'   THEN T.amt  END as FixedDepoist_amt,
CASE WHEN T.g_code in ('L21','L22' )  THEN T.amt  END as DOBCurrentDeposit_amt,
CASE WHEN T.g_code ='L23'   THEN T.amt  END as DOBCurrentDepositFCY_amt,
CASE WHEN T.g_code ='L24'   THEN T.amt  END as DOBSavingDeposit_amt,
CASE WHEN T.g_code ='L26'   THEN T.amt  END as DOBFixedDepoist_amt,
CASE WHEN T.g_code ='L31' and T.gl_head_code ='70141'    THEN T.amt  END as BorrowStateBank_amt,
CASE WHEN T.g_code ='L31' and T.gl_head_code ='70142'   THEN T.amt  END as BorrowPrivateBank_amt,
CASE WHEN T.g_code in ('L33','L34','L35','L36','L39')   THEN T.amt  END as BillPayables_amt,
CASE WHEN T.g_code not in ('L01' , 'L02' ,'L03','L11','L13','L15' ,'L17','L21','L22',
'L23','L24','L26','L31','L33','L34','L35','L36','L39','L80','L40')and t.g_code like 'L%' and T.gl_head_code not in ('70101','70103','70141','70142','60131','60161','60133')   THEN T.amt  END as OtherLiabilities_amt,
CASE WHEN T.g_code ='L80'   THEN T.amt  END as Acceptances_amt,
CASE WHEN T.g_code ='L40'   THEN T.amt  END as AIncome_amt,
--Cash------
CASE WHEN T.g_code ='A01'   THEN T.amt  END as   CashInHand,
CASE WHEN T.g_code ='A02'   THEN T.amt  END as CashInHandFCY_amt,
CASE WHEN T.g_code ='A03'   THEN T.amt  END as CashAtATM_amt,
CASE WHEN T.g_code ='A55'   THEN T.amt  END as CashInTransit_amt,
CASE WHEN T.g_code ='A04'  and T.gl_head_code ='10106'   THEN T.amt  END as AccCBM_amt,
CASE WHEN T.g_code ='A05'   THEN T.amt  END as AccCBMFCY_amt,
CASE WHEN T.g_code ='A06'   THEN T.amt  END as AccStateBank_amt,
CASE WHEN T.g_code ='A07'   THEN T.amt  END as AccPrivateBank_amt,
CASE WHEN T.g_code ='A08'   THEN T.amt  END as AccForeignBank_amt,
--Investment--
CASE WHEN T.g_code ='A11'   THEN T.amt  END as Government_amt,
CASE WHEN T.g_code ='A12'   THEN T.amt  END as Public_amt,
CASE WHEN T.g_code ='A04'  and T.gl_head_code ='10108'  THEN T.amt  END as DepositAuction_amt,

CASE WHEN T.g_code in ('A21','A23','A24','A25','A26' )   THEN T.amt  END as ShortLAB_amt,

CASE WHEN T.g_code ='A28'   THEN T.amt  END as LAB_amt,

CASE WHEN T.g_code  in ('A31','A32','A22' )  THEN T.amt  END as BillsReceivables_amt,
CASE WHEN T.g_code ='A41'   THEN T.amt  END as FixedAssets_amt,

CASE WHEN T.g_code not in ('A01','A02','A03','A55','A04','A05','A06','A07','A08',
'A11','A12','A04','A21','A23','A24','A25','A26',
'A28','A31','A32','A22','A41','A90','A50') and  t.g_code like '%A%' and T.gl_head_code  not in ('10106','10108')   THEN T.amt  END as OtherAssets_amt,

CASE WHEN T.g_code ='A90'   THEN T.amt  END as AGuarantees_amt,

CASE WHEN T.g_code ='A50'   THEN T.amt  END as Charges_amt

from(

select  q.g_code, q.gl_head_code,
  CASE WHEN q.cur = 'MMK' THEN q.amt
   when  q.gl_head_code = '70002' and  q.amt <> 0 THEN TO_NUMBER('4138000000')
  ELSE q.amt * NVL((SELECT r.VAR_CRNCY_UNITS 
                                FROM TBAADM.RTH r
                                where trim(r.fxd_crncy_code) = trim(q.cur) and r.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                and  r.RATECODE = 'NOR'
                                and trim(r.VAR_CRNCY_CODE) = 'MMK' 
                                and (fxd_crncy_code, rtlist_num) in (SELECT a.fxd_crncy_code,Max(A.rtlist_num)
                                                                      FROM TBAADM.RTH a
                                                                      where a.Rtlist_date = TO_DATE( CAST (  ci_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                      and  a.RATECODE = 'NOR'
                                                                      and trim(a.VAR_CRNCY_CODE) = 'MMK' 
                                                                      group by a.fxd_crncy_code
                                    )
                              ),1) END AS amt



from (
select coa.group_code as g_code,coa.gl_sub_head_code as gl_head_code,  abs(gstt.tot_dr_bal-gstt.tot_cr_bal) as amt , coa.cur  as cur
from custom.coa_mp coa , tbaadm.gstt gstt
where coa.gl_sub_head_code = gstt.gl_sub_head_code
and gstt.BAL_DATE <= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and gstt.END_BAL_DATE >= to_date(cast(ci_Date as varchar(10)), 'dd-MM-yyyy')
and GSTT.DEL_FLG = 'N'
and gstt.crncy_code = coa.cur
   and gstt.crncy_code not like 'MMK'
   and coa.cur not like 'MMK'
AND GSTT.BANK_ID = '01')q)T)P;



-------------------------------------------------------------------------------------

    
PROCEDURE FIN_CONSO_BALANCE_SHEET(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT limited_string )
AS
                v_Capital_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Reserves_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_RetainProfit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CurrentDeposit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CurrentDepositFCY_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_SavingDeposit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_SpecialDeposit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_FixedDepoist_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_DOBCurrentDeposit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_DOBCurrentDepositFCY_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_DOBSavingDeposit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_DOBFixedDepoist_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_BorrowStateBank_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_BorrowPrivateBank_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_BillPayables_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_OtherLiabilities_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Acceptances_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AIncome_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CashInHand    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CashInHandFCY_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CashAtATM_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_CashInTransit_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AccCBM_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AccCBMFCY_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AccStateBank_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AccPrivateBank_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AccForeignBank_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Government_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Public_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_DepositAuction_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_ShortLAB_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_LAB_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_BillsReceivables_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_FixedAssets_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_OtherAssets_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_AGuarantees_amt    TBAADM.gstt.tot_cash_cr_amt%type;
        v_Charges_amt     TBAADM.gstt.tot_cash_cr_amt%type;
              vi_rate varchar(20);               
BEGIN
  -------------------------------------------------------------
  -- Out Ret code is the code which controls
  -- the while loop,it can have values 0,1
  -- 0 - The while loop is being executed
  -- 1 - Exit
  -------------------------------------------------------------
  out_retCode := 0;
  out_rec     := NULL;
  tbaadm.basp0099.formInputArr(inp_str, outArr);
  --------------------------------------
  -- Parsing the i/ps from the string
  --------------------------------------
  vi_Date   := outArr(0);
  vi_Currency     := outArr(1);
  vi_CurType := outArr(2);
 
 
  If vi_CurType  not like 'All%' then 
  IF NOT ExtractData%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractData ( vi_Date , vi_Currency);
      --}
    END;
    --}
  END IF;
  IF ExtractData%ISOPEN THEN
    --{
    FETCH ExtractData
    INTO         v_Capital_amt , v_Reserves_amt,v_RetainProfit_amt, v_CurrentDeposit_amt ,
        v_CurrentDepositFCY_amt ,v_SavingDeposit_amt,v_SpecialDeposit_amt,
        v_FixedDepoist_amt,v_DOBCurrentDeposit_amt ,v_DOBCurrentDepositFCY_amt,
        v_DOBSavingDeposit_amt , v_DOBFixedDepoist_amt ,v_BorrowStateBank_amt ,
        v_BorrowPrivateBank_amt,v_BillPayables_amt,v_OtherLiabilities_amt,
		    v_Acceptances_amt,v_AIncome_amt,v_CashInHand ,v_CashInHandFCY_amt,
        v_CashAtATM_amt,v_CashInTransit_amt, v_AccCBM_amt,v_AccCBMFCY_amt,
        v_AccStateBank_amt,v_AccPrivateBank_amt,v_AccForeignBank_amt,
        v_Government_amt,v_Public_amt,v_DepositAuction_amt,v_ShortLAB_amt,
        v_LAB_amt ,v_BillsReceivables_amt ,v_FixedAssets_amt,v_OtherAssets_amt,
        v_AGuarantees_amt,v_Charges_amt;
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
      --}'
    END IF;
    --}
  END IF;
  --------------------------------------------------------------------------------
 ELSIf vi_CurType like 'All Currency' then  
  
  IF NOT ExtractDataAll%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractDataAll ( vi_Date );
      --}
    END;
    --}
  END IF;
  IF ExtractDataAll%ISOPEN THEN
    --{
    FETCH ExtractDataAll
    INTO         v_Capital_amt , v_Reserves_amt,v_RetainProfit_amt, v_CurrentDeposit_amt ,
        v_CurrentDepositFCY_amt ,v_SavingDeposit_amt,v_SpecialDeposit_amt,
        v_FixedDepoist_amt,v_DOBCurrentDeposit_amt ,v_DOBCurrentDepositFCY_amt,
        v_DOBSavingDeposit_amt , v_DOBFixedDepoist_amt ,v_BorrowStateBank_amt ,
        v_BorrowPrivateBank_amt,v_BillPayables_amt,v_OtherLiabilities_amt,
		v_Acceptances_amt,v_AIncome_amt,v_CashInHand ,v_CashInHandFCY_amt,
        v_CashAtATM_amt,v_CashInTransit_amt, v_AccCBM_amt,v_AccCBMFCY_amt,
        v_AccStateBank_amt,v_AccPrivateBank_amt,v_AccForeignBank_amt,
        v_Government_amt,v_Public_amt,v_DepositAuction_amt,v_ShortLAB_amt,
        v_LAB_amt ,v_BillsReceivables_amt ,v_FixedAssets_amt,v_OtherAssets_amt,
        v_AGuarantees_amt,v_Charges_amt;
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
      --}'
    END IF;
    --}
  END IF;
  ------------------------------------------------------------------
    ELSE --for All FCY
   IF NOT ExtractDataAllFCY%ISOPEN THEN
    --{
    BEGIN
      --{
      OPEN ExtractDataAllFCY ( vi_Date );
      --}
    END;
    --}
  END IF;
  IF ExtractDataAllFCY%ISOPEN THEN
    --{
    FETCH ExtractDataAllFCY
    INTO       v_Capital_amt , v_Reserves_amt,v_RetainProfit_amt, v_CurrentDeposit_amt ,
        v_CurrentDepositFCY_amt ,v_SavingDeposit_amt,v_SpecialDeposit_amt,
        v_FixedDepoist_amt,v_DOBCurrentDeposit_amt ,v_DOBCurrentDepositFCY_amt,
        v_DOBSavingDeposit_amt , v_DOBFixedDepoist_amt ,v_BorrowStateBank_amt ,
        v_BorrowPrivateBank_amt,v_BillPayables_amt,v_OtherLiabilities_amt,
		v_Acceptances_amt,v_AIncome_amt,v_CashInHand ,v_CashInHandFCY_amt,
        v_CashAtATM_amt,v_CashInTransit_amt, v_AccCBM_amt,v_AccCBMFCY_amt,
        v_AccStateBank_amt,v_AccPrivateBank_amt,v_AccForeignBank_amt,
        v_Government_amt,v_Public_amt,v_DepositAuction_amt,v_ShortLAB_amt,
        v_LAB_amt ,v_BillsReceivables_amt ,v_FixedAssets_amt,v_OtherAssets_amt,
        v_AGuarantees_amt,v_Charges_amt;
    ------------------------------------------------------------------
    -- Here it is checked whether the cursor has fetched
    -- something or not if not the cursor is closed
    -- and the out ret code is made equal to 1
    ------------------------------------------------------------------
    IF ExtractDataAllFCY%NOTFOUND THEN
      --{
      CLOSE ExtractDataAllFCY;
      out_retCode:= 1;
      RETURN;
      --}'
    END IF;
    --}
  END IF;
    --}
  END IF;
  ------------------------------------------------------------------
  BEGIN
    ---------To get rate for home currency --> from FXD_CRNCY_CODE to VAR_CRNCY_CODE(MMK)
    IF vi_CurType  = 'Home Currency' THEN
                if upper(vi_Currency) = 'MMK' THEN vi_rate := 1 ;
                ELSE select VAR_CRNCY_UNITS into vi_rate from tbaadm.rth 
                  where ratecode = 'NOR'
                  and rtlist_date = TO_DATE( CAST ( vi_Date AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                  and TRIM(FXD_CRNCY_CODE)= upper(vi_Currency)
                  and TRIM(VAR_CRNCY_CODE) = 'MMK' and rownum=1 order by rtlist_num desc;
                end if; 
                ELSIF vi_CurType = 'Source Currency' THEN
                   if upper(vi_Currency) = 'MMK' THEN vi_rate := 1 ;
                   ELSE
                      vi_rate := 1;
                  end if;
              ELSE
                  vi_rate := 1;
              END IF;
  end;

---------------------------------------
 IF v_Capital_amt IS  NULL or v_Capital_amt = ''  THEN
  v_Capital_amt := 0;
  END IF; 
  -------------------
  IF v_Reserves_amt IS  NULL or v_Reserves_amt = ''  THEN
  v_Reserves_amt := 0;
  END IF; 
  ---------------------------------
   IF v_RetainProfit_amt IS  NULL or v_RetainProfit_amt = ''  THEN
  v_RetainProfit_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_CurrentDeposit_amt IS  NULL or v_CurrentDeposit_amt = ''  THEN
  v_CurrentDeposit_amt := 0;
  END IF;
  ---------------------------------------
 IF v_CurrentDepositFCY_amt IS  NULL or v_CurrentDepositFCY_amt = ''  THEN
  v_CurrentDepositFCY_amt := 0;
  END IF; 
  -------------------
  IF v_SavingDeposit_amt IS  NULL or v_SavingDeposit_amt = ''  THEN
  v_SavingDeposit_amt := 0;
  END IF; 
  ---------------------------------
   IF v_SpecialDeposit_amt IS  NULL or v_SpecialDeposit_amt = ''  THEN
  v_SpecialDeposit_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_FixedDepoist_amt IS  NULL or v_FixedDepoist_amt = ''  THEN
  v_FixedDepoist_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_DOBCurrentDeposit_amt IS  NULL or v_DOBCurrentDeposit_amt = ''  THEN
  v_DOBCurrentDeposit_amt := 0;
  END IF; 
  -------------------
  IF v_DOBCurrentDepositFCY_amt IS  NULL or v_DOBCurrentDepositFCY_amt = ''  THEN
  v_DOBCurrentDepositFCY_amt := 0;
  END IF; 
  ---------------------------------
   IF v_DOBSavingDeposit_amt IS  NULL or v_DOBSavingDeposit_amt = ''  THEN
  v_DOBSavingDeposit_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_DOBFixedDepoist_amt IS  NULL or v_DOBFixedDepoist_amt = ''  THEN
  v_DOBFixedDepoist_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_BorrowStateBank_amt IS  NULL or v_BorrowStateBank_amt = ''  THEN
  v_BorrowStateBank_amt := 0;
  END IF; 
  -------------------
  IF v_BorrowPrivateBank_amt IS  NULL or v_BorrowPrivateBank_amt = ''  THEN
  v_BorrowPrivateBank_amt := 0;
  END IF; 
  ---------------------------------
   IF v_BillPayables_amt IS  NULL or v_BillPayables_amt = ''  THEN
  v_BillPayables_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_OtherLiabilities_amt IS  NULL or v_OtherLiabilities_amt = ''  THEN
  v_OtherLiabilities_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_Acceptances_amt IS  NULL or v_Acceptances_amt = ''  THEN
  v_Acceptances_amt := 0;
  END IF; 
  -------------------
  IF v_AIncome_amt IS  NULL or v_AIncome_amt = ''  THEN
  v_AIncome_amt := 0;
  END IF; 
  ---------------------------------
   IF v_CashInHand IS  NULL or v_CashInHand = ''  THEN
  v_CashInHand := 0;
  END IF; 
  ---------------------------------------
   IF v_CashInHandFCY_amt IS  NULL or v_CashInHandFCY_amt = ''  THEN
  v_CashInHandFCY_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_CashAtATM_amt IS  NULL or v_CashAtATM_amt = ''  THEN
  v_CashAtATM_amt := 0;
  END IF; 
  -------------------
  IF v_CashInTransit_amt IS  NULL or v_CashInTransit_amt = ''  THEN
  v_CashInTransit_amt := 0;
  END IF; 
  ---------------------------------
   IF v_AccCBM_amt IS  NULL or v_AccCBM_amt = ''  THEN
  v_AccCBM_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_AccCBMFCY_amt IS  NULL or v_AccCBMFCY_amt = ''  THEN
  v_AccCBMFCY_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_AccStateBank_amt IS  NULL or v_AccStateBank_amt = ''  THEN
  v_AccStateBank_amt := 0;
  END IF; 
  -------------------
  IF v_AccPrivateBank_amt IS  NULL or v_AccPrivateBank_amt = ''  THEN
  v_AccPrivateBank_amt := 0;
  END IF; 
  ---------------------------------
   IF v_AccForeignBank_amt IS  NULL or v_AccForeignBank_amt = ''  THEN
  v_AccForeignBank_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_LAB_amt IS  NULL or v_LAB_amt = ''  THEN
  v_LAB_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_BillsReceivables_amt IS  NULL or v_BillsReceivables_amt = ''  THEN
  v_BillsReceivables_amt := 0;
  END IF; 
  -------------------
  IF v_FixedAssets_amt IS  NULL or v_FixedAssets_amt = ''  THEN
  v_FixedAssets_amt := 0;
  END IF; 
  ---------------------------------
   IF v_OtherAssets_amt IS  NULL or v_OtherAssets_amt = ''  THEN
  v_OtherAssets_amt := 0;
  END IF; 
  ---------------------------------------
   IF v_AGuarantees_amt IS  NULL or v_AGuarantees_amt = ''  THEN
  v_AGuarantees_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  ---------------------------------------
 IF v_Charges_amt IS  NULL or v_Charges_amt = ''  THEN
  v_Charges_amt := 0;
  END IF; 
  -------------------
  IF vi_rate IS  NULL or vi_rate = ''  THEN
  vi_rate := 0;
  END IF; 
  -------------------
  IF v_Public_amt IS  NULL or v_Public_amt = ''  THEN
  v_Public_amt := 0;
  END IF;  
  
  ----------------------
   IF v_DepositAuction_amt IS  NULL or v_DepositAuction_amt = ''  THEN
  v_DepositAuction_amt := 0;
  END IF; 
  ----------------------
   IF v_Government_amt IS  NULL or v_Government_amt = ''  THEN
  v_Government_amt := 0;
  END IF; 
  ----------------------
   IF v_ShortLAB_amt IS  NULL or v_ShortLAB_amt = ''  THEN
  v_ShortLAB_amt := 0;
  END IF;
  -----------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
  ------------------------------------------------------------------------------------
  out_rec:=                 v_Capital_amt    || '|' ||
                             v_Reserves_amt    || '|' ||
                             v_RetainProfit_amt    || '|' ||
                             v_CurrentDeposit_amt    || '|' ||
                             v_CurrentDepositFCY_amt    || '|' ||
                              v_SavingDeposit_amt    || '|' ||
                              v_SpecialDeposit_amt    || '|' ||
                              v_FixedDepoist_amt    || '|' ||
                               v_DOBCurrentDeposit_amt    || '|' ||
                               v_DOBCurrentDepositFCY_amt    || '|' ||
                               v_DOBSavingDeposit_amt    || '|' ||
                                v_DOBFixedDepoist_amt    || '|' ||
                                v_BorrowStateBank_amt    || '|' ||
                                v_BorrowPrivateBank_amt    || '|' ||
                                v_BillPayables_amt    || '|' ||
                                v_OtherLiabilities_amt    || '|' ||
                                v_Acceptances_amt    || '|' ||
                                v_AIncome_amt    || '|' ||
                                v_CashInHand    || '|' ||
                                v_CashInHandFCY_amt    || '|' ||
                                v_CashAtATM_amt    || '|' ||
                                v_CashInTransit_amt    || '|' ||
                                v_AccCBM_amt    || '|' ||
                                v_AccCBMFCY_amt    || '|' ||
                                v_AccStateBank_amt    || '|' ||
                                v_AccPrivateBank_amt    || '|' ||
                                v_AccForeignBank_amt    || '|' ||
                                v_Government_amt    || '|' ||
                                v_Public_amt    || '|' ||
                                v_DepositAuction_amt    || '|' ||
                                v_ShortLAB_amt    || '|' ||
                                v_LAB_amt    || '|' ||
                                v_BillsReceivables_amt    || '|' ||
                                v_FixedAssets_amt    || '|' ||
                                v_OtherAssets_amt    || '|' ||
                                v_AGuarantees_amt    || '|' ||
                                v_Charges_amt     || '|' ||
                                vi_rate            
          ;
  dbms_output.put_line(out_rec);
   RETURN;
END FIN_CONSO_BALANCE_SHEET;
END FIN_CONSO_BALANCE_SHEET;
/
