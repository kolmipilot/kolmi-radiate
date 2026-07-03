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

private _potassiumIodateEfficiency = missionNamespace getVariable [QGVAR(potassiumIodateEfficiencyMultiplier), 1.0];
private _radiationDose = _patient getVariable [QGVAR(radiationDose), 0];
private _newRadiationDose = (_radiationDose - (200 * _potassiumIodateEfficiency)) max 0; // 1.0 = 200 (25% lethal), 10.0 = 2000 (100% lethal)
_patient setVariable [QGVAR(radiationDose), _newRadiationDose, true];

private _medicationProtection = _patient getVariable [QGVAR(medicationProtection), 0];
private _newMedicationProtection = _medicationProtection + (20 * _potassiumIodateEfficiency);
_patient setVariable [QGVAR(medicationProtection), _newMedicationProtection, true];

[ {
    params ["_unit", "_potassiumIodateEfficiency"];
    private _protection = _unit getVariable [QGVAR(medicationProtection), 0];   
    _unit setVariable [QGVAR(medicationProtection), _protection - (20 * _potassiumIodateEfficiency)];  
    // Optional: Show message
    TRACE_1("Potassium Iodate protection faded",_unit); 
}, 
[_patient, _potassiumIodateEfficiency], 180] call CBA_fnc_waitAndExecute;
