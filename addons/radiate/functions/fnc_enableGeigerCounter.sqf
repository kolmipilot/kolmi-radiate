#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Enables the audio on the Geiger Counter.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call kolmir_radiate_fnc_enableGeigerCounter
 *
 * Public: No
 */

params ["_unit"];

_unit setVariable [QGVAR(GeigerCounterEnabled), true, true];

[{
    params ["_args", "_idPFH"];
    _args params ["_unit"];

    private _alive = alive _unit;

    if (!_alive) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };

    if !("kolmir_SimpleGeigerCounter" in assignedItems _unit) exitWith {
        _unit setVariable [QGVAR(GeigerCounterEnabled), false, true];
        _idPFH call CBA_fnc_removePerFrameHandler;
    };

    private _geigerSound = _unit getVariable [QGVAR(GeigerCounterSound), false];
    
    // Get raw intensity before protection from areaTypes
    private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];
    private _intensity = 0;
    
    {
        _intensity = _intensity + (_x select 1);
    } forEach _areaTypes;

    if (_geigerSound) then {
        switch true do {
            case (_intensity > 0.9): { [QGVAR(playTone), [_unit, QGVAR(chemTone)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 0.7): { [QGVAR(playTone), [_unit, QGVAR(chemRapidChime)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 0.5): { [QGVAR(playTone), [_unit, QGVAR(chemFastChime)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 0.3): { [QGVAR(playTone), [_unit, QGVAR(chemNormalChime)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 0): { [QGVAR(playTone), [_unit, QGVAR(chemSlowChime)], _unit] call CBA_fnc_targetEvent; };
            default { [QGVAR(playTone), [_unit, QGVAR(chemBaseChime)], _unit] call CBA_fnc_targetEvent; };
        };
    };
}, 5, [_unit]] call CBA_fnc_addPerFrameHandler;
