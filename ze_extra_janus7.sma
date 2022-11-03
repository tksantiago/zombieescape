#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

#define get_bit(%1,%2)		(%1 & (1 << (%2 & 31)))
#define set_bit(%1,%2)		%1 |= (1 << (%2 & 31))
#define reset_bit(%1,%2)	%1 &= ~(1 << (%2 & 31))

#define EV_INT_WEAPONKEY	EV_INT_impulse
#define WEAPONKEY 7
#define JANUS7_CLIPAMMO	200
#define JANUS7_BPAMMO	200
#define JANUS7_DAMAGE	39
#define SHOTS_NEED	5
#define RELOAD_TIME 4.7
#define wId CSW_M249

#define JANUS7_VMODEL "models/ls/v_janus7.mdl"
#define JANUS7_PMODEL "models/ls/p_janus7.mdl"
#define JANUS7_WMODEL "models/ls/w_janus7.mdl"

new g_SmokePuff_SprId
new const Fire_snd[][] = {"weapons/janus7-1.wav", "weapons/janus7-2.wav"};

new const Reload_snd[][] = {"weapons/mg3_clipin.wav", "weapons/mg3_clipout.wav", "weapons/mg3_close.wav", "weapons/mg3_open.wav"};
new const went[] ="weapon_m249";
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 };

new  g_itemid_janus7,g_mode[33], g_shots[33], g_sprite, g_sprite1, g_target[33],
          g_sound[33],g_has_janus7[33],g_orig_event_janus7, g_clip_ammo[33],
          Float:cl_pushangle[33][3], m_iBlood[2], g_janus7_TmpClip[33], g_bitsMuzzleFlash, g_iEntity;

public plugin_init()
{
	register_plugin("Janus-7",		"1.0",		"kademik");
	register_clcmd("weapon_janus7", "Hook_Select");
	
	register_event("CurWeapon",	"CurrentWeapon",	"be","1=1");
	
	RegisterHam(Ham_Item_AddToPlayer,	went,	 	"fw_janus7_AddToPlayer");
	RegisterHam(Ham_Item_Deploy,		went,	 	"fw_Item_Deploy_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack,	went,	 	"fw_janus7_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack,	went,	 	"fw_janus7_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_PostFrame,		went,	 	"janus7__ItemPostFrame");
	RegisterHam(Ham_Weapon_Reload,		went, 		"janus7__Reload");
	RegisterHam(Ham_Weapon_Reload,		went, 		"janus7__Reload_Post", 1);
	RegisterHam(Ham_TakeDamage, 		"player",	 "fw_TakeDamage");
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	
	register_forward(FM_AddToFullPack,	 "CPlayer__AddToFullPack_post", 1);
	register_forward(FM_CheckVisibility,	 "CEntity__CheckVisibility");
	register_forward(FM_SetModel,		 "fw_SetModel");
	register_forward(FM_UpdateClientData,	 "fw_UpdateClientData_Post", 1);
	register_forward(FM_PlaybackEvent,	 "fwPlaybackEvent");

	g_itemid_janus7 = zp_register_extra_item("Janus-7", 50, ZP_TEAM_HUMAN);
	
}

public plugin_precache()
{
	precache_model(JANUS7_VMODEL);
	precache_model(JANUS7_PMODEL);
	precache_model(JANUS7_WMODEL);
	g_sprite = precache_model("sprites/ls/lgtning.spr");
	g_sprite1 = precache_model("sprites/ls/colflare.spr");
	precache_generic( "sprites/weapon_janus7.txt" );
	precache_generic( "sprites/ls/640hud7.spr" );
	precache_generic( "sprites/ls/640hud12.spr" );
	precache_generic( "sprites/ls/640hud99.spr" );

	precache_sound(Fire_snd[0]);
	precache_sound(Fire_snd[1]);
	precache_sound(Reload_snd[0]);
	precache_sound(Reload_snd[1]);
	precache_sound(Reload_snd[2]);
	precache_sound(Reload_snd[3]);
	precache_sound("weapons/janus7_change1.wav");
	precache_sound("weapons/janus7_change2.wav");
	
	m_iBlood[0] = precache_model("sprites/blood.spr");
	m_iBlood[1] = precache_model("sprites/bloodspray.spr");
	precache_model("sprites/ls/muzzleflash_janus7.spr");
	g_SmokePuff_SprId = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr");
	g_iEntity = create_entity("info_target");
	
	entity_set_model(g_iEntity, "sprites/ls/muzzleflash_janus7.spr");
	
	entity_set_float(g_iEntity, EV_FL_scale, 0.1);
	
	entity_set_int(g_iEntity, EV_INT_rendermode, kRenderTransTexture);
	entity_set_float(g_iEntity, EV_FL_renderamt, 0.0);

	
	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1);
	
}

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/m249.sc", name))
	{
		g_orig_event_janus7 = get_orig_retval();
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public Hook_Select(id)
{
	engclient_cmd(id, went);
	return PLUGIN_HANDLED;
}


public client_connect(id)
{
	g_has_janus7[id] = false;
}

public client_disconnected(id)
{
	g_has_janus7[id] = false;
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_has_janus7[id] = false;
		g_sound[id] = false;
		emit_sound(id, CHAN_WEAPON, Fire_snd[g_mode[id]], 0.0, ATTN_NORM, 0, PITCH_NORM);
		g_mode[id] = false;
		g_shots[id] = false;
	}
}

public fw_PlayerKilled(id)
{
	g_has_janus7[id] = false;
	g_sound[id] = false;
	emit_sound(id, CHAN_WEAPON, Fire_snd[g_mode[id]], 0.0, ATTN_NORM, 0, PITCH_NORM);
	g_mode[id] = false;
	g_shots[id] = false;
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED;
		
	static szClassName[33];
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED;
	static iOwner;
	iOwner = entity_get_edict(entity, EV_ENT_owner);
	if(equal(model, "models/w_m249.mdl"))
	{
		static iStoredSVDID;
		iStoredSVDID = find_ent_by_owner(-1, went, entity);
		if(!is_valid_ent(iStoredSVDID))
			return FMRES_IGNORED;
		if(g_has_janus7[iOwner])
		{
			entity_set_int(iStoredSVDID, EV_INT_WEAPONKEY, WEAPONKEY);
			g_has_janus7[iOwner] = false;
			entity_set_model(entity, JANUS7_WMODEL);
			g_mode[iOwner] = false;
			g_shots[iOwner] = false;
			remove_task(iOwner+1231);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public CEntity__CheckVisibility(iEntity, pSet)
{
	if (iEntity != g_iEntity)
		return FMRES_IGNORED;
	
	forward_return(FMV_CELL, 1);
	
	return FMRES_SUPERCEDE;
}


public give_janus7(id)
{
	drop_weapons(id, 1);
	new iWep2 = fm_give_item(id,went);
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, JANUS7_CLIPAMMO);
		cs_set_user_bpammo (id, wId, JANUS7_BPAMMO);
	}
	g_has_janus7[id] = true;
	g_shots[id] = 0;
	g_mode[id] = false;
	Sprite(id, 1);
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid == g_itemid_janus7)
	{
		give_janus7(id);
	}
}

public fw_janus7_AddToPlayer(janus7, id)
{
	if(!is_valid_ent(janus7) || !is_user_connected(id))
		return HAM_IGNORED;
		
	if(entity_get_int(janus7, EV_INT_WEAPONKEY) == WEAPONKEY)
	{
		g_has_janus7[id] = true;
		g_mode[id] = false;
		g_shots[id] = 0;
		g_sound[id] = 0;
		entity_set_int(janus7, EV_INT_WEAPONKEY, 0);
		Sprite(id, 1);
		return HAM_HANDLED;
	}
	else Sprite(id, 0);
	return HAM_IGNORED;
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner;
	owner = pev(weapon_ent, pev_owner);
	static weaponid;
	weaponid = cs_get_weapon_id(weapon_ent);
	replace_weapon_models(owner, weaponid);
}

public CurrentWeapon(id)	replace_weapon_models(id, read_data(2));

replace_weapon_models(id, weaponid)
{
	static g_wpn[33];
	switch (weaponid)
	{
		case wId:
		{
			if(is_user_alive(id) && is_user_connected(id) && g_has_janus7[id])
			{
				if (zp_get_user_zombie(id) || zp_get_user_survivor(id))
					return;
				if(g_wpn[id] != CSW_M249){
					if( g_mode[id]) UTIL_PlayWeaponAnimation(id, 8);
					else UTIL_PlayWeaponAnimation(id, g_shots[id]>50?14:2);
				}
				set_pev(id, pev_viewmodel2, JANUS7_VMODEL);
				set_pev(id, pev_weaponmodel2, JANUS7_PMODEL);
			}
		}
	}
	if(is_user_alive(id))g_wpn[id] = get_user_weapon(id);
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != wId) || !g_has_janus7[Player])
		return FMRES_IGNORED;
		
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001);
	return FMRES_HANDLED;
}

public fw_janus7_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4);
	if (!g_has_janus7[Player])
		return HAM_IGNORED;
	pev(Player,pev_punchangle,cl_pushangle[Player]);
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon);
	
	if( g_mode[Player] ) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_janus7))
		return FMRES_IGNORED;
		
	if (!(1 <= invoker <= get_maxplayers()))
		return FMRES_IGNORED;
		
	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_SUPERCEDE;
}

public fw_janus7_PrimaryAttack_Post(Weapon) {
	
	new Player = get_pdata_cbase(Weapon, 41, 4);
	new szClip, szAmmo;
	get_user_weapon(Player, szClip, szAmmo);
	if(Player > 0 && Player < 33)
	{
		if(g_has_janus7[Player])
		{
			if(szClip > 0 && !g_sound[Player]) {
				emit_sound(Player, CHAN_WEAPON, Fire_snd[g_mode[Player]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				if(g_mode[Player])g_sound[Player] = true;
			}
		}
		if(g_has_janus7[Player])
		{
			new Float:push[3];
			pev(Player,pev_punchangle,push);
			xs_vec_sub(push,cl_pushangle[Player],push);
			xs_vec_mul_scalar(push,0.6,push);
			xs_vec_add(push,cl_pushangle[Player],push);
			set_pev(Player,pev_punchangle,push);
			if (!g_clip_ammo[Player])
				return;
			set_pdata_float(Player, 83, g_mode[Player]?0.05:0.1);
			if(g_mode[Player]) UTIL_PlayWeaponAnimation(Player, random_num(9,10));
			else UTIL_PlayWeaponAnimation(Player, g_shots[Player]>=SHOTS_NEED?5:random_num(3,4));
			if( !g_mode[Player])make_blood_and_bulletholes(Player);
			new Float:origin1[3], targ, body;
			if( g_target[Player] ) {
				pev(g_target[Player], pev_origin, origin1);
			}
			else fm_get_aim_origin(Player, origin1);
			get_user_aiming(Player, targ, body);
			
			if( !g_mode[Player]) set_bit(g_bitsMuzzleFlash, Player);
			if(g_mode[Player]) {
				message_begin( MSG_BROADCAST,SVC_TEMPENTITY);
				write_byte (TE_BEAMENTPOINT);
				write_short(Player | 0x1000);
				write_coord(floatround(origin1[0]));
				write_coord(floatround(origin1[1]));
				write_coord(floatround(origin1[2]));
				write_short( g_sprite );
				write_byte( 1 ); // framestart
				write_byte( 100 ); // framerate
				write_byte( 1 ); // life
				write_byte( 15 ); // width
				write_byte( 20 ); // noise
				write_byte( 255 ); // r, g, b
				write_byte( 165 ); // r, g, b
				write_byte( 0 ); // r, g, b
				write_byte( 250 ); // brightness
				write_byte( 255 ); // speed
				message_end();      
				if( targ && is_user_alive(targ) && zp_get_user_zombie(targ) && !g_target[Player]) {
					remove_task(targ+324);
					pev(targ, pev_origin, origin1);
					ExecuteHam(Ham_TakeDamage, targ, Player, Player, JANUS7_DAMAGE*2.0, DMG_SLASH);
					fm_set_user_rendering(targ, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 10);
					set_task(0.2, "delete_effect", targ+324);
					g_target[Player] = targ;
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_EXPLOSION);
					write_coord(floatround(origin1[0]));
					write_coord(floatround(origin1[1]));
					write_coord(floatround(origin1[2]));
					write_short(g_sprite1);
					write_byte(10);
					write_byte(10);
					write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NODLIGHTS);
					message_end(); 
					
				}
				else if( g_target[Player] && is_user_alive(g_target[Player]) && zp_get_user_zombie(g_target[Player]) ) {
					remove_task(g_target[Player]+324);
					ExecuteHam(Ham_TakeDamage, g_target[Player], Player, Player, JANUS7_DAMAGE*2.0, DMG_SLASH);
					pev(g_target[Player], pev_origin, origin1);
					fm_set_user_rendering(g_target[Player], kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 10);
					set_task(0.2, "delete_effect", g_target[Player]+324);
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_EXPLOSION);
					write_coord(floatround(origin1[0]));
					write_coord(floatround(origin1[1]));
					write_coord(floatround(origin1[2]));
					write_short(g_sprite1);
					write_byte(10);
					write_byte(10);
					write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NODLIGHTS);
					message_end(); 

					
				}
			}
			
		}
	}
}

public delete_effect(id) {
	id-=324;
	if(zp_get_user_nemesis(id))
	{
		fm_set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
	}
	else
	{
		fm_set_user_rendering(id);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == wId)
		{
			if(g_has_janus7[attacker]) {
				if( g_mode[attacker] ) return;
				g_shots[attacker] ++;
				SetHamParamFloat(4, JANUS7_DAMAGE*(g_mode[attacker]?2.0:1.0));
			}
		}
	}
}

public CPlayer__AddToFullPack_post(esState, iE, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
	if (iEnt != g_iEntity)
		return;
	
	if (get_bit(g_bitsMuzzleFlash, iHost))
	{
		set_es(esState, ES_Frame, float(random_num(0, 2)));
			
		set_es(esState, ES_RenderMode, kRenderTransAdd);
		set_es(esState, ES_RenderAmt, 250.0);
		
		reset_bit(g_bitsMuzzleFlash, iHost);
	}
		
	set_es(esState, ES_Skin, iHost);
	set_es(esState, ES_Body, 1);
	set_es(esState, ES_AimEnt, iHost);
	set_es(esState, ES_MoveType, MOVETYPE_FOLLOW);
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(0);
	message_end();
}

stock Make_BulletSmoke(id, TrResult)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG;
	get_weapon_attachment(id, vecSrc);
	global_get(glb_v_forward, vecEnd);
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd);
	xs_vec_add(vecSrc, vecEnd, vecEnd);
	get_tr2(TrResult, TR_vecEndPos, vecSrc);
	get_tr2(TrResult, TR_vecPlaneNormal, vecEnd);
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd);
	xs_vec_add(vecSrc, vecEnd, vecEnd);
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecEnd[0]);
	engfunc(EngFunc_WriteCoord, vecEnd[1]);
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0);
	write_short(g_SmokePuff_SprId);
	write_byte(3);
	write_byte(70);
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_FLAG | TE_EXPLFLAG_NODLIGHTS);
	message_end();
}

stock Sprite(id, type)
{
    
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, id);
	write_string(type?"weapon_janus7":"weapon_m249");
	write_byte(3);
	write_byte(200);
	write_byte(-1);
	write_byte(-1);
	write_byte(0);
	write_byte(4);
	write_byte(20);
	write_byte(0);
	message_end();

}

	
stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3] 
	fm_get_aim_origin(id, vfEnd);
	new Float:fOrigin[3], Float:fAngle[3]
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	new Float:fAttack[3]
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	new Float:fRate
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	xs_vec_add(fOrigin, fAttack, output)
}


stock make_blood_and_bulletholes(id)
{
	new aimOrigin[3], target, body;
	get_user_origin(id, aimOrigin, 3);
	get_user_aiming(id, target, body);
	if(target > 0 && target <= get_maxplayers() && zp_get_user_zombie(target))
	{
		new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3];
		pev(id, pev_origin, fStart);
		velocity_by_aim(id, 64, fVel);
		fStart[0] = float(aimOrigin[0]);
		fStart[1] = float(aimOrigin[1]);
		fStart[2] = float(aimOrigin[2]);
		fEnd[0] = fStart[0]+fVel[0];
		fEnd[1] = fStart[1]+fVel[1];
		fEnd[2] = fStart[2]+fVel[2];
		new res;
		engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res);
		get_tr2(res, TR_vecEndPos, fRes);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BLOODSPRITE);
		write_coord(floatround(fStart[0]));
		write_coord(floatround(fStart[1]));
		write_coord(floatround(fStart[2]));
		write_short( m_iBlood [ 1 ]);
		write_short( m_iBlood [ 0 ] );
		write_byte(70);
		write_byte(random_num(1,2));
		message_end();
	}
	else if(!is_user_connected(target))
	{
		for(new i = 0; i <= 1; i ++) {
			if(target)
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_DECAL);
				write_coord(aimOrigin[0]);
				write_coord(aimOrigin[1]);
				write_coord(aimOrigin[2]);
				write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] );
				write_short(target);
				message_end();
			}
			else
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_WORLDDECAL);
				write_coord(aimOrigin[0]);
				write_coord(aimOrigin[1]);
				write_coord(aimOrigin[2]);
				write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] );
				message_end();
			}
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_GUNSHOTDECAL);
			write_coord(aimOrigin[0]);
			write_coord(aimOrigin[1]);
			write_coord(aimOrigin[2]);
			write_short(id);
			write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] );
			message_end();
		}
		Make_BulletSmoke(id, 0);
	}
}

public janus7__ItemPostFrame(weapon_entity) {
	new id = pev(weapon_entity, pev_owner);
	if (!is_user_connected(id))
		return HAM_IGNORED;
		
	if (!g_has_janus7[id])
		return HAM_IGNORED;
		
	new Float:flNextAttack = get_pdata_float(id, 83, 5);
	new iBpAmmo = cs_get_user_bpammo(id, wId);
	new iClip = get_pdata_int(weapon_entity, 51, 4);
	new fInReload = get_pdata_int(weapon_entity, 54, 4);
	if( fInReload && flNextAttack <= 0.0 )
	{
		new j = min(JANUS7_CLIPAMMO- iClip, iBpAmmo);
		set_pdata_int(weapon_entity, 51, iClip + j, 4);
		cs_set_user_bpammo(id, wId, iBpAmmo-j);
		set_pdata_int(weapon_entity, 54, 0, 4);
		fInReload = 0;
	}
	new Float:origin[3];
	pev(g_target[id], pev_origin, origin);
	
	if( g_shots[id] >= SHOTS_NEED && flNextAttack <= 0.0 && !g_mode[id] ) {
		
		UTIL_PlayWeaponAnimation(id, 12);
		
		if( get_user_button(id) & IN_ATTACK2 && flNextAttack <= 0.0 && iClip > 0) {
			
			UTIL_PlayWeaponAnimation(id, 6);
			set_pdata_float( id, 83, 2.0);
			g_mode[id] = 1;
			g_shots[id] = 0;
			set_task( 20.0, "remove_mode", id+1231 );
		}
			
	
	}
	else if (g_mode[id] && flNextAttack <= 0.0 ) {
		
		if( !(get_user_button(id) & IN_ATTACK) ) {
			g_target[id] = 0;
			emit_sound(id, CHAN_WEAPON, Fire_snd[g_mode[id]], 0.0, ATTN_NORM, 0, PITCH_NORM);
			g_sound[id] = 0;
		}
		if( !is_user_alive(g_target[id]) || !zp_get_user_zombie(g_target[id])  || !can_see_fm(id,g_target[id]) || entity_range(id, g_target[id]) > 400.0 || !is_in_viewcone(id, origin))
			g_target[id] = 0;
		
		UTIL_PlayWeaponAnimation(id, 7);
		
	}
	return HAM_IGNORED;
}

public remove_mode(id) {
	id-=1231;
	if(!g_mode[id]) return;
	g_mode[id] = false;
	g_shots[id] = false;
	g_sound[id] = false;
	emit_sound(id, CHAN_WEAPON, Fire_snd[g_mode[id]], 0.0, ATTN_NORM, 0, PITCH_NORM);
	UTIL_PlayWeaponAnimation(id, 11);
	set_pdata_float(id, 83, 2.0);
}
	
public janus7__Reload(weapon_entity) {
	new id = pev(weapon_entity, pev_owner);
	if (!is_user_connected(id))
		return HAM_IGNORED;
	if (!g_has_janus7[id])
		return HAM_IGNORED;
	if(g_mode[id])
		return HAM_SUPERCEDE;
	g_janus7_TmpClip[id] = -1;
	new iBpAmmo = cs_get_user_bpammo(id, wId);
	new iClip = get_pdata_int(weapon_entity, 51, 4);
	if (iBpAmmo <= 0)
		return HAM_SUPERCEDE;
	if (iClip >= JANUS7_CLIPAMMO)
		return HAM_SUPERCEDE;
	g_janus7_TmpClip[id] = iClip;
	return HAM_IGNORED;
}
public janus7__Reload_Post(weapon_entity) {
	new id = pev(weapon_entity, pev_owner);
	if (!is_user_connected(id))
		return HAM_IGNORED;
	if (!g_has_janus7[id])
		return HAM_IGNORED;
	if (g_janus7_TmpClip[id] == -1)
		return HAM_IGNORED;
	if(g_mode[id])
		return HAM_SUPERCEDE;
	set_pdata_int(weapon_entity, 51, g_janus7_TmpClip[id], 4);
	set_pdata_float(weapon_entity, 48, RELOAD_TIME, 4);
	set_pdata_float(id, 83, RELOAD_TIME, 5);
	set_pdata_int(weapon_entity, 54, 1, 4);
	if( g_mode[id]) g_mode[id] = 0;
	UTIL_PlayWeaponAnimation(id, g_shots[id]>50?13:1);
	return HAM_IGNORED;
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid;
	num = 0;
	get_user_weapons(id, weapons, num);
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i];
		const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|
		(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)| (1<<CSW_M249)|(1<<CSW_M3)|
		(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
		if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		{
			static wname[32];
			get_weaponname(weaponid, wname, sizeof wname - 1);
			engclient_cmd(id, "drop", wname);
		}
	}
}

public bool:can_see_fm(entindex1, entindex2)
{
	if (!entindex1 || !entindex2)
		return false;

	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags);
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false;
		}

		new Float:lookerOrig[3];
		new Float:targetBaseOrig[3];
		new Float:targetOrig[3];
		new Float:temp[3];

		pev(entindex1, pev_origin, lookerOrig);
		pev(entindex1, pev_view_ofs, temp);
		lookerOrig[0] += temp[0];
		lookerOrig[1] += temp[1];
		lookerOrig[2] += temp[2];

		pev(entindex2, pev_origin, targetBaseOrig);
		pev(entindex2, pev_view_ofs, temp);
		targetOrig[0] = targetBaseOrig [0] + temp[0];
		targetOrig[1] = targetBaseOrig [1] + temp[1];
		targetOrig[2] = targetBaseOrig [2] + temp[2];

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0);//  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false;
		} 
		else 
		{
			new Float:flFraction;
			get_tr2(0, TraceResult:TR_flFraction, flFraction);
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true;
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0];
				targetOrig[1] = targetBaseOrig [1];
				targetOrig[2] = targetBaseOrig [2];
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0); //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction);
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true;
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0];
					targetOrig[1] = targetBaseOrig [1];
					targetOrig[2] = targetBaseOrig [2] - 17.0;
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0); //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction);
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true;
					}
				}
			}
		}
	}
	return false;
}