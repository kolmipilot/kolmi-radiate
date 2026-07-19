#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Initializes unit variables.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kolmir_radiate_fnc_init;
 *
 * Public: No
 */

params ["_unit", ["_isRespawn", true]];

if (!local _unit) exitWith {};
if !(GVAR(enable)) exitWith {};

// init variables
[_unit] call FUNC(fullHealLocal);
