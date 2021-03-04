CREATE OR REPLACE PACKAGE FIN_CBM_TOTAL_FCY_BUYSELL AS 

PROCEDURE FIN_CBM_TOTAL_FCY_BUYSELL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_CBM_TOTAL_FCY_BUYSELL;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                FIN_CBM_TOTAL_FCY_BUYSELL AS

-------------------------------------------------------------------------------------
  -- ORIGINAL CODER     -  MOE HTET KYAW KYAW
  -- FINISHED DATE      -  31-03-2017
  -- CORRECTED BY       -   -
  -- CORRECTED DATE     -   -
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array
  
	vi_StartDate	         	Varchar2(10);             -- Input to procedure
  vi_EndDate	          	Varchar2(10);             -- Input to procedure
  vi_UserID		            Varchar2(20);		    	    -- Input to procedure
  vi_BranchCode		        Varchar2(6);		    	    -- Input to procedure
  vi_Option	              Varchar2(10);		    	    -- Input to procedure
  

  
  ----------------------------------CURSOR----------------------------------------
  CURSOR ExtractData(ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_option VARCHAR2) 
  IS
    
 select sol.sol_desc,
       ' ' as TellerName,
       nvl(p.USDUnits,0.00),
       nvl(p.USDKyats,0.00),
       nvl(p.EURUnits,0.00),
       nvl(p.EURKyats,0.00),
       nvl(p.SGDUnits,0.00),
       nvl(p.SGDKyats,0.00),
       nvl(p.THBUnits,0.00),
       nvl(p.THBKyats,0.00)
from tbaadm.sol sol
left join (select-- q.TellerName,
           q.sol_id,
           sum(q.USDUnits) as USDUnits,
          sum( q.USDKyats) as USDKyats,
           sum(q.EURUnits) as EURUnits,
          sum( q.EURKyats) as EURKyats,
          sum( q.SGDUnits) as SGDUnits,
          sum( q.SGDKyats) as SGDKyats,
          sum( q.THBUnits) as THBUnits,
          sum( q.THBKyats) as THBKyats
          from  (
                select --cdcm.teller_id as TellerName,
                      (select upr.sol_id 
                      from tbaadm.upr upr
                      where upr.user_id = cdcm.teller_id
                      and upr.del_flg= 'N'
                      and upr.entity_cre_flg = 'Y') as sol_id,
                      case when CDCM.REF_CRNCY_CODE = 'USD' then cdcm.tran_amt else 0 end as USDUnits,
                      case when CDCM.REF_CRNCY_CODE = 'USD' then cdcm.ref_amt else 0 end as USDKyats,
                      case when CDCM.REF_CRNCY_CODE = 'EUR' then cdcm.tran_amt else 0 end as EURUnits,
                      case when CDCM.REF_CRNCY_CODE = 'EUR' then cdcm.ref_amt else 0 end as EURKyats,
                      case when CDCM.REF_CRNCY_CODE = 'SGD' then cdcm.tran_amt else 0 end as SGDUnits,
                      case when CDCM.REF_CRNCY_CODE = 'SGD' then cdcm.ref_amt else 0 end as SGDKyats,
                      case when CDCM.REF_CRNCY_CODE = 'THB' then cdcm.tran_amt else 0 end as THBUnits,
                      case when CDCM.REF_CRNCY_CODE = 'THB' then cdcm.ref_amt else 0 end as THBKyats
                      
                      
                from CUSTOM.c_denom_cash_maintenance cdcm
                where tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                and  tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                and  cdcm.entity_cre_flg = 'Y'
                and  cdcm.bank_id = '01'
                and   cdcm.del_flg = 'N'
                and   cdcm.Foreign_exchange LIKE '%' || ci_option || '%'
                and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                        where atd.cont_tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                        and atd.cont_tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
             )q
            Group by q.sol_id--q.TellerName,
            order by q.sol_id)P
            on sol.sol_id = P.sol_id
      where sol.sol_id not in ('101', '10100', '20100')
      order by sol.sol_id--, p.tellerName
      ;
      
      
      ----------------------------------CURSOR with Option Parameter----------------------------------------
  CURSOR ExtractDataOption(ci_StartDate VARCHAR2,ci_EndDate VARCHAR2, ci_option VARCHAR2,Ci_BranchCode VARCHAR2) 
  IS
    
 select sol.sol_desc,
       nvl(p.tellerName,' '),
       nvl(p.USDUnits,0.00),
       nvl(p.USDKyats,0.00),
       nvl(p.EURUnits,0.00),
       nvl(p.EURKyats,0.00),
       nvl(p.SGDUnits,0.00),
       nvl(p.SGDKyats,0.00),
       nvl(p.THBUnits,0.00),
       nvl(p.THBKyats,0.00)
from tbaadm.sol sol
left join (select q.TellerName,
           q.sol_id,
           sum(q.USDUnits) as USDUnits,
          sum( q.USDKyats) as USDKyats,
           sum(q.EURUnits) as EURUnits,
          sum( q.EURKyats) as EURKyats,
          sum( q.SGDUnits) as SGDUnits,
          sum( q.SGDKyats) as SGDKyats,
          sum( q.THBUnits) as THBUnits,
          sum( q.THBKyats) as THBKyats
          from  (
                select cdcm.teller_id as TellerName,
                      (select upr.sol_id 
                      from tbaadm.upr upr
                      where upr.user_id = cdcm.teller_id
                      and upr.del_flg= 'N'
                      and upr.entity_cre_flg = 'Y') as sol_id,
                      case when CDCM.REF_CRNCY_CODE = 'USD' then cdcm.tran_amt else 0 end as USDUnits,
                      case when CDCM.REF_CRNCY_CODE = 'USD' then cdcm.ref_amt else 0 end as USDKyats,
                      case when CDCM.REF_CRNCY_CODE = 'EUR' then cdcm.tran_amt else 0 end as EURUnits,
                      case when CDCM.REF_CRNCY_CODE = 'EUR' then cdcm.ref_amt else 0 end as EURKyats,
                      case when CDCM.REF_CRNCY_CODE = 'SGD' then cdcm.tran_amt else 0 end as SGDUnits,
                      case when CDCM.REF_CRNCY_CODE = 'SGD' then cdcm.ref_amt else 0 end as SGDKyats,
                      case when CDCM.REF_CRNCY_CODE = 'THB' then cdcm.tran_amt else 0 end as THBUnits,
                      case when CDCM.REF_CRNCY_CODE = 'THB' then cdcm.ref_amt else 0 end as THBKyats
                      
                      
                from CUSTOM.c_denom_cash_maintenance cdcm
                where tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                and tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                and  cdcm.entity_cre_flg = 'Y'
                and  cdcm.bank_id = '01'
                and   cdcm.del_flg = 'N'
                and   cdcm.Foreign_exchange LIKE '%' || ci_option || '%'
                and trim (CDCM.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
                        where atd.cont_tran_date >= TO_DATE( CAST ( ci_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
                        and atd.cont_tran_date <= TO_DATE( CAST ( ci_EndDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) 
             )q
            Group by q.TellerName,q.sol_id
            order by q.sol_id)P
            on sol.sol_id = P.sol_id
      where sol.sol_id not in ('101', '10100', '20100')
      and   sol.sol_id like   '%'||vi_BranchCode||'%'
      order by sol.sol_id, p.tellerName
      ;
      

  
  
  PROCEDURE FIN_CBM_TOTAL_FCY_BUYSELL(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS
       
    v_TellerName CUSTOM.C_DENOM_CASH_MAINTENANCE.TELLER_ID%TYPE;
    v_USDUnits  CUSTOM.C_DENOM_CASH_MAINTENANCE.ref_amt%TYPE;
    v_USDKyats  CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
    v_EURUnits  CUSTOM.C_DENOM_CASH_MAINTENANCE.ref_amt%TYPE;
    v_EURKyats  CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
    v_SGDUnits  CUSTOM.C_DENOM_CASH_MAINTENANCE.ref_amt%TYPE;
    v_SGDKyats  CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;
    v_THBUnits  CUSTOM.C_DENOM_CASH_MAINTENANCE.ref_amt%TYPE;
    v_THBKyats  CUSTOM.C_DENOM_CASH_MAINTENANCE.tran_amt%TYPE;  
    v_Branch    varchar2(50);
    
    v_CurrencyCode      tbaadm.rth.fxd_crncy_code%TYPE;
    v_CurrencyVersion   tbaadm.rth.rtlist_num%TYPE;
    v_CurrencyRate      tbaadm.rth.ratecode%TYPE;
    v_CurrencyAmount    tbaadm.rth.VAR_CRNCY_UNITS%TYPE;
    
----------------------------buy sell rate var-----------------------------------
    BUSD1    Number(10,2);
    BUSD2    Number(10,2);
    BUSD3    Number(10,2);
    BUSD4    Number(10,2);
    BUSD5    Number(10,2);
    SUSD1    Number(10,2);
    SUSD2    Number(10,2);
    SUSD3    Number(10,2);
    SUSD4    Number(10,2);
    SUSD5    Number(10,2);
    BEUR1    Number(10,2);
    BEUR2    Number(10,2);
    BEUR3    Number(10,2);
    BEUR4    Number(10,2);
    BEUR5    Number(10,2);
    SEUR1    Number(10,2);
    SEUR2    Number(10,2);
    SEUR3    Number(10,2);
    SEUR4    Number(10,2);
    SEUR5    Number(10,2);
    BSGD1    Number(10,2);
    BSGD2    Number(10,2);
    BSGD3    Number(10,2);
    BSGD4    Number(10,2);
    BSGD5    Number(10,2);
    SSGD1    Number(10,2);
    SSGD2    Number(10,2);
    SSGD3    Number(10,2);
    SSGD4    Number(10,2);
    SSGD5    Number(10,2);
    BTHB1    Number(10,2);
    BTHB2    Number(10,2);
    BTHB3    Number(10,2);
    BTHB4    Number(10,2);
    BTHB5    Number(10,2);
    STHB1    Number(10,2);
    STHB2    Number(10,2);
    STHB3    Number(10,2);
    STHB4    Number(10,2);
    STHB5    Number(10,2);
      

    
  BEGIN
  
    out_retCode := 0;
		out_rec := NULL;
    
    
    tbaadm.basp0099.formInputArr(inp_str, outArr);
     --------------------------------------
		-- Parsing the i/ps from the string
		--------------------------------------
    vi_StartDate      	  :=outArr(0);		
    vi_EndDate        	  :=outArr(1);	
    vi_Option	            :=outArr(2);	
    vi_BranchCode         :=outArr(3);	
  

  IF vi_Option LIKE 'Buying%'  THEN
      vi_Option := 'B';
  END IF;
  
  IF vi_Option LIKE 'Selling%'  THEN
      vi_Option := 'S';
  END IF;
  
  IF vi_BranchCode IS NULL OR vi_BranchCode = '' THEN
      vi_BranchCode :='';
  END IF;
  
  
  
  

 IF vi_BranchCode IS NULL OR vi_BranchCode = '' THEN
  
      ----------------------------------EXTRACT---------------------------------------
      IF NOT ExtractData%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractData(vi_StartDate,vi_EndDate,vi_Option) ;
            --}
            END;
      
          --}
          END IF;
          IF ExtractData%ISOPEN Then

           -- dobal := dobal + OpeningAmount;
            FETCH	ExtractData INTO	v_Branch, v_TellerName, v_USDUnits,v_USDKyats,v_EURUnits,v_EURKyats,v_SGDUnits,v_SGDKyats,
                                    v_THBUnits,v_THBKyats;
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
  
   ELSE 
      
         IF vi_BranchCode ='10100' THEN
            vi_BranchCode :='';
        END IF;
      ----------------------------------EXTRACT---------------------------------------
      IF NOT ExtractDataOption%ISOPEN THEN
          --{
            BEGIN
            --{
              OPEN ExtractDataOption(vi_StartDate,vi_EndDate,vi_Option,vi_BranchCode) ;
            --}
            END;
      
          --}
          END IF;
          IF ExtractDataOption%ISOPEN Then

           -- dobal := dobal + OpeningAmount;
            FETCH	ExtractDataOption INTO	v_Branch, v_TellerName, v_USDUnits,v_USDKyats,v_EURUnits,v_EURKyats,v_SGDUnits,v_SGDKyats,
                                    v_THBUnits,v_THBKyats;
            ------------------------------------------------------------------
            -- Here it is checked whether the cursor has fetched
            -- something or not if not the cursor is closed
            -- and the out ret code is made equal to 1
            ------------------------------------------------------------------
            IF ExtractDataOption%NOTFOUND THEN
            --{
              CLOSE ExtractDataOption;
              out_retCode:= 1;
              RETURN;
            --}
            END IF;   
            
          --}
     END IF;
   
   
   
END IF;
    
    
    
    
      Begin
           select sum(q.BUSD1),sum(q.BUSD2),sum(q.BUSD3),sum(q.BUSD4),sum(q.BUSD5),
           sum(q.SUSD1),sum(q.SUSD2),sum(q.SUSD3),sum(q.SUSD4),sum(q.SUSD5),
           sum(q.BEUR1),sum(q.BEUR2),sum(q.BEUR3),sum(q.BEUR4),sum(q.BEUR5),
           sum(q.SEUR1),sum(q.SEUR2),sum(q.SEUR3),sum(q.SEUR4),sum(q.SEUR5),
           sum(q.BSGD1),sum(q.BSGD2),sum(q.BSGD3),sum(q.BSGD4),sum(q.BSGD5),
           sum(q.SSGD1),sum(q.SSGD2),sum(q.SSGD3),sum(q.SSGD4),sum(q.SSGD5),
           sum(q.BTHB1),sum(q.BTHB2),sum(q.BTHB3),sum(q.BTHB4),sum(q.BTHB5),
           sum(q.STHB1),sum(q.STHB2),sum(q.STHB3),sum(q.STHB4),sum(q.STHB5)
           into BUSD1, BUSD2, BUSD3, BUSD4, BUSD5, SUSD1, SUSD2, SUSD3, SUSD4, SUSD5,
                BEUR1, BEUR2, BEUR3, BEUR4, BEUR5, SEUR1, SEUR2, SEUR3, SUSD4, SEUR5,
                BSGD1, BSGD2, BSGD3, BSGD4, BSGD5, SSGD1, SSGD2, SSGD3, SSGD4, SSGD5,
                BTHB1, BTHB2, BTHB3, BTHB4, BTHB5, STHB1, STHB2, STHB3, STHB4, STHB5
    from (
          select 
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%1%' and rth.ratecode = '1HP' then rth.VAR_CRNCY_UNITS else 0 end as  BUSD1,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%2%' and rth.ratecode = '1HP' then rth.VAR_CRNCY_UNITS else 0 end as  BUSD2,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%3%' and rth.ratecode = '1HP' then rth.VAR_CRNCY_UNITS else 0 end as  BUSD3,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%4%' and rth.ratecode = '1HP' then rth.VAR_CRNCY_UNITS else 0 end as  BUSD4,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%5%' and rth.ratecode = '1HP' then rth.VAR_CRNCY_UNITS else 0 end as  BUSD5,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%1%' and rth.ratecode = '1HS' then rth.VAR_CRNCY_UNITS else 0 end as  SUSD1,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%2%' and rth.ratecode = '1HS' then rth.VAR_CRNCY_UNITS else 0 end as  SUSD2,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%3%' and rth.ratecode = '1HS' then rth.VAR_CRNCY_UNITS else 0 end as  SUSD3,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%4%' and rth.ratecode = '1HS' then rth.VAR_CRNCY_UNITS else 0 end as  SUSD4,
                case when rth.fxd_crncy_code = 'USD' and rth.rtlist_num like '%5%' and rth.ratecode = '1HS' then rth.VAR_CRNCY_UNITS else 0 end as  SUSD5,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BEUR1,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BEUR2,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BEUR3,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BEUR4,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BEUR5,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SEUR1,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SEUR2,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SEUR3,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SEUR4,
                case when rth.fxd_crncy_code = 'EUR' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SEUR5,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BSGD1,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BSGD2,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BSGD3,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BSGD4,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BSGD5,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SSGD1,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SSGD2,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SSGD3,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SSGD4,
                case when rth.fxd_crncy_code = 'SGD' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  SSGD5,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BTHB1,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BTHB2,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BTHB3,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BTHB4,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTB' then rth.VAR_CRNCY_UNITS else 0 end as  BTHB5,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%1%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  STHB1,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%2%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  STHB2,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%3%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  STHB3,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%4%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  STHB4,
                case when rth.fxd_crncy_code = 'THB' and rth.rtlist_num like '%5%' and rth.ratecode = 'TTS' then rth.VAR_CRNCY_UNITS else 0 end as  STHB5
        
          from   tbaadm.rth rth
          where  RATECODE in ('1HS', '1HP','TTB','TTS')
          and    Rtlist_date = TO_DATE( CAST (  vi_StartDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
          and    trim(VAR_CRNCY_CODE) = 'MMK'
        )q;
      End;

     out_rec:=	(
                v_Branch                || '|' || 
                v_TellerName            || '|' ||
                v_USDUnits              || '|' ||
                v_USDKyats              || '|' ||
                v_EURUnits              || '|' ||
                v_EURKyats              || '|' ||
                v_SGDUnits              || '|' ||
                v_SGDKyats              || '|' ||
                v_THBUnits              || '|' ||
                v_THBKyats              || '|' || 
                BUSD1                   || '|' ||
                BUSD2                   || '|' || 
                BUSD3                   || '|' || 
                BUSD4                   || '|' || 
                BUSD5                   || '|' || 
                SUSD1                   || '|' || 
                SUSD2                   || '|' || 
                SUSD3                   || '|' || 
                SUSD4                   || '|' || 
                SUSD5                   || '|' ||
                BEUR1                   || '|' || 
                BEUR2                   || '|' || 
                BEUR3                   || '|' || 
                BEUR4                   || '|' || 
                BEUR5                   || '|' || 
                SEUR1                   || '|' || 
                SEUR2                   || '|' || 
                SEUR3                   || '|' || 
                SUSD4                   || '|' || 
                SEUR5                   || '|' ||
                BSGD1                   || '|' || 
                BSGD2                   || '|' || 
                BSGD3                   || '|' || 
                BSGD4                   || '|' || 
                BSGD5                   || '|' || 
                SSGD1                   || '|' || 
                SSGD2                   || '|' || 
                SSGD3                   || '|' || 
                SSGD4                   || '|' || 
                SSGD5                   || '|' ||
                BTHB1                   || '|' || 
                BTHB2                   || '|' || 
                BTHB3                   || '|' || 
                BTHB4                   || '|' || 
                BTHB5                   || '|' || 
                STHB1                   || '|' || 
                STHB2                   || '|' || 
                STHB3                   || '|' || 
                STHB4                   || '|' || 
                STHB5
             
              );

			dbms_output.put_line(out_rec);
      
  END FIN_CBM_TOTAL_FCY_BUYSELL;

END FIN_CBM_TOTAL_FCY_BUYSELL;
/
