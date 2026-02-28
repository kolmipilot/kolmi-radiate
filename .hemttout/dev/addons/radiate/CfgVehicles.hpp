class CfgVehicles {
    class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
            class KOLMIR_Actions {
                displayName = CSTRING(KOLMIR_Actions);
                icon = QPATHTOF(ui\kolmiRadiate_minimal_logo.paa);
                class KOLMIR_CheckSimpleDosimeterReading {
                    displayName = CSTRING(CheckSimpleDosimeter);
                    condition = QUOTE('kolmir_SimpleDosimeter' in (items _player));
                    exceptions[] = {"isNotSwimming"};
                    statement = QUOTE(_this call FUNC(checkSimpleDosimeter));
                    showDisabled = 0;
                    icon = QPATHTOF(ui\SimpleDosimeter.paa);
                };
            };
        };
    };

    class Logic;
    class Module_F: Logic
    {
        class AttributesBase {};
        class ModuleDescription;
    };
    class kolmir_module_radiation: Module_F
    {
        scope = 2;
        side=7;
        displayName = CSTRING(RadiationModule_Displayname);
        category = QGVAR(RADIATE);
        function = QFUNC(radiationModule);
        isTriggerActivated = 0;
        functionPriority = 1;
        isGlobal = 0;

        class Arguments: AttributesBase
        {
            class Radius
            {
                displayName = CSTRING(UI_max_range);
                tooltip = CSTRING(RadiationModule_max_radius_dcs);
                typeName = "NUMBER";
                defaultValue = 20;
            };
            class Radiation_Type
            {
                displayName = CSTRING(UI_radiationType);
                typeName = "NUMBER";
                class values {
                    class Alpha {
                        name = CSTRING(Lvl0_Radiation);
                        value = 0;
                    };
                    class Beta {
                        name = CSTRING(Lvl1_Radiation);
                        value = 1;
                        default = 1;
                    };
                    class Gamma {
                        name = CSTRING(Lvl2_Radiation);
                        value = 2;
                    };
                };
            };
        };

        class ModuleDescription: ModuleDescription {
            description = CSTRING(RadiationModule_description);
            sync[] = {"LocationArea_F"};

            class LocationArea_F {
                position = 0;
                optional = 0;
                duplicate = 1;
                synced[] = {"Anything"};
            };
        };
    };

    class kolmir_module_zeus_radiation: Module_F
    {
        scope = 1;
        scopeCurator = 2;
        side=7;
        curatorCanAttach = 1;
        displayName = CSTRING(RadiationModule_Displayname);
        category = QGVAR(RADIATE);
        function = QACEFUNC(common,dummy);
        curatorInfoType = QGVAR(kolmir_RscRadiationModul);
        isTriggerActivated = 0;
        functionPriority = 1;
        isGlobal = 0;
    };
    
    class Static;
    class GVAR(logic): Static {
        scope = 1;
        displayName = "";
    };
};
