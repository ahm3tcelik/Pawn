#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

new TAG[] = "Kaos"
new g_amad,slay;

public plugin_init ()
{
	register_plugin("Zehri Acan Kim?", "2.0", "amad")
	RegisterHam(Ham_Use, "func_button", "basti", 1)
	g_amad = register_cvar("show_zehir", "1")
	slay = register_cvar("slay_zehir", "1")
}
public  basti(button, basan)
{
	if(!get_pcvar_num(g_amad) ||  get_user_team(basan) != 1)  return
	
	new bname[51],name[32]
	get_user_name(basan,name,charsmax(name))
	pev(button, pev_target, bname, charsmax(bname))
	
	if (contain(bname, "renk") != -1 || contain(bname,"zehir") !=-1)
	{	
		if(get_pcvar_num(slay))
		{
			user_kill(basan)
			client_print_color(basan,basan,"^1[^3%s^1] Kafesin zehrini actiginiz icin ^4olduruldunuz.",TAG)
		}
		client_print_color(0,0,"^1[^3%s^1] [^4%s^1] adli oyuncu ^4kafesin zehrini ^1acti.",TAG,name)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
