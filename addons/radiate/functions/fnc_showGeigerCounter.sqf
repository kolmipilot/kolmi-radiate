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

if('kolmir_SimpleGeigerCounter' in assignedItems ACE_player) then {

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

        // Get raw intensity from areaTypes
        private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];
        private _intensity = 0;

        {
            _intensity = _intensity + (_x select 1);
        } forEach _areaTypes;

        if ((_unit getVariable [QGVAR(GeigerCounterEnabled), false])) then {
            private _randomizedIntensity = _intensity * (random [0.9, 1, 1.1]);
            TRACE_1("kolmir_SimpleGeigerCounter: exposurelvl",_randomizedIntensity);
            _exposure ctrlSetText (_randomizedIntensity toFixed 0);
        } else {
            _exposure ctrlSetText ("----");
        };

    }, 1, [
        _unit,
        _exposure
    ]] call CBA_fnc_addPerFrameHandler;

} else {
    "kolmir_AdvancedGeigerCounter" cutRsc ["kolmir_AdvancedGeigerCounter", "PLAIN", 0, true];

    if (isNull (uiNamespace getVariable ["kolmir_AdvancedGeigerCounter", displayNull])) exitWith {};

    GVAR(AdvancedGeigerCounterActive) = true;
    TRACE_1("kolmir_AdvancedGeigerCounter: shown",_unit);

    private _display = uiNamespace getVariable ["kolmir_AdvancedGeigerCounter", displayNull];
    private _exposure  = _display displayCtrl 18505; // summary
    private _exposure1 = _display displayCtrl 18506; // alpha
    private _exposure2 = _display displayCtrl 18507; // beta
    private _exposure3 = _display displayCtrl 18508; // gamma

    [{
        _this params ["_args", "_pfhID"];
        _args params ["_unit","_exposure","_exposure1","_exposure2","_exposure3"];

        if !(GVAR(AdvancedGeigerCounterActive)) exitWith {
            _pfhID call CBA_fnc_removePerFrameHandler;
        };

        if !(alive _unit) exitWith {
            call FUNC(hideGeigerCounter);
            _pfhID call CBA_fnc_removePerFrameHandler;
        };

        if !("kolmir_AdvancedGeigerCounter" in assignedItems _unit) exitWith {
            call FUNC(hideGeigerCounter);
            _pfhID call CBA_fnc_removePerFrameHandler;
        };

        // Get raw intensity from areaTypes
        private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];
        private _intensity = 0;
        { _intensity = _intensity + (_x select 1); } forEach _areaTypes;

        if ((_unit getVariable [QGVAR(AdvancedGeigerCounterEnabled), false])) then {

            // Summary — total of all types
            _exposure ctrlSetText ((_intensity * (random [0.9, 1, 1.1])) toFixed 0);

            // Per-type: search by name, 0 if not present
            private _alphaVal = 0;
            { if ((_x select 0) isEqualTo "alpha") then { _alphaVal = _x select 1; }; } forEach _areaTypes;

            private _betaVal = 0;
            { if ((_x select 0) isEqualTo "beta")  then { _betaVal  = _x select 1; }; } forEach _areaTypes;

            private _gammaVal = 0;
            { if ((_x select 0) isEqualTo "gamma") then { _gammaVal = _x select 1; }; } forEach _areaTypes;

            _exposure1 ctrlSetText ((_alphaVal * (random [0.9, 1, 1.1])) toFixed 0);
            _exposure2 ctrlSetText ((_betaVal  * (random [0.9, 1, 1.1])) toFixed 0);
            _exposure3 ctrlSetText ((_gammaVal * (random [0.9, 1, 1.1])) toFixed 0);

        } else {
            _exposure  ctrlSetText "----";
            _exposure1 ctrlSetText "----";
            _exposure2 ctrlSetText "----";
            _exposure3 ctrlSetText "----";
        };

    }, 1, [
        _unit,
        _exposure,
        _exposure1,
        _exposure2,
        _exposure3
    ]] call CBA_fnc_addPerFrameHandler;
};
