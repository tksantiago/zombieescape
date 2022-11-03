/*    Formatright ? 2010, ConnorMcLeod   

    This plugin is free software;   
    you can redistribute it and/or modify it under the terms of the   
    GNU General Public License as published by the Free Software Foundation.   

    This program is distributed in the hope that it will be useful,   
    but WITHOUT ANY WARRANTY; without even the implied warranty of   
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the   
    GNU General Public License for more details.   

    You should have received a copy of the GNU General Public License   
    along with this plugin; if not, write to the   
    Free Software Foundation, Inc., 59 Temple Place - Suite 330,   
    Boston, MA 02111-1307, USA.   
*/   

#include <amxmodx>   
#include <cstrike>   
#include <fakemeta>   

#define VERSION "0.1"   

new const g_Sounds[][] =   
{  
	"player/pl_pain2.wav",
	"player/bhit_helmet-1.wav",
	"items/9mmclip1.wav",
	"items/flashlight1.wav",
	"hostage/hos1.wav",
	"hostage/hos2.wav",
	"hostage/hos3.wav",
	"hostage/hos4.wav",
	"hostage/hos5.wav",
	"items/tr_kevlar.wav",
	"weapons/awp1.wav",
	"weapons/boltpull1.wav",
	"weapons/boltup.wav",
	"weapons/boltdown.wav",
	"weapons/awp_deploy.wav",
	"weapons/awp_clipin.wav",
	"weapons/awp_clipout.wav",
	"weapons/g3sg1-1.wav",
	"weapons/g3sg1_slide.wav",
	"weapons/g3sg1_clipin.wav",
	"g3sg1_clipout.wav",
	"weapons/ak47-1.wav",
	"weapons/ak47-2.wav",
	"weapons/ak47_clipout.wav",
	"weapons/ak47_clipin.wav",
	"weapons/ak47_boltpull.wav",
	"weapons/scout_fire-1.wav",
	"weapons/scout_bolt.wav",
	"weapons/scout_clipin.wav",
	"weapons/scout_clipout.wav",
	"weapons/m249-1.wav",
	"weapons/m249-2.wav",
	"weapons/m249_boxout.wav",
	"weapons/m249_boxin.wav",
	"weapons/m249_chain.wav",
	"weapons/m249_coverup.wav",
	"weapons/m249_coverdown.wav",
	"weapons/m4a1-1.wav",
	"weapons/m4a1_unsil-1.wav",
	"weapons/m4a1_unsil-2.wav",
	"weapons/m4a1_clipin.wav",
	"weapons/m4a1_clipout.wav",
	"weapons/m4a1_boltpull.wav",
	"weapons/m4a1_deploy.wav",
	"weapons/m4a1_silencer_on.wav",
	"weapons/m4a1_silencer_off.wav",
	"weapons/sg552-1.wav",
	"weapons/sg552-2.wav",
	"weapons/sg552_clipout.wav",
	"weapons/sg552_clipin.wav",
	"weapons/sg552_boltpull.wav",
	"weapons/aug-1.wav",
	"weapons/aug_clipout.wav",
	"weapons/aug_clipin.wav",
	"weapons/aug_boltpull.wav",
	"weapons/aug_boltslap.wav",
	"weapons/aug_forearm.wav",
	"weapons/sg550-1.wav",
	"weapons/sg550_boltpull.wav",
	"weapons/sg550_clipin.wav",
	"weapons/sg550_clipout.wav",
	"weapons/m3-1.wav",
	"weapons/m3_insertshell.wav",
	"weapons/m3_pump.wav",
	"weapons/xm1014-1.wav",
	"weapons/usp1.wav",
	"weapons/usp2.wav",
	"weapons/usp_unsil-1.wav",
	"weapons/usp_clipout.wav",
	"weapons/usp_clipin.wav",
	"weapons/usp_silencer_on.wav",
	"weapons/usp_silencer_off.wav",
	"weapons/usp_sliderelease.wav",
	"weapons/usp_slideback.wav",
	"weapons/mac10-1.wav",
	"weapons/mac10_clipout.wav",
	"weapons/mac10_clipin.wav",
	"weapons/mac10_boltpull.wav",
	"weapons/ump45-1.wav",
	"weapons/ump45_clipout.wav",
	"weapons/ump45_clipin.wav",
	"weapons/ump45_boltslap.wav",
	"weapons/fiveseven-1.wav",
	"weapons/fiveseven_clipout.wav",
	"weapons/fiveseven_clipin.wav",
	"weapons/fiveseven_sliderelease.wav",
	"weapons/fiveseven_slidepull.wav",
	"weapons/p90-1.wav",
	"weapons/p90_clipout.wav",
	"weapons/p90_clipin.wav",
	"weapons/p90_boltpull.wav",
	"weapons/p90_cliprelease.wav",
	"weapons/deagle-1.wav",
	"weapons/deagle-2.wav",
	"weapons/de_clipout.wav",
	"weapons/de_clipin.wav",
	"weapons/de_deploy.wav",
	"weapons/p228-1.wav",
	"weapons/p228_clipout.wav",
	"weapons/p228_clipin.wav",
	"weapons/p228_sliderelease.wav",
	"weapons/p228_slidepull.wav",
	"weapons/glock18-1.wav",
	"weapons/glock18-2.wav",
	"weapons/mp5-1.wav",
	"weapons/mp5-2.wav",
	"weapons/mp5_clipout.wav",
	"weapons/mp5_clipin.wav",
	"weapons/mp5_slideback.wav",
	"weapons/tmp-1.wav",
	"weapons/tmp-2.wav",
	"weapons/elite_fire.wav",
	"weapons/elite_reloadstart.wav",
	"weapons/elite_leftclipin.wav",
	"weapons/elite_clipout.wav",
	"weapons/elite_sliderelease.wav",
	"weapons/elite_rightclipin.wav",
	"weapons/elite_deploy.wav",
	"weapons/flashbang-1.wav",
	"weapons/flashbang-2.wav",
	"weapons/hegrenade-1",
	"weapons/c4_click.wav",
	"weapons/galil-1.wav",
	"weapons/galil-2.wav",
	"weapons/galil_clipout.wav",
	"weapons/galil_clipin.wav",
	"weapons/galil_boltpull.wav",
	"weapons/famas-1.wav",
	"weapons/famas-2.wav",
	"weapons/famas_clipout.wav",
	"weapons/famas_clipin.wav",
	"weapons/famas_boltpull.wav",
	"weapons/famas_boltslap.wav",
	"weapons/famas_forearm.wav",
	"weapons/famas-burst.wav",
	"weapons/debris1.wav",
	"weapons/debris2.wav",
	"weapons/debris3.wav",
	"weapons/bullet_hit1.wav",
	"weapons/bullet_hit2.wav",
	"weapons/c4_beep1.wav",
	"weapons/c4_beep2.wav",
	"weapons/c4_beep3.wav",
	"weapons/c4_beep4.wav",
	"weapons/c4_beep5.wav",
	"weapons/c4_explode1.wav",
	"weapons/c4_plant.wav",
	"weapons/c4_disarm.wav",
	"weapons/c4_disarmed.wav"	
}  

new const g_Models[][] =   
{       
	"models/w_longjump.mdl",
	"models/w_battery.mdl"
}  

public plugin_precache()   
{    
    register_plugin("UnPrecacher", VERSION, "Proo.Noob")   
    register_forward(FM_PrecacheModel, "PrecacheModel")  
    register_forward(FM_PrecacheSound, "PrecacheSound")       
}   

public PrecacheModel(const szModel[])   
{   
    for(new i = 0; i < sizeof(g_Models); i++)  
    {  
        if( containi(szModel, g_Models[i]) != -1 )   
        {   
            forward_return(FMV_CELL, 0)   
            return FMRES_SUPERCEDE   
        }   
    }  
    return FMRES_IGNORED   
}   

public PrecacheSound(const szSound[])   
{   
    for(new i = 0; i < sizeof(g_Sounds); i++)  
    {  
        if( containi(szSound, g_Sounds[i]) != -1 )   
        {   
            forward_return(FMV_CELL, 0)   
            return FMRES_SUPERCEDE   
        }   
    }  
    return FMRES_IGNORED   
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE 
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1053\\ f0\\ fs16 \n\\ par } 
*/  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1254\\ deff0\\ deflang1055{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1254\\ deff0\\ deflang1055{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
