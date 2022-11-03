#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>
#include <engine>

#define PLUGIN "[ZP] Class - Ghost"
#define VERSION "1.3"
#define AUTHOR "HoRRoR, Fry!"

// Zombie Attributes
new g_zclass_ghost
new const zclass_name[] = "Ghost" // name
new const zclass_info[] = "['R']" // description
new const zclass_model[] = "star_zm_lusty" // model
new const zclass_clawmodel[] = "v_knife_lusty.mdl" // claw model
const zclass_health = 15000 // health
const zclass_speed = 300 // speed
const Float:zclass_gravity = 0.68 // gravity
const Float:zclass_knockback = 3.00// knockback
const zclass_lvl = 50

new i_stealth_time_hud[33]
new g_cooldown[33]
new g_infections[33]
new Float:g_stealth_time[33]
new i_cooldown_time[33]
new g_maxplayers

// --- config ------------------------ //
new Float:g_stealth_time_standart = 8.0 //first stealth time
new Float:g_stealth_cooldown_standart = 30.0 //cooldown time
new const sound_ghost_stealth[] = "ze_star/star_lusty.wav" //stealth sound
// ----------------------------------- //

new g_msgSayText

public plugin_init()
{	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("zp_zclass_ghost_zombie",VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_logevent("roundStart", 2, "1=Round_Start")
	g_maxplayers = get_maxplayers()
	g_msgSayText = get_user_msgid("SayText")
}

public plugin_precache()
{
	g_zclass_ghost = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback, zclass_lvl)
	precache_sound(sound_ghost_stealth)
}

public roundStart()
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		i_cooldown_time[i] = floatround(g_stealth_cooldown_standart)
		g_cooldown[i] = 0
		remove_task(i)
	}
}

public zp_user_humanized_post(id)
{
	for (new i = 1; i <= g_maxplayers; i++)
	{
		i_cooldown_time[i] = floatround(g_stealth_cooldown_standart)
		g_cooldown[i] = 0
		remove_task(i)
	}
}

public use_ability_one(id)
{
	if(is_valid_ent(id) && is_user_alive(id) && zp_get_user_zombie(id) && !zp_get_user_nemesis(id) && zp_get_user_zombie_class(id) == g_zclass_ghost)
	{
		if(g_cooldown[id] == 0)
		{
			set_user_rendering(id, kRenderFxGlowShell, 50, 50, 50, kRenderTransAlpha, 10)
			emit_sound(id, CHAN_STREAM, sound_ghost_stealth, 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_task(g_stealth_time[id],"ghost_make_visible",id)
			set_task(g_stealth_cooldown_standart,"reset_cooldown",id)
			g_cooldown[id] = 1
			
			i_cooldown_time[id] = floatround(g_stealth_cooldown_standart)
			i_stealth_time_hud[id] = floatround(g_stealth_time[id])
			
			set_task(1.0, "ShowHUD", id, _, _, "a",i_cooldown_time[id])
		}
	}
}

public ghost_make_visible(id)
{
	if(is_valid_ent(id) && zp_get_user_zombie(id) && !zp_get_user_nemesis(id) && zp_get_user_zombie_class(id) == g_zclass_ghost)
	{
		set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
	}
}

public ShowHUD(id)
{
	if(is_valid_ent(id) && is_user_alive(id))
	{
		i_cooldown_time[id] = i_cooldown_time[id] - 1;
	}else{
		remove_task(id)
	}
}

public reset_cooldown(id)
{
	if(is_valid_ent(id) && zp_get_user_zombie(id) && !zp_get_user_nemesis(id) && zp_get_user_zombie_class(id) == g_zclass_ghost)
	{
		g_cooldown[id] = 0
		
		zp_colored_print(id, "^x04[Star]^x01Sua habilidade ^x04Invisibilidade^x01 esta pronto.")
	}
}

public zp_user_infected_post(id, infector)
{
	if ((zp_get_user_zombie_class(id) == g_zclass_ghost) && !zp_get_user_nemesis(id))
	{	
		new text[100]
		zp_colored_print(id, "^x04[Star]^x01 Sua habilidade e^x04 Invisibilidade^x01. Tempo^x04 %.1f ^x01seconds.", g_stealth_cooldown_standart)
		message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
		write_byte(id) 
		write_string(text) 
		message_end()
		
		i_cooldown_time[id] = floatround(g_stealth_cooldown_standart)
		remove_task(id)
		
		g_stealth_time[id] = g_stealth_time_standart
		g_cooldown[id] = 0
		g_infections[id] = 0
	}
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	
	if(zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_zclass_ghost))
	{		
		if ((oldbutton & IN_RELOAD) && !(button & IN_RELOAD))
			use_ability_one(id)
	}
	
	return PLUGIN_CONTINUE
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
