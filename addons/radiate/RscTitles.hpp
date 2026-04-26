#define KOLMIR_CHEM_GRID_WAbs            (((safezoneW / safezoneH) min 0.7))
#define KOLMIR_CHEM_GRID_HAbs            ((((safezoneW / safezoneH) min 1.2) / 1.6))
#define KOLMIR_CHEM_GRID_W            ((((safeZoneW / safeZoneH) min 0.7) / 40))
#define KOLMIR_CHEM_GRID_H            (((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25))
#define KOLMIR_CHEM_GRID_X            ((safeZoneX + (safeZoneW - ((safeZoneW / safeZoneH) min 1.2)) / 11))
#define KOLMIR_CHEM_GRID_Y            ((safeZoneY + (safeZoneH - (((safeZoneW / safeZoneH) min 1.2) / 1.2)) / 0.8))

#define KOLMIR_CHEM_POS_H(N) ((N) * KOLMIR_CHEM_GRID_H)

#define ST_LEFT 0
#define ST_CENTER 2
#define ST_RIGHT 1

#define pixelW  (1 / (getResolution select 2))
#define pixelH  (1 / (getResolution select 3))
#define pixelScale  0.50

// pixel grids macros
#define UI_GRID_W (pixelW * pixelGridBase)
#define UI_GRID_H (pixelH * pixelGridBase)

#define SAFEZONE_X_RIGHTEDGE ((safeZoneX - 1) * -1)
#define SAFEZONE_Y_LOWEDGE ((safeZoneY - 1) * -1)

#define FRAME_W(N) ((UI_GRID_W * (N)) * (1.7777 / (getResolution select 4)))
#define FRAME_H(N) ((UI_GRID_H * (N)))

class RscTitles
{
    class kolmir_SimpleGeigerCounter
    {
        idd = 18835;
        enableSimulation = 1;
        movingEnable = 0;
        fadeIn=0;
        fadeOut=1;
        duration = 10e10;
        onLoad = "uiNamespace setVariable ['kolmir_SimpleGeigerCounter', _this select 0];";
        class controls
        {   
            class kolmirChemIcon: RscPicture
            {
                idc = 18801;
                text = "\z\kolmir\addons\radiate\UI\SimpleGeigerCounter.paa";
                x = QUOTE(SAFEZONE_X_RIGHTEDGE - FRAME_W(25) - FRAME_W(15));
                y = QUOTE(SAFEZONE_Y_LOWEDGE - FRAME_H(25));
                w = QUOTE(FRAME_W(25));
                h = QUOTE(FRAME_H(25));
            };
            class kolmirChemStrength: RscText
            {
                idc = 18805;
                style = ST_RIGHT;
                valign = "middle";
                shadow = 0;
                font = "PuristaBold";
                text = "0";
                x = QUOTE(SAFEZONE_X_RIGHTEDGE - FRAME_W(25) - FRAME_W(5.1));
                y = QUOTE(SAFEZONE_Y_LOWEDGE - FRAME_H(16.5));
                w = QUOTE(FRAME_W(5));
                h = QUOTE(FRAME_H(3));
                colorBackground[] = {0,0,0,0};
                colorText[] = {0.3,0.3,0.3,0.8};
                sizeEx = QUOTE(FRAME_H(2.2));
            };
        };
    };
};
