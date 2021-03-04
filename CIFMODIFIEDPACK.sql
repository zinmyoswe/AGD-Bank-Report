CREATE OR REPLACE PACKAGE        cifModifiedPack AS

PROCEDURE cifModifiedProc(inp_str IN varchar2,
                                out_retCode OUT Number,
                                out_rec OUT varchar2);

END cifModifiedPack;
/


CREATE OR REPLACE PACKAGE BODY        cifModifiedPack AS
--{
    out_rec                 varchar2(1900);
    out_retCode            number;
    OutArr                tbaadm.basp0099.ArrayType;
    iv_tranDate            date;
    lv_flg                varchar2(1):='Y';
    lv_header                        VARCHAR2(1);





    -------------------------------------------------------------------
    --CURSOR
    --------------------------------------------------------------------
    --CURSOR cifMod(tranDate date ) is
    --select distinct orgkey,name,embosname,UNIQUEID,phone,email,ADDRESS_LINE1,ADDRESS_LINE2,ADDRESS_LINE3,city,state,country,zip from CRMUSER.ACCOUNTS,
    --TBAADM.IRD where ENTITY_CRE_FLAG='Y'
    ----and to_date(rcre_time))=tranDate and entity_id=ORGKEY;
    --and to_date(to_char(rcre_time,'DD-MON-YY'))=to_date(tranDate) and entity_id=ORGKEY;

    CURSOR cifMod(tranDate date ) is
    select distinct c.orgkey,d.foracid,c.name,c.PREFERREDNAME,c.UNIQUEID,c.phone,c.email,c.ADDRESS_LINE1,c.ADDRESS_LINE2,c.ADDRESS_LINE3,c.city,c.state,c.country,c.zip
    from CRMUSER.ACCOUNTS c, TBAADM.IRD b,TBAADM.AAS a,TBAADM.GAM d
    where c.ENTITY_CRE_FLAG='Y' AND a.NMA_KEY_ID=c.orgkey and b.entity_id=c.ORGKEY and d.acid=a.acid and d.CIF_ID=c.ORGKEY
    and to_date(to_char(b.rcre_time,'DD-MON-YYYY'))=to_date(tranDate);

    ------------------------------------------------------------------
    --PROCEDURE
    ------------------------------------------------------------------
    PROCEDURE cifModifiedProc(inp_str IN varchar2,out_retCode OUT Number,out_rec OUT varchar2)
    AS

    lv_recInd                   varchar2(1):='';
    lv_fileName                 varchar2(80);
    lv_cifId                    CRMUSER.ACCOUNTS.orgkey%TYPE;
    lv_foracid			TBAADM.GENERAL_ACCT_MAST_TABLE.foracid%TYPE;
    lv_cifName                  CRMUSER.ACCOUNTS.NAME%TYPE;
    lv_phone                    CRMUSER.ACCOUNTS.phone%TYPE;
    lv_email                    CRMUSER.ACCOUNTS.email%TYPE;
    lv_email1			CRMUSER.PHONEEMAIL.email%TYPE;
    lv_phoneno1			CRMUSER.PHONEEMAIL.phoneno%TYPE;
    lv_address1                 CRMUSER.ACCOUNTS.ADDRESS_LINE1%TYPE;
    lv_address2                 CRMUSER.ACCOUNTS.ADDRESS_LINE2%TYPE;
    lv_address3                 CRMUSER.ACCOUNTS.ADDRESS_LINE3%TYPE;
    lv_city                     CRMUSER.ACCOUNTS.city%TYPE;
    lv_state                    CRMUSER.ACCOUNTS.state%TYPE;
    lv_country                  CRMUSER.ACCOUNTS.country%TYPE;
    lv_zip                      CRMUSER.ACCOUNTS.zip%TYPE;
    lv_city1                    CRMUSER.ACCOUNTS.city%TYPE;
    lv_state1                   CRMUSER.ACCOUNTS.state%TYPE;
    lv_country1                 CRMUSER.ACCOUNTS.country%TYPE;
    lv_asOfDate                 date :='';
    lv_nrc                      CRMUSER.ACCOUNTS.UNIQUEID%TYPE;
    lv_phnNo1			CRMUSER.PHONEEMAIL.phoneno%TYPE;
    lv_phnNo2			CRMUSER.PHONEEMAIL.phoneno%TYPE;
    lv_phnNo3			CRMUSER.PHONEEMAIL.phoneno%TYPE;
    lv_pos			number:='0';
    lv_embosName		CRMUSER.ACCOUNTS.PREFERREDNAME%TYPE;

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
    IF (NOT cifMod%ISOPEN)  THEN
    --{

        tbaadm.basp0099.formInputArr (inp_str,OutArr);

        iv_tranDate     := to_date(OutArr(0),'DD-MM-YYYY');
	lv_header	:=OutArr(1);
        dbms_output.put_line(iv_tranDate);
	dbms_output.put_line(lv_header);
    lv_asOfDate := iv_tranDate;


        OPEN cifMod(iv_tranDate);

    --}
    END IF;
    ------------------------------------------------------------------
    --Fetch the Cursor cifMod
    ------------------------------------------------------------------
        FETCH   cifMod
                INTO    lv_cifId,
			lv_foracid,
                        lv_cifName,
			lv_embosName,
                        lv_nrc,
                        lv_phone,
                        lv_email,
                        lv_address1,
                        lv_address2,
                        lv_address3,
                        lv_city,
                        lv_state,
                        lv_country,
                        lv_zip ;


	IF (cifMod%NOTFOUND)
	THEN
		CLOSE cifMod;

		out_retcode := 1;
		RETURN;
	END IF;

        BEGIN
        --{
                select REF_DESC into lv_city1 from tbaadm.rct where REF_REC_TYPE='01' and REF_CODE=lv_city;

                EXCEPTION when no_data_found then
                lv_city1        :='';
        --}
        END;

        BEGIN
        --{
                select REF_DESC into lv_state1 from tbaadm.rct where REF_REC_TYPE='02' and REF_CODE=lv_state;

                EXCEPTION when no_data_found then
                lv_state1        :='';
        --}
        END;

        BEGIN
        --{
                select REF_DESC into lv_country1 from tbaadm.rct where REF_REC_TYPE='03' and REF_CODE=lv_country;

                EXCEPTION when no_data_found then
                lv_country1        :='';
        --}
        END;
        BEGIN
        --{
                select email into lv_email1 from CRMUSER.PHONEEMAIL where PHONEOREMAIL='EMAIL' and PHONEEMAILTYPE='REGEML' and ORGKEY=lv_cifId;

                EXCEPTION when no_data_found then
                lv_email1        :='';
        --}
        END;
	--BEGIN
        --{
          --      select  substr(phoneno,phonee minus 1,'3'), substr(phoneno,'5','1'),substr(phoneno,'7'),phoneno into lv_phnNo1,lv_phnNo2,lv_phnNo3,lv_phoneno1 from CRMUSER.PHONEEMAIL where PHONEOREMAIL='PHONE' and PHONEEMAILTYPE='CELLPH' and ORGKEY=lv_cifId;

            --    EXCEPTION when no_data_found then
	--	lv_phnNo1	   :='';
	--	lv_phnNo2          :='';
	--	lv_phnNo3          :='';
        --        lv_phoneno1        :='';
        --}
        --END;
	--dbms_output.put_line(lv_phnNo1);
	--dbms_output.put_line(lv_phnNo2);
	--dbms_output.put_line(lv_phnNo3);
	--dbms_output.put_line(lv_phoneno1);
	--IF(lv_phnNo1 = '+95' or lv_phnNo1 = '+09')THEN
	--{
	--	lv_phoneno1 := lv_phnNo2||lv_phnNo3;
	--	dbms_output.put_line(lv_phoneno1);
	--}
	--END IF;
	BEGIN
        --{
		select INSTR(phoneno, ')', 1),phoneno into lv_pos,lv_phoneno1 from CRMUSER.PHONEEMAIL where PHONEOREMAIL='PHONE' and PHONEEMAILTYPE='CELLPH' and ORGKEY=lv_cifId;

		EXCEPTION when no_data_found then
		lv_pos	:='0';
		lv_phoneno1	:='';
	--}
	END;
	dbms_output.put_line(lv_pos);
	IF (lv_pos != '0')THEN
	--{
		BEGIN
        	--{
			select substr(phoneno,lv_pos-2,'2'),substr(phoneno,lv_pos+1) into lv_phnNo2,lv_phnNo3 from CRMUSER.PHONEEMAIL where PHONEOREMAIL='PHONE' and PHONEEMAILTYPE='CELLPH' and ORGKEY=lv_cifId;

			EXCEPTION when no_data_found then
			lv_phnNo2	:='';
			lv_phnNo3          :='';
		--}
		END;
		lv_phoneno1 := lv_phnNo2||lv_phnNo3;
		dbms_output.put_line(lv_phoneno1);
	--}
	END IF;
    ------------------------------------------------------------------
    --Output Generation
    ------------------------------------------------------------------
        IF(lv_header='Y')THEN
        --{
            dbms_output.put_line(lv_header);
            lv_header:='N';
            dbms_output.put_line(lv_header);

           out_rec:=   'CIF_ID'    ||'|'||
			'ACCOUNT_NO'  ||'|'||
                        'CIF_NAME'    ||'|'||
			'EMBOS_NAME'  ||'|'||
                        'NRC'         ||'|'||
                        'PHONE_NO'    ||'|'||
                        'EMAIL_ID'    ||'|'||
                        'ADDRESS1'    ||'|'||
                        'ADDRESS2'  ||'|'||
                        'ADDRESS3'  ||'|'||
                        'CITY'      ||'|'||
                        'STATE'     ||'|'||
                        'COUNTRY'   ||'|'||
                        'ZIP' ||CHR(10)
                        ||lv_cifId    ||'|'||
			lv_foracid    ||'|'||
                        lv_cifName    ||'|'||
			lv_embosName  ||'|'||
                        lv_nrc        ||'|'||
                        lv_phoneno1   ||'|'||
                        lv_email1     ||'|'||
                        lv_address1   ||'|'||
                        lv_address2   ||'|'||
                        lv_address3   ||'|'||
                        lv_city1      ||'|'||
                        lv_state1     ||'|'||
                        lv_country1   ||'|'||
                        lv_zip       ;

        --}
        ELSE
        --{

                    out_rec :=  lv_cifId    ||'|'||
				lv_foracid    ||'|'||
                                lv_cifName    ||'|'||
				lv_embosName  ||'|'||
                                lv_nrc        ||'|'||
                                lv_phoneno1     ||'|'||
                                lv_email1     ||'|'||
                                lv_address1  ||'|'||
                                lv_address2  ||'|'||
                                lv_address3  ||'|'||
                                lv_city1      ||'|'||
                                lv_state1     ||'|'||
                                lv_country1   ||'|'||
                                lv_zip       ;
                                RETURN;
        --}
        END IF;





--}
END cifModifiedProc;

END cifModifiedPack;
/
