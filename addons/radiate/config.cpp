#include "script_component.hpp"

class CfgPatches {
    class ADDON    {
        name = COMPONENT_NAME;
        requiredVersion = REQUIRED_VERSION;
        author = "kolmipilot";
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
        units[] = {
            "kolmir_module_radiation",
            "kolmir_module_zeus_radiation",
            "radiate_vodka_prop",
        };
        weapons[] = {
            "kolmir_SimpleDosimeter",
            "kolmir_SimpleGeigerCounter",
            "kolmir_EdtaAutoInjector",
            "kolmir_VodkaBottle",
            "kolmir_VodkaBottle_Half",
            "kolmir_VodkaBottle_Empty",
            "kolmir_BloodTester"

        };
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "ui\RscAttributes.hpp"
#include "RscTitles.hpp"
#include "CfgFactionClasses.hpp"
#include "CfgWeapons.hpp"
#include "CfgSounds.hpp"
#include "ACE_Medical_Treatment.hpp"
#include "ACE_Medical_Treatment_Actions.hpp"
#include "ACE_Medical_Injuries.hpp"
