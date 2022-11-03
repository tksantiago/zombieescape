/* Plugin generated by AMXX-Studio */ 

#include <amxmodx> 
#include <amxmisc> 
#include <engine> 
#include <fakemeta_stocks> 
#include <fakemeta_util> 
#include <hamsandwich> 
#include <ham_const> 
#include <cstrike> 

#define PLUGIN "Anti-Bug" 
#define VERSION "1.0" 
#define AUTHOR "DPCS" 


new bugYapanlar[33] // Bug yapan oyuncularin listesi. 

new const Float:ctHasar = 15.0 // Bug yapan insanlara her adimda verilecek zarar 

new const Float:tHasar = 500.0 // Bug yapan zombilere her adimda verilecek zarar 

new const Float:incitmeSikligi = 0.6 // Bug yapanlara zarar verme sikligi (saniye cinsinden) 

public plugin_init() { 
     
    register_plugin(PLUGIN, VERSION, AUTHOR) 
    // Tasit araclarina bug yapildiginda bug_var fonksiyonu cagrilsin 
    RegisterHam(Ham_Blocked, "func_tracktrain", "bug_var") 
    set_task(incitmeSikligi,"zararVer",0,"",0,"b") 
} 


public bug_var(const this,const idother) 
{ 
    if (idother >= 1 && idother <= 32) // Sadece oyuncu olan entityler kayit altina alinir 
        bugYapanlar[idother] = true 
     
} 
public zararVer() 
{ 
     
    // Her oyuncu icin bug yapip yapmadigi kontrol edilsin 
    for (new i = 1; i < 33; i++) 
    { 
        if (bugYapanlar[i] && is_user_alive(i)) 
        { 
             
             
            client_print (i, print_center, "NÃO INCOMODE! / NÃO INCOMODE!" ) 
             
            if (cs_get_user_team(i) == CsTeams:1) // zombi 
                fm_fakedamage(i, "", tHasar, DMG_GENERIC) 
            else if (cs_get_user_team(i) == CsTeams:2) // insan 
                fm_fakedamage(i, "", ctHasar, DMG_GENERIC) 
             
            bugYapanlar[i] = false // Ceza bitti. Hala bug devam ediyorsa bir daha True olur. 
             
        } 
    } 
     
} 