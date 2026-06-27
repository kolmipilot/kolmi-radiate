class CfgWeapons {
    class ACE_ItemCore;
    class ACE_morphine: ACE_ItemCore {};
    class CBA_MiscItem_ItemInfo;
    class kolmir_SimpleDosimeter : ACE_ItemCore {
        scope = 2;
        ACE_isTool = 1;
        author = "kolmipilot";
        displayName = CSTRING(SimpleDosimeter);
        model = "\A3\weapons_F\ammo\mag_univ.p3d";
        picture = QPATHTOF(ui\SimpleDosimeter.paa);
        descriptionShort = CSTRING(SimpleDosimeter_desc);
        descriptionUse = CSTRING(SimpleDosimeter_desc);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 1;
        };
    };
    class kolmir_EdtaAutoInjector: ACE_morphine {
        scope = 2;
        displayName = CSTRING(EdtaAutoInjector);
        picture = QPATHTOF(ui\icon_EdtaAutoInjector.paa);
        descriptionShort = CSTRING(EdtaAutoInjector_desc);
        ACE_isMedicalItem = 1;
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 0.5;
        };
    };
    class kolmir_BloodTester: ACE_ItemCore {
        scope = 2;
        displayName = CSTRING(BloodTester);
        picture = QPATHTOF(ui\icon_BloodTester.paa);
        model = "\A3\weapons_F\ammo\mag_univ.p3d";
        descriptionShort = CSTRING(BloodTester_desc);
        ACE_isMedicalItem = 1;
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 3;
        };
    };
    class ItemWatch;
    class kolmir_SimpleGeigerCounter : ItemWatch {
        ACE_hideItemType = "Watch";
        author = "kolmipilot";
        displayName = CSTRING(SimpleGeigerCounter);
        model = "\A3\weapons_F\ammo\mag_univ.p3d";
        picture = QPATHTOF(ui\SimpleGeigerCounter.paa);
        descriptionShort = CSTRING(SimpleGeigerCounter_desc);
        descriptionUse = CSTRING(SimpleGeigerCounter_desc);
    };
    class kolmir_AdvancedGeigerCounter: ItemWatch {
        ACE_hideItemType = "Watch";
        author = "kolmipilot";
        displayName = CSTRING(AdvancedGeigerCounter);
        model = "\A3\weapons_F\ammo\mag_univ.p3d";
        picture = QPATHTOF(ui\AdvancedGeigerCounter.paa);
        descriptionShort = CSTRING(AdvancedGeigerCounter_desc);
        descriptionUse = CSTRING(AdvancedGeigerCounter_desc);
    };

    // - Water Bottles --------------------------------------------------------
    class kolmir_VodkaBottle: ACE_ItemCore {
        author = "kolmipilot";
        scope = 2;
        displayName = CSTRING(VodkaBottle_DisplayName);
        descriptionShort = CSTRING(VodkaBottle_Description);
        model = QPATHTOF(data\vodka\vodkaBottle.p3d);
        picture = QPATHTOF(ui\absolut_ico.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 10;
        };
        XGVAR(consumeTime) = 10;
        XGVAR(thirstQuenched) = 10;
        XGVAR(consumeText) = CSTRING(DrinkingFromX);
        XGVAR(replacementItem) = "kolmir_VodkaBottle_Half";
        XGVAR(consumeAnims)[] = {QACEGVAR(drinkStand,field_rations), QACEGVAR(drinkCrouch,field_rations), QACEGVAR(drinkProne,field_rations)};
        XGVAR(consumeSounds)[] = {QACEGVAR(drink1,field_rations), QACEGVAR(drink1,field_rations), QACEGVAR(drink2,field_rations)};
        ACE_isFieldRationItem = 1;
    };

    class kolmir_VodkaBottle_Half: kolmir_VodkaBottle {
        author = "kolmipilot";
        displayName = CSTRING(VodkaBottleHalf_DisplayName);
        descriptionShort = CSTRING(VodkaBottleHalf_Description);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 5;
        };
        XGVAR(replacementItem) = "kolmir_VodkaBottle_Empty";
        XGVAR(refillItem) = "";
        XGVAR(refillAmount) = 0;
        XGVAR(refillTime) = 0;
    };

    class kolmir_VodkaBottle_Empty: kolmir_VodkaBottle {
        author = "kolmipilot";
        displayName = CSTRING(VodkaBottleEmpty_DisplayName);
        descriptionShort = CSTRING(VodkaBottleEmpty_Description);
        picture = QPATHTOF(ui\absolut_ico.paa);
        class ItemInfo: CBA_MiscItem_ItemInfo {
            mass = 1;
        };
        XGVAR(thirstQuenched) = 0;
        XGVAR(replacementItem) = "";
        XGVAR(refillItem) = "";
        XGVAR(refillAmount) = 0;
        XGVAR(refillTime) = 0;
    };
};
