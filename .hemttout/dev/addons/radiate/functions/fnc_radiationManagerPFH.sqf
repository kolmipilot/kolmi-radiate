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

{
    _y params ["_radiationLogic", "_radius", "_radiationType", "_condition", "_conditionArgs", "_isSealable"];
    TRACE_2("rafiationManagerPFH loop",_x,_y);

    private _infectedObject = _y;

    // Remove when condition is no longer valid
    if !(_conditionArgs call _condition) then {
        TRACE_2("condition no longer valid, deleting",_x,_y);

        detach _radiationLogic;
        deleteVehicle _radiationLogic;

        GVAR(RadiationSources) deleteAt _x;

        continue;
    };

    // Poison units (alive or dead) close to the radiation source
    {
        // Get the distance of the unit from the center of the sphere (_radiationLogic)
        private _distance = _x distance _radiationLogic;

        // Ensure the distance does not exceed the radius (prevents going beyond the sphere)
        _distance = _distance min _radius;

        // Calculate the intensity as a normalized value (1 at center, 0 at the edge)
        private _intensity = 1 - (_distance / _radius);

        _x setVariable [QGVAR(areaIntensity), _intensity, true];
        _x setVariable [QGVAR(areaType), _radiationType, true];

        [QGVAR(poison), [_x, _radiationType, _infectedObject], _x] call CBA_fnc_targetEvent;

    } forEach nearestObjects [_radiationLogic, ["CAManBase"], _radius];
} forEach GVAR(RadiationSources);
