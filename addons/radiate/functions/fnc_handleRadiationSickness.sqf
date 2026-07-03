#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Handles radiation sickness symptoms based on accumulated radiation dose.
 * Called from fnc_handleUnitVitals after dose update.
 * Runs locally on each unit.
 *
 * KAT (KAM) Integration:
 *   - Automatically detects if KAT is loaded
 *   - If KAT present: replaces ACE effects with KAT-specific ones
 *   - If ACE-only: uses equivalent ACE fallbacks
 *   - All symptom templates are configurable below
 *
 * Each symptom template:
 *   [
 *     _symptomId,           // <STRING> unique identifier
 *     _thresholdOn,         // <NUMBER> dose to activate
 *     _thresholdOff,        // <NUMBER> dose to deactivate
 *     _effectType,          // <STRING> see below
 *     _chance,              // <NUMBER> 0.0 - 1.0 probability per tick
 *     _effectParams,        // <ARRAY>
 *     _repeatInterval       // <NUMBER> seconds between repeats while active (0 = one-shot on activation)
 *   ]
 *
 * Effect types (ACE):
 *   "sound"          → [soundClass] — playTone event
 *   "ppEffect"       → [name, minI, maxI] — blur/chromatic/colorCorrection
 *   "aceUnconscious" → [minTime, forceWakeup]
 *   "aceAdjustPain"  → [painDelta]
 *   "aceBloodVolume" → [bloodVolumeLoss]
 *   "aceBurn"        → [damage, bodyPart, damageType]
 *   "aceCardiacArrest"→ ["FatalVitals"/"Bleedout"]
 *
 * Effect types (KAT only):
 *   "katPuke"        → [] — kat_airway_fnc_handlePuking
 *   "katInternalBleeding" → [] — kat_circulation_fnc_updateInternalBleeding
 *   "katCardiacArrest"→ [arrestTypeNum, initialCA]
 *   "katFever"       → [tempDelta, bloodVol, deltaTime]
 *   "katHypoxia"     → [hr, anerobic, bloodGas, temp, baro, opioid, fatigue, delta]
 *   "katCoagulation" → [disruptionLevel]
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call kolmir_radiate_fnc_handleRadiationSickness
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("handleRadiationSickness called",_unit);

if (!alive _unit || {!local _unit}) exitWith {};

// Check if radiation sickness is enabled
private _enabled = missionNamespace getVariable [QGVAR(enableRadiationSickness), true];
if (!_enabled) exitWith {
    _unit setVariable [QGVAR(activeSymptoms), [], true];
};

private _radiationDose = _unit getVariable [QGVAR(radiationDose), 0];
private _activeSymptoms = _unit getVariable [QGVAR(activeSymptoms), []];

// --- DETECT KAT ---
private _hasKAT = GVAR(KATLoaded);

// --- BASE SYMPTOM LIST (ACE baseline) ---
// All entries use ACE effects by default.
// When KAT is present, specific entries are replaced with KAT versions below.
private _symptomTemplates = [
    // Mild symptoms (1000 - 2000 mSv)
    ["nausea",             1000,  800, "aceAdjustPain",   0.15, [0.15]],
    ["vomiting",           1200,  900, "sound",           0.15, [QGVAR(Vomit)]],
    ["headache",           1200,  900, "aceAdjustPain",   0.20, [0.20]],

    // Moderate symptoms (2000 - 3000 mSv)
    ["blurredVision",      2000, 1500, "ppEffect",        0.25, ["blur", 0.1, 0.4]],
    ["fatigue",            2200, 1600, "aceAdjustPain",   0.20, [0.30]],
    ["skinBurns",          2300, 1700, "aceBurn",         0.15, [0.2, "", "radiationBurn"]],
    ["weakness",           2600, 1900, "aceBloodVolume",  0.20, [0.1]],

    // Severe symptoms (3000+ mSv)
    ["severePain",         3000, 2200, "aceAdjustPain",   0.30, [0.50]],
    ["internalBleeding",   3100, 2300, "aceBloodVolume",  0.20, [0.2]],
    ["deepBurns",          3400, 2500, "aceBurn",         0.20, [0.4, "", "radiationBurn"]],
    ["collapsedLung",      3500, 2500, "aceAdjustPain",   0.20, [0.70]],
    ["fever",              3600, 2600, "aceAdjustPain",   0.25, [0.5]],
    ["unconsciousness",    3800, 2800, "aceUnconscious",  0.15, [10, true]],

    // Critical symptoms (4000+ mSv — LD50/60 threshold)
    ["criticalBleeding",       4000, 3000, "aceBloodVolume",    0.30, [0.3]],
    ["coagulationFailure",     4200, 3200, "custom",           0.20, [""]],
    ["deepComa",               4500, 3500, "aceUnconscious",    0.25, [30, true]],
    ["hypoxia",                4600, 3600, "aceBloodVolume",    0.25, [0.4]],
    ["cardiacArrest",          4800, 3800, "aceCardiacArrest",  0.20, ["FatalVitals"]],
    ["totalCoagulationFailure",5000, 4000, "custom",           0.30, [""]],
    ["bleedout",               5200, 4200, "aceCardiacArrest",  0.25, ["Bleedout"]]
];

// --- KAT-SPECIFIC UPGRADES ---
// Replace matching ACE entries with KAT-specific versions
if (_hasKAT) then {
    {
        private _index = _forEachIndex;
        private _id = _x select 0;

        switch (_id) do {
            case "vomiting": {
                _symptomTemplates set [_index, ["vomiting", 1200, 900, "katPuke", 0.15, []]];
            };
            case "internalBleeding": {
                _symptomTemplates set [_index, ["internalBleeding", 3100, 2300, "katInternalBleeding", 0.20, []]];
            };
            /*
            case "fever": {
                _symptomTemplates set [_index, ["fever", 3600, 2600, "katFever", 0.25, [3, 6, 1]]];
            };
            */
            case "hypoxia": {
                _symptomTemplates set [_index, ["hypoxia", 4600, 3600, "katHypoxia", 0.25, [0.60, 60]]];
            };
            case "cardiacArrest": {
                _symptomTemplates set [_index, ["cardiacArrest", 4800, 3800, "katCardiacArrest", 0.20, [4, true]]];
            };
            case "coagulationFailure": {
                _symptomTemplates set [_index, ["coagulationFailure", 4200, 3200, "katCoagulation", 0.20, [15]]];
            };
            case "totalCoagulationFailure": {
                _symptomTemplates set [_index, ["totalCoagulationFailure", 5000, 4000, "katCoagulation", 0.30, [35]]];
            };
            case "collapsedLung": {
                _symptomTemplates set [_index, ["collapsedLung", 5000, 4000, "katCollapsedLung", 0.30, [5]]];
            };
        };
    } forEach _symptomTemplates;
};

// --- CONFIGURABLE COEFFICIENTS ---
private _randomness = missionNamespace getVariable [QGVAR(radiationSicknessRandomness), 1.0];
private _symptomSpeed = missionNamespace getVariable [QGVAR(radiationSicknessSpeed), 1.0];
private _symptomInterval = missionNamespace getVariable [QGVAR(radiationSymptomInterval), 5];

// Damage severity coefficient — scales all damage with dose above threshold
// Formula: baseDamage * (1 + _severityCoeff * (doseAboveThreshold / thresholdOn))
// At 2x threshold dose, damage is multiplied by (1 + _severityCoeff)
private _severityCoeff = missionNamespace getVariable [QGVAR(radiationSeverityCoefficient), 0.5];

// Track last repeat times per symptom (stored on unit as hashmap)
private _lastRepeats = _unit getVariable [QGVAR(symptomLastRepeats), createHashMap];

// --- PROCESS SYMPTOMS (all damaging symptoms repeat and scale with dose) ---
private _newActiveSymptoms = [];
private _currentTime = CBA_missionTime;

{
    _x params ["_symptomId", "_thresholdOn", "_thresholdOff", "_effectType", "_chance", "_effectParams"];
    private _repeatInterval = if (count _x > 6) then { _x select 6 } else { 0 };

    // All damaging effect types repeat by default using the configurable interval
    if (_repeatInterval == 0) then {
        _repeatInterval = _symptomInterval;
    };

    // Higher symptomSpeed = lower thresholds = symptoms appear faster
    private _adjustedThresholdOn = _thresholdOn / _symptomSpeed;
    private _adjustedThresholdOff = _thresholdOff / _symptomSpeed;
    private _adjustedChance = (_chance * _randomness) min 1.0;

    // Calculate how far above threshold the dose is (0 = at threshold, 1 = 2x threshold)
    private _doseAboveThreshold = 0;
    if (_radiationDose > _adjustedThresholdOn) then {
        _doseAboveThreshold = (_radiationDose - _adjustedThresholdOn) / _adjustedThresholdOn;
    };

    // Scale damage: base * (1 + _severityCoeff * _doseAboveThreshold)
    private _severityMultiplier = 1 + (_severityCoeff * _doseAboveThreshold);

    private _isActive = _symptomId in _activeSymptoms;
    private _lastRepeat = _lastRepeats getOrDefault [_symptomId, 0];

    if (_radiationDose >= _adjustedThresholdOn) then {
        if (!_isActive && {random 1 < _adjustedChance}) then {
            // --- ACTIVATION (first time, always with base damage) ---
            _newActiveSymptoms pushBack _symptomId;
            _lastRepeats set [_symptomId, _currentTime];
            TRACE_2("Symptom activated",_unit,_symptomId);
            [_unit, _symptomId, _effectType, _effectParams, _radiationDose] call FUNC(applySymptomEffect);
        } else {
            if (_isActive) then {
                _newActiveSymptoms pushBack _symptomId;

                // --- REPEATING EFFECT — damage scales with dose ---
                if (_currentTime - _lastRepeat >= _repeatInterval) then {
                    _lastRepeats set [_symptomId, _currentTime];

                    // Scale damage params by severity multiplier for applicable types
                    private _scaledParams = _effectParams;
                    if (_effectType == "aceAdjustPain" || _effectType == "acePain") then {
                        private _basePain = _effectParams param [0, 0.1];
                        _scaledParams = [(_basePain * _severityMultiplier) min 1.0];
                    };
                    if (_effectType == "aceBloodVolume") then {
                        private _baseLoss = _effectParams param [0, 0.1];
                        _scaledParams = [(_baseLoss * _severityMultiplier)];
                    };
                    if (_effectType == "aceBurn") then {
                        private _baseDamage = _effectParams param [0, 0.2];
                        private _bodyPart = _effectParams param [1, ""];
                        private _damageType = _effectParams param [2, "radiationBurn"];
                        _scaledParams = [(_baseDamage * _severityMultiplier), _bodyPart, _damageType];
                    };
                    if (_effectType == "katHypoxia") then {
                        private _baseParams = _effectParams;
                        private _bloodGas = _baseParams param [2, [50, 55, 0.80, 22, 7.25]];
                        private _worsenedGas = [
                            (_bloodGas select 0) + (5 * _severityMultiplier),
                            (_bloodGas select 1) - (5 * _severityMultiplier),
                            ((_bloodGas select 2) - (0.03 * _severityMultiplier)) max 0.5,
                            _bloodGas select 3,
                            (_bloodGas select 4) - (0.05 * _severityMultiplier)
                        ];
                        _scaledParams = [
                            _baseParams param [0, 120],
                            _baseParams param [1, 1],
                            _worsenedGas,
                            _baseParams param [3, 39],
                            _baseParams param [4, 760],
                            _baseParams param [5, 0],
                            _baseParams param [6, 0],
                            _baseParams param [7, 1]
                        ];
                    };
                    if (_effectType == "katFever") then {
                        private _baseTemp = _effectParams param [0, 3];
                        _scaledParams = [(_baseTemp * _severityMultiplier), _effectParams param [1, 6], _effectParams param [2, 1]];
                    };
                    if (_effectType == "katCoagulation") then {
                        private _baseLevel = _effectParams param [0, 5];
                        _scaledParams = [((_baseLevel + (_doseAboveThreshold * 2)) min 10) max 0];
                    };

                    TRACE_3("Symptom repeated (scaled)",_unit,_symptomId,_severityMultiplier);
                    [_unit, _symptomId, _effectType, _scaledParams, _radiationDose] call FUNC(applySymptomEffect);
                };
            };
        };
    } else {
        if (_radiationDose <= _adjustedThresholdOff) then {
            if (_isActive) then {
                TRACE_2("Symptom deactivated",_unit,_symptomId);
                [_unit, _symptomId, _effectType, _effectParams, -1] call FUNC(applySymptomEffect);
            };
        } else {
            // Hysteresis zone — keep current state with repeating damage
            if (_isActive) then {
                _newActiveSymptoms pushBack _symptomId;

                if (_currentTime - _lastRepeat >= _repeatInterval) then {
                    _lastRepeats set [_symptomId, _currentTime];

                    // Same scaling logic for hysteresis zone
                    private _scaledParams = _effectParams;
                    if (_effectType == "aceAdjustPain" || _effectType == "acePain") then {
                        private _basePain = _effectParams param [0, 0.1];
                        _scaledParams = [(_basePain * _severityMultiplier) min 1.0];
                    };
                    if (_effectType == "aceBloodVolume") then {
                        private _baseLoss = _effectParams param [0, 0.1];
                        _scaledParams = [(_baseLoss * _severityMultiplier)];
                    };
                    if (_effectType == "aceBurn") then {
                        private _baseDamage = _effectParams param [0, 0.2];
                        private _bodyPart = _effectParams param [1, ""];
                        private _damageType = _effectParams param [2, "radiationBurn"];
                        _scaledParams = [(_baseDamage * _severityMultiplier), _bodyPart, _damageType];
                    };
                    if (_effectType == "katHypoxia") then {
                        private _baseParams = _effectParams;
                        private _bloodGas = _baseParams param [2, [50, 55, 0.80, 22, 7.25]];
                        private _worsenedGas = [
                            (_bloodGas select 0) + (5 * _severityMultiplier),
                            (_bloodGas select 1) - (5 * _severityMultiplier),
                            ((_bloodGas select 2) - (0.03 * _severityMultiplier)) max 0.5,
                            _bloodGas select 3,
                            (_bloodGas select 4) - (0.05 * _severityMultiplier)
                        ];
                        _scaledParams = [
                            _baseParams param [0, 120],
                            _baseParams param [1, 1],
                            _worsenedGas,
                            _baseParams param [3, 39],
                            _baseParams param [4, 760],
                            _baseParams param [5, 0],
                            _baseParams param [6, 0],
                            _baseParams param [7, 1]
                        ];
                    };
                    if (_effectType == "katFever") then {
                        private _baseTemp = _effectParams param [0, 3];
                        _scaledParams = [(_baseTemp * _severityMultiplier), _effectParams param [1, 6], _effectParams param [2, 1]];
                    };
                    if (_effectType == "katCoagulation") then {
                        private _baseLevel = _effectParams param [0, 5];
                        _scaledParams = [((_baseLevel + (_doseAboveThreshold * 2)) min 10) max 0];
                    };

                    TRACE_3("Symptom repeated in hysteresis (scaled)",_unit,_symptomId,_severityMultiplier);
                    [_unit, _symptomId, _effectType, _scaledParams, _radiationDose] call FUNC(applySymptomEffect);
                };
            };
        };
    };
} forEach _symptomTemplates;

_unit setVariable [QGVAR(activeSymptoms), _newActiveSymptoms, true];
_unit setVariable [QGVAR(symptomLastRepeats), _lastRepeats, true];
