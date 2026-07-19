
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

[
    QGVAR(treatmentTime_EDTA),
    "SLIDER",
    ["EDTA treatment time", "EDTA treatment time"],
    CBA_SETTINGS_CAT,
    [1, 60, 5, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(CheckRadiation_TreatmentTime),
    "SLIDER",
    ["Check Radiation Treatment Time", "Check Radiation Treatment Time"],
    CBA_SETTINGS_CAT,
    [1, 60, 10, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(enableVodkaEffect),
    "CHECKBOX",
    [LLSTRING(setting_enableVodkaEffect), LLSTRING(setting_enableVodkaEffect_desc)],
    CBA_SETTINGS_CAT,
    [true],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(vodkaLimitBeforeEffect),
    "SLIDER",
    [LLSTRING(setting_vodkaLimitBeforeEffect), LLSTRING(setting_vodkaLimitBeforeEffect_desc)],
    CBA_SETTINGS_CAT,
    [1, 10, 2, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(vodkaProtectionDuration),
    "SLIDER",
    [LLSTRING(setting_vodkaProtectionDuration), LLSTRING(setting_vodkaProtectionDuration_desc)],
    CBA_SETTINGS_CAT,
    [10, 1200, 180, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(vodkaDrinkTime),
    "SLIDER",
    [LLSTRING(setting_vodkaDrinkTime), LLSTRING(setting_vodkaDrinkTime_desc)],
    CBA_SETTINGS_CAT,
    [1, 30, 5, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(vodkaUnconsciousLevel),
    "SLIDER",
    [LLSTRING(setting_vodkaUnconsciousLevel), LLSTRING(setting_vodkaUnconsciousLevel_desc)],
    CBA_SETTINGS_CAT,
    [1, 30, 10, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(vodkaEfficiencyMultiplier),
    "SLIDER",
    [LLSTRING(setting_vodkaEfficiencyMultiplier), LLSTRING(setting_vodkaEfficiencyMultiplier_desc)],
    CBA_SETTINGS_CAT,
    [0.1, 10, 1, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(edtaEfficiencyMultiplier),
    "SLIDER",
    [LLSTRING(setting_edtaEfficiencyMultiplier), LLSTRING(setting_edtaEfficiencyMultiplier_desc)],
    CBA_SETTINGS_CAT,
    [0.1, 10, 1, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(potassiumIodateEfficiencyMultiplier),
    "SLIDER",
    [LLSTRING(setting_potassiumIodateEfficiencyMultiplier), LLSTRING(setting_potassiumIodateEfficiencyMultiplier_desc)],
    CBA_SETTINGS_CAT,
    [0.1, 10, 1, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(prussianBlueEfficiencyMultiplier),
    "SLIDER",
    [LLSTRING(setting_prussianBlueEfficiencyMultiplier), LLSTRING(setting_prussianBlueEfficiencyMultiplier_desc)],
    CBA_SETTINGS_CAT,
    [0.1, 10, 1, 1],
    1
] call CBA_fnc_addSetting;

// --- Radiation Sickness Settings ---
[
    QGVAR(radiationSicknessRandomness),
    "SLIDER",
    [LLSTRING(setting_radiationSicknessRandomness), LLSTRING(setting_radiationSicknessRandomness_desc)],
    CBA_SETTINGS_CAT,
    [0, 2, 1, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(radiationSicknessSpeed),
    "SLIDER",
    [LLSTRING(setting_radiationSicknessSpeed), LLSTRING(setting_radiationSicknessSpeed_desc)],
    CBA_SETTINGS_CAT,
    [0.1, 5, 1, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(enableRadiationSickness),
    "CHECKBOX",
    [LLSTRING(setting_enableRadiationSickness), LLSTRING(setting_enableRadiationSickness_desc)],
    CBA_SETTINGS_CAT,
    [true],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(radiationSymptomInterval),
    "SLIDER",
    [LLSTRING(setting_radiationSymptomInterval), LLSTRING(setting_radiationSymptomInterval_desc)],
    CBA_SETTINGS_CAT,
    [1, 1000, 60, 0],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(radiationSeverityCoefficient),
    "SLIDER",
    [LLSTRING(setting_radiationSeverityCoefficient), LLSTRING(setting_radiationSeverityCoefficient_desc)],
    CBA_SETTINGS_CAT,
    [0, 3, 0.5, 1],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(contaminationTime),
    "SLIDER",
    ["Contamination Time", "Time in seconds spent inside a source before becoming contaminated"],
    CBA_SETTINGS_CAT,
    [1, 300, 30, 0],
    1
] call CBA_fnc_addSetting;

