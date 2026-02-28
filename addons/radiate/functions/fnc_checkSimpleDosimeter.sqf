#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Updates the vitals. Called from the statemachine's onState functions.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * Update Ran (at least 1 second between runs) <BOOL>
 *
 * Example:
 * [player] call kolmir_radiate_fnc_checkSimpleDosimeter
 *
 * Public: No
 */


params ["_unit"];

if(!([_unit] call FUNC(hasDosimeter))) exitWith {false};

private _countedRadiationDose = _unit getVariable [QGVAR(countedRadiationDose), 0];

// Get max oxygen time from mission settings, default to 3600 seconds (60 minutes).
private _deadlyRadiation = 4000;

// Calculate the number of bars to display (out of 10).
private _bars = round ((_countedRadiationDose / _deadlyRadiation) * 10);
if (_bars isEqualTo 0 && {_countedRadiationDose > 0}) then {
    _bars = 1; // Show at least one bar if there's any radiation dose left.
};
private _emptyBars = 10 - _bars;

// Determine the color of the bar based on remaining radiation dose.
private _color = [((2 * (1 - _countedRadiationDose / _deadlyRadiation)) min 1), ((2 * _countedRadiationDose / _deadlyRadiation) min 1), 0];

// Build the colored string for the filled bars.
private _string = "";
for "_a" from 1 to _bars do {
    _string = _string + "|";
};
private _text = [_string, _color] call ACEFUNC(common,stringToColoredText);

// Build the grey string for the empty bars.
_string = "";
for "_a" from 1 to _emptyBars do {
    _string = _string + "|";
};
_text = composeText [_text, [_string, "#808080"] call ace_common_fnc_stringToColoredText, lineBreak, str _countedRadiationDose, "mSv"];

// Get the picture of the backpack from its config.
private _picture = QPATHTOF(ui\SimpleDosimeter.paa);

// Display the text and picture to the player.
[_text, _picture] call ACEFUNC(common,displayTextPicture);
