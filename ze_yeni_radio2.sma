
/* AMX Mod X
*   Custom Radio Commands
*
* (c) Copyright 2007 by KaLoSZyFeR
*
* This file is provided as is (no warranties)
*
*     DESCRIPTION
*       Plugin changes old and adds new customizable menu, allow hear custom radio
*	commands, also included something like VEN's Real Radio
*
*     FEATURES
*       - custom radio commands (sounds and messages)
*	- custom menus
*       - real radio effect
*
*
*     CVARS
*	amx_custom_radio (0: OFF, 1: ON, default: 1) - disables/enables plugin (version 0.6+)
*       amx_real_radio (0: OFF, 1: ON, default: 1) - disables/enables real radio effect
*	amx_radio_info (0: OFF, 1: ON, default: 1) - disables/enables viewing info about
*						     plugin on start of server
*
*     VERSIONS
*       0.3   first release
*	0.4   menu and messages now are customizable
*	0.5   color of menu is customizable
*	0.6   now message 'Fire in the hole!' can be changed, also added support of quick
*	      commands such as: 'coverme', 'go', 'roger' etc. Added new cvar (amx_custom_radio).
*
*/

// DODAC CVAR

#include <amxmodx> 
#include <amxmisc>
#include <engine>
#include <csx>
#include <fakemeta>


#define PLUGIN "Custom Radio Commands"
#define VERSION "0.6"
#define AUTHOR "KaLoSZyFeR"


new g_RadioTimer[33]

/* CONFIG SETUP */
new CRcoverme[64]
new CRtakepoint[64]
new CRhposition[64]
new CRregroup[64]
new CRfollowme[64]
new CRfireassis[64]

new CRgo[64]
new CRfallback[64]
new CRsticktog[64]
new CRgetinpos[64]
new CRstormfront[64]
new CRreportin[64]

new CRroger[64]
new CRenemys[64]
new CRbackup[64]
new CRclear[64]
new CRposition[64]
new CRreportingin[64]
new CRgetoutblow[64]
new CRnegative[64]
new CRenemydown[64]

new CRexit[64]
new CRcolortitle[2]
new CRcolormenu[2]

//version 0.6
new CRfireinhole[64]

// Radio1 wav files 
stock const radio1_spk[6][] ={   
	"radio/dpcs2k20/ct_coverme.wav", 
	"radio/dpcs2k20/takepoint.wav", 
	"radio/dpcs2k20/position.wav", 
	"radio/dpcs2k20/regroup.wav", 
	"radio/dpcs2k20/followme.wav", 
	"radio/dpcs2k20/fireassis.wav" 
} 


public radio1(id) {   // Client used Radio1 commands 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	// What Radio1 menu will look like
	new key1 = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)
		
	new menu_body1[512]
	new len1 = format(menu_body1,511,"\%sRadio Commands A\%s^n\ ", CRcolortitle, CRcolormenu)
	len1 += format( menu_body1[len1], 511-len1, "^n\ " )
	len1 += format( menu_body1[len1], 511-len1, "1. %s^n\ ", CRcoverme)
	len1 += format( menu_body1[len1], 511-len1, "2. %s^n\ ", CRtakepoint)
	len1 += format( menu_body1[len1], 511-len1, "3. %s^n\ ", CRhposition)
	len1 += format( menu_body1[len1], 511-len1, "4. %s^n\ ", CRregroup)
	len1 += format( menu_body1[len1], 511-len1, "5. %s^n\ ", CRfollowme)
	len1 += format( menu_body1[len1], 511-len1, "6. %s^n\ ", CRfireassis)
	len1 += format( menu_body1[len1], 511-len1, "^n\ " )
	len1 += format( menu_body1[len1], 511-len1, "0. %s", CRexit)
	show_menu(id,key1,menu_body1) // Show the above menu on screen 
	return PLUGIN_HANDLED 
} 

public radio1cmd(id, key1) { 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	if(g_RadioTimer[id] == 1) return PLUGIN_HANDLED
	new players[32],total, team_name[10] 
	get_user_team(id,team_name, 9) 
	get_players(players, total ,"ce", team_name) // No bots and Match team name
	new name[32]
	get_user_name(id,name,31)
	for(new a=0; a < total; ++a) { 
		client_cmd(players[a], "spk ^"%s^"", radio1_spk[key1])
		if (get_cvar_num("amx_real_radio"))
		{
			emit_sound(id, CHAN_VOICE, radio1_spk[key1] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
		}
		//client_print(players[a],print_chat,"%s (RADIO): %s",name, radio1_say[key1])
		new message1[64]
		
		switch (key1) {
			case 0: { // 1
			message1 = CRcoverme	
			}
			case 1: { // 2
			message1 = CRtakepoint
			}
			case 2: { // 3
			message1 = CRhposition
			}
			case 3: { // 4
			message1 = CRregroup
			}
			case 4: { // 5
			message1 = CRfollowme
			}
			case 5: { // 6
			message1 = CRfireassis
			}
		}
		client_print(players[a],print_chat,"%s (RADIO): %s",name, message1)
		g_RadioTimer[id] = 1
		set_task(2.0,"radiotimer",id)
	}
	return PLUGIN_HANDLED 
} 



// Radio2 wav files 

stock const radio2_spk[6][] =  {   
	
	
	"radio/dpcs2k20/com_go.wav", 
	"radio/dpcs2k20/fallback.wav", 
	"radio/dpcs2k20/sticktog.wav", 
	"radio/dpcs2k20/com_getinpos.wav", 
	"radio/dpcs2k20/stormfront.wav", 
	"radio/dpcs2k20/com_reportin.wav"
} 

public radio2(id) {   // Client used Radio2 commands 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	// What Radio2 menu will look like
	new key2 = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)
		
	new menu_body2[512]
	new len2 = format(menu_body2,511,"\%sRadio Commands B\%s^n\ ", CRcolortitle, CRcolormenu)
	len2 += format( menu_body2[len2], 511-len2, "^n\ " )
	len2 += format( menu_body2[len2], 511-len2, "1. %s^n\ ", CRgo)
	len2 += format( menu_body2[len2], 511-len2, "2. %s^n\ ", CRfallback)
	len2 += format( menu_body2[len2], 511-len2, "3. %s^n\ ", CRsticktog)
	len2 += format( menu_body2[len2], 511-len2, "4. %s^n\ ", CRgetinpos)
	len2 += format( menu_body2[len2], 511-len2, "5. %s^n\ ", CRstormfront)
	len2 += format( menu_body2[len2], 511-len2, "6. %s^n\ ", CRreportin)
	len2 += format( menu_body2[len2], 511-len2, "^n\ " )
	len2 += format( menu_body2[len2], 511-len2, "0. %s", CRexit)
	
	show_menu(id,key2,menu_body2) // Show the above menu on screen 
	return PLUGIN_HANDLED 
}

public radio2cmd(id, key2) { 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	if(g_RadioTimer[id] == 1) return PLUGIN_HANDLED
	new players2[32],total2, team_name2[10] 
	get_user_team(id,team_name2, 9) 
	get_players(players2, total2 ,"ce", team_name2) // No bots and Match team name
	new name2[32]
	get_user_name(id,name2,31)
	for(new a2=0; a2 < total2; ++a2) { 
		client_cmd(players2[a2], "spk ^"%s^"", radio2_spk[key2])
		if (get_cvar_num("amx_real_radio"))
		{
			emit_sound(id, CHAN_VOICE, radio2_spk[key2] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
		}
		//client_print(players2[a2],print_chat,"%s (RADIO): %s",name2,radio2_say[key2]) // Print radio message on screen
		new message2[64]
		
		switch (key2) {
			case 0: { // 1
			message2 = CRgo	
			}
			case 1: { // 2
			message2 = CRfallback
			}
			case 2: { // 3
			message2 = CRsticktog
			}
			case 3: { // 4
			message2 = CRgetinpos
			}
			case 4: { // 5
			message2 = CRstormfront
			}
			case 5: { // 6
			message2 = CRreportin
			}
		}
		client_print(players2[a2],print_chat,"%s (RADIO): %s",name2, message2)
		g_RadioTimer[id] = 1
		set_task(2.0,"radiotimer",id)
	}
	return PLUGIN_HANDLED 
} 


// Radio3 wav files 

stock const radio3_spk[9][] =  {   
	
	
	"radio/dpcs2k20/roger.wav", 
	"radio/dpcs2k20/ct_enemys.wav", 
	"radio/dpcs2k20/ct_backup.wav", 
	"radio/dpcs2k20/clear.wav", 
	"radio/dpcs2k20/ct_inpos.wav", 
	"radio/dpcs2k20/ct_reportingin.wav", 
	"radio/dpcs2k20/blow.wav", 
	"radio/dpcs2k20/negative.wav", 
	"radio/dpcs2k20/enemydown.wav" 
} 

public radio3(id) {   // Client used Radio3 commands 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	// What Radio3 menu will look like
	new key3 = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
	
	new menu_body3[512]
	new len3 = format(menu_body3,511,"\%sRadio Commands C\%s^n\ ", CRcolortitle, CRcolormenu)
	len3 += format( menu_body3[len3], 511-len3, "^n\ " )
	len3 += format( menu_body3[len3], 511-len3, "1. %s^n\ ", CRroger)
	len3 += format( menu_body3[len3], 511-len3, "2. %s^n\ ", CRenemys)
	len3 += format( menu_body3[len3], 511-len3, "3. %s^n\ ", CRbackup)
	len3 += format( menu_body3[len3], 511-len3, "4. %s^n\ ", CRclear)
	len3 += format( menu_body3[len3], 511-len3, "5. %s^n\ ", CRposition)
	len3 += format( menu_body3[len3], 511-len3, "6. %s^n\ ", CRreportingin)
	len3 += format( menu_body3[len3], 511-len3, "7. %s^n\ ", CRgetoutblow)
	len3 += format( menu_body3[len3], 511-len3, "8. %s^n\ ", CRnegative)
	len3 += format( menu_body3[len3], 511-len3, "9. %s^n\ ", CRenemydown)
	len3 += format( menu_body3[len3], 511-len3, "^n\ " )
	len3 += format( menu_body3[len3], 511-len3, "0. %s", CRexit)
	
	show_menu(id,key3,menu_body3) // Show the above menu on screen 
	return PLUGIN_HANDLED 
} 

public radio3cmd(id, key3) { 
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(is_user_alive(id) == 0) return PLUGIN_HANDLED
	if(g_RadioTimer[id] == 1) return PLUGIN_HANDLED
	new players3[32],total3, team_name3[10] 
	get_user_team(id,team_name3, 9) 
	get_players(players3, total3 ,"ce", team_name3) // No bots and Match team name
	new name3[32]
	get_user_name(id,name3,31)
	for(new a3=0; a3 < total3; ++a3) { 
		client_cmd(players3[a3], "spk ^"%s^"", radio3_spk[key3])
		if (get_cvar_num("amx_real_radio"))
		{
			emit_sound(id, CHAN_VOICE, radio3_spk[key3] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
		}
		//client_print(players3[a3],print_chat,"%s (RADIO): %s",name3,radio3_say[key3]) // Print radio message on screen
		new message3[64]
		
		switch (key3) {
			case 0: { // 1
			message3 = CRroger	
			}
			case 1: { // 2
			message3 = CRenemys
			}
			case 2: { // 3
			message3 = CRbackup
			}
			case 3: { // 4
			message3 = CRclear
			}
			case 4: { // 5
			message3 = CRposition
			}
			case 5: { // 6
			message3 = CRreportingin
			}
			case 6: { // 7
			message3 = CRgetoutblow
			}
			case 7: { // 8
			message3 = CRnegative
			}
			case 8: { // 9
			message3 = CRenemydown
			}
		}
		client_print(players3[a3],print_chat,"%s (RADIO): %s",name3, message3)
		
		g_RadioTimer[id] = 1
		set_task(2.0,"radiotimer",id)
	}
	return PLUGIN_HANDLED 
} 


public plugin_precache() {
	
	precache_sound(radio1_spk[0])
	precache_sound(radio1_spk[1])
	precache_sound(radio1_spk[2])
	precache_sound(radio1_spk[3])
	precache_sound(radio1_spk[4])
	precache_sound(radio1_spk[5])
		
	precache_sound(radio2_spk[0])
	precache_sound(radio2_spk[1])
	precache_sound(radio2_spk[2])
	precache_sound(radio2_spk[3])
	precache_sound(radio2_spk[4])
	precache_sound(radio2_spk[5])
	
	precache_sound(radio3_spk[0])
	precache_sound(radio3_spk[1])
	precache_sound(radio3_spk[2])
	precache_sound(radio3_spk[3])
	precache_sound(radio3_spk[4])
	precache_sound(radio3_spk[5])
	precache_sound(radio3_spk[6])
	precache_sound(radio3_spk[7])
	precache_sound(radio3_spk[8])
	
	precache_sound("radio/dpcs2k20/ct_fireinhole.wav")
	
	return PLUGIN_CONTINUE 
} 

public plugin_init(){
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("radio1", "radio1", 0, "- Calls radio menu 1")
	register_clcmd("radio2", "radio2", 0, "- Calls radio menu 2")
	register_clcmd("radio3", "radio3", 0, "- Calls radio menu 3")
	register_menucmd(register_menuid("Radio Commands A"),511,"radio1cmd")
	register_menucmd(register_menuid("Radio Commands B"),511,"radio2cmd")
	register_menucmd(register_menuid("Radio Commands C"),511,"radio3cmd")

	register_cvar("amx_custom_radio", "1")
	register_cvar("amx_real_radio", "1")
	register_cvar("amx_radio_info", "1")
	
	register_cvar("CRcoverme", "radio")
	register_cvar("CRtakepoint", "radio")
	register_cvar("CRhposition", "radio")
	register_cvar("CRregroup", "radio")
	register_cvar("CRfollowme", "radio")
	register_cvar("CRfireassis", "radio")
	
	register_cvar("CRgo", "radio")
	register_cvar("CRfallback", "radio")
	register_cvar("CRsticktog", "radio")
	register_cvar("CRgetinpos", "radio")
	register_cvar("CRstormfront", "radio")
	register_cvar("CRreportin", "radio")

	register_cvar("CRroger", "radio")
	register_cvar("CRenemys", "radio")
	register_cvar("CRbackup", "radio")
	register_cvar("CRclear", "radio")
	register_cvar("CRposition", "radio")
	register_cvar("CRreportingin", "radio")
	register_cvar("CRgetoutblow", "radio")
	register_cvar("CRnegative", "radio")
	register_cvar("CRenemydown", "radio")
	
	register_cvar("CRexit", "radio")
	register_cvar("CRcolortitle", "r")
	register_cvar("CRcolormenu", "w")
	
	register_cvar("CRfireinhole", "radio")
		
	register_message(get_user_msgid("TextMsg"), "message")
	register_message(get_user_msgid("SendAudio"), "msg_audio")
	
	//version 0.6
	register_clcmd("coverme", "komenda", 0, "- Quick radio command")
	register_clcmd("takepoint", "komenda", 0, "- Quick radio command")
	register_clcmd("holdpos", "komenda", 0, "- Quick radio command")
	register_clcmd("regroup", "komenda", 0, "- Quick radio command")
	register_clcmd("followme", "komenda", 0, "- Quick radio command")
	register_clcmd("takingfire", "komenda", 0, "- Quick radio command")
	
	register_clcmd("go", "komenda", 0, "- Quick radio command")
	register_clcmd("fallback", "komenda", 0, "- Quick radio command")
	register_clcmd("sticktog", "komenda", 0, "- Quick radio command")
	register_clcmd("getinpos", "komenda", 0, "- Quick radio command")
	register_clcmd("stormfront", "komenda", 0, "- Quick radio command")
	register_clcmd("report", "komenda", 0, "- Quick radio command")
	
	register_clcmd("roger", "komenda", 0, "- Quick radio command")
	register_clcmd("enemyspot", "komenda", 0, "- Quick radio command")
	register_clcmd("needbackup", "komenda", 0, "- Quick radio command")
	register_clcmd("sectorclear", "komenda", 0, "- Quick radio command")
	register_clcmd("inposition", "komenda", 0, "- Quick radio command")
	register_clcmd("reportingin", "komenda", 0, "- Quick radio command")
	register_clcmd("getout", "komenda", 0, "- Quick radio command")
	register_clcmd("negative", "komenda", 0, "- Quick radio command")
	register_clcmd("enemydown", "komenda", 0, "- Quick radio command")

	new configsDir[64]
	get_configsdir(configsDir, 63)
	
	server_cmd("exec %s/custom_radio.cfg", configsDir)
	server_exec()
				
	return PLUGIN_CONTINUE  
}

public message()
{
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE

	if(get_msg_args() != 4 || get_msg_argtype(2) != ARG_STRING || get_msg_argtype(4) != ARG_STRING)
	{
		return PLUGIN_CONTINUE
	}

	new arg2[16]
	get_msg_arg_string(2, arg2, 15)
	if(!equal(arg2, "#Game_radio"))
	{
		return PLUGIN_CONTINUE
	}
	
	new arg4[20]
	get_msg_arg_string(4, arg4, 19)
	if(equal(arg4, "#Fire_in_the_hole"))
	{
		set_msg_arg_string(4, CRfireinhole)
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public msg_audio()
{
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	if(get_msg_args() != 3 || get_msg_argtype(2) != ARG_STRING) {
		return PLUGIN_CONTINUE
	}

	new arg2[20]
	get_msg_arg_string(2, arg2, 19)
	if(equal(arg2[1], "!MRAD_FIREINHOLE"))
	{
			return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public grenade_throw(id,ent,wid)
{
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	new players[32],total, team_name[10] 
	get_user_team(id,team_name, 9) 
	get_players(players, total ,"ce", team_name) // No bots and Match team name
	new name[32]
	get_user_name(id,name,31)
	for(new a=0; a < total; ++a)
	{ 
		client_cmd(players[a], "spk radio/dpcs2k20/ct_fireinhole.wav")
		if (get_cvar_num("amx_real_radio"))  
		{
		emit_sound(id, CHAN_VOICE, "radio/dpcs2k20/ct_fireinhole.wav" , 0.9, ATTN_STATIC, 0, PITCH_NORM)  
		}
	}
	return PLUGIN_HANDLED
}
	
public radiotimer(id) {
	g_RadioTimer[id] = 0
	return PLUGIN_HANDLED
}

public client_connect(id) {
	g_RadioTimer[id] = 0
}

public client_disconnect(id) {
	g_RadioTimer[id] = 0
}


public client_putinserver(id)	
{
	set_task(20.0, "dispInfo", id)
}

public dispInfo(id)
{
	if (get_cvar_num("amx_radio_info")) 
		//client_print(id,print_chat,"Plugin 'Custom Radio Commands' jest uruchomiony na tym serwerze. Kontakt z autorem: kaloszyfer@o2.pl")
		client_print(id,print_chat,"'Custom Radio Commands' plugin is running on this server. Contact with author: kaloszyfer@o2.pl")
}

public plugin_cfg()
{

	get_cvar_string("CRcoverme", CRcoverme, 63)
	get_cvar_string("CRtakepoint", CRtakepoint, 63)
	get_cvar_string("CRhposition", CRhposition, 63)
	get_cvar_string("CRregroup", CRregroup, 63)
	get_cvar_string("CRfollowme", CRfollowme, 63)
	get_cvar_string("CRfireassis", CRfireassis, 63)

	get_cvar_string("CRgo", CRgo, 63)
	get_cvar_string("CRfallback", CRfallback, 63)
	get_cvar_string("CRsticktog", CRsticktog, 63)
	get_cvar_string("CRgetinpos", CRgetinpos, 63)
	get_cvar_string("CRstormfront", CRstormfront, 63)
	get_cvar_string("CRreportin", CRreportin, 63)
	
	get_cvar_string("CRroger", CRroger, 63)
	get_cvar_string("CRenemys", CRenemys, 63)
	get_cvar_string("CRbackup", CRbackup, 63)
	get_cvar_string("CRclear", CRclear, 63)
	get_cvar_string("CRposition", CRposition, 63)
	get_cvar_string("CRreportingin", CRreportingin, 63)
	get_cvar_string("CRgetoutblow", CRgetoutblow, 63)
	get_cvar_string("CRnegative", CRnegative, 63)
	get_cvar_string("CRenemydown", CRenemydown, 63)
	
	get_cvar_string("CRexit", CRexit, 63)
	get_cvar_string("CRcolortitle", CRcolortitle, 1)
	get_cvar_string("CRcolormenu", CRcolormenu, 1)
	
	//version 0.6
	get_cvar_string("CRfireinhole", CRfireinhole, 63)
	
}

//version 0.6
new cmd_radio1[6][] =
{
	"coverme",
	"takepoint",
	"holdpos",
	"regroup",
	"followme",
	"takingfire"
}

new cmd_radio2[6][] =
{
	"go",
	"fallback",
	"sticktog",
	"getinpos",
	"stormfront",
	"report"
}

new cmd_radio3[9][] =
{
	"roger",
	"enemyspot",
	"needbackup",
	"sectorclear",
	"inposition",
	"reportingin",
	"getout",
	"negative",
	"enemydown"
}

public komenda(id)
{
	if(!get_cvar_num("amx_custom_radio"))
		return PLUGIN_CONTINUE
		
	new komenda[16]
	read_argv ( 0, komenda, 15 )
	
	for(new i = 0; i < 6; i++)
	{
		if(equal(komenda, cmd_radio1[i]))
		{
			if(is_user_alive(id) == 0)
				return PLUGIN_HANDLED
			if(g_RadioTimer[id] == 1) 
				return PLUGIN_HANDLED
		
			new players[32],total, team_name[10] 
			get_user_team(id,team_name, 9) 
			get_players(players, total ,"ce", team_name) // No bots and Match team name
			new name[32]
			get_user_name(id,name,31)
			for(new a=0; a < total; ++a)
			{ 
				client_cmd(players[a], "spk ^"%s^"", radio1_spk[i])
				if (get_cvar_num("amx_real_radio"))
				{
					emit_sound(id, CHAN_VOICE, radio1_spk[i] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
				}
				new message1[64]
		
				switch(i)
				{
					case 0: { // 1
					message1 = CRcoverme	
					}
					case 1: { // 2
					message1 = CRtakepoint
					}
					case 2: { // 3
					message1 = CRhposition
					}
					case 3: { // 4
					message1 = CRregroup
					}
					case 4: { // 5
					message1 = CRfollowme
					}
					case 5: { // 6
					message1 = CRfireassis
					}
				}
				client_print(players[a],print_chat,"%s (RADIO): %s",name, message1)
				g_RadioTimer[id] = 1
				set_task(2.0,"radiotimer",id)
			}
			return PLUGIN_HANDLED
		}
		
		if(equal(komenda, cmd_radio2[i]))
		{
			if(is_user_alive(id) == 0)
				return PLUGIN_HANDLED
			if(g_RadioTimer[id] == 1) 
				return PLUGIN_HANDLED
		
			new players[32],total, team_name[10] 
			get_user_team(id,team_name, 9) 
			get_players(players, total ,"ce", team_name) // No bots and Match team name
			new name[32]
			get_user_name(id,name,31)
			for(new a=0; a < total; ++a)
			{ 
				client_cmd(players[a], "spk ^"%s^"", radio2_spk[i])
				if (get_cvar_num("amx_real_radio"))
				{
					emit_sound(id, CHAN_VOICE, radio2_spk[i] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
				}
				new message2[64]
		
				switch(i)
				{
					case 0: { // 1
					message2 = CRgo	
					}
					case 1: { // 2
					message2 = CRfallback
					}
					case 2: { // 3
					message2 = CRsticktog
					}
					case 3: { // 4
					message2 = CRgetinpos
					}
					case 4: { // 5
					message2 = CRstormfront
					}
					case 5: { // 6
					message2 = CRreportin
					}
				}
				client_print(players[a],print_chat,"%s (RADIO): %s",name, message2)
				g_RadioTimer[id] = 1
				set_task(2.0,"radiotimer",id)
			}
			return PLUGIN_HANDLED
		}
	}
	
	for(new i = 0; i < 9; i++)
	{
		if(equal(komenda, cmd_radio3[i]))
		{
			if(is_user_alive(id) == 0)
				return PLUGIN_HANDLED
			if(g_RadioTimer[id] == 1) 
				return PLUGIN_HANDLED
		
			new players[32],total, team_name[10] 
			get_user_team(id,team_name, 9) 
			get_players(players, total ,"ce", team_name) // No bots and Match team name
			new name[32]
			get_user_name(id,name,31)
			for(new a=0; a < total; ++a)
			{ 
				client_cmd(players[a], "spk ^"%s^"", radio3_spk[i])
				if (get_cvar_num("amx_real_radio"))
				{
					emit_sound(id, CHAN_VOICE, radio3_spk[i] , 0.9, ATTN_STATIC, 0, PITCH_NORM)// Play sounds 
				}
				new message3[64]
		
				switch(i)
				{
					case 0: { // 1
					message3 = CRroger	
					}
					case 1: { // 2
					message3 = CRenemys
					}
					case 2: { // 3
					message3 = CRbackup
					}
					case 3: { // 4
					message3 = CRclear
					}
					case 4: { // 5
					message3 = CRposition
					}
					case 5: { // 6
					message3 = CRreportingin
					}
					case 6: { // 7
					message3 = CRgetoutblow
					}
					case 7: { // 8
					message3 = CRnegative
					}
					case 8: { // 9
					message3 = CRenemydown
					}
				}
				client_print(players[a],print_chat,"%s (RADIO): %s",name, message3)
				g_RadioTimer[id] = 1
				set_task(2.0,"radiotimer",id)
			}
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
