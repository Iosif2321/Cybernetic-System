
#include "\a3\ui_f\hpp\defineDIKCodes.inc"

#define PHEN_CS_L(KEY) (localize KEY)

PHEN_CS_HasACEMedical = isClass (configFile >> "CfgPatches" >> "ace_medical");
PHEN_CS_HasKAT = isClass (configFile >> "CfgPatches" >> "kat_main");

/*
    CBA Settings
*/

//code

/*
    KEYBINDS
*/
[PHEN_CS_L("STR_PHEN_CS_CBA_CAT_HUD"), "CheckCyberneticsOther", [PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CHECK_OTHER"), PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CHECK_OTHER_TT")], {

    _player = missionnamespace getVariable ["bis_fnc_moduleremoteControl_unit", player];
    if (_player getVariable ["PHEN_CS_Keybind_KeyPressed", false]) exitWith {};
    if (!(isNull findDisplay 49) || !(isNull findDisplay 312) || visibleMap) exitWith {};

    _player setVariable ["PHEN_CS_Keybind_KeyPressed", true]; // Set cooldown at start

    _player spawn {
        uiSleep 0.1;
        _this setVariable ["PHEN_CS_Keybind_KeyPressed", false];
    };

    [cursorObject] spawn PHEN_CS_fnc_ShowOther; 
 
    
}, {}, [DIK_U, [false, true, false]]] call cba_fnc_addKeybind;

[PHEN_CS_L("STR_PHEN_CS_CBA_CAT_HUD"), "CheckCyberneticsSelf", [PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CHECK_SELF"), PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CHECK_SELF_TT")], {

    _player = missionnamespace getVariable ["bis_fnc_moduleremoteControl_unit", player];
    if (_player getVariable ["PHEN_CS_Keybind_KeyPressed", false]) exitWith {};
    if (!(isNull findDisplay 49) || !(isNull findDisplay 312) || visibleMap) exitWith {};    

    _player setVariable ["PHEN_CS_Keybind_KeyPressed", true]; // Set cooldown at start

    _player spawn {
        uiSleep 0.1;
        _this setVariable ["PHEN_CS_Keybind_KeyPressed", false];
    };

    [_player] spawn PHEN_CS_fnc_ShowSelf;

    
}, {}, [DIK_U, [false, false, false]]] call cba_fnc_addKeybind;

/*
    HUD Settings
*/

[
    "PHEN_CS_HUD_Texture",
    "EDITBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_HUD_IMAGE"), PHEN_CS_L("STR_PHEN_CS_CBA_HUD_IMAGE_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_HUD"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_VISUALS")],
    "PHEN_Cybernetics\Data\HUD_0_CA.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_HUD_Texture = _value;
    }
] call CBA_fnc_addSetting;

/*
    Stress / Overclock
*/

[
    "PHEN_CS_StressMax",
    "SLIDER",
    [PHEN_CS_L("STR_PHEN_CS_CBA_STRESS_MAX"), PHEN_CS_L("STR_PHEN_CS_CBA_STRESS_MAX_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_GENERAL"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_STRESS")],
    [0, 200, 99, 0],
    1,
    {
        params ["_value"];
        PHEN_CS_StressMax = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_OverclockKills",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_OVERCLOCK_KILLS"), PHEN_CS_L("STR_PHEN_CS_CBA_OVERCLOCK_KILLS_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_GENERAL"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_STRESS")],
    false,
    1,
    {
        params ["_value"];
        PHEN_CS_OverclockKills = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_TacHUD_ADS_Auto",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_TACHUD_ADS_AUTO"), PHEN_CS_L("STR_PHEN_CS_CBA_TACHUD_ADS_AUTO_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_TACHUD"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SETTINGS")],
    true,
    1,
    {
        params ["_value"];
        PHEN_CS_TacHUD_ADS_Auto = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_TacHUD_Sound",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_TACHUD_SOUND"), PHEN_CS_L("STR_PHEN_CS_CBA_TACHUD_SOUND_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_TACHUD"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SETTINGS")],
    true,
    1,
    {
        params ["_value"];
        PHEN_CS_TacHUD_Sound = _value;
    }
] call CBA_fnc_addSetting;

/*
    General
*/

[
    "PHEN_CS_SaveToProfile",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_SAVE_TO_PROFILE"), PHEN_CS_L("STR_PHEN_CS_CBA_SAVE_TO_PROFILE_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_GENERAL"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_DATA")],
    true,
    1,
    {
        params ["_value"];
        PHEN_CS_SaveToProfile = _value;
    }
] call CBA_fnc_addSetting;

/*
    Cyberware enhancements SETS
*/

// --- ARMS ---
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_1")],
    "Servo-Assisted Arms Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_1")],
    "PHEN_Cybernetics\Data\arms_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_1")],
    "Servo-Assisted Arms Mk.I: Basic servo-support framework. Slight strength and handling bonuses.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_1")],
    (str [["recoil", 0.03], ["meleeDamageIncrease", 0.05], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_ARMS_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_2")],
    "Servo-Assisted Arms Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_2")],
    "PHEN_Cybernetics\Data\arms_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_2")],
    "Servo-Assisted Arms Mk.II: Improved load-bearing support. Better recoil control and melee capability.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_2")],
    (str [["recoil", 0.05], ["meleeDamageIncrease", 0.08], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_ARMS_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_3")],
    "Servo-Assisted Arms Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_3")],
    "PHEN_Cybernetics\Data\arms_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_3")],
    "Servo-Assisted Arms Mk.III: High-output actuators and shock systems. Exceptional melee output.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_ARMS_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_ARMS_3")],
    (str [["recoil", 0.07], ["meleeDamageIncrease", 0.12], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- CIRCULATORY ---
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_1")],
    "Adrenal Optimizer Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_1")],
    "PHEN_Cybernetics\Data\circulatory_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_1")],
    "Adrenal Optimizer Mk.II: Regulates adrenaline bursts, providing a mild speed increase and restoring the default stamina scheme.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_1")],
    (str [["speed", 0.03], ["setStaminaScheme_Default", 1], ["stressPenalty", 1]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_2")],
    "Adrenal Optimizer Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_2")],
    "PHEN_Cybernetics\Data\circulatory_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_2")],
    "Adrenal Optimizer Mk.III: Enhanced oxygenation and metabolic efficiency. Better movement speed and a more forgiving stamina model.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_2")],
    (str [["speed", 0.05], ["setStaminaScheme_Normal", 1], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_3")],
    "BioMedica Haemostatic Sub-System",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_3")],
    "PHEN_Cybernetics\Data\circulatory_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_3")],
    "BioMedica Haemostatic Sub-System: Sub-dermal emergency medical implant. Automatically administers treatment when vitals reach critical thresholds.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_CIRCULATORY_3")],
    (str [["bioMedicaStim", true], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- FRONTAL CORTEX ---
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_1")],
    "[FC] Tactical Co-Processor Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_1")],
    "PHEN_Cybernetics\Data\frontalcortex_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_1")],
    "Tactical Co-Processor Mk.I: Basic combat AI assistance. Slightly improves reaction-based abilities and scan efficiency. Stacks with other co-processors.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_1")],
    (str [["abilityCooldown", 0.05], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_2")],
    "[FC] Tactical Co-Processor Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_2")],
    "PHEN_Cybernetics\Data\frontalcortex_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_2")],
    "Tactical Co-Processor Mk.II: Forecasting algorithms optimize combat pacing. Stronger cooldown and scan buffs. Stacks with other cortex upgrades.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_2")],
    (str [["abilityCooldown", 0.1], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_3")],
    "[FC] Tactical Co-Processor Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_3")],
    "PHEN_Cybernetics\Data\frontalcortex_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_3")],
    "Tactical Co-Processor Mk.III: Aggressive overclocking of higher brain functions. Excellent for ability spam; risky but powerful when stacked. At the cost of mild strain.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_FRONTAL_CORTEX_3")],
    (str [["abilityCooldown", 0.15], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- HANDS ---
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_1")],
    "Stabilized Grip Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_1")],
    "PHEN_Cybernetics\Data\hands_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_1")],
    "Stabilized Grip Mk.I: Mechanical grip control. Slight recoil reduction.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_1")],
    (str [["recoil", 0.08], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_HANDS_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_2")],
    "Stabilized Grip Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_2")],
    "PHEN_Cybernetics\Data\hands_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_2")],
    "Stabilized Grip Mk.II: Built-in gyros counteract weapon sway. Good recoil and handling bonuses.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_2")],
    (str [["recoil", 0.15], ["reloadSpeed", 0.35], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_HANDS_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_3")],
    "Stabilized Grip Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_3")],
    "PHEN_Cybernetics\Data\hands_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_3")],
    "Stabilized Grip Mk.III: Extreme stabilization for automatic weapons. Excellent recoil control, Faster reloads.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_HANDS_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_HANDS_3")],
    (str [["recoil", 0.25], ["reloadSpeed", 0.5], ["stressPenalty", 7]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- IMMUNE ---
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_1")],
    "Adaptive Nanite Weave Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_1")],
    "PHEN_Cybernetics\Data\immune_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_1")],
    "Adaptive Nanite Weave Mk.I: First-generation nanites that purge toxins and microbial threats. Offers mild resistance to poison and disease.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_1")],
    (str [["poisonResist", 0.25], ["diseaseResist", 0.25], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_2")],
    "Adaptive Nanite Weave Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_2")],
    "PHEN_Cybernetics\Data\immune_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_2")],
    "Adaptive Nanite Weave Mk.II: Enhanced nanite density enables near-instant filtration of airborne pathogens and chemicals. Provides solid radiation buffering.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_2")],
    (str [["poisonResist", 0.5], ["diseaseResist", 0.5], ["radResist", 0.25], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_3")],
    "Adaptive Nanite Weave Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_3")],
    "PHEN_Cybernetics\Data\immune_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_3")],
    "Adaptive Nanite Weave Mk.III: Third-generation self-replicating nanite mesh. Provides unmatched resistance across poison, disease, and radiation exposure. At the cost of mild strain",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_IMMUNE_3")],
    (str [["poisonResist", 0.75], ["diseaseResist", 0.75], ["radResist", 0.5], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- INTEGUMENTARY ---
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_1")],
    "Subdermal Weave Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_1")],
    "PHEN_Cybernetics\Data\integ_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_1")],
    "Subdermal Weave Mk.I: Basic dermal reinforcement. Slight all-round damage reduction.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_1")],
    (str [["damageResist", 0.08], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_2")],
    "Subdermal Weave Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_2")],
    "PHEN_Cybernetics\Data\integ_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_2")],
    "Subdermal Weave Mk.II: Reactive skin-layer armor that stiffens on impact. Greatly reduces ballistic trauma.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_2")],
    (str [["damageResist", 0.1], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_3")],
    "Subdermal Weave Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_3")],
    "PHEN_Cybernetics\Data\integ_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_3")],
    "Subdermal Weave Mk.III: Advanced adaptive dermal mesh. Improved damage reduction at the cost of mental strain.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTEGUMENTARY_3")],
    (str [["damageResist", 0.15], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- LEGS ---
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_1")],
    "Reinforced Joints Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_1")],
    "PHEN_Cybernetics\Data\legs_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_1")],
    "Reinforced Joints Mk.I: Baseline leg reinforcement. Slight move speed increase.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_1")],
    (str [["speed", 0.05], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_2")],
    "Sprint Assist Pistons Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_2")],
    "PHEN_Cybernetics\Data\legs_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_2")],
    "Sprint Assist Pistons: Pneumatic pistons in the legs. Strong sprint speed bonus and abillity to jump high. At the cost of mild stress.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_2")],
    (str [["speed", 0.08], ["Abillity_Jump", true], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_3")],
    "Reinforced Joints Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_3")],
    "PHEN_Cybernetics\Data\legs_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_3")],
    "Reinforced Joints Mk.II: Designed for high mobility and solid speed.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_3")],
    (str [["speed", 0.1], ["setStaminaScheme_FastDrain", 1], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_3_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_4")],
    "Sprint Assist Pistons Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_3_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_4")],
    "PHEN_Cybernetics\Data\legs_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_3_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_3_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_4")],
    "Sprint Assist Pistons: Pneumatic pistons in the legs. Strong sprint speed bonus and abillity to jump and 'air-dash'. At the cost of mild stress.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_3_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_4")],
    (str [["speed", 0.08], ["Abillity_Jump", true], ["Abillity_AirDash", true], ["stressPenalty", 7]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_4_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_5")],
    "Turbo-Frame Actuators Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_4_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_5")],
    "PHEN_Cybernetics\Data\legs_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_4_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_4_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_5")],
    "Turbo-Frame Actuators Mk.I: First-generation overclocked leg actuators. Grants explosive acceleration, grants abillity to dash upon your enemies. Delivers high mobility at the cost of increased neuromuscular stress.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_4_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_5")],
    (str [["speed", 0.08], ["Abillity_Dash", true], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_5_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_6")],
    "Turbo-Frame Actuators Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_5_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_6")],
    "PHEN_Cybernetics\Data\legs_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_5_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_5_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_6")],
    "Turbo-Frame Actuators Mk.II: Second-generation overclocked leg actuators. Grants explosive acceleration, grants abillity to dash upon your enemies. Delivers high mobility at the cost of greater neuromuscular stress.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_5_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_6")],
    (str [["speed", 0.1], ["Abillity_Dash", true], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_6_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_7")],
    "Ultimate Mobility Framework Mk.IV",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_6_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_7")],
    "PHEN_Cybernetics\Data\legs_3_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_6_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_6_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_7")],
    "Ultimate Mobility Framework Mk.IV: A high-end multi-actuator leg system tuned for extreme agility. Grants full movement abilities, dash, jump, and air-dash, with only a modest speed increase. Comes at the cost of significant neuromuscular stress.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_6_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_7")],
    (str [["speed", 0.03], ["Abillity_Dash", true], ["Abillity_Jump", true], ["Abillity_AirDash", true], ["stressPenalty", 20]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_LEGS_ITEM_7_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_8")],
    "Ultimate Mobility Framework Mk.V",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_7_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_8")],
    "PHEN_Cybernetics\Data\legs_4_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_7_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_7_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_8")],
    "Ultimate Mobility Framework Mk.V: The pinnacle of cybernetic locomotion. Reinforced exo-tendons enable extreme sprint velocity, enhanced vertical movement, and precise mid-air redirection. All advanced movement abilities included. High stress load expected.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_LEGS_ITEM_7_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_LEGS_8")],
    (str [["speed", 0.1], ["Abillity_Dash", true], ["Abillity_Jump", true], ["Abillity_AirDash", true], ["stressPenalty", 25]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- NERVOUS ---
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_1")],
    "Overstim Neural Chain Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_1")],
    "PHEN_Cybernetics\Data\nervous_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_1")],
    "Overstim Neural Chain Mk.I: Baseline nerve conduction improvement. Slight movement and reaction boost.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_1")],
    (str [["speed", 0.02], ["stressPenalty", 1]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_2")],
    "Overstim Neural Chain Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_2")],
    "PHEN_Cybernetics\Data\nervous_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_2")],
    "Overstim Neural Chain Mk.II: Enhanced nerve lattice for combat. Better movement and reflex performance.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_2")],
    (str [["speed", 0.04], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_3")],
    "Overstim Neural Chain Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_3")],
    "PHEN_Cybernetics\Data\nervous_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_3")],
    "Overstim Neural Chain Mk.III: Maxed-out nerve overdrive. High reflex and speed gain with heavy fatigue.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_NERVOUS_3")],
    (str [["speed", 0.06], ["setStaminaScheme_FastDrain", 1], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- OCULAR ---
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_1")],
    "Low-Light Optics Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_1")],
    "PHEN_Cybernetics\Data\ocular_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_1")],
    "Low-Light Optics Mk.I: Enhanced low-light sensitivity. Grants basic night vision for nocturnal operations.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_1")],
    (str [["nightVision", 1], ["stressPenalty", 1]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_2")],
    "Low-Light Optics Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_2")],
    "PHEN_Cybernetics\Data\ocular_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_2")],
    "Low-Light Optics Mk.II: Upgraded sensor suite with thermal imaging, ideal for tracking heat signatures through smoke and foliage.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_2")],
    (str [["thermalVision", 1], ["tacHUD", true], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_3")],
    "Low-Light Optics Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_3")],
    "PHEN_Cybernetics\Data\ocular_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_3")],
    "Low-Light Optics Mk.III: Fully integrated multi-spectrum optics, combining night vision and thermal overlays for maximum target acquisition. At the cost of mild strain.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OCULAR_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OCULAR_3")],
    (str [["nightANDThermalVision", 1], ["tacHUD", true], ["stressPenalty", 7]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- OPERATING SYSTEM ---
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_1")],
    "Tactical OS Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_1")],
    "PHEN_Cybernetics\Data\os_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_1")],
    "Tactical OS Mk.I: Standard-issue combat operating system. Slightly improves all cybernetic efficiency.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_1")],
    (str [["abilityCooldown", 0.05], ["stressPenalty", 1]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_2")],
    "Tactical OS Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_2")],
    "PHEN_Cybernetics\Data\os_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_2")],
    "Tactical OS Mk.II: Optimized for multi-cyberware setups. Increases system capacity and efficiency.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_2")],
    (str [["abilityCooldown", 0.1], ["stressPenalty", 5]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_3")],
    "Tactical OS Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_3")],
    "PHEN_Cybernetics\Data\os_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_3")],
    "Tactical OS Mk.III: Illegal Black-ICE variant with aggressive overclocking. Strong combat boosts with increased mental strain.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_OPERATING_SYSTEM_3")],
    (str [["abilityCooldown", 0.2], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

// --- SKELETON ---
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_0_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_1")],
    "Reinforced Bone Plating Mk.I",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_0_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_1")],
    "PHEN_Cybernetics\Data\skeleton_0_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_0_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_1")],
    "Reinforced Bone Plating Mk.I: Simple structural reinforcement. Modest damage reduction.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_0_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_1")],
    (str [["damageResist", 0.03], ["stressPenalty", 1]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_1_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_2")],
    "Reinforced Bone Plating Mk.II",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_1_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_2")],
    "PHEN_Cybernetics\Data\skeleton_1_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_1_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_2")],
    "Reinforced Bone Plating Mk.II: Load-bearing spine and joint reinforcement. Better capacity and shock absorption.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_1_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_2")],
    (str [["damageResist", 0.05], ["stressPenalty", 3]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_2_Name",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_NAME"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_3")],
    "Reinforced Bone Plating Mk.III",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Name = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_2_PicturePath",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_PICTURE_PATH"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_3")],
    "PHEN_Cybernetics\Data\skeleton_2_ca.paa",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_PicturePath = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_2_Tooltip",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_TOOLTIP"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_3")],
    "Reinforced Bone Plating Mk.III: Full skeletal reinforcement tuned for frontline units. Exceptional durability with a mild stress burden.",
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Tooltip = _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;
[
    "PHEN_CS_Cybernetic_SKELETON_ITEM_2_Effects",
    "EDITBOX",
    PHEN_CS_L("STR_PHEN_CS_CBA_FIELD_EFFECTS_ARRAY"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_CYBERWARE"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_SKELETON_3")],
    (str [["damageResist", 0.1], ["stressPenalty", 10]]),
    1,
    {
        params ["_value"];
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Effects = parseSimpleArray _value;
        call PHEN_CS_fnc_GenerateMasterList; // generate/updates master list
    }
] call CBA_fnc_addSetting;

call PHEN_CS_fnc_GenerateMasterList; //generates master list from all above items

[ 
    "PHEN_CS_DashPower", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_DASH_POWER"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_POWER")],
    [0,100,50,0],
    1,
    {   
        params ["_value"];  
		PHEN_CS_DashPower = _value;
    }
] call CBA_fnc_addSetting;

[ 
    "PHEN_CS_AirDashPower", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_AIRDASH_POWER"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_POWER")],
    [0,100,75,0],
    1,
    {   
        params ["_value"];  
		PHEN_CS_AirDashPower = _value;
    }
] call CBA_fnc_addSetting;

[ 
    "PHEN_CS_JumpPower", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_JUMP_POWER"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_POWER")],
    [0,100,50,0],
    1,
    {   
        params ["_value"];  
		PHEN_CS_JumpPower = _value;
    }
] call CBA_fnc_addSetting;

// --- COOLDOWN SETTINGS ---

[ 
    "PHEN_CS_JumpCooldown", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_JUMP_COOLDOWN"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_COOLDOWNS")],
    [0,60,5,0],                 // min, max, default, decimals
    1,
    {   
        params ["_value"];  
        PHEN_CS_JumpCooldown = _value;
    }
] call CBA_fnc_addSetting;

[ 
    "PHEN_CS_DashCooldown", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_DASH_COOLDOWN"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_COOLDOWNS")],
    [0,60,3,0],
    1,
    {   
        params ["_value"];  
        PHEN_CS_DashCooldown = _value;
    }
] call CBA_fnc_addSetting;

[ 
    "PHEN_CS_AirDashCooldown", 
    "SLIDER", 
    PHEN_CS_L("STR_PHEN_CS_CBA_AIRDASH_COOLDOWN"),
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_MOVEMENT"),PHEN_CS_L("STR_PHEN_CS_CBA_SUB_COOLDOWNS")],
    [0,60,5,0],
    1,
    {   
        params ["_value"];  
        PHEN_CS_AirDashCooldown = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_EnableBaseActions",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_ENABLE_BASE_ACTIONS"), PHEN_CS_L("STR_PHEN_CS_CBA_ENABLE_BASE_ACTIONS_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_RIPPERDOC"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTERACTION")],
    true,
    1,
    {
        params ["_value"];
        PHEN_CS_EnableBaseActions = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_EnableACEActions",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_ENABLE_ACE_ACTIONS"), PHEN_CS_L("STR_PHEN_CS_CBA_ENABLE_ACE_ACTIONS_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_RIPPERDOC"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTERACTION")],
    true,
    1,
    {
        params ["_value"];
        PHEN_CS_EnableACEActions = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_EnableRipperdocQTE",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_RIPPERDOC_QTE"), PHEN_CS_L("STR_PHEN_CS_CBA_RIPPERDOC_QTE_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_RIPPERDOC"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTERACTION")],
    true,   // default
    1
] call CBA_fnc_addSetting;

[
    "PHEN_CS_RipperdocQTE_TimeLimit",
    "SLIDER",
    [PHEN_CS_L("STR_PHEN_CS_CBA_QTE_TIME_LIMIT"), PHEN_CS_L("STR_PHEN_CS_CBA_QTE_TIME_LIMIT_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_RIPPERDOC"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTERACTION")],
    [3, 20, 8, 0],
    1
] call CBA_fnc_addSetting;

[
    "PHEN_CS_RipperdocQTE_MaxResets",
    "SLIDER",
    [PHEN_CS_L("STR_PHEN_CS_CBA_QTE_MAX_MISTAKES"), PHEN_CS_L("STR_PHEN_CS_CBA_QTE_MAX_MISTAKES_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_RIPPERDOC"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_INTERACTION")],
    [0, 10, 3, 0],
    1
] call CBA_fnc_addSetting;

/////////////////////////////
// BioMedica Implant Settings //
/////////////////////////////
[
    "PHEN_CS_BioMedicaStim_Cooldown",
    "SLIDER",
    [PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_COOLDOWN"), PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_COOLDOWN_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
    [1, 1800, 180, 0],
    true,
    {
        params ["_value"];
        PHEN_CS_BioMedicaStim_Cooldown = _value;
    }
] call CBA_fnc_addSetting;

[
    "PHEN_CS_BioMedicaStim_Threshold",
    "SLIDER",
    [PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_THRESHOLD"), PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_THRESHOLD_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
    [0, 0.99, 0.5, 2],
    true,
    {
        params ["_value"];
        PHEN_CS_BioMedicaStim_Threshold = _value;
    }
] call CBA_fnc_addSetting;

if (PHEN_CS_HasACEMedical) then {

    [
        "PHEN_CS_BioMedicaStim_ActivationDelay",
        "SLIDER",
        [PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_ACTIVATION_DELAY"), PHEN_CS_L("STR_PHEN_CS_CBA_BIOMED_ACTIVATION_DELAY_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        [1, 30, 5, 0],
        true,
        {
            params ["_value"];
            PHEN_CS_BioMedicaStim_ActivationDelay = _value;
        }
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Bandage",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_BANDAGE"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Stitch",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_STITCH"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Fractures",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_FRACTURES"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Blood",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_BLOOD"), PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_BLOOD_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_BloodBagSize",
        "LIST",
        [PHEN_CS_L("STR_PHEN_CS_CBA_BLOOD_BAG_SIZE"), PHEN_CS_L("STR_PHEN_CS_CBA_BLOOD_BAG_SIZE_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        [[250, 500, 1000], ["250 ml", "500 ml", "1000 ml"], 2],
        true,
        {
            params ["_value"];
            PHEN_CS_BioMedicaStim_BloodBagSize = _value;
        }
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_BloodCount",
        "SLIDER",
        [PHEN_CS_L("STR_PHEN_CS_CBA_BLOOD_BAG_COUNT"), PHEN_CS_L("STR_PHEN_CS_CBA_BLOOD_BAG_COUNT_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        [1, 5, 1, 0],
        true,
        {
            params ["_value"];
            PHEN_CS_BioMedicaStim_BloodCount = _value;
        }
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_WakeUnconscious",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_WAKE"), PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_WAKE_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    if (PHEN_CS_HasKAT) then {
        [
            "PHEN_CS_BioMedicaStim_TOGGLE_TXA",
            "CHECKBOX",
            [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_TXA"), ""],
            [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
            true,
            true,
            {}
        ] call CBA_fnc_addSetting;

        [
            "PHEN_CS_BioMedicaStim_TOGGLE_EACA",
            "CHECKBOX",
            [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_EACA"), ""],
            [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
            true,
            true,
            {}
        ] call CBA_fnc_addSetting;

        [
            "PHEN_CS_BioMedicaStim_TOGGLE_Atropine",
            "CHECKBOX",
            [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_ATROPINE"), ""],
            [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
            false,
            true,
            {}
        ] call CBA_fnc_addSetting;
    } else {
        PHEN_CS_BioMedicaStim_TOGGLE_TXA = false;
        PHEN_CS_BioMedicaStim_TOGGLE_EACA = false;
        PHEN_CS_BioMedicaStim_TOGGLE_Atropine = false;
    };

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Epinephrine",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_EPINEPHRINE"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        true,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Morphine",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_MORPHINE"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        false,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_Adenosine",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_ADENOSINE"), ""],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        false,
        true,
        {}
    ] call CBA_fnc_addSetting;

    [
        "PHEN_CS_BioMedicaStim_TOGGLE_FullHeal",
        "CHECKBOX",
        [PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_FULL_HEAL"), PHEN_CS_L("STR_PHEN_CS_CBA_TOGGLE_FULL_HEAL_TT")],
        [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_BIOMEDICA"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_BIOMEDICA_SETTINGS")],
        false,
        true,
        {
            params ["_value"];
            PHEN_CS_BioMedicaStim_TOGGLE_FullHeal = _value;
        }
    ] call CBA_fnc_addSetting;

} else {
    PHEN_CS_BioMedicaStim_ActivationDelay = 5;
    PHEN_CS_BioMedicaStim_TOGGLE_Bandage = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Stitch = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Fractures = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Blood = false;
    PHEN_CS_BioMedicaStim_BloodBagSize = 1000;
    PHEN_CS_BioMedicaStim_BloodCount = 1;
    PHEN_CS_BioMedicaStim_TOGGLE_WakeUnconscious = false;
    PHEN_CS_BioMedicaStim_TOGGLE_TXA = false;
    PHEN_CS_BioMedicaStim_TOGGLE_EACA = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Atropine = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Epinephrine = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Morphine = false;
    PHEN_CS_BioMedicaStim_TOGGLE_Adenosine = false;
    PHEN_CS_BioMedicaStim_TOGGLE_FullHeal = false;
};

/*
    Unit Class Blacklist
*/

[
    "PHEN_CS_UnitClassBlacklist",
    "EDITBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_UNIT_CLASS_BLACKLIST"), PHEN_CS_L("STR_PHEN_CS_CBA_UNIT_CLASS_BLACKLIST_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_GENERAL"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_COMPATIBILITY")],
    "[""VirtualMan_F"", ""HeadlessClient_F""]",
    1,
    {
        params ["_value"];
        PHEN_CS_UnitClassBlacklist = parseSimpleArray _value;
    }
] call CBA_fnc_addSetting;

//DEBUG MODE
[
    "PHEN_CS_DebugMode",
    "CHECKBOX",
    [PHEN_CS_L("STR_PHEN_CS_CBA_DEBUG_MODE"), PHEN_CS_L("STR_PHEN_CS_CBA_DEBUG_MODE_TT")],
    [PHEN_CS_L("STR_PHEN_CS_CBA_CAT_DEBUG"), PHEN_CS_L("STR_PHEN_CS_CBA_SUB_DEBUG")],
    false,
    true,
    {}
] call CBA_fnc_addSetting;
