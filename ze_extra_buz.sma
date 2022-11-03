#include <amxmodx>
#include <fun>
#include <zombieplague>

new g_buz

public plugin_init()
{
	register_plugin("Extra Item: Frost Nade", "1.0", "DPCS")
	
	g_buz = zp_register_extra_item("Frostnade", 15, ZP_TEAM_HUMAN)
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid == g_buz)
	{
		give_item(id,"weapon_flashbang")
	}
}