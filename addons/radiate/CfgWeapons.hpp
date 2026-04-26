class CfgWeapons {
    class ACE_ItemCore;
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
};
