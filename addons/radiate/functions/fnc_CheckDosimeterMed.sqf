#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Checks the Radiation Dose and adds a log to ACE medical menu.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget] call kolmir_radiate_fnc_CheckDosimeterMed
 *
 * Public: No
 */

params ["_medic", "_patient"];

private _radiationDose = _patient getVariable [QGVAR(radiationDose), 0];
private _displayDose = _radiationDose * (random [0.9, 1, 1.1]);

private _output = (_displayDose toFixed 1);

[_patient, "quick_view", LLSTRING(CheckRadiation_Log), [_output]] call ACEFUNC(medical_treatment,addToLog);
