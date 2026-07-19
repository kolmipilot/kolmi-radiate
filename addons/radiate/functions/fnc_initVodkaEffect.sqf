#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Initializes visual effects for drinking vodka.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (isNil {GVAR(vodkaEffect)} || {GVAR(vodkaEffect) isEqualTo -1}) then {
    private _effect = ppEffectCreate ["ChromAberration", 213725];
    _effect ppEffectForceInNVG true;
    _effect ppEffectAdjust [0, 0, true];
    _effect ppEffectCommit 0;
    GVAR(vodkaEffect) = _effect;
};
