#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

new TAG[] = "Kaos"
new g_amad;

public plugin_init ()
{
	register_plugin("Button Name", "1.0", "amad")
	RegisterHam(Ham_Use, "func_button", "basti", 1)
	
	g_amad = register_cvar("button_name", "1")
}
public  basti(button, basan)
{
	if(!get_pcvar_num(g_amad)) return 
	
	new bname[51],name[32]
	get_user_name(basan,name,charsmax(name))
	pev(button, pev_target, bname, charsmax(bname))
	client_print_color(0,0,"^1[^3%s^1] [^4%s^1] adli oyuncu ^3%s ^1butonuna basti.",TAG,name,bname)
}
492 136 123