CREATE OR REPLACE PACKAGE  FIN_BANK_STATEMENT_NEW AS 

     
   PROCEDURE FIN_BANK_STATEMENT_NEW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 );

END FIN_BANK_STATEMENT_NEW;
/


CREATE OR REPLACE PACKAGE BODY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   FIN_BANK_STATEMENT_NEW AS

-------------------------------------------------------------------------------------
	-- Cursor declaration
	-- This cursor will fetch all the data based on the main query
-------------------------------------------------------------------------------------
  --3021210106578
  outArr			tbaadm.basp0099.ArrayType;  -- Input Parse Array

	vi_startDate		Varchar2(10);		    	    -- Input to procedure
  vi_endDate		  Varchar2(10);		    	    -- Input to procedure
  vi_AccountNo		Varchar2(20);		    	    -- Input to procedure
 
  num number;
  dobal Number := 0;		    	  
  --result_rec Varchar2(30000);
  OpeningAmount Number := 0;
  OpenDate		Varchar2(10);		    	
  limitsize  INTEGER := 400;
  v_schm_type Varchar2(10);	
  v_schm_code Varchar2(10);	
  v_joint_nrc Varchar2(50);	
  v_joint_name Varchar2(30);
  v_joint_cif Varchar2(30);
  v_type Varchar2(10);	
  v_acid  Varchar2(10);
-----------------------------------------------------------------------------
-- CURSOR declaration FIN_DRAWING_SPBX CURSOR
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CURSOR ExtractData
-----------------------------------------------------------------------------
CURSOR ExtractData (ci_startDate VARCHAR2, ci_endDate VARCHAR2, ci_AccountNo VARCHAR2)  IS
select 
  cdav.value_date ,
  cdav.tran_amt,
  cdav.tran_type,
  cdav.part_tran_type,
  cdav.tran_particular,
  cdav.instrmnt_num
  --gam.sol_id
from 
  tbaadm.general_acct_mast_table gam,TBAADM.CTD_DTD_ACLI_VIEW cdav
where 
  gam.acid = cdav.acid
  And Gam.Foracid = Ci_Accountno
  --and cdav.value_date between TO_DATE( CAST ( ci_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
 -- and TO_DATE( CAST ( ci_endDate AS VARCHAR(10) ) , 'dd-MM-yyyy' )
  And ((Cdav.Value_Date Between To_Date( Cast ( ci_startDate As Varchar(10) ) , 'dd-MM-yyyy' ) 
    And To_Date( Cast ( ci_endDate As Varchar(10) ) , 'dd-MM-yyyy' ))Or((Cdav.Tran_Date Between To_Date( Cast ( ci_startDate As Varchar(10) ) , 'dd-MM-yyyy' ) 
      And To_Date( Cast ( ci_endDate As Varchar(10) ) , 'dd-MM-yyyy' ))))
  and gam.del_flg != 'Y'
--  and gam.acct_cls_flg != 'Y'
  and gam.SCHM_TYPE  NOT in ('OAB','OAP','DDA')
  and gam.bank_id ='01'
  and cdav.pstd_date is not null
  and (trim (cdav.tran_id),trim(cdav.part_tran_srl_num),cdav.tran_date) NOT IN (select trim(atd.cont_tran_id), trim(atd.cont_part_tran_srl_num),atd.cont_tran_date
                                                                                from TBAADM.ATD atd
                                                                                where atd.cont_tran_date >= TO_DATE( CAST ( ci_startDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' )
                                                                                and atd.cont_tran_date <= TO_DATE( CAST ( ci_endDate  AS VARCHAR(10) ) , 'dd-MM-yyyy' ) )--Without Reversal
  order by cdav.value_date,cdav.rcre_time,cdav.tran_id,cdav.TRAN_PARTICULAR;
  
CURSOR ExtractDataForResult IS
select  tran_date,dobal,tran_amt,tran_type,part_tran_type,tran_particular,instrmnt_num from custom.TEMP_TABLE_BANKSTAT order by ID;
  
   TYPE mainretailtable IS TABLE OF ExtractData%ROWTYPE INDEX BY BINARY_INTEGER;
   ptmainretailtable         mainretailtable;
 
   -------------------------
  PROCEDURE FIN_BANK_STATEMENT_NEW(	inp_str      IN  VARCHAR2,
			out_retCode  OUT NUMBER,
			out_rec      OUT VARCHAR2 ) AS     
 
    v_tran_date CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_date%type;
    v_tran_amt CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_amt%type;
    v_tran_type CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_type%type;
    v_part_tran_type CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.part_tran_type%type; 
    v_tran_particular CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.tran_particular%type;
    v_AccountNumber TBAADM.GENERAL_ACCT_MAST_TABLE.FORACID%type;
    v_AccountName varchar2(200);
    v_Cur TBAADM.GENERAL_ACCT_MAST_TABLE.ACCT_crncy_code%type;
    v_Address varchar2(1000);
    v_Nrc CRMUSER.ACCOUNTS.UNIQUEID%type;
    v_Bal TBAADM.GENERAL_ACCT_MAST_TABLE.clr_bal_amt%type;
    v_PhoneNumber crmuser.phoneemail.phoneno%type;
    v_FaxNumber CRMUSER.address.faxno%type;
    v_BranchName tbaadm.sol.sol_desc%type;
    v_BankAddress varchar(200);
    v_instrmnt_num CUSTOM.CUSTOM_CTD_DTD_ACLI_VIEW.instrmnt_num%type;
    
    v_BankPhone VARCHAR(50);
    v_BankFax VARCHAR(50);
    v_WithdrawCount number :=0;
    v_DepositCount number :=0;
    v_SanctionLimit TBAADM.GENERAL_ACCT_MAST_TABLE.SANCT_LIM%type;
    v_ExpiredDate  TBAADM.LA_ACCT_MAST_TABLE.EI_PERD_END_DATE%type;
    
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
    
    vi_startDate  :=  outArr(0);		
    vi_endDate    :=  outArr(1);		
    vi_AccountNo	:=  outArr(2);
   
--------------------------------------------------------------------------------------------
if( vi_startDate is null or vi_endDate is null or vi_AccountNo is null ) then
        --resultstr := 'No Data For Report';
        out_rec:= ( '-' || '|' || 0 || '|' || '-' || '|' || '-' || '|' || '-' || '|' ||
            		0 || '|' || '-' || '|' ||'-' || '|' || '-' || '|' || '-' || '|' || 
					'-' || '|' || '-' || '|' || '-' || '|' ||'-'|| '|' || '-' || '|' ||
					'-'|| '|' || '-'|| '|' || 0 || '|' || 0 || '|' || '-' || '|' || '-');
        --dbms_output.put_line(out_rec);
        out_retCode:= 1;
        RETURN;        
  end if;

----------------------------------------------------------------------------
   
    
    IF NOT ExtractData%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractData (vi_startDate , vi_endDate, vi_AccountNo);
			--}
			END;

		--}
		END IF;
    
    IF ExtractData%ISOPEN Then
		--{
    Begin   
    
   select  tran_date_bal,eod_date INTO OpeningAmount,OpenDate
   from tbaadm.eab,tbaadm.general_acct_mast_table gam
   where gam.acid = tbaadm.eab.acid
   and gam.SCHM_TYPE  NOT in ('OAB','OAP','DDA')
   and eod_date = ( select  eod_date   from(
        select eod_date
        from tbaadm.eab ,tbaadm.general_acct_mast_table gam
        where tbaadm.eab.eod_date < TO_DATE( CAST ( vi_startDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ) 
        and gam.acid = tbaadm.eab.acid
        and gam.foracid = vi_AccountNo
        order by eod_date desc)
        where rownum =1)
   and gam.foracid = vi_AccountNo;    
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OpeningAmount := 0.00;  
   end;
   
      delete from custom.TEMP_TABLE_BANKSTAT ; commit;        
      dobal := OpeningAmount;
      insert into custom.TEMP_TABLE_BANKSTAT(Tran_Date,DOBAL,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID,INSTRMNT_NUM) 
      values(TO_DATE( CAST ( OpenDate AS VARCHAR(10) ) , 'dd-MM-yyyy' ),dobal,v_tran_amt,v_tran_type,'Opening Balance',v_part_tran_type,0,v_instrmnt_num);
      commit;
        
      Fetch	Extractdata	Bulk Collect Into Ptmainretailtable;-- LIMIT limitsize;     --outer Cursor  
      
      FOR outindx IN 1 .. ptmainretailtable.COUNT            --outer For loop
      Loop  
       -- dbms_output.put_line('before dobal :' + ptmainretailtable.COUNT  );
        if ptmainretailtable (outindx).part_tran_type = 'C' then
          dobal := dobal + ptmainretailtable(outindx).tran_amt;
        else if ptmainretailtable(outindx).part_tran_type = 'D' then
          dobal := dobal - ptmainretailtable(outindx).tran_amt;
        end if;
        end if;
        v_tran_date := ptmainretailtable (outindx).value_date;
        if ptmainretailtable (outindx).tran_amt > 0 and ptmainretailtable (outindx).part_tran_type = 'C' then
          v_DepositCount := v_DepositCount + 1;
        end if;
        if ptmainretailtable (outindx).tran_amt > 0 and ptmainretailtable (outindx).part_tran_type = 'D' then
          v_WithdrawCount := v_WithdrawCount + 1;
        end if;
        v_tran_amt := ptmainretailtable (outindx).tran_amt;
        v_tran_type := ptmainretailtable (outindx).tran_type;
        v_part_tran_type := ptmainretailtable (outindx).part_tran_type;
        v_tran_particular := ptmainretailtable (outindx).tran_particular;
        --result_rec := result_rec ||'|'|| dobal ||'|'|| to_char(to_date(v_tran_date,'dd/Mon/yy'), 'dd/MM/yyyy')||'|' ||
                 --    v_tran_amt 	|| '|' || v_tran_type 	|| '|' || v_part_tran_type 	|| '|' || v_tran_particular ;
      v_instrmnt_num :=  ptmainretailtable (outindx).instrmnt_num;
        insert into custom.TEMP_TABLE_BANKSTAT(Tran_Date,DOBAL,TRAN_AMT,TRAN_TYPE,TRAN_PARTICULAR,PART_TRAN_TYPE,ID,INSTRMNT_NUM) values(v_tran_date,dobal,v_tran_amt,v_tran_type,v_tran_particular,v_part_tran_type,outindx,v_instrmnt_num);
        commit;
                           
      END LOOP;
			------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractData%NOTFOUND THEN
			--{
				CLOSE ExtractData;
				--out_retCode:= 1;
				--RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    
    
    
    IF NOT ExtractDataForResult%ISOPEN THEN
		--{
			BEGIN
			--{
				OPEN ExtractDataForResult ;
			--}
			END;

		--}
		END IF;
    IF ExtractDataForResult%ISOPEN Then
   
     -- dobal := dobal + OpeningAmount;
      FETCH	ExtractDataForResult INTO	 v_tran_date,dobal,v_tran_amt,v_tran_type,v_part_tran_type,v_tran_particular,v_instrmnt_num;
     	------------------------------------------------------------------
			-- Here it is checked whether the cursor has fetched
			-- something or not if not the cursor is closed
			-- and the out ret code is made equal to 1
			------------------------------------------------------------------
      IF ExtractDataForResult%NOTFOUND THEN
			--{
				CLOSE ExtractDataForResult;
				out_retCode:= 1;
				RETURN;
			--}
			END IF;   
      
		--}
    END IF;
    
    
   
     BEGIN
-------------------------------------------------------------------------------
    -- GET BANK INFORMATION
-------------------------------------------------------------------------------
begin
SELECT sol.sol_desc,sol.addr_1 || sol.addr_2 || sol.addr_3,bct.PHONE_NUM, bct.FAX_NUM
   into    v_BranchName, v_BankAddress, v_BankPhone, v_BankFax
   FROM tbaadm.sol,tbaadm.bct 
   WHERE sol.SOL_ID = ( SELECT SOL_ID FROM TBAADM.GAM WHERE FORACID = vi_AccountNo) AND bct.br_code = sol.br_code
   and bct.bank_code = '116';
end;
   
 begin        
  select 
  general_acct_mast_table.foracid as "AccountNumber",
  LISTAGG(aas.acct_poa_as_name, ',') WITHIN GROUP (ORDER BY aas.acct_poa_as_srl_num)as "AcountName",
  general_acct_mast_table.acct_crncy_code as "Currency"
  into   v_AccountNumber,v_AccountName,v_Cur
  from 
  tbaadm.general_acct_mast_table general_acct_mast_table,TBAADM.aas aas 
  where 
  general_acct_mast_table.foracid = vi_AccountNo
  and general_acct_mast_table.del_flg != 'Y'
  and general_acct_mast_table.acid = aas.acid
  and general_acct_mast_table.bank_id ='01'  
  group by  general_acct_mast_table.foracid,general_acct_mast_table.acct_crncy_code;
  
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_AccountNumber := '-';
        v_AccountName := '-';
        v_Cur := '-';
       
end;

begin        
  select 
  address.address_line1 ||'/'|| address.address_line2 || address.address_line3 || address.city || address.state || address.country as "Address",
  address.faxnolocalcode||address.faxnocountrycode||address.faxnocitycode||address.faxno as "FaxNumber"
  into v_Address, v_FaxNumber
  from 
  tbaadm.general_acct_mast_table general_acct_mast_table,
  CRMUSER.address address
  where 
  general_acct_mast_table.foracid = vi_AccountNo
  and general_acct_mast_table.del_flg != 'Y'
  --and general_acct_mast_table.acct_cls_flg != 'Y'
  and general_acct_mast_table.bank_id ='01'
  and general_acct_mast_table.cif_id     = address.orgkey and address.addresscategory='Mailing'
  order by general_acct_mast_table.acct_opn_date desc;
  
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_Address := '-';
        v_FaxNumber := '-';
end;

begin
  select 
  pe.phoneno as "PhoneNumber"
  into    v_PhoneNumber
  from 
  tbaadm.general_acct_mast_table general_acct_mast_table,
  crmuser.phoneemail pe
  where 
  general_acct_mast_table.foracid = vi_AccountNo
  and general_acct_mast_table.del_flg != 'Y'
  and general_acct_mast_table.acct_cls_flg != 'Y'
  and general_acct_mast_table.bank_id ='01'
  and pe.orgkey = general_acct_mast_table.cif_id
  and rownum = 1
  order by general_acct_mast_table.acct_opn_date desc;
  
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_PhoneNumber := '-';
end;

 begin 
  select ACCOUNTS.uniqueid as "NRC" into   v_Nrc
  from tbaadm.general_acct_mast_table general_acct_mast_table,
  CRMUSER.ACCOUNTS ACCOUNTS
  where 
  general_acct_mast_table.foracid = vi_AccountNo
  and general_acct_mast_table.del_flg != 'Y'
  and general_acct_mast_table.acct_cls_flg != 'Y'
  and general_acct_mast_table.bank_id ='01'
  and general_acct_mast_table.cif_id     = ACCOUNTS.orgkey
  and rownum = 1
  order by general_acct_mast_table.acct_opn_date desc;
  
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_Nrc := '-';
end;

begin

  select 
   gam.SANCT_LIM as "SanctionLimit"
   into v_SanctionLimit
  from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam
  where
   gam.DEL_FLG = 'N' 
   and gam.ACCT_CLS_FLG = 'N' 
   and gam.bank_id = '01'
   and gam.foracid = vi_AccountNo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_SanctionLimit := null;
end;

begin 

select schm_type,schm_code into v_schm_type,v_schm_code from tbaadm.gam where gam.DEL_FLG = 'N' 
and gam.ACCT_CLS_FLG = 'N' and gam.bank_id = '01' and gam.foracid = vi_AccountNo;

if v_schm_type = 'LAA' then
  select   
   lam.EI_PERD_END_DATE as "ExpiredDate"
   into v_ExpiredDate
  from 
   TBAADM.GENERAL_ACCT_MAST_TABLE gam ,TBAADM.LA_ACCT_MAST_TABLE lam
  where
   gam.DEL_FLG = 'N' 
   and lam.acid = gam.acid   
   and gam.ACCT_CLS_FLG = 'N' 
   and gam.bank_id = '01'
   and gam.foracid = vi_AccountNo;
   
 else if v_schm_type = 'ODA' or v_schm_code = 'AGDOD' then
      Select  Lim_Exp_Date  Into V_Expireddate From (Select   
     max(lht.LIM_EXP_DATE) as   Lim_Exp_Date    
      from 
      TBAADM.gam gam ,TBAADM.lht lht
      where
      gam.DEL_FLG = 'N' 
      and lht.acid = gam.acid   
      and gam.ACCT_CLS_FLG = 'N' 
      and gam.bank_id = '01'
      And Gam.Foracid = Vi_Accountno
      and lht.Serial_Num In (Select Max(lht1.Serial_Num) From 
                            TBAADM.gam gam1 ,TBAADM.lht lht1
                            Where
                            Gam1.Del_Flg = 'N' 
                            And Lht1.Acid = Gam1.Acid   
                            And Gam1.Acct_Cls_Flg = 'N' 
                            And Gam1.Foracid = Vi_Accountno
                            And Gam1.Bank_Id = '01')
      order by lht.rcre_time desc)
      where rownum = 1;
      
      --3240011000091018
      
      --select * from tbaadm.lht order by lht.rcre_time desc;
      
   end if;   
   end if; 
   
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ExpiredDate := null;
  -- delete from custom.TEMP_TABLE_BANKSTAT ; commit;  
end;
END;

 /*begin
 v_joint_name := null;
  v_joint_cif := null;
 select mode_of_oper_code,acid into v_type,v_acid  from tbaadm.gam where foracid = vi_AccountNo;
 if v_type is not null or v_type <> '' then
 if v_type = 'JOINT' or v_type like 'ANYJ%' then
  select acct_poa_as_name, nma_key_id into v_joint_name,v_joint_cif from tbaadm.aas where acid = v_acid 
  and acct_poa_as_rec_type = 'J' and rownum =1;
  select uniqueid into v_joint_nrc from crmuser.accounts where ACCOUNTS.orgkey  = v_joint_cif;
 
 end if;
 end if;
 EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_type := null; 
        v_acid := null; 
        v_joint_name := null; 
        v_joint_nrc := null; 
end;
*/
    -----------------------------------------------------------------------------------
    -- out_rec variable retrieves the data to be sent to LST file with pipe seperation
    ------------------------------------------------------------------------------------
    out_rec:=	(to_char(to_date(v_tran_date,'dd/Mon/yy'), 'dd/MM/yyyy')||'|' ||
          v_tran_amt 	|| '|' || 
          v_tran_type 	|| '|' || 
          v_part_tran_type 	|| '|' || 
          v_tran_particular || '|' || 
          dobal ||'|'|| 
          v_AccountNumber || '|' ||
					v_AccountName --|| ', ' || --v_joint_name	
          || '|' ||
          v_Cur ||'|'||
					v_Address || '|' ||
          v_Nrc   --	|| ', ' ||-- v_joint_nrc	
          || '|' ||
          v_PhoneNumber || '|' ||
          v_FaxNumber    			|| '|' ||
					v_BranchName	|| '|' ||
					v_BankAddress      			|| '|' ||
					v_BankPhone || '|' ||
          v_BankFax ||'|'||
          v_DepositCount ||'|'||
          v_WithdrawCount ||'|'||
          v_SanctionLimit ||'|'|| 
          to_char(to_date(v_ExpiredDate,'dd/Mon/yy'), 'dd Mon,yyyy')||'|'|| 
          v_instrmnt_num);
  
			dbms_output.put_line(out_rec);
 
    
  END FIN_BANK_STATEMENT_NEW;

END FIN_BANK_STATEMENT_NEW;
/
