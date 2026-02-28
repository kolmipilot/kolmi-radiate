/*
 * Mapuje wartości z UI (Zeus) do logicznych zmiennych Radius i Radiation_Type
 * Wywoływane przez onButtonClick przyciskiem OK w RscAttributes
 */
params ["_ctrl"];

// Znajdź display attributes
private _display = ctrlParent _ctrl;
if (isNull _display) exitWith {};

// Pobierz wartość promienia
private _radiusCtrl = _display displayCtrl 1611;
private _radius = parseNumber (ctrlText _radiusCtrl);

// Pobierz typ promieniowania
private _typeCtrl = _display displayCtrl 1617;
private _typeIndex = lbCurSel _typeCtrl;
private _type = _typeIndex;

// Ustaw na logice (jeśli jest dostępna)
private _logic = missionNamespace getVariable ["BIS_fnc_initCuratorAttributes_target", objNull];
if (!isNull _logic) then {
    _logic setVariable ["Radius", _radius, true];
    _logic setVariable ["Radiation_Type", _type, true];
};
