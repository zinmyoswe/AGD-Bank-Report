CREATE OR REPLACE PACKAGE SUBLEDGERESSENTIAL AS 

  FUNCTION TODAYDOBAL(DOBALAMOUNT IN NUMBER) RETURN VARCHAR2;
FUNCTION CUSTOM_DOBAMOUNT(Part_Tran_Type	 IN VARCHAR2, TranAmt IN number  ) RETURN NUMBER;


END SUBLEDGERESSENTIAL;
/


CREATE OR REPLACE PACKAGE BODY        SUBLEDGERESSENTIAL AS

  FUNCTION TODAYDOBAL(DOBALAMOUNT IN NUMBER) RETURN VARCHAR2 AS
     PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
   
      update  custom.dobal
      set  balance = DOBALAMOUNT;
      commit;
   
       dbms_output.put_line('function');
  
    RETURN NULL;
  END TODAYDOBAL;

  FUNCTION CUSTOM_DOBAMOUNT(Part_Tran_Type	 IN VARCHAR2, TranAmt IN number  ) RETURN NUMBER AS
    v_DOBAL NUMBER(20,2) ;
       PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    
    select balance into v_DOBAL
     from CUSTOM.dobal;
   
    IF Part_Tran_Type = 'C' then
        v_DOBAL := v_DOBAL +  TranAmt;
    ELSE
        v_DOBAL := v_DOBAL -  TranAmt;
    END IF;
      
   -- dbms_output.put_line(Part_Tran_Type);
    -- dbms_output.put_line(TranAmt);
   update CUSTOM.dobal
   set    balance = v_DOBAL;
  commit;
  dbms_output.put_line(TranAmt);
    dbms_output.put_line(v_DOBAL);
  -- RETURN v_DOBAL; 
   
  

     RETURN v_DOBAL;
   
  END CUSTOM_DOBAMOUNT;

END SUBLEDGERESSENTIAL;
/
