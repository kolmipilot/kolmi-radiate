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

// Zbierz wszystkie jednostki, które mogą być w promieniowaniu
private _unitsInZones = [];

// Reset previous frame radiation values so intensity is momentary
{
    _x setVariable [QGVAR(areaIntensity), 0, true];
    _x setVariable [QGVAR(areaTypes), [], true];
} forEach allUnits;

{
    _y params ["_radiationLogic", "_power", "_radiationType", "_condition", "_conditionArgs"];

    // Ochrona przed zerową lub ujemną mocą
    if (_power <= 0) then { continue };

    // Sprawdzenie warunku
    if !(_conditionArgs call _condition) then {
        detach _radiationLogic;
        deleteVehicle _radiationLogic;
        GVAR(RadiationSources) deleteAt _x;
        continue;
    };

    // --- PROMIEŃ Z MOCY ---
    // Dostosowany zasięg: większy radius, mniej efektywna radiacja
    private _radius = sqrt(_power) * 3;

    {
        private _distance = _x distance _radiationLogic;
        if (_distance > _radius) then { continue };

        // Odwrócona funkcja kwadratowa: intensity = power przy distance=0, 0 przy distance=radius
        private _intensity = _power * (1 - ((_distance / _radius) ^ 2));

        // Sumowanie intensywności
        private _prevIntensity = _x getVariable [QGVAR(areaIntensity), 0];
        _x setVariable [QGVAR(areaIntensity), _prevIntensity + _intensity, true];

        // --- NOWA LOGIKA areaType ---
        // Pobierz aktualną tablicę typów
        private _typeArray = _x getVariable [QGVAR(areaTypes), []];

        // Szukamy czy typ już istnieje
        private _found = false;

        {
            if ((_x select 0) isEqualTo _radiationType) exitWith {
                _x set [1, (_x select 1) + _intensity];
                _found = true;
            };
        } forEach _typeArray;

        // Jeśli nie istnieje – dodaj nowy wpis
        if (!_found) then {
            _typeArray pushBack [_radiationType, _intensity];
        };

        _x setVariable [QGVAR(areaTypes), _typeArray, true];

        [QGVAR(handleUnitVitals), [_x], _x] call CBA_fnc_targetEvent;

        _unitsInZones pushBackUnique _x;

    } forEach nearestObjects [_radiationLogic, ["CAManBase"], _radius];

} forEach GVAR(RadiationSources);
// Wyzeruj areaIntensity i areaTypes dla jednostek, które nie są już w żadnej strefie
{
    if (!(_x in _unitsInZones)) then {
        _x setVariable [QGVAR(areaTypes), [], true];
        _x setVariable [QGVAR(areaIntensity), 0, true];
    };
} forEach allUnits;
