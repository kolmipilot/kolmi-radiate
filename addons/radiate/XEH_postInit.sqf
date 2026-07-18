#include "script_component.hpp"

#define CBA_SETTINGS_CAT LSTRING(cba_name)

// Initialize KAT detection for all machines (both server and clients)
GVAR(KATLoaded) = [] call FUNC(hasKAT);

[QGVAR(handleUnitVitals), LINKFUNC(handleUnitVitals)] call CBA_fnc_addEventHandler;

["kolmir_PotassiumIodate_Item", "kolmir_PotassiumIodate"] call ace_common_fnc_registerItemReplacement;
["kolmir_PrussianBlue_Item", "kolmir_PrussianBlue"] call ace_common_fnc_registerItemReplacement;

[QGVAR(EDTALocal), LINKFUNC(treatmentAdvanced_EDTALocal)] call CBA_fnc_addEventHandler;
[QGVAR(medicationLocal), LINKFUNC(medicationLocal)] call CBA_fnc_addEventHandler;
["acex_rationConsumed", LINKFUNC(drinkVodka)] call CBA_fnc_addEventHandler;
[QGVAR(PrussianBlueLocal), LINKFUNC(treatmentAdvanced_PrussianBlueLocal)] call CBA_fnc_addEventHandler;
[QGVAR(PotassiumIodateLocal), LINKFUNC(treatmentAdvanced_PotassiumIodateLocal)] call CBA_fnc_addEventHandler;

[QGVAR(playTone), {
    params ["_unit", "_tone"];
    _unit say3D [_tone];
}] call CBA_fnc_addEventHandler;

[CBA_SETTINGS_CAT, QGVAR(showSimpleGeigerCounter), "Show Geiger Counter", {
    // Conditions: canInteract
    if (!([ACE_player, objNull, ["isNotEscorting", "isNotInside"]] call ACEFUNC(common,canInteractWith)) || {!(('kolmir_SimpleGeigerCounter' in assignedItems ACE_player) || ('kolmir_AdvancedGeigerCounter' in assignedItems ACE_player))}) exitWith { false };

    if !(GETMVAR(GVAR(GeigerCounterActive),false)) then {
        [ACE_player] call FUNC(showGeigerCounter);
    } else {
        call FUNC(hideGeigerCounter);
    };

    true
}, { false }, [24, [false, false, false]], false] call CBA_fnc_addKeybind;

if (hasInterface) then {
    call FUNC(initVodkaEffect);
    [LINKFUNC(handleVodkaEffect), 1] call CBA_fnc_addPerFrameHandler;

    // Initialize post-process effects for radiation sickness
    GVAR(ppBlur) = ppEffectCreate ["DynamicBlur", 450];
    GVAR(ppBlur) ppEffectEnable false;

    GVAR(ppChromatic) = ppEffectCreate ["ChromAberration", 451];
    GVAR(ppChromatic) ppEffectEnable false;

    GVAR(ppColor) = ppEffectCreate ["ColorCorrections", 452];
    GVAR(ppColor) ppEffectEnable false;

    // Radiation sickness PFH — runs on all clients, handles symptoms based on accumulated dose
    // independent of whether unit is currently in a radiation zone
    [LINKFUNC(radiationSicknessPFH), 2, []] call CBA_fnc_addPerFrameHandler;
};

if (!isServer) exitWith {};


GVAR(RadiationSources) = createHashMap;

[QGVAR(addRadiationSource), {
    params [
        ["_source", objNull, [objNull, []]],
        ["_radius", 0, [0]],
        ["_radiationType", "alpha", ["", 0]],
        ["_irradiationSource", false, [false, true]],
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
