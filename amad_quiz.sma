#include <amxmodx>
#include <amxmisc>
#include <jail>

new  odul, aralik;
new bool:cevaplar;
new s_cevap1[8],s_cevap2[8];
new islemler[3],sayilar[3],sonuc;

// v1 Author : alex
// v2 Author : Doruk

public plugin_init() 
{
	register_plugin("Islemi Bul","3.0","amad")
	register_clcmd("say","hooksay");
	odul = register_cvar("amx_quizodul","10"); 
	aralik = register_cvar("amx_quizsure","50.0");
	
	set_task(30.0,"sorusor");
}

public hooksay(id)
{
	new szSay[25]
	read_args(szSay, charsmax(szSay))
	remove_quotes(szSay)
	
	if(szSay[0] == '/' ||(szSay[0] == '!'))
	{
		new szCommand[7], szCevap1[8],szCevap2[8],szname[32];
		parse(szSay,szCommand, charsmax(szCommand), szCevap1, charsmax(szCevap1), szCevap2, charsmax(szCevap2));
		
		if((equal(szCommand, "/cevap") || equal(szCommand, "!cevap")) && !cevaplar)
		{
			if(equal(szCevap1,s_cevap1) && equal(szCevap2,s_cevap2))
			{
				get_user_name(id,szname, charsmax(szname));
				client_cmd(id,"spk ^"events/enemy_died^"")
				client_print_color(id, id, "^3[^4Soru^3] ^4%s ^1soruyu dogru bildi ve ^4%d TL ^1kazandi.", szname, get_pcvar_num(odul));
				jb_set_user_packs(id,jb_get_user_packs(id) + get_pcvar_num(odul));
				remove_task(1051);
				set_task(get_pcvar_float(aralik),"sorusor",1050);
				cevaplar = true;
			}
			else client_print_color(id,id,"^3[^4Soru^3] ^1Maalesef cevabiniz ^4Yanlis!");
		}
	}
}

public surebitti()
{
	client_print_color(0,0,"^3[^4Soru^3] Sure bitti, kimse cevabi bilemedi.");
	client_print_color(0,0,"^3[^4Soru^3] Cevap : %s %s",s_cevap1,s_cevap2);
	client_print_color(0,0,"^3[^4Soru^3] ^1Yeni soru ^4%d ^1saniye icerisinde hazirlanacak...", get_pcvar_num(aralik));
	set_task(get_pcvar_float(aralik),"sorusor",1050);
	cevaplar = true;
}
public cevap()
{
	switch(islemler[0])
	{
		case 0: s_cevap1 = "toplama";
		case 1: s_cevap1 = "cikarma";
		case 2: s_cevap1 = "carpma";
	}
	switch(islemler[1])
	{
		case 0: s_cevap2 = "toplama";
		case 1: s_cevap2 = "cikarma";
		case 2: s_cevap2 = "carpma";
	}
	console_print(0,"%s %s",s_cevap1,s_cevap2);
}

public sorusor()
{
	new sag=0,sol =0;
	cevaplar = false;
	
	for(new i=0;i<3;i++)
		sayilar[i] = random_num(1,100);
	for(new j=0;j<3;j++)
		islemler[j] = random_num(0,2);
	
	if(islemler[0] != 2 && islemler[1] == 2)
	{
		sag = sayilar[1] * sayilar[2];
		switch(islemler[0])
		{
			case 0: sonuc = sayilar[0] + sag;
			case 1: sonuc = sayilar[0] - sag;     
		}     
	}
	else
	{
		switch(islemler[0])
		{
			case 0: sol = sayilar[0] + sayilar[1];
			case 1: sol = sayilar[0] - sayilar[1];
			case 2: sol = sayilar[0] * sayilar[1];
		}
		switch(islemler[1])
		{
			case 0: sonuc = sol + sayilar[2];
			case 1: sonuc = sol - sayilar[2];
			case 2: sonuc = sol * sayilar[2];
		}
	}
	cevap();
	client_print_color(0,0,"^1[^3Soru^1] ^4%d ^3[ ] ^4%d ^3[ ] ^4%d ^1= ^4%i",sayilar[0],sayilar[1],sayilar[2],sonuc);
	set_task(7.0,"tekrar",_,_,_,"a",5);
	client_print_color(0,0,"^1[^3Soru^1] Aradaki islemleri bul,odulu kap. ^nOrnek Cevap : ^3/cevap ^4toplama cikarma^1, ^3/cevap ^4cikarma carpma...",sayilar[0],sayilar[1],sayilar[2],sonuc);
	set_task(get_pcvar_float(aralik),"surebitti",1051);
}
public tekrar()
{
	if(!cevaplar) client_print_color(0,0,"^1[^3Soru^1] ^4%d ^3[ ] ^4%d ^3[ ] ^4%d ^1= ^4%i",sayilar[0],sayilar[1],sayilar[2],sonuc); 
}