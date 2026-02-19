#include "..\script_component.hpp"
/*
* Author: DiGii, MiszczuZPolski
* This cant be called manualy!
*
* Arguments:
* 0: Logic <LOGIC>
* 1: Affected Units (not used) <ARRAY>
* 2: Activated <BOOL>
*
* Return Value:
* NONE
*
* Example:
* [] call kat_chemical_fnc_gasmodule;
*
* Public: No
*/
params ["_logic", "_units", "_activated"];

private _radius = _logic getVariable ["Radius", 20];
private _radiationLevel = _logic getVariable ["Radiation_Type", 1];

if (count _units == 0) then {_units pushBack _logic;};

if (!_activated) exitWith {};
if (isServer) then {

    [{
        params ["_logic", "_radius", "_radiationLevel", "_units"];

        {
            [QGVAR(addGasSource), [_x, _radius, _radiationLevel, _x, {
                params ["_endTime", "_logic"];

                // If logic no longer exists, exit
                if (isNull _logic) exitWith {
                    false // returns
                };

                CBA_missionTime < _endTime // return
            }, [CBA_missionTime + 1e10, _logic]]] call CBA_fnc_serverEvent;

        } forEach _units;

    }, [_logic, _radius, _radiationLevel, _units], 1] call CBA_fnc_waitAndExecute;

};
