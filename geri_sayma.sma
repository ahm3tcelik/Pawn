#include <amxmodx>

new g_gerisay

public plugin_init() 
{
	register_plugin("Geri Say","1.0","amad")
	register_clcmd("say", "cmd_say")
	register_clcmd("say_team", "cmd_say")

}
public cmd_say(id) 
{
	if(!is_user_alive(id)) return 0
	
	new Args[64]
	read_args(Args, charsmax(Args))
	remove_quotes(Args)

	new yazim[4], numaram[16]
	strtok(Args, yazim, charsmax(yazim), numaram, charsmax(numaram))
	
	if(equali(yazim, "/say") || equali(numaram, "!say"))
	{
		
		if(task_exists(999))
		{
			client_print_color(id,id,"Geri sayim zaten devam ediyor.")
			return 1
		}
		new cd
		cd= str_to_num(numaram)
		if(cd > 0)
		{
			g_gerisay = cd
			set_task(1.0,"geri_say",999,_,_,"b")
		}
		else client_print_color(id,id,"^40'^1dan buyuk bir deger girin.")
	}
	return 0
}

public geri_say(taskid)
{
	if(g_gerisay)
	{
		set_hudmessage(random(255), random(255), random(255), -1.0, 0.34, 1, 2.0, 0.9, _, _, -1)
		show_hudmessage(0, "< %d >", g_gerisay--)
	}
	else
	{
		remove_task(taskid)
		
		set_hudmessage(220, _, _, -1.0, 0.34, 1, 2.0, 1.0, _, _, -1)
		show_hudmessage(0, ".: Geri sayim sonra erdi :.")
	}
}