#include "..\script_component.hpp"
/*
 * Author: DiGii
 *
 * Return Value:
 * NONE
 *
 * Example:
 * [] call kolmir_radiate_fnc_AttributeRadius;
 *
 * Public: No
 */

params ["_control"];

private _display = ctrlParent _control;
private _logic = missionNamespace getVariable ["BIS_fnc_initCuratorAttributes_target",objNull];
_control ctrlRemoveAllEventHandlers "SetFocus";

private _placeText = _display displayCtrl 1616;
private _maxEdit = _display displayCtrl 1611;
private _gasTypeCombo = _display displayCtrl 1617;

if !(isNull attachedTo _logic) then {
    _placeText ctrlSetText LLSTRING(radiationmodule_placemoduleonobject);
} else {
    _placeText ctrlSetText LLSTRING(radiationmodule_createcontaminatedzone);
};

_maxEdit ctrlSetText "100";

private _fnc_onKeyUp = {
    params ["_control"];
    private _display = ctrlParent _control;
    private _maxEdit = _display displayCtrl 1611;
    private _maxradius = parseNumber (ctrlText _maxEdit);

    if (_maxradius == 0) then {
        _maxEdit ctrlSetTooltip (ACELSTRING(Zeus,AttributeRadiusInvalid));
        _maxEdit ctrlSetTextColor [1,0,0,1];
    } else {
        _maxEdit ctrlSetTooltip "";
        _maxEdit ctrlSetTextColor [1,1,1,1];
        _display setVariable [QGVAR(ui_radius), _maxradius];
    };
};

private _fnc_onLBSelChange = {
    params ["_control"];
    private _display = ctrlParent _control;
    private _gastype = lbCurSel _control;
    _display setVariable [QGVAR(ui_gastype), _gastype];
};

[_maxEdit] call _fnc_onKeyUp;
[_gasTypeCombo] call _fnc_onLBSelChange;

_maxEdit ctrlAddEventHandler ["KeyUp", _fnc_onKeyUp];
_gasTypeCombo ctrlAddEventHandler ["LBSelChanged", _fnc_onLBSelChange];
