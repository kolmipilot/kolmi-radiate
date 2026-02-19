#include "script_component.hpp"

#define CBA_SETTINGS_CAT LSTRING(cba_name)

if (!isServer) exitWith {};

GVAR(RadiationSources) = createHashMap;

[QGVAR(addRadiationSource), {
    params [
        ["_source", objNull, [objNull, []]],
        ["_radius", 0, [0]],
        ["_radiationType", 0, [0]],
        ["_key", ""],
        ["_condition", {true}, [{}]],
        ["_conditionArgs", []]
    ];

    private _isObject = _source isEqualType objNull;

    // Check if the source is valid
    if !(_isObject || {_source isEqualTypeParams [0, 0, 0]}) exitWith {};

    if (_isObject && {isNull _source}) exitWith {};
    if (_radius == 0) exitWith {};
    if (_key isEqualTo "") exitWith {}; // key can be many types

    // hashValue supports more types than hashmaps do by default, but not all (e.g. locations)
    private _hashedKey = hashValue _key;

    if (isNil "_hashedKey") exitWith {
        ERROR_2("Unsupported key type used: %1 - %2",_key,typeName _key);
    };

    // If a position is passed, create a static object at said position
    private _sourcePos = if (_isObject) then {
        getPosATL _source
    } else {
        ASLToATL _source
    };

    private _radiationLogic = createVehicle [QGVAR(logic), _sourcePos, [], 0, "CAN_COLLIDE"];

    // If an object was passed, attach logic to the object
    if (_isObject) then {
        _radiationLogic attachTo [_source];
    };

    // To avoid issues, remove existing entries first before overwriting
    if (_hashedKey in GVAR(RadiationSources)) then {
        [QGVAR(removeRadiationSource), _key] call CBA_fnc_localEvent;
    };

    GVAR(RadiationSources) set [_hashedKey, [_radiationLogic, _radius, _radiationType, _condition, _conditionArgs]];
}] call CBA_fnc_addEventHandler;

[LINKFUNC(radiationManagerPFH), RADIATION_MANAGER_PFH_DELAY, []] call CBA_fnc_addPerFrameHandler;

