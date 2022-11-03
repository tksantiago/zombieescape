#include <amxmodx>

#define PLUGIN  "PUB BOT"
#define VERSION "1.0"
#define AUTHOR  "Fatih ~ EjderYa"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say","say_islemleri")
}

public say_islemleri(id) {

	new yazi[2]
	read_args(yazi,2)
	remove_quotes(yazi)
	
	
	if (equal(yazi, "^"/")  ){
		
		
		new yazix[100]
		read_args(yazix,100)
		remove_quotes(yazix)
		new Yazi1[50] , Yazi2[50]
		strtok(yazix, Yazi1, charsmax(Yazi1), Yazi2, charsmax(Yazi2), '/');
		client_cmd(id,"amx_%s",Yazi2)
		
		
	}
	
	
	
	if (equal(yazi, "^".")  ){
		
		
		new yazix[100]
		read_args(yazix,100)
		remove_quotes(yazix)
		new Yazi1[50] , Yazi2[50]
		strtok(yazix, Yazi1, charsmax(Yazi1), Yazi2, charsmax(Yazi2), '.');
		client_cmd(id,"amx_%s",Yazi2)
		
	}
	
	
	
	if (equal(yazi, "^"!") ){
		
		
		new yazix[100]
		read_args(yazix,100)
		remove_quotes(yazix)
		new Yazi1[50] , Yazi2[50]
		strtok(yazix, Yazi1, charsmax(Yazi1), Yazi2, charsmax(Yazi2), '!');
		client_cmd(id,"amx_%s",Yazi2)
		
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
