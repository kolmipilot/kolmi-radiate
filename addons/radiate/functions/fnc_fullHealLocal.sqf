#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Local callback for fully healing a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_fullHealLocal
 *
 * Public: No
 */

params ["_patient"];
TRACE_1("fullHealLocal kolmi radiate",_patient);

_patient setVariable [QGVAR(radiationDose), 0, true];
_patient setVariable [QGVAR(countedRadiationDose), 0, true];
_patient setVariable [QGVAR(medicationProtection), 0, true];
_patient setVariable [QGVAR(areaTypes), [], true];
