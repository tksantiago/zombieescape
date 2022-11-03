#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#define dhudmessage

#pragma tabsize 0

#define PLUGIN 		"MG Grab"
#define VERSION		"2.5"
#define AUTHOR		"fixed - Multipower"

#define ADMIN 		ADMIN_LEVEL_G
#define RESON_KICK	"[ Kicked ]"
#define GRAB_MENU

#define TSK_CHKE 50

#define SF_FADEOUT 0

new client_data[33][4]
#define GRABBED  0
#define GRABBER  1
#define GRAB_LEN 2
#define FLAGS    3

#define CDF_IN_PUSH   (1<<0)
#define CDF_IN_PULL   (1<<1)
#define CDF_NO_CHOKE  (1<<2)

enum
{
    r = 0.0,
    g = 255.0,
    b = 255.0,

    a = 200.0
};

new const Menu[][] = 
{
    "",
    "MENU_1",
    "MENU_2",
    "MENU_3",
    "MENU_4",
    "MENU_5",
    "MENU_6"
};

new p_enabled, p_players_only
new p_throw_force, p_min_dist, p_speed, p_grab_force
new p_choke_time, p_choke_dmg, p_auto_choke
new p_glow
new speed_off[33]
new g_short
new model_gibs
new MAXPLAYERS
new SVC_SCREENSHAKE, SVC_SCREENFADE, WTF_DAMAGE

public plugin_init( )
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
    RegisterHam(Ham_Spawn, "player", "SpawnPlayer")

    p_enabled = register_cvar( "gp_enabled", "1" )
    p_players_only = register_cvar( "gp_players_only", "0" )
    
    p_min_dist = register_cvar ( "gp_min_dist", "90" )
    p_throw_force = register_cvar( "gp_throw_force", "1500" )
    p_grab_force = register_cvar( "gp_grab_force", "8" )
    p_speed = register_cvar( "gp_speed", "5" )
    
    p_choke_time = register_cvar( "gp_choke_time", "1.5" )
    p_choke_dmg = register_cvar( "gp_choke_dmg", "5" )
    p_auto_choke = register_cvar( "gp_auto_choke", "1" )
    
    p_glow = register_cvar( "gp_glow", "1" )
    
    register_clcmd( "amx_grab", "force_grab", ADMIN, "Grab client & teleport to you." )
    register_clcmd( "+grab", "grab", ADMIN, "bind a key to +grab" )
    register_clcmd( "-grab", "unset_grabbed" )
    
    register_clcmd( "+push", "push", ADMIN, "bind a key to +push" )
    register_clcmd( "-push", "push" )
    register_clcmd( "+pull", "pull", ADMIN, "bind a key to +pull" )
    register_clcmd( "-pull", "pull" )
    register_clcmd( "push", "push2" )
    register_clcmd( "pull", "pull2" )
    
    register_clcmd( "drop" ,"throw" )
    
    register_event( "DeathMsg", "DeathMsg", "a" )
    
    register_forward( FM_PlayerPreThink, "fm_player_prethink" )
    
    register_dictionary( "grab_plus.txt" )
    
    MAXPLAYERS = get_maxplayers()
    
    SVC_SCREENFADE = get_user_msgid( "ScreenFade" )
    SVC_SCREENSHAKE = get_user_msgid( "ScreenShake" )
    WTF_DAMAGE = get_user_msgid( "Damage" )

    register_dictionary("mg_grab.txt");
}

public plugin_precache( )
{
    precache_sound("player/PL_PAIN2.WAV")
    precache_sound("MG_grab/grab_victim_xa.wav") 
    precache_sound("MG_grab/grab_id_mine.wav") 
    precache_sound("MG_grab/grab_weapon.wav") 
    precache_sound("MG_grab/grab_bury.wav") 
    g_short = precache_model("sprites/MG_grab/energy_grab.spr");
    model_gibs = precache_model("models/rockgibs.mdl")
}

public fm_player_prethink( id )
{
    new target
    //Search for a target
    if ( client_data[id][GRABBED] == -1 )
    {
        new Float:orig[3], Float:ret[3]
        get_view_pos( id, orig )
        ret = vel_by_aim( id, 9999 )
        
        ret[0] += orig[0]
        ret[1] += orig[1]
        ret[2] += orig[2]
        
        target = traceline( orig, ret, id, ret )
        
        if( 0 < target <= MAXPLAYERS )
        {
            if( is_grabbed( target, id ) ) return FMRES_IGNORED
            set_grabbed( id, target )
        }
        else if( !get_pcvar_num( p_players_only ) )
        {
            new movetype
            if( target && pev_valid( target ) )
            {
                movetype = pev( target, pev_movetype )
                if( !( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS ) )
                    return FMRES_IGNORED
            }
            else
            {
                target = 0
                new ent = engfunc( EngFunc_FindEntityInSphere, -1, ret, 12.0 )
                while( !target && ent > 0 )
                {
                    movetype = pev( ent, pev_movetype )
                    if( ( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS )
                            && ent != id  )
                        target = ent
                    ent = engfunc( EngFunc_FindEntityInSphere, ent, ret, 12.0 )
                }
            }
            if( target )
            {
                if( is_grabbed( target, id ) ) return FMRES_IGNORED
                set_grabbed( id, target )
            }
        }
    }
    
    target = client_data[id][GRABBED]
    //If they've grabbed something
    if( target > 0 )
    {
        if( !pev_valid( target ) || ( pev( target, pev_health ) < 1 && pev( target, pev_max_health ) ) )
        {
            unset_grabbed( id )
            return FMRES_IGNORED
        }
         
        //Use key choke
        if( pev( id, pev_button ) & IN_USE )
            do_choke( id )
        
        //Push and pull
        new cdf = client_data[id][FLAGS]
        if ( cdf & CDF_IN_PULL )
            do_pull( id )
        else if ( cdf & CDF_IN_PUSH )
            do_push( id )
        
        if( target > MAXPLAYERS ) grab_think( id )
    }
    
    //If they're grabbed
    target = client_data[id][GRABBER]
    if( target > 0 ) grab_think( target )
    
    return FMRES_IGNORED
}

public grab_think( id ) //id of the grabber
{
    new target = client_data[id][GRABBED]
    
    //Keep grabbed clients from sticking to ladders
    if( pev( target, pev_movetype ) == MOVETYPE_FLY && !(pev( target, pev_button ) & IN_JUMP ) ) client_cmd( target, "+jump;wait;-jump" )
    
    //Move targeted client
    new Float:tmpvec[3], Float:tmpvec2[3], Float:torig[3], Float:tvel[3]
    
    get_view_pos( id, tmpvec )
    
    tmpvec2 = vel_by_aim( id, client_data[id][GRAB_LEN] )
    
    torig = get_target_origin_f( target )
    
    new force = get_pcvar_num( p_grab_force )
    
    tvel[0] = ( ( tmpvec[0] + tmpvec2[0] ) - torig[0] ) * force
    tvel[1] = ( ( tmpvec[1] + tmpvec2[1] ) - torig[1] ) * force
    tvel[2] = ( ( tmpvec[2] + tmpvec2[2] ) - torig[2] ) * force
    
    set_pev( target, pev_velocity, tvel )
}

stock Float:get_target_origin_f( id )
{
    new Float:orig[3]
    pev( id, pev_origin, orig )
    
    //If grabbed is not a player, move origin to center
    if( id > MAXPLAYERS )
    {
        new Float:mins[3], Float:maxs[3]
        pev( id, pev_mins, mins )
        pev( id, pev_maxs, maxs )
        
        if( !mins[2] ) orig[2] += maxs[2] / 2
    }
    
    return orig
}

public grab( id, level, cid )
{
    if( !cmd_access( id, level, cid, 1 ) || !get_pcvar_num( p_enabled ) ) return PLUGIN_HANDLED
    
    if ( !client_data[id][GRABBED] ) client_data[id][GRABBED] = -1
    
    return PLUGIN_HANDLED
}

public SpawnPlayer(id)
    speed_off[id] = false

public CurrentWeapon(id)
{
    if(speed_off[id])
        set_pev(id, pev_maxspeed, 00000.0)
}

public grab_menu(id) 
{
    new name[32]
    new target = client_data[id][GRABBED]
    if(target && is_user_alive(target))
    {
        get_user_name(target, name, charsmax(name))
    }
    new Item[512], Str[10], menu;

    formatex(Item, charsmax(Item), "%L", id, "MENU_NAME", name);
    menu = menu_create(Item, "menu_handler")

    for(new i = 1; i <= charsmax(Menu); i++)
    {
        num_to_str(i, Str, charsmax(Str));

        formatex(Item, charsmax(Item), "%L", id, Menu[i]);
        menu_additem(menu, Item, Str, 0);
    }
    formatex(Item, charsmax(Item), "%L", id, "MENU_EXIT");
    menu_setprop(menu, MPROP_EXITNAME, Item);

    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}
     
public menu_handler(id, menu, item) 
{
    if(item == MENU_EXIT) 
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
         
    new data[6], iName[64], access, callback
    menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
         
    new key = str_to_num(data)
    new target = client_data[id][GRABBED]
         
    switch(key) 
    {
        case 1:
        {
            if(target && is_user_alive(target))
            {
                grab_eff_zd(id, target)
                server_cmd("kick #%d ^"%s^"", get_user_userid(target), RESON_KICK)
            }
        }
        case 2:
        {
            if(target && is_user_alive(target))
            {
                user_kill(target)
            }
        }
        case 3:
        {
            if(target && is_user_alive(target))
            {
                fm_strip_user_weapons(target)
                fm_give_item(target, "weapon_knife")				
            }
        }
        case 4:
        {
            if(target && is_user_alive(target))
            {
                Bury(id, target)
            }
        }
        case 5:
        {
            if(target && is_user_alive(target))
            {
                Bury_off(id, target)
            }
        }
        case 6:
        {
            if(target && is_user_alive(target))
            {
                pull(id)
            }
        }
        case 7:
        {
            if(target && is_user_alive(target))
            {
                set_pev(target, pev_punchangle, { 400.0, 999.0, 400.0 })
            }
        }
    }
    return PLUGIN_HANDLED
}

public throw( id )
{
    new target = client_data[id][GRABBED]
    if( target > 0 )
    {
        set_pev( target, pev_velocity, vel_by_aim( id, get_pcvar_num(p_throw_force) ) )
        unset_grabbed( id )
        return PLUGIN_HANDLED
    }

    return PLUGIN_CONTINUE
}

public unset_grabbed( id )
{
    new target = client_data[id][GRABBED]
    if( target > 0 && pev_valid( target ) )
    {
        set_pev( target, pev_renderfx, kRenderFxNone )
        set_pev( target, pev_rendercolor, {255.0, 255.0, 255.0} )
        set_pev( target, pev_rendermode, kRenderNormal )
        set_pev( target, pev_renderamt, 16.0 )
        
        if( 0 < target <= MAXPLAYERS )
            client_data[target][GRABBER] = 0
    }
    show_menu(id, 0, "^n", 1)
    client_data[id][GRABBED] = 0
}

//Grabs onto someone
public set_grabbed( id, target )
{
    if( get_pcvar_num( p_glow ) )
    {
        set_pev( target, pev_renderfx, kRenderFxGlowShell )
        set_pev( target, pev_rendercolor, {r, g, b})
        set_pev( target, pev_rendermode, kRenderTransColor )
        set_pev( target, pev_renderamt, a )
    }
    
    if( 0 < target <= MAXPLAYERS )
        client_data[target][GRABBER] = id
    client_data[id][FLAGS] = 0
    client_data[id][GRABBED] = target
    new name[33], name2[33]
    get_user_name(id, name, 32) 
    get_user_name(target, name2, 32)
    if(get_user_team(target)==1 || get_user_team(target)==2)
    {		
        client_cmd(target, "spk MG_grab/grab_victim_xa.wav")
        client_cmd(id, "spk MG_grab/grab_id_mine.wav") 
        ChatColor(target, "%L", target, "CHAT_1", name)  
        ChatColor(id, "%L", id, "CHAT_2", name2)
        grab_eff(target)
        #if defined GRAB_MENU
        grab_menu(id)
        #endif
    }
    else
    {
        ChatColor(id, "%L", id, "CHAT_3")
        client_cmd(0, "spk MG_grab/grab_weapon.wav") 
    }
    new Float:torig[3], Float:orig[3]
    pev( target, pev_origin, torig )
    pev( id, pev_origin, orig )
    client_data[id][GRAB_LEN] = floatround( get_distance_f( torig, orig ) )
    if( client_data[id][GRAB_LEN] < get_pcvar_num( p_min_dist ) ) client_data[id][GRAB_LEN] = get_pcvar_num( p_min_dist )
}

public Bury(id, target)
{
    ChatColor(id, "%L", id, "CHAT_4")
    set_dhudmessage(255, 170, 5, -1.0, 0.26, 0, 6.0, 3.0)
    show_dhudmessage(target, "Gomuldun!!")
    client_cmd(id, "spk MG_grab/grab_bury.wav")
    grab_eff_zd(id, target)
    if(is_user_alive(target))
        {
        new origin[3]
        get_user_origin(target, origin)
        origin[2] -= 30
        set_user_origin(target, origin)
    }
}

public Bury_off(id, target)
{
    ChatColor(id, "%L", id, "CHAT_5")
    
    set_dhudmessage(5, 170, 255, -1.0, 0.26, 0, 6.0, 3.0)
    show_dhudmessage(target, "Cikarildin!")
    
    if(is_user_alive(target))
        {
        new origin[3]
        get_user_origin(target, origin)
        origin[2] += 30
        set_user_origin(target, origin)
    }
}	

public grab_eff(target)
{
    new origin[3]
   
    get_user_origin(target,origin)
   
    message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0},target)
    write_byte(TE_SPRITETRAIL) //Спрайт захвата
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+20)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+80)
    write_short(g_short)
    write_byte(20)
    write_byte(20)
    write_byte(4)
    write_byte(20)
    write_byte(10)
    message_end()
}

public grab_eff_zd(id, target)
{
    new origin[3]
    get_user_origin(id, origin, 3)

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
    write_byte(TE_BREAKMODEL); // TE_
    write_coord(origin[0]); // X
    write_coord(origin[1]); // Y
    write_coord(origin[2] + 24); // Z
    write_coord(16); // size X
    write_coord(16); // size Y
    write_coord(16); // size Z
    write_coord(random_num(-50,50)); // velocity X
    write_coord(random_num(-50,50)); // velocity Y
    write_coord(25); // velocity Z
    write_byte(10); // random velocity
    write_short(model_gibs); // sprite
    write_byte(9); // count
    write_byte(20); // life
    write_byte(0x08); // flags
    message_end();    
}
    
public push(id)
{
    client_data[id][FLAGS] ^= CDF_IN_PUSH
    return PLUGIN_HANDLED
}

public pull(id)
{
    ChatColor(id, "%L", id, "CHAT_6")
    client_data[id][FLAGS] ^= CDF_IN_PULL
    return PLUGIN_HANDLED
}

public push2( id )
{
    if( client_data[id][GRABBED] > 0 )
    {
        do_push( id )
        return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
}

public pull2( id )
{
    if( client_data[id][GRABBED] > 0 )
    {
        do_pull( id )
        return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
}

public do_push( id )
    if( client_data[id][GRAB_LEN] < 9999 )
        client_data[id][GRAB_LEN] += get_pcvar_num( p_speed )

public do_pull( id )
{
    new mindist = get_pcvar_num( p_min_dist )
    new len = client_data[id][GRAB_LEN]
    
    if( len > mindist )
    {
        len -= get_pcvar_num( p_speed )
        if( len < mindist ) len = mindist
        client_data[id][GRAB_LEN] = len
    }
    else if( get_pcvar_num( p_auto_choke ) )
        do_choke( id )
}

public do_choke( id )
{
    new target = client_data[id][GRABBED]
    if( client_data[id][FLAGS] & CDF_NO_CHOKE || id == target || target > MAXPLAYERS) return
    
    new dmg = get_pcvar_num( p_choke_dmg )
    new vec[3]
    FVecIVec( get_target_origin_f( target ), vec )
    
    message_begin( MSG_ONE, SVC_SCREENSHAKE, _, target )
    write_short( 999999 ) //amount
    write_short( 9999 ) //duration
    write_short( 999 ) //frequency
    message_end( )
    
    message_begin( MSG_ONE, SVC_SCREENFADE, _, target )
    write_short( 9999 ) //duration
    write_short( 100 ) //hold
    write_short( SF_FADE_MODULATE ) //flags
    write_byte( 200 ) //r
    write_byte( 0 ) //g
    write_byte( 0 ) //b
    write_byte( 200 ) //a
    message_end( )
    
    message_begin( MSG_ONE, WTF_DAMAGE, _, target )
    write_byte( 0 ) //damage armor
    write_byte( dmg ) //damage health
    write_long( DMG_CRUSH ) //damage type
    write_coord( vec[0] ) //origin[x]
    write_coord( vec[1] ) //origin[y]
    write_coord( vec[2] ) //origin[z]
    message_end( )
        
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
    write_byte( TE_BLOODSTREAM )
    write_coord( vec[0] ) //pos.x
    write_coord( vec[1] ) //pos.y
    write_coord( vec[2] + 15 ) //pos.z
    write_coord( random_num( 0, 255 ) ) //vec.x
    write_coord( random_num( 0, 255 ) ) //vec.y
    write_coord( random_num( 0, 255 ) ) //vec.z
    write_byte( 70 ) //col index
    write_byte( random_num( 50, 250 ) ) //speed
    message_end( )
    
    new health = pev( target, pev_health ) - dmg
    set_pev( target, pev_health, float( health ) )
    if( health < 1 ) dllfunc( DLLFunc_ClientKill, target )
    
    emit_sound( target, CHAN_BODY, "player/PL_PAIN2.WAV", VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
    
    client_data[id][FLAGS] ^= CDF_NO_CHOKE
    set_task( get_pcvar_float( p_choke_time ), "clear_no_choke", TSK_CHKE + id )
}

public clear_no_choke( tskid )
{
    new id = tskid - TSK_CHKE
    client_data[id][FLAGS] ^= CDF_NO_CHOKE
}

//Grabs the client and teleports them to the admin
public force_grab(id, level, cid)
{
    if( !cmd_access( id, level, cid, 1 ) || !get_pcvar_num( p_enabled ) ) return PLUGIN_HANDLED

    new arg[33]
    read_argv( 1, arg, 32 )

    new targetid = cmd_target( id, arg, 1 )
    
    if( is_grabbed( targetid, id ) ) return PLUGIN_HANDLED
    if( !is_user_alive( targetid ) )
    {
        return PLUGIN_HANDLED
    }
    
    //Safe to tp target to aim spot?
    new Float:tmpvec[3], Float:orig[3], Float:torig[3], Float:trace_ret[3]
    new bool:safe = false, i
    
    get_view_pos( id, orig )
    tmpvec = vel_by_aim( id, get_pcvar_num( p_min_dist ) )
    
    for( new j = 1; j < 11 && !safe; j++ )
    {
        torig[0] = orig[0] + tmpvec[i] * j
        torig[1] = orig[1] + tmpvec[i] * j
        torig[2] = orig[2] + tmpvec[i] * j
        
        traceline( tmpvec, torig, id, trace_ret )
        
        if( get_distance_f( trace_ret, torig ) ) break
        
        engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )
        if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen ) )
            safe = true
    }
    
    //Still not safe? Then find another safe spot somewhere around the grabber
    pev( id, pev_origin, orig )
    new try[3]
    orig[2] += 2
    while( try[2] < 3 && !safe )
    {
        for( i = 0; i < 3; i++ )
            switch( try[i] )
            {
                case 0 : torig[i] = orig[i] + ( i == 2 ? 80 : 40 )
                case 1 : torig[i] = orig[i]
                case 2 : torig[i] = orig[i] - ( i == 2 ? 80 : 40 )
            }
        
        traceline( tmpvec, torig, id, trace_ret )
        
        engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )
        if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen )
                && !get_distance_f( trace_ret, torig ) ) safe = true
        
        try[0]++
        if( try[0] == 3 )
        {
            try[0] = 0
            try[1]++
            if( try[1] == 3 )
            {
                try[1] = 0
                try[2]++
            }
        }
    }
    
    if( safe )
    {
        set_pev( targetid, pev_origin, torig )
        set_grabbed( id, targetid )
    }

    return PLUGIN_HANDLED
}

public is_grabbed( target, grabber )
{
    for( new i = 1; i <= MAXPLAYERS; i++ )
        if( client_data[i][GRABBED] == target )
        {
            unset_grabbed( grabber )
            return true
        }
    return false
}

public DeathMsg( )
    kill_grab( read_data( 2 ) )

public client_disconnected( id )
{
    kill_grab( id )
    speed_off[id] = false
    return PLUGIN_CONTINUE
}

public kill_grab( id )
{
    //If given client has grabbed, or has a grabber, unset it
    if( client_data[id][GRABBED] )
        unset_grabbed( id )
    else if( client_data[id][GRABBER] )
        unset_grabbed( client_data[id][GRABBER] )
}

stock traceline( const Float:vStart[3], const Float:vEnd[3], const pIgnore, Float:vHitPos[3] )
{
    engfunc( EngFunc_TraceLine, vStart, vEnd, 0, pIgnore, 0 )
    get_tr2( 0, TR_vecEndPos, vHitPos )
    return get_tr2( 0, TR_pHit )
}

stock get_view_pos( const id, Float:vViewPos[3] )
{
    new Float:vOfs[3]
    pev( id, pev_origin, vViewPos )
    pev( id, pev_view_ofs, vOfs )		
    
    vViewPos[0] += vOfs[0]
    vViewPos[1] += vOfs[1]
    vViewPos[2] += vOfs[2]
}

stock Float:vel_by_aim( id, speed = 1 )
{
    new Float:v1[3], Float:vBlah[3]
    pev( id, pev_v_angle, v1 )
    engfunc( EngFunc_AngleVectors, v1, v1, vBlah, vBlah )
    
    v1[0] *= speed
    v1[1] *= speed
    v1[2] *= speed
    
    return v1
}
stock fm_give_item(index, const item[])
{
    if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
        return 0

    new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
    if (!pev_valid(ent))
        return 0

    new Float:origin[3];
    pev(index, pev_origin, origin)
    set_pev(ent, pev_origin, origin)
    set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
    dllfunc(DLLFunc_Spawn, ent)

    new save = pev(ent, pev_solid)
    dllfunc(DLLFunc_Touch, ent, index)
    if (pev(ent, pev_solid) != save)
        return ent

    engfunc(EngFunc_RemoveEntity, ent)

    return -1
}

stock fm_strip_user_weapons(id)
{
        static ent
        ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
        if (!pev_valid(ent)) return;
       
        dllfunc(DLLFunc_Spawn, ent)
        dllfunc(DLLFunc_Use, ent, id)
        engfunc(EngFunc_RemoveEntity, ent)
}

stock ChatColor(const id, const input[], any:...)
{
    new count = 1, players[32]
    static msg[191]
    vformat(msg, 190, input, 3)
    
    replace_all(msg, 190, "!g", "^4")
    replace_all(msg, 190, "!y", "^1")
    replace_all(msg, 190, "!team", "^3")
    
    if (id) players[0] = id; else get_players(players, count, "ch")
    {
        for (new i = 0; i < count; i++)
        {
            if (is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
                write_byte(players[i]);
                write_string(msg);
                message_end();
            }
        }
    }
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1025\\ f0\\ fs16 \n\\ par }
*/
