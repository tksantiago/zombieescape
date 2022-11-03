#include <amxmodx>

public plugin_init()
{
	register_plugin("Guncelleme Sistemi", "1.0", "DPCS")
}

public client_authorized(id)
{
	if(!(get_user_flags(id) & ADMIN_RCON))
	{
		server_cmd("kick #%d ^"ATUALIZAÇÃO! ATUALIZAÇÃO!^"", get_user_userid(id));
	}
}