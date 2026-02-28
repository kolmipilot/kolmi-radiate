#include "..\script_component.hpp"
/*
* Author: kolmipilot
* This cant be called manualy!
*
*
* Arguments:
* 0: classname <strinG>
* 1: configname (CfgGlasses) <strinG>
*
* Return Value:
* List <ARRAY>
*
* Example:
* [backpack player, "Cfgweapons"] call kolmir_radiate_fnc_getlist;
*
* Public: No
*/
params ["_str", ["_cfg", "", [""]]];

private _clipstring = _str splitString ", ""[]()'";
private _array = [];
{
    if (isClass(configFile >> _cfg >> _x) || _cfg isEqualTo "") then {
        _array pushBackUnique _x
    };
    nil
} count _clipstring;

_array
