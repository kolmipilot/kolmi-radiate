#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Applies or removes a symptom effect on a unit.
 * Called from fnc_handleRadiationSickness.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Symptom ID <STRING>
 * 2: Effect Type <STRING> - "sound", "ppEffect", "aceUnconscious", "acePain", "aceAdjustPain", "aceBloodVolume", "aceBurn", "aceCardiacArrest", "katPuke", "katInternalBleeding", "katCardiacArrest", "katFever", "katHypoxia", "katCoagulation", "custom"
 * 3: Effect Params <ARRAY>
 * 4: Current Radiation Dose <NUMBER> (-1 means deactivation)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "nausea", "aceAdjustPain", [0.15], 1500] call kolmir_radiate_fnc_applySymptomEffect
 *
 * Public: No
 */

params ["_unit", "_symptomId", "_effectType", "_effectParams", "_radiationDose"];
TRACE_4("applySymptomEffect",_unit,_symptomId,_effectType,_radiationDose);

private _isActive = _radiationDose >= 0;

switch (_effectType) do {

    // --- SOUND via playTone event (consistent with the rest of the addon) ---
    case "sound": {
        _effectParams params [["_soundClass", ""], ["_volume", 1]];
        if (_isActive) then {
            // Use existing playTone event - same as in GeigerCounter
            [QGVAR(playTone), [_unit, _soundClass], _unit] call CBA_fnc_targetEvent;
        };
    };

    // --- POST-PROCESS EFFECTS (ppEffect) ---
    case "ppEffect": {
        _effectParams params [["_ppEffectName", ""], ["_intensityMin", 0], ["_intensityMax", 0]];
        if (_isActive) then {
            // Calculate intensity based on dose (linear interpolation between min and max)
            private _symptomThresholds = [
                ["nausea", 1000, 2000],
                ["headache", 1200, 2200],
                ["blurredVision", 2000, 3500],
                ["fatigue", 2200, 3200],
                ["weakness", 2600, 3600],
                ["severePain", 3000, 4000],
                ["collapsedLung", 3500, 4500],
                ["hemorrhage", 3200, 4200],
                ["criticalBleeding", 4000, 5000],
                ["deepComa", 4500, 5500]
            ];

            private _thresholdMin = 1000;
            private _thresholdMax = 4000;

            {
                _x params ["_id", "_tMin", "_tMax"];
                if (_id == _symptomId) exitWith {
                    _thresholdMin = _tMin;
                    _thresholdMax = _tMax;
                };
            } forEach _symptomThresholds;

            private _progress = linearConversion [_thresholdMin, _thresholdMax, _radiationDose, 0, 1];
            private _intensity = _intensityMin + (_intensityMax - _intensityMin) * _progress;
            _intensity = _intensity min _intensityMax;

            switch (_ppEffectName) do {
                case "blur": {
                    GVAR(ppBlur) ppEffectAdjust [_intensity];
                    GVAR(ppBlur) ppEffectCommit 1;
                    GVAR(ppBlur) ppEffectEnable true;
                };
                case "chromatic": {
                    GVAR(ppChromatic) ppEffectAdjust [_intensity, _intensity, true];
                    GVAR(ppChromatic) ppEffectCommit 1;
                    GVAR(ppChromatic) ppEffectEnable true;
                };
                case "colorCorrection": {
                    GVAR(ppColor) ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [0, 0, 0, _intensity], [0, 0, 0, 0]];
                    GVAR(ppColor) ppEffectCommit 1;
                    GVAR(ppColor) ppEffectEnable true;
                };
                default {
                    WARNING_1("Unknown ppEffect: %1",_ppEffectName);
                };
            };
        } else {
            // Disable the ppEffect
            switch (_ppEffectName) do {
                case "blur": {
                    GVAR(ppBlur) ppEffectAdjust [0];
                    GVAR(ppBlur) ppEffectCommit 1;
                    [{ GVAR(ppBlur) ppEffectEnable false; }, [], 1] call CBA_fnc_waitAndExecute;
                };
                case "chromatic": {
                    GVAR(ppChromatic) ppEffectAdjust [0, 0, true];
                    GVAR(ppChromatic) ppEffectCommit 1;
                    [{ GVAR(ppChromatic) ppEffectEnable false; }, [], 1] call CBA_fnc_waitAndExecute;
                };
                case "colorCorrection": {
                    GVAR(ppColor) ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
                    GVAR(ppColor) ppEffectCommit 1;
                    [{ GVAR(ppColor) ppEffectEnable false; }, [], 1] call CBA_fnc_waitAndExecute;
                };
                default {
                    WARNING_1("Unknown ppEffect: %1",_ppEffectName);
                };
            };
        };
    };

    // --- ACE UNCONSCIOUS ---
    // Usage: [_unit, true, 5, true] call ace_medical_fnc_setUnconscious
    // Arguments: [unit, setUnconscious, minTime, forceWakeupIfStable]
    case "aceUnconscious": {
        _effectParams params [["_minTime", 0], ["_forceWakeup", false]];
        if (_isActive) then {
            [_unit, true, _minTime, _forceWakeup] call ace_medical_fnc_setUnconscious;
        };
    };

    // --- ACE PAIN (direct setVariable - legacy, kept for compatibility) ---
    case "acePain": {
        _effectParams params [["_painAmount", 0]];
        if (_isActive) then {
            private _pain = _unit getVariable ["ace_medical_pain", 0];
            _unit setVariable ["ace_medical_pain", (_pain + _painAmount) min 1, true];
        };
    };

    // --- ACE ADJUST PAIN LEVEL (recommended by ACE) ---
    // Usage: [_unit, 0.5] call ace_medical_fnc_adjustPainLevel
    case "aceAdjustPain": {
        _effectParams params [["_painDelta", 0]];
        if (_isActive) then {
            [_unit, _painDelta] call ace_medical_fnc_adjustPainLevel;
        };
    };

    // --- ACE BLOOD VOLUME ---
    case "aceBloodVolume": {
        _effectParams params [["_bloodVolumeLoss", 0]];
        if (_isActive) then {
            private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6.0];
            _unit setVariable ["ace_medical_bloodVolume", (_bloodVolume - _bloodVolumeLoss) max 0, true];
        };
    };

    // --- ACE BURN (chemical/radiation burns) ---
    // Usage: [_unit, 0.2, "leftarm", "radiationBurn"] call ace_medical_fnc_addDamageToUnit
    // damage = burn severity (can increase over time)
    // bodyPart = "body", "leftarm", "rightarm", "leftleg", "rightleg"
    // typeOfDamage = "radiationBurn"
    case "aceBurn": {
        _effectParams params [["_damage", 0.2], ["_bodyPart", ""], ["_damageType", "radiationBurn"]];
        if (_isActive) then {
            private _bodyParts = ["body", "leftarm", "rightarm", "leftleg", "rightleg"];
            private _part = if (_bodyPart != "") then { _bodyPart } else { selectRandom _bodyParts };
            [_unit, _damage, _part, "radiationBurn"] call ace_medical_fnc_addDamageToUnit;
        };
    };

    // --- ACE CARDIAC ARREST (circulatory arrest) ---
    // Using ACE events: FatalVitals → cardiac arrest, Bleedout → exsanguination
    case "aceCardiacArrest": {
        _effectParams params [["_arrestType", "FatalVitals"]];
        if (_isActive) then {
            // "FatalVitals" → cardiac arrest
            // "Bleedout" → exsanguination
            private _event = ["ace_medical_FatalVitals", "ace_medical_Bleedout"] select (_arrestType == "Bleedout");
            [_event, _unit] call CBA_fnc_localEvent;
        };
    };

    // ====================================================================
    // KAT (KAM) ADVANCED MEDICAL — conditional, only works if KAT is loaded
    // ====================================================================

    // --- KAT PUKE (vomiting via KAT airway) ---
    // Usage: [player] call kat_airway_fnc_handlePuking
    // Blocks airways during unconsciousness
    case "katPuke": {
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                private _tone = selectRandom ["kat_airway_puke1", "kat_airway_puke2", "kat_airway_puke3"];
                [QGVAR(playTone), [_unit, _tone], _unit] call CBA_fnc_targetEvent;
            } else {
                // Fallback: use vomiting sound without blocking airway
                [QGVAR(playTone), [_unit, QGVAR(Vomit)], _unit] call CBA_fnc_targetEvent;
            };
        };
    };

    // --- KAT INTERNAL BLEEDING (internal bleeding) ---
    // Usage: [_unit, false] call kat_circulation_fnc_updateInternalBleeding
    // false = open bleeding, true = close
    case "katInternalBleeding": {
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                private _countTXA = ([_unit, "TXA"] call ACEFUNC(medical_status,getMedicationCount)) select 1;
                if(countTXA < 1) then {
                    _unit setVariable ["kat_circulation_internalBleeding", 0.03, true];
                    [{
                        params ["_unit"];
                        ([_unit, "TXA"] call ACEFUNC(medical_status,getMedicationCount)) select 1 > 0
                    }, {
                        params ["_unit"];
                        _unit setVariable ["kat_circulation_internalBleeding", 0, true];
                    }, [_unit]] call CBA_fnc_waitUntilAndExecute;
                };
            } else {
                // Fallback: use ACE blood volume
                private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6.0];
                _unit setVariable ["ace_medical_bloodVolume", (_bloodVolume - 0.15) max 0, true];
            };
        } else {
            if (GVAR(KATLoaded)) then {
                _unit setVariable ["kat_circulation_internalBleeding", 0, true];
            };
        };
    };

    // --- KAT CARDIAC ARREST (cardiac arrest via KAT) ---
    // Usage: [_unit, true, true] call kat_circulation_fnc_handleCardiacArrest
    // Parameters: [unit, active, initialCA]
    // Types: 0=normal, 1=asystole, 2=PEA, 3=VF, 4=VT
    case "katCardiacArrest": {
        _effectParams params [["_arrestTypeNum", 1], ["_initialCA", true]];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                ["ace_medical_FatalVitals", [_unit], _unit] call CBA_fnc_targetEvent;
                _unit setVariable ["kat_circulation_cardiacArrestType", _arrestTypeNum, true];
            } else {
                // Fallback: ACE FatalVitals event
                [QEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
            };
        };
    };

    // --- KAT FEVER (fever via KAT vitals) ---  FOR NOW REMOVED BECAUSE I CAN'T FIND "PUBLIC" FUNCTION 
    // Usage: [_unit, tempDelta, bloodVol, deltaTime, sync] call kat_vitals_fnc_handleTemperatureFunction
    case "katFever": {
        _effectParams params [["_tempDelta", 2], ["_bloodVol", 6], ["_deltaTime", 1]];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit, _tempDelta, _bloodVol, _deltaTime, false] call kat_vitals_fnc_handleTemperatureFunction;
            };
            // No fallback — ACE has no native temperature system
        };
    };

    // --- KAT HYPOXIA (hypoxia — SpO2 decrease) ---
    // Usage: [_unit, hr, anerobicPressure, bloodGas, temp, baroPressure, opioidDepression, aceFatigue, deltaTime, sync]
    //   call kat_vitals_fnc_handleOxygenFunction
    case "katHypoxia": {
    if (GVAR(KATLoaded)) then {
        _effectParams params [
            ["_targetSpO2", 0.60],
            ["_pO2", 50]
        ];

        if (_isActive) then {
            // Check if the smooth drop loop is already running to avoid duplication
            if (_unit getVariable [QGVAR(isDroppingO2), false]) exitWith {};
            _unit setVariable [QGVAR(isDroppingO2), true, true];

            // Define a local function (script) for gradually lowering parameters
            private _fnc_smoothDrop = {
                params ["_unit", "_targetSpO2", "_pO2", "_fnc_smoothDrop"];
                
                // If the effect was disabled in the meantime, stop the loop
                if !(_unit getVariable [QGVAR(isDroppingO2), false]) exitWith {};

                private _currentBloodGas = _unit getVariable ["kat_circulation_bloodGas", [80, 98, 0.73, 24, 7.4]];
                private _currentSpO2 = _currentBloodGas select 2;
                private _currentpO2 = _currentBloodGas select 1;

                // If we haven't reached the target yet, lower parameters (e.g. by 2 points per second)
                if (_currentSpO2 > _targetSpO2) then {
                    _currentBloodGas set [2, (_currentSpO2 - 2) max _targetSpO2];
                    _currentBloodGas set [1, (_currentpO2 - 2) max _pO2];
                    _unit setVariable ["kat_vitals_respiratoryDepth", 8, true];
                    _unit setVariable ["kat_circulation_bloodGas", _currentBloodGas, true];

                    // Call the same again in 1 second (unscheduled loop via CBA)
                    [_fnc_smoothDrop, [_unit, _targetSpO2, _pO2, _fnc_smoothDrop], 1] call CBA_fnc_waitAndExecute;
                }else{
                    _unit setVariable [QGVAR(isDroppingO2), false, true];
                }
            };

            // Start the first iteration of the loop
            [_unit, _targetSpO2, _pO2, _fnc_smoothDrop] call _fnc_smoothDrop;

        } else {
            // EFFECT ENDED: Disable the loop flag and restore health
            _unit setVariable [QGVAR(isDroppingO2), false, true];
            _unit setVariable ["kat_circulation_bloodGas", [80, 98, 0.73, 24, 7.4], true];
        };
    };
    };
    case "katCollapsedLung": {
    if (GVAR(KATLoaded)) then {
        _effectParams params [
            ["_volume", 6]
        ];

        if (_isActive) then {
            // Check if the smooth drop loop is already running to avoid duplication
            if (_unit getVariable [QGVAR(isDroppingVolume), false]) exitWith {};
            _unit setVariable [QGVAR(isDroppingVolume), true, true];

            _unit setVariable ["kat_breathing_pneumothorax", 4, true];
            [_unit, -48, -48, "ptx_tension", true] call kat_circulation_updateBloodPressureChange;
            [_unit] call kat_breathing_fnc_handlePneumothoraxDeterioration;

            // Define a local function (script) for gradually lowering parameters
            private _fnc_smoothDrop = {
                params ["_unit", "_volume", "_fnc_smoothDrop"];
                
                // If the effect was disabled in the meantime, stop the loop
                if !(_unit getVariable [QGVAR(isDroppingVolume), false]) exitWith {};

                private _currentLungsVolume = _unit getVariable ["kat_vitals_respiratoryDepth", 10];

                // If we haven't reached the target yet, lower parameters (e.g. by 2 points per second)
                if (_currentLungsVolume > _volume) then {
                    _currentLungsVolume set [2, (_currentLungsVolume - 2) max _volume];
                    _unit setVariable ["kat_vitals_respiratoryDepth", _currentLungsVolume, true];

                    // Call the same again in 1 second (unscheduled loop via CBA)
                    [_fnc_smoothDrop, [_unit, _volume, _fnc_smoothDrop], 1] call CBA_fnc_waitAndExecute;
                }else{
                    _unit setVariable [QGVAR(isDroppingVolume), false, true];
                }
            };

            // Start the first iteration of the loop
            [_unit, _volume, _fnc_smoothDrop] call _fnc_smoothDrop;

        } else {
            // EFFECT ENDED: Disable the loop flag and restore health
            _unit setVariable [QGVAR(isDroppingVolume), false, true];
            _unit setVariable ["kat_vitals_respiratoryDepth", 10, true];
        };
    };
    };

    // --- KAT COAGULATION (coagulation disorders) ---
    // Usage: sets KAT variables for coagulation
    // disruptionLevel 0-10: 0=normal, 10=no coagulation
    case "katCoagulation": {
    if (GVAR(KATLoaded)) then {
        _effectParams params [["_disruptionLevel", 5]];
        private _limit = missionNamespace getVariable ["kat_pharma_coagulation_factor_count", 30];

        if (_isActive) then {
            // Calculate reduction and ensure it stays within [0, _limit]
            private _reduction = ((10 - _disruptionLevel) max 0) min _limit;

            _unit setVariable ["kat_pharma_coagulationFactor", _reduction, true];
            // Trick the KAT system by setting saved 1 higher to block auto-regeneration
            _unit setVariable ["kat_pharma_coagulationSavedFactors", (_reduction + 1), true];
        } else {
            // Safely restore to the maximum limit defined in mission settings
            _unit setVariable ["kat_pharma_coagulationFactor", _limit, true];
            _unit setVariable ["kat_pharma_coagulationSavedFactors", _limit, true];
        };
    };
    // No fallback for pure ACE, since ACE does not have a native coagulation factor system
};

    // --- CUSTOM CODE ---
    case "custom": {
        _effectParams params [["_code", ""]];
        if (_code != "") then {
            private _fnc = compile _code;
            [_unit, _symptomId, _isActive] call _fnc;
        };
    };

    default {
        WARNING_1("Unknown effect type: %1",_effectType);
    };
};
