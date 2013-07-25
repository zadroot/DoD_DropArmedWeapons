/**
* DoD:S Drop Armed Weapons by Root
*
* Description:
*   Simply allows player to drop deployed weapons (such as miniguns or rocket launchers).
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

#pragma semicolon 1
#include <sdktools_functions>

// ====[ CONSTANTS ]===============================================================
#define PLUGIN_NAME    "DoD:S Drop Armed Weapons"
#define PLUGIN_VERSION "1.0"

#define SLOT_PRIMARY   0
#define DOD_MAXPLAYERS 33

enum
{
	_30cal,
	mg42,
	bazooka,
	pschreck
}

static	Offset_DeployedMG,
		Offset_DeployedRT,
		Handle:AllowDropping,
		bool:DroppedMG[DOD_MAXPLAYERS + 1],
		String:DeployedWeapons[][] =
{
	"30cal",
	"mg42",
	"bazooka",
	"pschreck"
};

// ====[ PLUGIN ]==================================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Simply allows player to drop deployed weapons",
	version     = PLUGIN_VERSION,
	url         = "http://dodsplugins.com/"
};


/* OnPluginStart()
 *
 * When the plugin starts up.
 * -------------------------------------------------------------------------------- */
public OnPluginStart()
{
	// Create ConVars (version one and toggle)
	CreateConVar("dod_armedrop_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AllowDropping = CreateConVar("dod_armedrop_enable", "1", "Allow players to drop deployed weapons ?", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// Store property offset for deployed weapons
	Offset_DeployedMG = FindSendPropInfo("CDODBipodWeapon",      "m_bDeployed");
	Offset_DeployedRT = FindSendPropInfo("CDODBaseRocketWeapon", "m_bDeployed");

	// Listen a command to drop weapons
	AddCommandListener(OnDropWeapon, "drop");
}

/* OnDropWeapon()
 *
 * When the 'drop' command is called.
 * -------------------------------------------------------------------------------- */
public Action:OnDropWeapon(client, const String:command[], argc)
{
	// Check whether or not plugin should work
	if (GetConVarBool(AllowDropping))
	{
		// Get the weapon which player is holding at this moment and retrieve its classname
		decl String:classname[16];
		GetClientWeapon(client, classname, sizeof(classname));

		new weapon = GetPlayerWeaponSlot(client, SLOT_PRIMARY);

		// Skip the first 7 characters in weapon string to avoid comparing with the "weapon_" prefix (optimizations)
		if (StrEqual(classname[7], DeployedWeapons[_30cal]))
		{
			SetEntData(weapon, Offset_DeployedMG, false, 4, true);

			// Make sure player has dropped a MG
			DroppedMG[client] = true;
		}
		else if (StrEqual(classname[7], DeployedWeapons[mg42]))
		{
			// MG42 is dropped: set m_bDeployed value to 0 (to allow weapon dropping automatically)
			SetEntData(weapon, Offset_DeployedMG, false, 4, true);
			DroppedMG[client] = true;
		}
		else if (StrEqual(classname[7], DeployedWeapons[bazooka]))
		{
			// A bazooka was dropped
			SetEntData(weapon, Offset_DeployedRT, false, 4, true);
		}
		else if (StrEqual(classname[7], DeployedWeapons[pschreck]))
		{
			// Another weapon - appropriate set offset for panzerschreck now
			SetEntData(weapon, Offset_DeployedRT, false, 4, true);
		}
	}
}

/* OnPlayerRunCmd()
 *
 * When a clients movement buttons are being processed.
 * -------------------------------------------------------------------------------- */
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	// Check whether or not player has dropped a MG
	if (DroppedMG[client] == true)
	{
		// Force +duck button to fix bad player height
		buttons ^= IN_DUCK;

		// For optimizations set global bool to false now
		DroppedMG[client] = false;
	}

	// return
	return Plugin_Continue;
}