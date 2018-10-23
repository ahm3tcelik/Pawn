/* Sublime AMXX Editor v2.2 */

#include <amxmodx>
#include <engine>
#include <reapi>
#include <fakemeta>
#include <jail>

new TAG[] = "Kaos"
new uzaklik,sure_t,sure_ct,soygun_t,soygun_ct,bool:aktif[33],target[33], body,bilgi,hak,amad[33];

public plugin_init() {
	register_plugin("[JB] Soygun]","2.0","amad")
	
	register_clcmd("+soy","soygunON")
	register_clcmd("-soy","soygunOFF")
	register_clcmd("drop","ac")
	
	RegisterHookChain(RG_CBasePlayer_Killed, "killed", 0);
	RegisterHookChain(RG_CBasePlayer_Spawn, "dogunca", 1);
	RegisterHookChain(RG_CBasePlayer_Jump, "jump");
	
	register_event("Damage", "hasar", "b", "2!=0")
	
	uzaklik = register_cvar("soygun_uzaklik", "40")
	sure_t = register_cvar("soygun_suresiTE", "5")
	sure_ct = register_cvar("soygun_suresiCT", "3")
	soygun_t = register_cvar("soygun_miktarT", "5")
	soygun_ct = register_cvar("soygun_miktarCT", "10")
	bilgi = register_cvar("soygun_bilgi", "1")
	hak = register_cvar("soygun_hakki", "3")	
}
public ac(id)
{
	if(get_user_button(id) & IN_RELOAD)
	{
		soygunON(id)
	}
}
public plugin_precache() {
	
	precache_sound("weapons/c4_disarm.wav")
	precache_sound("weapons/c4_disarmed.wav")
	precache_sound("fvox/warning.wav")
}
public soygunON(id) {

	get_user_aiming(id, target[id], body, get_pcvar_num(uzaklik))
	if(amad[id] > get_pcvar_num(hak))
	{
		client_print_color(id,id,"^1[^3%s^1] Maximum soygun girisiminde bulundunuz.",TAG)
		return PLUGIN_HANDLED
	}
	if(!is_user_alive(id))
	{
		client_print_color(id,id,"^1[^3%s^1] Oluyken ^4Soygun ^1yapamazsiniz.",TAG)
		return  PLUGIN_HANDLED
	}
	if(get_user_team(id) != 1)
	{
		client_print_color(id,id,"^1[^3%s^1] Sadece ^4Mahkumlar ^1soygun yapabilir.",TAG)
		return PLUGIN_HANDLED
	}
	if(aktif[target[id]])
	{
		client_print_color(id,id,"^1[^3%s^1] Bu Oyuncuyu su anda soyamazsiniz.",TAG)
		return PLUGIN_HANDLED
	}
	if(Stuck(id))
	{
		client_print_color(id,id,"^1[^3%s^1] ^4Gömülüyken^1 soygun yapamazsiniz.")
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(target[id]))
	{
		return PLUGIN_HANDLED
	}
	new team = get_user_team(target[id])
	switch(team)
	{
		case 1:
		{
			if(jb_get_user_packs(target[id]) < get_pcvar_num(soygun_t))
			{
				client_print_color(id,id,"^1[^3%s^1] Malesef arkadasinizin calinacak  ^4parasi yok.",TAG)
				return PLUGIN_HANDLED
			}
			
			rg_send_bartime(id,get_pcvar_num(sure_t))
			rg_send_bartime(target[id],get_pcvar_num(sure_t))
			set_task(get_pcvar_float(sure_t), "finish", 123+id)
		}
		case 2:
		{
			if(jb_get_user_packs(target[id]) < get_pcvar_num(soygun_ct))
			{
				client_print_color(id,id,"^1[^3%s^1] Malesef arkadasinizin calinacak  ^4parasi yok.",TAG)
				return PLUGIN_HANDLED
			}
			rg_send_bartime(id,get_pcvar_num(sure_ct))
			rg_send_bartime(target[id],get_pcvar_num(sure_ct))
			set_task(get_pcvar_float(sure_t), "finish", 123+id)
		}
	}
	new name[32],name2[32]
	get_user_name(id,name,31)
	get_user_name(target[id],name2,31)
	amad[id]++
	client_print_color(target [id],target[id],"^1[^3%s^1] <^4%s^1> tarafindan soyuluyorsunuz! ^3Engellemek icin Ziplayin^1.",TAG,name)
	client_print_color(id,id,"^1[^3%s^1] <^4%s^1> oyuncusunu ^3soyma islemi basladi^1.",TAG,name2)
	entity_set_float(id, EV_FL_maxspeed, -1.0)
	entity_set_float(target[id], EV_FL_maxspeed, -1.0)
	aktif[id] = true
	aktif[target[id]] = true
	emit_sound(id, CHAN_AUTO, "weapons/c4_disarm.wav", VOL_NORM, ATTN_NORM , 0, PITCH_NORM)
	emit_sound(target[id], CHAN_AUTO, "fvox/warning.wav", VOL_NORM, ATTN_NORM , 0, PITCH_NORM)
	return PLUGIN_HANDLED
}
public soygunOFF(id) {
	if(get_user_team(id) != 1 || !aktif[id])
		return PLUGIN_HANDLED
	entity_set_float(id, EV_FL_maxspeed, 250.0)
	rg_send_bartime(id,0)
	aktif[id] = false
	remove_task(123+id)
	
	if(!is_user_alive(target[id]))
		return PLUGIN_HANDLED
	
	entity_set_float(target[id], EV_FL_maxspeed, 250.0)
	rg_send_bartime(target[id],0)
	aktif[target[id]] = false
	
	return PLUGIN_HANDLED
}


public finish(id) {
	id -= 123
	new name1[32],name2[32];
	get_user_name(id,name1,31)
	get_user_name(target[id],name2,31)
	
	switch(get_user_team(target[id]))
	{
		case 1:  
		{
			if(aktif[target[id]] && aktif[id])
			{
				jb_set_user_packs(id, jb_get_user_packs(id) + get_pcvar_num(soygun_t))
				jb_set_user_packs(target[id], jb_get_user_packs(target[id]) - get_pcvar_num(soygun_t))
				client_print_color(0,0,"^1[^3%s^1] <^4%s^1> Adli mahkum ^3<^4%s^3>^1 adli arkadasini soydu.",TAG,name1,name2)
			}
		}
		case 2:
		{
			if(aktif[target[id]] && aktif[id])
			{
				jb_set_user_packs(id, jb_get_user_packs(id) + get_pcvar_num(soygun_ct))
				jb_set_user_packs(target[id], jb_get_user_packs(target[id]) - get_pcvar_num(soygun_ct))
				client_print_color(0,0,"^1[^3%s^1] <^4%s^1> Adli mahkum ^3<^4%s^3> ^1adli gardiyani soydu.",TAG,name1,name2)
			}
		}
	}
	soygunOFF(id)
	emit_sound(id, CHAN_AUTO, "weapons/c4_disarmed.wav", VOL_NORM, ATTN_NORM , 0, PITCH_NORM)
}
public hasar(id) {
	if(aktif[id])
		soygunOFF(id)
}
public killed(killer,victim)
{
	aktif[killer] = false
	aktif[victim] = false
}
public jump(const id)
{	
	if(aktif[id])
	soygunOFF(id)
}

public CurWeapon(id) {
	if(aktif[id])
		entity_set_float(id, EV_FL_maxspeed, -1.0)
}

public dogunca(id) {
	aktif[id] = false
	amad[id] = 0
}
public client_putinserver(id) {
	set_task(4.0,"info",id)
	if(get_pcvar_num(bilgi))
	{
		client_print_color(id,id,"^1[^3%s^1] [^4 R ^1+ ^3G ^1] tuşlarına basarak oyuncuları ^4soyabilirsiniz.",TAG)	
		set_task(100.0, "info",id , _, _, "b")
	}
}
public info(id) client_print_color(id,id,"^1[^3%s^1] [^4 R ^1+ ^3G ^1] tuşlarına basarak oyuncuları ^4soyabilirsiniz.",TAG)	

stock bool:Stuck(Id)
{
	static Float:Origin[3]
	pev(Id, pev_origin, Origin)
	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(Id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0)
	if (get_tr2(0, TR_StartSolid))
		return true
	return false
}



