#include "..\script_component.hpp"
/*
 * Author: Glowbal, mharis001
 * Modified: MiszczuZPolski, Blue, Mazinski
 * Local callback for administering medication to a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 * 1: Body Part <STRING>
 * 2: Treatment <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "RightArm", "Morphine"] call kat_pharma_fnc_medicationLocal
 *
 * Public: No
 */

params ["_patient", "_bodyPart", "_classname"];
TRACE_3("medicationLocal",_patient,_bodyPart,_classname);

// Medication has no effects on dead units
if (!alive _patient) exitWith {};
TRACE_1("Running treatmentMedicationLocal with Advanced configuration for",_patient);

private _partIndex = ALL_BODY_PARTS find toLower _bodyPart;

// Get adjustment attributes for used medication
private _defaultConfig = configFile >> QUOTE(ACE_ADDON(Medical_Treatment)) >> "Medication";
private _medicationConfig = _defaultConfig >> _classname;

private _incompatibleMedication = GET_ARRAY(_medicationConfig >> "incompatibleMedication",getArray (_defaultConfig >> "incompatibleMedication"));

// Check for medication compatiblity
[_patient, _className, _incompatibleMedication] call ACEFUNC(medical_treatment,onMedicationUsage);

if (_className isEqualTo "EDTA") then {
    // EDTA does not use _bodyPart for its effect, only _patient
    [QGVAR(EDTALocal), [_patient], _patient] call CBA_fnc_targetEvent;
};
if (_className isEqualTo "PrussianBlue") then {
    // PrussianBlue does not use _bodyPart for its effect, only _patient
    [QGVAR(PrussianBlueLocal), [_patient], _patient] call CBA_fnc_targetEvent;
};
if (_className isEqualTo "PotassiumIodate") then {
    // PotassiumIodate does not use _bodyPart for its effect, only _patient
    [QGVAR(PotassiumIodateLocal), [_patient], _patient] call CBA_fnc_targetEvent;
};
