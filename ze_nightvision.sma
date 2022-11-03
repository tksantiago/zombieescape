#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <zombieplague>

new g_nvg[33]

public plugin_init()
{
	register_plugin("[ZE] CSO:Nightvision", "1.0", "DPCS")
	register_clcmd("nightvision", "cmd_nightvision")
	register_clcmd("nvgver", "cmd_nvgver")
}

// NightVision
public cmd_nightvision(id)
{
	if (!is_user_alive(id) || !zp_get_user_zombie(id)) return PLUGIN_HANDLED;
	
	if (!g_nvg[id])
	{
		SwitchNvg(id, 1)
	}
	else
	{
		SwitchNvg(id, 0)
	}
	
	return PLUGIN_CONTINUE
}

public SwitchNvg(id, mode)
{
	if (!is_user_connected(id)) return;
	
	g_nvg[id] = mode
	set_user_nvision(id)
}

public set_user_nvision(id)
{
	if (!is_user_connected(id)) return;
	
	new alpha
	if (g_nvg[id]) alpha = 90
	else alpha = 0
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
	write_short(0) // duration
	write_short(0) // hold time
	write_short(0x0004) // fade type
	write_byte(253) // r
	write_byte(110) // g
	write_byte(110) // b
	write_byte(alpha) // alpha
	message_end()
}
// End of NightVision

public cmd_nvgver(id)
{
	set_task(random_float(0.1, 0.5), "set_user_nvision", id)
	SwitchNvg(id, 1)
}