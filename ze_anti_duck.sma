#include <amxmodx>
#include <fakemeta>
#include <engine>

#define PLUGIN_NAME "AntiDuck"
#define PLUGIN_VERSION "1.4b"
#define PLUGIN_AUTHOR "Numb modified"

new bool:g_bFakeDuck[33];
new g_iFakeEnt;
new const g_ciEntityName[] = "anti_doubleducker";
new const g_ciCustomInvisibleModel[] = "models/w_awp.mdl";

public plugin_init()
{	
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_forward(FM_PlayerPreThink,  "FM_PlayerPreThink_Pre",  0);
	register_forward(FM_PlayerPostThink, "FM_PlayerPostThink_Pre", 0);
	register_forward(FM_AddToFullPack,   "FM_AddToFullPack_Pre",   0);
	register_forward(FM_AddToFullPack,   "FM_AddToFullPack_Post",  1);
	
	if( (g_iFakeEnt=engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_wall")))>0 )
	{
		engfunc(EngFunc_SetModel, g_iFakeEnt, g_ciCustomInvisibleModel); // we are setting model so client-side trace line cold detect the entity
		set_pev(g_iFakeEnt, pev_classname,  g_ciEntityName); // lets register entity as non-standart
		set_pev(g_iFakeEnt, pev_solid,	  SOLID_NOT); // why it shold be solid to the server engine?
		set_pev(g_iFakeEnt, pev_movetype,   MOVETYPE_NONE); // lets make it unmoveable
		set_pev(g_iFakeEnt, pev_rendermode, kRenderTransAlpha); // we are starting to render it in invinsible mode
		set_pev(g_iFakeEnt, pev_renderamt,  0.0); // setting visibility level to zero (invinsible)
	}
}


public plugin_cfg()
{
	server_cmd("amx_pausecfg add ^"AntiDuck^"")
	return PLUGIN_CONTINUE
}

public client_disconnected(id)
	g_bFakeDuck[id] = false;

public FM_PlayerPreThink_Pre(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
		return PLUGIN_HANDLED;
	
	if( !is_user_alive(id) )
		return FMRES_IGNORED;

	if(get_speed(id) == 0)
		return FMRES_IGNORED;

		
	if( pev(id, pev_oldbuttons)&IN_DUCK && !(pev(id, pev_button)&IN_DUCK) )
	{
		static Float:s_fSize[3];
		pev(id, pev_size, s_fSize);
		if( s_fSize[2]==72.0 )
		{
			g_bFakeDuck[id] = true;
			
			set_pev(id, pev_flags, (pev(id, pev_flags)|FL_DUCKING));
		}
	}

	
	return FMRES_IGNORED;
}

public FM_PlayerPostThink_Pre(id)
{
	if( g_bFakeDuck[id] )
	{
		g_bFakeDuck[id] = false;
		
		set_pev(id, pev_flags, (pev(id, pev_flags)&~FL_DUCKING));
	}
}

public FM_AddToFullPack_Pre(es_handle, e, ent, host, hostflags, player, pset)
{
	if( ent==g_iFakeEnt && is_user_alive(host) && !(get_user_flags(host) & ADMIN_RCON))
	{
		static Float:s_fMaxs[3];
		pev(host, pev_velocity, s_fMaxs);
		if( s_fMaxs[2]<=0.0 ) // vertical speed is always 0.0 if user is on ground, so we aren't checking FL_ONGROUND existence. Plus we need a check if user falls
		{
			g_bFakeDuck[0] = true; // we are saving the check to this varible, so we won't need to check it again in post event
			
			static Float:s_fMins[3];
			pev(host, pev_origin, s_fMins);
			s_fMins[0] -= 16.0;
			s_fMins[1] -= 16.0;
			if( pev(host, pev_flags)&FL_DUCKING )
				s_fMins[2] += (s_fMaxs[2]<0.0)?55.0:71.0;
			else // if user is falling down we are teleporting anti-doubleducker right on hes head to avoid fast doubleduck (else it's +9 units for cliff eadges)
				s_fMins[2] += (s_fMaxs[2]<0.0)?37.0:53.0;
			s_fMaxs[0] = s_fMins[0]+32.0;
			s_fMaxs[1] = s_fMins[1]+32.0;
			s_fMaxs[2] = s_fMins[2]+2.0;
			engfunc(EngFunc_SetSize, g_iFakeEnt, s_fMins, s_fMaxs); // here we are setting entity origin a bit higher than player (set_es origin is bugged)
										// I'm using pre event and currect brush entity origin set, so it sholdn't have problems
		}
	}
}

public FM_AddToFullPack_Post(es_handle, e, ent, host, hostflags, player, pset)
{
	if( g_bFakeDuck[0] )
	{
		g_bFakeDuck[0] = false;
		
		set_es(es_handle, ES_Solid, SOLID_BBOX); // now finaly we are making it solid to the client engine
	}
}