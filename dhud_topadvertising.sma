#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "Kg Gun reklam"
#define VERSION "2.0"
#define AUTHOR "Amad;Dhst." /* Version 1.0 Author :Sn!ffer. */

#define USERTASK 921
#define UPDATEDELAY 0.5


new rounds,g_elbasi=false,toplamoyuncu;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)	
	
	register_event("TextMsg","restart_roundsnum","a","2&#Game_C"/*,"2&#Game_w"*/) 
	
	register_logevent("round_end", 2, "1=Round_End")  
	register_logevent("elbasi", 2, "1=Round_Start");
	
	RegisterHam(Ham_Spawn, "player", "client_spawn", 1)
	
	toplamoyuncu = get_maxplayers()
}
public elbasi()
{
	g_elbasi = true
	set_task(5.0,"amad")
}
public amad()
	g_elbasi = false	
	
public round_end()
	rounds ++

public restart_roundsnum() 
	rounds = 0 

public client_disconnected(id)
{
	if(task_exists(id + USERTASK))
	{
		remove_task(id + USERTASK)
	}
}

public client_spawn(id)
{	
	if(task_exists(id + USERTASK))
	{
		remove_task(id + USERTASK)
	}	
	
	set_task(UPDATEDELAY, "client_jailinfo", id + USERTASK, _, _, "b")
}

public client_jailinfo(TASKID)
{
	static id
	id = TASKID - USERTASK
	
	new players[32], TNum, CTNum
	get_players(players, TNum, "aeh", "TERRORIST")
	get_players(players, CTNum, "aeh", "CT")
	
	if(g_elbasi)
	{
		
		new oyuncusayisi=0;
		new players[32], num, tempid;	
		get_players(players, num)
		for (new i=0; i<num; i++)
		{
			tempid = players[i]
			
			if (is_user_connected(tempid))
				oyuncusayisi++;	
		}
		new map[32],player;
		get_playersnum(player)
		get_mapname(map,31)
		
		set_dhudmessage(170, 170, 255, -1.0,0.18, 0, 6.0, 0.4);
		show_dhudmessage(id,"KAOS GAMING | GUN : %i^n^nHarita : %s - Sunucu : %d/%d",rounds,map,oyuncusayisi,toplamoyuncu)
		
		set_dhudmessage(255, 127, 0, -1.0,0.18, 0, 6.0, 0.4);
		show_dhudmessage(id ,"^nCS39.CSDURAGI.COM & TS112.CSDURAGI.INFO")
	}
	else 
	{
		
		if(is_user_alive(id))
		{
			new hostname[64]
			get_cvar_string("hostname", hostname, 63)
			set_dhudmessage(170, 170, 255, -1.0, 0.0, 0, 6.0, 0.4);
			show_dhudmessage(id ,"[%i]^n%s^nServer & TS3 IP : CS39.CSDURAGI.COM & TS112.CSDURAGI.INFO",rounds,hostname)

			set_dhudmessage(255, 0, 0, -1.0, 0.0, 0, 6.0, 0.4);
			show_dhudmessage(id ,"MAHKUM : %d                                    ",TNum)
	
			set_dhudmessage(0, 255, 255, -1.0, 0.0, 0, 6.0, 0.4);
			show_dhudmessage(id ,"                                     GARDIYAN : %d",CTNum)
		} 
		else 
		{
			if(get_user_flags(id) & ADMIN_RESERVATION)
			{
				set_dhudmessage(170, 170, 255, -1.0, 0.15, 1, 6.0, 0.4)
				show_dhudmessage(id, "KAOS GAMING | GUN : %i^n[ - Cumartesi Gunu Saat 21:00'da Toplantimiz Vardir. Katilim Zorunludur. - ]",rounds)
				set_dhudmessage(255, 0, 0, -1.0, 0.15, 0, 6.0, 0.4)
				show_dhudmessage(id, "MAHKUM : %i                                                             ",TNum)
				set_dhudmessage(0, 255, 255, -1.0, 0.15, 0, 6.0, 0.4)
				show_dhudmessage(id, "                                                              GARDIYAN : %i",CTNum)
			} 
			else 
			{
				set_dhudmessage(170, 170, 255, -1.0, 0.15, 1, 6.0, 0.4)
				show_dhudmessage(id, "KAOS GAMING | GUN : %i^n[ - Sende Ailemize Katilmak Istersen say'a [/TS3] Yazarak Katilabilirsin. - ]",rounds)
				set_dhudmessage(255, 0, 0, -1.0, 0.15, 0, 6.0, 0.4)
				show_dhudmessage(id, "MAHKUM : %i                                                             ",TNum)
				set_dhudmessage(0, 255, 255, -1.0, 0.15, 0, 6.0, 0.4)
				show_dhudmessage(id, "                                                              GARDIYAN : %i",CTNum)
			}
		}
	}
}
