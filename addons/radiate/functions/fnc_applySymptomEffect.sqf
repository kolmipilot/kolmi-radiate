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

    // --- SOUND via playTone event (spójne z resztą addonu) ---
    case "sound": {
        _effectParams params [["_soundClass", ""], ["_volume", 1]];
        if (_isActive) then {
            // Użyj istniejącego eventu playTone - tak samo jak w GeigerCounter
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
    // Użycie: [_unit, true, 5, true] call ace_medical_fnc_setUnconscious
    // Argumenty: [unit, setUnconscious, minTime, forceWakeupIfStable]
    case "aceUnconscious": {
        _effectParams params [["_minTime", 0], ["_forceWakeup", false]];
        if (_isActive) then {
            [_unit, true, _minTime, _forceWakeup] call ace_medical_fnc_setUnconscious;
        };
    };

    // --- ACE PAIN (bezpośrednie setVariable - stare, zachowane dla kompatybilności) ---
    case "acePain": {
        _effectParams params [["_painAmount", 0]];
        if (_isActive) then {
            private _pain = _unit getVariable ["ace_medical_pain", 0];
            _unit setVariable ["ace_medical_pain", (_pain + _painAmount) min 1, true];
        };
    };

    // --- ACE ADJUST PAIN LEVEL (zalecane przez ACE) ---
    // Użycie: [_unit, 0.5] call ace_medical_fnc_adjustPainLevel
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

    // --- ACE BURN (oparzenia chemiczne/popromienne) ---
    // Użycie: [_unit, 0.2, "leftarm", "radiationBurn"] call ace_medical_fnc_addDamageToUnit
    // damage = siła oparzenia (może rosnąć z czasem)
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

    // --- ACE CARDIAC ARREST (zatrzymanie krążenia) ---
    // Użycie eventów ACE: FatalVitals → cardiac arrest, Bleedout → wykrwawienie
    case "aceCardiacArrest": {
        _effectParams params [["_arrestType", "FatalVitals"]];
        if (_isActive) then {
            // "FatalVitals" → zatrzymanie krążenia
            // "Bleedout" → wykrwawienie
            private _event = [QEGVAR(medical,FatalVitals), QEGVAR(medical,Bleedout)] select (_arrestType == "Bleedout");
            [_event, _unit] call CBA_fnc_localEvent;
        };
    };

    // ====================================================================
    // KAT (KAM) ADVANCED MEDICAL — warunkowe, działają tylko jeśli KAT jest załadowany
    // ====================================================================

    // --- KAT PUKE (wymioty przez KAT airway) ---
    // Użycie: [player] call kat_airway_fnc_handlePuking
    // Blokuje drogi oddechowe podczas uncon
    case "katPuke": {
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit] call kat_airway_fnc_handlePuking;
            } else {
                // Fallback: użyj dźwięku wymiotów bez blokowania airway
                [QGVAR(playTone), [_unit, QGVAR(sfx_vomit)], _unit] call CBA_fnc_targetEvent;
            };
        };
    };

    // --- KAT INTERNAL BLEEDING (krwawienie wewnętrzne) ---
    // Użycie: [_unit, false] call kat_circulation_fnc_updateInternalBleeding
    // false = otwórz krwawienie, true = zamknij
    case "katInternalBleeding": {
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit, false] call kat_circulation_fnc_updateInternalBleeding;
            } else {
                // Fallback: użyj ACE blood volume
                private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6.0];
                _unit setVariable ["ace_medical_bloodVolume", (_bloodVolume - 0.15) max 0, true];
            };
        };
    };

    // --- KAT CARDIAC ARREST (zatrzymanie serca przez KAT) ---
    // Użycie: [_unit, true, true] call kat_circulation_fnc_handleCardiacArrest
    // Parametry: [unit, active, initialCA]
    // Typy: 0=normal, 1=asystole, 2=PEA, 3=VF, 4=VT
    case "katCardiacArrest": {
        _effectParams params [["_arrestTypeNum", 1], ["_initialCA", true]];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit, true, _initialCA] call kat_circulation_fnc_handleCardiacArrest;
            } else {
                // Fallback: ACE FatalVitals event
                [QEGVAR(medical,FatalVitals), _unit] call CBA_fnc_localEvent;
            };
        };
    };

    // --- KAT FEVER (gorączka przez KAT vitals) ---
    // Użycie: [_unit, tempDelta, bloodVol, deltaTime, sync] call kat_vitals_fnc_handleTemperatureFunction
    case "katFever": {
        _effectParams params [["_tempDelta", 2], ["_bloodVol", 6], ["_deltaTime", 1]];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit, _tempDelta, _bloodVol, _deltaTime, false] call kat_vitals_fnc_handleTemperatureFunction;
            };
            // Brak fallback — ACE nie ma natywnej temperatury
        };
    };

    // --- KAT HYPOXIA (niedotlenienie — spadek SpO2) ---
    // Użycie: [_unit, hr, anerobicPressure, bloodGas, temp, baroPressure, opioidDepression, aceFatigue, deltaTime, sync]
    //   call kat_vitals_fnc_handleOxygenFunction
    case "katHypoxia": {
        _effectParams params [
            ["_heartRate", 100],
            ["_anerobicPressure", 1],
            ["_bloodGas", [50, 60, 0.85, 24, 7.3]],
            ["_temperature", 38.5],
            ["_baroPressure", 760],
            ["_opioidDepression", 0],
            ["_aceFatigue", 0],
            ["_deltaTime", 1]
        ];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                [_unit, _heartRate, _anerobicPressure, _bloodGas, _temperature, _baroPressure, _opioidDepression, _aceFatigue, _deltaTime, false] call kat_vitals_fnc_handleOxygenFunction;
            };
            // Brak fallback — ACE nie ma natywnego SpO2
        };
    };

    // --- KAT COAGULATION (zaburzenia krzepnięcia) ---
    // Użycie: ustawia zmienne KAT dla koagulacji
    // disruptionLevel 0-10: 0=normal, 10=brak krzepnięcia
    case "katCoagulation": {
        _effectParams params [["_disruptionLevel", 5]];
        if (_isActive) then {
            if (GVAR(KATLoaded)) then {
                private _reduction = (10 - _disruptionLevel) max 0;
                _unit setVariable ["kat_pharma_coagulationFactor", _reduction, true];

                if (_disruptionLevel >= 5) then {
                    private _timeMultiplier = 1 + (_disruptionLevel / 10) * 5;
                    missionNamespace setVariable ["kat_pharma_coagulation_time_minor", round(15 * _timeMultiplier)];
                    missionNamespace setVariable ["kat_pharma_coagulation_time_medium", round(30 * _timeMultiplier)];
                    missionNamespace setVariable ["kat_pharma_coagulation_time_large", round(45 * _timeMultiplier)];
                };

                if (_disruptionLevel >= 6) then {
                    missionNamespace setVariable ["kat_pharma_coagulation_requireBV", 5.0];
                };

                if (_disruptionLevel >= 8) then {
                    missionNamespace setVariable ["kat_pharma_coagulation_allow_MinorWounds", false];
                    missionNamespace setVariable ["kat_pharma_coagulation_allow_MediumWounds", false];
                };

                if (_disruptionLevel >= 9) then {
                    missionNamespace setVariable ["kat_pharma_coagulation", false];
                };
            };
            // Brak fallback — ACE nie ma systemu koagulacji
        } else {
            // Przywróć domyślne ustawienia koagulacji
            if (GVAR(KATLoaded)) then {
                _unit setVariable ["kat_pharma_coagulationFactor", 30, true];
                missionNamespace setVariable ["kat_pharma_coagulation", true];
                missionNamespace setVariable ["kat_pharma_coagulation_time_minor", 15];
                missionNamespace setVariable ["kat_pharma_coagulation_time_medium", 30];
                missionNamespace setVariable ["kat_pharma_coagulation_time_large", 45];
                missionNamespace setVariable ["kat_pharma_coagulation_requireBV", 3.6];
                missionNamespace setVariable ["kat_pharma_coagulation_allow_MinorWounds", true];
                missionNamespace setVariable ["kat_pharma_coagulation_allow_MediumWounds", true];
            };
        };
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
