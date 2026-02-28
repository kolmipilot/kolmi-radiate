class RscControlsGroup;
class RscControlsGroupNoScrollbars;
class RscText;
class RscCombo;
class RscEdit;

class RscDisplayAttributes {
    class Controls {
        class Background;
        class Title;
        class Content: RscControlsGroup {};
        class ButtonOK;
        class ButtonCancel;
    };
};

class GVAR(kolmir_RscAtributeRadius): RscControlsGroupNoScrollbars {
    onSetFocus = QUOTE(_this call FUNC(AttributeRadius));
    idc = 26422;
    x = 0;
    y = 0;
    w = QUOTE(W_PART(26));
    h = QUOTE(H_PART(8));
    class controls {
        class Title1: RscText {
            idc = 16109;
            text = CSTRING(UI_max_range);
            toolTip = CSTRING(RadiationModule_max_radius_dcs);
            x = 0;
            y = 0;
            w = QUOTE(W_PART(10));
            h = QUOTE(H_PART(1));
            colorBackground[] = {0,0,0,0.5};
        };
        class radius_max: RscEdit {
            idc = 1611;
            x = QUOTE(W_PART(10.1));
            y = 0;
            w = QUOTE(W_PART(15.9));
            h = QUOTE(H_PART(1));
        };
        class Title5: Title1 {
            idc = -1;
            text = CSTRING(UI_selectRadiationType);
            toolTip = "";
            y = QUOTE(H_PART(4.8));
        };
        class radiationType: RscCombo {
            idc = 1617;
            x = QUOTE(W_PART(10.1));
            y = QUOTE(H_PART(4.8));
            w = QUOTE(W_PART(10));
            h = QUOTE(H_PART(1));
            colorBackground[] = {0, 0, 0, 0.7};
            class Items {
                class type0 {
                    text = CSTRING(Lvl0_Radiation);
                };
                class type1 {
                    text = CSTRING(Lvl1_Radiation);
                    default = 1;
                };
                class type2 {
                    text = CSTRING(Lvl2_Radiation);
                };
            };
        };
        class Title7: Title1 {
            idc = 1616;
            text = CSTRING(RadiationModule_createContaminatedZone);
            toolTip = "";
            y = QUOTE(H_PART(6));
            w = QUOTE(W_PART(25));
        };
        class Title6: Title1 {
            idc = -1;
            text = CSTRING(RadiationModule_placeModuleOnObject);
            toolTip = "";
            y = QUOTE(H_PART(7.1));
            w = QUOTE(W_PART(25));
        };
    };
};


class GVAR(kolmir_RscRadiationModul): RscDisplayAttributes {
    onLoad = QUOTE([ARR_3('onLoad',_this,QQGVAR(kolmir_RscRadiationModul))] call EFUNC(zeus,zeusAttributes));
    onUnload = QUOTE([ARR_3('onUnload',_this,QQGVAR(kolmir_RscRadiationModul))] call EFUNC(zeus,zeusAttributes));

    class Controls: Controls {
        class Background: Background {};
        class Title: Title {};
        class Content: Content {
            class Controls {
                class radius: GVAR(kolmir_RscAtributeRadius) {};
            };
        };
        class ButtonOK: ButtonOK {
            onButtonClick = QUOTE(_this call FUNC(radiationModuleZeus));
        };
        class ButtonCancel: ButtonCancel {};
    };
};
