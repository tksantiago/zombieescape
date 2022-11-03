#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <global> 

// Prefix
#define xPREFIXCHAT "!y[!gStar!y]"
#define xPREFIXMENU "\y[\rStar\y]"


new RequiredEnt;
new bool:HasUsedButton;

public plugin_init()
{
	register_plugin( "[ZE] Heli Button Info", "1.0", "r0ck" );
	new iEnt1 = -1, iEnt2 = -1, Float:fspeed, Float:origin[3], Float:origin2[3], Float:fdistance, Float:ShortDistance = 99999.9, bool:FoundEnt;
	while ( (iEnt1 = engfunc( EngFunc_FindEntityByString, iEnt1, "classname", "path_track" ) ) != 0 )
	{
		pev( iEnt1, pev_speed, fspeed );
		if ( 2.0 < fspeed < 40.0 )
		{
			pev( iEnt1, pev_origin, origin );
			/* log_amx("track origin %f %f %f", origin[0], origin[1], origin[2]) */
			while ( (iEnt2 = engfunc( EngFunc_FindEntityByString, iEnt2, "classname", "func_button" ) ) != 0 )
			{
				fm_get_brush_entity_origin( iEnt2, origin2 );
				fdistance = get_distance_f( origin, origin2 );
				if ( fdistance < ShortDistance )
				{
					RequiredEnt   = iEnt2;
					ShortDistance = fdistance;
					/* log_amx("ent %i distance %f", iEnt2, fdistance) */
				}
				FoundEnt = true;
			}
			break;
		}
	}
	if ( !FoundEnt )
	{
		while ( (iEnt1 = engfunc( EngFunc_FindEntityByString, iEnt1, "classname", "trigger_multiple" ) ) != 0 )
		{
			fm_get_brush_entity_origin( iEnt1, origin );
			/* log_amx("trigger origin %f %f %f", origin[0], origin[1], origin[2]) */
			while ( (iEnt2 = engfunc( EngFunc_FindEntityByString, iEnt2, "classname", "func_button" ) ) != 0 )
			{
				fm_get_brush_entity_origin( iEnt2, origin2 );
				fdistance = get_distance_f( origin, origin2 );
				if ( fdistance < ShortDistance )
				{
					RequiredEnt   = iEnt2;
					ShortDistance = fdistance;
					/* log_amx("ent %i distance %f", iEnt2, fdistance) */
				}
				FoundEnt = true;
			}
			break;
		}
	}
	if ( FoundEnt )
	{
		register_logevent( "Event_RoundStart", 2, "0=World triggered", "1=Round_Start" );
		RegisterHam( Ham_Use, "func_button", "fwButtonUsed" );
	} else
		set_fail_state( "[ZE] Zombie Escape Button not found." );
}
public Event_RoundStart()
{
	HasUsedButton = false;
}
public fwButtonUsed( ent, idcaller )
{
	if ( !HasUsedButton && ent == RequiredEnt )
	{
		new szName[33]; get_user_name( idcaller, szName, charsmax( szName ) );
		print_colored( 0, "%s !g%s !tPressinou o Botão Fuga!", szName, xPREFIXCHAT);
		HasUsedButton = true;
	}
}
stock fm_get_brush_entity_origin( index, Float:origin[3] )
{
	new Float:mins[3], Float:maxs[3];
	pev( index, pev_origin, origin );
	pev( index, pev_mins, mins );
	pev( index, pev_maxs, maxs );
	origin[0] += (mins[0] + maxs[0]) * 0.5;
	origin[1] += (mins[1] + maxs[1]) * 0.5;
	origin[2] += (mins[2] + maxs[2]) * 0.5;
	return(1);
}
/* Color Stocks */
stock print_colored( const id, const input[], any: ... )
{
	new count = 1, players[32], i, player;
	static msg[191];
	if ( numargs() == 2 )
		copy( msg, 190, input );
	else
		vformat( msg, 190, input, 3 );
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	if ( id )
	{
		if ( !is_user_connected( id ) ) return;
		players[0] = id;
	} else get_players( players, count, "ch" );
	for ( i = 0; i < count; i++ )
	{
		player = players[i];
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, player );
		write_byte( player );
		write_string( msg );
		message_end();
	}
}
