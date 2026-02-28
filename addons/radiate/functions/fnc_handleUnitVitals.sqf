#include "..\script_component.hpp"
/*
 * Author: kolmipilot, chatGPT
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

// Oblicz czas od ostatniej aktualizacji
private _lastTimeUpdated = _unit getVariable [QGVAR(lastTimeUpdated), CBA_missionTime];
private _deltaT = ((CBA_missionTime - _lastTimeUpdated) min 10) max 0;
_unit setVariable [QGVAR(lastTimeUpdated), CBA_missionTime, true];

// Pobierz typy promieniowania (2D array)
private _areaTypes = _unit getVariable [QGVAR(areaTypes), []];

if ((count _areaTypes) > 0) then {

    private _radiationDose = _unit getVariable [QGVAR(radiationDose), 0];
    private _countedRadiationDose = _unit getVariable [QGVAR(countedRadiationDose), 0];

    private _hasMask = goggles _unit in (missionNamespace getVariable [QGVAR(availGasmaskList), []]);
    private _hasSuit = uniform _unit in (missionNamespace getVariable [QGVAR(availSuitsList), []]);
    private _hasBackpack = backpack _unit in (missionNamespace getVariable [QGVAR(availBackpackList), []]);

    private _protection = 1;
    if (_hasMask) then { _protection = _protection + 10; };
    if (_hasSuit) then { _protection = _protection + 5; };
    if (_hasBackpack) then { _protection = _protection + 5; };

    {
        private _type = _x select 0;
        private _intensity = _x select 1;

        private _doseRate = 0;

        switch (_type) do {

            case "alpha": {

                if (_hasMask && _hasSuit) then {
                    _doseRate = 0;   // 100% blokady
                } else {
                    if (_hasMask) then {
                        _doseRate = _intensity * 0.1;  // -90%
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

    } forEach _areaTypes;

    _unit setVariable [QGVAR(radiationDose), _radiationDose, true];
    _unit setVariable [QGVAR(countedRadiationDose), _countedRadiationDose, true];

    TRACE_2("handleUnitVitals updated dose",_unit,_radiationDose);
};
