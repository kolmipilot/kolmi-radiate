#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Displays Simple Geiger Counter on screen.
 *
 * Arguments:
 * 0: unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kolmir_radiate_fnc_showGeigerCounter;
 *
 * Public: Yes
 */

params ["_unit"];

"kolmir_SimpleGeigerCounter" cutRsc ["kolmir_SimpleGeigerCounter", "PLAIN", 0, true];

if (isNull (uiNamespace getVariable ["kolmir_SimpleGeigerCounter", displayNull])) exitWith {};

GVAR(GeigerCounterActive) = true;
TRACE_1("kolmir_SimpleGeigerCounter: shown",_unit);

private _display = uiNamespace getVariable ["kolmir_SimpleGeigerCounter", displayNull];
private _exposure = _display displayCtrl 18805;

[{
    _this params ["_args", "_pfhID"];
    _args params ["_unit","_exposure"];

    if !(GVAR(GeigerCounterActive)) exitWith {
        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    if !(alive _unit) exitWith {
        call FUNC(hideGeigerCounter);
        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    if !("kolmir_SimpleGeigerCounter" in assignedItems _unit) exitWith {
        call FUNC(hideGeigerCounter);
        _pfhID call CBA_fnc_removePerFrameHandler;
    };

    // Get raw intensity before protection from areaTypes
    private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];
    private _intensity = 0;
    
    {
        _intensity = _intensity + (_x select 1);
    } forEach _areaTypes;

    if ((_unit getVariable [QGVAR(GeigerCounterEnabled), false])) then {

        TRACE_1("kolmir_SimpleGeigerCounter: exposurelvl",_intensity);
        _exposure ctrlSetText (_intensity toFixed 0);

    } else {
        _exposure ctrlSetText ("----");
    };

}, 1, [
    _unit,
    _exposure
]] call CBA_fnc_addPerFrameHandler;
