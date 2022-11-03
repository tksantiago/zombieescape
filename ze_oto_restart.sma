/* Plugin generated by AMXX-Studio */


#include <amxmodx>

#define PLUGIN "Auto Restart vl"
#define VERSION "1.4"
#define AUTHOR "vato loco [GE-S]"

#define TIMER_TASK        123456
#define RESTART_TASK      789123

new g_counter  

new g_autorestart
new g_autoenabled
new g_autocds
new g_autocount_color
new g_autostart_color
new g_auto_xypos

new g_SyncGameStart
new g_SyncRestartTimer

new bool:g_bRoundStart 

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_logevent("RoundStart", 2, "1=Round_Start")
	register_event("TextMsg","RestartTask","a","2&#Game_C")   
	
	register_dictionary("auto_restart_vl.txt")
	
	g_autoenabled = register_cvar("amx_autorr_enable","1")
	g_autocds = register_cvar("amx_autorr_cds","1")
	g_autorestart = register_cvar("amx_autorr_time","40")
	g_autocount_color = register_cvar("amx_autorr_count_color","0 255 0")
	g_autostart_color = register_cvar("amx_autorr_start_color","0 255 255")
	g_auto_xypos = register_cvar("amx_autorr_xypos","-1.0 0.25")
	
	g_SyncGameStart = CreateHudSyncObj()
	g_SyncRestartTimer = CreateHudSyncObj()
}

public RoundStart()
{
	if(!get_pcvar_num(g_autoenabled))
		return PLUGIN_HANDLED
	
	if(g_bRoundStart)
	{
		static r, g, b, Float:x, Float:y
		HudMsgPos(x,y)
		HudMsgColor(g_autostart_color, r, g, b)
		
		set_hudmessage( r, g, b, x, y, 1, 5.0, 8.0, 0.0, 0.0, -1)
		ShowSyncHudMsg( 0, g_SyncGameStart, "%L",LANG_PLAYER, "GAME_STARTED")
	}
	g_bRoundStart = false
	
	return PLUGIN_CONTINUE
}

public RestartTask() 
{
	if(!get_pcvar_num(g_autoenabled))
		return PLUGIN_HANDLED
	
	set_task(1.0,"TimeCounter",TIMER_TASK,_,_,"a",get_pcvar_num(g_autorestart))
	set_task(get_pcvar_float(g_autorestart),"RestartRound",RESTART_TASK)
	
	return PLUGIN_CONTINUE
}

public TimeCounter() 
{
	g_counter++
	
	new Float:iRestartTime = get_pcvar_float(g_autorestart) - g_counter
	new Float:fSec
	fSec = iRestartTime 
	
	static r, g, b, Float:x, Float:y
	HudMsgPos(x,y)
	HudMsgColor(g_autocount_color, r, g, b)
	
	set_hudmessage( r, g, b, x, y, 0, 0.0, 1.0, 0.0, 0.0, -1)
	ShowSyncHudMsg( 0, g_SyncRestartTimer, "%L",LANG_PLAYER, "AUTO_RESTART", floatround(fSec))
	
	if(get_pcvar_num(g_autocds) && get_pcvar_num(g_autorestart) - g_counter < 11 && get_pcvar_num(g_autorestart) - g_counter !=0)
	{
		static szNum[32]
		num_to_word(get_pcvar_num(g_autorestart) - g_counter, szNum, 31)
		client_cmd(0,"speak ^"vox/%s^"", szNum)
	}
	if(g_counter == get_pcvar_num(g_autorestart))
	{
		g_bRoundStart = true
		g_counter = 0
	}
}

public RestartRound() 
{
	server_cmd("sv_restartround 1")
}

public HudMsgColor(cvar, &r, &g, &b)
{
	static color[16], piece[5]
	get_pcvar_string(cvar, color, 15)
	
	argbreak( color, piece, 4, color, 15)
	r = str_to_num(piece)
	
	argbreak( color, piece, 4, color, 15)
	g = str_to_num(piece)
	b = str_to_num(color)
}

public HudMsgPos(&Float:x, &Float:y)
{
	static coords[16], piece[10]
	get_pcvar_string(g_auto_xypos , coords, 15)
	
	argbreak(coords, piece, 9, coords, 15)
	x = str_to_float(piece)
	y = str_to_float(coords)
}

