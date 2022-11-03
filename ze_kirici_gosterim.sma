#include <amxmodx>
#include <hamsandwich>
#include <engine>
public plugin_init()
{
    register_plugin("[ZE] Kirici Gosterim","1.0","Multipower")
    
    RegisterHam(Ham_TakeDamage,"func_breakable","Kirildi",1)
}

public Kirildi(ent, weapon, killer)
{
    if(entity_get_float(ent,EV_FL_health)<0)
    {
        static name[ 32 ];
        get_user_name( killer, name, charsmax( name ) );
        renkli_yazi(0,"!g[ZE] !y%s !thas broken something.",name)
        renkli_yazi(0,"!g[ZE] !y%s !tbirseyler kirdi.",name)
        return(HAM_IGNORED);
    }
    return(HAM_IGNORED);
}

stock renkli_yazi( const id, const input[], any: ... )
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
