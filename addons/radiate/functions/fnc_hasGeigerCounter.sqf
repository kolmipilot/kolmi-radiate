#include "..\script_component.hpp"
/*
 * Author: kolmnipilot
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [player] call kolmir_radiate_fnc_hasGeigerCounter;
 *
 * Public: No
*/

params ["_unit"];

if ("kolmir_SimpleGeigerCounter" in assignedItems _unit) exitWith {
    true
};

false
