#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Handles drinking vodka.
 *
 * Return Value:
 * <BOOL>
 *
 * Example:
 * [player] call kolmir_radiate_fnc_drinkVodkaAceHalf;
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("drinkVodka",_unit);

if (!alive _unit) exitWith {false};

private _drinkTime = missionNamespace getVariable [QGVAR(vodkaDrinkTime), 5];

[_drinkTime, _unit, {
    params ["_unit"];
    
    _unit addItem "kolmir_VodkaBottle_Empty";
    _unit removeItem "kolmir_VodkaBottle_Half";

    [_unit] call FUNC(VodkaHandling);

    true
}, {false}, "Drinking Vodka"] call ace_common_fnc_progressBar;
