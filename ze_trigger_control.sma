#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>
#include <fakemeta>

#define PLUGIN "Trigger Hurt Block"
#define VERSION "1.0"
#define AUTHOR "DPCS"

const tlimit = 32

new trig_id[tlimit]
new trig_targets[tlimit][32]
new trig_state[tlimit]
new numoftrigs = 0

new Float:turnOffDelay = 3.0 // Her sinyal geldiginde kac saniyeligine acik kalacak? 
new Float:forbiddenDelay = 20.0 // Round basinda ilk kac saniye trigger_hurt ile olmek imkansiz olacak? 

new Float:lastRoundTime = 0.0 // DOKUNMA

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event( "HLTV", "EventNewRound", "a", "1=0", "2=0" )
	RegisterHam(Ham_TakeDamage, "player", "player_damage")
	register_forward(FM_AlertMessage, "FireEvent", 1)
	
	new temptext[64]
	new c = 0
	new entcount = entity_count()
	for (new id = 33; id < entcount; id++)
	{
		if (!is_valid_ent(id))
			continue;
		entity_get_string(id, EV_SZ_classname, temptext, 64)
		if (equali(temptext, "trigger_hurt"))
		{
			if (entity_get_int(id, EV_INT_spawnflags) & 2)
			{
				trig_id[c] = id
				entity_get_string(id, EV_SZ_targetname, trig_targets[c], 32)
				
				c++
				if (c >= tlimit)
					break;
			}
		}
	}
	numoftrigs = c
	
	register_logevent( "EventRoundEnd", 2, "1=Round_End" )
}


public TurnOffState(data[], id)
{
	trig_state[data[0]] = 0
}

public FireEvent()
{
	new arg0[64]
	new comptxt[64]
	new param[1]
	for (new id = 0; id < 64; id++)
		arg0[id] = getarg(1, id)
	for (new id = 0; id < numoftrigs; id++)
	{
		format(comptxt, charsmax(comptxt), "Firing: (%s)", trig_targets[id])
		if (equal(arg0, comptxt, strlen(comptxt)))
		{
			param[0] = id
			trig_state[id] = 1
			set_task(turnOffDelay, "TurnOffState", _, param, 1)
		}
	}
	return FMRES_IGNORED
}

public EventNewRound()
{
	for (new id = 0; id < numoftrigs; id++)
		trig_state[id] = 0
	lastRoundTime = get_gametime()
}

public EventRoundEnd()
{
	/*new param[1]
	for (new id = 0; id < numoftrigs; id++)
	{
		param[0] = id
		set_task(turnOffDelay, "TurnOffState", _, param, 1)
	}*/
	//client_print(0, print_chat, "ROUND END")
}


public player_damage(this, idinflictor, idattacker, Float:damage, damagebits) {
	for (new id = 0; id < numoftrigs; id++)
	{
		if(idattacker == trig_id[id] && (!trig_state[id] || get_gametime() - lastRoundTime < forbiddenDelay))
			return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
