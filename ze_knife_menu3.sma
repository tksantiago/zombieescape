#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

new gorunum[33]

new bicakmodel[][][] =
{
	{CSW_KNIFE,
	"models/dpcs_2k20_v2/knife/v_rain.mdl",
	"models/dpcs_2k20_v2/knife/v_blue.mdl",
	"models/dpcs_2k20_v2/knife/v_razor.mdl",
	"models/dpcs_2k20_v2/knife/v_ruyistick.mdl",
	"models/dpcs_2k20_v1/knife/v_huntsman.mdl",
	"models/dpcs_2k20_v2/knife/v_thanatos.mdl",
	"models/dpcs_2k20_v2/knife/v_wh.mdl",
	"models/dpcs_2k20_v1/knife/v_source.mdl",
	"models/dpcs_2k20_v2/knife/v_vip_motosierra.mdl",
	"models/dpcs_2k20_v2/knife/v_vip_dualaxe.mdl"	
	}
}

public plugin_init()
{
	register_plugin("Skin Menu", "1.0","Multipower")
	
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	
	register_clcmd("say /bicak","knifemenu")
	register_clcmd("say /knife","knifemenu")	
	register_clcmd("say_team /knife","knifemenu")
	register_clcmd("say_team /bicak","knifemenu")
}

public plugin_precache()
{
	precache_model(bicakmodel[0][1])
	precache_model(bicakmodel[0][2])
	precache_model(bicakmodel[0][3])
	precache_model(bicakmodel[0][4])
	precache_model(bicakmodel[0][5])
	precache_model(bicakmodel[0][6])
	precache_model(bicakmodel[0][7])
	precache_model(bicakmodel[0][8])
	precache_model(bicakmodel[0][9])	
	precache_model(bicakmodel[0][10])
}

public client_connect(id)
{
	gorunum[id] = 1
}

public knifemenu(id)
{
	new menuz;
	static amenu[512];
	formatex(amenu,charsmax(amenu),"\r[ZE] \yKnife Menu")
	menuz = menu_create(amenu,"knifemenu_devam")
	
	formatex(amenu,charsmax(amenu),"\wRain")
	menu_additem(menuz,amenu,"1")
	
	formatex(amenu,charsmax(amenu),"\wMaster Combat")
	menu_additem(menuz,amenu,"2")
	
	formatex(amenu,charsmax(amenu),"\wRazor")
	menu_additem(menuz,amenu,"3")
	
	formatex(amenu,charsmax(amenu),"\wRuyi-Stick")
	menu_additem(menuz,amenu,"4")
	
	formatex(amenu,charsmax(amenu),"\wHuntsman")
	menu_additem(menuz,amenu,"5")

	formatex(amenu,charsmax(amenu),"\wThanatos")
	menu_additem(menuz,amenu,"6")

	formatex(amenu,charsmax(amenu),"\wWar Hammer")
	menu_additem(menuz,amenu,"7")
	
	formatex(amenu,charsmax(amenu),"\wSource")
	menu_additem(menuz,amenu,"8")	

	if(is_user_admin(id))
	{
		formatex(amenu,charsmax(amenu),"\wMotosierra \y[Admin]")
	}
	else
	{
		formatex(amenu,charsmax(amenu),"\dMotosierra \r[Admin]")
	}		
	menu_additem(menuz,amenu,"9")

	if(is_user_admin(id))
	{
		formatex(amenu,charsmax(amenu),"\wDual Axe \y[Admin]")
	}
	else
	{
		formatex(amenu,charsmax(amenu),"\dDual Axe \r[Admin]")
	}		
	menu_additem(menuz,amenu,"10")
	
	menu_setprop(menuz,MPROP_EXIT,MEXIT_ALL)
	menu_display(id,menuz,0)
	
	return PLUGIN_HANDLED
}

public knifemenu_devam(id,menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new access,callback,data[6],iname[64]
	
	menu_item_getinfo(menu,item,access,data,5,iname,63,callback)
	
	new key = str_to_num(data)
	
	if(key == 1)
	{
		gorunum[id] = 1
	}
	else if(key == 2)
	{
		gorunum[id] = 2
	}
	else if(key == 3)
	{
		gorunum[id] = 3
	}
	else if(key == 4)
	{
		gorunum[id] = 4
	}
	else if(key == 5)
	{
		gorunum[id] = 5
	}
	else if(key == 6)
	{
		gorunum[id] = 6
	}
	else if(key == 7)
	{
		gorunum[id] = 7
	}
	else if(key == 8)
	{
		gorunum[id] = 8
	}
	else if(key == 9)
	{
		if(is_user_admin(id))
		{
			gorunum[id] = 9
		}
		else
		{
			renkli_yazi(id, "!g[ZE]!t Yetkin Yok. !g|| !tOnly For VIPS.")
			knifemenu(id)
		}
	}
	else if(key == 10)
	{
		if(is_user_admin(id))
		{
			gorunum[id] = 10
		}
		else
		{
			renkli_yazi(id, "!g[ZE]!t Yetkin Yok. !g|| !tOnly For VIPS.")
			knifemenu(id)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public CurrentWeapon(id)
{
	replace_weapon_models(id, read_data(2))
}

replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_KNIFE:
		{
			if(!zp_get_user_zombie(id))
			{
				set_pev(id, pev_viewmodel2, bicakmodel[0][gorunum[id]][0])
			}
		}
	}
}

stock renkli_yazi(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, sizeof(msg) - 1, input, 3)
	
	replace_all(msg, 190, "!n", "^x01")
	replace_all(msg, 190, "!g", "^x04")
	replace_all(msg, 190, "!t", "^x03")
	
	if(id) players[0] = id; else get_players(players, count, "ch")
	for(new i = 0; i < count; i++)
	{
		if(is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
