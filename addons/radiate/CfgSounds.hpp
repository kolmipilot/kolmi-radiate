class CfgSounds {
    class GVAR(BaseGeiger) {
        name = QGVAR(BaseGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            3,
            0.7,
            10
        };
        titles[] = {};
    };
    class GVAR(SlowGeiger) {
        name = QGVAR(SlowGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            3,
            0.7,
            5
        };
        titles[] = {};
    };
    class GVAR(NormalGeiger) {
        name = QGVAR(NormalGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            8,
            0.9,
            5
        };
        titles[] = {};
    };
    class GVAR(FastGeiger) {
        name = QGVAR(FastGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            8,
            1.0,
            5
        };
        titles[] = {};
    };
    class GVAR(RapidGeiger) {
        name = QGVAR(RapidGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            8,
            1.1,
            5
        };
        titles[] = {};
    };
    class GVAR(CrazyGeiger) {
        name = QGVAR(CrazyGeiger);
        sound[] =
        {
            QPATHTOF(audio\geiger.ogg),
            8,
            1.2,
            5
        };
        titles[] = {};
    };
    class GVAR(Vomit) {
        name = QGVAR(Vomit);
        sound[] = {
            QPATHTOF(audio\vomit.ogg),
            15,
            1,
            5
        };
        titles[] = {};
    };
};
