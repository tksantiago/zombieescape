#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>
#include <xs>

#define PLUGIN "[ZP] Addon: Infect-Effect"
#define VERSION "1.0"
#define AUTHOR "Dias"

new g_effect_id[33], g_had_effect[33]
new const effect_model[] = "sprites/infect-effect.spr"

new cvar_scale, cvar_showtime, cvar_lightlevel

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "fw_spawn_post", 1)
	register_forward(FM_AddToFullPack, "fw_WhatTheFuck_Post", 1)
	
	cvar_scale = register_cvar("zp_in-ef_scale", "0.035")
	cvar_showtime = register_cvar("zp_in-ef_showtime", "1.0")
	cvar_lightlevel = register_cvar("zp_in-ef_lightlevel", "100.0")
}

public plugin_precache()
{
	precache_model(effect_model)
}

public fw_spawn_post(id)
{
	if(g_had_effect[id])
		remove_effect(id)
}

public zp_user_infected_post(id, attacker)
{
	if(is_user_alive(attacker))
	{
		show_effect(id)
	}
}

public show_effect(id)
{
	g_effect_id[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	if (!pev_valid(g_effect_id[id]))
		return
	
	g_had_effect[id] = 1
	
	set_pev(g_effect_id[id], pev_solid, SOLID_NOT)
	set_pev(g_effect_id[id], pev_movetype, MOVETYPE_NONE)

	engfunc(EngFunc_SetModel, g_effect_id[id], effect_model)
	
	set_pev(g_effect_id[id], pev_rendermode, kRenderTransAlpha)
	set_pev(g_effect_id[id], pev_renderamt, 0.0)
	set_pev(g_effect_id[id], pev_owner, id)
	set_pev(g_effect_id[id], pev_scale, get_pcvar_float(cvar_scale))
	set_pev(g_effect_id[id], pev_light_level, get_pcvar_float(cvar_lightlevel))
	
	set_task(get_pcvar_float(cvar_showtime), "remove_effect", g_effect_id[id])
}

public fw_WhatTheFuck_Post(es, e, ent, host, host_flags, player, p_set)
{
	if(!(0 < host < 33))
		return FMRES_IGNORED
		
	if(ent != g_effect_id[host] || !pev_valid(ent))
		return FMRES_IGNORED
		
	if(pev(ent, pev_owner) != host)
		return FMRES_IGNORED
		
	if(!is_user_alive(host))
		return FMRES_IGNORED
		
	static Float:origin[3], Float:forvec[3], Float:voffsets[3], Float:Angles[3]
	
	pev(host, pev_origin, origin)
	pev(host, pev_view_ofs, voffsets)
	pev(host, pev_angles, Angles)
	
	xs_vec_add(origin, voffsets, origin)
	
	// Get a forward vector in the direction of player's aim
	velocity_by_aim(host, 10, forvec)
	
	// Set the sprite on the new origin
	xs_vec_add(origin, forvec, origin)
	
	engfunc(EngFunc_SetOrigin, ent, origin)
	set_es(es, ES_Origin, origin)
	set_es(es, ES_Angles, Angles)
	
	// Make the sprite visible
	set_es(es, ES_RenderMode, kRenderTransAdd)
	set_es(es, ES_RenderAmt, 200)
		
	return FMRES_HANDLED
}

public remove_effect(ent)
{
	g_had_effect[pev(ent, pev_owner)] = 0
	
	if(pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)
}
