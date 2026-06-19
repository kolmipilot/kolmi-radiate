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
            case (_intensity > 3000): { [QGVAR(playTone), [_unit, QGVAR(CrazyGeiger)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 1500): { [QGVAR(playTone), [_unit, QGVAR(RapidGeiger)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 700): { [QGVAR(playTone), [_unit, QGVAR(FastGeiger)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 400): { [QGVAR(playTone), [_unit, QGVAR(NormalGeiger)], _unit] call CBA_fnc_targetEvent; };
            case (_intensity > 0): { [QGVAR(playTone), [_unit, QGVAR(SlowGeiger)], _unit] call CBA_fnc_targetEvent; };
            default { [QGVAR(playTone), [_unit, QGVAR(BaseGeiger)], _unit] call CBA_fnc_targetEvent; };
        };
    };
}, 4, [_unit]] call CBA_fnc_addPerFrameHandler;
