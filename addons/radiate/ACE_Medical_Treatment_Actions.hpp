class ACE_Medical_Treatment_Actions {
    class Morphine;
    class CheckPulse;
    class EDTA: Morphine {
        displayName = CSTRING(Take_EDTA);
        displayNameProgress = CSTRING(Using_EDTA);
        allowedSelections[] = {"LeftArm", "RightArm", "LeftLeg", "RightLeg"};
        allowSelfTreatment = 1;
        treatmentTime = QGVAR(treatmentTime_EDTA);
        condition = "";
        items[] = {"kolmir_EdtaAutoInjector"};
        callbackSuccess = QFUNC(medication);
        sounds[] = {};
    };
    class CheckDosimeter: CheckPulse {
        displayName = CSTRING(CheckDosimeter_DisplayName);
        displayNameProgress = CSTRING(CheckDosimeter_DisplayNameProgress);
        allowedSelections[] = {"LeftArm", "RightArm"};
        treatmentTime = QGVAR(CheckDosimeter_TreatmentTime);
        category = "examine";
        consumeItem = 0;
        items[] = {};
        condition = QUOTE([_patient] call FUNC(hasDosimeter));
        callbackProgress = "";
        callbackStart = "";
        callbackFailure = "";
        callbackSuccess = QFUNC(CheckDosimeterMed);
        litter[] = {};
    };
    class CheckRadiation: CheckPulse {
        displayName = CSTRING(CheckRadiation_DisplayName);
        displayNameProgress = CSTRING(CheckRadiation_DisplayNameProgress);
        allowedSelections[] = {"LeftArm", "RightArm"};
        treatmentTime = QGVAR(CheckRadiation_TreatmentTime);
        category = "examine";
        consumeItem = 0;
        items[] = {"kolmir_BloodTester"};
        condition = "";
        callbackProgress = "";
        callbackStart = "";
        callbackFailure = "";
        callbackSuccess = QFUNC(CheckRadiation);
        litter[] = {};
    };
    class PrussianBlue: Morphine {
        displayName = CSTRING(Administer_PrussianBlue);
        displayNameProgress = CSTRING(Using_PrussianBlue);
        allowedSelections[] = {"Head"};
        allowSelfTreatment = 1;
        treatmentTime = 4;
        condition = "";
        items[] = {"kolmir_PrussianBlue"};
        callbackSuccess = QFUNC(medication);
        sounds[] = {};
    };
    class PotassiumIodate: Morphine {
        displayName = CSTRING(Administer_PotassiumIodate);
        displayNameProgress = CSTRING(Using_PotassiumIodate);
        allowedSelections[] = {"Head"};
        allowSelfTreatment = 1;
        treatmentTime = 4;
        condition = "";
        items[] = {"kolmir_PotassiumIodate"};
        callbackSuccess = QFUNC(medication);
        sounds[] = {};
    };
};
