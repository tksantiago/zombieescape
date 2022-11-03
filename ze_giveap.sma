#include <amxmodx>
#include <amxmisc>
#include <zombieplague>

public plugin_init()
{
	register_plugin("Give Ap", "1.0", "DPCS")
	
	register_clcmd("amx_giveap", "give_ap", ADMIN_LEVEL_B, "<authid, nick or #userid>")
	register_clcmd("amx_apver", "ap_ver", ADMIN_RCON, "")
}

public give_ap(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32], arg2[5], arg3[3]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	read_argv(3, arg3, charsmax(arg3))
	
	if(arg3[0])
		return PLUGIN_HANDLED
	
	new player = cmd_target(id, arg, charsmax(arg))
	if(!player)
		return PLUGIN_HANDLED
	
	new sPlayer[2]
	sPlayer[0] = player
	
	new adminname[32], playername[32]
	get_user_name(id, adminname, 31)
	get_user_name(player, playername, 31)
	if(id == player)
	{
		new current_ammopacks = zp_get_user_ammo_packs(player)
		zp_set_user_ammo_packs(player, current_ammopacks + str_to_num(arg2))
		renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Admin Kendisine !n[ !t%d !n] CP Verdi.", adminname, str_to_num(arg2))
	}
	else if(get_user_flags(id) & ADMIN_RCON)
	{
		new current_ammopacks = zp_get_user_ammo_packs(player)
		zp_set_user_ammo_packs(player, current_ammopacks + str_to_num(arg2))
		renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Admin !n[ !t%s !n] Adli Oyuncucuya !n[ !t%d !n] CP Verdi.", adminname, playername, str_to_num(arg2))
	}
	
	return PLUGIN_HANDLED
}

public ap_ver(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[5], arg2[3]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	
	if(arg2[0])
		return PLUGIN_HANDLED
	
	new players[32], inum, di
	get_players(players, inum)
	for(new i;i<inum;i++)
	{
		di = players[i]
		new current_ammopacks = zp_get_user_ammo_packs(di)
		zp_set_user_ammo_packs(di, current_ammopacks + str_to_num(arg))
	}
	
	new adminname[32]
	get_user_name(id,adminname,31)
	renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Admin Butun Oyunculara !n[ !t%d !n] CP Hediye Etti!!", adminname, str_to_num(arg))
	renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Admin Butun Oyunculara !n[ !t%d !n] CP Hediye Etti!!", adminname, str_to_num(arg))
	renkli_yazi(0,"!g[DPCS] !n[ !t%s !n] Adli Admin Butun Oyunculara !n[ !t%d !n] CP Hediye Etti!!", adminname, str_to_num(arg))
	
	return PLUGIN_HANDLED
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