CREATE OR REPLACE PACKAGE               AGDCommonPack AS
FUNCTION GetEffAvailAmt(lv_foracid IN varchar2) RETURN NUMBER;
FUNCTION GetEffAvailAmtPool(lv_foracid IN varchar2) RETURN NUMBER;
END AGDCommonPack;
/


CREATE OR REPLACE PACKAGE BODY AGDCommonPack AS

Cursor getAccounts(lv_poolId tbaadm.gam.pool_id%type) IS
	Select foracid from tbaadm.gam where pool_id = lv_poolId;

FUNCTION GetEffAvailAmt (lv_foracid varchar2) RETURN NUMBER IS
	lv_clr_bal_amt			tbaadm.gam.clr_bal_amt%type;
	lv_lien_amt			tbaadm.gam.lien_amt%type;
	lv_system_reserved_amt		tbaadm.gam.system_reserved_amt%type;

	lv_eff_avail_amt                tbaadm.gam.clr_bal_amt%type;
	lv_tot_clean_lim		tbaadm.gam.clr_bal_amt%type;
	lv_shadow_bal_to_add		tbaadm.gam.clr_bal_amt%type;
	lv_tot_secured_lim		tbaadm.gam.clr_bal_amt%type;
	lv_eff_drawing_power		tbaadm.gam.clr_bal_amt%type;
	lv_loc_system_gen_lim		tbaadm.gam.clr_bal_amt%type;

	lv_clean_adhoc_lim		tbaadm.gam.clean_adhoc_lim%type;
	lv_clean_emer_advn		tbaadm.gam.clean_emer_advn%type;
	lv_clean_single_tran_lim	tbaadm.gam.clean_single_tran_lim%type;
	lv_used_clean_single_tran_lim	tbaadm.gam.used_clean_single_tran_lim%type;
	lv_used_oc_cln_single_tran_lim	tbaadm.gam.used_oc_cln_single_tran_lim%type;

	lv_dacc_lim			tbaadm.gam.dacc_lim%type;

	lv_sanct_lim			tbaadm.gam.sanct_lim%type;
	lv_adhoc_lim			tbaadm.gam.adhoc_lim%type;
	lv_emer_advn			tbaadm.gam.emer_advn%type;
	lv_single_tran_lim		tbaadm.gam.single_tran_lim%type;
	lv_used_single_tran_lim		tbaadm.gam.used_single_tran_lim%type;

	lv_drwng_power			tbaadm.gam.drwng_power%type;

	lv_system_gen_lim		tbaadm.gam.system_gen_lim%type;
	lv_used_un_clr_over_dacc_amt 	tbaadm.gam.used_un_clr_over_dacc_amt%type;
BEGIN
	lv_eff_avail_amt := 0;

	select clr_bal_amt, lien_amt, system_reserved_amt, clean_adhoc_lim, clean_emer_advn,
		clean_single_tran_lim, used_clean_single_tran_lim, dacc_lim, sanct_lim, adhoc_lim,
		emer_advn, single_tran_lim, used_single_tran_lim, drwng_power, system_gen_lim,
		used_un_clr_over_dacc_amt, used_oc_cln_single_tran_lim
	into
	lv_clr_bal_amt, lv_lien_amt, lv_system_reserved_amt, lv_clean_adhoc_lim, lv_clean_emer_advn,
		lv_clean_single_tran_lim, lv_used_clean_single_tran_lim, lv_dacc_lim, lv_sanct_lim,
		lv_adhoc_lim, lv_emer_advn, lv_single_tran_lim, lv_used_single_tran_lim, lv_drwng_power,
		lv_system_gen_lim, lv_used_un_clr_over_dacc_amt, lv_used_oc_cln_single_tran_lim
	from
	tbaadm.gam where foracid = lv_foracid;


	lv_tot_clean_lim := lv_clean_adhoc_lim + lv_clean_emer_advn + lv_clean_single_tran_lim;
	lv_tot_clean_lim := lv_tot_clean_lim + lv_used_clean_single_tran_lim;
	lv_tot_clean_lim := lv_tot_clean_lim + lv_used_oc_cln_single_tran_lim;

	lv_shadow_bal_to_add  := lv_dacc_lim;

	lv_tot_secured_lim := lv_sanct_lim + lv_adhoc_lim + lv_emer_advn + lv_single_tran_lim;
	lv_tot_secured_lim := lv_tot_secured_lim + lv_used_single_tran_lim;

	lv_loc_system_gen_lim := lv_system_gen_lim + lv_used_un_clr_over_dacc_amt ;

	IF (lv_tot_secured_lim > lv_drwng_power) then
                lv_eff_drawing_power := lv_drwng_power;
        ELSE
                lv_eff_drawing_power := lv_tot_secured_lim;
        END IF;

	lv_eff_avail_amt := lv_eff_drawing_power + lv_tot_clean_lim + lv_loc_system_gen_lim;
	lv_eff_avail_amt := lv_eff_avail_amt + lv_clr_bal_amt + lv_shadow_bal_to_add;
	lv_eff_avail_amt := lv_eff_avail_amt - lv_lien_amt - lv_system_reserved_amt;

        RETURN lv_eff_avail_amt;

END GetEffAvailAmt;

FUNCTION GetEffAvailAmtPool (lv_foracid varchar2) RETURN NUMBER IS
	lv_eff_avail_amt	tbaadm.gam.clr_bal_amt%type;
	lv_eff_avl_bal_acc	tbaadm.gam.clr_bal_amt%type;
	lv_pool_id		tbaadm.gam.pool_id%type;
	in_foracid 		tbaadm.gam.foracid%type;
BEGIN
	lv_eff_avail_amt := 0;

	select NVL(pool_id,'0') into lv_pool_id
	from tbaadm.gam
	where foracid = lv_foracid;

	If (lv_pool_id = '0') then
		lv_eff_avail_amt := GetEffAvailAmt(lv_foracid);
	Else
		lv_eff_avl_bal_acc := 0;
		IF(NOT getAccounts%ISOPEN)  THEN
		--{
			open getAccounts(lv_pool_id);
		--}
		END IF;
		Loop
			Fetch getAccounts into in_foracid;
			Exit when getAccounts%NOTFOUND;

			lv_eff_avl_bal_acc := GetEffAvailAmt (in_foracid);
			lv_eff_avail_amt := lv_eff_avail_amt + lv_eff_avl_bal_acc;
		End Loop;
		close getAccounts;
	End If;
	RETURN lv_eff_avail_amt;

END GetEffAvailAmtPool;


END AGDCommonPack;
/
