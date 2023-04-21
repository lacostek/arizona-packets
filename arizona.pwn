@___If_u_can_read_this_u_r_nerd();    // 10 different ways to crash DeAMX
@___If_u_can_read_this_u_r_nerd()    // and also a nice tag for exported functions table in the AMX file
{ // by Daniel_Cortez \\ ***-****.ru
    #emit    stack    0x7FFFFFFF    // wtf (1) (stack over... overf*ck!?)
    #emit    inc.s    cellmax    // wtf (2) (this one should probably make DeAMX allocate all available memory and lag forever)
    static const ___[][] = {"***-****", ".ru"};    // pretty old anti-deamx trick
    #emit    retn
    #emit    load.s.pri    ___    // wtf (3) (opcode outside of function?)
    #emit    proc    // wtf (4) (if DeAMX hasn't crashed already, it would think it is a new function)
    #emit    proc    // wtf (5) (a function inside of another function!?)
    #emit    fill    cellmax    // wtf (6) (fill random memory block with 0xFFFFFFFF)
    #emit    proc
    #emit    stack    1    // wtf (7) (compiler usually allocates 4 bytes or 4*N for arrays of N elements)
    #emit    stor.alt    ___    // wtf (8) (...)
    #emit    strb.i    2    // wtf (9)
    #emit    switch    4
    #emit    retn    // wtf (10) (no "casetbl" opcodes before retn - invalid switch statement?)
L1:
    #emit    jump    L1    // avoid compiler crash from "#emit switch"
    #emit    zero    cellmin    // wtf (11) (nonexistent address)
}

#define FILTERSCRIPT

#include <a_samp>
#include <Pawn.RakNet>

const ID_CUSTOM_PACKET = 220;

enum // custom packet rpc
{
	RPC_SetHudType = 8,
	RPC_SetRadarType,
	RPC_CreateBrowser,
	RPC_ExecuteEvent = 17,
	RPC_FocusBrowser = 25
};

forward CreateBrowser(playerid, browserid, const url[], const key[]);
forward ExecuteEvent(playerid, browserid, const event[]);
forward SetFocusBrowser(playerid, browserid, toggle);

public OnFilterScriptInit()
{
    print("\n--------------------------------------");
    print(" ARIZONA PACKETS LOADED");
    print(" AUTHOR: SHAD0W");
    print(" REPOSITORY: https://github.com/lacostek/arizona-packets");
    print("--------------------------------------\n");
    return 1;
}

public CreateBrowser(playerid, browserid, const url[], const key[])
{
	new BitStream:bs = BS_New(),
	    urlStrLen = strlen(url),
	    keyStrLen = strlen(key);

	if(keyStrLen < 3) keyStrLen = 0;
	    
	BS_WriteValue(bs, PR_UINT8, ID_CUSTOM_PACKET);
	BS_WriteValue(bs, PR_UINT8, RPC_CreateBrowser);
	// --------------------------------------
	BS_WriteValue(bs, PR_UINT8, 128);
	BS_WriteValue(bs, PR_UINT8, 7); //uint 16?
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 56);
	BS_WriteValue(bs, PR_UINT8, 4);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);
	BS_WriteValue(bs, PR_UINT8, 0);

	BS_WriteValue(bs, PR_UINT32, urlStrLen);
	BS_WriteValue(bs, PR_STRING, url, urlStrLen);

	BS_WriteValue(bs, PR_UINT32, keyStrLen);
	BS_WriteValue(bs, PR_STRING, !keyStrLen ? "" : key, keyStrLen);

	BS_WriteValue(bs, PR_UINT32, browserid);
	// --------------------------------------
	PR_SendPacket(bs, playerid);
	BS_Delete(bs);
}

public ExecuteEvent(playerid, browserid, const event[])
{
	new BitStream:bs = BS_New(),
		eventStrLen = strlen(event);
		
	BS_WriteValue(bs, PR_UINT8, ID_CUSTOM_PACKET);
	BS_WriteValue(bs, PR_UINT8, RPC_ExecuteEvent);
	// --------------------------------------
	BS_WriteValue(bs, PR_UINT32, browserid);
	BS_WriteValue(bs, PR_UINT32, eventStrLen);
	BS_WriteValue(bs, PR_STRING, event, eventStrLen);
	
	BS_WriteValue(bs, PR_UINT8, 255); //I do not know why
	BS_WriteValue(bs, PR_UINT8, 255);
	BS_WriteValue(bs, PR_UINT8, 255);
	BS_WriteValue(bs, PR_UINT8, 255);
    // --------------------------------------
	PR_SendPacket(bs, playerid);
	BS_Delete(bs);
}

public SetFocusBrowser(playerid, browserid, toggle)
{
	new BitStream:bs = BS_New();

	BS_WriteValue(bs, PR_UINT8, ID_CUSTOM_PACKET);
	BS_WriteValue(bs, PR_UINT8, RPC_FocusBrowser);
	// --------------------------------------
	BS_WriteValue(bs, PR_UINT32, browserid);
	BS_WriteValue(bs, PR_BOOL, toggle);
    // --------------------------------------
	PR_SendPacket(bs, playerid);
	BS_Delete(bs);
}

public OnIncomingPacket(playerid, packetid, BitStream:bs)
{
	if(packetid == 220)
	{
		BS_IgnoreBits(bs, 8);
		
		new custom;
		
		BS_ReadValue(bs, PR_UINT8, custom);
		printf("custom rpc %d", custom);
		
		if(custom == 18)
		{
		    new lenght, data[64];
		    
		    BS_ReadValue(bs, PR_UINT32, lenght);
		    BS_ReadValue(bs, PR_STRING, data, lenght);
		    
		    if(lenght > 0)
		        CallRemoteFunction("OnInterfaceEvent", "is", playerid, data);
		        
			printf("arizona.amx: OnInterfaceEvent %s", data);
		}
	}
	return 1;
}
