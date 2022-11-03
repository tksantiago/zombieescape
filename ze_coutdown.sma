#include <amxmodx>
#include <fakemeta>
#include <zombieplague>
#define dhudmessage


new xTimer, xCountDown

new const Ready[]= 
{
	"ze_dp/zombie_start.mp3"
}

new const xSoundCountDown[][]=
{
	"star/count/1.wav", 
	"star/count/2.wav", 
	"star/count/3.wav", 
	"star/count/4.wav", 
	"star/count/5.wav", 
	"star/count/6.wav",
	"star/count/7.wav", 
	"star/count/8.wav", 
	"star/count/9.wav", 
	"star/count/10.wav"
}

public plugin_init()
{
	register_plugin("xCountDown", "1.0", "yRestrict")
	register_event("HLTV","event_new_round","a","1=0","2=0")
	
	
}

public plugin_precache() 
{
	precache_sound(Ready)
	precache_sound("star/count/20secs.wav")
	new i

	for( i = 0; i < sizeof xSoundCountDown;i++) engfunc(EngFunc_PrecacheSound, xSoundCountDown[i])
}

public event_new_round()
{
	//client_cmd(0,"speak star/count/20secs.wav")
	client_cmd(0,"mp3 play sound/ze_dp/zombie_start.mp3")
	
	remove_task(1444)
	
	xTimer = 20
	xCountDown = 9
	
	xContagem()
}

public xContagem()
{
	if(xTimer >= 1)
	{
		if(xTimer >=10)
		{
			set_dhudmessage(random_num(57, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.39, 0, 6.0, 0.001, 0.1, 1.0)
			show_dhudmessage(0, "[All Star] ^n| Tempo Até Aparecimento Zombie: %d segundos. |", xTimer)
		}
		else
		{
			set_dhudmessage(random_num(57, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.39, 0, 6.0, 0.001, 0.1, 1.0)
			show_dhudmessage(0, " [All Star] ^nTempo Até Aparecimento Zombie 0%d segundos.", xTimer)
		}
		set_task(1.0,"xContagem", 1444)
		
		if(xTimer <= 10)
		{
			ses_baslat(0, xSoundCountDown[xCountDown])
			xCountDown--
		}
		
		xTimer--
	}
}

stock ses_baslat(p_id, const ses[])
{
	if(equal(ses[strlen(ses)-4], ".mp3"))
	{
		if(p_id == 0)
			client_cmd(0,"mp3 play ^"sound/%s^"",ses)
		else
		{
			if(is_user_connected(p_id))
				client_cmd(p_id,"mp3 play ^"sound/%s^"",ses)
		}
	}
	else if(equal(ses[strlen(ses)-4], ".wav"))
	{
		if(p_id == 0)
			emit_sound(0, CHAN_AUTO, ses, VOL_NORM, ATTN_NORM , 0, PITCH_NORM)
		else
		{
			if(is_user_connected(p_id))
				emit_sound(p_id, CHAN_AUTO, ses, VOL_NORM, ATTN_NORM , 0, PITCH_NORM)
		}
	}
}