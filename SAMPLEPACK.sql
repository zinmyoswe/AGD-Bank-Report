CREATE OR REPLACE PACKAGE        samplePack
AS
    PROCEDURE sampleProc 
    (
        inp_str        IN VARCHAR2,
        out_retcode    OUT NUMBER,
        out_rec        OUT VARCHAR2
    );

END samplePack;
 
/


CREATE OR REPLACE PACKAGE BODY                      samplePack
AS

    outarr            tbaadm.basp0099.arraytype;
    v_bank_id        tbaadm.gam.bank_id%TYPE;
    v_qStart        VARCHAR2(100);
    v_lEnd          VARCHAR2(100);
    v_Flag            VARCHAR2(1);
    v_msg            VARCHAR2(100);
    v_tran_date        VARCHAR2(100);
    v_sol_id        VARCHAR2(100);

PROCEDURE sampleProc
    (
        inp_str        IN VARCHAR2,
        out_retcode    OUT NUMBER,
        out_rec        OUT VARCHAR2
    )
    AS
    
    loc_outarr              tbaadm.basp0099.arraytype;
    out_acid        tbaadm.gam.acid%TYPE;
    out_foracid        tbaadm.gam.foracid%TYPE;
    out_start_date        VARCHAR2(100);
    out_end_date        VARCHAR2(100);
    out_lqb            VARCHAR2(100);
    out_div            VARCHAR2(100);

    BEGIN
        dbms_output.put_line('check 1');
        out_rec        :=      NULL;
        out_retcode    :=      0;    
        out_acid    :=    NULL;
        out_foracid    :=      NULL;
        out_lqb        :=    NULL;
            out_start_date    :=    NULL;
        out_end_date    :=    NULL;
        out_div        :=    NULL;

        
        -- Get the Foracid from Acid
        BEGIN
            dbms_output.put_line('check 4');
            SELECT FORACID INTO out_foracid 
            FROM TBAADM.GAM WHERE ACID = out_acid;
            EXCEPTION WHEN NO_DATA_FOUND THEN
            out_foracid := '';
        END;
            dbms_output.put_line('check 4a');
    
        IF (CCALQB%FOUND)
        THEN
            dbms_output.put_line('check 4b');
--           IF v_flag = 'S' THEN
            dbms_output.put_line('check 5');
            out_rec    := (out_foracid ||'|'|| out_lqb ||'|'|| out_start_date ||'|'|| out_end_date ||'|'|| out_div);
--           ELSE
            dbms_output.put_line('check 5a');
--            out_rec := (out_foracid ||'|'|| out_start_date ||'|'|| out_end_date ||'|'|| v_msg);
--           END IF;
        ELSE
            dbms_output.put_line('check 6');
            CLOSE CCALQB;
            out_retcode := 1;
            RETURN;    
        END IF;
    ELSE
        out_retcode := 1;
        RETURN;
    END IF;

    END sampleProc;
/
