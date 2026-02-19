// COMPONENT should be defined in the script_component.hpp and included BEFORE this hpp

#define MAINPREFIX z
#define PREFIX kolmir

#include "script_version.hpp"

#define VERSION     MAJOR.MINOR
#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR  MAJOR,MINOR,PATCHLVL,BUILD

#define KOLMI_RADIATE_TAG KOLMI_RADIATE

// MINIMAL required version for the Mod. Components can specify others..
#define REQUIRED_VERSION 2.02

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(kolmir - COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(kolmir - COMPONENT)
#endif
