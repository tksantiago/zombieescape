#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

#define PLUGIN "NST Zombie Class Heal"
#define VERSION "1.0"
#define AUTHOR "NST"

new const zclass_name[] = "Iyilesen Zombi (Heal)"
new const zclass_info[] = "[Yetenek Icin 'G']"
new const zclass_model[] = "heal_zombi_dp"
new const zclass_clawmodel[] = "v_knife_heal_zombi.mdl"
const zclass_health = 15000
const zclass_speed = 300
const Float:zclass_gravity = 0.68
const Float:zclass_knockback = 3.00
const zclass_level = 20

new idclass
new const zombie_sound_heal[] = "ze_dp/zombi_heal.wav"
new const zombie_sound_healteam[] = "ze_dp/td_heal.wav"

const Float:heal_timewait = 10.0
const Float:heal_dmg = 0.3
const heal_dmg_team = 500
new idsprites_heal

new g_heal_wait[33]
new g_msgDamage, g_msgScreenFade, g_msgSayText

new g_maxplayers
new g_roundend

enum (+= 100)
{
	TASK_WAIT_HEAL = 2000,
	TASK_BOT_USE_SKILL
}

#define ID_WAIT_HEAL (taskid - TASK_WAIT_HEAL)
#define ID_BOT_USE_SKILL (taskid - TASK_BOT_USE_SKILL)

public plugin_precache()
{
	precache_sound(zombie_sound_heal)
	precache_sound(zombie_sound_healteam)
	
	idsprites_heal = precache_model("sprites/zb_restore_health.spr")
	
	idclass = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "Death", "a")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_clcmd("drop", "cmd_heal")
	
	g_msgDamage = get_user_msgid("Damage")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgSayText = get_user_msgid("SayText")
	g_maxplayers = get_maxplayers()
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
		
		zp_colored_print(id, "^x04[ZE]^x01 Sinifinin yetenegi Iyilestirme. Yuklenme suresi %.1f saniye.", heal_timewait)
	}
}

public zp_user_humanized_post(id)
{
	reset_value_player(id)
}

public cmd_heal(id)
{
	if (g_roundend) return PLUGIN_CONTINUE
	
	if (!is_user_alive(id) || !zp_get_user_zombie(id) || zp_get_user_nemesis(id)) return PLUGIN_CONTINUE

	if (zp_get_user_zombie_class(id) == idclass && !g_heal_wait[id])
	{
		new start_health = zp_get_zombie_maxhealth(id)
		if (get_user_health(id)>=start_health) return PLUGIN_CONTINUE
		
		g_heal_wait[id] = 1
		
		new Float:health, Float:heath_up, health_set
		health = float(get_user_health(id))
		
		heath_up = health*heal_dmg
		health_set = floatround(health) + max(heal_dmg_team, floatround(heath_up))
		health_set = min(start_health, health_set)
		fm_set_user_health(id, health_set)
		
		UpdateHealthZombieTeam(id)
		PlaySound(id, zombie_sound_heal)
		EffectRestoreHealth(id)
		
		set_task(heal_timewait, "RemoveWaitSmoke", id+TASK_WAIT_HEAL)
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public bot_use_skill(taskid)
{
	new id = ID_BOT_USE_SKILL
	
	if (!is_user_alive(id)) return;

	cmd_heal(id)
	
	set_task(random_float(5.0,15.0), "bot_use_skill", id+TASK_BOT_USE_SKILL)
}

public RemoveWaitSmoke(taskid)
{
	new id = ID_WAIT_HEAL
	
	g_heal_wait[id] = 0
	
	zp_colored_print(id, "^x04[ZE]^x01 Iyilestirme Yetenegin hazir.")
}

UpdateHealthZombieTeam(id)
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		if (!is_user_alive(i) || zp_get_user_nemesis(i)) return;
		
		if (zp_get_user_zombie(i) && i != id)
		{
			new current_health = get_user_health(i)
			new start_health = zp_get_zombie_maxhealth(i)
			if (current_health < start_health)
			{
				new health_new
				health_new = min(start_health, (current_health+heal_dmg_team))
				fm_set_user_health(i, health_new)
				EffectRestoreHealth(i)
				PlaySound(i, zombie_sound_healteam)
			}
		}
	}
}

PlaySound(id, const sound[])
{
	client_cmd(id, "spk ^"%s^"", sound)
}

fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

EffectRestoreHealth(id)
{
	if (!is_user_alive(id)) return;
	
	static origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_short(idsprites_heal)
	write_byte(5)
	write_byte(192)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade , _, id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(0x0000)
	write_byte(255)
	write_byte(0)
	write_byte(0)
	write_byte(75)
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
	write_byte(0)
	write_byte(0)
	write_long(DMG_NERVEGAS)
	write_coord(0)
	write_coord(0)
	write_coord(0)
	message_end()
}

reset_value_player(id)
{
	g_heal_wait[id] = 0
	
	remove_task(id+TASK_WAIT_HEAL)
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
