#include <amxmodx>
#include <reapi>

new const MAX_ISYAN = 3;
new const SERVERISMI[] = "Kaos Gaming"
new const KISATAG[] = "KaoS"

enum _: eIsyan {
    mahkumID,
    gardiyanID
};

new Array: isyanlar;
new komutcuID = -1;
new oylamaAktif = false;
new adaylar[MAX_PLAYERS], adaySayi = 0;
new oylar[MAX_PLAYERS];
new isyanSayilari[MAX_CLIENTS + 1];

public plugin_init() {
	register_plugin("[JB] Aktif Komutcu Ve Isyan Sayaci", "1.0", "amad");
	register_clcmd("say /vk", "cmdMenu");
	register_clcmd("say !vk", "cmdMenu");
	register_clcmd("say .vk", "cmdMenu");

	register_clcmd("say /isyan", "getIsyanSayilari");

	RegisterHookChain(RG_CBasePlayer_Spawn, "onSpawn",1);
	RegisterHookChain(RG_RoundEnd, "roundEnd", 1);
	RegisterHookChain(RG_CBasePlayer_Killed, "onDeath", 1);
	register_event("HLTV", "roundStart", "a", "1=0", "2=0");

	isyanlar = ArrayCreate(eIsyan);
}

public plugin_natives() {
	register_native("get_user_isyan", "native_get_user_isyan");
	register_native("get_komutcu_id", "native_get_komutcu_id");
}

public native_get_komutcu_id() {
	return komutcuID;
}
public native_get_user_isyan(id) {
	if(id == komutcuID || komutcuID == -1  || get_member(id, m_iTeam) !=  2 || !is_user_connected(id)) 
		return -1;
	return isyanSayilari[id];
}

public client_putinserver(id) if(!is_user_bot(id)) remove_task(id),set_task( 1.0, "info", id, _, _, "b" );

public info(id) {
	static msg[512], pos, i;
	if(komutcuID != -1) {
		pos = 0;
		pos += formatex(msg[pos], 511-pos, "KMT - %s", getName(komutcuID));
		new players[MAX_PLAYERS], ct_num;
		static ids;
		get_players(players, ct_num, "ehi", "CT");

		for(i = 0; i < ct_num; i++) {
			ids = players[i];
			if(ids == komutcuID) continue;
			pos += formatex(msg[pos], 511 - pos, "^n%s - %d", getName(ids), isyanSayilari[ids]);
		}
		set_hudmessage(170, 170, 25, 0.02, 0.2, _, _, 4.0, _, _, -1);
		show_hudmessage(id ,"%s", msg);
	}
}

public cmdMenu(id) {
	
	if(!(get_user_flags(id) & ADMIN_VOTE)) {
		client_print_color(id, id, "^1[^3%s^1] Erisim ^4engellendi^1.", KISATAG);
		return;
	}
	static ndmenu[128];
	formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \yKomutcu Secim Menusu", SERVERISMI);
	new Menu = menu_create(ndmenu, "cmdMenuHandler");

	formatex(ndmenu, charsmax(ndmenu), "\w[\r%s\w] %sYeni Komutcu Oylamasi", KISATAG, !oylamaAktif || komutcuID != -1 ? "\y" : "\d");
	menu_additem(Menu, ndmenu, "1");

	formatex(ndmenu, charsmax(ndmenu), "\w[\r%s\w] %sOylamayi Iptal Et", KISATAG, oylamaAktif ? "\y" : "\d");
	menu_additem(Menu, ndmenu, "2");

	formatex(ndmenu, charsmax(ndmenu), "\w[\r%s\w] %sAktif Komutcuyu Iptal Et", KISATAG, (komutcuID != -1) ? "\y" : "\d");
	menu_additem(Menu, ndmenu, "3");

	menu_display(id, Menu, 0);
	
}

public cmdMenuHandler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED; 
	}
	new access,callback,data[6],iname[32]; 
	menu_item_getinfo(menu,item,access,data, charsmax(data), iname, charsmax(iname), callback);
	new key = str_to_num(data);
	switch(key) {
		case 1: {
			if(!oylamaAktif) {
				voteKomutcu(id);
			}
			else {
				client_print_color(id, id, "^1[^3%s^1] Zaten komutcu oylamasi ^4devam ediyor^1.", KISATAG);
				cmdMenu(id);
			}
		}
		case 2: {
			if(oylamaAktif) {
				oylamaAktif = false;
				log_amx("Komutcu oylamasi [%s] tarafindan iptal edildi.", getName(id));
				client_print_color(0, 0, "^1[^3%s^1] Komutcu oylamasi [^4%s] ^1tarafindan ^3iptal edildi^1.", KISATAG, getName(id));
			}
			else {
				client_print_color(id, id, "^1[^3%s^1] Aktif bir oylama ^4bulunmuyor^1.", KISATAG);
				cmdMenu(id);
			}
		}
		case 3: {
			if(komutcuID != -1) {
				log_amx("Aktif komutcu, [%s] tarafindan iptal edildi.", getName(id));
				client_print_color(0, 0, "^1[^3%s^1] <^4%s> ^1tarafindan aktif komutcu ^3iptal edildi^1.", KISATAG, getName(id));
				rg_set_user_team(komutcuID, 1);
				rg_round_respawn(komutcuID);
				komutcuID = -1;
			}
			else {
				client_print_color(id, id, "^1[^3%s^1] Aktif bir ^4komutcu bulunmuyor^1.", KISATAG);
				cmdMenu(id);
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED; 
}

public voteKomutcu(id) {

	if(!(get_user_flags(id) & ADMIN_VOTE)) client_print_color(id, id, "^1[^3%s^1] Erisim ^4engellendi^1.", KISATAG);
	else if(komutcuID != -1) client_print_color(id, id, "^1[^3%s^1] Zaten bir ^4komutcu bulunuyor^1.", KISATAG);
	else if(oylamaAktif) client_print_color(id, id, "^1[^3%s^1] Zaten komutcu oylamasi ^4devam ediyor^1.", KISATAG);
	else {
		new allPlayers[MAX_PLAYERS], ctPlyayers[MAX_PLAYERS], ct_num, num;
		get_players(allPlayers, num, "hi");
		get_players(ctPlyayers, ct_num, "ehi","CT");
		if(ct_num < 1) client_print_color(id, id, "^1[^3%s^1] CT'de kimse ^4YOK^1!", KISATAG);
		else if(ct_num == 1) yeniKomutcu(ctPlyayers[0]);
		else {
			oylamaAktif = true;
			for(new i = 0; i < num; i++)
				oylamamenu(allPlayers[i]);

			set_task(16.0, "oylamaBitir");
			client_print_color(0, 0, "^1[^3%s^1] Komutcu oylamasi [^4%s] ^1tarafindan ^3baslatildi^1.", KISATAG, getName(id));
			log_amx("Komutcu oylamasi [%s] tarafindan baslatildi", getName(id));
			client_print_color(0, 0, "^1[^3%s^1]^4 Komutcu secimi basladi.^3 15 saniye^4 sonra oylama bitecektir!", KISATAG);
		}
	}
}

public oylamamenu(id) {
	if(oylamaAktif) {
		static ndmenu[128], szTempid[10];
		formatex(ndmenu, charsmax(ndmenu),"\w%s \d|| \yKomutcu Oy Pusulasi^n\dOylama Suresi \r15 Saniye!", SERVERISMI);
		new Menu = menu_create(ndmenu, "oylamaMenuHandler");
		static ids;
		get_players(adaylar, adaySayi, "ehi","CT");

		for(new i = 0; i < adaySayi; i++) {
			ids = adaylar[i];
			oylar[ids] = 0;
			num_to_str(ids, szTempid, charsmax(szTempid));
			formatex(ndmenu, charsmax(ndmenu), "\y%s", getName(ids));
			menu_additem(Menu, ndmenu, szTempid);
		}
		menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Sayfa");
		menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Sayfa");
		menu_setprop(Menu, MPROP_EXITNAME, "\wBoykot Et");
		menu_display(id, Menu,0, 15);
	}
}
public oylamaMenuHandler(id, menu, item) {
	if(item == MENU_EXIT) {
		client_print_color(0, 0, "^3%s ^1: ^1Boykot ediyorum.", getName(id));
		menu_destroy(menu);
		return PLUGIN_HANDLED; 
	}
	else if(item == MENU_TIMEOUT) {
		client_print_color(id, id, "^1[^3%s^1] ^4Oy^1 verme suresi ^3doldu^1!", KISATAG);
		menu_destroy(menu);
		return PLUGIN_HANDLED; 
	}
	new access, callback, data[6], iname[32]; 
	menu_item_getinfo(menu,item,access,data, charsmax(data), iname, charsmax(iname), callback);
	new key = str_to_num(data);
	
	if(is_user_connected(key) && oylamaAktif) {
		client_print_color(0, 0, "^3%s ^1: Oyum sana > [^4%s^1]", getName(id), getName(key));
		oylar[key]++;
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public oylamaBitir() {

	if(!oylamaAktif) return;
	
	new max = -1, max2 = -2;
	new kazananID = -1;
	for(new i = 0; i < adaySayi; i++) {
		if(oylar[adaylar[i]] > max) {
			max = oylar[adaylar[i]];
			kazananID = adaylar[i];
		}
		else if(oylar[adaylar[i]] == max) max2 = max;
	}
	if(max > max2) { // kazanan belli
		client_print_color(0, 0, "^1[^3%s^1] Secimi kazanan [^3%s^1] - ^4%d ^1Oy", KISATAG, getName(kazananID), oylar[kazananID]);
		yeniKomutcu(kazananID);
	}
	else { //rasgele
		client_print_color(0, 0, "^1[^3%s^1] ^4Sonuçlar^1 eşit çıktı. ^3Rastgele^1 komutçu seçilecek...", KISATAG);
		set_task(3.0, "rastgeleKomutcu");
	}
}

public rastgeleKomutcu() {
	new kazananID = adaylar[random_num(0, adaySayi - 1)];
	client_print_color(0, 0, "^1[^3%s^1] ^4Secimi kazanan [%s] - %d Oy^1", KISATAG, getName(kazananID), oylar[kazananID]);
	yeniKomutcu(kazananID);
}

public yeniKomutcu(id) {
	new players[MAX_PLAYERS], ct_num;
	static ids;
	get_players(players, ct_num, "ehi", "CT");
	for(new i = 0; i < ct_num; i++) {
		ids = players[i];
		if(ids == id) continue;
		rg_set_user_team(ids, 1);
		rg_round_respawn(ids);
	}
	oylamaAktif = false;
	komutcuID = id;
	client_print_color(0, 0, "^1[^3%s^1] ^4Yeni Komutcu^1 : <^3%s^1>", KISATAG, getName(komutcuID));
	client_print_color(0, 0, "^1[^3%s^1] ^4Yeni Komutcu^1 : <^3%s^1>", KISATAG, getName(komutcuID));
}

public getIsyanSayilari(id) {

	if(komutcuID == -1) return; // eğer oylamayla kmtçu seçilmediyse devre dışı

	new players[MAX_PLAYERS], ct_num;
	static ids;
	get_players(players, ct_num, "ehi", "CT");

	for(new i = 0; i < ct_num; i++) {
		ids = players[i];
		if(ids == komutcuID) continue;
		client_print_color(id, id, "^1[^3%s^1] <^4%s^1> isyan : %d", KISATAG, getName(ids), isyanSayilari[ids]);
	}
}

public plugin_end() ArrayDestroy(isyanlar);

public roundEnd() ArrayClear(isyanlar);

public roundStart() {
	ArrayClear(isyanlar);
	
	if(komutcuID == -1) return;

	new players[MAX_PLAYERS], ct_num;
	static ids;
	get_players(players, ct_num, "ehi", "CT");
	for(new i = 0; i < ct_num; i++) {
		ids = players[i];
		if(ids == komutcuID) continue;
		if(isyanSayilari[ids] == MAX_ISYAN) {
			client_print_color(0, 0, "^1[^3%s^1] <^4%s^1> adli oyuncunun ^3isyan hakkı^1 doldu.", KISATAG, getName(ids));
			set_member(ids, m_iTeam, 1);
		}
	}
}
public client_disconnected(id) {

	new isyan[eIsyan], players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi", "TERRORIST");

	if(get_member(id, m_iTeam) == 1) {
		for(new i = 0; i < ArraySize(isyanlar); i++) {
			ArrayGetArray(isyanlar, i, isyan);
			if(isyan[mahkumID] == id) {
				if(!is_user_alive(isyan[gardiyanID]) && is_user_connected(isyan[gardiyanID]) && get_member(isyan[gardiyanID], m_iTeam) == 2) {
					if(te_num >= 1) {
						client_print_color(0, 0, "^1[^3%s^1] <^4%s^1> oyundan çıktığından dolayi ^1 <^4%s^1> adlı ^3gardiyani^1 revlendi.", KISATAG, getName(id), getName(isyan[gardiyanID]));
						rg_round_respawn(isyan[gardiyanID]);
					}
					if(isyan[gardiyanID] != komutcuID && komutcuID != -1) isyanSayilari[isyan[gardiyanID]]--;
				}
				ArrayDeleteItem(isyanlar, i--);
			}
		}
	}
	if(komutcuID == id) komutcuID = -1;
}

public onSpawn(id) {
	if(get_member(id, m_iTeam) == 1) {
		isyanSayilari[id] = 0;
		if(komutcuID == id) komutcuID = -1;
	}
}

public onDeath(olen, olduren) {
	new isyan[eIsyan], players[MAX_PLAYERS], te_num, ct_num;
	get_players(players, te_num, "aehi", "TERRORIST");
	get_players(players, ct_num, "aehi", "CT");

	if(get_member(olduren, m_iTeam) == 1 && get_member(olen, m_iTeam) == 2) {
		if(ct_num >= 1 && te_num > 1) {
			isyan[mahkumID] = olduren;
			isyan[gardiyanID] = olen;
			ArrayPushArray(isyanlar, isyan);
			client_print_color(0, 0, "^1[^3%s^1] <^4%s^1> adlı ^3isyancı^1 <^4%s^1> adlı ^3gardiyanı^1 öldürdü.", KISATAG, getName(olduren), getName(olen));
		}
		if(olen != komutcuID && komutcuID != -1) isyanSayilari[olen]++;
	}
	else if(get_member(olen, m_iTeam) == 1) {
		for(new i = 0; i < ArraySize(isyanlar); i++) {
			ArrayGetArray(isyanlar, i, isyan);
			if(isyan[mahkumID] == olen) {
				if(!is_user_alive(isyan[gardiyanID]) && is_user_connected(isyan[gardiyanID]) && get_member(isyan[gardiyanID], m_iTeam) == 2) {
					if(isyan[gardiyanID] != komutcuID && komutcuID != -1) isyanSayilari[isyan[gardiyanID]]--;
					if(te_num >= 1) {
						client_print_color(0, 0, "^1[^3%s^1] <^4%s^1> adlı ^3isyanci^1 öldüğü için <^4%s^1> yeniden doğdu.", KISATAG, getName(olen), getName(isyan[gardiyanID]));
						rg_round_respawn(isyan[gardiyanID]);
					}
				}
				ArrayDeleteItem(isyanlar, i--);
			}
		}
	}
}
public getName(id) {
	new isim[32];
	get_entvar(id, var_netname, isim, charsmax(isim));
	return isim;
}

/* Native Örnek */
/*

native get_user_isyan(id); // parametre olan girilen kişinin isyan sayısını döndürür. Ct değilse veya yoksa -1
native get_komutcu_id(); // aktif komutçunun id'sini döndürür. Yoksa -1

public komutcu(id) {
	new name[32];
	get_user_name(get_komutcu_id(), name, 31)
	client_print(id, print_chat, "komutcu : %s", name);
}

public isyan(id) {
	new players[32], num, name[32];
	get_players(players, num, "ehi", "CT");
	for(new i = 0; i < num; i++) {
		if(get_user_isyan(players[i]) != -1) {
			get_user_name(players[i], name, 31);
			client_print(id, print_chat, "%s - : %d", name, get_user_isyan(players[i]));
		}
	}
}

*/