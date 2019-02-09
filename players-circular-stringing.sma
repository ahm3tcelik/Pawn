/* Sublime AMXX Editor v2.2 */
#pragma semicolon 1

#include <amxmodx>
#include <fun>
#include <fakemeta_util>

new cvar_dondur, cvar_dondur_sure;
new const TAG[] = "CSD";

/********************************************** Stuck *************************************************************************************************************************************************************************************************************/
// Stuck Plugin Author : NL)Ramon(NL

new stuck[33]; // 

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};
/*******************************************************************************************************************************************************************************************************************************************************************/

public plugin_init()
{
	register_plugin("Players-Circular Stringing","1.0","amad - NDOGAN");
	register_clcmd("say /daire", "diz");

	cvar_dondur = register_cvar("dairede_dondur","1");
	cvar_dondur_sure = register_cvar("dairede_dondur","5");

}
public diz(id) 
{
	if(get_user_team(id) != 2) 
	{
		client_print_color(id, id, "^1[^3%s^1] Bu komut ^4Gardiyanlara ^1ozeldir.",TAG);
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(id)) 
	{
		client_print_color(id, id, "^1[^3%s^1] Bu komut ^4Canlilara ^1ozeldir.",TAG);
		return PLUGIN_HANDLED;
	}
	if(is_aiming_at_sky(id))
	{
		client_print_color(id, id, "^1[^3%s^1] Hedefinizi ^4Gokyuzunde^1 tutmayiniz.",TAG);
		return PLUGIN_HANDLED;
	}

	new kordinat[3],yeni_kordinat[3],players[32],num;
	static cid;
	new r = 250;

	get_user_origin(id,kordinat,3);
	get_players(players,num,"ae","TERRORIST");
	
	if(num > 0)
	{
		for(new i=0;i<num;i++)
		{
			cid = players[i];
			yeni_kordinat[0] = kordinat[0] + floatround(floatsin(2 * M_PI * i / num, radian) * r, floatround_round);
			yeni_kordinat[1] = kordinat[1] + floatround(floatcos(2 * M_PI * i / num, radian) * r, floatround_round);
			yeni_kordinat[2] = kordinat[2] + 50;

			set_user_origin(cid,yeni_kordinat);
			checkStuck(cid);
			
			if(get_pcvar_num(cvar_dondur))
			{
				set_user_maxspeed(cid, 1.0);
				set_task(get_pcvar_float(cvar_dondur_sure),"end",cid);
			}
		}
	}
	return PLUGIN_CONTINUE;
}
public end(id)
{
	set_user_maxspeed(id,250.0);
}
public checkStuck(player) 
{
		static Float:origin[3];
		static Float:mins[3], hull;
		static Float:vec[3];
		static o;
		pev(player, pev_origin, origin);
		hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;
		if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT))
		{
			++stuck[player];
			pev(player, pev_mins, mins);
			vec[2] = origin[2];
			for (o=0; o < sizeof size; ++o) 
			{
				vec[0] = origin[0] - mins[0] * size[o][0];
				vec[1] = origin[1] - mins[1] * size[o][1];
				vec[2] = origin[2] - mins[2] * size[o][2];
				if (is_hull_vacant(vec, hull,player)) 
				{
					engfunc(EngFunc_SetOrigin, player, vec);
					effects(player);
					set_pev(player,pev_velocity,{0.0,0.0,0.0});
					o = sizeof size;
				}
			}
		}
		else
		{
			stuck[player] = 0;
		}
}
stock bool:is_hull_vacant(const Float:origin[3], hull,id) 
{
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true;
	
	return false;
}
stock bool:is_aiming_at_sky(id) // Author : AdaskoMX!
{
	new Float:origin[3];
	fm_get_aim_origin(id, origin);

	return engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY;
}
public effects(id) 
{
		message_begin(MSG_ONE_UNRELIABLE,105,{0,0,0},id );
		write_short(1<<10);  // fade lasts this long duration
		write_short(1<<10);   // fade lasts this long hold time
		write_short(1<<1);   // fade type (in / out)
		write_byte(20);          // fade red
		write_byte(255);    // fade green
		write_byte(255);       // fade blue
		write_byte(255);    // fade alpha
		message_end();
		client_cmd(id,"spk fvox/blip.wav");
}
