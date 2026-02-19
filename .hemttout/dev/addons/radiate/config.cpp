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
            "kolmir_module_zeus_radiation"
         };
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "ui\RscAttributes.hpp"
