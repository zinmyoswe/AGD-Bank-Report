CREATE OR REPLACE PACKAGE               FIN_NOSTRO_IN_OUT_REMIT AS 

  subtype limited_string is varchar2(2000);
  PROCEDURE FIN_NOSTRO_IN_OUT_REMIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string );

END FIN_NOSTRO_IN_OUT_REMIT;
/


CREATE OR REPLACE PACKAGE BODY                             FIN_NOSTRO_IN_OUT_REMIT AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  
  outArr			tbaadm.basp0099.ArrayType;   -- Input Parse Array
	vi_tranDate		Varchar2(20);		    	     -- Input to procedure
  vi_currency   varchar2(3);

  CURSOR ExtractData is
  select distinct CRNCY_CODE from tbaadm.gstt where CRNCY_CODE = 'USD';

   FUNCTION FUNC_GET_AMOUNT(tranDate varchar2, currency varchar2, code varchar2,
   bankCode varchar2) 
   RETURN TBAADM.COLLECTION_GEN_MAINT_TBL.COLLECTION_AMT%TYPE AS
  
   v_amount TBAADM.COLLECTION_GEN_MAINT_TBL.COLLECTION_AMT%TYPE;
  
  BEGIN
    select sum(collection_amt) into v_amount
    from tbaadm.cgm 
    where collection_code = code 
    and CORR_COLL_BANK_CODE = bankCode
    --and CORR_COLL_BR_CODE = '001' 
    and COLLECTION_CRNCY = upper(currency)
    and DATE_OF_REMIT = TO_DATE( CAST ( tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' );
    RETURN v_amount;
  END FUNC_GET_AMOUNT;

  FUNCTION FUNC_GET_OPENING_AMOUNT(glSubHeadCode varchar2, currency varchar2)
  RETURN TBAADM.eab.value_date_tot_tran%TYPE AS
    
    v_openintAmount TBAADM.eab.value_date_tot_tran%TYPE;
    
  BEGIN
  select ABS(sum(eab.value_date_tot_tran))
            into v_openintAmount
            from tbaadm.eab,custom.custom_ctd_dtd_acli_view cdav
            where cdav.acid = tbaadm.eab.acid
            and eod_date = ( 
            select  eod_date   
            from(
              select eod_date
              from tbaadm.eab,custom.custom_ctd_dtd_acli_view cdav
              where tbaadm.eab.eod_date < TO_DATE( CAST ( vi_tranDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )           
              and cdav.acid = tbaadm.eab.acid
              --and cdav.REF_CRNCY_CODE = upper('EUR')
              and cdav.gl_sub_head_code = glSubHeadCode
              --and rownum =1
              order by eod_date desc)  where rownum =1
              )
              and cdav.REF_CRNCY_CODE = upper(currency)
              and cdav.gl_sub_head_code = glSubHeadCode;
  RETURN v_openintAmount;
  END FUNC_GET_OPENING_AMOUNT;

  FUNCTION FUNC_GET_GLSUBHEADCODE(variableName varchar2)
  RETURN CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%TYPE AS
  
  v_glSubHeadCode CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
  BEGIN
    SELECT VARIABLE_VALUE INTO v_glSubHeadCode
    FROM CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE
    WHERE VARIABLE_NAME like variableName
    AND MODULE_NAME = 'REPORT'
    AND SUB_MODULE_NAME = 'GL_SUB_HEAD_CODE'
    AND BANK_ID = '01';
    RETURN v_glSubHeadCode;
    
    
  END FUNC_GET_GLSUBHEADCODE;

  PROCEDURE FIN_NOSTRO_IN_OUT_REMIT(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT limited_string ) AS
      
      v_openingAmtDBS number;
      v_openingAmtOCBC number;
      v_openingAmtUOB  number;
      v_openingAmtKASIKORN number;
      v_openingAmtBANGKOK number;
      v_openingAmtOCBCVISA number;
      v_openingAmtMAYKL number;
      v_openingAmtSIAMCOMMERCIAL number;
      v_openingAmtCIMBIslamic number;
      v_openingAmtCIMB number;
      v_openingAmtMAYSG number;
      
      v_inwardAmtDBS number;
      v_inwardAmtOCBC number;
      v_inwardAmtUOB  number;
      v_inwardAmtKASIKORN number;
      v_inwardAmtBANGKOK number;
      v_inwardAmtOCBCVISA number;
      v_inwardAmtMAYKL number;
      v_inwardAmtSIAMCOMMERCIAL number;
      v_inwardAmtCIMBIslamic number;
      v_inwardAmtCIMB number;
      v_inwardAmtMAYSG number;
      
      v_outwardAmtDBS number;
      v_outwardAmtOCBC number;
      v_outwardAmtUOB  number;
      v_outwardAmtKASIKORN number;
      v_outwardAmtBANGKOK number;
      v_outwardAmtOCBCVISA number;
      v_outwardAmtMAYKL number;
      v_outwardAmtSIAMCOMMERCIAL number;
      v_outwardAmtCIMBIslamic number;
      v_outwardAmtCIMB number;
      v_outwardAmtMAYSG number;
      
      v_currency varchar2(3);
      
      v_dbsGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_ocbcGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_uobGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_kasikornGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_bkkGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_ocbcVisaGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_mayKLGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_scGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_cimbISGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_cimbGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      v_maySGGL CUSTOM.CUST_RPTCUST_GL_SUB_HEAD_TABLE.VARIABLE_VALUE%type;
      
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
    
    vi_tranDate:=outArr(0);
    vi_currency:=outArr(1);
    
    v_dbsGL := FUNC_GET_GLSUBHEADCODE('DBS');
    v_ocbcGL := FUNC_GET_GLSUBHEADCODE('OCBC');
    V_Uobgl := Func_Get_Glsubheadcode('UOB');
    v_kasikornGL := FUNC_GET_GLSUBHEADCODE('KASIKORN_01');
    v_bkkGL := FUNC_GET_GLSUBHEADCODE('BKK_BANK');
    v_ocbcVisaGL := FUNC_GET_GLSUBHEADCODE('OCBC_SG');
    v_mayKLGL := FUNC_GET_GLSUBHEADCODE('MAY_BANK_MYR');
    v_scGL := FUNC_GET_GLSUBHEADCODE('SIAM_COMMERCIAL');
    v_cimbISGL := FUNC_GET_GLSUBHEADCODE('CIMB_ISLAMIC');
    v_cimbGL := FUNC_GET_GLSUBHEADCODE('CIMB');
    v_maySGGL := FUNC_GET_GLSUBHEADCODE('MAY_BANK_SGD');
--------------------------------DBS IN/OUT---------------------------------------
    v_openingAmtDBS := FUNC_GET_OPENING_AMOUNT(v_dbsGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','DB01');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','DB01');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','DB01');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','DB01');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','DB01');
    ELSE
    v_inwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','DB01');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','DB01');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','DB01');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','DB01');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','DB01');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','DB01');
    ELSE
    v_outwardAmtDBS := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','DB01');
    END IF;
--------------------------------OCBC IN/OUT-------------------------------------
    v_openingAmtOCBC := FUNC_GET_OPENING_AMOUNT(v_ocbcGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','OC01');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','OC01');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','OC01');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','OC01');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','OC01');
    ELSE
    v_inwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','OC01');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','OC01');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','OC01');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','OC01');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','OC01');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','OC01');
    ELSE
    v_outwardAmtOCBC := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','OC01');
    END IF;
--------------------------------UOB IN/OUT--------------------------------------
    v_openingAmtUOB := FUNC_GET_OPENING_AMOUNT(v_uobGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','UO01');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','UO01');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','UO01');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','UO01');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','UO01');
    ELSE
    v_inwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','UO01');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','UO01');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','UO01');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','UO01');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','UO01');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','UO01');
    ELSE
    v_outwardAmtUOB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','UO01');
    END IF;
--------------------------------KASIKORN IN/OUT---------------------------------
    v_openingAmtKASIKORN := FUNC_GET_OPENING_AMOUNT(v_KASIKORNGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','KB03');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','KB03');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','KB03');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','KB03');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','KB03');
    ELSE
    v_inwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','KB03');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','KB03');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','KB03');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','KB03');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','KB03');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','KB03');
    ELSE
    v_outwardAmtKASIKORN := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','KB03');
    END IF;
--------------------------------BANGKOK IN/OUT----------------------------------
    v_openingAmtBANGKOK := FUNC_GET_OPENING_AMOUNT(v_bkkGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','BK03');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','BK03');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','BK03');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','BK03');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','BK03');
    ELSE
    v_inwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','BK03');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','BK03');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','BK03');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','BK03');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','BK03');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','BK03');
    ELSE
    v_outwardAmtBANGKOK := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','BK03');
    END IF;
--------------------------------OCBCVISA IN/OUT---------------------------------
    v_openingAmtOCBCVISA := FUNC_GET_OPENING_AMOUNT(v_ocbcVisaGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','OC02');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','OC02');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','OC02');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','OC02');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','OC02');
    ELSE
    v_inwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','OC02');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','OC02');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','OC02');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','OC02');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','OC02');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','OC02');
    ELSE
    v_outwardAmtOCBCVISA := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','OC02');
    END IF;
--------------------------------MAYKL IN/OUT------------------------------------
    v_openingAmtMAYKL := FUNC_GET_OPENING_AMOUNT(v_mayKLGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','MY02');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','MY02');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','MY02');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','MY02');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','MY02');
    ELSE
    v_inwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','MY02');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','MY02');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','MY02');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','MY02');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','MY02');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','MY02');
    ELSE
    v_outwardAmtMAYKL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','MY02');
    END IF;
--------------------------------MAYSG IN/OUT------------------------------------
    v_openingAmtMAYSG := FUNC_GET_OPENING_AMOUNT(v_maySGGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','MY01');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','MY01');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','MY01');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','MY01');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','MY01');
    ELSE
    v_inwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','MY01');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','MY01');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','MY01');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','MY01');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','MY01');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','MY01');
    ELSE
    v_outwardAmtMAYSG := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','MY01');
    END IF;
--------------------------------SIAMCOMMERCIAL IN/OUT---------------------------
    v_openingAmtSIAMCOMMERCIAL := FUNC_GET_OPENING_AMOUNT(v_scGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','SC03');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','SC03');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','SC03');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','SC03');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','SC03');
    ELSE
    v_inwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','SC03');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','SC03');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','SC03');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','SC03');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','SC03');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','SC03');
    ELSE
    v_outwardAmtSIAMCOMMERCIAL := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','SC03');
    END IF;
--------------------------------CIMBIslamic IN/OUT------------------------------
    v_openingAmtCIMBIslamic := FUNC_GET_OPENING_AMOUNT(v_cimbISGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','CI01');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','CI01');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','CI01');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','CI01');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','CI01');
    ELSE
    v_inwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','CI01');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','CI01');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','CI01');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','CI01');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','CI01');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','CI01');
    ELSE
    v_outwardAmtCIMBIslamic := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','CI01');
    END IF;
--------------------------------CIMB IN/OUT-------------------------------------
    v_openingAmtCIMB := FUNC_GET_OPENING_AMOUNT(v_cimbGL, vi_currency);
    if upper(vi_currency) = 'USD' then
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIUS','CI02');
    elsif upper(vi_currency) = 'EUR' then
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIEU','CI02');
    elsif upper(vi_currency) = 'SGD' then
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTISG','CI02');
    elsif upper(vi_currency) = 'THB' then
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTITH','CI02');
    elsif upper(vi_currency) = 'JPY' then
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIJP','CI02');
    ELSE
    v_inwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTIMY','CI02');
    END IF;
                  ------------------------------
    if upper(vi_currency) = 'USD' then
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOUS','CI02');
    elsif upper(vi_currency) = 'EUR' then
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOEU','CI02');
    elsif upper(vi_currency) = 'SGD' then
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOSG','CI02');
    elsif upper(vi_currency) = 'THB' then
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOTH','CI02');
    elsif upper(vi_currency) = 'JPY' then
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOJP','CI02');
    ELSE
    v_outwardAmtCIMB := FUNC_GET_AMOUNT(vi_tranDate, vi_currency, 'TTOMY','CI02');
    END IF;
--------------------------------------------------------------------------------
IF NOT ExtractData%ISOPEN THEN
        --{
          BEGIN
          --{
            OPEN ExtractData;
          --}
          END;
    
        --}
        END IF;
        
        IF ExtractData%ISOPEN THEN
        --{
          FETCH	ExtractData
          INTO	 v_currency;
          
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
  BEGIN
    IF v_openingAmtDBS IS NULL THEN v_openingAmtDBS := 0.0; END IF;
    IF v_openingAmtOCBC IS NULL THEN v_openingAmtOCBC := 0.0; END IF;
    IF v_openingAmtUOB  IS NULL THEN v_openingAmtUOB := 0.0; END IF;
    IF v_openingAmtKASIKORN IS NULL THEN v_openingAmtKASIKORN := 0.0; END IF;
    IF v_openingAmtBANGKOK IS NULL THEN v_openingAmtBANGKOK := 0.0; END IF;
    IF v_openingAmtOCBCVISA IS NULL THEN v_openingAmtOCBCVISA := 0.0; END IF;
    IF v_openingAmtMAYKL IS NULL THEN v_openingAmtMAYKL := 0.0; END IF;
    IF v_openingAmtSIAMCOMMERCIAL IS NULL THEN v_openingAmtSIAMCOMMERCIAL := 0.0; END IF;
    IF v_openingAmtCIMBIslamic IS NULL THEN v_openingAmtCIMBIslamic := 0.0; END IF;
    IF v_openingAmtCIMB IS NULL THEN v_openingAmtCIMB := 0.0; END IF;
    IF v_openingAmtMAYSG IS NULL THEN v_openingAmtMAYSG := 0.0; END IF;
    IF v_inwardAmtDBS IS NULL THEN v_inwardAmtDBS := 0.0; END IF;
    IF v_inwardAmtOCBC IS NULL THEN v_inwardAmtOCBC := 0.0; END IF;
    IF v_inwardAmtUOB  IS NULL THEN v_inwardAmtUOB := 0.0; END IF;
    IF v_inwardAmtKASIKORN IS NULL THEN v_inwardAmtKASIKORN := 0.0; END IF;
    IF v_inwardAmtBANGKOK IS NULL THEN v_inwardAmtBANGKOK := 0.0; END IF;
    IF v_inwardAmtOCBCVISA IS NULL THEN v_inwardAmtOCBCVISA := 0.0; END IF;
    IF v_inwardAmtMAYKL IS NULL THEN v_inwardAmtMAYKL := 0.0; END IF;
    IF v_inwardAmtSIAMCOMMERCIAL IS NULL THEN v_inwardAmtSIAMCOMMERCIAL := 0.0; END IF;
    IF v_inwardAmtCIMBIslamic IS NULL THEN v_inwardAmtCIMBIslamic := 0.0; END IF;
    IF v_inwardAmtCIMB IS NULL THEN v_inwardAmtCIMB := 0.0; END IF;
    IF v_inwardAmtMAYSG IS NULL THEN v_inwardAmtMAYSG := 0.0; END IF;
    IF v_outwardAmtDBS IS NULL THEN v_outwardAmtDBS := 0.0; END IF;
    IF v_outwardAmtOCBC IS NULL THEN v_outwardAmtOCBC := 0.0; END IF;
    IF v_outwardAmtUOB  IS NULL THEN v_outwardAmtUOB := 0.0; END IF;
    IF v_outwardAmtKASIKORN IS NULL THEN v_outwardAmtKASIKORN := 0.0; END IF;
    IF v_outwardAmtBANGKOK IS NULL THEN v_outwardAmtBANGKOK := 0.0; END IF;
    IF v_outwardAmtOCBCVISA IS NULL THEN v_outwardAmtOCBCVISA := 0.0; END IF;
    IF v_outwardAmtMAYKL IS NULL THEN v_outwardAmtMAYKL := 0.0; END IF;
    IF v_outwardAmtSIAMCOMMERCIAL IS NULL THEN v_outwardAmtSIAMCOMMERCIAL := 0.0; END IF;
    IF v_outwardAmtCIMBIslamic IS NULL THEN v_outwardAmtCIMBIslamic := 0.0; END IF;
    IF v_outwardAmtCIMB IS NULL THEN v_outwardAmtCIMB := 0.0; END IF;
    IF v_outwardAmtMAYSG IS NULL THEN v_outwardAmtMAYSG := 0.0; END IF;
  END;
--------------------------------------------------------------------------------
  out_rec:=	(v_openingAmtDBS || '|' ||v_openingAmtOCBC || '|' ||
  v_openingAmtUOB  || '|' ||v_openingAmtKASIKORN || '|' ||
  v_openingAmtBANGKOK || '|' ||v_openingAmtOCBCVISA || '|' ||
  v_openingAmtMAYKL || '|' ||v_openingAmtSIAMCOMMERCIAL || '|' ||
  v_openingAmtCIMBIslamic || '|' ||v_openingAmtCIMB || '|' ||
  v_openingAmtMAYSG || '|' ||v_inwardAmtDBS || '|' ||
  v_inwardAmtOCBC || '|' ||v_inwardAmtUOB  || '|' ||
  v_inwardAmtKASIKORN || '|' ||v_inwardAmtBANGKOK || '|' ||
  v_inwardAmtOCBCVISA || '|' ||v_inwardAmtMAYKL || '|' ||
  v_inwardAmtSIAMCOMMERCIAL || '|' ||v_inwardAmtCIMBIslamic || '|' ||
  v_inwardAmtCIMB || '|' ||v_inwardAmtMAYSG || '|' ||
  v_outwardAmtDBS || '|' ||v_outwardAmtOCBC || '|' ||
  v_outwardAmtUOB  || '|' ||v_outwardAmtKASIKORN || '|' ||
  v_outwardAmtBANGKOK || '|' ||v_outwardAmtOCBCVISA || '|' ||
  v_outwardAmtMAYKL || '|' ||v_outwardAmtSIAMCOMMERCIAL || '|' ||
  v_outwardAmtCIMBIslamic || '|' ||v_outwardAmtCIMB || '|' ||v_outwardAmtMAYSG );
    
    dbms_output.put_line(out_rec);


  END FIN_NOSTRO_IN_OUT_REMIT;

END FIN_NOSTRO_IN_OUT_REMIT;
/
