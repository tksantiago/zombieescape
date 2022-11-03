#include <amxmisc>
#include <cstrike>
#include <zombieplague>

#define DECREASE_FRAG; // Comment if you don't want to decrease player's frags

#if defined DECREASE_FRAG
        #define KILL_FLAG 0
#else
        #define KILL_FLAG 1
#endif

new g_iMaxPlrs;

public plugin_init()
{
        register_plugin("Slay Team", "1.0", "hleV");
 
        register_concmd("amx_slayt", "cmdSlayT", ADMIN_SLAY, "- slays Ts");
        register_concmd("amx_slayct", "cmdSlayCT", ADMIN_SLAY, "- slays CTs");
 
        g_iMaxPlrs = get_maxplayers();
}

public cmdSlayT(iCl, iLvl, iCmd)
{
        if (!cmd_access(iCl, iLvl, iCmd, 1))
                return PLUGIN_HANDLED;
 
        for (new iCl = 1; iCl <= g_iMaxPlrs; iCl++)
                if (is_user_alive(iCl) && zp_get_user_zombie(iCl))
                        user_kill(iCl, KILL_FLAG);
 
        return PLUGIN_HANDLED;
}

public cmdSlayCT(iCl, iLvl, iCmd)
{
        if (!cmd_access(iCl, iLvl, iCmd, 1))
                return PLUGIN_HANDLED;
 
        for (new iCl = 1; iCl <= g_iMaxPlrs; iCl++)
                if (is_user_alive(iCl) && !zp_get_user_zombie(iCl))
                        user_kill(iCl, KILL_FLAG);
 
        return PLUGIN_HANDLED;
}