class CfgMagazines {
    class CA_Magazine;
    class ACE_painkillers: CA_Magazine {};
    class kolmir_PotassiumIodate: ACE_painkillers {
        displayName = CSTRING(potassiumIodate);
        author = "kolmipilot";
        descriptionShort = CSTRING(potassiumIodate_desc);
        descriptionUse = CSTRING(Administer_PotassiumIodate);
        picture = QPATHTOF(ui\potasumIodineIco.paa);
        count = 10;
    };
    class kolmir_PrussianBlue: kolmir_PotassiumIodate {
        displayName = CSTRING(PrussianBlue);
        descriptionShort = CSTRING(PrussianBlue_desc);
        descriptionUse = CSTRING(Administer_PrussianBlue);
        picture = QPATHTOF(ui\PrussianBlueIco.paa);
        count = 10;
    };
};
