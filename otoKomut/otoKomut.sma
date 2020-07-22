#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <fakemeta_util>
#include <engine>

/******** EDITLENECEK YERLER **************/

#define semiclip_cvaraktif
//amx_cvar semiclip ayari olmayan semiclip eklentisi kullaniyorsaniz veya vv
//paneldeki semiclip eklentisini kullaniyorsaniz bu satiri silin. 

#define MAX_OYUN_SURESI 5.0 // 3 dk içerisinde kimse oyunu kazanamasa herkes olur. 
#define BEKLEME_SURESI 20.0 // 20 sn içinde CT Gelmezse Oto Komut başlar
new const HOSTTAG[] = "Yapay Zeka | ";
new const SERVERISMI[] = "KaoSCommunity.com";
new const KISATAG[] = "KaoS";

/**************** SON *********************/

#define maxOyunSureTask 2000
#define komutKontrolTask 2001
#define oyunSayacTask 1999

native otoKomutAktif();
native otoKomutRevle(id);
native getAktifOyun(name[], len);
native jb_get_user_packs(id);
native jb_set_user_packs(id, Float:ammount);

enum {
	BOS,
	GOMULEN_OLUR,
	CUCE_TAVSAN,
	SARKAC,
	TSUSTUM,
	AREF,
	FREEZOLUR,
	BOMBA_FF,
	SERI_FF,
	AWP_FF,
	POMPA_FF,
	SAYIYI_BILEN,
	VATAN_HAINI,
	TAVUK_BUL,
	HUNGER_GAMES
};
new oyunlar[][] = {
	"Belirlenmedi!",
	"Gomulen Olur",
	"Deve Cuce Tavsan",
	"Sarkac",
	"T-Sustum Deagle",
	"Aref",
	"Freezelenen Olur",
	"Bomba FF",
	"Seri FF",
	"Awp FF",
	"Pompali FF",
	"Sayiyi Bilen Kazanir",
	"Vatan Haini",
	"Tavugu Bul",
	"Hunger Games"
};

new const tavukKonums[][] = { 
	{-2773, -499, -155}, //sınıf
	{-2768, 468, -155}, //hücrenin sağı
	{4, 1438, -407}, // bombalama yeri mor bölüm
	{0, 1316, -407}, // bombalama yeri yeşil bölüm
	{-31, 1680, -411}, // bombalama yerinin solu
	{596, 2465, -435}, // kule bok çukuru
	{687, 2323, -435}, // kule orta çukur
	{790, 2466, -435}, // kule su çukuru
	{137, 2393, -315}, // mahkeme dugmeler
	{34, 2507, -411}, // mahkeme sagi
	{774, 150, -523}, // çatışma 2.nin 1.si
	{938, 150, -523}, // çatışma 2.nin 2.si
	{932, 646, -523}, // çatışma 1.nin 2.si
	{774, 646, -523}, // çatışma 1.nin 1.si
	{260, 820, -531}, // gizli yer 1
	{253, -32, -531}, // gizli yer 2
	{424, -20, -531}, // gizli yer 3
	{1477, 1381, -475}, // bomba sahasi 1
	{1507, 1759, -475}, // bomba sahasi 2
	{1279, 2464, -475}, // scout karşısı
	{2235, 2474, -707}, // scout yanı
	{2229, 499, -668}, // fındık karşısı su 1
	{2238, 1002, -701}, // fındık karşısı su 2
	{2174, 1600, -689}, // fındık karşısı su 3
	{1277, 538, -475}, // fındık yanı
	{1188, 1482, -411}, // ring arkası
	{-847, 779, -411}, // havuz dışı 1
	{-840, 12, -411}, // havuz dışı 2
	{-587, 374, -634}, // havuz 1
	{-398, 610, -646}, // havuz 2
	{-234, 2365, -411}, // kz 1
	{-830, 1253, -411}, // kz 2
	{-1487, 198, -155}, // karanlık 1
	{-1002, 172, -27}, // karanlık 2
	{-1539, -231, -155}, // karanlık 3
	{-979, -483, -27}, // karanlık 4
	{-1530, -363, -27}, // karanlık 5
	{-986, -482, 101}, // şans
	{-2745, -478, 101}, // futbol
	{-2735, 2067, 101}, // at yarışı yanı
	{-3118, -3251, -1230}, // bhop giriş
	{-1112, -1642, -1803}, // surf giriş
	{-2322, 593, 164}, // silah odası
	// Zor Yerler 
	{-2642, 1762, 187}, // at yarışı 1
	{-2446, 1832, 187}, // at yarışı 2
	{-2244, 1905, 187}, // at yarışı 3
	{-2670, 1976, 101}, // at yarışı 4
	{-582, -3496, -1608}, // surf zor
	{1378, -1208, -1661}, // surf kolay
	{-2106, 2352, -427}  // lz
};

new const hungerKonums[][] = {
	{-1772, 1267, -155},
	{-1776, 740, -155},
	{-1302, 760, -155}, 
	{-1257, 1273, -155},
	{-1523, 1501, -155}, 
	{-2099, 1011, -155},
	{-1455, 445, -155},
	{-1423, 1008, -27},
	{-1516, 922, -27},
	{-1614, 1006, -27},
	{-1525, 1090, -27},
	{-2466, 882, -155},
	{-2397, 1457, -155},
	{-2757, 1167, -129}
};

new Float:meydanKonum[] = {-1523.0, 1009.9, -27.0};

new const cuceTavsanKomut[][] = {
	"CUCE",
	"TAVSAN",
	"DEVE",
	/* Bu satırdan sonrakiler Fake, eklemek istiyorsan aşağıya ekle */
	"CUC",
	"CURE",
	"DAVSAN"
};

new const sustumKelimeler[][] = { // sadece 5 harfli keliemeler
	"belli", "acemi", "bolca", "firma", "pompa", "kafes", "hucre", "ahmet", "espri", "marka", "hamsi",
	"maraz", "isyan", "salca", "ninni", "eylem", "otizm", "selam", "vahsi", "efekt", "yetki", "admin",
	"simdi", "taksi", "oneri", "zombi", "hapis", "tokat", "araba", "sisli", "trend", "vakit", "nakit"
};

new const entClases[][] = {
	"Tavuk",
	"Box",
	"Meydan"
};

/*********** MODEL VE SESLER **************/

new const sesler[][] = {
	"misc/kutu_acilis.wav", // Rastgele Oyun Secimi
	"misc/kutu_dolu.wav", // Rastgele Oyun Secildi
	"buttons/blip1.wav", // Gomulen Olur Her Saniye
	"buttons/bell1.wav", // Gomulen Olur Gomdum
	"events/task_complete.wav" // Ayar Sifirla
};

new const modeller[][] = {
	"models/chick.mdl",
	"models/kaos_box.mdl"
};

new const weapons[][] = {
	"weapon_usp", "weapon_glock18", "weapon_deagle", "weapon_p228", "weapon_elite", "weapon_fiveseven",
	"weapon_m3", "weapon_xm1014", "weapon_tmp", "weapon_mac10", "weapon_mp5navy", "weapon_p90",
	"weapon_ump45", "weapon_famas", "weapon_galil", "weapon_ak47", "weapon_m4a1", "weapon_sg552", "weapon_aug",
	"weapon_scout", "weapon_sg550", "weapon_awp", "weapon_g3sg1", "weapon_m249", "weapon_hegrenade", "weapon_smokegrenade",
	"weapon_flashbang", "item_kevlar", "item_assaultsuit"
};

/**************** SON *********************/

#if defined semiclip_cvaraktif 
	new  semiclip;
#endif

new bool: cKomutAktif = false, bool: elsonuKomutSon = false, bool:blockRev = false, lastTe[MAX_CLIENTS + 1];
new bool: egildi[MAX_CLIENTS + 1],  zipladi[MAX_CLIENTS + 1], sustumKelime[18], sustumAktif = false, hungerMesafe = 5000;
new aktifOyun = BOS, bool: g_effectON = false, bool: g_finishFlash = false, bool: cuceTavsanAktif, cuceTavsanDurum;
new sv_gravity, mp_forcecamera, sv_parachute, mp_freeforall,mp_infinite_ammo,mp_infinite_grenades,mapname[32];
new bool:OyunDurumu, tavukEnt, meydanEnt, Float:tavukOrigin[3], hudcvar, hostcvar;
new bool:FFAktif, sayi_kaydet,vatanhaini = -1;
new hostname, oldhostname[64], oyunSira = 0;//, wasCT[MAX_CLIENTS + 1];
new sonOyunlar[4] = {-1,-1,-1,-1};

new Float: fTime, isim[32];
new HookChain: fwd_Death, HookChain:fwd_Jump, HookChain:fwd_Duck, HookChain:fwd_Dmg;

public plugin_init() {
	register_plugin("[ReAPI] Oto Komut", "v0.1", "Necati_DGN & amad");
	register_clcmd("say", "onSaid");
	register_clcmd("say_team", "onSaid");
	
	register_clcmd("say simdikioyun", "oyunAdi");
	register_clcmd("say oyunadi", "oyunAdi");
	register_clcmd("say /oyun", "oyunAdi");
	register_clcmd("say !oyun", "oyunAdi");
	register_clcmd("say .oyun", "oyunAdi");

	/* Events */
	register_event("HLTV", "roundStart", "a", "1=0", "2=0");

	RegisterHookChain(RG_RoundEnd, "roundEnd", 1);
	RegisterHookChain(RG_CBasePlayer_Spawn, "onSpawn",1);
	DisableHookChain(fwd_Jump = RegisterHookChain(RG_CBasePlayer_Jump, "onJump"));
	DisableHookChain(fwd_Duck = RegisterHookChain(RG_CBasePlayer_Duck, "onDuck"));
	DisableHookChain(fwd_Death = RegisterHookChain(RG_CBasePlayer_Killed, "onDeath", 1));
	DisableHookChain(fwd_Dmg = RegisterHookChain(RG_CBasePlayer_TakeDamage, "TakeDamage", 0));

	register_touch(entClases[1], "player", "onTouchBox");
	register_touch(entClases[0], "player", "onTouchTavuk"); 

	
	/* Cvars */
	bind_pcvar_num(create_cvar("otokomut_hud", "0"), hudcvar); // Radar alti Hud
	bind_pcvar_num(create_cvar("otokomut_hostname", "0"), hostcvar); // hostcvar

	#if defined semiclip_cvaraktif 
		semiclip = get_cvar_pointer("semiclip");
	#endif
	mp_freeforall = get_cvar_pointer("mp_freeforall");
	mp_infinite_ammo = get_cvar_pointer("mp_infinite_ammo"); //sinirsiz mermi
	mp_infinite_grenades = get_cvar_pointer("mp_infinite_grenades"); //sinirsiz bomba
	sv_gravity = get_cvar_pointer("sv_gravity");
	sv_parachute = get_cvar_pointer("sv_parachute");
	mp_forcecamera = get_cvar_pointer("mp_forcecamera");

	if(hostcvar) {
		hostname = get_cvar_pointer("hostname");
		get_pcvar_string(hostname, oldhostname, charsmax(oldhostname));

		if(contain(oldhostname, HOSTTAG) != -1) {
			replace(oldhostname, charsmax(oldhostname), HOSTTAG, "");
			set_pcvar_string(hostname, oldhostname);
		}
	}
	get_mapname(mapname, charsmax(mapname));
}

public plugin_precache() {

	for(new i = 0; i < sizeof(sesler); i++) 
		precache_sound(sesler[i]);
	for(new i = 0; i < sizeof(modeller); i++)
		precache_model(modeller[i]);
}


/*************** Natives *******************/

public plugin_natives() {
	register_native("otoKomutAktif", "native_otoKomutAktif", 1);
	register_native("otoKomutRevle", "native_otoKomutRevle", 1);
	register_native("getAktifOyun", "native_getAktifOyun");
}

public native_otoKomutRevle(id) {
	lastTe[id] = true;
	rg_round_respawn(id);
}

public native_getAktifOyun(plugin, params) {
	new oyunAd[32];
	formatex(oyunAd, charsmax(oyunAd), "%s", cKomutAktif ? oyunlar[aktifOyun] : "PASIF");
	set_string(1, oyunAd, get_param(2));
}

public native_otoKomutAktif() return cKomutAktif;

/**************** SON ***********************/

/*************** General Events ********************/

public roundEnd() {
	if(cKomutAktif) {
		aktifOyun = BOS;
		remove_task(maxOyunSureTask);
	}
	if(elsonuKomutSon) {
		elsonuKomutSon = false;
		cKomutAktif = false;
		resetGame();
	}
}
public roundStart() {
	blockRev = false;
	if(cKomutAktif) {
		remove_task(1338),set_task(15.0, "blockRevive",1338);
		chooseGame();
		set_task(0.1, "ayarsifirla");// ayarsifirla();
	}
	
	if(!task_exists(komutKontrolTask)) {
		set_task(BEKLEME_SURESI, "checkCT", komutKontrolTask);
	}
}

public blockRevive() {
	if(cKomutAktif) blockRev = true;
}
public onSpawn(id) {
	switch (get_user_team(id)) {
		case 1: {
			if(!task_exists(komutKontrolTask)) 
				set_task(BEKLEME_SURESI, "checkCT", komutKontrolTask);
		}
		case 2: { 
			if(cKomutAktif) 
				checkCT();
		}  
	}
	if(cKomutAktif && !lastTe[id] && blockRev) {
		client_print_color(id,id,"^1[^3%s^1] ^4Oto Komut ^3aktifken ^1yeniden dogamazsiniz. Bir sonraki roundu bekleyin.", KISATAG);
		set_task(1.0,"oldur", id);
	}
	else if(cKomutAktif && lastTe[id]) lastTe[id] = false;
}

public client_disconnected(id) {
	if(get_user_team(id) == 2) {
		if(!task_exists(komutKontrolTask)) {
			set_task(BEKLEME_SURESI, "checkCT", komutKontrolTask);
		}
	}
}

public onSaid(id) {
	if(is_user_alive(id) && cKomutAktif) {
		/*** T-Sustum ***/
		if(sustumAktif && aktifOyun == TSUSTUM) {
			static msg[64];
			read_args(msg, charsmax(msg));
			remove_quotes(msg);
			trim(msg);
			trim(sustumKelime);
			if(!strcmp(msg, sustumKelime, true)) {
				sustumAktif = false;
				remove_task(9000 + TSUSTUM);
				emit_sound(0, CHAN_AUTO, sesler[3], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
				client_print_color(id, id, "^1[^3%s^1] ^4Oto Komut ^1: Dogru bildin! 15 Saniye icerisinde birini secip oldurman gerekiyor.", KISATAG);
				client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Ilk Yazan : ^3%s.^1Simdi sectigi oyuncuyu ^3oldurecek^1.", KISATAG, getName(id));
				tSustumOldurMenu(id);
				set_task(17.0, "tSustumBasla", 8000 + TSUSTUM);
			}
		}
		else if(sayi_kaydet > 0) {
			//Sayiyi bilen
			static say[6]; read_args(say, charsmax(say)); remove_quotes(say);
			if(is_str_num(say)) {
				if(get_member(id, m_iTeam)==1) {
					new miktar = str_to_num(say);
					if(miktar == sayi_kaydet) {
						client_print_color(0, print_team_blue, "^1[^3%s^1]^4 adli oyuncu ^1Sayiyi Bilen Kazanir^4 oyununu kazandi. ^3Dogru cevap > ^1%d^3.",getName(id),sayi_kaydet);
						new players[MAX_PLAYERS], te_num,ids;
						get_players(players, te_num, "aehi", "TERRORIST");
						for(new i = 0; i < te_num; i++) {
							ids = players[i];
							if(ids == id) continue;
							else if(is_user_alive(ids)) kill(id, ids, "deagle");
						}
						sayi_kaydet = 0;
						sonOyuncuHazirla(id);
						ayarsifirla();
					} 
					else if(miktar < sayi_kaydet) {
						client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Dogru cevap ^1%d ^4sayisindan daha ^3YUKSEK^4.",SERVERISMI, miktar);
						return PLUGIN_HANDLED;
						} else {
						client_print_color(id, print_team_blue, "^1[^3%s^1]^4 Dogru cevap ^1%d ^4sayisindan daha ^3DUSUK^4.",SERVERISMI, miktar);
						return PLUGIN_HANDLED;
					}
				} else client_print_color(0, id, "^1[^3%s^1]^4 Sadece mahkumlar tahminde bulunabilir.",SERVERISMI);
			}
		}
	}
	return PLUGIN_CONTINUE;
}

/*************** SON ********************/

public checkCT() {
	new te_num, ct_num;
	te_num = get_member_game(m_iNumTerrorist);
	ct_num = get_member_game(m_iNumCT);
	if(te_num > 1 && ct_num < 1) {
		if(!cKomutAktif) { // Oto Komut Hazırla
			cKomutAktif = true;
			prepareGame();
		}
	}
	else if(ct_num > 0 || te_num < 2) { // Oto Komut Sonlandır
		if(cKomutAktif) {
			elsonuKomutSon = true;
		}
	}
}

public oyunAdi() {
	if(cKomutAktif)
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Aktif Oyun ^4>^1 [^3%s^1]", KISATAG, oyunlar[aktifOyun]);
}
public prepareGame() {
	if(hostcvar) {
		static yenisi[64];
		formatex(yenisi, charsmax(yenisi), "%s%s", HOSTTAG, oldhostname);
		set_pcvar_string(hostname, yenisi);
		message_begin(MSG_BROADCAST, get_user_msgid("ServerName"));
		write_string(yenisi);
		message_end();
	}

	if(hudcvar == 1) set_task(1.0,"ekrana_yansit",1337,_,_,"b");

	set_cvar_num("sv_restartround", 1);
	client_print(0, print_center, "Oto Komut Aktiflestirildi.");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^3Aktiflestirildi.^1 Artik ^3Oyun ^4Sistem^1 tarafindan oynatilacak.", KISATAG);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^3Aktiflestirildi.^1 Artik ^3Oyun ^4Sistem^1 tarafindan oynatilacak.", KISATAG);
}
public ekrana_yansit(){
	if(hudcvar != 1) { 
		remove_task(1337); 
		return; 
	}
	set_hudmessage(0, 255, 0, 0.005, 0.17, 0, 0.5, 1.0);
	show_hudmessage(0,"Yapay Zeka AKTIF!^nOyun : %s", oyunlar[aktifOyun]); 
}
public resetGame() {
	if(hostcvar) {
	static yenisi[64];
	formatex(yenisi, charsmax(yenisi), "%s", oldhostname);
	set_pcvar_string(hostname, yenisi);
	message_begin(MSG_BROADCAST, get_user_msgid("ServerName"));
	write_string(yenisi);
	message_end();
	}
	
	set_cvar_num("sv_restartround", 1);//server_cmd("sv_restartround 1");
	ayarsifirla();
	cKomutAktif = false;
	client_print(0, print_center, "Oto Komut Sonlandirildi.");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^3Sonlandirildi. ^1Komut gercek komutcuya devredildi.", KISATAG);
	client_print_color(0, 0," ^1[^3%s^1] ^4Oto Komut ^3Sonlandirildi. ^1Komut gercek komutcuya devredildi.", KISATAG);
}

public chooseGame() {
	/* Effect */
	set_task(1.2,"effectON");
	set_task(3.8,"effectDsc");
	set_task(6.1,"effectOFF");
	g_effectON = true;
	
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Rastgele Oyun Seciliyor...", KISATAG);
	emit_sound(0, CHAN_AUTO, sesler[0], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
	flashla(-1, random_num(0, 255), random_num(0, 255), random_num(0, 255), 255);
}

public effectON() {
	if(g_effectON) {
		ekranrengi(-1, random_num(0,255), random_num(0,255), random_num(0,255), 70);
		set_task(0.2, "effectON");
	}
}

public effectDsc() {
	g_effectON = false;
	finishFlash();
	set_task(1.0, "finishFlash");
	g_finishFlash = true;
}

public finishFlash() {
	if(g_finishFlash) {
		set_task(1.0, "finishFlash");	
		ekranrengi(-1, random_num(0,255), random_num(0,255), random_num(0,255), 70);
	}
}

public effectOFF() {
	g_finishFlash = false;
	set_task(0.5, "printGame");
}

public printGame() {
	if(cKomutAktif) {
		
		while(aktifOyun == BOS) {

			if(equal(mapname, "jail_buyukisyan_dark")) aktifOyun = random_num(1, charsmax(oyunlar));
			else aktifOyun = random_num(1, charsmax(oyunlar) - 2); // map dark değilse darka özel oyunları çıkar. 

			for(new i = 0; i < sizeof(sonOyunlar); i++) {
				if(aktifOyun == sonOyunlar[i]) {
					aktifOyun = BOS;
					i = sizeof(sonOyunlar);
				}
			}
		}
		if(aktifOyun != TAVUK_BUL && aktifOyun != HUNGER_GAMES && aktifOyun != VATAN_HAINI) {
			sonOyunlar[oyunSira++] = aktifOyun;
			if(oyunSira == 4) oyunSira = 0;
		}
		set_task(1.0, "oyunSayac", oyunSayacTask, _, _, "b");
		
		emit_sound(0, CHAN_AUTO, sesler[1], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Rastgele secilen oyun : [^3%s^1]", KISATAG, oyunlar[aktifOyun]);
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Rastgele secilen oyun : [^3%s^1]", KISATAG, oyunlar[aktifOyun]);
		client_print(0, print_center, "Rastgele secilen oyun : [%s]", oyunlar[aktifOyun]);	
	}
	
	flashla(-1, random_num(0, 255), random_num(0, 255), random_num(0, 255), 255);
}

public oyunSayac() {
	if(cKomutAktif) {
		if(fTime == 0) {
			startGame();
			remove_task(oyunSayacTask);
			fTime = 5.0;
		}
		else {
			client_print(0, print_center, "'%s' oyununun baslamasina [%d]", oyunlar[aktifOyun], floatround(fTime));
			client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: [^3%d^1] saniye sonra '^4%s^1' oyunu baslayacak.", KISATAG, floatround(fTime), oyunlar[aktifOyun]);
			fTime--;
		}
	}
}

public startGame() {
	if(cKomutAktif) {
		new players[MAX_PLAYERS], te_num, ids;
		get_players(players, te_num, "aehi", "TERRORIST");
		if(te_num == 1) {
			sonOyuncuHazirla(players[0]);
			ayarsifirla();
		}
		else {
			client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: '^4%s^1' oyunu basladi.", KISATAG, oyunlar[aktifOyun]);
			switch(aktifOyun) {
				case GOMULEN_OLUR: {
					set_pcvar_num(sv_gravity, 250);
					#if defined semiclip_cvaraktif 
					set_pcvar_num(semiclip, 1);
					#endif
					
					set_task(1.0, "saniyeEffect", 9000 + GOMULEN_OLUR, _, _, "b");
					set_task(6.0, "gomulenOlurGom");
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: 6 Saniye Sonra ^3Gomulen Olur ! ", KISATAG);
				}
				case CUCE_TAVSAN: {

					EnableHookChain(fwd_Jump);
					EnableHookChain(fwd_Duck);

					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: KOMUTLAR : ^3DEVE ^1(Normal), ^3CUCE ^1(Otur), ^3TAVSAN ^1(Zipla)", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: KOMUTLAR : ^3DEVE ^1(Normal), ^3CUCE ^1(Otur), ^3TAVSAN ^1(Zipla)", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^1Hareketi ^3BIR DEFA ^1yapmaniz ^4yeterlidir.", KISATAG);
					
					set_task(1.0, "saniyeEffect", 9000 + CUCE_TAVSAN, _, _, "b");
					set_task(5.0, "cuceTavsanBasla");
				}
				case SARKAC: {
					SarkacOyunBaslat();
				}
				case TSUSTUM: {
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3T Sustum^1 yazdiktan sonra yazilani ^4ilk dogru ^1yazan birini oldurur.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3T Sustum^1 yazdiktan sonra yazilani ^4ilk dogru ^1yazan birini oldurur.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^1 Dogru yazan kisi^4 15^1 saniye icerisinde kimseyi secmezse ^3kendisi olur^1.", KISATAG);
					set_task(7.0, "tSustumBasla");
					
				}
				case AREF: {
					EnableHookChain(fwd_Death);
					FFAktif = true; 
					set_pcvar_num(mp_freeforall, 1);
					set_pcvar_num(mp_infinite_ammo, 1);
					#if defined semiclip_cvaraktif 
					set_pcvar_num(semiclip, 0);
					#endif
					for(new i = 0; i < te_num; i++) {
						ids = players[i];
						rg_remove_all_items(ids);
						rg_give_item(ids, "weapon_knife");
						rg_give_item(ids, "weapon_usp");
						set_entity_visibility(ids, 0);
					}
				}
				case FREEZOLUR: {
					set_task(3.0, "freezebasla", 9000 + FREEZOLUR,_ ,_ , "b");
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 3 saniyede bir kisi ^1rastgele ^3freezelenecek^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Freezelenmeden sona kalan ^1oyunu ^4kazanir^1.", KISATAG);
				}
				case BOMBA_FF: {
					EnableHookChain(fwd_Death);
					FFAktif = true;	
					set_pcvar_num(mp_freeforall, 1);
					set_pcvar_num(mp_infinite_grenades, 1);
					for(new i = 0; i < te_num; i++) {
						ids = players[i];
						rg_remove_all_items(ids);
						rg_give_item(ids, "weapon_knife");
						rg_give_item(ids, "weapon_hegrenade");
					}
				}
				case SERI_FF: {
					EnableHookChain(fwd_Death);
					FFAktif = true;
					set_pcvar_num(mp_freeforall, 1);
					set_pcvar_num(mp_infinite_ammo, 1);
					for(new i = 0; i < te_num; i++) {
						ids = players[i];
						set_entvar(ids, var_health, Float:500.0);
						rg_give_item(ids, "weapon_m4a1");
						rg_give_item(ids, "weapon_ak47");
					}
				}
				case AWP_FF: {
					EnableHookChain(fwd_Death);
					FFAktif = true;
					set_pcvar_num(mp_freeforall, 1);
					set_pcvar_num(mp_infinite_ammo, 1);
					for(new i = 0; i < te_num; i++) {
						ids = players[i];
						rg_remove_all_items(ids);
						set_entvar(ids, var_health, Float:500.0);
						rg_give_item(ids, "weapon_knife");
						rg_give_item(ids, "weapon_awp");
					}
				}
				case POMPA_FF: {
					EnableHookChain(fwd_Death);
					FFAktif = true;
					new ids;
					set_pcvar_num(mp_freeforall, 1);
					set_pcvar_num(mp_infinite_ammo, 1);
					for(new i = 0; i < te_num; i++) {
						ids = players[i];
						set_entvar(ids, var_health, Float:500.0),rg_give_item(ids, "weapon_xm1014"),rg_give_item(ids, "weapon_m3");
					}
				}
				case SAYIYI_BILEN: {
					set_task(5.0, "sayiyibelirle", 9000 + SAYIYI_BILEN);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 5 saniye sonra ^1sayi^3 belirlenecek^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Say'dan sayiyi ^1tahmin eden ^4kazanir^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Sayinin dogru cevaptan ^1yuksek/dusuk^3 bilgisi say'dan verecektir^1.", KISATAG);
				}
				case VATAN_HAINI: {
					EnableHookChain(fwd_Dmg);
					EnableHookChain(fwd_Death);
					vatanhaini = -5;
					set_task(5.0, "hainbelirle", 9000 + VATAN_HAINI);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 5 saniye sonra ^1Vatan Haini^3 belirlenecek^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Haini olduren ^1oyunu ^4kazanir^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Kimse olduremezse ^1Hain^3 kazanir^1.", KISATAG);
				}
				case TAVUK_BUL: {
					tavukOlustur();
					hucreKapisiKaldir(true);
					set_task(1.0,"tavukSaniyeEffect", 9000 + TAVUK_BUL, _, _, "b");
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Haritada bir ^3TAVUK saklandi^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Tavuga basan ^1oyunu ^4kazanir^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Tavuga basan ^1oyunu ^4kazanir^1.", KISATAG);
				}
				case HUNGER_GAMES: {
					EnableHookChain(fwd_Death);
					kutuOlustur();
					meydanOlustur();
					hucreKapisiKaldir(true);
					set_lights("e");
					set_pcvar_num(sv_gravity, 0);
					silahlariKaldirGetir(true); // yerdeki silahları gizler
					hungerIsinla();
					set_task(5.0,"hungerBasla");
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Haritadaki kutulardan ^3silahlari ^1cikar.^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Silahlarla ^4rakiplerini ^3oldur^1.", KISATAG);
					client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Birazdan ^4inise gecilip oyun baslayacak!.", KISATAG);
				}
			}
			set_task(MAX_OYUN_SURESI * 60, "oyunSureBitti", maxOyunSureTask);
			client_print(0, print_center, "'%s' Oyunu Basladi!", oyunlar[aktifOyun]);
		}
	}
}

/* Oyun Fonksiyonları */

public onDeath(olen, saldiran) {
	if(cKomutAktif) {
		new players[MAX_PLAYERS], te_num, ids;
		if(FFAktif) {
			get_players(players, te_num, "aehi", "TERRORIST");
			if(te_num == 1) {
				sonOyuncuHazirla(players[0]);
				ayarsifirla();
			}
		}
		if(aktifOyun == VATAN_HAINI && vatanhaini != -1) {
			get_players(players, te_num, "aehi", "TERRORIST");
			if(saldiran != vatanhaini && olen == vatanhaini) {
				for(new i = 0; i < te_num; i++) {
					ids = players[i];
					if(ids != saldiran) {
						kill(saldiran, ids, "vatan haini");
					}
					client_print_color(0, print_team_blue, "^1[^3%s^1]^4 adli oyuncu ^1Haini oldurdu^4 ve oyunu kazandi",getName(ids)); 
					sonOyuncuHazirla(saldiran);
				}
				ayarsifirla();
			} 
			else if(te_num == 1 && players[0] == vatanhaini) {
				sonOyuncuHazirla(vatanhaini);
				client_print_color(0, print_team_blue, "^1[^3%s^1]^4 adli hain ^3 ve oyunu kazandi",getName(vatanhaini)); 
				ayarsifirla();
			} 
			else if(saldiran == vatanhaini && vatanhaini == olen) {
				vatanhaini = -5;
				set_task(5.0, "hainbelirle", 9000 + VATAN_HAINI);
				client_print_color(0, print_team_blue, "^1[^3%s^1]^4 adli ^1Hain^4 kendi kendine oldu!^3 Yeni Hain Belirleniyor!",getName(olen));
			}
		}
	}

}
hucreKapisiKaldir(bool:kaldir = true) {
	static iEnt;
	while( (iEnt = find_ent_by_class(iEnt, "func_door")) )
	{
		set_entity_visibility(iEnt, !kaldir);
		kaldir ? set_entvar(iEnt, var_solid, SOLID_NOT) : set_entvar(iEnt, var_solid, SOLID_BSP);
	}
}

public oyunSureBitti() {

	if(cKomutAktif) {
		new players[MAX_PLAYERS], te_num;
		get_players(players, te_num, "aehi", "TERRORIST");
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: %.2f dakikalik oyun suresi doldu.", KISATAG, MAX_OYUN_SURESI);
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: %.2f dakikalik oyun suresi doldu.", KISATAG, MAX_OYUN_SURESI);
		for(new i = 0; i < te_num; i++) {
			kill(0, players[i], "sure doldu");
		}
		ayarsifirla();
	}	
}

public sonOyuncuHazirla(id) {
	if(!is_user_connected(id)) return;
	
	lastTe[id] = true;
	rg_round_respawn(id);
	jb_set_user_packs(id, Float:jb_get_user_packs(id)+10.0);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Sona kalan ve oyunu kazanan : '^4%s^1' ||^3 10.00 TL Odul verildi!", KISATAG, getName(id));
	client_cmd(id, "say /lr");
}
public ayarsifirla() {

	vatanhaini = -1;
	sayi_kaydet = 0;
	aktifOyun = BOS;
	cuceTavsanAktif = false;
	sustumAktif = false;
	FFAktif = false;

	DisableHookChain(fwd_Death);
	DisableHookChain(fwd_Jump);
	DisableHookChain(fwd_Duck);
	DisableHookChain(fwd_Dmg);

	set_pcvar_num(mp_infinite_grenades, 0);
	set_pcvar_num(mp_infinite_ammo, 0);
	set_pcvar_num(mp_freeforall, 0);
	set_pcvar_num(sv_parachute, 1);
	set_pcvar_num(sv_gravity, 800);
	set_pcvar_num(mp_forcecamera, 0);
	#if defined semiclip_cvaraktif 
	set_pcvar_num(semiclip, 1);
	#endif
	set_lights("l");
	remove_task(oyunSayacTask);
	remove_task(9000 + CUCE_TAVSAN);
	remove_task(9000 + GOMULEN_OLUR);
	remove_task(9000 + TSUSTUM);
	remove_task(8000 + TSUSTUM);
	remove_task(9000 + TAVUK_BUL);
	remove_task(9000 + SAYIYI_BILEN);
	remove_task(9000 + FREEZOLUR);
	remove_task(8000 + HUNGER_GAMES);

	hungerMesafe = 5000;
	
	static tempEnt;
	for(new i = 0; i < sizeof(entClases); i++) {
		while((tempEnt = rg_find_ent_by_class(tempEnt, entClases[i])))
		destroyEnt(tempEnt);
	}
	
	silahlariKaldirGetir(false);
	hucreKapisiKaldir(false);
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		if(OyunDurumu) {
			//Sarkacta[ids] = false;
			set_entvar(ids, var_gravity, 1.0);
		}
		glowla(ids, 0, 0, 0, 0);
		set_entity_visibility(ids, 1);
		lastTe[ids] = false;
	}
	OyunDurumu = false;
	emit_sound(0, CHAN_AUTO, sesler[4], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
}

silahlariKaldirGetir(bool:kaldir = true) {
	static iEnt;
	while( (iEnt = find_ent_by_class(iEnt, "armoury_entity")) )
	{
		if(kaldir) {
			set_entvar(iEnt, var_rendermode, kRenderTransAlpha);
			set_entvar(iEnt, var_solid, SOLID_NOT);
		}
		else {
			set_entvar(iEnt, var_rendermode, kRenderNormal);
			set_entvar(iEnt, var_solid, SOLID_TRIGGER);
		}
	}
}
public saniyeEffect() {
	emit_sound(0, CHAN_AUTO, sesler[2], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
}

/*********** Freezelenen olur *****************/

public freezebasla() {
	new players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi", "TERRORIST");

	if(te_num > 1) {
		new rastgele = players[random_num(0, te_num - 1)];
		set_task(2.0, "oldur", rastgele);    //user_kill(rastgele);

		new flags = get_entvar(rastgele, var_flags);
		if(~flags & FL_FROZEN){
			set_entvar(rastgele, var_flags, flags | FL_FROZEN);
			glowla(rastgele, 0, 100, 200, 25);
		}
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, rastgele);
		write_short(1<<14);
		write_short(1<<9);
		write_short(1<<11);
		write_byte(100);
		write_byte(200);
		write_byte(25);
		write_byte(255);
		message_end();
		client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Freeze'lenen Kisi > ^1%s^4",SERVERISMI,getName(rastgele));
	} else {
		ayarsifirla();
		sonOyuncuHazirla(players[0]);
		client_print_color(0, print_team_blue, "^1[^3%s^1]^4 Freeze'lenen Olur oyununu ^1%s^4 kazandi.",SERVERISMI,getName(players[0]));
	}
}
public oldur(id) {
	user_kill(id, 1);
}
/*********** Vatan Haini *****************/
public hainbelirle() {
	if(vatanhaini == -1) return;
	hucreKapisiKaldir(true);
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	if(te_num == 1) { 
		sonOyuncuHazirla(players[0]);
		ayarsifirla(); 
		return; 
	}
	else if(te_num == 0) {
		ayarsifirla();
		return;
	}
	vatanhaini = players[random_num(0, te_num - 1)];
	
	client_print_color(0, 0, "^1[^3%s^1] ^4adli oyuncu ^3Vatan Haini^4 secilti.^1 Olduren KAZANIR !", getName(vatanhaini));
	client_print_color(0, 0, "^1[^3%s^1]^4 adli oyuncu ^3Vatan Haini^4 secilti.^1 Olduren KAZANIR !", getName(vatanhaini));
	
	if(equal(mapname, "jail_buyukisyan_dark")) set_entvar(vatanhaini, var_origin, Float:{1132.0, 2443.0, 410.0});
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		set_entvar(ids, var_health, Float:100.0);
		rg_give_item(ids, "weapon_m4a1");
		rg_give_item(ids, "weapon_ak47");
		glowla(vatanhaini, 0, 0, 255, 25);
	}
	set_entvar(vatanhaini, var_health, Float:100.0*float(te_num - 1));
	glowla(vatanhaini, 255, 0, 0, 25);
	set_pcvar_num(mp_infinite_ammo, 2);
	set_pcvar_num(mp_freeforall, 1);
	#if defined semiclip_cvaraktif 
	set_pcvar_num(semiclip, 0);
	#endif
}
public TakeDamage(victim, inflictor, attacker, Float:damage, damage_bits) {
	if(is_user_connected(attacker) && is_user_connected(victim) && victim != attacker) {
		if(vatanhaini!=-1 && vatanhaini!=victim && vatanhaini!=attacker) SetHookChainArg(4, ATYPE_FLOAT, 0.0);
	}
}

/*********** Sayiyi Bilen *****************/

public sayiyibelirle() {
	set_task(1.0,"saniyeEffect", 9000 + SAYIYI_BILEN, _, _, "b");
	sayi_kaydet = random_num(10,100);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^4Sayi belirlendi! ^1Say'dan ilk bilen kazanir^3!", KISATAG);
	client_print(0, print_center,"Oto Komut : Sayi belirlendi! Say'dan ilk bilen kazanir!");
}

/*********** Gomulen Olur *****************/

public gomulenOlurGom() {
	new players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi", "TERRORIST");

	if(te_num == 1) {
		fTime = 6.0;
		sonOyuncuHazirla(players[0]);
		ayarsifirla();
		return;
	}
	else if(te_num == 0) {
		fTime = 6.0;
		ayarsifirla();
		return;
	}
	fTime--;
	if(fTime < 0) fTime = 1.0;
	
	tGom();
	gomulenOldur();
	set_task(fTime, "gomulenOlurGom");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: %d Saniye Sonra ^3Gomulen Olur ! ", KISATAG, floatround(fTime));
}
public tGom() {
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		if(!Stuck(ids)) {
			client_cmd(ids, "-jump;-duck");
			new Float:origin[3]; get_entvar(ids, var_origin, origin); origin[2]-=35.0;
			set_entvar(ids, var_origin, origin);
		}
	}
	emit_sound(0, CHAN_AUTO, sesler[3], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
	set_pcvar_num(mp_forcecamera, 2);
}

public gomulenOldur() {
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	new aliveT = te_num;
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		if(get_entvar(ids, var_movetype) == MOVETYPE_FLY) {
			user_kill(ids);
			aliveT--;
			client_print(ids, print_center, "Merdiven bugu yaptigin icin olduruldun.");
			client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Merdiven bugu ^1kullandigin icin ^4olduruldun^1! ", KISATAG, floatround(fTime));
		}
		else if(Stuck(ids) && aliveT > 1) {
			user_kill(ids);
			aliveT--;
			client_print(ids, print_center, "Gomuldugun icin olduruldun.");
		}
	}
	
}

/**************** SON *********************/

/*********** DEVE CUCE TAVSAN *************/

public cuceTavsanBasla() {
	new players[MAX_PLAYERS], te_num, ids;
	static komutSayi = 1;
	get_players(players, te_num, "aehi", "TERRORIST");
	
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		zipladi[ids] = false;
		egildi[ids] = false;
	}
	
	if(te_num == 1) {
		fTime = 6.0;
		komutSayi = 1;
		sonOyuncuHazirla(players[0]);
		ayarsifirla();
		return;
	}
	else if(te_num == 0) {
		fTime = 6.0;
		komutSayi = 1;
		ayarsifirla();
		return;
	}
	
	cuceTavsanDurum = random_num(0, charsmax(cuceTavsanKomut));
	cuceTavsanAktif = true;
	client_print_color(0, 0, " ");
	client_print_color(0, 0, " ");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 %d.^1Tur : ^3%s", KISATAG, komutSayi, cuceTavsanKomut[cuceTavsanDurum]);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 %d.^1Tur : ^3%s", KISATAG, komutSayi, cuceTavsanKomut[cuceTavsanDurum]);
	client_print_color(0, 0, " ");
	client_print(0, print_center,"Oto Komut : %d. Tur : [%s]", komutSayi, cuceTavsanKomut[cuceTavsanDurum]);
	
	komutSayi++;
	set_task(fTime - 1, "cuceTavsanKontrol");
	set_task(fTime, "cuceTavsanBasla");
	fTime--;
	if(fTime < 2.0) fTime = 2.0;
}
public cuceTavsanKontrol() {
	cuceTavsanAktif = false;
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	new aliveT = te_num;
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		if ((!cuceTavsanDurum && zipladi[ids]) || (!cuceTavsanDurum && !zipladi[ids] && !egildi[ids]) || (cuceTavsanDurum == 1 && egildi[ids]) || (cuceTavsanDurum == 1 && !egildi[ids] && !zipladi[ids]) || (cuceTavsanDurum >= 2 && (egildi[ids] || zipladi[ids])) && aliveT > 1)  {
			user_kill(ids);
			aliveT--;
			if(cuceTavsanDurum > 2) { // Fake
				client_print(ids, print_center, "[%s] yani bir sey yapmaman gerekiyordu.", cuceTavsanKomut[cuceTavsanDurum]);
			}
			else client_print(ids, print_center, "Sadece %s yapman gerekiyordu.", cuceTavsanKomut[cuceTavsanDurum]);
		}
	}
	
}
public onJump(const id) {
	if(aktifOyun == CUCE_TAVSAN && cuceTavsanAktif) zipladi[id] = true;
}

public onDuck(const id) {
	if(aktifOyun == CUCE_TAVSAN && cuceTavsanAktif) egildi[id] = true;
}
/**************** SON *********************/

/*********** SARKAC *************/

public SarkacOyunBaslat(){
	set_pcvar_num(sv_gravity, 800);
	set_pcvar_num(sv_parachute, 0);
	set_lights("d");
	OyunDurumu = true;
	new players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi", "TERRORIST");
	for (new i = 0; i < te_num ; i++) OyuncuyuSarkacaEkle(players[i]);
	
}
public OyuncuyuSarkacaEkle(id) {
	glowla(id, random_num(20, 200), random_num(20, 200), random_num(20, 200), 25);
	set_entvar(id, var_health, Float:float(random_num(90, 125)));
	set_task(float(id)/10.0,"Sarkac_Islemleri",id);
}

public Sarkac_Islemleri(id) {
	if (!OyunDurumu || !is_user_alive(id)) return PLUGIN_HANDLED;
	new players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi","TERRORIST");
	
	if(te_num == 1) {
		sonOyuncuHazirla(id);
		ayarsifirla();
		return PLUGIN_HANDLED;
	}
	new Float:vHIZ[3];
	get_entvar(id, var_velocity, Float:vHIZ); 
	
	if(floatabs(vHIZ[2]) >= random_float(1000.0,500.0)) {
		if (random_num(0, 1) == random_num(0, 1)) 
			set_entvar(id, var_velocity, Float:{0.0,0.0,0.0});
	}
	else if(vHIZ[2] == 0 && Duvar_Ici(id,-1.0) && !Duvar_Ici(id,1.0)) {
		static Float:Konum[3];
		get_entvar(id, var_origin, Konum);
		Konum[2] += 1.0;
		set_entvar(id, var_origin, Konum);
		set_entvar(id, var_velocity, Float:{0.0,0.0,300.0});
	}
	static Float:Cekim; 
	get_entvar(id, var_gravity, Cekim);
	if (random_num(0, 5) == random_num(0, 5)) {
		if (Yerden_Yukseklik(id) > 750)	
			Cekim = random_float(0.0,5.0);
		
		if (random_num(0, 6) == random_num(0, 5)) set_entvar(id, var_velocity,	Float:{0.0,0.0,-555.0});
		else Cekim = random_float(-3.0,5.0);
	}
	else Cekim = random_float(-1.0,1.0);
	
	if(random_num(0, 3) == random_num(0,3)) {
		new Float:rand = float(random_num(-10,1));
		if(rand > 0.0) 
			set_entvar(id, var_health, Float:get_entvar(id, var_health)+rand);
		else if(rand<0.0) {
			if(Float:get_entvar(id, var_health)+(rand)<=0.0) user_kill(id);
			else set_entvar(id, var_health, Float:get_entvar(id, var_health)+rand);
		}
	}
	set_entvar(id, var_gravity, Cekim);
	set_task(random_float(0.2,0.4),"Sarkac_Islemleri",id);
	
	return PLUGIN_HANDLED;
}

bool:Duvar_Ici(Id,Float:Sayi) {
	static Float:Origin[3];
	get_entvar(Id, var_origin, Origin);
	Origin[2] += Sayi;
	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
	
	if (get_tr2(0, TR_StartSolid))
		return true;
	
	return false;
}
Yerden_Yukseklik(Id) {
	static Yukseklik, Durum;
	for (new i = 0; Durum != 1; i++){
		static Float:Origin[3];
		get_entvar(Id, var_origin, Origin );
		Origin[2] -= i*10.0;
		engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
		if (get_tr2(0, TR_StartSolid))
			Durum = 1 , Yukseklik = i * 10;
	}
	return Yukseklik;
}

/**************** SON *********************/

/*************** T-SUSTUM *****************/

public tSustumBasla() {
	new players[MAX_PLAYERS], te_num;
	get_players(players, te_num, "aehi", "TERRORIST");
	sustumAktif = false;

	if(te_num == 1) {
		sonOyuncuHazirla(players[0]);
		ayarsifirla();
		return;
	}
	else if(te_num == 0) {
		ayarsifirla();
		return;
	}
	
	client_print_color(0, 0, " ");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^4T-SUSTUM!", KISATAG);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^4T-SUSTUM!", KISATAG);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^4T-SUSTUM!", KISATAG);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^4T-SUSTUM!", KISATAG);
	client_print(0, print_center,"Oto Komut : T-SUSTUM!");
	set_task(3.0, "sustumKelimeGoster");
}

public sustumKelimeGoster() {
	if(!task_exists(komutKontrolTask)) {
		set_task(1.0, "saniyeSustumEffect", 9000 + TSUSTUM, _, _, "b");
	}
	sustumAktif = true;
	formatex(sustumKelime, charsmax(sustumKelime), "%s %s %s", sustumKelimeler[random_num(0, charsmax(sustumKelimeler))], 
	sustumKelimeler[random_num(0, charsmax(sustumKelimeler))], 
	sustumKelimeler[random_num(0, charsmax(sustumKelimeler))]
	);
	
	client_print_color(0, 0, " ");
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: '^3%s^1'", KISATAG, sustumKelime);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: '^3%s^1'", KISATAG, sustumKelime);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: '^3%s^1'", KISATAG, sustumKelime);
	client_print(0, print_center, "Oto Komut : T-Sustum '%s'", sustumKelime);
}

public saniyeSustumEffect() {
	emit_sound(0, CHAN_AUTO, sesler[2], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
	client_print(0, print_center, "Oto Komut : T-Sustum '%s'", sustumKelime);
}

public tSustumOldurMenu(id) {
	static ndmenu[64], szTempid[10];
	formatex(ndmenu, charsmax(ndmenu),"\yOto Komut \w: \rSectigin Kisiyi Oldur",SERVERISMI);
	new Menu = menu_create(ndmenu, "tSustumOldurMenuHandler");
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi","TERRORIST");
	
	if(te_num <= 1) {
		tSustumBasla();
	}
	else {
		for(new i = 0; i < te_num; i++) {
			ids = players[i];
			if(ids == id) continue;
			num_to_str(ids, szTempid, charsmax(szTempid));
			formatex(ndmenu, charsmax(ndmenu), "\y%s", getName(ids));
			menu_additem(Menu, ndmenu, szTempid);
		}
		menu_setprop(Menu, MPROP_BACKNAME, "\wOnceki Menu");
		menu_setprop(Menu, MPROP_NEXTNAME, "\wDiger Menu");
		menu_setprop(Menu, MPROP_EXITNAME, "\wKendini Sec");
		menu_display(id, Menu,0, 15);
	}
}
public tSustumOldurMenuHandler(id, menu, item) {
	if(item == MENU_EXIT || item == MENU_TIMEOUT) {
		user_kill(id);
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1:^3 15 saniye ^1icerisinde kimseyi secmediğin icin ^4oldun^1.", KISATAG);
		menu_destroy(menu);
		return PLUGIN_HANDLED; 
	}
	new access,callback,data[6],iname[32]; 
	menu_item_getinfo(menu,item,access,data,charsmax(data),iname,charsmax(iname),callback);
	new key = str_to_num(data);
	
	if(is_user_connected(key) && is_user_alive(key) && is_user_alive(id)) {
		kill(id, key, "deagle");
		client_print(key, print_center, "%s T-Sustumda seni oldurdu.", getName(id));
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3%s^1, T-Sustum oyununda ^3%s^1 adli oyuncuyu ^4oldurdu^1.", KISATAG, getName(id), getName(key));
		if(task_exists(8000 + TSUSTUM)) {
			remove_task(8000 + TSUSTUM);
			client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Bir sonraki tur basliyor...", KISATAG); 
			set_task(3.0, "tSustumBasla", 8000 + TSUSTUM);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

/**************** SON *********************/

/*************** TAVUGU BUL *****************/

public tavukOlustur() {

	tavukEnt = create_entity("info_target");

	if(is_valid_ent(tavukEnt)) {
		entity_set_model(tavukEnt, modeller[0]);
		entity_set_size(tavukEnt, Float:{-6.0, -10.0, 0.0}, Float:{6.0, 10.0, 18.0});
		new rand = random_num(0, charsmax(tavukKonums));
		tavukOrigin[0] = float(tavukKonums[rand][0]);
		tavukOrigin[1] = float(tavukKonums[rand][1]);
		tavukOrigin[2] = float(tavukKonums[rand][2]);
		entity_set_string(tavukEnt, EV_SZ_classname, entClases[0]);
		entity_set_origin(tavukEnt, tavukOrigin);
		entity_set_int(tavukEnt, EV_INT_solid,SOLID_BBOX);
		entity_set_float(tavukEnt, EV_FL_takedamage, DAMAGE_NO);
		SetThink(tavukEnt, "thinkTavuk");
		set_entvar(tavukEnt, var_nextthink, get_gametime() + 0.3);
		set_entvar(tavukEnt, var_animtime, 2.0);
		set_entvar(tavukEnt, var_framerate, 1.0);
		set_entvar(tavukEnt, var_sequence, 0);
		drop_to_floor(tavukEnt);
		glowla(tavukEnt, random_num(20, 200), random_num(20, 200), random_num(20, 200), 30);
	}
}

public onTouchTavuk(entity, id) {

	if(is_user_alive(id) && !entity_get_int(entity, EV_INT_iuser1)) {
		
		//set touched
		entity_set_int(entity, EV_INT_iuser1, 1);

		remove_task(9000 + TAVUK_BUL);
		emit_sound(0, CHAN_AUTO, sesler[3], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
		destroyEnt(entity);
		tavukOyunBitir(id);
		client_print(0, print_center,"Tavuk bulundu! Ilk Bulan : %s", getName(id));
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Tavuk bulundu! ^1Tavugu ilk bulan : ^4%s^1.", KISATAG, getName(id));
		client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: ^3Tavuk bulundu! ^1Tavugu ilk bulan : ^4%s^1.", KISATAG, getName(id));
	}
}

public thinkTavuk(Ent) {

	if(cKomutAktif && aktifOyun == TAVUK_BUL) {
		entity_set_float( Ent, EV_FL_nextthink, halflife_time() + 0.3);
		static distance, Float:PlayerOrigin[3];
		new players[MAX_PLAYERS], te_num, ids;
		get_players(players, te_num, "aehi", "TERRORIST");
		
		for(new i = 0; i < te_num; i++) {
			ids = players[i];
			get_entvar(ids, var_origin, PlayerOrigin);
			distance = floatround(get_distance_f(tavukOrigin, PlayerOrigin));
			if(distance <= 1000) {
				ekranrengi(ids, 130, 0, 0, 200 - (distance / (1000 / 200)));
			}
		}
	}
}

public tavukOyunBitir(id) {
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		if(id == ids) continue;
		kill(id, ids, entClases[0]);
	}
	sonOyuncuHazirla(id);
	ayarsifirla();
}

public tavukSaniyeEffect() {
	emit_sound(0, CHAN_AUTO, sesler[2], VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
	client_print(0, print_center, "Oto Komut : Haritada tavugu bulan kazanir.");
}

/**************** SON ***********************/

/*************** HUNGER GAMES ***************/

public hungerIsinla() {
	static Float:Origin[3];
	Origin[0] = -2200.0;
	Origin[1] = 1027.0;
	Origin[2] = 800.0;
	new players[MAX_PLAYERS], te_num, ids;
	get_players(players, te_num, "aehi", "TERRORIST");
	for(new i = 0; i < te_num; i++) {
		ids = players[i];
		glowla(ids, random_num(0, 255), random_num(0, 255), random_num(0, 255), 50);
		set_entvar(ids, var_origin, Origin);
		Origin[0] += 200.0;
		if(Origin[0] >= 2200.0) {
			Origin[0] = -2200.0;
			Origin[2] -= 100.0;
		}
	}
}

public hungerBasla() {
	FFAktif = true;
	set_pcvar_num(mp_freeforall, 1);
	set_pcvar_num(mp_infinite_ammo, 2);
	set_pcvar_num(sv_gravity, 800);
	client_print_color(0, 0, "^1[^3%s^1] ^4Oto Komut ^1: Aclik Oyunlari basladi!", KISATAG);
	client_print(0, print_center,"Oto Komut : Aclik Oyunlari Basladi!");
	set_task(1.0, "hungerMeydanGel", 8000 + HUNGER_GAMES,_ ,_,"b");
}

public hungerMeydanGel() {
	if(hungerMesafe > 260 && cKomutAktif && aktifOyun == HUNGER_GAMES) 
		hungerMesafe -= 20;
	else remove_task(8000 + HUNGER_GAMES);
}
public thinkMeydan(Ent) {

	if(cKomutAktif && aktifOyun == HUNGER_GAMES) {
		entity_set_float(Ent, EV_FL_nextthink, halflife_time() + 1.0);
		static distance, Float:PlayerOrigin[3];
		new players[MAX_PLAYERS], te_num, ids;
		get_players(players, te_num, "aehi", "TERRORIST");
		
		for(new i = 0; i < te_num; i++) {
			ids = players[i];
			get_entvar(ids, var_origin, PlayerOrigin);
			distance = floatround(get_distance_f(meydanKonum, PlayerOrigin));
			if(distance > 5000) distance = 5000;
			if(distance > hungerMesafe) { 
				client_print(ids, print_center, "Zehirli Gazdasin. Meydana gel!");
				ekranrengi(ids, 0, 0, 200, 180 - (180 * distance) / 5000);
				meydanDisiHasar(ids);
			} 
			else ekranrengi(ids, 0, 0, 200, 0);
		}
	}
}

meydanDisiHasar(id) {
	static Float:hp;
	switch(hungerMesafe) {
		case 0..300: hp = 5.0;
		case 301..500: hp = 4.0; 
		case 501..1500: hp = 3.0;
		case 1501..3000: hp = 2.0;
		case 3001..5000: hp = 1.0; 
	}
	if(get_entvar(id, var_health) <= hp)
		user_kill(id);
	else
		set_entvar(id, var_health, Float:get_entvar(id, var_health) -  hp);
}

public meydanOlustur() { 
	meydanEnt = create_entity("info_target");
	if(is_valid_ent(meydanEnt)) {  
		entity_set_size(meydanEnt, Float:{-6.0, -10.0, 0.0}, Float:{6.0, 10.0, 18.0});
		entity_set_string(meydanEnt, EV_SZ_classname, entClases[2]); 
		SetThink(meydanEnt, "thinkMeydan");
		entity_set_origin(meydanEnt, meydanKonum);
		entity_set_int(meydanEnt, EV_INT_solid, SOLID_NOT);
		entity_set_float(meydanEnt, EV_FL_nextthink, halflife_time() + 1.0);
		drop_to_floor(meydanEnt);
	}
}

public kutuOlustur() {
	static ent, Float:boxOrigin[3];
	for(new i = 0; i < sizeof(tavukKonums); i++) {
		ent = create_entity("info_target");
		if(is_valid_ent(ent)) {  
			entity_set_model(ent, modeller[1]);
			entity_set_size(ent, Float:{-6.0, -10.0, 0.0}, Float:{6.0, 10.0, 18.0});
			boxOrigin[0] = float(tavukKonums[i][0]);
			boxOrigin[1] = float(tavukKonums[i][1]);
			boxOrigin[2] = float(tavukKonums[i][2]);
			entity_set_string(ent, EV_SZ_classname, entClases[1]);
			entity_set_origin(ent, boxOrigin);
			entity_set_int(ent, EV_INT_solid,SOLID_BBOX);
			entity_set_float(ent, EV_FL_takedamage, DAMAGE_NO);
			glowla(ent, random_num(20, 200), random_num(20, 200), random_num(20, 200), 30);
			drop_to_floor(ent);
		}
	}
	for(new i = 0; i < sizeof(hungerKonums); i++) {
		ent = create_entity("info_target");
		if(is_valid_ent(ent)) {  
			entity_set_model(ent, modeller[1]);
			entity_set_size(ent, Float:{-6.0, -10.0, 0.0}, Float:{6.0, 10.0, 18.0});
			boxOrigin[0] = float(hungerKonums[i][0]);
			boxOrigin[1] = float(hungerKonums[i][1]);
			boxOrigin[2] = float(hungerKonums[i][2]);
			entity_set_string(ent, EV_SZ_classname, entClases[1]); 
			entity_set_origin(ent, boxOrigin);
			entity_set_int(ent, EV_INT_solid,SOLID_BBOX);
			entity_set_float(ent, EV_FL_takedamage, DAMAGE_NO);
			glowla(ent, random_num(20, 200), random_num(20, 200), random_num(20, 200), 30);
			drop_to_floor(ent);
		}
	}
}

public onTouchBox(entity, id) {
	if(is_user_alive(id) && !entity_get_int(entity, EV_INT_iuser1)) {
		entity_set_int(entity, EV_INT_iuser1, 1);
		destroyEnt(entity);
		rg_give_item(id, weapons[random_num(0, charsmax(weapons))]);
	}
}

/**************** SON ***********************/

bool:Stuck(id) {
	static Float:Origin[3]; get_entvar(id, var_origin, Origin);
	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, get_entvar(id, var_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
	if(get_tr2(0, TR_StartSolid) ) return true;
	return false;
}

public getName(id) {
	get_entvar(id, var_netname, isim, charsmax(isim));
	return isim;
}

public destroyEnt(ent) {
	if(is_valid_ent(ent))
		remove_entity(ent);
}

glowla(id, bir = 0, iki = 0, uc = 0, amount = 0) {
	static Float:RenderColor[3]; RenderColor[0]=float(bir); RenderColor[1]=float(iki); RenderColor[2]=float(uc);
	
	set_entvar(id, var_renderfx, kRenderFxGlowShell);
	set_entvar(id, var_rendercolor, RenderColor);
	set_entvar(id, var_rendermode, kRenderNormal);
	set_entvar(id, var_renderamt, float(amount));
}

flashla(id, r = 0, g = 255, b = 0, amount = 255) {
	if(id == -1) message_begin(MSG_ALL, get_user_msgid("ScreenFade"),{0,0,0}, 0);
	else message_begin(MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0}, id);
	
	write_short(1<<14);
	write_short(1<<9);
	write_short(1<<11);
	write_byte(r); 
	write_byte(g);
	write_byte(b);
	write_byte(amount);
	message_end();
}

ekranrengi(id, r = 0, g = 255, b = 0, amount = 70) {
	if(id == -1) message_begin(MSG_ALL, get_user_msgid("ScreenFade"),{0,0,0}, 0);
	else message_begin(MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0}, id);
	
	write_short(~0); write_short(~0); 
	write_short(1<<2);
	write_byte(r); 
	write_byte(g); 
	write_byte(b); 
	write_byte(amount);
	message_end();
}

kill(killer, victim, weapon[]) {
	user_silentkill(victim);
	message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0,0,0}, 0);
	write_byte(killer);
	write_byte(victim);
	write_byte(0);
	write_string(weapon);
	message_end();
}

/*

******* NATIVE KULLANIM EXAMPLE *********

native otoKomutAktif(); // oto komut aktif mi?
otoKomutAKtif() -> return (true | false)


native getAktifOyun(name[], len) // aktif oyunun adı?

new name[32];
getAktifOyun(name, charsmax(name));
client_print(0, print_chat," Aktif Oyun : %s", name);


native otoKomutRevle(id); //oyuncu revle, normal r
otoKomutRevle(index);

**************** SON *******************
*/
