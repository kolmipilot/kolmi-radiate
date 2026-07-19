#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Decontaminates a unit, clearing all active contaminations and removing the radiation sources.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kolmir_radiate_fnc_decontamination
 *
 * Public: Yes
 */

params ["_unit"];
TRACE_1("decontamination called",_unit);

if (!isServer) exitWith {
    [QGVAR(decontaminationLocal), [_unit]] call CBA_fnc_serverEvent;
};

_unit setVariable [QGVAR(Contamination), [], true];
_unit setVariable [QGVAR(contaminationTimers), createHashMap];
