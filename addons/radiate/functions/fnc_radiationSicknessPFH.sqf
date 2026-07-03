#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Per-frame handler for radiation sickness symptoms.
 * Runs independently of radiation zones — handles symptoms based on accumulated dose.
 * Registered in XEH_postInit.sqf for all clients.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [LINKFUNC(radiationSicknessPFH), 2, []] call CBA_fnc_addPerFrameHandler;
 *
 * Public: No
 */

// Only run on units local to this machine
private _allLocalUnits = allUnits select { local _x };

{
    private _radiationDose = _x getVariable [QGVAR(radiationDose), 0];

    // Skip units with no accumulated dose
    if (_radiationDose <= 0) then { continue };

    // Handle radiation sickness based on accumulated dose
    if (isDamageAllowed _x) then {
        [_x] call FUNC(handleRadiationSickness);
    };

} forEach _allLocalUnits;
