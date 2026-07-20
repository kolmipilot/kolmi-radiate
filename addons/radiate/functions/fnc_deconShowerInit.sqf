#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Init function for the decontamination shower.
 * Source: https://github.com/diwako/diwako_cbrn
 *
 * Arguments:
 * 0: Shower <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [this] call kolmir_radiate_fnc_deconShowerInit;
 *
 * Public: No
 */

params ["_shower"];

if !(hasInterface) exitWith {};

_shower setVariable ["BIN_deconshower_disableAction", true];

private _action = [QGVAR(turn_on), "Turn on","",{
    [QGVAR(turnOnShower), [_target]] call cba_fnc_globalEvent;
    _target setVariable [QGVAR(deconshowerOn), true, true];
},{
    !(_target getVariable [QGVAR(deconshowerOn), false])
},{},[], [0,0,0], 5] call ace_interact_menu_fnc_createAction;
[_shower, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = [QGVAR(turn_off), "Turn off","",{
    [QGVAR(turnOffShower), [_target]] call cba_fnc_globalEvent;
    _target setVariable [QGVAR(deconshowerOn), false, true];
},{
    _target getVariable [QGVAR(deconshowerOn), false]
},{},[], [0,0,0], 5] call ace_interact_menu_fnc_createAction;
[_shower, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
