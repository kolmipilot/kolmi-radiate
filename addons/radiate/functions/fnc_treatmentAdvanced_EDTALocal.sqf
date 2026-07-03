#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Radiation-side EDTA local handler. 
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

private _edtaEfficiency = missionNamespace getVariable [QGVAR(edtaEfficiencyMultiplier), 1.0];
private _radiationDose = _patient getVariable [QGVAR(radiationDose), 0];
private _newRadiationDose = (_radiationDose - (400 * _edtaEfficiency)) max 0; // 1.0 = 400 (10% lethal), 10.0 = 4000 (100% lethal)
_patient setVariable [QGVAR(radiationDose), _newRadiationDose, true];

private _medicationProtection = _patient getVariable [QGVAR(medicationProtection), 0];
private _newMedicationProtection = _medicationProtection + (10 * _edtaEfficiency);
_patient setVariable [QGVAR(medicationProtection), _newMedicationProtection, true];

[ {
    params ["_unit"];
    private _protection = _unit getVariable [QGVAR(medicationProtection), 0];   
    _unit setVariable [QGVAR(medicationProtection), _protection - 10];  
    // Optional: Show message
    TRACE_1("EDTA protection faded",_unit); 
}, 
[_patient], 180] call CBA_fnc_waitAndExecute;
