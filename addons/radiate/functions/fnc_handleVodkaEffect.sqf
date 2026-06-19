#include "..\script_component.hpp"
/*
 * Author: kolmipilot, Antigravity
 * Handles visual effects for drinking vodka on the client.
 * Called from CBA per-frame handler (every 1 second).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Disable effect if player is dead or in curator/spectator mode
private _unit = ACE_player;
private _isSpectator = false;
if (!isNil "ACE_common_fnc_isSpectator") then {
    _isSpectator = [_unit] call ace_common_fnc_isSpectator;
};

// Check if effect is disabled by setting
private _enabled = missionNamespace getVariable [QGVAR(enableVodkaEffect), true];

if (!_enabled || !alive _unit || _isSpectator || cameraOn != _unit) exitWith {
    if (!isNil {GVAR(vodkaEffect)} && {GVAR(vodkaEffect) != -1}) then {
        GVAR(vodkaEffect) ppEffectAdjust [0, 0, true];
        GVAR(vodkaEffect) ppEffectCommit 0.5;
        [{ GVAR(vodkaEffect) ppEffectEnable false; }, [], 0.5] call CBA_fnc_waitAndExecute;
    };
};

private _vodkaLevel = _unit getVariable [QGVAR(vodkaLevel), 0];

// Force unconsciousness if local player's vodka level is at the configured threshold and they are not unconscious
private _unconsciousLevel = missionNamespace getVariable [QGVAR(vodkaUnconsciousLevel), 10];
if (_vodkaLevel >= _unconsciousLevel && {!(_unit getVariable ["ACE_isUnconscious", false])}) then {
    [_unit, true, 5, true] call ace_medical_fnc_setUnconscious;
};

private _limit = missionNamespace getVariable [QGVAR(vodkaLimitBeforeEffect), 2];


// If vodka level is low, disable/fade out the effect
if (_vodkaLevel < _limit) exitWith {
    if (!isNil {GVAR(vodkaEffect)} && {GVAR(vodkaEffect) != -1}) then {
        GVAR(vodkaEffect) ppEffectAdjust [0, 0, true];
        GVAR(vodkaEffect) ppEffectCommit 1;
        [{ GVAR(vodkaEffect) ppEffectEnable false; }, [], 1] call CBA_fnc_waitAndExecute;
    };
};

// If we reach here, we have enough vodka level to enable the effect
if (!isNil {GVAR(vodkaEffect)} && {GVAR(vodkaEffect) != -1}) then {
    GVAR(vodkaEffect) ppEffectEnable true;
};

// Pulse logic (every 4 seconds)
private _showNextTick = missionNamespace getVariable [QGVAR(showVodkaNextTick), 0];
_showNextTick = (_showNextTick + 1) mod 4;
missionNamespace setVariable [QGVAR(showVodkaNextTick), _showNextTick];

if (_showNextTick != 0) exitWith {};

// Calculate intensity: starts at 0.2 and caps at 0.8
private _intensity = ((_vodkaLevel - _limit + 1) * 0.2) min 0.8;

private _initialAdjust = [_intensity, _intensity, true];
private _delayedAdjust = [_intensity * 0.15, _intensity * 0.15, true];

if (!isNil {GVAR(vodkaEffect)} && {GVAR(vodkaEffect) != -1}) then {
    GVAR(vodkaEffect) ppEffectAdjust _initialAdjust;
    GVAR(vodkaEffect) ppEffectCommit 0.3; // Fade in

    [{
        if (!isNil {GVAR(vodkaEffect)} && {GVAR(vodkaEffect) != -1}) then {
            GVAR(vodkaEffect) ppEffectAdjust _this;
            GVAR(vodkaEffect) ppEffectCommit 0.7; // Fade out
        };
    }, _delayedAdjust, 0.3] call CBA_fnc_waitAndExecute;
};
