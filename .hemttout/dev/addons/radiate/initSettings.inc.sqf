
[
    QGVAR(availGasmask),
    "EDITBOX",
    [LLSTRING(SETTING_AVAIL_GASMASK), LLSTRING(SETTING_AVAIL_GASMASK_DISC)],
    CBA_SETTINGS_CAT,
    "'G_AirPurifyingRespirator_01_F', 'G_AirPurifyingRespirator_01_nofilter_F', 'kat_mask_M50', 'kat_mask_M04' 'G_AirPurifyingRespirator_02_black_F', 'G_AirPurifyingRespirator_02_olive_F', 'G_AirPurifyingRespirator_02_sand_F', 'G_RegulatorMask_F'",
    1,
    {
        private _array = [_this, "CfgGlasses"] call FUNC(getList);
        missionNamespace setVariable [QGVAR(availGasmaskList), _array, true];
    },
    true
] call CBA_fnc_addSetting;

[
    QGVAR(availBackpack),
    "EDITBOX",
    [LLSTRING(SETTING_AVAIL_BACKPACK), LLSTRING(SETTING_AVAIL_BACKPACK_DISC)],
    CBA_SETTINGS_CAT,
    "'B_SCBA_01_F', 'B_CombinationUnitRespirator_01_F'",
    1,
    {
        private _array = [_this, "CfgVehicles"] call FUNC(getList);
        missionNamespace setVariable [QGVAR(availBackpackList), _array, true];
    },
    true
] call CBA_fnc_addSetting;

[
    QGVAR(availSuits),
    "EDITBOX",
    [LLSTRING(SETTING_AVAIL_SUITS), LLSTRING(SETTING_AVAIL_SUITS_DISC)],
    CBA_SETTINGS_CAT,
    "'U_C_CBRN_Suit_01_Blue_F', 'U_B_CBRN_Suit_01_MTP_F', 'U_B_CBRN_Suit_01_Tropic_F', 'U_C_CBRN_Suit_01_White_F', 'U_B_CBRN_Suit_01_Wdl_F', 'U_I_CBRN_Suit_01_AAF_F', 'U_I_E_CBRN_Suit_01_EAF_F'",
    1,
    {
        private _array = [_this, "CfgWeapons"] call FUNC(getList);
        missionNamespace setVariable [QGVAR(availSuitsList), _array, true];
    },
    true
] call CBA_fnc_addSetting;
