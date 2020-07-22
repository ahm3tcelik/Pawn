#include <amxmodx>
#include <reapi>
#include <engine>
#include <fun>
#include <fakemeta>

#define TEMP_MSG	16
#define TEMP_MSG2	1936

#define SERVERISMI "KaoSCommunity.com"
#define tag "KaoS"

native otoKomutAktif();
native otoKomutRevle(id);

enum MapBilgileri {
    mapName[32],
    origin1[3],
    origin2[3]
};

new const  maps[][MapBilgileri] = {
	{"jail_buyukisyan_dark", {-1336, 720, -155}, {-1681, 1308, -155}},
	{"jail_buyukisyan_v8", {-1405, -181, -155}, {-1816, 447, -155}},
	{"jail_oyunhavuzu", {-176, -1362, 36}, {629, -1311, 36}},
	{"some1s_jailbreak", {-1338, -782, 38}, {-1352, 271, 38}}
};

enum {
	DUEL_AWP,
	DUEL_SCOUT,
	DUEL_DEAGLE,
	DUEL_USP,
	DUEL_AUG,
	DUEL_AK47,
	DUEL_M4A1,
	DUEL_MP5
};

enum DuelloInf {
	dName[7],
	weaponName[15],
	bool: duel[MAX_CLIENTS + 1]
};

new duels[][DuelloInf] = {
	{"AWP", "weapon_awp"},
	{"SCOUT", "weapon_scout"},
	{"DEAGLE", "weapon_deagle"},
	{"USP", "weapon_usp"},
	{"AUG", "weapon_aug"},
	{"AK47", "weapon_ak47"},
	{"M4A1", "weapon_m4a1"},
	{"MP5", "weapon_mp5navy"}
};

new const muzik[] = "misc/kaos_lr_new.wav";

new duelzaman,g_maxPlayers,g_msgsync,ct,te;
new bool:touch_weapons[MAX_CLIENTS + 1], bool:once[MAX_CLIENTS + 1], bool:player_challenged[33], mapname[32];
new bool:duel_active, aktifDuello, bool:g_muzik;
new fwPreThink, mp_freeforall, bh_enabled, mp_infinite_ammo, cvars[16], beam, g_gerisayim, Float: iAngles[MAX_CLIENTS + 1][3];

const TASK_ID = 1603;
const DAIRE_TASKID = 3051;
const GERSAYIM_ID = 1952;

public plugin_precache() {	
	precache_sound("weapons/zoom.wav");
	beam = precache_model("sprites/laserbeam.spr")
	precache_sound(muzik);
	precache_sound("weapons/headshot2.wav");
}

public plugin_init() {

	register_plugin("[JB] Lr (Oto Komut Destekli)", "4.0", "amad");

	register_clcmd("say /lr", "duel_menu");
	register_clcmd("say !lr", "duel_menu");
	register_clcmd("say .lr", "duel_menu");
	register_clcmd("say /vs", "duel_menu");
	register_clcmd("say !vs", "duel_menu");
	register_clcmd("say .vs", "duel_menu");
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0"); 

	register_message(get_user_msgid("AmmoX"), "Message_AmmoX"); // DEAGLE SHOT FIX
	
	register_touch("weaponbox", "player", "onTouchWeapon");
	register_touch("armoury_entity", "player", "onTouchWeapon");
	register_touch("weapon_shield", "player", "onTouchWeapon");

	RegisterHookChain(RG_CBasePlayer_Spawn, "onSpawn",1);
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed", 1);

	g_maxPlayers = get_maxplayers();
	g_msgsync = CreateHudSyncObj();

	get_mapname(mapname, charsmax(mapname));
	
	mp_freeforall = get_cvar_pointer("mp_freeforall");
	bh_enabled = get_cvar_pointer("bh_enabled");
	mp_infinite_ammo = get_cvar_pointer("mp_infinite_ammo");
	
	/*============================================================
	Cvar Ayarlari 
	============================================================*/

	cvars[8] = register_cvar("jb_efekt", "1"); // [0: Sadece Glow | 1: Glow + Daire]
	cvars[9] = register_cvar("lr_bunny","1"); //  Lr Baslayýnca Bunny Kapanmasi [0: Kapali | 1: Acik]

	cvars[10] = register_cvar("lr_sureli","1"); // Süreli Lr [[0: Kapali Lr | 1: Acik] 
	cvars[11] = register_cvar("lr_kill_effects","1"); // Lr'de Olum Efekti [0: Kapali | 1: Acik] 
	cvars[12] = register_cvar("lr_auto","1"); // Sona Kalan Mahkuma Oto Lr Yazdýrma [0: Kapali | 1: Acik]
	cvars[13] = register_cvar("lr_music","1"); // Lr Baslayinca Müzik [0: Kapali | 1: Acik]
	cvars[14] = register_cvar("lr_kalancan","1"); // Lr'de Oynucularýn Kalan Canini gösterir [0: Kapali | 1: Acik]
	
	cvars[15] = register_cvar("lr_zaman","45"); // Lr Suresi (Sure bitince Mahkum ölür.)
	
	cvars[0] = register_cvar("lr_awp","1");  // AWP LR [0:Kapali | 1:Açik]
	cvars[1] = register_cvar("lr_scout","1");  // Scout LR [0:Kapali | 1:Açik]
	cvars[2] = register_cvar("lr_deagle","1"); // Deagle LR [0:Kapali | 1:Açik]
	cvars[3] = register_cvar("lr_usp","1"); // Usp LR [0:Kapali | 1:Açik]
	cvars[4] = register_cvar("lr_aug","1"); // Aug LR [0:Kapali | 1:Açik]
	cvars[5] = register_cvar("lr_ak47","1"); // Ak47 LR [0:Kapali | 1:Açik]
	cvars[6] = register_cvar("lr_m4a1","1"); // M4a1 LR [0:Kapali | 1:Açik]
	cvars[7] = register_cvar("lr_mp5","1"); // Mp5 LR [0:Kapali | 1:Açik]
}

public event_round_start() {
	set_pcvar_num(bh_enabled, 1);
	set_lights("l");
	set_pcvar_num(mp_freeforall, 0);
	aktifDuello = -1;
	duel_active = false;
	remove_task(TASK_ID);
	remove_task(DAIRE_TASKID);
}

public onSpawn(id) {

	if(!is_user_alive(id) || !get_user_team(id))
		return;
	
	set_user_rendering(id);
	remove_task(id);
	//remove_task(TASK_ID);
	//remove_task(DAIRE_TASKID);
	rg_reset_user_model(id);
	touch_weapons[id] = false;
	once[id] = false;

	for(new i = 0; i < sizeof(duels); i++) 
		duels[i][duel][id] = false;
	
	player_challenged[id] = false;
}

public onTouchWeapon(weapon, id) {

	if (!is_user_connected(id) || touch_weapons[id])
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
	
}

public CBasePlayer_Killed(olen, olduren) {

	if(is_user_connected(olduren) && is_user_connected(olen) && touch_weapons[olen] && touch_weapons[olduren]) {
		if(duel_active) {

			remove_task(olduren);
			remove_task(TASK_ID);
			remove_task(DAIRE_TASKID);
			remove_task(olen);
			rg_reset_user_model(olen);
			rg_reset_user_model(olduren);
			set_lights("l");
			aktifDuello = -1;

			if(otoKomutAktif()) {
				if(olduren != olen) {
					client_print_color(0, 0, "^1[^3%s^1] Duelloyu kazanan : ^4%s", SERVERISMI , getName(olduren));
					client_print(0, print_center, "%s Kazandi round otomatik sonlanacak", getName(olduren));
				}
				set_task(3.0, "komutOyunBitti");
			}
			else {
				if(get_user_team(olen) == 2 && player_challenged[olen]) {
					
					for(new i = 0; i < sizeof(duels); i++) 
						duels[i][duel][olduren] = false;

					once[olduren] = false;
					strip_user_weapons(olduren);
					give_item(olduren, "weapon_knife");
					set_user_rendering(olduren);
					duel_menu(olduren);
					set_lights("l");
					remove_task(TASK_ID);
					remove_task(DAIRE_TASKID);
					rg_reset_user_model(olen);
					rg_reset_user_model(olduren);
				}
				else if(get_user_team(olen) == 2 && !player_challenged[olen]) {
					set_task(0.4, "kill_player", olduren);
					client_print(olduren, print_center, "Yanlis adami vurdun dostum!");
				}
			}
		}
		if(get_pcvar_num(cvars[12]) == 1) {

			new players[MAX_PLAYERS], te_num; 
			get_players(players, te_num, "aehi", "TERRORIST");

			if(!duel_active && te_num == 1 && !otoKomutAktif()) {
				duel_menu(players[0]);
				client_print_color(0, 0, "^1[^3%s^1] ^4Hayatta Kalan ^3Tek bir Mahkum ^1var [^4%s^1]!", SERVERISMI, getName(players[0]));
			}
		}
		if(get_pcvar_num(cvars[11]) && duel_active) {

			if(!read_data(1)) return PLUGIN_CONTINUE;

			new wpn[3],vOrigin[3],coord[3];
			read_data(4, wpn, 2);
			get_user_origin(olen,vOrigin);
			vOrigin[2] -= 26;
			coord[0] = vOrigin[0] + 150;
			coord[1] = vOrigin[1] + 150;
			coord[2] = vOrigin[2] + 800;	
			
			create_blood(vOrigin);
			emit_sound(olen,CHAN_ITEM, "weapons/headshot2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
	return PLUGIN_CONTINUE;
}

public komutOyunBitti() {
	new players[32],inum;
	get_players(players, inum, "ahi");

	for(new i;i<inum;i++) {
		user_silentkill(players[i]);
	}
}
public kill_player(id) user_kill(id);

public duel_menu(id) {

	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if (!once[id]) {
		if(get_user_team(id) == 1) {
			new cts[32], ts[32], ctsnum, tsnum, tnum;
			for (new id=1; id <= g_maxPlayers; id++) {
				
				if (!is_user_connected(id)) { 
					continue;
				} 
				if (get_user_team(id) == 1) {
					if(is_user_alive(id)) 
						ts[tsnum++] = id;
					tnum++;
				} 
				else if (get_user_team(id) == 2 && is_user_alive(id)) { 
					cts[ctsnum++] = id;
				} 
			}

			if ((tsnum == 1 && ctsnum >= 1) || (otoKomutAktif() && tnum > 1 && tsnum == 1)) {
				static opcion[64], szId[3];
				formatex(opcion, charsmax(opcion),"\w%s \d|| \yDuello (LR) Menusu",SERVERISMI);
				new iMenu = menu_create(opcion, "sub_duel_menu");

				for(new i = 0; i < sizeof(duels); i++) {
					if(!get_pcvar_num(cvars[i])) continue;
					num_to_str(i, szId, charsmax(szId));
					formatex(opcion, charsmax(opcion), "\d[\r%s\d] \w- \y%s",tag, duels[i][dName]);
					menu_additem(iMenu, opcion, szId);
				}
				
				menu_setprop(iMenu, MPROP_PERPAGE, 0 );
				menu_display(id, iMenu, 0);
				
			}
			else if	(tsnum == 1 && ctsnum < 1)
				client_print_color(id, id, "^1[^3%s^1] ^4Malesef Yasayan Gardiyan Yok!",SERVERISMI);
			
			else if	(tsnum > 1) 
				client_print_color(id, id, "^1[^3%s^1] ^4Sadece Sona Kalan Mahkum Duello Yapabilir!",SERVERISMI);
		}
		else client_print_color(id, id, "^1[^3%s^1] ^4Bu Komut Sadece Mahkumlar icindir.",SERVERISMI);
		
	}
	return PLUGIN_HANDLED;
}

public sub_duel_menu(id, menu, item) {
	
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64];
	new Access, Callback;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback);
	new Key = str_to_num(Data);

	if(is_user_alive(id)) {		
		duels[Key][duel][id] = true;
		aktifDuello = Key;
		choose_enemy(id);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public choose_enemy(id) {

	static opcion[64];
	formatex(opcion, charsmax(opcion),"\w%s \d|| \yRakibini Sec",SERVERISMI);
	new iMenu = menu_create(opcion, "sub_choose_enemy");
	
	new players[32], pnum, tempid;
	new szTempid[10];
	if(otoKomutAktif()) get_players(players, pnum, "ehi", "TERRORIST");
	else get_players(players, pnum, "aehi", "CT");
	
	for( new i; i<pnum; i++ ) {
		tempid = players[i];
		if(tempid == id) 
			continue;
		num_to_str(tempid, szTempid, 9);
		menu_additem(iMenu, getName(tempid), szTempid, 0);
	}
	
	menu_display(id, iMenu);
	return PLUGIN_HANDLED;
}

public sub_choose_enemy(id, menu, item) {
	if( item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new players[MAX_PLAYERS],num;
	get_players(players, num, "acehi", "TERRORIST");
	if(num>1) return PLUGIN_HANDLED;
	
	new Data[6], Name[64];
	new Access, Callback;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback);
	
	new tempid = str_to_num(Data);

	if(otoKomutAktif()) {
		otoKomutRevle(tempid);
		set_pcvar_num(mp_freeforall, 1);
		rg_set_user_model(tempid, "gign");
	}
	
	// strip weapons
	if(!is_user_connected(id) || !is_user_alive(id) || !is_user_connected(tempid) || !is_user_alive(tempid)) return PLUGIN_HANDLED;
	
	// freeze
	strip_user_weapons(id),strip_user_weapons(tempid);
	
	freeze(id);
	freeze(tempid);

	g_gerisayim = 3;
	
	// map teleport
	isinla(id, tempid);
	
	// health
	set_user_health(id, 100);
	set_user_health(tempid, 100);
	
	set_pcvar_num(mp_infinite_ammo, 0);

	if(get_pcvar_num(cvars[9]) == 0)  set_pcvar_num(bh_enabled, 1);
	else set_pcvar_num(bh_enabled, 0);
	
	new inum;
	get_players(players,inum, "ahi");

	set_user_godmode(id, 0);
	set_user_godmode(tempid, 0);
	
	duelzaman = get_pcvar_num(cvars[15]);

	if(get_pcvar_num(cvars[10])) set_task(3.0, "FuncCountDown",id);

	if(get_pcvar_num(cvars[14])) {
		ct = tempid;
		te = id;
		lrBaslamasina();
	}
	switch (get_pcvar_num(cvars[8])) {
		case 0: { // glow
			set_user_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 20);
			set_user_rendering(tempid, kRenderFxGlowShell, 0, 0, 250, kRenderNormal, 20);
		}
		case 1: { // beacon
			set_user_rendering(id, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 20);
			set_user_rendering(tempid, kRenderFxGlowShell, 0, 0, 250, kRenderNormal, 20);
			beacon();
		}
	}

	player_challenged[tempid] = true;
	once[id] = true ;

	touch_weapons[id] = true;
	touch_weapons[tempid] = true;

	g_muzik = true;
	set_lights("f");
	set_task(2.9,"durdur");
	set_task(3.0,"muzik_cal");

	duels[aktifDuello][duel][tempid] = true;

	rg_give_item(id, duels[aktifDuello][weaponName]);
	rg_give_item(tempid, duels[aktifDuello][weaponName]);

	if(otoKomutAktif()) {
		set_task(1.0, "silahVer", 551 + tempid);
	}

	new WeaponIdType:weaponId = getWeaponId(aktifDuello);

	if(aktifDuello == DUEL_AWP || aktifDuello == DUEL_SCOUT) {
		rg_set_user_ammo(id, weaponId, 100);
		rg_set_user_ammo(tempid, weaponId, 100);
	}
	else {
		rg_set_user_ammo(id, weaponId, 1);
		rg_set_user_ammo(tempid , weaponId, 1);
	}
	rg_set_user_bpammo(id ,weaponId, 1);
	rg_set_user_bpammo(tempid , weaponId, 1);

	client_print_color(0, 0, "^1[^3%s^1] ^4%s ^1vs ^4%s ^1%s Duellosu Yapiyorlar.", SERVERISMI , getName(id), getName(tempid), duels[aktifDuello][dName]);
	
	duel_active = true;
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public silahVer(tempid) {
	tempid = tempid - 551;
	rg_remove_all_items(tempid);
	rg_give_item(tempid, duels[aktifDuello][weaponName]);
	rg_set_user_ammo(tempid, getWeaponId(aktifDuello), 1);
	rg_set_user_bpammo(tempid , getWeaponId(aktifDuello), 1);

	if(aktifDuello == DUEL_AWP || aktifDuello == DUEL_SCOUT) {
		rg_set_user_ammo(tempid, getWeaponId(aktifDuello), 100);
	}
	else rg_set_user_ammo(tempid, getWeaponId(aktifDuello), 1);
	
}

public WeaponIdType:getWeaponId(wpn) {

	switch(wpn) {
		case DUEL_AWP: return WEAPON_AWP;
		case DUEL_SCOUT: return WEAPON_SCOUT;
		case DUEL_DEAGLE: return WEAPON_DEAGLE;
		case DUEL_USP: return WEAPON_USP;
		case DUEL_AUG: return WEAPON_AUG;
		case DUEL_AK47: return WEAPON_AK47;
		case DUEL_M4A1: return WEAPON_M4A1;
		case DUEL_MP5: return WEAPON_MP5N;
	}
	return WEAPON_NONE;
}

public isinla(id1, id2) {

	for(new i = 0; i < sizeof(maps); i++) {
		if(equali(mapname, maps[i][mapName])) {
			new Float:or1[3], Float:or2[3];
			for(new j = 0; j < 3; j++) {
				or1[j] = float(maps[i][origin1][j]);
				or2[j] = float(maps[i][origin2][j]);
			}
			set_entvar(id1, var_origin, or1);
			set_entvar(id2, var_origin, or2);
		}
		
	}
}

public freeze(id) {
	new iFlags = get_entvar(id, var_flags);
	if( ~iFlags & FL_FROZEN ) {
		set_entvar(id, var_flags, iFlags | FL_FROZEN);
		get_entvar(id, var_v_angle, iAngles[id]);
		fwPreThink = register_forward( FM_PlayerPreThink , "fwPlayerPreThink" );
		set_task(3.0, "unfreeze",id);
	}
}

public unfreeze(id) {
	new iFlags = pev(id,pev_flags);
	if(iFlags & FL_FROZEN) {
		set_entvar(id, var_flags, iFlags & ~FL_FROZEN);
		if(fwPreThink) unregister_forward( FM_PlayerPreThink , fwPreThink );
	}
	client_print_color(0, 0, "^1[^3%s^1] ^4LR Basladi !",SERVERISMI);
}

public durdur() client_cmd(0,"stopsound");

public muzik_cal() {
	if(g_muzik && get_pcvar_num(cvars[13])) {
		emit_sound(0, CHAN_AUTO, muzik, VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
		g_muzik = false;
	}
}

public beacon() {
	te_create_beam_ring_between_ent(ct, te, beam, 0, 30, 10, 10, 0, 255, 255, 255, 75, 0, 0, true);
	set_task(1.0, "beacon", DAIRE_TASKID);
}
public lrBaslamasina() {
	client_print(0, print_center,"Lr %d saniye sonra baslayacak.",g_gerisayim);
	g_gerisayim--;
	emit_sound(0, CHAN_AUTO, "weapons/zoom.wav", VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
	
	if(g_gerisayim < 0) remove_task(GERSAYIM_ID);
	else set_task(1.0, "lrBaslamasina", GERSAYIM_ID);
}

public FuncCountDown(id) {
	
	if(!duelzaman) {
		new players[32],inum;
		get_players(players,inum);

		for(new i;i<inum;i++) {
			if(get_user_team(players[i]) == 1)
				user_kill(players[i]);
		}
	}
	else set_task(1.0,"FuncCountDown", TASK_ID);

	set_hudmessage(0, 255 , 0, -1.0, 0.25 , 2, 0.02, 1.0, 0.01, 0.1, 35);
	new hp1 = get_user_health(ct) < 0 ? 0 : get_user_health(ct);
	new hp2 = get_user_health(te) < 0 ? 0 : get_user_health(te);
	ShowSyncHudMsg(0,g_msgsync,"Duellonun Bitmesine [ %d ] saniye kaldi!^n%s: %d HP | %s: %d HP", duelzaman--, getName(ct), hp1, getName(te), hp2);
	
}

public Message_AmmoX(iMsgId, iMsgDest, id) {
	if(is_user_alive(id) && duel_active) {
		set_msg_arg_int(2, ARG_BYTE, 1);
		for(new i = 1; i <= 10; i++) {
			set_pdata_int(id, 376 + i, 1, 5);
		}
	}
}

create_blood(vec1[3]) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_LAVASPLASH); 
	write_coord(vec1[0]); 
	write_coord(vec1[1]); 
	write_coord(vec1[2]); 
	message_end();
}

public getName(id) { 
	new isim[MAX_NAME_LENGTH]; 
	get_entvar(id, var_netname, isim, charsmax(isim));
	return isim;
}

stock te_create_beam_ring_between_ent(startent, endent, sprite, startframe = 0, framerate = 30, life = 10, width = 10, noise = 0, r = 0, g = 0, b = 255, a = 75, speed = 0, receiver = 0, bool:reliable = true)
{
	if(receiver && !is_user_connected(receiver))
		return 0;

	message_begin(get_msg_destination(receiver, reliable), SVC_TEMPENTITY, .player = receiver);
	write_byte(TE_BEAMRING);
	write_short(startent);
	write_short(endent);
	write_short(sprite);
	write_byte(startframe);
	write_byte(framerate);
	write_byte(life);
	write_byte(width);
	write_byte(noise);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(a);
	write_byte(speed);
	message_end();

	return 1;
}

get_msg_destination(id, bool:reliable)
{
	if(id)
		return reliable ? MSG_ONE : MSG_ONE_UNRELIABLE;

	return reliable ? MSG_ALL : MSG_BROADCAST;
}