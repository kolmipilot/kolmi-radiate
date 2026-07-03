#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Radiation-side Prussian Blue local handler. 
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value: 
 * None
 *
 * Public: No
 */

params ["_patient"];

private _PrussianBlueEfficiency = missionNamespace getVariable [QGVAR(PrussianBlueEfficiencyMultiplier), 1.0];
private _radiationDose = _patient getVariable [QGVAR(radiationDose), 0];
private _newRadiationDose = (_radiationDose - (300 * _PrussianBlueEfficiency)) max 0; // 1.0 = 300 (75% lethal), 10.0 = 3000 (100% lethal)
_patient setVariable [QGVAR(radiationDose), _newRadiationDose, true];

private _medicationProtection = _patient getVariable [QGVAR(medicationProtection), 0];
private _newMedicationProtection = _medicationProtection + (10 * _PrussianBlueEfficiency);
_patient setVariable [QGVAR(medicationProtection), _newMedicationProtection, true];

[ {
    params ["_unit", "_PrussianBlueEfficiency"];
    private _protection = _unit getVariable [QGVAR(medicationProtection), 0];   
    _unit setVariable [QGVAR(medicationProtection), _protection - (10 * _PrussianBlueEfficiency)];  
    // Optional: Show message
    TRACE_1("Prussian Blue protection faded",_unit); 
}, 
[_patient, _PrussianBlueEfficiency], 180] call CBA_fnc_waitAndExecute;
