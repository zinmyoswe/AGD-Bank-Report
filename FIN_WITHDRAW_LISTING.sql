CREATE OR REPLACE PACKAGE                                          FIN_WITHDRAW_LISTING AS 

  PROCEDURE FIN_WITHDRAW_LISTING(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_WITHDRAW_LISTING;
/


CREATE OR REPLACE PACKAGE BODY                                                                              FIN_WITHDRAW_LISTING
AS
  -------------------------------------------------------------------------------------
  -- Cursor declaration
  -- This cursor will fetch all the data based on the main query
  -------------------------------------------------------------------------------------
  outArr tbaadm.basp0099.ArrayType; -- Input Parse Array
  vi_startDate   VARCHAR2(10);        -- Input to procedure
  vi_endDate     VARCHAR2(10);        -- Input to procedure
  vi_SchemeType  VARCHAR2(5);         -- Input to procedure
  vi_SchemeCode  VARCHAR2(6);         -- Input to procedure
  vi_currency    VARCHAR2(5);         -- Input to procedure
  vi_ReversalType VARCHAR2(20);       -- Input to procedure
  vi_entryUserId VARCHAR2(20);        -- Input to procedure
  vi_branchCode  VARCHAR2(5);         -- Input to procedure
  -----------------------------------------------------------------------------
  -- CURSOR declaration FIN_DRAWING_SPBX CURSOR
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- CURSOR ExtractData with Scheme Code
  -----------------------------------------------------------------------------
  ---------------------------User ID(with) and Scheme Code (with)-------------
  ----------------------------------------------------------------------------
  CURSOR ExtractDataWithoutReversal (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2,ci_currency VARCHAR2, ci_entryUserId VARCHAR2, ci_branchCode VARCHAR2)
  IS
  
    select q.entryNumber,
       q.entryDate,
       q.enteredBy,
       q.accountNumber,
       q.amount,
       q.accountName
from
(SELECT detail.tran_id  AS entryNumber,
      detail.pstd_date     AS entryDate,--detail.tran_date
      detail.entry_user_id AS enteredBy,
      gam.foracid          AS accountNumber,
      detail.tran_amt      AS amount,
      gam.acct_name        AS accountName,
      detail.tran_date     as Tran_Date
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam
    WHERE detail.acid         = gam.acid
    AND gam.del_flg           = 'N'
    --AND gam.acct_cls_flg      = 'N'
    AND gam.bank_id           ='01'
    AND gam.acct_crncy_code   = UPPER(ci_currency)
    AND detail.pstd_flg       = 'Y'
    AND detail.TRAN_TYPE = 'C'
    AND detail.part_tran_type = 'D'
    AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.SOL_ID           like '%' || ci_branchCode || '%'
    AND gam.schm_type        like '%' || UPPER(ci_SchemeType) || '%'
    AND gam.schm_code        like '%' || UPPER(ci_SchemeCode) || '%'
    AND detail.entry_user_id like '%' || UPPER(ci_entryUserId) || '%'
    and trim (detail.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
    where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
    and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) ---Without Reversal
    --ORDER BY detail.tran_date ASC, detail.tran_id ASC, gam.foracid ASC
    
    union all
    
    SELECT V.entryNumber, V.entryDate, V.enteredBy, V.accountNumber, V.amount
    , V.accountName, V.Tran_Date FROM -- ****(NOT IN CLAUSE REMOVE FOR PERFORMANCE)****
    (
    SELECT T2.entryNumber AS tID, T1.* FROM
    (
      SELECT detail.tran_id  AS entryNumber,
        detail.pstd_date     AS entryDate,--detail.tran_date
        --detail.entry_user_id AS enteredBy,
        NVL(d.CHANNEL_DEVICE_ID,'') AS enteredBy,
        gam.foracid          AS accountNumber,
        detail.tran_amt      AS amount,
        gam.acct_name        AS accountName,
        detail.tran_date     as Tran_Date
      FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam,
      tbaadm.DCTI d
      WHERE detail.acid         = gam.acid
      and trim(d.free_text1)    = trim(detail.tran_id)
      and detail.tran_date = d.tran_date
      and d.channel_id = 'EFT'
      and d.free_text2 in ('10300004','00240001')
      AND gam.del_flg           = 'N'
      --AND gam.acct_cls_flg      = 'N'
      AND gam.bank_id           ='01'
      AND gam.acct_crncy_code   = UPPER(ci_currency)
      AND detail.pstd_flg       = 'Y'
      AND detail.TRAN_TYPE = 'T'    
      AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,1)= 'CWD' AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,4)= 'EFT'
      AND detail.part_tran_type = 'D'
      and detail.GL_SUB_HEAD_CODE NOT IN ('10102')
      AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND gam.SOL_ID           like '%' || ci_branchCode || '%'
      and d.sol_id             like '%' || ci_branchCode || '%'
      AND gam.schm_type       like '%'  || UPPER(ci_SchemeType) || '%'
      AND gam.schm_code        like '%' || UPPER(ci_SchemeCode) || '%'
      AND detail.entry_user_id like '%' || UPPER(ci_entryUserId) || '%'
      --and trim (detail.tran_id) NOT IN (select trim(CONT_TRAN_ID) from TBAADM.ATD atd
      --where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
      --and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) ) ---Without Reversal
      --ORDER BY detail.tran_date ASC, detail.tran_id ASC, gam.foracid ASC
    ) T1 LEFT JOIN
    (
      SELECT REGEXP_SUBSTR(detail.TRAN_RMKS,'[^/]+',1,1) AS entryNumber,
      detail.pstd_date     AS entryDate,--detail.tran_date
      --detail.entry_user_id AS enteredBy,
      NVL(d.CHANNEL_DEVICE_ID,'') AS enteredBy,
      gam.foracid          AS accountNumber,
      detail.tran_amt      AS amount,
      gam.acct_name        AS accountName,
      detail.tran_date     as Tran_Date
      FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam,
      tbaadm.DCTI d
      WHERE detail.acid         = gam.acid
      and trim(d.free_text1)    = trim(detail.tran_id)
      and detail.tran_date = d.tran_date
      and d.channel_id = 'EFT'
      and d.free_text2 in ('10300004','00240001')
      AND gam.del_flg           = 'N'
      --AND gam.acct_cls_flg      = 'N'
      AND gam.bank_id           ='01'
      AND gam.acct_crncy_code   = UPPER(ci_currency)
      AND detail.pstd_flg       = 'Y'
      AND detail.TRAN_TYPE = 'T'    
      AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,1)= 'CWC' AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,4)= 'EFT'
      AND detail.part_tran_type = 'C'
      and detail.GL_SUB_HEAD_CODE NOT IN ('10102')
      AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
      AND gam.SOL_ID           like '%' || ci_branchCode || '%'
      and d.sol_id             like '%' || ci_branchCode || '%'
      AND gam.schm_type       like '%'  || UPPER(ci_SchemeType) || '%'
      AND gam.schm_code        like '%' || UPPER(ci_SchemeCode) || '%'
      AND detail.entry_user_id like '%' || UPPER(ci_entryUserId) || '%'
      AND REGEXP_SUBSTR(detail.TRAN_RMKS,'[^/]+',1,1) IS NOT NULL
      )T2 ON T2.entryNumber = T1.entryNumber
      
      )V WHERE V.tID IS NULL
    ) q 
    order by q.Tran_Date asc,q.entryNumber asc, q.accountNumber asc;
  
  --------------------------------------------------------------------------
  CURSOR ExtractDataWithReversal (ci_startDate VARCHAR2, ci_endDate VARCHAR2,ci_SchemeType VARCHAR2, ci_SchemeCode VARCHAR2, ci_currency VARCHAR2, ci_entryUserId VARCHAR2, ci_branchCode VARCHAR2)
  IS
  
    select q.entryNumber,
       q.entryDate,
       q.enteredBy,
       q.accountNumber,
       q.amount,
       q.accountName
from
(SELECT detail.tran_id  AS entryNumber,
      detail.pstd_date     AS entryDate,--detail.tran_date
      detail.entry_user_id AS enteredBy,
      gam.foracid          AS accountNumber,
      detail.tran_amt      AS amount,
      gam.acct_name        AS accountName,
      detail.tran_date     as Tran_Date
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam
    WHERE detail.acid         = gam.acid
    AND gam.del_flg           = 'N'
    --AND gam.acct_cls_flg      = 'N'
    AND gam.bank_id           ='01'
    AND gam.acct_crncy_code   = UPPER(ci_currency)
    AND detail.pstd_flg       = 'Y'
    AND detail.TRAN_TYPE = 'C' 
    AND detail.part_tran_type = 'D'
    AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.SOL_ID           like '%' || ci_branchCode || '%'
    AND gam.schm_type        like '%' || UPPER(ci_SchemeType) || '%'
    AND gam.schm_code        like '%' || UPPER(ci_SchemeCode) || '%'
    AND detail.entry_user_id like '%' || UPPER(ci_entryUserId) || '%'
    --ORDER BY detail.tran_date ASC, detail.tran_id ASC, gam.foracid ASC
    union all
SELECT detail.tran_id  AS entryNumber,
      detail.pstd_date     AS entryDate,--detail.tran_date
      --detail.entry_user_id AS enteredBy,
      NVL(d.CHANNEL_DEVICE_ID,'') AS enteredBy,
      gam.foracid          AS accountNumber,
      detail.tran_amt      AS amount,
      gam.acct_name        AS accountName,
      detail.tran_date     as Tran_Date
    FROM custom.CUSTOM_CTD_DTD_ACLI_VIEW detail,
      tbaadm.general_acct_mast_table gam,
      tbaadm.DCTI d
    WHERE detail.acid         = gam.acid
    and trim(d.free_text1)    = trim(detail.tran_id)
    and detail.tran_date = d.tran_date
    and d.channel_id = 'EFT'
    and d.free_text2 in ('10300004','00240001')
    AND gam.del_flg           = 'N'
    --AND gam.acct_cls_flg      = 'N'
    AND gam.bank_id           ='01'
    AND gam.acct_crncy_code   = UPPER(ci_currency)
    AND detail.pstd_flg       = 'Y'
    AND detail.TRAN_TYPE = 'T'
    AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,1) LIKE 'CW%' AND REGEXP_SUBSTR(detail.TRAN_PARTICULAR,'[^/]+',1,4)= 'EFT'
    --AND detail.part_tran_type = 'D'
    and detail.GL_SUB_HEAD_CODE NOT IN ('10102')
    AND detail.tran_date BETWEEN TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) AND TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
    AND gam.SOL_ID           like '%' || ci_branchCode || '%'
    and d.sol_id             like '%' || ci_branchCode || '%'
    AND gam.schm_type        like '%' || UPPER(ci_SchemeType) || '%'
    AND gam.schm_code        like '%' || UPPER(ci_SchemeCode) || '%'
    AND detail.entry_user_id like '%' || UPPER(ci_entryUserId) || '%'
   -- ORDER BY detail.tran_date ASC, detail.tran_id ASC, gam.foracid ASC
   )q
    order by q.Tran_Date asc, q.entryNumber asc, q.accountNumber;---with Reversal
-------------------------------------------------------------------------------------------------
PROCEDURE FIN_WITHDRAW_LISTING(
    inp_str IN VARCHAR2,
    out_retCode OUT NUMBER,
    out_rec OUT VARCHAR2 )
IS
  v_entryNumber TBAADM.CTD_DTD_ACLI_VIEW.TRAN_ID%type;
  v_entryDate DATE;
  v_enteredBy TBAADM.CTD_DTD_ACLI_VIEW.ENTRY_USER_ID%type;
  v_accountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
  v_amount TBAADM.CTD_DTD_ACLI_VIEW.TRAN_AMT%type;
  v_accountName TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_NAME%type;
  v_BranchName TBAADM.BRANCH_CODE_TABLE.BR_SHORT_NAME%type;
  v_BankAddress TBAADM.BRANCH_CODE_TABLE.BR_ADDR_1%type;
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
  out_rec     := NULL;
  tbaadm.basp0099.formInputArr(inp_str, outArr);
  --------------------------------------
  -- Parsing the i/ps from the string
  --------------------------------------
  vi_startDate     :=outArr(0);
  vi_endDate       :=outArr(1);
  vi_SchemeType    :=outArr(2);
  vi_SchemeCode    :=outArr(3);
  vi_currency      :=outArr(4);
  vi_ReversalType  :=outArr(5);
  vi_entryUserId   :=outArr(6);
  vi_branchCode    :=outArr(7);
  
  --------------------------------------------------------------------------------------------------
  if( vi_startDate is null or vi_endDate is null or vi_currency is null or vi_ReversalType is null  ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;
  
  
  IF( vi_entryUserId IS NULL and vi_SchemeType IS NULL) THEN
    --resultstr := 'No Data For Report';
    out_rec:= ( '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-' || '|' || '-'  );
    --dbms_output.put_line(out_rec);
    out_retCode:= 1;
    RETURN;
  END IF;
  IF vi_SchemeType IS NULL OR vi_SchemeType = '' THEN
  vi_SchemeType  := '';
  END IF; 
  ------------------------------------------------------------------------------------------------- 
  IF vi_SchemeCode is null or vi_SchemeCode = '' THEN
    vi_SchemeCode := '';
  END IF;
  
  
  IF vi_branchCode is null or vi_branchCode = '' THEN
    vi_branchCode := '';
  END IF;
  
  IF vi_entryUserId is null or vi_entryUserId = '' THEN
    vi_entryUserId := '';
  END IF;
  ----------------------------Without Scheme Code  -----------------------------------
  IF vi_ReversalType like 'Without%' then
    
      --{
      IF NOT ExtractDataWithoutReversal%ISOPEN THEN
        --{
        BEGIN
          --{
          OPEN ExtractDataWithoutReversal ( vi_startDate , vi_endDate  ,vi_SchemeType ,vi_SchemeCode, vi_currency,vi_entryUserId, vi_branchCode );
          --}
        END;
        --}
      END IF;
      IF ExtractDataWithoutReversal%ISOPEN THEN
        --{
        FETCH ExtractDataWithoutReversal
        INTO v_entryNumber,
          v_entryDate,
          v_enteredBy,
          v_accountNumber,
          v_amount,
          v_accountName;
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataWithoutReversal%NOTFOUND THEN
          --{
          CLOSE ExtractDataWithoutReversal;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
      
  ELSIF vi_ReversalType like 'With%' then 
     --{
      IF NOT ExtractDataWithReversal%ISOPEN THEN
        --{
        BEGIN
          --{
          OPEN ExtractDataWithReversal ( vi_startDate , vi_endDate  ,vi_SchemeType ,vi_SchemeCode, vi_currency,vi_entryUserId, vi_branchCode );
          --}
        END;
        --}
      END IF;
      IF ExtractDataWithReversal%ISOPEN THEN
        --{
        FETCH ExtractDataWithReversal
        INTO v_entryNumber,
          v_entryDate,
          v_enteredBy,
          v_accountNumber,
          v_amount,
          v_accountName;
        ------------------------------------------------------------------
        -- Here it is checked whether the cursor has fetched
        -- something or not if not the cursor is closed
        -- and the out ret code is made equal to 1
        ------------------------------------------------------------------
        IF ExtractDataWithReversal%NOTFOUND THEN
          --{
          CLOSE ExtractDataWithReversal;
          out_retCode:= 1;
          RETURN;
          --}
        END IF;
        --}
      END IF;
    END IF;
---------------------------------------------------------------------------------------------      
  BEGIN
    -------------------------------------------------------------------------------
    -- GET BANK INFORMATION
    -------------------------------------------------------------------------------
    If vi_branchCode is not null then
    SELECT BRANCH_CODE_TABLE.BR_SHORT_NAME AS "BranchName",
      BRANCH_CODE_TABLE.BR_ADDR_1          AS "BankAddress",
      BRANCH_CODE_TABLE.PHONE_NUM          AS "BankPhone",
      BRANCH_CODE_TABLE.FAX_NUM            AS "BankFax"
    INTO v_BranchName,
      v_BankAddress,
      v_BankPhone,
      v_BankFax
    FROM TBAADM.SERVICE_OUTLET_TABLE SERVICE_OUTLET_TABLE ,
      TBAADM.BRANCH_CODE_TABLE BRANCH_CODE_TABLE
    WHERE SERVICE_OUTLET_TABLE.SOL_ID = vi_branchCode
    AND SERVICE_OUTLET_TABLE.BR_CODE  = BRANCH_CODE_TABLE.BR_CODE
    AND SERVICE_OUTLET_TABLE.DEL_FLG  = 'N'
    AND SERVICE_OUTLET_TABLE.BANK_ID  = '01';
    end if;
  END;
  -----------------------------------------------------------------------------------
  -- out_rec variable retrieves the data to be sent to LST file with pipe seperation//TO_CHAR(to_date(v_entryDate,'dd/Mon/yy'), 'dd/MM/yyyy')
  ------------------------------------------------------------------------------------
  out_rec:= (v_entryNumber || '|' || TO_CHAR(to_date(v_entryDate,'dd/Mon/yy'), 'dd/MM/yyyy') || '|' || v_enteredBy || '|' || v_accountNumber || '|' || v_amount || '|' || v_accountName || '|' || v_BranchName || '|' || v_BankAddress || '|' || v_BankPhone || '|' || v_BankFax || '|' || TO_CHAR(v_entryDate, 'HH24:MI:SS'));
  dbms_output.put_line(out_rec);
END FIN_WITHDRAW_LISTING;
END FIN_WITHDRAW_LISTING;
/
