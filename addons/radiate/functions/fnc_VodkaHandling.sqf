#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Handles drinking vodka.
 *
 * Return Value:
 * <BOOL>
 *
 * Example:
 * [player] call kolmir_radiate_fnc_drinkVodkaAce;
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("drinkVodka",_unit);

if (!alive _unit) exitWith {false};

private _vodkaEfficiency = missionNamespace getVariable [QGVAR(vodkaEfficiencyMultiplier), 1.0];
private _reductionPerDrink = 40 * _vodkaEfficiency; // 1.0 = 40 (1% lethal), 10.0 = 400 (10% lethal)
private _radiationDose = _unit getVariable [QGVAR(radiationDose), 0];

private _newRadiationDose = (_radiationDose - _reductionPerDrink) max 0;
_unit setVariable [QGVAR(radiationDose), _newRadiationDose, true];

private _protection = _unit getVariable [QGVAR(medicationProtection), 0];
private _newProtection = _protection + 5;
_unit setVariable [QGVAR(medicationProtection), _newProtection, true];

private _protectionDuration = missionNamespace getVariable [QGVAR(vodkaProtectionDuration), 180];
[ {
    params ["_unit"];
    private _protection = _unit getVariable [QGVAR(medicationProtection), 0];   
    _unit setVariable [QGVAR(medicationProtection), _protection - 5];  
    // Optional: Show message
    TRACE_1("Vodka protection faded",_unit); 
}, 
[_unit], _protectionDuration] call CBA_fnc_waitAndExecute;

// Add vodka level for chromatic aberration
private _vodkaLevel = _unit getVariable [QGVAR(vodkaLevel), 0];
private _newVodkaLevel = _vodkaLevel + 1;
_unit setVariable [QGVAR(vodkaLevel), _newVodkaLevel, true];

if (_newVodkaLevel >= 10) then {
    [_unit, true] call ACEFUNC(medical,setUnconscious);
};

[ {
    params ["_unit"];
    private _vodkaLevel = _unit getVariable [QGVAR(vodkaLevel), 0];   
    _unit setVariable [QGVAR(vodkaLevel), (_vodkaLevel - 1) max 0, true];  
    TRACE_1("Vodka level decreased",_unit); 
}, 
[_unit], _protectionDuration] call CBA_fnc_waitAndExecute;


TRACE_2("Vodka consumed, radiation reduced",_unit,_newRadiationDose);
