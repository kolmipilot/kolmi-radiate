#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Checks if KAT (KAM) is loaded on the server.
 * Called once from XEH_postInit.sqf — result cached in GVAR(KATLoaded).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * KAT Available <BOOL>
 *
 * Example:
 * [] call kolmir_radiate_fnc_hasKAT
 *
 * Public: No
 */

// Static check — only runs once via postInit
private _katLoaded = isClass (configFile >> "cfgPatches" >> "kat_main");

if (_katLoaded) then {
    INFO("KAT advanced medical system detected - enhanced radiation sickness symptoms enabled");
} else {
    INFO("KAT not detected - using standard ACE-only radiation sickness symptoms");
};

_katLoaded
