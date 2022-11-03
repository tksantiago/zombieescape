#include <amxmodx>
#include <hamsandwich>
#include <zombieplague>

#define MAX_PLAYERS    32

// Integers
new g_iMaxPlayers
new g_iPlayerPos[MAX_PLAYERS+1]

// Bools
new bool:g_bIsConnected[33]
new const Float:g_flCoords[][] = 
{
    {0.15, -1.0},
    {0.20, -1.0},
    {0.25, -1.0},
    {0.30, -1.0},
    {0.35, -1.0},
    {0.40, -1.0},
    {0.35, -1.0},
    {0.30, -1.0},
    {0.25, -1.0},
    {0.20, -1.0}
}

// Macros
#define IsConnected(%1) (1 <= %1 <= g_iMaxPlayers && g_bIsConnected[%1])

#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "meTaLiCroSS"

public plugin_init() 
{
    register_plugin("[ZP] Addon: Zombie HP Displayer", PLUGIN_VERSION, PLUGIN_AUTHOR)
    
    RegisterHam(Ham_TakeDamage, "player", "fw_Player_TakeDamage_Post", 1)
    
    g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(iId) g_bIsConnected[iId] = true
public client_disconnected(iId) g_bIsConnected[iId] = false

public fw_Player_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, iDamageType)
{
    if(!IsConnected(iAttacker) || iVictim == iAttacker)
        return HAM_IGNORED
    
    if(zp_get_user_zombie(iVictim))
    {
        new iVictimHealth = get_user_health(iVictim)
        if(1 <= iAttacker <= g_iMaxPlayers)
        {
            new iPos = ++g_iPlayerPos[iAttacker]
            if( iPos == sizeof(g_flCoords) )
            {
                iPos = g_iPlayerPos[iAttacker] = 0
            }
            set_hudmessage(0, 40, 80, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
            show_hudmessage(iAttacker, "%d", iVictimHealth)  
        }
    }
    
    return HAM_IGNORED
}