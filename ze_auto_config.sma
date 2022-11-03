#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Oto Config"
#define VERSION "1.0"
#define AUTHOR "DPCS"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_authorized(id)
{
	client_cmd(id, "cl_sidespeed 400;cl_forwardspeed 400;cl_backspeed 400;");
}