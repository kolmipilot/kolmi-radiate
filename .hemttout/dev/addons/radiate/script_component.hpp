#define COMPONENT radiate
#define COMPONENT_BEAUTIFIED Radiate
#include "\z\kolmir\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_RADIATE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_RADIATE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_RADIATE
#endif

#include "\z\kolmir\addons\main\script_macros.hpp"

// UI grid
#define SIZEX ((safeZoneW / safeZoneH) min 1.2)
#define SIZEY (SIZEX / 1.2)
#define W_PART(num) (num * (SIZEX / 40))
#define H_PART(num) (num * (SIZEY / 25))
#define X_PART(num) (W_PART(num) + (safeZoneX + (safeZoneW - SIZEX) / 2))
#define Y_PART(num) (H_PART(num) + (safeZoneY + (safeZoneH - SIZEY) / 2))

#define RADIATION_MANAGER_PFH_DELAY 1
