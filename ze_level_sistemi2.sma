#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <levels>
#include <nvault>
#include <zombieplague>

#define MAXLEVEL 71

new const LEVELS[MAXLEVEL] = { 
90, // Needed on level 1
180, // Needed on level 2
300, // Needed on level 3
450, // Needed on level 4
700, // Needed on level 5
1200, // Needed on level 6
1800, // Needed on level 7
2800, // Needed on level 8
4100, // Needed on level 9
5200, // Needed on level 10
6000, // Needed on level 11
6800, // Needed on level 12
8200, // Needed on level 13
10200, // Needed on level 14
12000, // Needed on level 15
15000, // Needed on level 16
17500, // Needed on level 17
20500, // Needed on level 18
25500, // Needed on level 19
29000, // Needed on level 20
35000, // Needed on level 21
46000, // Needed on level 22
58000, // Needed on level 23
71000, // Needed on level 24
85000, // Needed on level 25
100000, // Needed on level 26
116000, // Needed on level 27
133000, // Needed on level 28
151000, // Needed on level 29
170000, // Needed on level 30
190000, // Needed on level 31
211000, // Needed on level 32
233000, // Needed on level 33
256000, // Needed on level 34
280000, // Needed on level 35
305000, // Needed on level 36
331000, // Needed on level 37
358000, // Needed on level 38
386000, // Needed on level 39
415000, // Needed on level 40
445000, // Needed on level 41
476000, // Needed on level 42
508000, // Needed on level 43
541000, // Needed on level 44
575000, // Needed on level 45
610000, // Needed on level 46
646000, // Needed on level 47
683000, // Needed on level 48
721000, // Needed on level 49
760000, // Needed on level 50
800000, // Needed on level 51
842000, // Needed on level 52
886000, // Needed on level 53
974000, // Needed on level 54
1020000, // Needed on level 55
1068000, // Needed on level 56
1118000, // Needed on level 57
1170000, // Needed on level 58
1224000, // Needed on level 59
1280000, // Needed on level 60
1338000, // Needed on level 61
1398000, // Needed on level 62
1460000, // Needed on level 63
1524000, // Needed on level 64
1590000, // Needed on level 65
1658000, // Needed on level 66
1728000, // Needed on level 67
1800000, // Needed on level 68
1874000, // Needed on level 69
1950000, // Needed on level 70
9999999 // Needed on level 71
}; // Needed Xp on each Levels

new PlayerXp[33]
new PlayerLevel[33]

new g_Vault
new savexp, save_type, escape_xp_human, escape_xp_zombie

public plugin_init()
{
	register_plugin("Level Sistemi", "1.0", "DPCS")

	save_type = register_cvar("levels_savetype","0") // Save Xp to : 0 = NVault.
	savexp = register_cvar("levels_save","1") // Save Xp by : 2 = Name, 1 = SteamID, 0 = IP.
	escape_xp_human = register_cvar("escape_xp_amount_human", "90") // How much XP given to Humans when escape success?
	escape_xp_zombie = register_cvar("escape_xp_amount_zombie", "45") // How much XP given to Humans when escape success?
	
	register_event("HLTV", "elbasi", "a", "1=0", "2=0")
	register_clcmd("amx_levelmenu", "levelmenu")
	register_clcmd("amx_levelver", "level_ver", ADMIN_RCON, "<authid, nick or #userid>")
}

public elbasi()
{
	new players[32],inum,id
	get_players(players,inum)
	for(new i;i<inum;i++)
	{
		id = players[i]
		
		new current_ammopacks = zp_get_user_ammo_packs(id)
		if(get_user_level(id) >= 10 && get_user_level(id) <= 19)
		{
			zp_set_user_ammo_packs(id, current_ammopacks + 5)
			renkli_yazi(id,"!g[ZE] !nHesabina !t5CP !neklendi.")
			renkli_yazi(id,"!g[ZE] !nAdded !t5AP !nto your account.")
		}
		else if(get_user_level(id) >= 20 && get_user_level(id) <= 29)
		{
			zp_set_user_ammo_packs(id, current_ammopacks + 10)
			renkli_yazi(id,"!g[ZE] !nHesabina !t10CP !neklendi.")
			renkli_yazi(id,"!g[ZE] !nAdded !t10AP !nto your account.")
		}
		else if(get_user_level(id) >= 30)
		{
			zp_set_user_ammo_packs(id, current_ammopacks + 15)
			renkli_yazi(id,"!g[ZE] !nHesabina !t15CP !neklendi.")
			renkli_yazi(id,"!g[ZE] !nAdded !t15AP !nto your account.")
		}
	}
}

// Level sifirlama
public levelmenu(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
	{
		static amenu[512]
		formatex(amenu,charsmax(amenu),"\yLevel Sifirlama icin oyuncu sec")
		new menuz = menu_create(amenu,"silmemenu_devam")
		
		new players[32], tempid, pnum
		new szName[32], szTempid[10]
		get_players(players, pnum)
		
		for(new i; i < pnum; i++)
		{
			tempid = players[i]
			if(is_user_connected(tempid) && !is_user_bot(tempid))
			{
				get_user_name(tempid, szName, 31)
				num_to_str(tempid, szTempid, 9)
				
				formatex(amenu, charsmax(amenu), "\w%s", szName)
				menu_additem(menuz, amenu, szTempid)
			}
		}
		
		menu_setprop(menuz,MPROP_EXIT,MEXIT_ALL)
		menu_display(id,menuz,0)
	}
	
	return PLUGIN_HANDLED
}

public silmemenu_devam(id,menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new access,callback,data[6],iname[64]
	
	menu_item_getinfo(menu,item,access,data,5,iname,63,callback)
	
	new tempid = str_to_num(data)
	
	silmeislem(id, tempid)
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public silmeislem(id, player) {
	if (!player)
	return PLUGIN_HANDLED
	
	set_user_xp(player, 0)
	set_user_level(player, 0)
	SaveLevel(player)
	
	return PLUGIN_HANDLED
}

// Level verme
public level_ver(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32], arg2[10], arg3[3]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	read_argv(3, arg3, charsmax(arg3))
	
	if(arg3[0])
		return PLUGIN_HANDLED
	
	new player = cmd_target(id, arg, charsmax(arg))
	if(!player)
		return PLUGIN_HANDLED
	
	set_user_xp(player, str_to_num(arg2))
	SaveLevel(player)
	check_level(player)
	
	return PLUGIN_HANDLED
}

public plugin_cfg()
{
	//Open our vault and have g_Vault store the handle.
	g_Vault = nvault_open("levels")

	//Make the plugin error if vault did not successfully open
	if ( g_Vault == INVALID_HANDLE )
		set_fail_state( "Error opening levels nVault, file does not exist!" )
}

public plugin_precache()
{
	precache_sound("ze_dp/ze_levelup.wav")
}

public plugin_natives()
{
	register_native("get_user_xp", "native_get_user_xp", 1)
	register_native("set_user_xp", "native_set_user_xp", 1)
	register_native("get_user_level", "native_get_user_level", 1)
	register_native("set_user_level", "native_set_user_level", 1)
	register_native("get_user_max_level", "native_get_user_max_level", 1)
}

public plugin_end()
{
	//Close the vault when the plugin ends (map change\server shutdown\restart)
	nvault_close(g_Vault)
}

public client_connect(id)
{
	LoadLevel(id)
}

public client_disconnected(id)
{
	SaveLevel(id)
	
	PlayerXp[id] = 0
	PlayerLevel[id] = 0
}

public zp_round_ended()
{
	new Alive_Terrorists_Number = GetPlayersNum(CsTeams:CS_TEAM_T)
	new Alive_CT_Numbers = GetPlayersNum(CsTeams:CS_TEAM_CT)
	
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ace", "CT")
	
	for (new i = 0; i < iNum; i++)
	{
		if(PlayerLevel[iPlayers[i]] < MAXLEVEL-1)
		{
			if((Alive_CT_Numbers > Alive_Terrorists_Number) && (Alive_Terrorists_Number == 0))
			{
				set_user_xp(iPlayers[i], get_user_xp(iPlayers[i]) + get_pcvar_num(escape_xp_human))
				SaveLevel(iPlayers[i])
			}
			else if((Alive_Terrorists_Number > Alive_CT_Numbers) && (Alive_CT_Numbers == 0))
			{
				set_user_xp(iPlayers[i], get_user_xp(iPlayers[i]) + get_pcvar_num(escape_xp_zombie))
				SaveLevel(iPlayers[i])
			}
			check_level(iPlayers[i])
		}
	}
}

public check_level(id)
{
	if(PlayerLevel[id] < MAXLEVEL-1)
	{
		while(PlayerXp[id] >= LEVELS[PlayerLevel[id]])
		{
			PlayerLevel[id]++
			SaveLevel(id)
			
			static name[32]
			get_user_name(id, name, charsmax(name))
			renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Oyuncu !n[ !t%i. !n] Level'e Ulasti.", name, PlayerLevel[id])
		}
	}
}

SaveLevel(id)
{
	new szAuth[33];
	new szKey[64];
	
	if (get_pcvar_num(savexp) == 0)
	{
		get_user_ip(id, szAuth , charsmax(szAuth), 1)
		formatex(szKey , 63 , "%s-IP" , szAuth)
	}
	else if (get_pcvar_num(savexp) == 1)
	{
		get_user_authid(id , szAuth , charsmax(szAuth))
		formatex(szKey , 63 , "%s-ID" , szAuth)
	}
	else if (get_pcvar_num(savexp) == 2)
	{
		get_user_name(id, szAuth , charsmax(szAuth))
		formatex(szKey , 63 , "%s-NAME" , szAuth)
	}
	
	if (!get_pcvar_num(save_type))
	{
		new szData[256]
		
		formatex(szData , 255 , "%i#%i#" , PlayerLevel[id], PlayerXp[id])
		
		nvault_pset(g_Vault , szKey , szData)
	}
}

LoadLevel(id)
{
	new szAuth[33];
	new szKey[40];
	
	if (get_pcvar_num(savexp) == 0)
	{
		get_user_ip(id, szAuth , charsmax(szAuth), 1)
		formatex(szKey , 63 , "%s-IP" , szAuth)
	}
	else if (get_pcvar_num(savexp) == 1)
	{
		get_user_authid(id , szAuth , charsmax(szAuth))
		formatex(szKey , 63 , "%s-ID" , szAuth)
	}
	else if (get_pcvar_num(savexp) == 2)
	{
		get_user_name(id, szAuth , charsmax(szAuth))
		formatex(szKey , 63 , "%s-NAME" , szAuth)
	}
	
	if (!get_pcvar_num(save_type))
	{
		new szData[256];
		
		formatex(szData , 255, "%i#%i#", PlayerLevel[id], PlayerXp[id])
		
		nvault_get(g_Vault, szKey, szData, 255)
		
		replace_all(szData , 255, "#", " ")
		new xp[32], level[32]
		parse(szData, level, 31, xp, 31)
		PlayerLevel[id] = str_to_num(level)
		PlayerXp[id] = str_to_num(xp)
	}
}

// Native: get_user_xp
public native_get_user_xp(id)
{
	return PlayerXp[id]
}

// Native: set_user_xp
public native_set_user_xp(id, amount)
{
	PlayerXp[id] = amount
}

// Native: get_user_level
public native_get_user_level(id)
{
	return PlayerLevel[id]
}

// Native: set_user_xp
public native_set_user_level(id, amount)
{
	PlayerLevel[id] = amount
}

// Native: Gets user level by Xp
public native_get_user_max_level(id)
{
	new gerilevel
	
	if(PlayerLevel[id] > (MAXLEVEL-1)) {
		gerilevel = LEVELS[MAXLEVEL-1]
	}
	else {
		gerilevel = LEVELS[PlayerLevel[id]]
	}
	
	return gerilevel
}

stock GetPlayersNum(CsTeams:iTeam) {
	new iNum
	for( new i = 1; i <= get_maxplayers(); i++ ) {
		if(is_user_connected(i) && is_user_alive(i) && cs_get_user_team(i) == iTeam)
			iNum++
	}
	return iNum
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
