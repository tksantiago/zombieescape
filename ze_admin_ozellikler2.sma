#include <amxmodx>
#include <hlsdk_const>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <fun>
#include <zombieplague>
#include <levels>

#define ADMINACCESS ADMIN_RESERVATION

#define SCOREATTRIB_NONE 0
#define SCOREATTRIB_DEAD (1 << 0)
#define SCOREATTRIB_BOMB (1 << 1)
#define SCOREATTRIB_VIP  (1 << 2)

new jumpnum[33] = 0
new bool:dojump[33] = false

new suankimap[250]

public plugin_init()
{
	register_plugin("Admin Ozellikleri","1.0","DPCS")
	
	RegisterHam(Ham_Spawn, "player", "fwdPlayerSpawnPost", 1)
	RegisterHam(Ham_TakeDamage, "player", "OnCBasePlayer_TakeDamage")
	register_forward(FM_Voice_SetClientListening, "FwdSetVoice")
	register_message(get_user_msgid("ScoreAttrib"), "MessageScoreAttrib")
	
	register_cvar("amx_maxjumps", "1")
	register_cvar("freevip_hour", "1")
}

public client_putinserver(id)
{
	jumpnum[id] = 0
	dojump[id] = false
}

public client_disconnected(id)
{
	jumpnum[id] = 0
	dojump[id] = false
}

public client_PreThink(id)
{
	get_mapname(suankimap,249)
	if(is_user_alive(id) && !zp_get_user_zombie(id) && (get_cvar_num("freevip_hour") || get_user_level(id) >= 40 || access(id,ADMINACCESS) || (contain(suankimap, "de_") != -1) || (contain(suankimap, "cs_") != -1)))
	{
		new nbut = get_user_button(id)
		new obut = get_user_oldbutton(id)
		if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
		{
			if(jumpnum[id] < get_cvar_num("amx_maxjumps"))
			{
				dojump[id] = true
				jumpnum[id]++
				return PLUGIN_CONTINUE
			}
		}
		if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
		{
			jumpnum[id] = 0
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	get_mapname(suankimap,249)
	if(is_user_alive(id) && !zp_get_user_zombie(id) && (get_cvar_num("freevip_hour") || get_user_level(id) >= 30 || access(id,ADMINACCESS) || (contain(suankimap, "de_") != -1) || (contain(suankimap, "cs_") != -1)))
	{
		if(dojump[id] == true)
		{
			new Float:velocity[3]
			entity_get_vector(id,EV_VEC_velocity,velocity)
			velocity[2] = random_float(265.0,285.0)
			entity_set_vector(id,EV_VEC_velocity,velocity)
			dojump[id] = false
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public fwdPlayerSpawnPost(id)
{
	if(!is_user_alive(id) && !is_user_connected(id))
		return PLUGIN_HANDLED
	
	if(access(id,ADMINACCESS) || get_user_level(id) >= 40)
	{
		set_user_armor(id, 100)
	}
	else if(get_cvar_num("freevip_hour") && get_user_level(id) < 20)
	{
		set_user_armor(id, 15)
	}
	else if(get_user_level(id) >= 10 && get_user_level(id) <= 19)
	{
		set_user_armor(id, 10)
	}
	else if(get_user_level(id) >= 20 && get_user_level(id) <= 29)
	{
		set_user_armor(id, 20)
	}
	else if(get_user_level(id) >= 30)
	{
		set_user_armor(id, 30)
	}
	return PLUGIN_CONTINUE
}

public OnCBasePlayer_TakeDamage(id, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(bitsDamageType & DMG_FALL)
	{
		if(access(id, ADMINACCESS))
		{
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public FwdSetVoice(receiver, sender, listen)
{
	if(!access(sender, ADMIN_KICK))
	{
		engfunc(EngFunc_SetClientListening, receiver, sender, 0)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public MessageScoreAttrib(iMsgID, iDest, iReceiver)
{
	new iPlayer = get_msg_arg_int(1)
	if(is_user_connected(iPlayer) && ((get_user_flags(iPlayer) & ADMINACCESS) || get_cvar_num("freevip_hour")))
	{
		set_msg_arg_int(2, ARG_BYTE, is_user_alive(iPlayer) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
