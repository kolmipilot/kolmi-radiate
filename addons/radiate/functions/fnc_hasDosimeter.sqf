#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 *
 * Arguments:
 * 0: Target <OBJECT>
 *
 * Return Value:
 * Has any Dosimeter <BOOL>
 *
 * Example:
 * [player] call kolmir_radiate_fnc_hasDosimeter;
 *
 * Public: No
 */

params ["_unit"];

(('kolmir_SimpleDosimeter' in (items _unit)))
