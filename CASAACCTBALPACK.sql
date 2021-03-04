CREATE OR REPLACE PACKAGE        casaAcctBalPack AS

PROCEDURE casaAcctBalProc(inp_str IN varchar2,
                                out_retCode OUT Number,
                                out_rec OUT varchar2);

END casaAcctBalPack;
/


CREATE OR REPLACE PACKAGE BODY        casaAcctBalPack AS
--{
    out_rec                 varchar2(1400);
    out_retCode            number;
    OutArr                tbaadm.basp0099.ArrayType;
    iv_bankId           tbaadm.gam.bank_id%type;


    -------------------------------------------------------------------
    --CURSOR
    --------------------------------------------------------------------
    CURSOR casaAcctBal(bankid tbaadm.gam.bank_id%type)is
    select acid  from tbaadm.gac where FREE_CODE_1='YES' and bank_id=bankid;
--MINUTES part has to be added.

    ------------------------------------------------------------------
    --PROCEDURE
    ------------------------------------------------------------------
    PROCEDURE casaAcctBalProc(inp_str IN varchar2,out_retCode OUT Number,out_rec OUT varchar2)
    AS

    lv_recInd                   varchar2(1):='';
    lv_fileName                 varchar2(80);
    lv_acid                        TBAADM.GAM.ACID%TYPE;
    lv_acid1                        TBAADM.GAM.ACID%TYPE;
    lv_acid2                        TBAADM.GAM.ACID%TYPE;
    lv_cifId                    TBAADM.GAM.CIF_ID%TYPE;
    lv_acctName                    TBAADM.GAM.ACCT_NAME%TYPE;
    lv_accountNo                TBAADM.GAM.FORACID%TYPE;
    lv_balance                      TBAADM.GAM.CLR_BAL_AMT%TYPE;
    lv_PHONE                        crmuser.accounts.PHONE%TYPE;
    lv_remarks                        varchar2(100 CHAR);
    lv_remarks1                        varchar2(100 CHAR);
    --lv_asOfDate                 date :='';





    BEGIN
    --{

    -------------------------------------------------------------------------
    --Out Ret code is the code which controls
    --the while loop,it can have values 0,1
    --0 - The while loop is being executed
    --1 - Exit
    -------------------------------------------------------------------------

    -----------------------------------------------------------------
    -- Open the Cursor C1
    -----------------------------------------------------------------
    <<nextrec>>
    lv_acid:='';
    lv_acid1:='';
    lv_acid2:='';
    lv_cifId:='';
    lv_acctName:='';
    lv_accountNo:='';
    lv_balance:='';
    lv_PHONE:='';
    lv_remarks:='';
    lv_remarks1:='';



    IF (NOT casaAcctBal%ISOPEN)  THEN
    --{

        tbaadm.basp0099.formInputArr (inp_str,OutArr);
        iv_bankId        := OutArr(0);
        --iv_bankId:='01';
    OPEN casaAcctBal(iv_bankId);

    --}
    END IF;
    ------------------------------------------------------------------
    --Fetch the Cursor casaAcctBal
    ------------------------------------------------------------------
    FETCH casaAcctBal
    INTO lv_acid;

    IF (casaAcctBal%NOTFOUND)
    THEN
        CLOSE casaAcctBal;

        out_retcode := 1;
        RETURN;
    END IF;

         BEGIN
        --{
                SELECT acid
                INTO lv_acid1
                FROM tbaadm.smt
                WHERE acct_status = 'A' AND bank_id = iv_bankId and acid=lv_acid ;

                EXCEPTION when no_data_found then
                lv_acid1        :='';
                GOTO nextrec;
        --}
        END;
        BEGIN
        --{
                select distinct foracid,acid,acct_name,cif_id,clr_bal_amt
                into lv_accountNo,lv_acid2,lv_acctName,lv_cifId,lv_balance
                from tbaadm.gam g where g.acid=lv_acid1 and entity_cre_flg='Y' and del_flg='N' and acct_cls_flg='N' and bank_id=iv_bankId and
               	(exists (select * from tbaadm.gam g1 where schm_type = 'SBA' and g1.schm_type = g.schm_type and g1.acid=lv_acid1 )
		or exists (select * from tbaadm.gam g2 where schm_type = 'CAA' and g2.schm_type = g.schm_type and g2.acid=lv_acid1)) ;
                EXCEPTION when no_data_found then
                lv_accountNo        :='';
                lv_acid2            :='';
                lv_acctName            :='';
                lv_cifId            :='';
                lv_balance            :='';
                GOTO nextrec;
        --}
        END;
        BEGIN
        --{
                select trim(PREFERRED_MOBILE_ALERT_NO) into lv_phone from crmuser.accounts where orgkey=lv_cifId and bank_id=iv_bankId;

                EXCEPTION when no_data_found then
                lv_phone        :='';
                lv_remarks        :='CFIERR00019';
        --}
        END;
        IF(lv_remarks is not NULL)THEN
        --{
                BEGIN
                --{
                            select MSG_LITERAL into lv_remarks1 from CUSTOM.C_MMSG where MSG_ID=lv_remarks and del_flg='N';

                            EXCEPTION when no_data_found then
                            lv_remarks1    :='';
                   --}
                   END;
        --}
        END IF;
        IF(lv_phone is NULL)THEN
        --{
            lv_remarks1        :='PREFERRED_MOBILE_ALERT_NO not present for CIF';
        --}
        END IF;




    ------------------------------------------------------------------
    --Output Generation
    ------------------------------------------------------------------


                    out_rec :=  lv_accountNo    ||'|'||
                                lv_acctName    ||'|'||
                                lv_phone        ||'|'||
                                lv_balance     ||'|'||
                                lv_remarks1;
                                RETURN;


--}
END casaAcctBalProc;

END casaAcctBalPack;
/
