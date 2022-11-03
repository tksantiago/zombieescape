#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>
#include <xs>

#define PLUGIN "DJB Zombie Class Banchee"
#define VERSION "1.0.3"
#define AUTHOR "Csoldjb&wbyokomo"

new const zclass_name[] = "Cadi Zombi (Banshee)"
new const zclass_info[] = "[Yetenek Icin 'G']"
new const zclass_model[] = "banchee_zombi_dp"
new const zclass_clawmodel[] = "v_knife_witch_zombi.mdl"
const zclass_health = 15000
const zclass_speed = 300
const Float:zclass_gravity = 0.68
const Float:zclass_knockback = 3.00
const zclass_level = 40

new const SOUND_FIRE[] = "ze_dp/zombi_banshee_pulling_fire.wav"
new const SOUND_BAT_HIT[] = "ze_dp/zombi_banshee_laugh.wav"
new const SOUND_BAT_MISS[] = "ze_dp/zombi_banshee_pulling_fail.wav"
new const SOUND_FIRE_CONFUSION[] = "ze_dp/zombi_banshee_confusion_fire.wav"
new const SOUND_CONFUSION_HIT[] = "ze_dp/zombi_banshee_confusion_keep.wav"
new const SOUND_CONFUSION_EXP[] = "ze_dp/zombi_banshee_confusion_explosion.wav"
new const MODEL_BAT[] = "models/bat_witch.mdl"
new const MODEL_BOMB[] = "models/w_zbombbb.mdl"
new const BAT_CLASSNAME[] = "banchee_bat"
new const CONFUSION_CLASSNAME[] = "banchee_bomb"
new const FAKE_PLAYER_CLASSNAME[] = "fake_player"
new spr_skull, spr_confusion_exp, spr_confusion_icon, spr_confusion_trail

const Float:banchee_skull_bat_speed = 600.0
const Float:banchee_skull_bat_flytime = 3.0
const Float:banchee_skull_bat_catch_time = 3.0
const Float:banchee_skull_bat_catch_speed = 100.0
const Float:bat_timewait = 20.0
const Float:confusion_time = 12.0

new g_stop[33]
new g_bat_time[33]
new g_bat_stat[33]
new g_bat_enemy[33]
new g_owner_confusion[33]
new g_fake_ent[33]
new g_is_confusion[33]

new idclass_banchee
new g_maxplayers
new g_roundend
new g_msgSayText, g_msgScreenFade, g_msgScreenShake

enum (+= 100)
{
	TASK_BOT_USE_SKILL = 2367,
	TASK_REMOVE_STAT,
	TASK_CONFUSION,
	TASK_SOUND
}

#define ID_BOT_USE_SKILL (taskid - TASK_BOT_USE_SKILL)
#define ID_TASK_REMOVE_STAT (taskid - TASK_REMOVE_STAT)
#define ID_CONFUSION (taskid - TASK_CONFUSION)
#define ID_SOUND (taskid - TASK_SOUND)

const UNIT_SECOND = (1<<12)
const FFADE_IN = 0x0000

public plugin_precache()
{
	precache_sound(SOUND_FIRE)
	precache_sound(SOUND_BAT_HIT)
	precache_sound(SOUND_BAT_MISS)
	precache_sound(SOUND_FIRE_CONFUSION)
	precache_sound(SOUND_CONFUSION_HIT)
	precache_sound(SOUND_CONFUSION_EXP)
	
	precache_model(MODEL_BAT)
	precache_model(MODEL_BOMB)
	
	spr_skull = precache_model("sprites/ef_bat.spr")
	spr_confusion_exp = precache_model("sprites/zombiebomb_exp.spr")
	spr_confusion_icon = precache_model("sprites/confused.spr")
	spr_confusion_trail = precache_model("sprites/smoke.spr")
	
	idclass_banchee = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_level)
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "EventHLTV", "a", "1=0", "2=0")
	register_event("DeathMsg", "EventDeath", "a")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_clcmd("drop", "cmd_bat")
	
	register_forward(FM_PlayerPreThink,"fw_PlayerPreThink")
	register_forward(FM_AddToFullPack, "fw_AddToFullPackPost", 1)
	
	RegisterHam(Ham_Touch,"info_target","EntityTouchPost",1)
	RegisterHam(Ham_Think,"info_target","EntityThink")
	
	g_maxplayers = get_maxplayers()
	g_msgSayText = get_user_msgid("SayText")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
}

public client_putinserver(id)
{
	reset_value_player(id)
}

public client_disconnect(id)
{
	reset_value_player(id)
}

public EventHLTV()
{
	g_roundend = 0
	
	RemoveAllFakePlayer()
	
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if (!is_user_connected(id)) continue;
		
		reset_value_player(id)
	}
}

public logevent_round_end()
{
	g_roundend = 1
}

public EventDeath()
{
	new id = read_data(2)
	
	reset_value_player(id)
}

public zp_user_infected_post(id)
{
	reset_value_player(id)
	
	if(zp_get_user_nemesis(id)) return;
	
	if(zp_get_user_zombie_class(id) == idclass_banchee)
	{
		if(is_user_bot(id))
		{
			set_task(random_float(5.0,15.0), "bot_use_skill", id+TASK_BOT_USE_SKILL)
			return
		}
		
		zp_colored_print(id, "^x04[ZE]^x01 Sinifinin yetenegi Yarasa Firlatma. Yuklenme suresi %.1f saniye.", bat_timewait)
	}
}

public zp_user_humanized_post(id)
{
	reset_value_player(id)
}

public CmdSecondSkill(id)
{
	if(g_roundend) return PLUGIN_CONTINUE
	
	if(!is_user_alive(id) || !zp_get_user_zombie(id) || zp_get_user_nemesis(id)) return PLUGIN_CONTINUE
	
	if(zp_get_user_zombie_class(id) == idclass_banchee && !g_bat_time[id] && get_user_weapon(id) == CSW_KNIFE)
	{
		g_bat_time[id] = 1
		
		FireConfusion(id)
		PlayWeaponAnimation(id, 7)
		set_task(bat_timewait,"clear_stat",id+TASK_REMOVE_STAT)
		
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public cmd_bat(id)
{
	if(g_roundend) return PLUGIN_CONTINUE
	
	if(!is_user_alive(id) || !zp_get_user_zombie(id) || zp_get_user_nemesis(id)) return PLUGIN_CONTINUE
	
	if(zp_get_user_zombie_class(id) == idclass_banchee && !g_bat_time[id] && get_user_weapon(id) == CSW_KNIFE)
	{
		g_bat_time[id] = 1
		
		set_task(bat_timewait,"clear_stat",id+TASK_REMOVE_STAT)
		
		new ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
		
		if(!pev_valid(ent)) return PLUGIN_HANDLED
		
		new Float:vecAngle[3],Float:vecOrigin[3],Float:vecVelocity[3],Float:vecForward[3]
		fm_get_user_startpos(id,5.0,2.0,-1.0,vecOrigin)
		pev(id,pev_angles,vecAngle)
		
		engfunc(EngFunc_MakeVectors,vecAngle)
		global_get(glb_v_forward,vecForward)
		
		velocity_by_aim(id,floatround(banchee_skull_bat_speed),vecVelocity)
		
		set_pev(ent,pev_origin,vecOrigin)
		set_pev(ent,pev_angles,vecAngle)
		set_pev(ent,pev_classname,BAT_CLASSNAME)
		set_pev(ent,pev_movetype,MOVETYPE_FLY)
		set_pev(ent,pev_solid,SOLID_BBOX)
		engfunc(EngFunc_SetSize,ent,{-20.0,-15.0,-8.0},{20.0,15.0,8.0})
		
		engfunc(EngFunc_SetModel,ent,MODEL_BAT)
		set_pev(ent,pev_animtime,get_gametime())
		set_pev(ent,pev_framerate,1.0)
		set_pev(ent,pev_owner,id)
		set_pev(ent,pev_velocity,vecVelocity)
		set_pev(ent,pev_nextthink,get_gametime()+banchee_skull_bat_flytime)
		emit_sound(ent, CHAN_WEAPON, SOUND_FIRE, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		g_stop[id] = ent
		
		PlayWeaponAnimation(id, 2)
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id)) return FMRES_IGNORED
	
	if(g_bat_stat[id])
	{
		new owner = g_bat_enemy[id], Float:ownerorigin[3]
		pev(owner,pev_origin,ownerorigin)
		static Float:vec[3]
		aim_at_origin(id,ownerorigin,vec)
		engfunc(EngFunc_MakeVectors, vec)
		global_get(glb_v_forward, vec)
		vec[0] *= banchee_skull_bat_catch_speed
		vec[1] *= banchee_skull_bat_catch_speed
		vec[2] = 0.0
		set_pev(id,pev_velocity,vec)
	}
	
	return FMRES_IGNORED
}

public fw_AddToFullPackPost(es_handled, inte, ent, host, hostflags, player, pSet)
{
	if (!is_user_alive(host)) return FMRES_IGNORED;
	
	static iAttacker
	iAttacker = g_owner_confusion[host]
	if (!iAttacker || iAttacker == host || !is_user_alive(iAttacker)) return FMRES_IGNORED;
		
	if (ent == iAttacker)
	{
		set_es(es_handled, ES_RenderMode, kRenderTransAdd)
		set_es(es_handled, ES_RenderAmt, 0.0)
		
		new fake_ent = find_ent_by_owner(-1, FAKE_PLAYER_CLASSNAME, iAttacker)
		if(!fake_ent || !pev_valid(fake_ent))
		{
			fake_ent = CreateFakePlayer(iAttacker)
		}
			
		g_fake_ent[iAttacker] = fake_ent
	}
	else if (ent == g_fake_ent[iAttacker])
	{
		set_es(es_handled, ES_RenderMode, kRenderNormal)
		set_es(es_handled, ES_RenderAmt, 255.0)
		set_es(es_handled, ES_ModelIndex, pev(host, pev_modelindex))
	}
	
	return FMRES_IGNORED
}

public EntityThink(ent)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	
	new classname[32]
	pev(ent,pev_classname,classname,31)
	
	if(equal(classname,BAT_CLASSNAME))
	{
		static Float:origin[3];
		pev(ent,pev_origin,origin);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		write_coord(floatround(origin[0]))
		write_coord(floatround(origin[1]))
		write_coord(floatround(origin[2]))
		write_short(spr_skull)
		write_byte(40)
		write_byte(30)
		write_byte(14)
		message_end()
		
		emit_sound(ent, CHAN_WEAPON, SOUND_BAT_MISS, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		new owner = pev(ent, pev_owner)
		g_stop[owner] = 0
		
		engfunc(EngFunc_RemoveEntity,ent)
	}
	
	return HAM_IGNORED
}

public EntityTouchPost(ent,ptd)
{
	if(!pev_valid(ent)) return HAM_IGNORED
	
	new classname[32]
	pev(ent,pev_classname,classname,31)
	
	if(equal(classname,BAT_CLASSNAME))
	{
		if(!pev_valid(ptd))
		{
			static Float:origin[3];
			pev(ent,pev_origin,origin);
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_EXPLOSION)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(spr_skull)
			write_byte(40)
			write_byte(30)
			write_byte(14)
			message_end()
			
			emit_sound(ent, CHAN_WEAPON, SOUND_BAT_MISS, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			new owner = pev(ent, pev_owner)
			g_stop[owner] = 0
			
			engfunc(EngFunc_RemoveEntity,ent)
			
			return HAM_IGNORED
		}
		
		new owner = pev(ent,pev_owner)
		
		if(0 < ptd && ptd <= g_maxplayers && is_user_alive(ptd) && ptd != owner)
		{
			g_bat_enemy[ptd] = owner
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, ptd)
			write_short(UNIT_SECOND)
			write_short(0)
			write_short(FFADE_IN)
			write_byte(150)
			write_byte(150)
			write_byte(150)
			write_byte(150)
			message_end()
			
			emit_sound(owner, CHAN_VOICE, SOUND_BAT_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM)
						
			set_pev(ent,pev_nextthink,get_gametime()+banchee_skull_bat_catch_time)
			set_task(banchee_skull_bat_catch_time,"clear_stat2",ptd+TASK_REMOVE_STAT)
			set_pev(ent,pev_movetype,MOVETYPE_FOLLOW)
			set_pev(ent,pev_aiment,ptd)
			
			g_bat_stat[ptd] = 1
		}
	}
	else if(equal(classname,CONFUSION_CLASSNAME))
	{		
		ConfusionExplode(ent, ptd)
		
		return HAM_IGNORED
	}
	
	return HAM_IGNORED
}

public clear_stat(taskid)
{
	new id = ID_TASK_REMOVE_STAT
	
	g_bat_stat[id] = 0
	g_bat_time[id] = 0
	
	zp_colored_print(id, "^x04[ZE]^x01 Yarasa Firlatma Yetenegin hazir.")
}

public clear_stat2(idx)
{
	new id = idx-TASK_REMOVE_STAT
	
	g_bat_enemy[id] = 0
	g_bat_stat[id] = 0
}

public bot_use_skill(taskid)
{
	new id = ID_BOT_USE_SKILL
	
	if (!is_user_alive(id)) return;
	
	new skill = random_num(0,1)
	switch(skill)
	{
		case 0: cmd_bat(id)
		case 1: CmdSecondSkill(id)
	}
	
	set_task(random_float(5.0,15.0), "bot_use_skill", id+TASK_BOT_USE_SKILL)
}

public ResetConfusion(taskid)
{
	g_owner_confusion[ID_CONFUSION] = 0
	g_is_confusion[ID_CONFUSION] = 0
	
	RemoveConfusionSprites(ID_CONFUSION)
}

public TaskConfusionSound(taskid)
{
	if(g_is_confusion[ID_SOUND]) emit_sound(ID_SOUND, CHAN_STREAM, SOUND_CONFUSION_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);
	else remove_task(taskid)
}

FireConfusion(id)
{
	new Float:vecAngle[3],Float:vecOrigin[3],Float:vecVelocity[3],Float:vecForward[3]
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	fm_get_user_startpos(id,5.0,2.0,-1.0,vecOrigin)
	pev(id,pev_angles,vecAngle)
	engfunc(EngFunc_MakeVectors,vecAngle)
	global_get(glb_v_forward,vecForward)
	velocity_by_aim(id,800,vecVelocity)
	set_pev(ent,pev_origin,vecOrigin)
	set_pev(ent,pev_angles,vecAngle)
	set_pev(ent,pev_classname,CONFUSION_CLASSNAME)
	set_pev(ent,pev_movetype,MOVETYPE_BOUNCE)
	set_pev(ent,pev_solid,SOLID_BBOX)
	set_pev(ent,pev_gravity,1.0)
	set_pev(ent,pev_sequence,1) //add
	set_pev(ent,pev_animtime,get_gametime()) //add
	set_pev(ent,pev_framerate,1.0) //add
	engfunc(EngFunc_SetSize,ent,{-1.0,-1.0,-1.0},{1.0,1.0,1.0})
	engfunc(EngFunc_SetModel,ent,MODEL_BOMB)
	set_pev(ent,pev_owner,id)
	set_pev(ent,pev_velocity,vecVelocity)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(spr_confusion_trail)
	write_byte(5)
	write_byte(3)
	write_byte(189)
	write_byte(183)
	write_byte(107)
	write_byte(62)
	message_end()
	
	emit_sound(ent, CHAN_WEAPON, SOUND_FIRE_CONFUSION, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

ConfusionExplode(ent, victim)
{
	if(!pev_valid(ent)) return;
	
	static Float:Origin[3]
	pev(ent, pev_origin, Origin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(floatround(Origin[0]))
	write_coord(floatround(Origin[1]))
	write_coord(floatround(Origin[2]))
	write_short(spr_confusion_exp)
	write_byte(40)
	write_byte(30)
	write_byte(14)
	message_end()
		
	emit_sound(ent, CHAN_WEAPON, SOUND_CONFUSION_EXP, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static owner; owner = pev(ent, pev_owner)
	
	if(is_user_alive(victim) && !zp_get_user_zombie(victim) && !g_is_confusion[victim])
	{
		g_owner_confusion[victim] = owner
		g_is_confusion[victim] = 1
		
		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(UNIT_SECOND)
		write_short(0)
		write_short(FFADE_IN)
		write_byte(189)
		write_byte(183)
		write_byte(107)
		write_byte (255)
		message_end()

		new shake[3]
		shake[0] = random_num(2,20)
		shake[1] = random_num(2,5)
		shake[2] = random_num(2,20)
		message_begin(MSG_ONE, g_msgScreenShake, _, victim)
		write_short(UNIT_SECOND*shake[0])
		write_short(UNIT_SECOND*shake[1])
		write_short(UNIT_SECOND*shake[2])
		message_end()
		
		emit_sound(victim, CHAN_STREAM, SOUND_CONFUSION_HIT, 1.0, ATTN_NORM, 0, PITCH_NORM)
		CreateConfusionSprites(victim)
		
		set_task(confusion_time, "ResetConfusion", victim+TASK_CONFUSION)
		set_task(2.0, "TaskConfusionSound", victim+TASK_SOUND, _, _, "b")
	}
	
	engfunc(EngFunc_RemoveEntity,ent)
}

fm_get_user_startpos(id,Float:forw,Float:right,Float:up,Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

aim_at_origin(id, Float:target[3], Float:angles[3])
{
	static Float:vec[3]
	pev(id,pev_origin,vec)
	vec[0] = target[0] - vec[0]
	vec[1] = target[1] - vec[1]
	vec[2] = target[2] - vec[2]
	engfunc(EngFunc_VecToAngles,vec,angles)
	angles[0] *= -1.0
	angles[2] = 0.0
}

PlayWeaponAnimation(id, animation)
{
	set_pev(id, pev_weaponanim, animation)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(animation)
	write_byte(pev(id, pev_body))
	message_end()
}

CreateFakePlayer(id)
{
	new ent = create_entity("info_target")
	set_pev(ent, pev_classname, FAKE_PLAYER_CLASSNAME)
	set_pev(ent, pev_modelindex, pev(id, pev_modelindex))
	set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(ent, pev_solid, SOLID_NOT)
	set_pev(ent, pev_aiment, id)
	set_pev(ent, pev_owner, id)
	set_pev(ent, pev_rendermode, kRenderTransAdd)
	set_pev(ent, pev_renderamt, 0.0)

	return ent
}

CreateConfusionSprites(id)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(id)
	write_coord(35)
	write_short(spr_confusion_icon)
	write_short(999)
	message_end()
}

RemoveConfusionSprites(id)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS)
	write_byte(id)
	message_end()
}

RemoveAllFakePlayer()
{	
	new ent
	ent = find_ent_by_class(-1, FAKE_PLAYER_CLASSNAME)
	
	while(ent > 0)
	{
		remove_entity(ent)
		ent = find_ent_by_class(-1, FAKE_PLAYER_CLASSNAME)
	}
}

reset_value_player(id)
{
	if(g_is_confusion[id]) RemoveConfusionSprites(id);
	
	g_stop[id] = 0
	g_bat_time[id] = 0
	g_bat_stat[id] = 0
	g_bat_enemy[id] = 0
	g_owner_confusion[id] = 0
	g_fake_ent[id] = 0
	g_is_confusion[id] = 0
	
	remove_task(id+TASK_BOT_USE_SKILL)
	remove_task(id+TASK_REMOVE_STAT)
	remove_task(id+TASK_CONFUSION)
	remove_task(id+TASK_SOUND)
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
