#include <amxmodx>
#include <fakemeta_util>
#include <zombieplague>

new const knife_slash1[] 	= { "knf_dp/knife_slash1.wav" }
new const knife_slash2[] 	= { "knf_dp/knife_slash2.wav" }
new const knife_wall[] 	= { "knf_dp/knife_hitwall1.wav" }
new const knife_hit1[] 	= { "knf_dp/knife_hit1.wav" }
new const knife_hit2[] 	= { "knf_dp/knife_hit2.wav" }
new const knife_hit3[] 	= { "knf_dp/knife_hit3.wav" }
new const knife_hit4[] 	= { "knf_dp/knife_hit4.wav" }
new const knife_stab[] 	= { "knf_dp/knife_stab.wav" }

new const bomba1[] 	= { "weapons/m79_draw.wav" }
new const bomba2[] 	= { "weapons/janus1-2.wav" }
new const bomba3[] 	= { "weapons/janus1_change1.wav" }

public plugin_init()
{
	register_plugin("Bicak Sesleri", "1.0","DPCS")
	
	register_forward(FM_EmitSound, "fw_EmitSound")
}

public plugin_precache()
{
	precache_sound(knife_slash1)
	precache_sound(knife_slash2)
	precache_sound(knife_wall)
	precache_sound(knife_hit1)
	precache_sound(knife_hit2)
	precache_sound(knife_hit3)
	precache_sound(knife_hit4)
	precache_sound(knife_stab)
	
	precache_sound(bomba1)
	precache_sound(bomba2)
	precache_sound(bomba3)
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (!is_user_connected(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED;
	
	if (equal(sample[8], "kni", 3))
	{
		if (equal(sample[14], "sla", 3)) 
		{
			switch (random_num(1, 2))
			{
				case 1: engfunc(EngFunc_EmitSound, id, channel, knife_slash1, volume, attn, flags, pitch)
					case 2: engfunc(EngFunc_EmitSound, id, channel, knife_slash2, volume, attn, flags, pitch)
				}
			return FMRES_SUPERCEDE;
		}
		if(equal(sample,"weapons/knife_deploy1.wav"))
		{
			return FMRES_SUPERCEDE;
		}
		if (equal(sample[14], "hit", 3))
		{
			if (sample[17] == 'w') 
			{
				engfunc(EngFunc_EmitSound, id, channel, knife_wall, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			else // hit
			{
				switch (random_num(1, 4))
				{
					case 1: engfunc(EngFunc_EmitSound, id, channel, knife_hit1, volume, attn, flags, pitch)
						case 2: engfunc(EngFunc_EmitSound, id, channel, knife_hit2, volume, attn, flags, pitch)
						case 3: engfunc(EngFunc_EmitSound, id, channel, knife_hit3, volume, attn, flags, pitch)
						case 4: engfunc(EngFunc_EmitSound, id, channel, knife_hit4, volume, attn, flags, pitch)
					}
				return FMRES_SUPERCEDE;
			}
		}
		if (equal(sample[14], "sta", 3)) 
		{
			engfunc(EngFunc_EmitSound, id, channel, knife_stab, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}