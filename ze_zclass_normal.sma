/*================================================================================
	
	-----------------------------------
	-*- [ZP] Default Zombie Classes -*-
	-----------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This plugin adds the default zombie classes to Zombie Plague.
	Feel free to modify their attributes to your liking.
	
	Note: If zombie classes are disabled, the first registered class
	will be used for all players (by default, Classic Zombie).
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// Classic Zombie Attributes
new const zclass1_name[] = { "Normal Zombi (Classic)" }
new const zclass1_info[] = { "=Ayarli=" }
new const zclass1_model[] = { "tank_zombi_dp" }
new const zclass1_clawmodel[] = { "v_knife_tank_zombi.mdl" }
const zclass1_health = 15000
const zclass1_speed = 300
const Float:zclass1_gravity = 0.68
const Float:zclass1_knockback = 3.00
const zclass1_level = 0

/*============================================================================*/

// Zombie Classes MUST be registered on plugin_precache
public plugin_precache()
{
	register_plugin("[ZP] Default Zombie Classes", "4.3 Fix5", "MeRcyLeZZ")
	
	// Register all classes
	zp_register_zombie_class(zclass1_name, zclass1_info, zclass1_model, zclass1_clawmodel, zclass1_health, zclass1_speed, zclass1_gravity, zclass1_knockback, zclass1_level)
}