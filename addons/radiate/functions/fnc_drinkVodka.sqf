#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * Handles drinking vodka.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Consumed Item <STRING>
 * 2: Replacement Item <STRING>
 * 3: Thirst Quenched <NUMBER>
 * 4: Hunger Satiated <NUMBER>
 * 5: Is Magazine <BOOL>
 *
 * Return Value:
 * <BOOL>
 *
 * Example:
 * [player, "kolmir_VodkaBottle", "kolmir_VodkaBottle_Half", 10, 0, false] call kolmir_radiate_fnc_drinkVodka;
 *
 * Public: No
 */

params ["_unit", "_consumeItem", "_replacementItem", "_thirstQuenched", "_hungerSatiated", "_isMagazine"];
TRACE_2("drinkVodka",_unit,_consumeItem);

if (!alive _unit) exitWith {false};

// Define which items are considered vodka and their reduction values
private _vodkaItems = ["kolmir_VodkaBottle", "kolmir_VodkaBottle_Half"];

if (_consumeItem in _vodkaItems) then {
    [_unit] call FUNC(VodkaHandling);
};

true
