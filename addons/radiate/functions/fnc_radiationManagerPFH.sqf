#include "..\script_component.hpp"
/*
 * Author: komlmipilot
 * Handles various objects on radiation and determines if units close to objects deserve to get poisoned
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * kolmir_radiate_fnc_radiationManagerPFH call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Collect all units that may be in radiation zones
private _unitsInZones = [];
private _activeTimersPerUnit = createHashMap;

// Reset previous frame radiation values so intensity is momentary
{
    _x setVariable [QGVAR(areaTypes), [], true];
} forEach allUnits;

{
    private _sourceKey = _x;
    _y params ["_radiationLogic", "_power", "_radiationType", "_contaminationSource", "_condition", "_conditionArgs"];

    // Protection against zero or negative power
    if (_power <= 0) then { continue };

    // Check condition
    if !(_conditionArgs call _condition) then {
        detach _radiationLogic;
        deleteVehicle _radiationLogic;
        GVAR(RadiationSources) deleteAt _x;
        continue;
    };

    // --- RADIUS FROM POWER ---
    // Adjusted range: larger radius, less effective radiation
    private _radius = sqrt(_power) * 3;

    {
        private _unit = _x;
        private _distance = _unit distance _radiationLogic;
        if (_distance > _radius) then { continue };

        // Inverse square function: intensity = power at distance=0, 0 at distance=radius
        private _intensity = _power * (1 - ((_distance / _radius) ^ 2));

        // --- NEW areaType LOGIC ---
        // Get current type array
        private _typeArray = _unit getVariable [QGVAR(areaTypes), []];

        // Check if type already exists
        private _found = false;

        {
            if ((_x select 0) isEqualTo _radiationType) exitWith {
                _x set [1, (_x select 1) + _intensity];
                _found = true;
            };
        } forEach _typeArray;

        // If it doesn't exist - add new entry
        if (!_found) then {
            _typeArray pushBack [_radiationType, _intensity];
        };

        _unit setVariable [QGVAR(areaTypes), _typeArray, true];

        [QGVAR(handleUnitVitals), [_unit], _unit] call CBA_fnc_targetEvent;

        _unitsInZones pushBackUnique _unit;

        // --- CONTAMINATION LOGIC ---
        // Contaminate if source is marked as contamination source OR intensity > 500 mSv/h
        // Only if unit lacks proper CBRN protection (both mask and suit required)
        private _hasMask = goggles _unit in (missionNamespace getVariable [QGVAR(availGasmaskList), []]);
        private _hasSuit = uniform _unit in (missionNamespace getVariable [QGVAR(availSuitsList), []]);
        private _hasFullProtection = _hasMask && _hasSuit;

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
                if (_cType isEqualTo _radiationType) then {
                    _existingContaminationIdx = _forEachIndex;
                    if (_cPower >= (_power * 0.1)) then {
                        _hasStrongerOrEqualContamination = true;
                    };
                };
            } forEach _contaminationList;

            if (!_alreadyContaminatedFromThisSource && !_hasStrongerOrEqualContamination) then {
                // Record that this timer is active this frame
                private _unitHash = hashValue _unit;
                private _activeTimers = _activeTimersPerUnit getOrDefault [_unitHash, []];
                _activeTimers pushBack _sourceKey;
                _activeTimersPerUnit set [_unitHash, _activeTimers];

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

                        // Update power in global RadiationSources hashmap
                        private _hashedId = hashValue _cId;
                        private _sourceData = GVAR(RadiationSources) get _hashedId;
                        if (!isNil "_sourceData") then {
                            _sourceData set [1, _newContaminationPower];
                        };
                    } else {
                        // Create a new contamination source attached to the unit
                        private _contaminationId = format ["%1_cont_%2_%3", netId _unit, _radiationType, round(random 100000)];
                        _contaminationList pushBack [_radiationType, _newContaminationPower, _contaminationId, _sourceKey];

                        [QGVAR(addRadiationSource), [
                            _unit,
                            _newContaminationPower,
                            _radiationType,
                            false, // _contaminationSource = false
                            _contaminationId,
                            {
                                params ["_unit", "_contaminationId"];
                                private _activeContaminations = _unit getVariable [QGVAR(Contamination), []];
                                !isNull _unit && { (_activeContaminations findIf { _x select 2 isEqualTo _contaminationId }) >= 0 }
                            },
                            [_unit, _contaminationId]
                        ]] call CBA_fnc_localEvent;
                    };

                    _unit setVariable [QGVAR(Contamination), _contaminationList, true];
                } else {
                    _timers set [_sourceKey, _currentTime];
                };
                _unit setVariable [QGVAR(contaminationTimers), _timers];
            };
        };

    } forEach nearestObjects [_radiationLogic, ["CAManBase"], _radius];

} forEach GVAR(RadiationSources);

// Reset areaTypes for units no longer in any zone and cleanup inactive timers
{
    private _unit = _x;
    if (!(_unit in _unitsInZones)) then {
        _unit setVariable [QGVAR(areaTypes), [], true];
    };

    // Cleanup inactive timers
    private _timers = _unit getVariable [QGVAR(contaminationTimers), createHashMap];
    if (count _timers > 0) then {
        private _unitHash = hashValue _unit;
        private _activeKeys = _activeTimersPerUnit getOrDefault [_unitHash, []];
        private _keysToRemove = [];
        {
            if (!(_x in _activeKeys)) then {
                _keysToRemove pushBack _x;
            };
        } forEach _timers;

        if (_keysToRemove isNotEqualTo []) then {
            {
                _timers deleteAt _x;
            } forEach _keysToRemove;
            _unit setVariable [QGVAR(contaminationTimers), _timers];
        };
    };
} forEach allUnits;

