CREATE OR REPLACE PACKAGE               remitDetailsPack AS

PROCEDURE remitDetailsProc(inp_str IN varchar2,
                                out_retCode OUT Number,
                                out_rec OUT varchar2);

END remitDetailsPack;
 

/


CREATE OR REPLACE PACKAGE BODY               remitDetailsPack AS
--{
    out_rec                     varchar2(30000);
    gv_outrec                    varchar2(30000);
    out_retCode                    number;
    OutArr                        tbaadm.basp0099.ArrayType;
    iv_bankCode                   tbaadm.gam.bank_id%type;
    uadArr                       tbaadm.basp0099.ArrayType;
    lv_bankId                    TBAADM.GAM.bank_id%TYPE;
    lv_tranDate                 TBAADM.DTD.TRAN_DATE%TYPE;

    -------------------------------------------------------------------
    --CURSOR
    --------------------------------------------------------------------
    CURSOR remitDetails(lv_bankCode tbaadm.sol.bank_code%type,lv_bankId tbaadm.gam.bank_id%type,lv_tranDate tbaadm.dtd.tran_date%type)is
    SELECT  TRAN_RMKS,REF_NUM,TRAN_ID,TRAN_AMT,TRAN_CRNCY_CODE,PART_TRAN_SRL_NUM,UAD_MODULE_ID,UAD_MODULE_KEY FROM tbaadm.gam g,tbaadm.dtd d
    WHERE foracid in(
    select distinct oap_acct from CUSTOM.CCHRG_TBL where BANKCODE=lv_bankCode and del_flg='N' and bank_id=lv_bankId
    UNION
    select oab_acct from CUSTOM.CCHRG_TBL where BANKCODE!=lv_bankCode and del_flg='N' and bank_id=lv_bankId)
    and acct_cls_flg='N' and entity_cre_flg='Y' and g.del_flg=d.del_flg and g.BANK_ID = lv_bankId and g.acid=d.acid and d.del_flg='N' and g.bank_id=d.bank_id
    and tran_date=lv_tranDate and PART_TRAN_TYPE='C' and g.BANK_ID = lv_bankId and pstd_flg='Y'
    and RPT_CODE in
    (SELECT VARIABLE_VALUE FROM CUSTOM.C_CGPM where MODULE_NAME = 'REMITTANCE' AND SUB_MODULE_NAME = 'INTERBANK' AND
    variable_name='RPT_CODE' and DEL_FLG = 'N' AND BANK_ID = lv_bankId
    UNION
    SELECT VARIABLE_VALUE FROM CUSTOM.C_CGPM where MODULE_NAME = 'REMITTANCE' AND SUB_MODULE_NAME = 'INTERBRANCH' AND
    variable_name='RPT_CODE' and DEL_FLG = 'N' AND BANK_ID = lv_bankId
    );


    ------------------------------------------------------------------
    --PROCEDURE
    ------------------------------------------------------------------
    PROCEDURE remitDetailsProc(inp_str IN varchar2,out_retCode OUT Number,out_rec OUT varchar2)
    AS

    lv_recInd                   varchar2(1):='';
    lv_fileName                 varchar2(80);
    lv_acid                     TBAADM.GAM.ACID%TYPE;
    lv_foracid                  TBAADM.GAM.FORACID%TYPE;
    lv_remName                  varchar2(80);
    lv_remNRC                   varchar2(80);
    lv_remAddr                  varchar2(180);
    lv_remPhone                 varchar2(80);
    lv_remPurp                  varchar2(80);
    lv_addtInfo                 varchar2(180);
    lv_benName                  varchar2(80);
    lv_benPhone                 varchar2(80);
    lv_tranId                   varchar2(80);
    lv_amt                      varchar2(80);
    lv_tranCcy                  varchar2(10);
    lv_partTranSrlNo            number;
    lv_uadModuleId              varchar2(20);
    lv_uadModuleKey                varchar2(80);




    BEGIN
    --{


    -----------------------------------------------------------------
    -- Open the Cursor C1
    -----------------------------------------------------------------
    <<nextrec>>


    IF (NOT remitDetails%ISOPEN)  THEN
    --{

        tbaadm.basp0099.formInputArr (inp_str,OutArr);
        iv_bankCode            := OutArr(0);
        lv_tranDate            := to_date(OutArr(1),'DD-MM-YYYY');
        lv_bankId           := OutArr(2);
      -- dbms_output.put_line(iv_bankCode);
      -- dbms_output.put_line(lv_tranDate);
      -- dbms_output.put_line(lv_bankId);
    OPEN remitDetails(iv_bankCode,lv_bankId,lv_tranDate);

    --}
    END IF;
    ------------------------------------------------------------------
    --Fetch the Cursor remitDetails
    ------------------------------------------------------------------
    FETCH remitDetails
    INTO lv_benName,
                            lv_benPhone,
                            lv_tranId,
                            lv_amt,
                            lv_tranCcy,
                            lv_partTranSrlNo,
                            lv_uadModuleId,
                            lv_uadModuleKey;
    --dbms_output.put_line(lv_foracid);

    IF (remitDetails%NOTFOUND)
    THEN
        CLOSE remitDetails;

        out_retcode := 1;
        RETURN;
    END IF;






                          BEGIN
                        --{
                                select replace(ADDTL_DETAIL_INFO,'|','!') into lv_addtInfo from tbaadm.uad where module_key=lv_uadModuleKey and MODULE_ID=lv_uadModuleId and bank_id=lv_bankId;

                                EXCEPTION when no_data_found then
                                lv_addtInfo                :='';

                        --}
                        END;
                        IF(lv_addtInfo is not NULL)THEN
                        --{
                                tbaadm.basp0099.formInputArr(lv_addtInfo,uadArr);
                                lv_remName            := uadArr(1);
                                lv_remNRC             := uadArr(2);
                                lv_remAddr            := uadArr(3);
                                lv_remPhone           := uadArr(4);
                                lv_remPurp            := uadArr(5);
                        --}
                        END IF;





    ------------------------------------------------------------------
    --Output Generation
    ------------------------------------------------------------------


                    out_rec := lv_remName        ||'|'||
                                lv_remPhone       ||'|'||
                                lv_benName      ||'|'||
                                lv_benPhone     ||'|'||
                                lv_tranId         ||'|'||
                                lv_tranDate     ||'|'||
                                lv_amt          ||'|'||
                                lv_tranCcy    ;
                                RETURN;




--}
END remitDetailsProc;

END remitDetailsPack;
/
