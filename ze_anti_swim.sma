#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#define PLUGIN "Fast Swim Detector"
#define VERSION "1.0"
#define AUTHOR "DPCS*"

const Float:jumplimit = 2.5 // space basili tutma max sure
new Float:jumpstarttime[33]
const Float:speedlimit = 250.0 // suda max hiz (space ile)

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPostThink, "Player_PostThink");
	RegisterHam(Ham_Killed, "player", "Player_Spawn",1);
	for (new i = 1; i < 33; i++)
		jumpstarttime[i] = -1.0
}

public Player_Spawn(id)
{
	jumpstarttime[id] = -1.0
	return HAM_IGNORED;
}

public client_disconnected(id)
{
	jumpstarttime[id] = -1.0
}

public Player_PostThink(id)
{
	static inwater; inwater = entity_get_int(id, EV_INT_waterlevel)
	static Buttons;Buttons = pev(id, pev_button);
	static Float:veloc[3];get_user_velocity(id, veloc)
	static Float:hveloc; hveloc = vector_length(veloc)
	if(inwater == 2 && Buttons & IN_JUMP && jumpstarttime[id] < 0.0) {
		jumpstarttime[id] = get_gametime()
	}
	else if(!(Buttons & IN_JUMP) && jumpstarttime[id] > 0.0) {
		jumpstarttime[id] = -1.0
	}
	if(inwater == 2 && jumpstarttime[id] >= 0.0 && get_gametime() - jumpstarttime[id] > jumplimit && hveloc > speedlimit) {
		new szName[33]
		get_user_name(id, szName, 33)
		renkli_yazi(0, "!g[DPCS] !n[ !t%s !n] Adli Oyuncuda !n[ !tHizli Yuzme !n] Tespit Edildigi Icin Olduruldu", szName)
		user_silentkill(id)
		jumpstarttime[id] = -1.0
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