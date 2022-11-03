#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <zombieplague>
#define PLUGIN "Saat Cvar"
#define VERSION "1.0"
#define AUTHOR "DPCS"
new suankimap[250]
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_logevent("ElBasi",2,"1=Round_Start")
	register_cvar("freevip_manuel","0")
	register_event("HLTV", "Cephane", "a", "1=0", "2=0")
}

public ElBasi()
{
	new saat[6], dakika[6]
	get_time("%H", saat, 5)
	get_time("%M", dakika, 5)
	new cevir_saat = str_to_num(saat)
	new cevir_dakika = str_to_num(dakika)
	get_mapname(suankimap,249)
	if((cevir_saat>=22 && cevir_saat<24) || (cevir_saat>=0 && cevir_saat<9) || get_cvar_num("freevip_manuel"))
	{
		set_cvar_num("freevip_hour",1)
		set_cvar_num("zp_human_speed",240)
		set_cvar_num("escape_xp_amount_human",540)
		set_cvar_num("escape_xp_amount_zombie",540)
		renkli_yazi(0,"!g[ZE] !nDoubleXP and Vip Features !t-> !gACTIVE!")
		renkli_yazi(0,"!g[ZE] !nDoubleXP and Vip Features !t-> !gACTIVE!")
		renkli_yazi(0,"!g[ZE] !nDoubleXP and Vip Features !t-> !gACTIVE!")
		if((contain(suankimap, "de_") != -1) || (contain(suankimap, "cs_") != -1) || (contain(suankimap, "big_") != -1))
		{
			server_cmd("hostname ^"[FreeVIP + x6EXP]| All Star | Zombie Escape | NEMESIS MOD!^"")
		}
		else
		{
			server_cmd("hostname ^"[FreeVIP + x6EXP]| All Star | Zombie Escape | AS | [TR]^"")
		}
	}
	else
	{
		set_cvar_num("freevip_hour",0)
		set_cvar_num("zp_human_speed",260)
		set_cvar_num("escape_xp_amount_human",360)
		set_cvar_num("escape_xp_amount_zombie",360)
	}
	if((cevir_saat == 1 || cevir_saat == 12 || cevir_saat == 20) && (cevir_dakika >= 0 && cevir_dakika < 20) && !(contain(suankimap, "de_") != -1) 
	&& !(contain(suankimap, "cs_") != -1) && !(contain(suankimap, "big_") != -1))
	{
		server_cmd("amx_votemap cs_assault_1337 de_westwood de_dust")
	}
}

public Cephane()
{
	new players[32],inum,id
	get_players(players,inum)
	for(new i;i<inum;i++)
	{
		id = players[i]
		get_mapname(suankimap,249)
		if((contain(suankimap, "de_") != -1) || (contain(suankimap, "cs_") != -1) || (contain(suankimap, "big_") != -1))
		{
			new current_ammopacks = zp_get_user_ammo_packs(id)
			zp_set_user_ammo_packs(id, current_ammopacks + 999)
			
			renkli_yazi(id,"!g[ZE] !tHesabina !g999CP !teklendi.")
			renkli_yazi(id,"!g[ZE] !tAdded !g999AP !tto your account.")
			renkli_yazi(id,"!g[ZE] !tHesabina 999CP !teklendi.")
			renkli_yazi(id,"!g[ZE] !tAdded !g999AP !tto your account.")
			renkli_yazi(id,"!g[ZE] !tHesabina 999CP !teklendi.")
			renkli_yazi(id,"!g[ZE] !tAdded !g999AP !tto your account.")
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
