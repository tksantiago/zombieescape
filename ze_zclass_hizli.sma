#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <zombieplague>
#include <levels>

#define PLUGIN "NST Zombie Class Tank"
#define VERSION "1.0.1"
#define AUTHOR "NST"

new const zclass_name[] = "Fast"
new const zclass_info[] = "['G']"
new const zclass_model[] = "tank_zombi_dp"
new const zclass_clawmodel[] = "v_knife_tank_zombi.mdl"
const zclass_health = 15000
const zclass_speed = 300
const Float:zclass_gravity = 0.68
const Float:zclass_knockback = 3.00
const zclass_level = 10

new idclass
const Float:fastrun_time = 10.0
const Float:fastrun_timewait = 15.0
const Float:fastrun_speed = 340.0
new const sound_fastrun_start[] = "ze_dp/zombi_pressure.wav"
new const sound_fastrun_heartbeat[][] = {"ze_dp/zombi_pre_idle_1.wav", "ze_dp/zombi_pre_idle_2.wav"}
const fastrun_dmg = 500
const fastrun_fov = 105
const glow_red = 255
const glow_green = 3
const glow_blue = 0

new g_fastrun[33], g_fastrun_wait[33]

new g_msgSayText, g_msgSetFOV
new g_maxplayers
new g_roundend

enum (+= 100)
{
	TASK_FASTRUN = 2000,
	TASK_FASTRUN_HEARTBEAT,
	TASK_FASTRUN_WAIT,
	TASK_BOT_USE_SKILL
}

#define ID_FASTRUN (taskid - TASK_FASTRUN)
#define ID_FASTRUN_HEARTBEAT (taskid - TASK_FASTRUN_HEARTBEAT)
#define ID_FASTRUN_WAIT (taskid - TASK_FASTRUN_WAIT)
#define ID_BOT_USE_SKILL (taskid - TASK_BOT_USE_SKILL)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "Death", "a")
	register_event("CurWeapon","EventCurWeapon","be","1=1")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_clcmd("drop", "cmd_fastrun")
	
	g_msgSayText = get_user_msgid("SayText")
	g_msgSetFOV = get_user_msgid("SetFOV")
	g_maxplayers = get_maxplayers()
}

public plugin_precache()
{
	new i
	for(i = 0; i < sizeof sound_fastrun_heartbeat; i++ )
	{
		precache_sound(sound_fastrun_heartbeat[i]);
	}
	
	precache_sound(sound_fastrun_start)
	
	idclass = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public client_putinserver(id)
{
	reset_value_player(id)
}

public client_disconnect(id)
{
	reset_value_player(id)
}

public event_round_start()
{
	g_roundend = 0
	
	for (new id=1; id<=g_maxplayers; id++)
	{
		if (!is_user_connected(id)) continue;
		
		reset_value_player(id)
	}
}

public logevent_round_end()
{
	g_roundend = 1
}

public Death()
{
	new victim = read_data(2) 
	reset_value_player(victim)
}

public EventCurWeapon(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;
	
	new extrahiz;
	if(get_user_level(id) >= 10 && get_user_level(id) <= 19)
	{
		extrahiz = 10
	}
	else if(get_user_level(id) >= 20 && get_user_level(id) <= 29)
	{
		extrahiz = 20
	}
	else if(get_user_level(id) >= 30)
	{
		extrahiz = 30
	}
	
	if(g_fastrun[id]) set_user_maxspeed(id, (fastrun_speed+extrahiz));
	
	return PLUGIN_CONTINUE;
}

public zp_user_infected_post(id)
{
	reset_value_player(id)
	
	if(zp_get_user_nemesis(id)) return;
	
	if(zp_get_user_zombie_class(id) == idclass)
	{
		if(is_user_bot(id))
		{
			set_task(random_float(5.0,15.0), "bot_use_skill", id+TASK_BOT_USE_SKILL)
			return
		}
		
		zp_colored_print(id, "^x04[ZE]^x01 Sinifinin yetenegi Hizli Kosma. Yuklenme suresi %.1f saniye.", fastrun_timewait)
	}
}

public zp_user_humanized_post(id)
{
	if(g_fastrun[id]) EffectFastrun(id);
	
	reset_value_player(id)
}

public zp_user_unfrozen(id)
{
	if(g_fastrun[id]) set_user_rendering(id, kRenderFxGlowShell, glow_red, glow_green, glow_blue, kRenderNormal, 0)
}

public cmd_fastrun(id)
{
	if (g_roundend) return PLUGIN_CONTINUE
	
	if (!is_user_alive(id) || !zp_get_user_zombie(id) || zp_get_user_nemesis(id)) return PLUGIN_CONTINUE

	new health = get_user_health(id) - fastrun_dmg
	if (zp_get_user_zombie_class(id) == idclass && health>0 && !g_fastrun[id] && !g_fastrun_wait[id])
	{
		g_fastrun[id] = 1
		
		set_user_health(id, health)
		new extrahiz;
		if(get_user_level(id) >= 10 && get_user_level(id) <= 19)
		{
			extrahiz = 10
		}
		else if(get_user_level(id) >= 20 && get_user_level(id) <= 29)
		{
			extrahiz = 20
		}
		else if(get_user_level(id) >= 30)
		{
			extrahiz = 30
		}
		set_user_maxspeed(id, (fastrun_speed+extrahiz))
		set_user_rendering(id, kRenderFxGlowShell, glow_red, glow_green, glow_blue, kRenderNormal, 0)
		EffectFastrun(id, fastrun_fov)
		PlayEmitSound(id, sound_fastrun_start)
		
		set_task(fastrun_time, "RemoveFastRun", id+TASK_FASTRUN)
		set_task(2.0, "FastRunHeartBeat", id+TASK_FASTRUN_HEARTBEAT, _, _, "b")

		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public bot_use_skill(taskid)
{
	new id = ID_BOT_USE_SKILL
	
	if (!is_user_alive(id)) return;

	cmd_fastrun(id)
	
	set_task(random_float(5.0,15.0), "bot_use_skill", id+TASK_BOT_USE_SKILL)
}

public RemoveFastRun(taskid)
{
	new id = ID_FASTRUN

	g_fastrun[id] = 0
	g_fastrun_wait[id] = 1
	
	set_user_maxspeed(id, float(zclass_speed))
	set_user_rendering(id)
	EffectFastrun(id)
	
	set_task(fastrun_timewait, "RemoveWaitFastRun", id+TASK_FASTRUN_WAIT)
}

public RemoveWaitFastRun(taskid)
{
	new id = ID_FASTRUN_WAIT
	
	g_fastrun_wait[id] = 0
	
	zp_colored_print(id, "^x04[ZE]^x01 Hizli Kosma Yetenegin hazir.")
}

public FastRunHeartBeat(taskid)
{
	new id = ID_FASTRUN_HEARTBEAT
	
	if (g_fastrun[id]) PlayEmitSound(id, sound_fastrun_heartbeat[random_num(0, sizeof sound_fastrun_heartbeat - 1)]);
	else remove_task(taskid)
}

PlayEmitSound(id, const sound[])
{
	emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

EffectFastrun(id, num = 90)
{
	message_begin(MSG_ONE, g_msgSetFOV, {0,0,0}, id)
	write_byte(num)
	message_end()
}

reset_value_player(id)
{
	g_fastrun[id] = 0
	g_fastrun_wait[id] = 0
	
	remove_task(id+TASK_FASTRUN)
	remove_task(id+TASK_FASTRUN_HEARTBEAT)
	remove_task(id+TASK_FASTRUN_WAIT)
	remove_task(id+TASK_BOT_USE_SKILL)
}

zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			if (!is_user_connected(player))
				continue;
			
			static changed[5], changedcount
			changedcount = 0
			
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			vformat(buffer, charsmax(buffer), message, 3)
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	else
	{
		vformat(buffer, charsmax(buffer), message, 3)
		
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}
