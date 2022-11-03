/* Yek'-ta */

#include <amxmodx>

#define PLUGIN  "UzaBAN"
#define VERSION "1.0"
#define AUTHOR  "Yek'-ta"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("amx_uzabanmenu", "farklibanmenu")
}


public farklibanmenu(id){

    if(get_user_flags(id) & ADMIN_BAN){
        static opcion[64]

        formatex(opcion, charsmax(opcion),"\yUZABan icin oyuncu sec")
        new iMenu = menu_create(opcion, "farklibanmenudevam")

        new players[32], tempid
        new szName[32], szTempid[10]
        new pnum


        get_players(players, pnum)

        for( new i; i<pnum; i++ )
        {
            tempid = players[i]
            if(is_user_connected(tempid) && !is_user_bot(tempid) && !(get_user_flags(tempid) & ADMIN_BAN)){
                get_user_name(tempid, szName, 31)
                num_to_str(tempid, szTempid, 9)
                formatex(opcion, charsmax(opcion), "\w%s", szName)
                menu_additem(iMenu, opcion, szTempid, 0)
            }

        }

        menu_display(id, iMenu)

    }
}

public farklibanmenudevam(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new Data[6], Name[64]
    new Access, Callback
    menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback)

    new tempid = str_to_num(Data)


    cmdFarkliBan(id,tempid)
    menu_destroy(menu)
    return PLUGIN_HANDLED
}
//Yek'-ta
//forum.csduragi.com

public cmdFarkliBan(id,banlanan)
{

    if (!banlanan)
        return PLUGIN_HANDLED

    new authid[32]
    new userid = get_user_userid(banlanan)
    new address[32]
    get_user_ip(banlanan, address, 31, 1)

    get_user_authid(banlanan, authid, 31)

    server_cmd("kick #%d ^"UzaBAN ile banlandiniz^";wait;banid 999999999999 %s;wait;writeid", userid, authid)

    server_cmd("wait;addip ^"9999999999999^" ^"%s^";wait;writeip", address)

    chat_color(0,"!y^"%s^", !y^"%s^" oyuncusuna !tUZA BAN ATTI", isimver(id), isimver(banlanan));

    new szFile[50]
    new szDate[40]
    get_time("%Y-%m-%d", szDate, charsmax(szDate));
    formatex(szFile, charsmax(szFile), "addons/amxmodx/logs/%s-UZABANLOG.txt",szDate)
    new szTime[32],szLog[200]
    get_time( "%H:%M", szTime, charsmax(szTime))
    formatex(szLog, charsmax(szLog), "%s ^"amx_uzaban^" Saat: %s |>> %s", isimver(id), szTime,isimver(banlanan));

    write_file(szFile, szLog)

    return PLUGIN_HANDLED
}

public isimver(oyuncu){
    new isim[32]
    get_user_name(oyuncu, isim, 31)

    return isim;
}

stock chat_color(const id, const input[], any:...)
{
    new count = 1, players[32]
    static msg[191]
    vformat(msg, 190, input, 3)

    replace_all(msg, 190, "!g", "^4")
    replace_all(msg, 190, "!y", "^1")
    replace_all(msg, 190, "!t", "^3")

    if (id) players[0] = id; else get_players(players, count, "ch")
    {
        for (new i = 0; i < count; i++)
        {
            if (is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
                write_byte(players[i]);
                write_string(msg);
                message_end();
            }
        }
    }
}

