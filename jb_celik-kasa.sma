/* Sublime AMXX Editor v2.2 */

#include <amxmodx>
#include <amxmisc>
#include <jail>

new bool:kilitli=false,ucret,g_name[32],kasa_hane,kasa_baslangic,sifre,para,h_deneme=0,g_deneme[33],engel,g_engel[33],ipucu[33],say_reklam

new const TAG[] = "Kaos"

public plugin_init()
{
	register_plugin("[JB] Celik Kasa","1.0","amad")
	register_clcmd("say /box","box")
	register_clcmd("say /kasa","box")
	register_clcmd("PW_GIR","kontrol")
	
	register_event("HLTV", "elbasi", "a", "1=0", "2=0")
	
	engel = register_cvar("kasa_koruma","1")
	ucret = register_cvar("kasa_ucret","1")
	kasa_hane = register_cvar("kasa_hane","3")
	kasa_baslangic = register_cvar("kasa_baslangic","0")
	say_reklam = register_cvar("kasa_bilgi","1")
}
public plugin_precache()
{
	precache_sound("buttons/button2.wav")
	precache_sound("buttons/button3.wav")
}
public elbasi()
{
	if(kilitli)
	{
		client_print_color(0,0,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresini henüz çözen yok. ^3%d TL ^1karşılığında şansını deneyebilirsin. [^4/box^1]",TAG,get_pcvar_num(ucret))
		client_print_color(0,0,"^1[^3%s^1] ^4UNUTMA! ^1Şifreyi çözen kasadaki tüm parayı alır. Şu anki para : ^4%d TL",TAG,para)
	}
	else 
	{
		set_task(3.0,"create")
	}
	return 0
}
public create()
{
	switch(get_pcvar_num(kasa_hane))
	{
		case 2: 
		{
			sifre = random_num(10, 99)
			client_print_color(0,0,"^1[^3%s^1] Yeni bir çelik kasa oluşturuldu. Şifreyi çözen kasadaki tüm parayı alır. ^3Şifre ^1: [^4##^1]",TAG)
		}
		case 3: 
		{
			sifre = random_num(100,999)
			client_print_color(0,0,"^1[^3%s^1] Yeni bir çelik kasa oluşturuldu. Şifreyi çözen kasadaki tüm parayı alır. ^3Şifre ^1: [^4###^1]",TAG)	
		}
		case 4: 
		{
			sifre = random_num(1000,9999)
			client_print_color(0,0,"^1[^3%s^1] Yeni bir çelik kasa oluşturuldu. Şifreyi çözen kasadaki tüm parayı alır. ^3Şifre ^1: [^4####^1]",TAG)
		}
	}
	h_deneme = 0
	kilitli = true
	para = get_pcvar_num(kasa_baslangic)
}
public box(id)
{
	if(get_pcvar_num((engel)) && g_engel[id])
	{
		client_print_color(id,id,"^1[^3%s^1] Bu menuye Oyuna girdikten^4 60 Saniye ^3sonra ^1giriş yapabilirsiniz.",TAG)
		return PLUGIN_HANDLED
	}
	if(!kilitli)
	{
		client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1 henüz oluşturulmadı. ^1Bir sonraki roundu bekleyin.",TAG)
		return PLUGIN_HANDLED
	}
	new menuz;
	static amenu[512];
	formatex(amenu,charsmax(amenu),"\r%s Gaming \w|| \yÇelik Kasa^n\wKasadaki Para: \r%d TL^n\wŞifre Denemeleri [Herkes & Siz]: \r{%d}\y & \r{%d}",TAG,para,h_deneme,g_deneme[id])
	menuz = menu_create(amenu,"box_handler")
	
	formatex(amenu,charsmax(amenu),"\r%s \w|| \yŞifre Dene [\r%d TL\y]",TAG,get_pcvar_num(ucret))
	menu_additem(menuz,amenu,"1")
	formatex(amenu,charsmax(amenu),"\r%s \w|| \yŞifre Bilgi",TAG)
	menu_additem(menuz,amenu,"2")

	if(para >= 50)
	{
		formatex(amenu,charsmax(amenu),"\r%s \w|| \yŞifre İpucu (Son Basamak) [\r%d TL\y]",TAG,para/2+20)
		menu_additem(menuz,amenu,"3")
	}
	else
	{
		formatex(amenu,charsmax(amenu),"\d%s || Şifre İpucu (Son Basamak)",TAG)
		menu_additem(menuz,amenu,"4")
	}
	menu_setprop(menuz,MPROP_EXIT,MEXIT_ALL)
	menu_display(id,menuz,0)
	
	return PLUGIN_CONTINUE
	
}
public box_handler(id,menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new access,callback,data[6],iname[64]
	menu_item_getinfo(menu,item,access,data,5,iname,63,callback)
	
	switch(str_to_num(data))
	{
		case 1:
		{
			if(jb_get_user_packs(id) >= get_pcvar_num(ucret))
			{
				jb_set_user_packs(id,jb_get_user_packs(id) - get_pcvar_num(ucret))
				para += get_pcvar_num(ucret)
				client_cmd(id,"messagemode PW_GIR")
			}
			else 
			{
				client_print_color(id,id,"^1[^3%s^1] Malesef yeterli paranız yok.",TAG,get_pcvar_num(kasa_hane))
			}
		}
		case 2:
		{
			client_print_color(id,id,"^1[^3%s^1] Şifre, ^4%d ^1haneli bir doğal sayıdan oluşmaktadır.",TAG,get_pcvar_num(kasa_hane))
			box(id)
		}
		case 3:
		{
			new kalan = sifre%10
			if(ipucu[id])
			{
				client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresinin son basamağı: [^4 %d ^1].",TAG,kalan)
				client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresinin son basamağı: [ ^4%d ^1].",TAG,kalan)
			}
			else
			{
				if(jb_get_user_packs(id) >= 50)
				{
					jb_set_user_packs(id,jb_get_user_packs(id) - para/2+20)
					ipucu[id] = true
					client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresinin son basamağı: [ ^4%d ^1].",TAG,kalan)
					client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresinin son basamağı: [ ^4%d ^1].",TAG,kalan)
				}
				else 
				{
					client_print_color(id,id,"^1[^3%s^1] ^4Malesef ^1yeterli paraniz yok.",TAG)
				}
			}
			box(id)
		}
		case 4:
		{
			client_print_color(id,id,"^1[^3%s^1] ^4İpucucunu, kasada en az^3 50 TL^1 biriktikten sonra kullanabilirsiniz.",TAG)
			box(id)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public kontrol(id)
{
	new number[128];
	read_args(number, charsmax(number))
	remove_quotes(number)

	if(str_to_num(number) == sifre)
	{
		//doğru
		get_user_name(id,g_name,charsmax(g_name))
		/* bitiş...........................................................................*/

		kilitli = false
		jb_set_user_packs(id,jb_get_user_packs(id) + para)
		emit_sound(id, CHAN_AUTO, "buttons/button3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		client_print_color(id,id,"^1[^3%s^1] ^4Tebrikler! ^1Şifreyi doğru bularak kasadaki [ ^3%d^1 ] ^3TL^1'nin sahibi oldunuz.",TAG,para)
		client_print_color(0,0,"^1[^3%s^1] ^4%s ^1Adli Oyuncu ^4%d^1. denemenin sonunda kasanın şifresini çözerek ^4%d^1 TL'nin sahibi oldu. Şifre : %d",TAG,g_name,g_deneme[id],para,str_to_num(number))
		new players[32],inum;
		get_players(players,inum)
		for(new i;i<inum;i++)
		{
			g_deneme[players[i]] = 0
			ipucu[players[i]] = false
		}
		h_deneme = 0
	}
	else 
	{
		//yanlış
		
		emit_sound(id, CHAN_AUTO, "buttons/button2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		h_deneme++
		g_deneme[id]++
	}
	return PLUGIN_CONTINUE
}
public client_putinserver(id) 
{
	g_deneme[id] = 0
	ipucu[id] = false
	g_engel[id] = 1
	if(get_pcvar_num(say_reklam)) set_task(150.0, "Amad",id , _, _, "b")
	if(get_pcvar_num(engel)) set_task(60.0,"aktifet",id)
}
public Amad(id)
{
	if(kilitli)
	{
		client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresini henüz çözen yok. Kasada biriken para [^3 %d TL ^1]",TAG,para)
		client_print_color(id,id,"^1[^3%s^1] ^3UNUTMA! ^1Şifreyi çözen kasadaki tüm parayı alır. [^4/kasa ^1& ^4/box^1] ",TAG)
	}
}
public aktifet(id)
{
	g_engel[id] = 0
	client_print_color(id,id,"^1[^3%s^1]^4 60 saniyelik ^4Çelik Kasa ^1koruma süresi doldu.")
	if(kilitli)
	{
		client_print_color(id,id,"^1[^3%s^1] ^4Çelik Kasa^1'nın şifresini henüz çözen yok. ^3%d TL ^1karşılığında şansını deneyebilirsin. [^4/box^1]",TAG,get_pcvar_num(ucret))
		client_print_color(id,id,"^1[^3%s^1] ^4UNUTMA! ^1Şifreyi çözen kasadaki tüm parayı alır. Şu anki para : ^4%d TL",TAG,para)
	}
}