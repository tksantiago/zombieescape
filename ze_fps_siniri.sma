#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "High FPS Detector"
#define VERSION "1.0"
#define AUTHOR "DPCS"

new iFrames[33]

#define FPSSINIR 180

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink")
}

public Forward_PlayerPreThink(id) {
	if(!is_user_alive(id)) return FMRES_IGNORED
	
	iFrames[id]++
	return FMRES_IGNORED
}

public client_authorized(id) {
	client_cmd(id, "fps_max 144;")
}

public client_putinserver(id) {
	iFrames[id] = 0
	set_task(1.0, "ShowFps",id+19075, _, _, "b")
}

public client_disconnected(id) {
	if(task_exists(id+19075)) {
		remove_task(id+19075)
	}
}

public ShowFps(id)
{
	id -= 19075
	if(is_user_alive(id) && iFrames[id] >= FPSSINIR) {
		new szName[33]
		get_user_name(id, szName, 33)
		renkli_yazi(0, "!g[DPCS] !n[ !t%s !n] Adli Oyuncuda !n[ !t%dFPS !n] Tespit Edildigi Icin Olduruldu", szName, iFrames[id])
		user_silentkill(id)
	}
	iFrames[id] = 0
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