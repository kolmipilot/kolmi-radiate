#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Handles the radiation dose of units. Called from the statemachine's onState functions.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * Update Ran (at least 1 second between runs) <BOOL>
 *
 * Example:
 * [player] call kolmir_radiate_fnc_handleUnitVitals
 *
 * Public: No
 */


params ["_unit"];
TRACE_1("handleUnitVitals called",_unit);

private _lastTimeUpdated = _unit getVariable [QGVAR(lastTimeUpdated), CBA_missionTime];
private _deltaT = ((CBA_missionTime - _lastTimeUpdated) min 10) max 0;
_unit setVariable [QGVAR(lastTimeUpdated), CBA_missionTime, true];

private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];

if ((count _areaTypes) > 0 && isDamageAllowed _unit) then {

    private _radiationDose = _unit getVariable [QGVAR(radiationDose), 0];
    private _countedRadiationDose = _unit getVariable [QGVAR(countedRadiationDose), 0];

    private _hasMask = goggles _unit in (missionNamespace getVariable [QGVAR(availGasmaskList), []]);
    private _hasSuit = uniform _unit in (missionNamespace getVariable [QGVAR(availSuitsList), []]);
    private _hasBackpack = backpack _unit in (missionNamespace getVariable [QGVAR(availBackpackList), []]);
    private _hasFullProtection = _hasMask && _hasSuit;

    private _protection = 1;
    private _medicationProtection = _unit getVariable [QGVAR(medicationProtection), 0];
    if(_medicationProtection > 0) then { 
        _protection = _protection + _medicationProtection;
    };

    if (_hasMask) then { _protection = _protection + 10; };
    if (_hasSuit) then { _protection = _protection + 5; };
    if (_hasBackpack) then { _protection = _protection + 5; };

    private _activeTimerKeys = [];

    {
        private _type = _x select 0;
        private _intensity = _x select 1;
        private _sourceKey = _x select 2;
        private _contaminationSource = _x select 3;
        private _power = _x select 4;

        private _doseRate = 0;

        switch (_type) do {

            case "alpha": {

                if (_hasMask && _hasSuit) then {
                    _doseRate = 0;   
                } else {
                    if (_hasMask) then {
                        _doseRate = _intensity * 0.1;  
                    } else {
                        _doseRate = _intensity;
                    };
                };
            };

            case "beta": {
                _doseRate = _intensity / (_protection * 1);
            };

            case "gamma": {
                _doseRate = _intensity / (_protection * 0.1);
            };

            default {
                _doseRate = _intensity;
            };
        };

        private _additionalDose = (_doseRate * _deltaT) / 3600;
        _radiationDose = _radiationDose + _additionalDose;
        if([_unit] call FUNC(hasDosimeter)) then {
            _countedRadiationDose = _countedRadiationDose + _additionalDose;
        };


        //contamiation logic

        if (!_hasFullProtection && (_contaminationSource && {_intensity > 500})) then {
            private _contaminationList = _unit getVariable [QGVAR(Contamination), []];
            private _alreadyContaminatedFromThisSource = false;
            private _hasStrongerOrEqualContamination = false;
            private _existingContaminationIdx = -1;

            {    
                _x params ["_cType", "_cPower", "_cId", "_cSourceKey"];
                if (_cSourceKey isEqualTo _sourceKey) then {
                    _alreadyContaminatedFromThisSource = true;
                };
                if (_cType isEqualTo _type) then {
                    _existingContaminationIdx = _forEachIndex;
                    if (_cPower >= (_power * 0.1)) then {
                        _hasStrongerOrEqualContamination = true;
                    };
                };
            } forEach _contaminationList;

            if (!_alreadyContaminatedFromThisSource && !_hasStrongerOrEqualContamination) then {
                // Record that this timer is active this frame (local variable, no cross-machine sync needed)
                _activeTimerKeys pushBackUnique _sourceKey;

                private _timers = _unit getVariable [QGVAR(contaminationTimers), createHashMap];
                private _currentTime = _timers getOrDefault [_sourceKey, 0];
                _currentTime = _currentTime + RADIATION_MANAGER_PFH_DELAY;

                private _requiredTime = missionNamespace getVariable [QGVAR(contaminationTime), 30];
                if (_currentTime >= _requiredTime) then {
                    // Time to contaminate! Remove timer
                    _timers deleteAt _sourceKey;

                    private _newContaminationPower = _power * 0.1;

                    if (_existingContaminationIdx >= 0) then {
                        // Update existing contamination of this type
                        private _existingEntry = _contaminationList select _existingContaminationIdx;
                        _existingEntry params ["_cType", "_cPower", "_cId", "_cSourceKey"];

                        _existingEntry set [1, _newContaminationPower];
                        _existingEntry set [3, _sourceKey]; // Update source key to new source

                        // Update power in global RadiationSources hashmap (server-only, must route via event)
                        [QGVAR(updateRadiationSourcePower), [_cId, _newContaminationPower]] call CBA_fnc_serverEvent;
                    } else {
                        // Create a new contamination source attached to the unit
                        private _contaminationId = format ["%1_cont_%2_%3", netId _unit, _type, round(random 100000)];
                        _contaminationList pushBack [_type, _newContaminationPower, _contaminationId, _sourceKey];

                        [QGVAR(addRadiationSource), [
                            _unit,
                            _newContaminationPower,
                            _type,
                            false, // _contaminationSource = false
                            _contaminationId,
                            {
                                params ["_unit", "_contaminationId"];
                                private _activeContaminations = _unit getVariable [QGVAR(Contamination), []];
                                !isNull _unit && { (_activeContaminations findIf { _x select 2 isEqualTo _contaminationId }) >= 0 }
                            },
                            [_unit, _contaminationId]
                        ]] call CBA_fnc_serverEvent;
                    };

                    _unit setVariable [QGVAR(Contamination), _contaminationList, true];
                } else {
                    _timers set [_sourceKey, _currentTime];
                };
                _unit setVariable [QGVAR(contaminationTimers), _timers];
            };
        };

    } forEach _areaTypes;

    // Cleanup timers for sources no longer affecting this unit this frame
    private _allTimers = _unit getVariable [QGVAR(contaminationTimers), createHashMap];
    if (count _allTimers > 0) then {
        private _keysToRemove = (keys _allTimers) select { !(_x in _activeTimerKeys) };
        if (_keysToRemove isNotEqualTo []) then {
            { _allTimers deleteAt _x; } forEach _keysToRemove;
            _unit setVariable [QGVAR(contaminationTimers), _allTimers];
        };
    };

    _unit setVariable [QGVAR(radiationDose), _radiationDose, true];
    _unit setVariable [QGVAR(countedRadiationDose), _countedRadiationDose, true];

    TRACE_2("handleUnitVitals updated dose",_unit,_radiationDose);
};
