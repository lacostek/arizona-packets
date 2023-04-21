#if defined _arz_packet_inc
    #endinput
#endif
#define _arz_packet_inc

forward OnInterfaceEvent(playerid, const args[]);

stock CreateBrowser(playerid, browserid, const url[], const key[]=" ") {
	if(strlen(url) > 0)
		CallRemoteFunction("CreateBrowser", "iiss", playerid, browserid, url, key);
}

stock ExecuteEvent(playerid, browserid, const event[]) {
	if(strlen(event) > 0) 
		CallRemoteFunction("ExecuteEvent", "iis", playerid, browserid, event);
}

stock SetFocusBrowser(playerid, browserid, toggle) {
	CallRemoteFunction("SetFocusBrowser", "iii", playerid, browserid, toggle);
}
