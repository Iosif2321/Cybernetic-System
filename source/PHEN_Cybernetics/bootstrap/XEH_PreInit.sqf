#define PHEN_CS_L(KEY) (localize KEY)
#define PHEN_CS_KEYBIND_CAT_MOVEMENT "[FOD] Cybernetics System - Movement"
#define PHEN_CS_KEYBIND_CAT_TACHUD "[FOD] Cybernetics System - Tactical HUD"

/*
EXAMPLE OF *FULL* DATA ARRAY STRUCTURE:
PHEN_CS_CyberneticsSaveData = [

    // - Frontal Cortex -
    [
        ITEM_X, // 0100 - FC_0
        ITEM_X, // 0101 - FC_1
        ITEM_X  // 0102 - FC_2
    ],

    // - Ocular System -
    [
        ITEM_X // 0200 - OS_0
    ],

    // - Circulatory System -
    [
        ITEM_X, // 0300 - CS_0
        ITEM_X, // 0301 - CS_1
        ITEM_X  // 0302 - CS_2
    ],

    // - Immune System -
    [
        ITEM_X, // 0400 - IS_0
        ITEM_X  // 0401 - IS_1
    ],

    // - Nervous System -
    [
        ITEM_X, // 0500 - NS_0
        ITEM_X  // 0501 - NS_1
    ],

    // - Integumentary System (Skin/Body Surface) -
    [
        ITEM_X, // 0600 - ITS_0
        ITEM_X, // 0601 - ITS_1
        ITEM_X  // 0602 - ITS_2
    ],

    // - Operating System Layer (Cyber Framework) -
    [
        ITEM_X // 0700 - OPS_0
    ],

    // - Skeleton Reinforcement -
    [
        ITEM_X, // 0800 - SK_0
        ITEM_X  // 0801 - SK_1
    ],

    // - Limb Prosthetic Slots -
    [
        ITEM_X, // 0900 - H_0
        ITEM_X, // 1000 - A_0
        ITEM_X  // 1100 - L_0
    ]
];

EXAMPLE OF EMPTY DATA ARRAY (NO CYBERNETICS INSTALLED):
PHEN_CS_CyberneticsSaveData = [

    // - Frontal Cortex - 3 slots
    [
        [], // 0100 - FC_0
        [], // 0101 - FC_1
        []  // 0102 - FC_2
    ],

    // - Ocular System - 1 slot
    [
        [] // 0200 - OS_0
    ],

    // - Circulatory System - 3 slots
    [
        [], // 0300 - CS_0
        [], // 0301 - CS_1
        []  // 0302 - CS_2
    ],

    // - Immune System - 2 slots
    [
        [], // 0400 - IS_0
        []  // 0401 - IS_1
    ],

    // - Nervous System - 2 slots
    [ 
        [], // 0500 - NS_0
        []  // 0501 - NS_1
    ],

    // - Integumentary System (Skin/Body Surface) - 3 slots
    [
        [], // 0600 - ITS_0
        [], // 0601 - ITS_1
        []  // 0602 - ITS_2
    ],

    // - Operating System Layer (Cyber Framework) - 1 slot
    [
        [] // 0700 - OPS_0
    ],

    // - Skeleton Reinforcement - 2 slots
    [
        [], // 0800 - SK_0
        []  // 0801 - SK_1
    ],

    // - Limb Prosthetic Slots - 3 slots
    [
        [], // 0900 - H_0
        [], // 1000 - A_0
        []  // 1100 - L_0
    ]
];

*/

PHEN_CS_HasACEMedical = isClass (configFile >> "CfgPatches" >> "ace_medical");
PHEN_CS_HasKAT = isClass (configFile >> "CfgPatches" >> "kat_main");

// Save player's current Cybernetics to profileNamespace for persistence
//Player variable will always be leading!
PHEN_CS_fnc_saveCyberneticsData = {

    private _PHEN_CS_CyberneticsSaveData = [];

    if (!isNil {missionNamespace getVariable 'PHEN_CS_CyberneticsSaveData'}) then {
        _PHEN_CS_CyberneticsSaveData = PHEN_CS_CyberneticsSaveData;
        PHEN_CS_CyberneticsSaveData = _PHEN_CS_CyberneticsSaveData;
    };

    // Use the player variable if it exists (lead)
    if (!isNil {player getVariable 'My_CS_CyberneticsSaveData'}) then {
        _PHEN_CS_CyberneticsSaveData = player getVariable 'My_CS_CyberneticsSaveData';
        _PHEN_CS_CyberneticsSaveData = [_PHEN_CS_CyberneticsSaveData] call PHEN_CS_fnc_SetCyberneticsData; //sort and return
    };

    // Save to profileNamespace (only if toggle is enabled)
    if (PHEN_CS_SaveToProfile) then {
        profileNamespace setVariable ["PHEN_CS_CyberneticsSaveData", _PHEN_CS_CyberneticsSaveData];
        saveProfileNamespace;
    };

    // systemChat 'PHEN_CS_fnc_saveCyberneticsData | SAVED';
};

// Load Cybernetics, player variable leads
PHEN_CS_fnc_loadCyberneticsData = {

    private _PHEN_CS_CyberneticsSaveData = [];

    if (!isNil {missionNamespace getVariable 'PHEN_CS_CyberneticsSaveData'}) then {
        _PHEN_CS_CyberneticsSaveData = PHEN_CS_CyberneticsSaveData;
    };

    // Prefer the player variable first
    if (!isNil {player getVariable 'My_CS_CyberneticsSaveData'}) then {
        _PHEN_CS_CyberneticsSaveData = player getVariable 'My_CS_CyberneticsSaveData';
    } else {
        // fallback to profileNamespace if no player data exists (only if toggle is enabled)
        if (PHEN_CS_SaveToProfile) then {
            _PHEN_CS_CyberneticsSaveData = profileNamespace getVariable ["PHEN_CS_CyberneticsSaveData", []];
        };
    };

    _PHEN_CS_CyberneticsSaveData = [_PHEN_CS_CyberneticsSaveData] call PHEN_CS_fnc_SetCyberneticsData;

    // systemChat 'PHEN_CS_fnc_loadCyberneticsData | LOADED';
    _PHEN_CS_CyberneticsSaveData
};

// Set Cybernetics data, player variable has lead
PHEN_CS_fnc_SetCyberneticsData = {
    params [["_PHEN_CS_CyberneticsSaveData", []]];

    // Update player variable and global variable
    player setVariable ['My_CS_CyberneticsSaveData', _PHEN_CS_CyberneticsSaveData, true];
    PHEN_CS_CyberneticsSaveData = _PHEN_CS_CyberneticsSaveData;

    PHEN_CS_CyberneticsSaveData
};

// [] call PHEN_CS_fnc_saveCyberneticsData;
// [] call PHEN_CS_fnc_loadCyberneticsData;

// Creates a dedicated #particlesource emitter attached to _object and plays a 3D sound on it.
// Each call gets its own emitter so multiple sounds never block each other on the same object.
// params [object, soundClass, distance, duration]  duration = seconds before emitter cleanup
PHEN_CS_fnc_Say3D = {
    params [["_object", objNull], ["_soundClass", ""], ["_distance", 100], ["_duration", 10]];
    if (isNull _object) exitWith {};
    if (_soundClass isEqualTo "") exitWith {};
    private _emitter = "#particlesource" createVehicle (getPosASL _object);
    _emitter attachTo [_object, [0,0,0]];
    [_emitter, _soundClass, _distance] call CBA_fnc_GlobalSay3d;
    [_emitter, _duration] spawn {
        params ["_emitter", "_duration"];
        uiSleep _duration;
        deleteVehicle _emitter;
    };

    _emitter
};

PHEN_CS_fnc_registerCyberneticsEventHandlers = {
    // All EHs are here
	
    // Save on mission end
	addMissionEventHandler ["Ended", {
		[] call PHEN_CS_fnc_saveCyberneticsData;
	}];

	// Save when player disconnects (if local!)
	if (!isDedicated) then {
		addMissionEventHandler ["HandleDisconnect", {
			[] call PHEN_CS_fnc_saveCyberneticsData;
			false // continue default handling
		}];
	};

	// Save periodically (fallback safety timer, every 5 min)
	[] spawn {
		while {true} do {
			sleep 300;
			[] call PHEN_CS_fnc_saveCyberneticsData;
		};
	};

	// Save when exiting to lobby (useful in MP)
	addMissionEventHandler ["HandleDisconnect", {
		[] call PHEN_CS_fnc_saveCyberneticsData;
		false;
	}];

	// Save on player respawn (makes sense?)
	addMissionEventHandler ["EntityRespawned", {
		params ["_newEntity", "_oldEntity"];
		if (_newEntity isEqualTo player) then {
			[] call PHEN_CS_fnc_saveCyberneticsData;
			call PHEN_CS_fnc_registerBioMedicaEHs;
		};
	}];

	player addEventHandler ["InventoryOpened", {
		[] call PHEN_CS_fnc_saveCyberneticsData;
	}];

	player addEventHandler ["WeaponAssembled", {
		[] call PHEN_CS_fnc_saveCyberneticsData;
	}];

};

/*
    Cybernetics System Dialog - IDC Reference

    Background and header
   ------------------
    000  - BG              - Fullscreen dark background overlay.
    001  - BG_Image        - Main HUD_0.png image background.
    002  - PlayerName      - "USER#: <player name>" text at top center.

    Left side - Frontal Cortex row
   ---------------------------
    0100 - FC_0            - Frontal Cortex slot 1 (leftmost top-left square).
    0101 - FC_1            - Frontal Cortex slot 2 (middle top-left square).
    0102 - FC_2            - Frontal Cortex slot 3 (right top-left square).

    Center-left - Ocular System
   ------------------------
    0200 - OS_0            - Ocular System slot 1 (single square below frontal cortex row).

    Left mid - Circulatory System
   ---------------------------
    0300 - CS_0            - Circulatory System slot 1 (left square).
    0301 - CS_1            - Circulatory System slot 2 (center square).
    0302 - CS_2            - Circulatory System slot 3 (right square).

    Left lower-mid - Immune System
   ---------------------------
    0400 - IS_0            - Immune System slot 1 (left square).
    0401 - IS_1            - Immune System slot 2 (right square).

    Left lower - Nervous System
   ------------------------
    0500 - NS_0            - Nervous System slot 1 (left square).
    0501 - NS_1            - Nervous System slot 2 (right square).

    Left bottom - Integumentary System
   -------------------------------
    0600 - ITS_0           - Integumentary System slot 1 (left bottom-left square).
    0601 - ITS_1           - Integumentary System slot 2 (middle bottom-left square).
    0602 - ITS_2           - Integumentary System slot 3 (right bottom-left square).

    Right upper - Operating System
   ---------------------------
    0700 - OPS_0           - Operating System slot 1 (single upper-right square).

    Right mid - Skeleton
   -----------------
    0800 - SK_0            - Skeleton slot 1 (left skeleton square).
    0801 - SK_1            - Skeleton slot 2 (right skeleton square).

    Right lower-mid - Hands / Arms
   ---------------------------
    0900 - H_0             - Hands slot 1.
    1000 - A_0             - Arms slot 1.

    Right bottom - Legs
   ----------------
    1100 - L_0             - Legs slot 1.
*/

// Cybernetics System Dialog IDC defines

#define IDC_CYB_BG              000
#define IDC_CYB_BG_IMAGE        001
#define IDC_CYB_PLAYERNAME      002

// Frontal Cortex
#define IDC_CYB_FC_0            0100
#define IDC_CYB_FC_1            0101
#define IDC_CYB_FC_2            0102

// Ocular System (left-center single slot)
#define IDC_CYB_OS_0            0200

// Circulatory System
#define IDC_CYB_CS_0            0300
#define IDC_CYB_CS_1            0301
#define IDC_CYB_CS_2            0302

// Immune System
#define IDC_CYB_IS_0            0400
#define IDC_CYB_IS_1            0401

// Nervous System
#define IDC_CYB_NS_0            0500
#define IDC_CYB_NS_1            0501

// Integumentary System
#define IDC_CYB_ITS_0           0600
#define IDC_CYB_ITS_1           0601
#define IDC_CYB_ITS_2           0602

// Operating System (right side)
#define IDC_CYB_OPS_0           0700

// Skeleton
#define IDC_CYB_SK_0            0800
#define IDC_CYB_SK_1            0801

// Hands
#define IDC_CYB_H_0             0900

// Arms
#define IDC_CYB_A_0             1000

// Legs
#define IDC_CYB_L_0             1100

PHEN_CYBERWARE_MAP = [
    0100,0101,0102, // frontal cortex
    0200,           // ocular
    0300,0301,0302, // circulatory
    0400,0401,      // immune
    0500,0501,      // nervous
    0600,0601,0602, // skin/integrity
    0700,           // OS
    0800,0801,      // skeleton
    0900,1000,1100  // hands, arms, legs
]; //just for ref

// Category index per item
// 0 Frontal, 1 Ocular, 2 Circulatory, 3 Immune, 4 Nervous,
// 5 Integumentary, 6 OS, 7 Skeleton, 8 Hands, 9 Arms, 10 Legs
PHEN_CS_Cybernetic_ItemCategoryMap = [
    // FRONTAL CORTEX (3)
    0,0,0,
    // OCULAR (3)
    1,1,1,
    // CIRCULATORY (3)
    2,2,2,
    // IMMUNE (3)
    3,3,3,
    // NERVOUS (3)
    4,4,4,
    // INTEGUMENTARY (3)
    5,5,5,
    // OPERATING SYSTEM (3)
    6,6,6,
    // SKELETON (3)
    7,7,7,
    // HANDS (3)
    8,8,8,
    // ARMS (3)
    9,9,9,
    // LEGS (8 total)
    10,10,10, 10,10,10, 10,10
];



PHEN_CS_fnc_getOrInitCyberData = {
    params ["_unit"];

    private _data = _unit getVariable ["My_CS_CyberneticsSaveData", []];

    if (
        !(_data isEqualType [])
        || _data isEqualTo []
        || {count _data != 11}
    ) then {
        _data = [
            // 0 Frontal Cortex (3 slots)
            [[], [], []],

            // 1 Ocular System (1 slot)
            [[]],

            // 2 Circulatory System (3 slots)
            [[], [], []],

            // 3 Immune System (2 slots)
            [[], []],

            // 4 Nervous System (2 slots)
            [[], []],

            // 5 Integumentary System (3 slots)
            [[], [], []],

            // 6 Operating System (1 slot)
            [[]],

            // 7 Skeleton (2 slots)
            [[], []],

            // 8 Hands (1 slot)
            [[]],

            // 9 Arms (1 slot)
            [[]],

            // 10 Legs (1 slot)
            [[]]
        ];
    } else {
        // compact each category: filled slots to front, empties to back
        // handles legacy saves that may have gaps from pre-compaction removals
        {
            private _catIndex = _forEachIndex;
            private _filled = _x select { !(_x isEqualTo []) };
            private _empties = _x select { _x isEqualTo [] };
            _data set [_catIndex, _filled + _empties];
        } forEach _data;
    };

    _data
};



PHEN_CS_fnc_getItemCategoryIndex = {
    params ["_item"];

    private _items = PHEN_CS_Cybernetic_Items;          // must be: PHEN_CS_Cybernetic_MasterList # 0
    private _idx = -1;

    {
        if (_x isEqualTo _item) exitWith {_idx = _forEachIndex};
    } forEach _items;

    if (_idx < 0) exitWith {-1};                        // not found

    private _map = PHEN_CS_Cybernetic_ItemCategoryMap;
    if (_idx >= count _map) exitWith {-1};              // out of range, also fail safe

    _map # _idx                                         // always scalar
};


PHEN_CS_fnc_installCybernetic = {
    params ["_unit", "_item"];

    if (isNull _unit) exitWith {0};

    if ([_unit] call PHEN_CS_fnc_isUnitExcluded) exitWith {6};

    private _data = [_unit] call PHEN_CS_fnc_getOrInitCyberData;
    if !(_data isEqualType []) exitWith {1};

    private _catIndex = [_item] call PHEN_CS_fnc_getItemCategoryIndex;

    // must be a scalar int and within bounds
    if !(_catIndex isEqualType 0) exitWith {2};

    // systemChat format ["Category Index: %1", _catIndex];

    if (_catIndex < 0 || {_catIndex >= count _data}) exitWith {3};

    private _cat = _data # _catIndex;
    if !(_cat isEqualType []) exitWith {4};

    private _installed = false;

    for "_i" from 0 to (count _cat - 1) do {
        if ((_cat # _i) isEqualTo []) then {
            _cat set [_i, _item];
            _installed = true;
            break;
        };
    };

    if (!_installed) exitWith {5};   // no free slot in that category

    _data set [_catIndex, _cat];
    _unit setVariable ["My_CS_CyberneticsSaveData", _data, true];

    if (_unit isEqualTo player) then {
        PHEN_CS_CyberneticsSaveData = _data;
        [] call PHEN_CS_fnc_saveCyberneticsData;
        [] call PHEN_CS_fnc_loadCyberneticsData;
    };

    true
};

PHEN_CS_fnc_removeCybernetic = {
    params ["_unit", "_item"];

    private _data = [_unit] call PHEN_CS_fnc_getOrInitCyberData;
    private _removed = false;

    {
        private _catIndex = _forEachIndex;
        private _cat = _x;

        for "_i" from 0 to (count _cat - 1) do {
            if ((_cat # _i) isEqualTo _item) then {
                _cat set [_i, []];
                private _filled = _cat select { !(_x isEqualTo []) };
                private _empties = _cat select { _x isEqualTo [] };
                _cat = _filled + _empties;
                _data set [_catIndex, _cat];
                _removed = true;
                break;
            };
        };

        if (_removed) exitWith {};
    } forEach _data;

    if (!_removed) exitWith {false};

    _unit setVariable ["My_CS_CyberneticsSaveData", _data, true];

    if (_unit isEqualTo player) then {
        PHEN_CS_CyberneticsSaveData = _data;
        [] call PHEN_CS_fnc_saveCyberneticsData;
        [] call PHEN_CS_fnc_loadCyberneticsData;
    };

    true
};

// _unit is optional, defaults to player
PHEN_CS_fnc_LoadList = {

    params ["_unit"];

    // Ensure we use an actual unit, not a UI control
    if (isNil "_unit" || {!(_unit isKindOf "CAManBase")}) then {
        _unit = player;
    };

    // reload from profile / global (ensurancee)
    [] call PHEN_CS_fnc_loadCyberneticsData;

    // ALWAYS normalize via helper
    private _data = [_unit] call PHEN_CS_fnc_getOrInitCyberData;



    private _display = findDisplay 2312769;
    if (_unit != player) then { _display = findDisplay 2312770; };

    if (isNull _display) exitWith {};

    private _PlayerNameCtrl = _display displayCtrl 002;
    _PlayerNameCtrl ctrlSetText (name _unit);

    private _idcMap = [
        [0100, 0101, 0102],   // FC
        [0200],               // Ocular
        [0300, 0301, 0302],   // Circulatory
        [0400, 0401],         // Immune
        [0500, 0501],         // Nervous
        [0600, 0601, 0602],   // Integ
        [0700],               // OS
        [0800, 0801],         // Skeleton
        [0900],               // Hands
        [1000],               // Arms
        [1100]                // Legs
    ];

    private _emptyIcon = "a3\data_f\clear_empty.paa";
    private _emptyTooltip = "Empty cybernetic slot";

    {
        private _catIndex = _forEachIndex;
        private _slots = _x;

        {
            private _slotIndex = _forEachIndex;
            private _slotData = _x;

            private _idcArray = _idcMap # _catIndex;
            if (_slotIndex >= count _idcArray) then {continue};

            private _idc = _idcArray # _slotIndex;
            private _ctrl = _display displayCtrl _idc;
            if (isNull _ctrl) then {continue};

            if (
                (_slotData isEqualTo [])
                || {count _slotData < 3}
            ) then {

                if (_emptyIcon != "") then {
                    _ctrl ctrlSetText _emptyIcon;
                };
                _ctrl ctrlSetTooltip _emptyTooltip;

            } else {

                private _name    = _slotData # 0;
                private _picture = _slotData # 1;
                private _tip     = _slotData # 2;

                _ctrl ctrlSetText _picture;
                _ctrl ctrlSetTooltip _tip;
            };

        } forEach _slots;

    } forEach _data;
};

PHEN_CS_fnc_ShowSelf = {
    if (isNull findDisplay 2312769) then {
        createDialog 'CyberneticsSystemDialog';
        private _display = findDisplay 2312769;
        if (!isNull _display) then {
            private _pfhHandle = [{
                [] call PHEN_CS_fnc_LoadList;
            }, 3, []] call CBA_fnc_addPerFrameHandler;
            uiNamespace setVariable ["PHEN_CS_HUD_Self_PFH", _pfhHandle];
            _display displayAddEventHandler ["Unload", {
                if (!isNil { uiNamespace getVariable "PHEN_CS_HUD_Self_PFH" }) then {
                    [uiNamespace getVariable "PHEN_CS_HUD_Self_PFH"] call CBA_fnc_removePerFrameHandler;
                    uiNamespace setVariable ["PHEN_CS_HUD_Self_PFH", nil];
                };
            }];
        };
    } else {
        private _display = findDisplay 2312769;
        _display closeDisplay 0;
    };
};

PHEN_CS_fnc_ShowOther = {
    params [["_unit", cursorObject]];

    if (isNull findDisplay 2312770) then {
        if (_unit isKindOf "CAManBase") then {
            uiNamespace setVariable ["PHEN_CS_OtherUnit", _unit];
            createDialog 'CyberneticsSystemDialog_other';
            private _display = findDisplay 2312770;
            if (!isNull _display) then {
                private _pfhHandle = [{
                    private _other = uiNamespace getVariable ["PHEN_CS_OtherUnit", objNull];
                    if (!isNull _other) then { [_other] call PHEN_CS_fnc_LoadList; };
                }, 3, []] call CBA_fnc_addPerFrameHandler;
                uiNamespace setVariable ["PHEN_CS_HUD_Other_PFH", _pfhHandle];
                _display displayAddEventHandler ["Unload", {
                    if (!isNil { uiNamespace getVariable "PHEN_CS_HUD_Other_PFH" }) then {
                        [uiNamespace getVariable "PHEN_CS_HUD_Other_PFH"] call CBA_fnc_removePerFrameHandler;
                        uiNamespace setVariable ["PHEN_CS_HUD_Other_PFH", nil];
                    };
                }];
            };
        };
    } else {
        private _display = findDisplay 2312770;
        _display closeDisplay 0;
    };
};

PHEN_CS_fnc_StressBarInit_Self = {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _labelCtrl = _display displayCtrl 9900;
    private _pfhHandle = [{
        params ["_args", "_handle"];
        _args params ["_fillCtrl", "_labelCtrl"];
        private _stress = player getVariable ["PHEN_CS_stressPenaltyModifier", 0];
        private _stressCap = PHEN_CS_StressMax + 1;
        private _fill = (_stress / _stressCap) min 1;
        _fillCtrl progressSetPosition _fill;
        private _stressInterp = 0;
        private _green = 0;
        if (_fill <= 0.333) then {
            _stressInterp = _fill / 0.333;
            _green = 0.898 + (_stressInterp * (0.608 - 0.898));
        } else {
            if (_fill <= 0.666) then {
                _stressInterp = (_fill - 0.333) / 0.333;
                _green = 0.608 + (_stressInterp * (0.267 - 0.608));
            } else {
                _stressInterp = (_fill - 0.666) / 0.334;
                _green = 0.267 * (1 - _stressInterp);
            };
        };
        _fillCtrl ctrlSetTextColor [0.949, (_green max 0), 0, 1];
        _fillCtrl ctrlCommit 0.19;
        _labelCtrl ctrlSetText format ["NEURAL STRESS  %1 / %2", round _stress, PHEN_CS_StressMax];
    }, 0.2, [_ctrl, _labelCtrl]] call CBA_fnc_addPerFrameHandler;
    _display displayAddEventHandler ["Unload", {
        if (!isNil {uiNamespace getVariable "PHEN_CS_StressBarPFH_Self"}) then {
            [uiNamespace getVariable "PHEN_CS_StressBarPFH_Self"] call CBA_fnc_removePerFrameHandler;
            uiNamespace setVariable ["PHEN_CS_StressBarPFH_Self", nil];
        };
    }];
    uiNamespace setVariable ["PHEN_CS_StressBarPFH_Self", _pfhHandle];
};

PHEN_CS_fnc_StressBarInit_Other = {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _labelCtrl = _display displayCtrl 9900;
    private _pfhHandle = [{
        params ["_args", "_handle"];
        _args params ["_fillCtrl", "_labelCtrl"];
        private _unit = uiNamespace getVariable ["PHEN_CS_OtherUnit", objNull];
        if (isNull _unit) exitWith {};
        private _stress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
        private _stressCap = PHEN_CS_StressMax + 1;
        private _fill = (_stress / _stressCap) min 1;
        _fillCtrl progressSetPosition _fill;
        private _stressInterp = 0;
        private _green = 0;
        if (_fill <= 0.333) then {
            _stressInterp = _fill / 0.333;
            _green = 0.898 + (_stressInterp * (0.608 - 0.898));
        } else {
            if (_fill <= 0.666) then {
                _stressInterp = (_fill - 0.333) / 0.333;
                _green = 0.608 + (_stressInterp * (0.267 - 0.608));
            } else {
                _stressInterp = (_fill - 0.666) / 0.334;
                _green = 0.267 * (1 - _stressInterp);
            };
        };
        _fillCtrl ctrlSetTextColor [0.949, (_green max 0), 0, 1];
        _fillCtrl ctrlCommit 0.19;
        _labelCtrl ctrlSetText format ["NEURAL STRESS  %1 / %2", round _stress, PHEN_CS_StressMax];
    }, 0.2, [_ctrl, _labelCtrl]] call CBA_fnc_addPerFrameHandler;
    _display displayAddEventHandler ["Unload", {
        if (!isNil {uiNamespace getVariable "PHEN_CS_StressBarPFH_Other"}) then {
            [uiNamespace getVariable "PHEN_CS_StressBarPFH_Other"] call CBA_fnc_removePerFrameHandler;
            uiNamespace setVariable ["PHEN_CS_StressBarPFH_Other", nil];
        };
    }];
    uiNamespace setVariable ["PHEN_CS_StressBarPFH_Other", _pfhHandle];
};

PHEN_CS_fnc_isUnitExcluded = {
    params ["_unit"];
    if (_unit getVariable ["PHEN_CS_Disabled", false]) exitWith { true };
    private _blacklist = missionNamespace getVariable ["PHEN_CS_UnitClassBlacklist", []];
    if (_blacklist isEqualTo []) exitWith { false };
    private _unitClass = typeOf _unit;
    private _isBlacklisted = false;
    {
        if (_unitClass isKindOf [_x, configFile >> "CfgVehicles"]) exitWith {
            _isBlacklisted = true;
        };
    } forEach _blacklist;
    _isBlacklisted
};

PHEN_CS_fnc_addCyberwareHandler = {
    params ["_unit"];

        // Exit if running in Eden editor
        if (is3DEN) exitWith {};

        // Check for nil first
        if (isNil "_unit") exitWith {};

        // If it’s an array, pick first element
        if (typeName _unit == "ARRAY") then {
            if (count _unit == 0) exitWith {};
            _unit = _unit select 0;
        };

        // Check if it’s null
        if (isNull _unit) exitWith {};

        // check if it’s a UAV
        if (unitIsUAV _unit) exitWith {};

        if (isNil {_unit getVariable "PHEN_CS_BaseAnimSpeed"}) then {
            _unit setVariable ["PHEN_CS_BaseAnimSpeed", getAnimSpeedCoef _unit];
        };

        //pfH
        _handle = [{
            params ["_unit", "_handle"];

            [_unit] call PHEN_CS_fnc_CyberWareHandler;

        }, 0.01, _unit] call CBA_fnc_addPerFrameHandler;

        _unit setVariable ["PHEN_CS_CyberHandlerID", _handle, true];

        _unit addEventHandler ["Killed", {
            params ["_unit"];
            if (!isNil { _unit getVariable "PHEN_CS_CyberHandlerID" }) then {
                [_unit getVariable "PHEN_CS_CyberHandlerID"] call CBA_fnc_removePerFrameHandler;
                _unit setVariable ["PHEN_CS_CyberHandlerID", nil, true];
            };
        }];
};

PHEN_CS_fnc_CyberWareHandler = {
    params ["_unit"];
    
    if (_unit getVariable ['PHEN_CS_fnc_CyberWareHandler_running', false]) exitWith {}; //only run one call at time
    _unit setVariable ['PHEN_CS_fnc_CyberWareHandler_running', true];

    if ([_unit] call PHEN_CS_fnc_isUnitExcluded) exitWith {
        _unit setVariable ["PHEN_CS_Abillity_Jump", false, true];
        _unit setVariable ["PHEN_CS_Abillity_AirDash", false, true];
        _unit setVariable ["PHEN_CS_Abillity_Dash", false, true];
        _unit setVariable ["PHEN_CS_Abillity_TacHUD", false, true];
        _unit setVariable ["PHEN_CS_AutoHealStim_Active", false, true];
        _unit setVariable ["PHEN_CS_abilityCooldownModifier", 0, true];
        _unit setVariable ["PHEN_CS_stressPenaltyModifier", 0, true];
        _unit setVariable ["PHEN_CS_poisonResistModifier", 0, true];
        _unit setVariable ["PHEN_CS_diseaseResistModifier", 0, true];
        _unit setVariable ["PHEN_CS_radResistModifier", 0, true];
        _unit setVariable ["PHEN_CS_meleeDamageIncreaseModifier", 0, true];
        _unit setVariable ["PHEN_CS_recoilModifier", 0, true];
        _unit setVariable ["PHEN_CS_damageResistModifier", 0, true];
        private _baseSpeed = _unit getVariable ["PHEN_CS_BaseAnimSpeed", 1];
        [_unit, _baseSpeed] remoteExec ["setAnimSpeedCoef", 0, false];
        private _normalRecoil = _unit getVariable ["PHEN_CS_Normalrecoil", 0];
        if (_normalRecoil > 0) then { _unit setUnitRecoilCoefficient _normalRecoil; };
        if (hasInterface && { _unit isEqualTo player }) then { call PHEN_CS_fnc_TacHUD_hide; };
        _unit setVariable ["PHEN_CS_fnc_CyberWareHandler_running", nil];
    };

    // Make sure you have a valid data structure for this unit
    private _data = [_unit] call PHEN_CS_fnc_getOrInitCyberData;
    
    //index
	_HelmetVisionModeChanged = false;
	_lastvisionmode = currentVisionMode _unit;

    private _baseSpeed = _unit getVariable ["PHEN_CS_BaseAnimSpeed", 1];
    if (_baseSpeed <= 0) then { _baseSpeed = 1; };

    _SpeedModifier = _baseSpeed;

    _abilityCooldownModifier = 0;
    _stressPenaltyModifier = 0;
    _nvgToGive = "";
    _StaminaScheme = "";
    _poisonResist = 0;
    _diseaseResist = 0;
    _radResist = 0;
    _meleeDamageIncrease = 0;
    _damageResist = 0;
    _recoilModifier = 0;

    _Normalrecoil = (unitRecoilCoefficient _unit);
    //or (_unit getVariable ['PHEN_CS_Normalrecoil', 0]) for start of game value, might conflict with BCH or other mods like it
    
    _reloadSpeed = 0;
    _Abillity_Jump = false;
    _Abillity_AirDash = false;
    _Abillity_Dash = false;
    _bioMedicaStim = false;
    _Abillity_TacHUD = false;

    // Loop over all categories
    {
        private _catIndex = _forEachIndex;
        private _cat = _x;

        // Loop over all slots in this category
        {
            private _slotIndex = _forEachIndex;
            private _slot = _x;

            // Empty slot or malformed; skip
            if (_slot isEqualTo [] || {count _slot < 4}) then {continue};

            // Slot structure: [name, picture, tooltip, effectsArray]
            private _effectsArray = _slot # 3;

            // Loop over all effects in this installed cybernetic
            {
                // Each _x is ["effectName", value]
                _x params ["_effectName", "_effectValue"];

                switch (true) do {
                    case (_effectName isEqualTo "speed"): {
                        _SpeedModifier = _SpeedModifier + _effectValue;
                    };
                    case (_effectName isEqualTo "abilityCooldown"): {
                        _abilityCooldownModifier = _abilityCooldownModifier + _effectValue;
                    };
                    case (_effectName isEqualTo "stressPenalty"): {
                        _stressPenaltyModifier = _stressPenaltyModifier + _effectValue;
                    };
                    case (_effectName isEqualTo "nightVision"): {
                        _nvgToGive = "PHEN_CS_LowLightOptics_MkI";
                    };
                    case (_effectName isEqualTo "thermalVision"): {
                        _nvgToGive = "PHEN_CS_LowLightOptics_MkII";
                    };
                    case (_effectName isEqualTo "nightANDThermalVision"): {
                        _nvgToGive = "PHEN_CS_LowLightOptics_MkIII";
                    };
                    case (_effectName isEqualTo "setStaminaScheme_Default"): {
                        _StaminaScheme = "Default";
                    };
                    case (_effectName isEqualTo "setStaminaScheme_Normal"): {
                        _StaminaScheme = "Normal";
                    };
                    case (_effectName isEqualTo "setStaminaScheme_FastDrain"): {
                        _StaminaScheme = "FastDrain";
                    };
                    case (_effectName isEqualTo "poisonResist"): {
                        _poisonResist = _poisonResist + _effectValue;
                    };
                    case (_effectName isEqualTo "diseaseResist"): {
                        _diseaseResist = _diseaseResist + _effectValue;
                    };
                    case (_effectName isEqualTo "radResist"): {
                        _radResist = _radResist + _effectValue;
                    };
                    case (_effectName isEqualTo "meleeDamageIncrease"): {
                        _meleeDamageIncrease = _meleeDamageIncrease + _effectValue;
                    };
                    case (_effectName isEqualTo "recoil"): {
                        _recoilModifier = _recoilModifier + _effectValue;
                    };
                    case (_effectName isEqualTo "reloadSpeed"): {
                        _reloadSpeed = _reloadSpeed + _effectValue;
                    };
                    case (_effectName isEqualTo "Abillity_Jump"): {
                        _Abillity_Jump = _effectValue;
                    };
                    case (_effectName isEqualTo "Abillity_AirDash"): {
                        _Abillity_AirDash = _effectValue;
                    };
                    case (_effectName isEqualTo "Abillity_Dash"): {
                        _Abillity_Dash = _effectValue;
                    };
                    case (_effectName isEqualTo "bioMedicaStim"): {
                        _bioMedicaStim = _effectValue;
                    };
                    case (_effectName isEqualTo "tacHUD"): {
                        _Abillity_TacHUD = true;
                    };
                    case (_effectName isEqualTo "damageResist"): {
                        _damageResist = _damageResist + _effectValue;
                    };
                    default {};
                };

            } forEach _effectsArray;

        } forEach _cat;

    } forEach _data;

    //Get final '_recoilModifier' variable based on our effect values (before safety check)
    _recoilModifier =  _Normalrecoil - _recoilModifier;

    // safety checks (return defaults if needed)!
    if (_SpeedModifier <= 1) then { _SpeedModifier = 1; };

    if (_abilityCooldownModifier <= 0) then { _abilityCooldownModifier = 0; };

    switch (true) do {
        case (_stressPenaltyModifier <= 0): { _stressPenaltyModifier = 0; };
        case (_stressPenaltyModifier >= 100): { _stressPenaltyModifier = 100; };
        default { };
    };

    // CYBER NVG ENFORCEMENT
    // Only our cyber NVGs, nothing else.
    private _allCyberNVGs = [
        "PHEN_CS_LowLightOptics_MkI",
        "PHEN_CS_LowLightOptics_MkII",
        "PHEN_CS_LowLightOptics_MkIII"
    ];

    // If some bug set a nonsense NVG, nuke it.
    if !(_nvgToGive in _allCyberNVGs) then {
        _nvgToGive = "";
    };

    // 1) Remove ALL cyber NVGs from containers (no stashing, no dupes)
    private _containerItems = uniformItems _unit + vestItems _unit + backpackItems _unit;
    {
        private _class = _x;
        // Remove all occurrences in gear containers
        while { _class in _containerItems } do {
            [_unit, _class] call CBA_fnc_removeItem;
            _containerItems = uniformItems _unit + vestItems _unit + backpackItems _unit;
        };
    } forEach _allCyberNVGs;

    // 2) Clean up HMD slot if needed and enforce ocular logic
    private _currentHMD = hmd _unit;

    // If no ocular cyberware → no cyber NVGs at all, including HMD
    if (_nvgToGive isEqualTo "") then {

        if (_currentHMD in _allCyberNVGs) then {
            _unit unlinkItem _currentHMD;
        };

    } else {

        // We HAVE an ocular effect that wants a cyber NVG

        // If current HMD is some other cyber NVG, unlink it first
        if (_currentHMD in _allCyberNVGs && { _currentHMD != _nvgToGive }) then {
            _unit unlinkItem _currentHMD;
        };

        // If we do not have the correct NVG in HMD, link it
        if ((hmd _unit) != _nvgToGive) then {
            _unit linkItem _nvgToGive;
        };
    };

    if !(_StaminaScheme in ["Normal","FastDrain","Exhausted","Default",""]) then { _StaminaScheme = ""; };

    if (_poisonResist <= 0) then { _poisonResist = 0; };

    if (_diseaseResist <= 0) then { _diseaseResist = 0; };

    if (_radResist <= 0) then { _radResist = 0; };

    if (_meleeDamageIncrease <= 0) then { _meleeDamageIncrease = 0; };

    if (_damageResist < 0) then { _damageResist = 0; };
    if (_damageResist > 0.99) then { _damageResist = 0.99; };

    if (_recoilModifier <= 0) then { _recoilModifier = 0; };
    
    if (_reloadSpeed <= 0) then { _reloadSpeed = 0; };

    //Interjecting check in regards to reload speed (they use the same fnc but are conditional)
    if ((weaponState _unit) select 6 > 0) then {
        _multiplier = (1 + _reloadSpeed); // example: 1 + 0.08 = 1.08 // 108% of our already MODIFIED base speed WHILE 'reloading'
        _SpeedModifier = _SpeedModifier * _multiplier;
    };

    // Debug only fires on state change to avoid spamming chat
    if (PHEN_CS_DebugMode) then {
        private _nowReloading = (weaponState _unit) select 6 > 0;
        private _prevReloading = _unit getVariable ["PHEN_CS_debug_reloadWasReloading", false];
        private _prevReloadSpeed = _unit getVariable ["PHEN_CS_debug_reloadSpeedLast", -1];
        if (_nowReloading != _prevReloading || !(_reloadSpeed isEqualTo _prevReloadSpeed)) then {
            _unit setVariable ["PHEN_CS_debug_reloadWasReloading", _nowReloading];
            _unit setVariable ["PHEN_CS_debug_reloadSpeedLast", _reloadSpeed];
            private _pct = round (_reloadSpeed * 100);
            private _reloadState = if (_nowReloading) then { "RELOADING" } else { "idle" };
            [format ["reloadSpeed: +%1%% (%2) | %3 | animCoef: %4", _pct, _reloadSpeed, _reloadState, _SpeedModifier]] call PHEN_CS_fnc_debugMsg;
        };
    };

    // -- final apply!
    if (_SpeedModifier != (getAnimSpeedCoef _unit)) then { [_unit, _SpeedModifier] remoteExec ["setAnimspeedcoef", 0, false]; };
    if (_abilityCooldownModifier != (_unit getVariable ['PHEN_CS_abilityCooldownModifier', 0])) then { _unit setVariable ['PHEN_CS_abilityCooldownModifier', _abilityCooldownModifier, true]; };
    if (_stressPenaltyModifier != (_unit getVariable ['PHEN_CS_stressPenaltyModifier', 0])) then { _unit setVariable ['PHEN_CS_stressPenaltyModifier', _stressPenaltyModifier, true]; };
    if (_StaminaScheme != "") then { setStaminaScheme _StaminaScheme; }; //LOCAL on _unit PC
    if (_poisonResist != (_unit getVariable ['PHEN_CS_poisonResistModifier', 0])) then { _unit setVariable ['PHEN_CS_poisonResistModifier', _poisonResist, true]; };
    if (_diseaseResist != (_unit getVariable ['PHEN_CS_diseaseResistModifier', 0])) then { _unit setVariable ['PHEN_CS_diseaseResistModifier', _diseaseResist, true]; };
    if (_radResist != (_unit getVariable ['PHEN_CS_radResistModifier', 0])) then { _unit setVariable ['PHEN_CS_radResistModifier', _radResist, true]; };
    if (_meleeDamageIncrease != (_unit getVariable ['PHEN_CS_meleeDamageIncreaseModifier', 0])) then { _unit setVariable ['PHEN_CS_meleeDamageIncreaseModifier', _meleeDamageIncrease, true]; };
    if (_recoilModifier != (_unit getVariable ['PHEN_CS_recoilModifier', 0])) then { _unit setVariable ['PHEN_CS_recoilModifier', _recoilModifier, true]; };
    if ((_recoilModifier != 0) && !((_unit getVariable ['PHEN_CS_Normalrecoil', 0]) <= 0)) then {
        _unit setUnitRecoilCoefficient _recoilModifier;
    };
    if (_Abillity_Jump != (_unit getVariable ['PHEN_CS_Abillity_Jump', false])) then { _unit setVariable ['PHEN_CS_Abillity_Jump', _Abillity_Jump, true]; };
    if (_Abillity_AirDash != (_unit getVariable ['PHEN_CS_Abillity_AirDash', false])) then { _unit setVariable ['PHEN_CS_Abillity_AirDash', _Abillity_AirDash, true]; };
    if (_Abillity_Dash != (_unit getVariable ['PHEN_CS_Abillity_Dash', false])) then { _unit setVariable ['PHEN_CS_Abillity_Dash', _Abillity_Dash, true]; };
    if (_bioMedicaStim != (_unit getVariable ['PHEN_CS_AutoHealStim_Active', false])) then { _unit setVariable ['PHEN_CS_AutoHealStim_Active', _bioMedicaStim, true]; };
    if (_Abillity_TacHUD != (_unit getVariable ["PHEN_CS_Abillity_TacHUD", false])) then {
        _unit setVariable ["PHEN_CS_Abillity_TacHUD", _Abillity_TacHUD, true];
        if (!_Abillity_TacHUD && { hasInterface } && { _unit isEqualTo player }) then {
            call PHEN_CS_fnc_TacHUD_hide;
        };
    };
    if (_damageResist != (_unit getVariable ['PHEN_CS_damageResistModifier', 0])) then { _unit setVariable ['PHEN_CS_damageResistModifier', _damageResist, true]; };

    // OVERCLOCK CHECK, OverclockWarningActive gates re-entry for the 21s window
    if (alive _unit && {lifeState _unit != "INCAPACITATED"}) then {
        if (_stressPenaltyModifier > PHEN_CS_StressMax) then {
            if (!(_unit getVariable ["PHEN_CS_OverclockWarningActive", false])) then {
                _unit setVariable ["PHEN_CS_OverclockWarningActive", true, false];
                [_unit] spawn PHEN_CS_fnc_doOverclockEvent;
            };
        };
    };

    _unit setVariable ['PHEN_CS_fnc_CyberWareHandler_running', nil]; //reset
};

// BIO-MEDICA HAEMOSTATIC IMPLANT

PHEN_CS_fnc_registerBioMedicaEHs = {
    // Remove vanilla unit EHs
    if !(isNil "PHEN_CS_BioMedicaHitEH") then {
        player removeEventHandler ["HitPart", PHEN_CS_BioMedicaHitEH];
    };
    if !(isNil "PHEN_CS_BioMedicaHealEH") then {
        player removeEventHandler ["HandleHeal", PHEN_CS_BioMedicaHealEH];
    };
    if !(isNil "PHEN_CS_BioMedicaDamageEH") then {
        player removeEventHandler ["HandleDamage", PHEN_CS_BioMedicaDamageEH];
    };
    if !(isNil "PHEN_CS_DamageResistEH") then {
        player removeEventHandler ["HandleDamage", PHEN_CS_DamageResistEH];
    };

    // Remove ACE CBA EHs
    if !(isNil "PHEN_CS_BioMedicaUnconsciousEH") then {
        ["ace_unconscious", PHEN_CS_BioMedicaUnconsciousEH] call CBA_fnc_removeEventHandler;
    };
    if !(isNil "PHEN_CS_BioMedicaTreatSuccessEH") then {
        ["ace_treatmentSucceded", PHEN_CS_BioMedicaTreatSuccessEH] call CBA_fnc_removeEventHandler;
    };
    if !(isNil "PHEN_CS_BioMedicaTreatFailEH") then {
        ["ace_treatmentFailed", PHEN_CS_BioMedicaTreatFailEH] call CBA_fnc_removeEventHandler;
    };
    if !(isNil "PHEN_CS_BioMedicaBandagedEH") then {
        ["ace_medical_treatment_bandaged", PHEN_CS_BioMedicaBandagedEH] call CBA_fnc_removeEventHandler;
    };
    if !(isNil "PHEN_CS_BioMedicaOverdoseEH") then {
        ["ace_medical_overdose", PHEN_CS_BioMedicaOverdoseEH] call CBA_fnc_removeEventHandler;
    };

    // Vanilla unit EHs
    PHEN_CS_BioMedicaHitEH = player addEventHandler ["HitPart", {
        (_this select 0) params ["_target"];
        if (_target getVariable ["PHEN_CS_AutoHealStim_Active", false]) then {
            [_target] call PHEN_CS_fnc_checkBioMedicaStim;
        };
    }];

    PHEN_CS_BioMedicaHealEH = player addEventHandler ["HandleHeal", {
        params ["_injured"];
        if (_injured getVariable ["PHEN_CS_AutoHealStim_Active", false]) then {
            [_injured] call PHEN_CS_fnc_checkBioMedicaStim;
        };
    }];

    PHEN_CS_BioMedicaDamageEH = player addEventHandler ["HandleDamage", {
        params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPartIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
        if (_unit getVariable ["PHEN_CS_AutoHealStim_Active", false]) then {
            [_unit] call PHEN_CS_fnc_checkBioMedicaStim;
        };
    }];

    if (!PHEN_CS_HasACEMedical) then {
        PHEN_CS_DamageResistEH = player addEventHandler ["HandleDamage", {
            params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPartIndex", "_instigator", "_hitPoint", "_directHit", "_context"];

            private _isCyberAirborne = _unit getVariable ["PHEN_CS_IsJumpingOrDashing", false];
            private _hasNoProjectile = _projectile isEqualTo "";
            private _isSelfDamage = _source isEqualTo _unit || { isNull _source };

            [format ["BaseDmg | sel=%1, dmg=%2, proj=%3, src=%4, hitPt=%5", _selection, _damage, _projectile, _source, _hitPoint]] call PHEN_CS_fnc_debugMsg;
            [format ["BaseDmg | cyberAirborne=%1, noProj=%2, selfDmg=%3", _isCyberAirborne, _hasNoProjectile, _isSelfDamage]] call PHEN_CS_fnc_debugMsg;

            if (_isCyberAirborne && { _hasNoProjectile && _isSelfDamage }) exitWith {
                ["BaseDmg | FALL SUPPRESSED (cyber airborne)"] call PHEN_CS_fnc_debugMsg;
                0
            };

            private _resist = _unit getVariable ["PHEN_CS_damageResistModifier", 0];
            [format ["BaseDmg | resist=%1, dmg in=%2, dmg out=%3", _resist, _damage, _damage * (1 - _resist)]] call PHEN_CS_fnc_debugMsg;
            if (_resist <= 0) exitWith {};
            _damage * (1 - _resist)
        }];
    };

    // ACE CBA EHs
    if (PHEN_CS_HasACEMedical) then {
        PHEN_CS_BioMedicaUnconsciousEH = ["ace_unconscious", {
            params ["_unit", "_isUnconscious"];
            if (_unit == player && { _isUnconscious } && { _unit getVariable ["PHEN_CS_AutoHealStim_Active", false] }) then {
                [_unit] call PHEN_CS_fnc_checkBioMedicaStim;
            };
        }] call CBA_fnc_addEventHandler;

        PHEN_CS_BioMedicaTreatSuccessEH = ["ace_treatmentSucceded", {
            params ["_caller", "_target"];
            if (_target == player && { _target getVariable ["PHEN_CS_AutoHealStim_Active", false] }) then {
                [_target] call PHEN_CS_fnc_checkBioMedicaStim;
            };
        }] call CBA_fnc_addEventHandler;

        PHEN_CS_BioMedicaTreatFailEH = ["ace_treatmentFailed", {
            params ["_caller", "_target"];
            if (_target == player && { _target getVariable ["PHEN_CS_AutoHealStim_Active", false] }) then {
                [_target] call PHEN_CS_fnc_checkBioMedicaStim;
            };
        }] call CBA_fnc_addEventHandler;

        PHEN_CS_BioMedicaBandagedEH = ["ace_medical_treatment_bandaged", {
            params ["_target", "_caller"];
            if (_target == player && { _target getVariable ["PHEN_CS_AutoHealStim_Active", false] }) then {
                [_target] call PHEN_CS_fnc_checkBioMedicaStim;
            };
        }] call CBA_fnc_addEventHandler;

        PHEN_CS_BioMedicaOverdoseEH = ["ace_medical_overdose", {
            params ["_unit"];
            if (_unit == player && { _unit getVariable ["PHEN_CS_AutoHealStim_Active", false] }) then {
                [_unit] call PHEN_CS_fnc_checkBioMedicaStim;
            };
        }] call CBA_fnc_addEventHandler;
    };
};

PHEN_CS_fnc_checkBioMedicaStim = {
    params ["_unit"];

    if (!alive _unit) exitWith {};
    if (_unit getVariable ["PHEN_CS_BioMedicaStim_Used", false]) exitWith {};
    if (_unit getVariable ["PHEN_CS_BioMedicaStim_Running", false]) exitWith {};

    if (PHEN_CS_HasACEMedical) then {
        private _bloodVol = _unit getVariable ["ace_medical_bloodVolume", 6];
        private _normalizedBlood = _bloodVol / 6;
        if (
            (_normalizedBlood <= PHEN_CS_BioMedicaStim_Threshold) ||
            { (lifeState _unit) in ["INCAPACITATED", "UNCONSCIOUS"] }
        ) then {
            [_unit] spawn PHEN_CS_fnc_executeBioMedicaStim;
        };
    } else {
        if (
            ((damage _unit) >= PHEN_CS_BioMedicaStim_Threshold) ||
            { (lifeState _unit) in ["INCAPACITATED", "UNCONSCIOUS"] }
        ) then {
            [_unit] spawn PHEN_CS_fnc_executeBioMedicaStim;
        };
    };
};

PHEN_CS_fnc_executeBioMedicaStim = {
    params ["_unit"];

    if (!alive _unit) exitWith {};
    if (_unit getVariable ["PHEN_CS_BioMedicaStim_Running", false]) exitWith {};
    _unit setVariable ["PHEN_CS_BioMedicaStim_Running", true, true];

    playSoundUI ["PHEN_CS_UI_Smart_System_Activation", (0.7 + random 0.3), (0.85 + random 0.3)];
    playSoundUI ["PHEN_CS_BioMedica_Scan", (0.8 + random 0.2), (0.9 + random 0.2)];

    sleep PHEN_CS_BioMedicaStim_ActivationDelay;
    if (!alive _unit) exitWith { _unit setVariable ["PHEN_CS_BioMedicaStim_Running", false, true]; };

    private _stimUsed = false;

    // Full heal mode: instant comprehensive treatment, bypasses individual toggles
    if (PHEN_CS_BioMedicaStim_TOGGLE_FullHeal && { PHEN_CS_HasACEMedical }) then {
        if (PHEN_CS_HasKAT) then {
            // KAT: use native full heal, which resets all medical state variables
            [_unit] call kat_circulation_fnc_fullHealLocal;
            uiSleep 0.2;
            _unit setVariable ["ace_medical_inCardiacArrest", false, true];
            _unit setVariable ["kat_circulation_cardiacArrestType", 0, true];
            [_unit, false] call ace_medical_fnc_setUnconscious;
        } else {
            // ACE only: manual comprehensive treatment
            private _healingSphereF = "#particlesource" createVehicleLocal (getPosATL _unit);
            _healingSphereF attachTo [_unit, [0, 0, 0], "spine3"];
            private _bodyPartsF = ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];
            { [_healingSphereF, _unit, _x, "FieldDressing", nil, nil, false, 99] call ace_medical_treatment_fnc_bandage; uiSleep 0.02; } forEach _bodyPartsF;
            { [_unit, toLower _x] call ace_medical_treatment_fnc_stitchWound; } forEach _bodyPartsF;
            private _bloodBagsF = _unit getVariable ["ace_medical_ivBags", []];
            for "_i" from 1 to 6 do { _bloodBagsF pushBack [1000, "Blood", 1, "BloodIV", 1, "ACE_bloodIV_1000"]; };
            _unit setVariable ["ace_medical_ivBags", _bloodBagsF, true];
            uiSleep 0.2;
            [_healingSphereF, _unit] call ace_medical_treatment_fnc_cprSuccess;
            playSoundUI [selectRandom ["PHEN_CS_BioMedica_Defib_0", "PHEN_CS_BioMedica_Defib_1"], (0.9 + random 0.1), (0.85 + random 0.3)];
            uiSleep 0.5;
            _unit setVariable ["ace_medical_inCardiacArrest", false, true];
            deleteVehicle _healingSphereF;
            [_unit, false] call ace_medical_fnc_setUnconscious;
        };
        _unit setDamage 0;
        if ((missionNamespace getVariable ["bis_revive_mode", 0]) != 0) then {
            [objNull, 1, _unit] call BIS_fnc_reviveOnState;
        };
        _stimUsed = true;
    };
    if (PHEN_CS_BioMedicaStim_TOGGLE_FullHeal && { PHEN_CS_HasACEMedical }) exitWith {
        _unit setVariable ["PHEN_CS_BioMedicaStim_Running", false, true];
        if (_stimUsed) then {
            playSoundUI ["PHEN_CS_BioMedica_GeneralHeal", (0.7 + random 0.3), (0.85 + random 0.3)];
            _unit setVariable ["PHEN_CS_BioMedicaStim_Used", true, true];
            [_unit] spawn {
                params ["_unit"];
                uiSleep PHEN_CS_BioMedicaStim_Cooldown;
                _unit setVariable ["PHEN_CS_BioMedicaStim_Used", false, true];
            };
        };
    };

    // Vanilla healing
    if (
        ((damage _unit) >= PHEN_CS_BioMedicaStim_Threshold) ||
        { (lifeState _unit) in ["INCAPACITATED", "UNCONSCIOUS"] }
    ) then {
        _unit setDamage 0;
        if ((missionNamespace getVariable ["bis_revive_mode", 0]) != 0) then {
            [objNull, 1, _unit] call BIS_fnc_reviveOnState;
        };
        _stimUsed = true;
    };

    // ACE Medical healing
    if (PHEN_CS_HasACEMedical) then {
        private _healingSphere = "#particlesource" createVehicleLocal (getPosATL _unit);
        _healingSphere attachTo [_unit, [0, 0, 0], "spine3"];

        private _bodyParts = ["Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg"];

        // KAT-specific drugs: TXA, EACA, atropine only exist when KAT is loaded
        if (PHEN_CS_HasKAT) then {
            if (PHEN_CS_BioMedicaStim_TOGGLE_TXA) then {
                { [_healingSphere, _unit, _x, "kat_TXA", objNull, "kat_TXA"] call kat_pharma_fnc_medication; uiSleep 0.01; } forEach _bodyParts;
                _stimUsed = true;
            };
            uiSleep 0.1; // wait
            if (PHEN_CS_BioMedicaStim_TOGGLE_EACA) then {
                { [_healingSphere, _unit, _x, "kat_EACA", objNull, "kat_EACA"] call kat_pharma_fnc_medication; uiSleep 0.01; } forEach _bodyParts;
                _stimUsed = true;
            };
            uiSleep 0.1; // wait
            if (PHEN_CS_BioMedicaStim_TOGGLE_Atropine) then {
                [_healingSphere, _unit, "LeftArm", "kat_atropine", objNull, "kat_atropine"] call kat_pharma_fnc_medication;
                _stimUsed = true;
            };
        };

        // ACE drugs: kat_pharma_fnc_medication when KAT loaded, ace_medical_treatment_fnc_medication otherwise
        if (PHEN_CS_BioMedicaStim_TOGGLE_Epinephrine) then {
            if (PHEN_CS_HasKAT) then {
                [_healingSphere, _unit, "LeftArm", "Epinephrine", objNull, "ACE_epinephrine"] call kat_pharma_fnc_medication;
            } else {
                [_healingSphere, _unit, "LeftArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
            };
            _stimUsed = true;
        };
        uiSleep 0.1; // wait
        if (PHEN_CS_BioMedicaStim_TOGGLE_Morphine) then {
            if (PHEN_CS_HasKAT) then {
                [_healingSphere, _unit, "LeftArm", "Morphine", objNull, "ACE_morphine"] call kat_pharma_fnc_medication;
            } else {
                [_healingSphere, _unit, "LeftArm", "Morphine", objNull, "ACE_morphine"] call ace_medical_treatment_fnc_medication;
            };
            _stimUsed = true;
        };
        uiSleep 0.1; // wait
        if (PHEN_CS_BioMedicaStim_TOGGLE_Adenosine) then {
            if (PHEN_CS_HasKAT) then {
                [_healingSphere, _unit, "LeftArm", "Adenosine", objNull, "ACE_adenosine"] call kat_pharma_fnc_medication;
            } else {
                [_healingSphere, _unit, "LeftArm", "Adenosine", objNull, "ACE_adenosine"] call ace_medical_treatment_fnc_medication;
            };
            _stimUsed = true;
        };

        // Blood
        if (PHEN_CS_BioMedicaStim_TOGGLE_Blood) then {
            private _bloodBags = _unit getVariable ["ace_medical_ivBags", []];
            private _bloodItemClass = format ["ACE_bloodIV_%1", PHEN_CS_BioMedicaStim_BloodBagSize];
            for "_i" from 1 to PHEN_CS_BioMedicaStim_BloodCount do {
                _bloodBags pushBack [PHEN_CS_BioMedicaStim_BloodBagSize, "Blood", 1, "BloodIV", 1, _bloodItemClass];
            };
            _unit setVariable ["ace_medical_ivBags", _bloodBags, true];
            _stimUsed = true;
        };

        uiSleep 0.1; // wait for bloodIV application

        // Bandaging
        //weapons[] = {"ACE_fieldDressing","ACE_packingBandage","ACE_elasticBandage","ACE_tourniquet","ACE_splint","ACE_morphine","ACE_adenosine","ACE_epinephrine","ACE_plasmaIV","ACE_plasmaIV_500","ACE_plasmaIV_250","ACE_bloodIV","ACE_bloodIV_500","ACE_bloodIV_250","ACE_salineIV","ACE_salineIV_500","ACE_salineIV_250","ACE_quikclot","ACE_personalAidKit","ACE_surgicalKit","ACE_suture","ACE_bodyBag","ACE_bodyBag_blue","ACE_bodyBag_white","ACE_painkillers_Item"};
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "Head"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "Head", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "Head", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "Head", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "Body"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "Body", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "Body", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "Body", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "LeftArm"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "LeftArm", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "LeftArm", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "LeftArm", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "RightArm"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "RightArm", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "RightArm", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "RightArm", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "LeftLeg"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "LeftLeg", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "LeftLeg", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "LeftLeg", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Bandage) then {
            private _bandageTries = 0;
            while { _bandageTries < 2 && { count ([_unit, "RightLeg"] call ace_medical_fnc_getopenWounds) >= 1 } } do {
                [_healingSphere, _unit, "RightLeg", "FieldDressing", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "RightLeg", "elasticBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                [_healingSphere, _unit, "RightLeg", "packingBandage", nil, nil, false, 1] call ace_medical_treatment_fnc_bandage;
                uiSleep 0.1;
                _bandageTries = _bandageTries + 1;
            };
            if (_bandageTries > 0) then { _stimUsed = true; };
        };

        uiSleep 0.1;

        // Stitching (fresh bandaged wound reads after bandage application above)
        private _bandagedHead =     [_unit, "Head"]     call ace_medical_fnc_getBandagedWounds;
        private _bandagedBody =     [_unit, "Body"]     call ace_medical_fnc_getBandagedWounds;
        private _bandagedLeftArm =  [_unit, "LeftArm"]  call ace_medical_fnc_getBandagedWounds;
        private _bandagedRightArm = [_unit, "RightArm"] call ace_medical_fnc_getBandagedWounds;
        private _bandagedLeftLeg =  [_unit, "LeftLeg"]  call ace_medical_fnc_getBandagedWounds;
        private _bandagedRightLeg = [_unit, "RightLeg"] call ace_medical_fnc_getBandagedWounds;

        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedHead > 0)) then {
            [_unit, "head"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "Head"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "head"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedBody > 0)) then {
            [_unit, "body"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "Body"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "body"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedLeftArm > 0)) then {
            [_unit, "leftarm"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "LeftArm"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "leftarm"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedRightArm > 0)) then {
            [_unit, "rightarm"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "RightArm"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "rightarm"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedLeftLeg > 0)) then {
            [_unit, "leftleg"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "LeftLeg"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "leftleg"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };
        if (PHEN_CS_BioMedicaStim_TOGGLE_Stitch && (count _bandagedRightLeg > 0)) then {
            [_unit, "rightleg"] call ace_medical_treatment_fnc_stitchWound;
            uiSleep 0.1;
            if (count ([_unit, "RightLeg"] call ace_medical_fnc_getBandagedWounds) > 0) then {
                [_unit, "rightleg"] call ace_medical_treatment_fnc_stitchWound;
            };
            _stimUsed = true;
        };

        uiSleep 0.1;

        // Fractures (fresh read after all drug and bandage treatments)
        private _fractures = _unit getVariable "ace_medical_fractures";
        if !(isNil "_fractures") then {
            if (PHEN_CS_BioMedicaStim_TOGGLE_Fractures && ((_fractures # 2) > 0)) then {
                [_healingSphere, _unit, "LeftArm"] call ace_medical_treatment_fnc_splint;
                _stimUsed = true;
            };
            if (PHEN_CS_BioMedicaStim_TOGGLE_Fractures && ((_fractures # 3) > 0)) then {
                [_healingSphere, _unit, "RightArm"] call ace_medical_treatment_fnc_splint;
                _stimUsed = true;
            };
            if (PHEN_CS_BioMedicaStim_TOGGLE_Fractures && ((_fractures # 4) > 0)) then {
                [_healingSphere, _unit, "LeftLeg"] call ace_medical_treatment_fnc_splint;
                _stimUsed = true;
            };
            if (PHEN_CS_BioMedicaStim_TOGGLE_Fractures && ((_fractures # 5) > 0)) then {
                [_healingSphere, _unit, "RightLeg"] call ace_medical_treatment_fnc_splint;
                _stimUsed = true;
            };
        };

        uiSleep 0.1;

        // CPR / cardiac arrest recovery (fresh vitals read after all treatments have been applied)
        private _currentPulse = _unit getVariable ["ace_medical_heartRate", 0];
        private _inCardiacArrest = _unit getVariable ["ace_medical_inCardiacArrest", false];
        if (_currentPulse <= 30 || { _inCardiacArrest }) then {
            [_healingSphere, _unit] call ace_medical_treatment_fnc_cprSuccess;
            playSoundUI [selectRandom ["PHEN_CS_BioMedica_Defib_0", "PHEN_CS_BioMedica_Defib_1"], (0.9 + random 0.1), (0.85 + random 0.3)];
            uiSleep 0.5;
            if (_unit getVariable ["ace_medical_inCardiacArrest", false]) then {
                _unit setVariable ["ace_medical_inCardiacArrest", false, true];
                if (PHEN_CS_HasKAT) then { _unit setVariable ["kat_circulation_cardiacArrestType", 0, true]; };
            };
            _stimUsed = true;
        };

        deleteVehicle _healingSphere;

        // Wake from unconscious if vitals are now stable
        if (PHEN_CS_BioMedicaStim_TOGGLE_WakeUnconscious && { (lifeState _unit) in ["UNCONSCIOUS", "INCAPACITATED"] }) then {
            private _heartRate = _unit getVariable ["ace_medical_heartRate", 0];
            private _bloodVol = _unit getVariable ["ace_medical_bloodVolume", 6];
            if (_heartRate > 30 && { (_bloodVol / 6) > PHEN_CS_BioMedicaStim_Threshold }) then {
                [_unit, false] call ace_medical_fnc_setUnconscious;
                _stimUsed = true;
            };
        };
    };

    if (_stimUsed) then {
        playSoundUI ["PHEN_CS_BioMedica_GeneralHeal", (0.7 + random 0.3), (0.85 + random 0.3)];

        private _rXY = random [0.03, 0.05, 0.07];
        ["ChromAberration", random [300, 500, 700], [_rXY, _rXY, true]] spawn {
            params ["_name", "_priority", "_effect"];
            private _handle = -1;
            while { _handle = ppEffectCreate [_name, _priority]; _handle < 0 } do {
                _priority = _priority + 1;
            };
            _handle ppEffectEnable true;
            _handle ppEffectAdjust _effect;
            _handle ppEffectCommit 0.5;
            waitUntil { ppEffectCommitted _handle };
            _handle ppEffectAdjust [0, 0, false];
            _handle ppEffectCommit 0.4;
            uiSleep 0.5;
            ppEffectDestroy _handle;
        };

        0 spawn {
            BIS_BleedCC ppEffectAdjust [1, 1, 0, [0.25, 0.75, 0.25, 0], [0.25, 0.75, 0.25, 0.2], [1, 1, 1, 0], [0.7, 1, 0, 0, 0, 0.3, 5]];
            BIS_BleedCC ppEffectEnable true;
            BIS_BleedCC ppEffectCommit 1;
            uiSleep 1;

            BIS_BleedCC ppEffectAdjust [1, 1, 0, [0.25, 0.75, 0.25, 0], [0.25, 0.75, 0.25, 0.2], [1, 1, 1, 0], [0.5, 2, 0, 0, 0, 0.3, 5]];
            BIS_BleedCC ppEffectEnable true;
            BIS_BleedCC ppEffectCommit 0.3;
            uiSleep 0.3;

            BIS_BleedCC ppEffectAdjust [1, 1, 0, [0.25, 0.75, 0.25, 0], [0.25, 0.75, 0.25, 0.2], [1, 1, 1, 0], [0.7, 1, 0, 0, 0, 0.3, 5]];
            BIS_BleedCC ppEffectEnable true;
            BIS_BleedCC ppEffectCommit 1;
            uiSleep 1;

            BIS_BleedCC ppEffectAdjust [1, 1, 0, [0.25, 0.75, 0.25, 0], [0.25, 0.75, 0.25, 0.1], [1, 1, 1, 0], [2, 2, 0, 0, 0, 0.3, 5]];
            BIS_BleedCC ppEffectEnable true;
            BIS_BleedCC ppEffectCommit 3;
        };

        _unit setVariable ["PHEN_CS_BioMedicaStim_Used", true, true];
        [_unit] spawn {
            params ["_unit"];
            uiSleep PHEN_CS_BioMedicaStim_Cooldown;
            _unit setVariable ["PHEN_CS_BioMedicaStim_Used", false, true];
        };
    };
    _unit setVariable ["PHEN_CS_BioMedicaStim_Running", false, true];
};

// OVERCLOCK VISUAL EFFECT
PHEN_CS_fnc_showOverclockGlitch = {
    params [["_unit", player]];

    if (!hasInterface) exitWith {};
    if (isNull (findDisplay 46)) exitWith {};

    private _display = findDisplay 46;
    private _frames = [
        "PHEN_Cybernetics\Data\CS_Overclock_Lite_01.paa",
        "PHEN_Cybernetics\Data\CS_Overclock_Lite_02.paa",
        "PHEN_Cybernetics\Data\CS_Overclock_Lite_03.paa"
    ];

    // PP effects
    private _ppCA = ppEffectCreate ["ChromAberration", 223];
    private _ppRB = ppEffectCreate ["RadialBlur",      422];
    private _ppDB = ppEffectCreate ["DynamicBlur",     122];
    private _ppFG = ppEffectCreate ["FilmGrain",       2321];
    _ppCA ppEffectEnable true;
    _ppRB ppEffectEnable true;
    _ppDB ppEffectEnable true;
    _ppFG ppEffectEnable true;

    _ppCA ppEffectAdjust [0, 0, 0];             _ppCA ppEffectCommit 0;
    _ppRB ppEffectAdjust [0, 1, 0.5, 0.5];     _ppRB ppEffectCommit 0;
    _ppDB ppEffectAdjust [0];                   _ppDB ppEffectCommit 0;
    _ppFG ppEffectAdjust [0, 0, 1.2, 0, 1];    _ppFG ppEffectCommit 0;

    private _ctrl = _display ctrlCreate ["RscPicture", -1];
    _ctrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
    _ctrl ctrlSetText (_frames # 0);
    _ctrl ctrlSetTextColor [1, 1, 1, 0];
    _ctrl ctrlCommit 0;

    // hard-cut in
    // playSoundUI ["PHEN_CS_Texture_Optical_Attack", 1, 1];
    _soundOBJ1 = [_unit, "PHEN_CS_Texture_Optical_Attack", 10, 19] call PHEN_CS_fnc_Say3D;
    [_unit, _soundOBJ1] spawn {
        params ["_unit", "_soundOBJ"];
        for "_i" from 0 to 20 do {
            private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
            if ((_currentStress <= PHEN_CS_StressMax) && (!(isNull _soundOBJ))) exitWith {
                deleteVehicle _soundOBJ;
            };
            sleep 1;
        };
    };
    _ctrl ctrlSetTextColor [1, 1, 1, 0.9];
    _ctrl ctrlCommit 0;
    _ppCA ppEffectAdjust [0.025, 0.025, 0];            _ppCA ppEffectCommit 0;
    _ppRB ppEffectAdjust [0.055, 1, 0.5, 0.5];         _ppRB ppEffectCommit 0;
    _ppDB ppEffectAdjust [1.8];                         _ppDB ppEffectCommit 0;
    _ppFG ppEffectAdjust [0.35, 0.08, 1.3, 0.85, 1];   _ppFG ppEffectCommit 0;

    for "_i" from 0 to 7 do {
        private _frame = _frames # (_i mod 3);
        _ctrl ctrlSetText _frame;

        private _jX = safeZoneX + ((random 0.006) - 0.003);
        private _jY = safeZoneY + ((random 0.006) - 0.003);
        _ctrl ctrlSetPosition [_jX, _jY, safeZoneW, safeZoneH];

        if (random 1 > 0.45) then {
            _ctrl ctrlSetTextColor [1, 0.08, 0.08, 0.95];
        } else {
            _ctrl ctrlSetTextColor [1, 1, 1, 0.85];
        };
        _ctrl ctrlCommit 0;

        private _caStr = 0.010 + random 0.020;
        private _rbStr = 0.020 + random 0.040;
        _ppCA ppEffectAdjust [_caStr, _caStr, 0];                      _ppCA ppEffectCommit 0;
        _ppRB ppEffectAdjust [_rbStr, 1, 0.5, 0.5];                    _ppRB ppEffectCommit 0;
        _ppFG ppEffectAdjust [0.20 + random 0.20, 0.05 + random 0.05, 1.2, 0.6 + random 0.3, 1]; _ppFG ppEffectCommit 0;

        if (random 1 > 0.5) then {
            private _rsound = selectRandom ["PHEN_CS_UI_Window_Open", "PHEN_CS_UI_Zappy_Pop_Up", "PHEN_CS_Glitch_Digital_Bleep"];
            playSoundUI [_rsound, (0.4 + random 0.6), (0.85 + random 0.3)];
        };

        uiSleep (0.07 + random 0.12);
    };

    // final hold, deep red
    _ctrl ctrlSetText (_frames # 2);
    _ctrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
    _ctrl ctrlSetTextColor [1, 0.05, 0.05, 1];
    _ctrl ctrlCommit 0;
    _ppCA ppEffectAdjust [0.030, 0.030, 0];             _ppCA ppEffectCommit 0;
    _ppRB ppEffectAdjust [0.045, 1, 0.5, 0.5];          _ppRB ppEffectCommit 0;
    _ppDB ppEffectAdjust [0];                            _ppDB ppEffectCommit 0.15;
    _ppFG ppEffectAdjust [0.30, 0.07, 1.3, 0.70, 1];    _ppFG ppEffectCommit 0;
    _soundOBJ2 = [_unit, "PHEN_CS_Texture_Virus_Detected_Alarm", 10, 21] call PHEN_CS_fnc_Say3D;
    [_unit, _soundOBJ2] spawn {
        params ["_unit", "_soundOBJ"];
        for "_i" from 0 to 20 do {
            private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
            if ((_currentStress <= PHEN_CS_StressMax) && (!(isNull _soundOBJ))) exitWith {
                deleteVehicle _soundOBJ;
            };
            sleep 1;
        };
    };
    uiSleep 0.45;

    // fade out
    _ctrl ctrlSetTextColor [1, 1, 1, 0];
    _ctrl ctrlCommit 0.25;
    _ppCA ppEffectAdjust [0, 0, 0];         _ppCA ppEffectCommit 0.3;
    _ppRB ppEffectAdjust [0, 1, 0.5, 0.5];  _ppRB ppEffectCommit 0.3;
    _ppFG ppEffectAdjust [0, 0, 1.2, 0, 1]; _ppFG ppEffectCommit 0.3;
    uiSleep 0.4;

    ctrlDelete _ctrl;
    ppEffectDestroy _ppCA;
    ppEffectDestroy _ppRB;
    ppEffectDestroy _ppDB;
    ppEffectDestroy _ppFG;
};

// OVERCLOCK ANIMATION
// Plays a spasm/collapse on the unit at the moment of consequence.
// Uses IMS lightsaber_death anims (electrocution look) if WBK_MeleeMechanics is loaded, vanilla fall anims otherwise.
PHEN_CS_fnc_overclockAnim = {
    params [["_unit", player]];
    if (isNull _unit) exitWith {};
    if (!(alive _unit)) exitWith {};
    if (!(isNull objectParent _unit)) exitWith {};

    // skip if already mid a death/transition anim
    private _knownDeathAnims = [
        "death_neck_1","death_neck_2","death_neck_3",
        "long_death_front_in_1","long_death_front_in_2","long_death_front_in_3",
        "longDeath_front","longDeath_Back",
        "lightsaber_death_1","lightsaber_death_3","lightsaber_death_4",
        "lightsaber_death_12","lightsaber_death_14","lightsaber_death_21",
        "A_PlayerDeathAnim_Electric","A_PlayerDeathAnim_13","A_PlayerDeathAnim_14",
        "A_PlayerDeathAnim_20","A_PlayerDeathAnim_21"
    ];
    if ((configName (configFile >> getText (configFile >> "CfgVehicles" >> typeOf _unit >> "moves") >> "States" >> (animationState _unit))) in _knownDeathAnims) exitWith {};

    private _spasmAnims = [
        "lightsaber_death_1","lightsaber_death_3","lightsaber_death_4",
        "lightsaber_death_12","lightsaber_death_14","lightsaber_death_21",
        "A_PlayerDeathAnim_Electric","A_PlayerDeathAnim_13","A_PlayerDeathAnim_14",
        "A_PlayerDeathAnim_20","A_PlayerDeathAnim_21"
    ];
    private _collapseAnims = [
        "long_death_front_in_1","long_death_front_in_2","long_death_front_in_3",
        "longDeath_front","death_neck_1","death_neck_2","death_neck_3"
    ];

    private _anim = if (isClass (configFile >> "CfgPatches" >> "WBK_MeleeMechanics")) then {
        selectRandom _spasmAnims
    } else {
        selectRandom _collapseAnims
    };

    [_unit, _anim] remoteExec ["switchMove", 0];
    [_unit, _anim] remoteExec ["playMove", 0];
};


PHEN_CS_fnc_isWarningValid = {
    private _unit = _this#0;

    private _isAlive = alive _unit;
    private _stress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
    private _isOver = _stress > PHEN_CS_StressMax;
    private _isActive = _unit getVariable ["PHEN_CS_OverclockWarningActive", false];

    (_isAlive && _isOver && _isActive)
};

// OVERCLOCK EVENT
PHEN_CS_fnc_doOverclockEvent = {
    params [["_unit", player]];

    if (!hasInterface) exitWith {};

    private _warnings = [
        "WARNING: NEURAL OVERLOAD IMMINENT - REDUCE CYBERNETIC LOAD",
        "WARNING: OVERCLOCK THRESHOLD EXCEEDED - SYSTEM CRITICAL",
        "WARNING: CYBERNETIC STRESS CRITICAL - REMOVE IMPLANTS NOW",
        "WARNING: COGNITIVE MATRIX DESTABILIZING - SEEK MEDICAL AID",
        "WARNING: BIONICS EXCEEDING SAFE PARAMETERS - SHUTDOWN ADVISED",
        "WARNING: SYSTEM FAILURE APPROACHING - EMERGENCY PROTOCOL ACTIVE"
    ];
    [_warnings, true] call CBA_fnc_shuffle;

    _soundOBJ3 = [_unit, "PHEN_CS_Texture_Virus_Detected_Alarm", 35, 22] call PHEN_CS_fnc_Say3D;
    [_unit, _soundOBJ3] spawn {
        params ["_unit", "_soundOBJ"];
        for "_i" from 0 to 20 do {
            private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
            if ((_currentStress <= PHEN_CS_StressMax) && (!(isNull _soundOBJ))) exitWith {
                deleteVehicle _soundOBJ;
            };
            sleep 1;
        };
    };

    private _display = findDisplay 46;

    // background glitch loop
    [] spawn {
        if (isNull (findDisplay 46)) exitWith {};
        private _display = findDisplay 46;
        private _frames = [
            "PHEN_Cybernetics\Data\CS_Overclock_Lite_01.paa",
            "PHEN_Cybernetics\Data\CS_Overclock_Lite_02.paa",
            "PHEN_Cybernetics\Data\CS_Overclock_Lite_03.paa"
        ];
        private _bgCtrl = _display ctrlCreate ["RscPicture", -1];
        _bgCtrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
        _bgCtrl ctrlSetTextColor [1, 0.2, 0.2, 0];
        _bgCtrl ctrlCommit 0;

        while {player getVariable ["PHEN_CS_OverclockWarningActive", false]} do {
            private _randomFrame   = _frames # (floor (random 3));
            private _jitterX       = safeZoneX + (random 0.008) - 0.004;
            private _jitterY       = safeZoneY + (random 0.008) - 0.004;
            private _randomAlpha   = 0.18 + random 0.22;    // 0.18 - 0.40
            _bgCtrl ctrlSetText _randomFrame;
            _bgCtrl ctrlSetPosition [_jitterX, _jitterY, safeZoneW, safeZoneH];
            _bgCtrl ctrlSetTextColor [1, 0.15, 0.15, _randomAlpha];
            _bgCtrl ctrlCommit 0;
            uiSleep (0.10 + random 0.30);    // faster flicker
        };

        _bgCtrl ctrlSetTextColor [1, 1, 1, 0];
        _bgCtrl ctrlCommit _animDuration;
        uiSleep 0.2;
        ctrlDelete _bgCtrl;
    };

    // PP loop
    [_unit] spawn {
        _unit = _this select 0;
        if (!hasInterface) exitWith {};
        // priorities 1745-1746, below consequence hit (1750-1753)
        private _chromAberration = ppEffectCreate ["ChromAberration", 225];
        private _filmGrain       = ppEffectCreate ["FilmGrain",       2322];
        _chromAberration ppEffectEnable true;
        _filmGrain       ppEffectEnable true;

        // Start zeroed
        _chromAberration ppEffectAdjust [0, 0, 0];          _chromAberration ppEffectCommit 0;
        _filmGrain       ppEffectAdjust [0, 0, 1.1, 0, 1];  _filmGrain       ppEffectCommit 0;

        while {
            private _stress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
            private _active = _unit getVariable ["PHEN_CS_OverclockWarningActive", false];
            (_active && (_stress > PHEN_CS_StressMax))
        } do {
            private _caStrength  = 0.08 + random 0.12;    // 0.08 - 0.20, edge-concentrated
            private _grainAmount = 0.40 + random 0.35;    // 0.40 - 0.75
            _chromAberration ppEffectAdjust [_caStrength, _caStrength, true];
            _chromAberration ppEffectCommit 0;
            _filmGrain ppEffectAdjust [0.18 + random 0.15, 0.05 + random 0.04, 2.5, _grainAmount, 1];
            _filmGrain ppEffectCommit 0;
            uiSleep (0.15 + random 0.35);   // hold briefly at peak

            // ease down
            private _transTimeDn = 0.25 + random 0.40;
            _chromAberration ppEffectAdjust [0.004, 0.004, true];
            _chromAberration ppEffectCommit _transTimeDn;
            _filmGrain ppEffectAdjust [0.06, 0.02, 1.5, 0.12, 1];
            _filmGrain ppEffectCommit _transTimeDn;
            uiSleep (_transTimeDn + 0.05 + random 0.30);
        };

        // Clean up
        _chromAberration ppEffectAdjust [0, 0, 0];          _chromAberration ppEffectCommit 0.5;
        _filmGrain       ppEffectAdjust [0, 0, 1.1, 0, 1];  _filmGrain       ppEffectCommit 0.5;
        uiSleep 0.6;
        ppEffectDestroy _chromAberration;
        ppEffectDestroy _filmGrain;
    };

    // warning text
    private _textCtrl = _display ctrlCreate ["RscStructuredText", -1];
    _textCtrl ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH * 0.44, safeZoneW, safeZoneH * 0.07];
    _textCtrl ctrlSetTextColor [1, 0.05, 0.05, 0];
    _textCtrl ctrlCommit 0;

    // ~3.5s per warning, 21s total
    {
        private _valid = [_unit] call PHEN_CS_fnc_isWarningValid;
        if (!_valid) exitWith {};

        _textCtrl ctrlSetStructuredText parseText format [
            "<t align='center' font='LCD14' size='1.3' shadow='2'>%1</t>", _x
        ];

        _textCtrl ctrlSetTextColor [1, 0.05, 0.05, 1.0];
        _textCtrl ctrlCommit 0;

        uiSleep 1.7;

        _valid = [_unit] call PHEN_CS_fnc_isWarningValid;
        if (!_valid) exitWith {};

        _textCtrl ctrlSetTextColor [1, 0.05, 0.05, 0.25];
        _textCtrl ctrlCommit 0.35;

        uiSleep 1.5;

    } forEach _warnings;

    if (!([_unit] call PHEN_CS_fnc_isWarningValid)) exitWith {
        _textCtrl ctrlSetTextColor [1, 0.05, 0.05, 0];
        _textCtrl ctrlCommit 0.2;
        uiSleep 0.2;
        ctrlDelete _textCtrl;

        _unit setVariable ["PHEN_CS_OverclockWarningActive", false, false];
    };

    // fade + remove
    _textCtrl ctrlSetTextColor [1, 0.05, 0.05, 0];
    _textCtrl ctrlCommit 0.3;
    uiSleep 0.3;
    ctrlDelete _textCtrl;

    private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];
    if (_currentStress <= PHEN_CS_StressMax) exitWith {
        _unit setVariable ["PHEN_CS_OverclockWarningActive", false, false];
    };

    // still over, consequence
    if (!(alive _unit)) exitWith { _unit setVariable ["PHEN_CS_OverclockWarningActive", false, false]; };
    if (lifeState _unit == "INCAPACITATED") exitWith { _unit setVariable ["PHEN_CS_OverclockWarningActive", false, false]; };

    [] spawn PHEN_CS_fnc_showOverclockGlitch;

    [_unit] call PHEN_CS_fnc_overclockAnim;
    _unit spawn {
        _unit = _this;
        for "_i" from 1 to 5 do { 
            private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];

            if ((random 1 > 0.5) && (_currentStress >= PHEN_CS_StressMax)) then { 
                [_unit] remoteExec ["PHEN_CS_fnc_singleSparkRandomAttach", ([0, -2] select isDedicated), false];
                uiSleep (random 2);
            }; 
        };
    };
    
    uiSleep 0.7;

    if (PHEN_CS_OverclockKills) then {
        playSoundUI ["PHEN_CS_SomeOverclockImpactSound", (0.5 + random 0.5), (0.85 + random 0.3)];
        _unit setDamage 1;
        _unit spawn {
            _unit = _this;
            for "_i" from 1 to 10 do { 
                private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];

                if (random 1 > 0.5) then { 
                    [_unit] remoteExec ["PHEN_CS_fnc_singleSparkRandomAttach", ([0, -2] select isDedicated), false];
                    uiSleep (random 1);
                }; 
            };
            uiSleep 5;
            for "_i" from 1 to 10 do { 
                private _currentStress = _unit getVariable ["PHEN_CS_stressPenaltyModifier", 0];

                if (random 1 > 0.5) then { 
                    [_unit] remoteExec ["PHEN_CS_fnc_singleSparkRandomAttach", ([0, -2] select isDedicated), false];
                    uiSleep (random 1);
                }; 
            };
        };
    } else {
        if (PHEN_CS_HasACEMedical) then {
            [_unit, true, 5, true] call ace_medical_fnc_setUnconscious;
        } else {
            _unit setUnconscious true;
            [_unit] spawn { params ["_unit"]; uiSleep 5; _unit setUnconscious false; };
        };
    };

    _unit setVariable ["PHEN_CS_OverclockWarningActive", false, false];
};

PHEN_CS_fnc_createSparkLight = { 
    private _source = _this; 
 
    if (isNull _source) exitWith {}; 
 
    // create light 
    private _pos = getPosATL _source; 
    private _light = "#lightpoint" createVehicleLocal _pos; 
 
    _light setLightAmbient [1,1,1]; 
    _light setLightColor [1,1,1]; 
    _light setLightBrightness 0; 
 
    _light attachTo [_source, [0,0,0]]; 
 
    // fade in/out
    private _step = 0.1; 
    private _sleep = 0.01; 
 
    private _brightness = 0; 
    private _direction = 1; 
 
    while {true} do { 
 
        _light setLightBrightness _brightness; 
 
        _brightness = _brightness + (_step * _direction); 
 
        private _reachedMax = _brightness >= (0.75 + (random 1.25)); // 0.4 - 1.0 max brightness
        private _reachedMin = _brightness <= 0; 
 
        if (_reachedMax) then { 
            _brightness = 1; 
            _direction = -1; 
        }; 
 
        if (_reachedMin && {_direction < 0}) exitWith {}; 
 
        uiSleep _sleep; 
    }; 
 
    deleteVehicle _light; 
};

// example usage, attach a spark to the unit (only clients or SP depending on context)
//[_unit] remoteExec ["PHEN_CS_fnc_singleSparkRandomAttach",([0, -2] select isDedicated), false];
PHEN_CS_fnc_singleSparkRandomAttach = { 
    private _unit = _this select 0; 
 
    if (isNull _unit) exitWith {}; 
 
    // attachment selection 
    private _selections = ["head", "neck"]; 
    private _selection = selectRandom _selections; 
 
    private _offsetHead = [0, 0, 0.08]; 
    private _offsetNeck = [0, 0, 0.02]; 
 
    private _offset = _offsetHead; 
    if (_selection isEqualTo "neck") then { 
        _offset = _offsetNeck; 
    }; 
 
    // helper object
    private _helper = "Logic" createVehicleLocal [0,0,0]; 
    _helper attachTo [_unit, _offset, _selection, true]; 
 
    // particle source 
    private _helperPos = getPosATL _helper; 
    private _ps = "#particlesource" createVehicleLocal _helperPos; 
    _ps attachTo [_helper, [0,0,0]]; 
 
    private _randomPos = [0.02, 0.02, 0.05]; 
    private _randomVel = [2, 2, 1.5]; 
 
    _ps setParticleCircle [0, [0, 0, 0]]; 
    _ps setParticleRandom [0.5, _randomPos, _randomVel, 0, 0.002, [0,0,0,0], 0, 0]; 
 
    private _shape = "\A3\data_f\proxies\muzzle_flash\muzzle_flash_silencer.p3d"; 
    private _lifeTime = 0.7 + (random 1); 
    private _position = [0,0,0]; 
    private _moveVelocity = [0,0,0]; 
    private _rotationVel = 0; 
    private _weight = 15; 
    private _volume = 7; 
    private _rubbing = 0; 
 
    private _size = [0.15, 0.1, 0.02]; 
    private _color = [[1,1,1,1],[1,1,1,0.7],[1,1,1,0]]; 
    private _animSpeed = [0.05]; 
 
    _ps setParticleParams [ 
        [_shape, 1, 0, 1], 
        "", 
        "SpaceObject", 
        1, 
        _lifeTime, 
        _position, 
        _moveVelocity, 
        _rotationVel, 
        _weight, 
        _volume, 
        _rubbing, 
        _size, 
        _color, 
        _animSpeed, 
        1, 
        0, 
        "", 
        "", 
        _ps, 
        0, 
        true, 
        0.2, 
        [[0,0,0,0]] 
    ]; 
 
    _ps setDropInterval 0.01; 
 
    // optional subtle sound 
    // private _sounds = ["PHEN_Local_spark1","PHEN_Local_spark2","PHEN_Local_spark3"]; 
    // private _sound = selectRandom _sounds; 
    // _unit say3D [_sound, 20]; 
 
    _ps spawn PHEN_CS_fnc_createSparkLight; 
 
    // short lifetime 
    private _delay = 0.35; 
    private _timeStart = time; 
    private _timeNow = time; 
    private _elapsed = 0; 
 
    while {true} do { 
        _timeNow = time; 
        _elapsed = _timeNow - _timeStart; 
 
        if (_elapsed >= _delay) exitWith {}; 
        sleep 0.01; 
    }; 
 
    deleteVehicle _ps; 
    deleteVehicle _helper; 
};

/*

    //ACE stuff for speed compat?
    if (missionnamespace getvariable "ace_advanced_fatigue_enabled") then {
		oldPerformanceFactor = ace_advanced_fatigue_performanceFactor;
		oldRecoveryFactor = ace_advanced_fatigue_recoveryFactor;
	};

    //apply stuff
    if (missionnamespace getvariable "ace_advanced_fatigue_enabled") then {
        ace_advanced_fatigue_performanceFactor = 500;
        ace_advanced_fatigue_recoveryFactor = 500;
    };

*/


PHEN_CS_fnc_GenerateMasterList = {

    PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0 = [
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Name,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0_Effects
    ];

    PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1 = [
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Name,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1_Effects
    ];

    PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2 = [
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Name,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_OCULAR_ITEM_0 = [
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Name,
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_OCULAR_ITEM_0_Effects
    ];

    PHEN_CS_Cybernetic_OCULAR_ITEM_1 = [
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Name,
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_OCULAR_ITEM_1_Effects
    ];

    PHEN_CS_Cybernetic_OCULAR_ITEM_2 = [
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Name,
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_OCULAR_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0 = [
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Name,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0_Effects
    ];


    PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1 = [
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Name,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1_Effects
    ];

    PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2 = [
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Name,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_IMMUNE_ITEM_0 = [
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Name,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_IMMUNE_ITEM_1 = [
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Name,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_IMMUNE_ITEM_2 = [
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Name,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_IMMUNE_ITEM_2_Effects
    ];


    PHEN_CS_Cybernetic_NERVOUS_ITEM_0 = [
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Name,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_NERVOUS_ITEM_1 = [
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Name,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_NERVOUS_ITEM_2 = [
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Name,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_NERVOUS_ITEM_2_Effects
    ];
    PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0 = [
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Name,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0_Effects
    ];

    PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1 = [
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Name,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2 = [
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Name,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2_Effects
    ];
    PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0 = [
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Name,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1 = [
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Name,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2 = [
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Name,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_SKELETON_ITEM_0 = [
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Name,
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_SKELETON_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_SKELETON_ITEM_1 = [
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Name,
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_SKELETON_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_SKELETON_ITEM_2 = [
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Name,
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_SKELETON_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_HANDS_ITEM_0 = [
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Name,
        PHEN_CS_Cybernetic_HANDS_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_HANDS_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_HANDS_ITEM_1 = [
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Name,
        PHEN_CS_Cybernetic_HANDS_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_HANDS_ITEM_1_Effects
    ];

    PHEN_CS_Cybernetic_HANDS_ITEM_2 = [
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Name,
        PHEN_CS_Cybernetic_HANDS_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_HANDS_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_ARMS_ITEM_0 = [
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Name,
        PHEN_CS_Cybernetic_ARMS_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_ARMS_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_ARMS_ITEM_1 = [
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Name,
        PHEN_CS_Cybernetic_ARMS_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_ARMS_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_ARMS_ITEM_2 = [
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Name,
        PHEN_CS_Cybernetic_ARMS_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_ARMS_ITEM_2_Effects
    ];

    PHEN_CS_Cybernetic_LEGS_ITEM_0 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_0_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_0_Effects
    ];
    PHEN_CS_Cybernetic_LEGS_ITEM_1 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_1_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_1_Effects
    ];
    PHEN_CS_Cybernetic_LEGS_ITEM_2 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_2_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_2_Effects
    ];
    PHEN_CS_Cybernetic_LEGS_ITEM_3 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_3_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_3_Effects
    ];
    PHEN_CS_Cybernetic_LEGS_ITEM_4 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_4_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_4_Effects
    ];
    PHEN_CS_Cybernetic_LEGS_ITEM_5 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_5_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_5_Effects
    ];

    PHEN_CS_Cybernetic_LEGS_ITEM_6 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_6_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_6_Effects
    ];


    PHEN_CS_Cybernetic_LEGS_ITEM_7 = [
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Name,
        PHEN_CS_Cybernetic_LEGS_ITEM_7_PicturePath,
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Tooltip,
        PHEN_CS_Cybernetic_LEGS_ITEM_7_Effects
    ];

    PHEN_CS_Cybernetic_MasterList = [

        // FULL ITEM ARRAYS
        [
            PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0,
            PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1,
            PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2,

            PHEN_CS_Cybernetic_OCULAR_ITEM_0,
            PHEN_CS_Cybernetic_OCULAR_ITEM_1,
            PHEN_CS_Cybernetic_OCULAR_ITEM_2,

            PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0,
            PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1,
            PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2,

            PHEN_CS_Cybernetic_IMMUNE_ITEM_0,
            PHEN_CS_Cybernetic_IMMUNE_ITEM_1,
            PHEN_CS_Cybernetic_IMMUNE_ITEM_2,

            PHEN_CS_Cybernetic_NERVOUS_ITEM_0,
            PHEN_CS_Cybernetic_NERVOUS_ITEM_1,
            PHEN_CS_Cybernetic_NERVOUS_ITEM_2,

            PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0,
            PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1,
            PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2,

            PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0,
            PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1,
            PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2,

            PHEN_CS_Cybernetic_SKELETON_ITEM_0,
            PHEN_CS_Cybernetic_SKELETON_ITEM_1,
            PHEN_CS_Cybernetic_SKELETON_ITEM_2,

            PHEN_CS_Cybernetic_HANDS_ITEM_0,
            PHEN_CS_Cybernetic_HANDS_ITEM_1,
            PHEN_CS_Cybernetic_HANDS_ITEM_2,

            PHEN_CS_Cybernetic_ARMS_ITEM_0,
            PHEN_CS_Cybernetic_ARMS_ITEM_1,
            PHEN_CS_Cybernetic_ARMS_ITEM_2,

            PHEN_CS_Cybernetic_LEGS_ITEM_0,
            PHEN_CS_Cybernetic_LEGS_ITEM_1,
            PHEN_CS_Cybernetic_LEGS_ITEM_2,
            PHEN_CS_Cybernetic_LEGS_ITEM_3,
            PHEN_CS_Cybernetic_LEGS_ITEM_4,
            PHEN_CS_Cybernetic_LEGS_ITEM_5,
            PHEN_CS_Cybernetic_LEGS_ITEM_6,
            PHEN_CS_Cybernetic_LEGS_ITEM_7
        ],

        // ZEN DISPLAY
        // name, tooltip, picture, iconColor
        [
            // FRONTAL CORTEX
            [PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0#0, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0#2, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1#0, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1#2, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2#0, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2#2, PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2#1, [255,255,255,255]],

            // OCULAR
            [PHEN_CS_Cybernetic_OCULAR_ITEM_0#0, PHEN_CS_Cybernetic_OCULAR_ITEM_0#2, PHEN_CS_Cybernetic_OCULAR_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_OCULAR_ITEM_1#0, PHEN_CS_Cybernetic_OCULAR_ITEM_1#2, PHEN_CS_Cybernetic_OCULAR_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_OCULAR_ITEM_2#0, PHEN_CS_Cybernetic_OCULAR_ITEM_2#2, PHEN_CS_Cybernetic_OCULAR_ITEM_2#1, [255,255,255,255]],

            // CIRCULATORY
            [PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0#0, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0#2, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1#0, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1#2, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2#0, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2#2, PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2#1, [255,255,255,255]],

            // IMMUNE
            [PHEN_CS_Cybernetic_IMMUNE_ITEM_0#0, PHEN_CS_Cybernetic_IMMUNE_ITEM_0#2, PHEN_CS_Cybernetic_IMMUNE_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_IMMUNE_ITEM_1#0, PHEN_CS_Cybernetic_IMMUNE_ITEM_1#2, PHEN_CS_Cybernetic_IMMUNE_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_IMMUNE_ITEM_2#0, PHEN_CS_Cybernetic_IMMUNE_ITEM_2#2, PHEN_CS_Cybernetic_IMMUNE_ITEM_2#1, [255,255,255,255]],

            // NERVOUS
            [PHEN_CS_Cybernetic_NERVOUS_ITEM_0#0, PHEN_CS_Cybernetic_NERVOUS_ITEM_0#2, PHEN_CS_Cybernetic_NERVOUS_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_NERVOUS_ITEM_1#0, PHEN_CS_Cybernetic_NERVOUS_ITEM_1#2, PHEN_CS_Cybernetic_NERVOUS_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_NERVOUS_ITEM_2#0, PHEN_CS_Cybernetic_NERVOUS_ITEM_2#2, PHEN_CS_Cybernetic_NERVOUS_ITEM_2#1, [255,255,255,255]],

            // INTEGUMENTARY
            [PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0#0, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0#2, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1#0, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1#2, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2#0, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2#2, PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2#1, [255,255,255,255]],

            // OPERATING SYSTEM
            [PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0#0, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0#2, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1#0, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1#2, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2#0, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2#2, PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2#1, [255,255,255,255]],

            // SKELETON
            [PHEN_CS_Cybernetic_SKELETON_ITEM_0#0, PHEN_CS_Cybernetic_SKELETON_ITEM_0#2, PHEN_CS_Cybernetic_SKELETON_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_SKELETON_ITEM_1#0, PHEN_CS_Cybernetic_SKELETON_ITEM_1#2, PHEN_CS_Cybernetic_SKELETON_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_SKELETON_ITEM_2#0, PHEN_CS_Cybernetic_SKELETON_ITEM_2#2, PHEN_CS_Cybernetic_SKELETON_ITEM_2#1, [255,255,255,255]],

            // HANDS
            [PHEN_CS_Cybernetic_HANDS_ITEM_0#0, PHEN_CS_Cybernetic_HANDS_ITEM_0#2, PHEN_CS_Cybernetic_HANDS_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_HANDS_ITEM_1#0, PHEN_CS_Cybernetic_HANDS_ITEM_1#2, PHEN_CS_Cybernetic_HANDS_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_HANDS_ITEM_2#0, PHEN_CS_Cybernetic_HANDS_ITEM_2#2, PHEN_CS_Cybernetic_HANDS_ITEM_2#1, [255,255,255,255]],

            // ARMS
            [PHEN_CS_Cybernetic_ARMS_ITEM_0#0, PHEN_CS_Cybernetic_ARMS_ITEM_0#2, PHEN_CS_Cybernetic_ARMS_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_ARMS_ITEM_1#0, PHEN_CS_Cybernetic_ARMS_ITEM_1#2, PHEN_CS_Cybernetic_ARMS_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_ARMS_ITEM_2#0, PHEN_CS_Cybernetic_ARMS_ITEM_2#2, PHEN_CS_Cybernetic_ARMS_ITEM_2#1, [255,255,255,255]],

            // LEGS
            [PHEN_CS_Cybernetic_LEGS_ITEM_0#0, PHEN_CS_Cybernetic_LEGS_ITEM_0#2, PHEN_CS_Cybernetic_LEGS_ITEM_0#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_1#0, PHEN_CS_Cybernetic_LEGS_ITEM_1#2, PHEN_CS_Cybernetic_LEGS_ITEM_1#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_2#0, PHEN_CS_Cybernetic_LEGS_ITEM_2#2, PHEN_CS_Cybernetic_LEGS_ITEM_2#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_3#0, PHEN_CS_Cybernetic_LEGS_ITEM_3#2, PHEN_CS_Cybernetic_LEGS_ITEM_3#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_4#0, PHEN_CS_Cybernetic_LEGS_ITEM_4#2, PHEN_CS_Cybernetic_LEGS_ITEM_4#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_5#0, PHEN_CS_Cybernetic_LEGS_ITEM_5#2, PHEN_CS_Cybernetic_LEGS_ITEM_5#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_6#0, PHEN_CS_Cybernetic_LEGS_ITEM_6#2, PHEN_CS_Cybernetic_LEGS_ITEM_6#1, [255,255,255,255]],
            [PHEN_CS_Cybernetic_LEGS_ITEM_7#0, PHEN_CS_Cybernetic_LEGS_ITEM_7#2, PHEN_CS_Cybernetic_LEGS_ITEM_7#1, [255,255,255,255]]

        ],

        // DEFAULT INDEX
        0
    ];

    PHEN_CS_Cybernetic_ItemIDs = [
        "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_0",
        "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_1",
        "PHEN_CS_Cybernetic_FRONTALCORTEX_ITEM_2",
        "PHEN_CS_Cybernetic_OCULAR_ITEM_0",
        "PHEN_CS_Cybernetic_OCULAR_ITEM_1",
        "PHEN_CS_Cybernetic_OCULAR_ITEM_2",
        "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_0",
        "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_1",
        "PHEN_CS_Cybernetic_CIRCULATORY_ITEM_2",
        "PHEN_CS_Cybernetic_IMMUNE_ITEM_0",
        "PHEN_CS_Cybernetic_IMMUNE_ITEM_1",
        "PHEN_CS_Cybernetic_IMMUNE_ITEM_2",
        "PHEN_CS_Cybernetic_NERVOUS_ITEM_0",
        "PHEN_CS_Cybernetic_NERVOUS_ITEM_1",
        "PHEN_CS_Cybernetic_NERVOUS_ITEM_2",
        "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_0",
        "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_1",
        "PHEN_CS_Cybernetic_INTEGUMENTARY_ITEM_2",
        "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_0",
        "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_1",
        "PHEN_CS_Cybernetic_OPERATINGSYSTEM_ITEM_2",
        "PHEN_CS_Cybernetic_SKELETON_ITEM_0",
        "PHEN_CS_Cybernetic_SKELETON_ITEM_1",
        "PHEN_CS_Cybernetic_SKELETON_ITEM_2",
        "PHEN_CS_Cybernetic_HANDS_ITEM_0",
        "PHEN_CS_Cybernetic_HANDS_ITEM_1",
        "PHEN_CS_Cybernetic_HANDS_ITEM_2",
        "PHEN_CS_Cybernetic_ARMS_ITEM_0",
        "PHEN_CS_Cybernetic_ARMS_ITEM_1",
        "PHEN_CS_Cybernetic_ARMS_ITEM_2",
        "PHEN_CS_Cybernetic_LEGS_ITEM_0",
        "PHEN_CS_Cybernetic_LEGS_ITEM_1",
        "PHEN_CS_Cybernetic_LEGS_ITEM_2",
        "PHEN_CS_Cybernetic_LEGS_ITEM_3",
        "PHEN_CS_Cybernetic_LEGS_ITEM_4",
        "PHEN_CS_Cybernetic_LEGS_ITEM_5",
        "PHEN_CS_Cybernetic_LEGS_ITEM_6",
        "PHEN_CS_Cybernetic_LEGS_ITEM_7"
    ];

    publicVariable "PHEN_CS_Cybernetic_MasterList";
    publicVariable "PHEN_CS_Cybernetic_ItemIDs";

    // full item list (first element of master list)
    PHEN_CS_Cybernetic_Items = PHEN_CS_Cybernetic_MasterList # 0;

};

PHEN_CS_fnc_normalizeRipperdocAccessList = {
    params [["_rawList", [], [[], ""]]];

    private _list = _rawList;
    if (_list isEqualType "") then {
        if (_list isEqualTo "") exitWith { [] };

        private _chars = toArray _list;
        if ((count _chars > 0) && { (_chars # 0) isEqualTo 91 }) then {
            _list = parseSimpleArray _list;
        } else {
            _list = [_list];
        };
    };

    if !(_list isEqualType []) exitWith { [] };

    private _normalized = [];
    {
        if (_x isEqualType "") then {
            private _value = toLower _x;
            if !(_value isEqualTo "") then {
                _normalized pushBackUnique _value;
            };
        };
    } forEach _list;

    _normalized
};

PHEN_CS_fnc_isRipperdocImplantAllowed = {
    params [
        ["_item", [], [[]]],
        ["_itemId", "", [""]],
        ["_mode", "all", [""]],
        ["_normalizedList", [], [[]]]
    ];

    if !(_mode in ["whitelist", "blacklist"]) exitWith { true };

    private _name = "";
    if ((count _item) > 0 && { (_item # 0) isEqualType "" }) then {
        _name = toLower (_item # 0);
    };

    private _id = toLower _itemId;
    private _listed = (_id in _normalizedList) || { _name in _normalizedList };

    if (_mode isEqualTo "whitelist") exitWith { _listed };
    if (_mode isEqualTo "blacklist") exitWith { !_listed };

    true
};

PHEN_CS_fnc_GetRipperdocCyberneticMasterList = {
    params [
        ["_source", objNull, [objNull]],
        ["_fallbackMode", "all", [""]],
        ["_fallbackList", [], [[], ""]]
    ];

    private _mode = _fallbackMode;
    private _list = _fallbackList;

    if !(isNull _source) then {
        _mode = _source getVariable ["PHEN_CS_RipperdocAccessMode", _mode];
        _list = _source getVariable ["PHEN_CS_RipperdocAccessList", _list];

        private _allowedList = _source getVariable ["PHEN_CS_RipperdocAllowedList", []];
        private _deniedList = _source getVariable ["PHEN_CS_RipperdocDeniedList", []];

        if !(_allowedList isEqualTo []) then {
            _mode = "whitelist";
            _list = _allowedList;
        };

        if !(_deniedList isEqualTo []) then {
            _mode = "blacklist";
            _list = _deniedList;
        };
    };

    if !(_mode isEqualType "") exitWith { PHEN_CS_Cybernetic_MasterList };

    _mode = toLower _mode;
    if !(_mode in ["whitelist", "blacklist"]) exitWith { PHEN_CS_Cybernetic_MasterList };

    private _normalizedList = [_list] call PHEN_CS_fnc_normalizeRipperdocAccessList;
    if ((_mode isEqualTo "blacklist") && { _normalizedList isEqualTo [] }) exitWith { PHEN_CS_Cybernetic_MasterList };

    private _masterItems = PHEN_CS_Cybernetic_MasterList # 0;
    private _masterRows = PHEN_CS_Cybernetic_MasterList # 1;
    private _itemIds = missionNamespace getVariable ["PHEN_CS_Cybernetic_ItemIDs", []];

    private _items = [];
    private _rows = [];

    for "_i" from 0 to ((count _masterItems) - 1) do {
        private _item = _masterItems # _i;
        private _row = _masterRows # _i;
        private _itemId = if (_i < (count _itemIds)) then { _itemIds # _i } else { "" };

        if ([_item, _itemId, _mode, _normalizedList] call PHEN_CS_fnc_isRipperdocImplantAllowed) then {
            _items pushBack _item;
            _rows pushBack _row;
        };
    };

    [
        _items,
        _rows,
        0
    ]
};

PHEN_CS_fnc_ZEN_GetPlayerCurrentCybernetics = {
    params ["_unit"];

    private _items = [];   // will mirror MasterList #0 but ONLY installed 
    private _rows  = [];   // will mirror MasterList #1 but only installed 

    private _data = [_unit] call PHEN_CS_fnc_getOrInitCyberData;

    {
        private _cat = _x;

        {
            private _slot = _x;

            // Skip empty / corrupted
            if (_slot isEqualTo [] || {count _slot < 3}) then { continue };

            private _name    = _slot # 0;
            private _picture = _slot # 1;
            private _tooltip = _slot # 2;

            // Avoid duplicates if same cybernetic is installed in multiple slots
            if !(_slot in _items) then {
                _items pushBack _slot;
                _rows pushBack [
                    _name,        // text / label
                    _tooltip,     // tooltip / description
                    _picture,     // picture path
                    [255,255,255,255]  // color (matches your MasterList style)
                ];
            };

        } forEach _cat;

    } forEach _data;

    // needed foramtting:
    // [ itemsArray, rowsArray, defaultIndex ]
    [
        _items,
        _rows,
        0
    ]
};

PHEN_CS_fnc_AddTerminalActions = {
    params [
        ["_object", objNull],
        ["_ImplantAction", true],
        ["_RemoveAction", true],
        ["_accessMode", "all"],
        ["_accessList", []],
        ["_allowedList", []],
        ["_deniedList", []]
    ];

    if !(isNull _object) then {
        _accessMode = _object getVariable ["PHEN_CS_RipperdocAccessMode", _accessMode];
        _accessList = _object getVariable ["PHEN_CS_RipperdocAccessList", _accessList];
        _allowedList = _object getVariable ["PHEN_CS_RipperdocAllowedList", _allowedList];
        _deniedList = _object getVariable ["PHEN_CS_RipperdocDeniedList", _deniedList];

        if !(_allowedList isEqualTo []) then {
            _accessMode = "whitelist";
            _accessList = _allowedList;
        };

        if !(_deniedList isEqualTo []) then {
            _accessMode = "blacklist";
            _accessList = _deniedList;
        };

        _object setVariable ["PHEN_CS_RipperdocAccessMode", _accessMode, true];
        _object setVariable ["PHEN_CS_RipperdocAccessList", _accessList, true];
        _object setVariable ["PHEN_CS_RipperdocAllowedList", _allowedList, true];
        _object setVariable ["PHEN_CS_RipperdocDeniedList", _deniedList, true];
    };

    [[_object, _ImplantAction, _RemoveAction, _accessMode, _accessList, _allowedList, _deniedList], {
        params [
            ["_object", objNull],
            ["_ImplantAction", true],
            ["_RemoveAction", true],
            ["_accessMode", "all"],
            ["_accessList", []],
            ["_allowedList", []],
            ["_deniedList", []]
        ];

        if !(isNull _object) then {
            _object setVariable ["PHEN_CS_RipperdocAccessMode", _accessMode, false];
            _object setVariable ["PHEN_CS_RipperdocAccessList", _accessList, false];
            _object setVariable ["PHEN_CS_RipperdocAllowedList", _allowedList, false];
            _object setVariable ["PHEN_CS_RipperdocDeniedList", _deniedList, false];
        };

        // helper to get a valid empty-structured save array
        private _fnc_getOrInitCyberData = {
            params ["_unit"];

            private _data = _unit getVariable ["My_CS_CyberneticsSaveData", []];

            // if not set or malformed, reset to empty structure
            if (
                !(_data isEqualType [])
                || _data isEqualTo []
                || {count _data != 11}
            ) then {
                _data = [
                    // 0 Frontal Cortex (3 slots)
                    [[], [], []],

                    // 1 Ocular System (1 slot)
                    [[]],

                    // 2 Circulatory System (3 slots)
                    [[], [], []],

                    // 3 Immune System (2 slots)
                    [[], []],

                    // 4 Nervous System (2 slots)
                    [[], []],

                    // 5 Integumentary System (3 slots)
                    [[], [], []],

                    // 6 Operating System (1 slot)
                    [[]],

                    // 7 Skeleton (2 slots)
                    [[], []],

                    // 8 Hands (1 slot)
                    [[]],

                    // 9 Arms (1 slot)
                    [[]],

                    // 10 Legs (1 slot)
                    [[]]
                ];
            };

            _data
        };

       // IMPLANT ACTION
        if (_ImplantAction) then {
            if (isNil {_object getVariable "PHEN_CS_ImplanterActionID"}) then {
                private _ImplanterActionID = _object addAction [
                    format ["<img size='2'image='x\enh\addons\main\data\plus_ca.paa'/><t color='#FF00FF00' size='2' font='LCD14' align='left' shadow='2'>IMPLANT Cybernetics</t>", player],
                    {
                        params ["_target", "_caller", "_actionId", "_args"];

                        private _ripperdocList = [_target] call PHEN_CS_fnc_GetRipperdocCyberneticMasterList;
                        if ((_ripperdocList # 0) isEqualTo []) exitWith {
                            hintSilent parseText "<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t size='0.9' color='#aaaaaa'>This Ripperdoc has no cybernetics available.</t>";
                        };

                        [
                            "Implant Cybernetics",
                            [
                                ["COMBO", ["Cybernetics", "Select the Cybernetics to implant into yourself"], _ripperdocList]
                            ],
                            {
                                params ["_values", "_args"];
                                _values params ["_implant"];   // full item array from MasterList
                                _args params ["_unit"];        // the action user

                                private _ok = [_unit, _implant] call PHEN_CS_fnc_installCybernetic;

                                if (_ok isEqualTo true) then {
                                    hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Cybernetics Implanted</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t>", _implant # 0];
                                } else {
                                    hintSilent parseText (if (_ok isEqualTo 5) then { "<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t size='0.9' color='#aaaaaa'>All slots in this category are occupied.</t>" } else { format ["<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>Code %1, try rejoining or contact admin.</t>", _ok] });
                                };
                            },
                            {},
                            [_caller]  // pass caller to the dialog as _unit
                        ] call zen_dialog_fnc_create;
                    },
                    nil,        // arguments
                    100,        // priority
                    true,       // showWindow
                    true,       // hideOnUse
                    "",         // shortcut
                    "PHEN_CS_EnableBaseActions",     // condition
                    5,          // radius
                    false,      // unconscious
                    "",         // selection
                    ""          // memoryPoint
                ];
                _object setVariable ["PHEN_CS_ImplanterActionID", _ImplanterActionID, false];
            };
        };


        // REMOVE ACTION
        if (_RemoveAction) then {
            if (isNil {_object getVariable "PHEN_CS_removeActionID"}) then {
                private _removeActionID = _object addAction [
                    format ["<img size='2'image='x\enh\addons\main\data\minus_ca.paa'/><t color='#FFFF2626' size='2' font='LCD14' align='left' shadow='2'>REMOVE Cybernetics</t>", player],
                    {
                        params ["_target", "_caller", "_actionId", "_args"];

                        // Build a MasterList-style structure only for the caller's installed cybernetics
                        private _list = [_caller] call PHEN_CS_fnc_ZEN_GetPlayerCurrentCybernetics;

                        // _list format: [itemsArray, rowsArray, defaultIndex]
                        private _items = _list # 0;

                        if (_items isEqualTo []) exitWith {
                            [_caller, "You have no cybernetics installed."] call BIS_fnc_showCuratorFeedbackMessage;
                        };

                        [
                            "Remove Cybernetics",
                            [
                                // Only a COMBO for "your" cybernetics, no OWNERS
                                ["COMBO", ["Cybernetics", "Select the Cybernetics to remove from yourself"], _list]
                            ],
                            {
                                params ["_values", "_args"];
                                _values params ["_implant"];       // full item array selected in the COMBO
                                _args params ["_unit"];            // the caller

                                private _ok = [_unit, _implant] call PHEN_CS_fnc_removeCybernetic;
                                private _success = (_ok isEqualType true && {_ok});

                                if (_success isEqualTo true) then {
                                    playSoundUI ["PHEN_CS_UI_Touchscreen_Sweep", 0.85 + random 0.3, 0.9 + random 0.2];
                                    hintSilent parseText format ["<t size='0.85' color='#ff6644'>Cybernetics Removed</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t>", _implant # 0];
                                } else {
                                    hintSilent parseText "<t size='0.85' color='#ff6666'>Removal Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>Selected cybernetic is not installed on you.</t>";
                                };
                            },
                            {},
                            [_caller]  // pass the action user into the dialog handler
                        ] call zen_dialog_fnc_create;
                    },
                    nil,        // arguments
                    1,          // priority
                    true,       // showWindow
                    true,       // hideOnUse
                    "",         // shortcut
                    "PHEN_CS_EnableBaseActions",     // condition
                    5,          // radius
                    false,      // unconscious
                    "",         // selection
                    ""          // memoryPoint
                ];
                _object setVariable ["PHEN_CS_removeActionID", _removeActionID, false];
            };
        };

        // ACE interactions for the station object, clients only
        if (hasInterface && { "ace_interact_menu" in activatedAddons }) then {

            if (_ImplantAction) then {
                private _aceImplantAction = [
                    "PHEN_CS_Station_Implant",
                    "Implant Cybernetics",
                    "PHEN_Cybernetics\Data\RipperDoc_Add_ca.paa",
                    {
                        params ["_target", "_player", "_actionParams"];
                        private _ripperdocList = [_target] call PHEN_CS_fnc_GetRipperdocCyberneticMasterList;
                        if ((_ripperdocList # 0) isEqualTo []) exitWith {
                            hintSilent parseText "<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t size='0.9' color='#aaaaaa'>This Ripperdoc has no cybernetics available.</t>";
                        };

                        [
                            "Implant Cybernetics",
                            [
                                ["COMBO", ["Cybernetics", "Select the Cybernetics to implant into yourself"], _ripperdocList]
                            ],
                            {
                                params ["_values", "_args"];
                                _values params ["_implant"];
                                _args params ["_unit"];
                                private _ok = [_unit, _implant] call PHEN_CS_fnc_installCybernetic;

                                if (_ok isEqualTo true) then {
                                    hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Cybernetics Implanted</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t>", _implant # 0];
                                } else {
                                    hintSilent parseText (if (_ok isEqualTo 5) then { "<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t size='0.9' color='#aaaaaa'>All slots in this category are occupied.</t>" } else { format ["<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>Code %1, try rejoining or contact admin.</t>", _ok] });
                                };
                            },
                            {},
                            [_player]
                        ] call zen_dialog_fnc_create;
                    },
                    { PHEN_CS_EnableACEActions && { alive _player } && { vehicle _player isEqualTo _player } }
                ] call ace_interact_menu_fnc_createAction;

                [_object, 0, ["ACE_MainActions"], _aceImplantAction] call ace_interact_menu_fnc_addActionToObject;
            };

            if (_RemoveAction) then {
                private _aceRemoveAction = [
                    "PHEN_CS_Station_Remove",
                    "Remove Cybernetics",
                    "PHEN_Cybernetics\Data\RipperDoc_Remove_ca.paa",
                    {
                        params ["_target", "_player", "_actionParams"];
                        private _list = [_player] call PHEN_CS_fnc_ZEN_GetPlayerCurrentCybernetics;
                        private _items = _list # 0;
                        if (_items isEqualTo []) exitWith {
                            systemChat "You have no cybernetics installed.";
                        };
                        [
                            "Remove Cybernetics",
                            [
                                ["COMBO", ["Cybernetics", "Select the Cybernetics to remove from yourself"], _list]
                            ],
                            {
                                params ["_values", "_args"];
                                _values params ["_implant"];
                                _args params ["_unit"];
                                private _ok = [_unit, _implant] call PHEN_CS_fnc_removeCybernetic;
                                private _success = (_ok isEqualType true && {_ok});
                                if (_success isEqualTo true) then {
                                    playSoundUI ["PHEN_CS_UI_Touchscreen_Sweep", 0.85 + random 0.3, 0.9 + random 0.2];
                                    hintSilent parseText format ["<t size='0.85' color='#ff6644'>Cybernetics Removed</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t>", _implant # 0];
                                } else {
                                    hintSilent parseText "<t size='0.85' color='#ff6666'>Removal Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>Selected cybernetic is not installed on you.</t>";
                                };
                            },
                            {},
                            [_player]
                        ] call zen_dialog_fnc_create;
                    },
                    { PHEN_CS_EnableACEActions && { alive _player } && { vehicle _player isEqualTo _player } }
                ] call ace_interact_menu_fnc_createAction;

                [_object, 0, ["ACE_MainActions"], _aceRemoveAction] call ace_interact_menu_fnc_addActionToObject;
            };
        };
    }] remoteExec ["spawn", 0, true];
};

/// MOVEMENT \\\

PHEN_CS_fnc_applySmoothImpulse = {
    params ["_unit", "_vec", ["_steps", 4]];

    // Run locally on unit
    [_unit, _vec, _steps] remoteExec ["PHEN_CS_fnc_applySmoothImpulse_local", _unit];
};

PHEN_CS_fnc_applySmoothImpulse_local = {
    params ["_unit", "_vec", "_steps"];

    if (isNull _unit) exitWith {};
    if (!local _unit) exitWith {};     // safety

    private _x = _vec select 0;
    private _y = _vec select 1;
    private _z = _vec select 2;

    private _stepX = _x / _steps;
    private _stepY = _y / _steps;
    private _stepZ = _z / _steps;

    for "_i" from 1 to _steps do {
        // stop if invalid at some point
        if (!alive _unit || {vehicle _unit != _unit} || {lifeState _unit == "INCAPACITATED"}) exitWith {};

        _unit setVelocityModelSpace [_stepX, _stepY, _stepZ];

        uiSleep 0.01;   // smooth enough
    };
};

// CBA keybind Jump
[
    PHEN_CS_KEYBIND_CAT_MOVEMENT,                       // Stable CBA keybind registry category
    "PHEN_CS_JumpKey",                                 // Unique action ID
    [PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CYBER_JUMP"), PHEN_CS_L("STR_PHEN_CS_CBA_KEY_CYBER_JUMP_TT")], // [name, tooltip]

    {
        // On key down do jump function
        if (!(isNull findDisplay 49) || !(isNull findDisplay 312) || visibleMap) exitWith {};
        private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
        [_unit] call PHEN_CS_fnc_doJump;
    },

    {},                                                // KeyUp handler (unused)

    [57, [true, false, false]]                         // Default: Shift + Space (DIK 57)
] call CBA_fnc_addKeybind;


PHEN_CS_fnc_doJump = {
    params ["_unit"];

    // Safety: fallback to player / remote control
    if (isNil "_unit" || {isNull _unit}) then {
        _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    };
    if (isNull _unit) exitWith {};
    if (!alive _unit) exitWith {};
    if (lifeState _unit == "INCAPACITATED") exitWith {};
    if (!(vehicle _unit isEqualTo _unit)) exitWith {};
    if (unitIsUAV _unit) exitWith {};
    if (_unit getVariable ["PHEN_CS_Disabled", false]) exitWith {};

    // Needs jump cyberware
    if !(_unit getVariable ["PHEN_CS_Abillity_Jump", false]) exitWith {};

    // Only allow from ground
    if !(isTouchingGround _unit) exitWith {};

    // Cooldown check
    private _now       = time;
    private _cooldown  = missionNamespace getVariable ["PHEN_CS_JumpCooldown", 3];
    private _cooldown = round (((_cooldown - (_unit getVariable ['PHEN_CS_abilityCooldownModifier', 0])) min 999) max 0);
    private _lastUse   = _unit getVariable ["PHEN_CS_Jump_LastUse", -1000];

    if (_cooldown >= 0) then {
        private _elapsed   = _now - _lastUse;
        private _remaining = _cooldown - _elapsed;

        if (_elapsed < _cooldown) exitWith {
            private _remainingNUMBER = round ((_remaining min 999) max 0);
            hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Jump systems recharging</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1s</t>", _remainingNUMBER max 1];
            playSound "PHEN_CS_UI_Message_Bleep";
        };
    
        // Read jump power from CBA setting
        private _power = missionNamespace getVariable ["PHEN_CS_JumpPower", 10];
        if (_power <= 0) exitWith {};

        // Direction (small influence)
        private _dir = missionNamespace getVariable ["PHEN_CS_DashDir", "Forward"];

        // directional influence factor (tiny!)
        private _push = round (_power/3);  
        
        private _vec = switch (_dir) do {
            case "Back":  {[0, -_push, _power]};
            case "Left":  {[-_push, 0, _power]};
            case "Right": {[ _push, 0, _power]};
            default {      [0, _push, _power]};   // Forward (fallback)
        };

        // Apply jump
        private _rSound = selectRandom [
            "Jump_1",
            "Jump_2",
            "Jump_3"
        ];

        [_unit, _rSound, 10] call CBA_fnc_globalSay3d;

        [_unit, _vec, 5] call PHEN_CS_fnc_applySmoothImpulse;

        _unit setVariable ["PHEN_CS_IsJumpingOrDashing", true, false];
        _unit allowDamage false;
        [_unit] spawn {
            params ["_unit"];
            sleep 0.3;
            waitUntil { !alive _unit || isTouchingGround _unit };
            _unit setVariable ["PHEN_CS_IsJumpingOrDashing", false, false];
            _unit allowDamage true;
        };

        // Store cooldown
        _unit setVariable ["PHEN_CS_Jump_LastUse", _now];
    };
};


// CBA keybind Dash / AirDash - single unified bind so only one fires per press
[
    PHEN_CS_KEYBIND_CAT_MOVEMENT,
    "PHEN_CS_Dash_Key",
    [PHEN_CS_L("STR_PHEN_CS_CBA_KEY_DASH"), PHEN_CS_L("STR_PHEN_CS_CBA_KEY_DASH_TT")],
    {
        if (!(isNull findDisplay 49) || !(isNull findDisplay 312) || visibleMap) exitWith {};

        private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];

        // Skip if a cyber-jump just fired this frame (Shift+Space fires this bind too)
        private _jumpJustUsed = (time - (_unit getVariable ["PHEN_CS_Jump_LastUse", -1000])) < 0.1;
        if (_jumpJustUsed) exitWith {};

        if (isTouchingGround _unit) then {
            [_unit] call PHEN_CS_fnc_doDash;
        } else {
            [_unit] call PHEN_CS_fnc_doAirDash;
        };
    }, {}, [57, [false, false, false]] //default IMS dodge keybind
] call cba_fnc_addKeybind;  

PHEN_CS_fnc_doDash = {
    params ["_unit"];

    // Safety: fallback to RC unit / player
    if (isNil "_unit" || {isNull _unit}) then {
        _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    };
    if (isNull _unit) exitWith {};
    if (!alive _unit) exitWith {};
    if (lifeState _unit == "INCAPACITATED") exitWith {};
    if (!(vehicle _unit isEqualTo _unit)) exitWith {};          // no vehicles
    if (unitIsUAV _unit) exitWith {};                           // no UAVs
    if (_unit getVariable ["PHEN_CS_Disabled", false]) exitWith {};

    // Needs dash cyberware implantt
    if !(_unit getVariable ["PHEN_CS_Abillity_Dash", false]) exitWith {};

    // Grounded dash only (AirDash is separate ability)
    if !(isTouchingGround _unit) exitWith {};

    // no prone
    if (stance _unit == "PRONE") exitWith {};

    // Cooldown
    private _now      = time;
    private _cooldown = missionNamespace getVariable ["PHEN_CS_DashCooldown", 2];
    private _cooldown = round (((_cooldown - (_unit getVariable ['PHEN_CS_abilityCooldownModifier', 0])) min 999) max 0);
    private _lastUse  = _unit getVariable ["PHEN_CS_Dash_LastUse", -1000];

    if (_cooldown >= 0) then {
        private _elapsed   = _now - _lastUse;
        private _remaining = _cooldown - _elapsed;

        if (_elapsed < _cooldown) exitWith {
            private _remainingNUMBER = round ((_remaining min 999) max 0);
            if (_remainingNUMBER < 0) then { _remainingNUMBER = 0; };

            if (_unit isEqualTo player) then {
                hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Dash actuators recharging</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1s</t>", _remainingNUMBER max 1];
                playSound "PHEN_CS_UI_Message_Bleep";
            };

            // exit
        };

        // Direction from WASD handler
        // Reuse as generic movement direction
        private _dir = missionNamespace getVariable ["PHEN_CS_DashDir", "Forward"];

        // Power from CBA setting
        private _power = missionNamespace getVariable ["PHEN_CS_DashPower", 5];
        if (_power <= 0) exitWith {};

         private _HopNudge = (_power/5);

        // Direction -> impulse vector in model space
        private _impulse = switch (_dir) do {
            case "Back":  {[0, -_power, _HopNudge]};  // small bit up so it feels better
            case "Left":  {[-_power, 0, _HopNudge]};
            case "Right": {[ _power, 0, _HopNudge]};
            default {      [0, _power, _HopNudge]};   // Forward (fallback)
        };

        // Apply dash
        private _rSound = selectRandom [
            "Dash_1",
            "Dash_2",
            "Dash_3"
        ];

        [_unit, _rSound, 10] call CBA_fnc_globalSay3d;

        [_unit, _impulse, 5] call PHEN_CS_fnc_applySmoothImpulse;

        _unit setVariable ["PHEN_CS_IsJumpingOrDashing", true, false];
        _unit allowDamage false;
        [_unit] spawn {
            params ["_unit"];
            sleep 0.3;
            waitUntil { !alive _unit || isTouchingGround _unit };
            _unit setVariable ["PHEN_CS_IsJumpingOrDashing", false, false];
            _unit allowDamage true;
        };

        // Store last use for cooldown
        _unit setVariable ["PHEN_CS_Dash_LastUse", _now];
    };

};

// AirDash is dispatched from the unified PHEN_CS_Dash_Key bind above based on isTouchingGround
PHEN_CS_fnc_doAirDash = {
    params ["_unit"];

    // Safety: fallback to RC unit / player
    if (isNil "_unit" || {isNull _unit}) then {
        _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    };
    if (isNull _unit) exitWith {};
    if (!alive _unit) exitWith {};
    if (lifeState _unit == "INCAPACITATED") exitWith {};
    if (!(vehicle _unit isEqualTo _unit)) exitWith {};      // no vehicles
    if (unitIsUAV _unit) exitWith {};                       // no UAVs
    if (_unit getVariable ["PHEN_CS_Disabled", false]) exitWith {};

    // Needs AirDash cyberware
    if !(_unit getVariable ["PHEN_CS_Abillity_AirDash", false]) exitWith {};

    // AirDash only when NOT touching ground
    if (isTouchingGround _unit) exitWith {};

    // Optional: don’t allow when prone mid-fall (looks cursed)
    if (stance _unit == "PRONE") exitWith {};

    // Cooldown
    private _now      = time;
    private _cooldown = missionNamespace getVariable ["PHEN_CS_AirDashCooldown", 2.5];
    private _cooldown = round (((_cooldown - (_unit getVariable ['PHEN_CS_abilityCooldownModifier', 0])) min 999) max 0);
    private _lastUse  = _unit getVariable ["PHEN_CS_AirDash_LastUse", -1000];

    if (_cooldown >= 0) then {
        private _charges = _unit getVariable ["PHEN_CS_AirDash_ChargesLeft", 2];
        private _elapsed = _now - _lastUse;

        // Block only when all charges are spent AND cooldown hasn't elapsed
        if (_charges <= 0 && { _elapsed < _cooldown }) exitWith {
            private _remaining = _cooldown - _elapsed;
            private _remainingNUMBER = (round (_remaining min 999)) max 0;
            if (_unit isEqualTo player) then {
                hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Air-dash thrusters recharging</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1s</t>", _remainingNUMBER max 1];
                playSound "PHEN_CS_UI_Message_Bleep";
            };
        };

        // Cooldown expired mid-air with 0 charges, restore before consuming
        if (_charges <= 0) then {
            _charges = 2;
            _unit setVariable ["PHEN_CS_AirDash_ChargesLeft", 2];
        };

        // Consume a charge
        private _chargesAfter = _charges - 1;
        _unit setVariable ["PHEN_CS_AirDash_ChargesLeft", _chargesAfter];

        if (_unit isEqualTo player) then {
            hintSilent parseText format ["<t size='0.8' color='#aaaaaa'>Air-dash</t><br/><t font='EtelkaMonospacePro' size='0.75' color='#00ccff'>(%1/2)</t>", _chargesAfter];
        };

        // Direction from WASD handler
        private _dir = missionNamespace getVariable ["PHEN_CS_DashDir", "Forward"];

        // Power from CBA setting
        private _power = missionNamespace getVariable ["PHEN_CS_AirDashPower", 5];
        if (_power <= 0) exitWith {};

        private _stayinAirNudge = (_power/4);

        // Lower Z 'hop' thingy so it feels like a mid-air strafe, not a second jump
        private _impulse = switch (_dir) do {
            case "Back":  {[0, -_power, _stayinAirNudge]};
            case "Left":  {[-_power, 0, _stayinAirNudge]};
            case "Right": {[ _power, 0, _stayinAirNudge]};
            default {      [0, _power, _stayinAirNudge]};   // Forward fallback
        };

        // Apply AirDash impulse + sound (paticle source bc the fnc cant play two sounds on one object
        _soundOBJ = "#particlesource" createVehicle (getposATL _unit);
        _soundOBJ attachTo [_unit, [0,0,0], "leftLeg", true];
        private _rSound = selectRandom [
            "AirDash_1",
            "AirDash_2",
            "AirDash_3"
        ];
        [_soundOBJ, _rSound, 10] call CBA_fnc_globalSay3d;
        [_unit, _soundOBJ] spawn {
            params ["_unit","_soundOBJ"];
            uiSleep 3;
            deleteVehicle _soundOBJ;
        };

        [_unit, _impulse, 5] call PHEN_CS_fnc_applySmoothImpulse;

        _unit setVariable ["PHEN_CS_IsJumpingOrDashing", true, false];
        _unit allowDamage false;
        [_unit] spawn {
            params ["_unit"];
            waitUntil { !alive _unit || isTouchingGround _unit };
            _unit setVariable ["PHEN_CS_IsJumpingOrDashing", false, false];
            _unit allowDamage true;
            _unit setVariable ["PHEN_CS_AirDash_ChargesLeft", 2];
            if (_unit isEqualTo player) then { hintSilent "" };
        };

        // Start cooldown timer only when the last charge is spent
        if (_chargesAfter <= 0) then {
            _unit setVariable ["PHEN_CS_AirDash_LastUse", _now];
        };
    };
};

/// RIPPERDOC SYSTEMS \\\
PHEN_CS_fnc_Ripperdoc_RunQTEThen = {
    params [
        ["_unit", objNull],    // patient
        ["_doc", objNull],     // doctor
        ["_title", "Ripperdoc Procedure"],
        ["_onSuccess", {}],    // code: params ["_unit","_doc"];
        ["_onFail", {}]        // code: params ["_unit","_doc"];
    ];

    if (isNull _unit || {isNull _doc}) exitWith {};

    private _useQTE = missionNamespace getVariable ["PHEN_CS_EnableRipperdocQTE", true];
    if (!_useQTE) exitWith { [_unit, _doc] call _onSuccess; };

    private _timeLimit = missionNamespace getVariable ["PHEN_CS_RipperdocQTE_TimeLimit", 8];
    private _maxResets = missionNamespace getVariable ["PHEN_CS_RipperdocQTE_MaxResets", 3];

    // Pick a random QTE length (3..6 inputs)
    private _len = 3 + floor (random 4);
    private _pool = ["^","v",">","<"];
    private _seq = [];
    for "_i" from 1 to _len do { _seq pushBack (selectRandom _pool); };

    // Small helper for a clean UI
    private _fnc_show = {
        params ["_icon", "_headline", "_sub", "_seqTxt", "_histTxt", "_tries"];

        private _msg = format [
            "<img size='2' image='%1'/>" +
            "<br/>" +
            "<t color='#FFFFFF' size='1.4' shadow='1' font='PuristaSemiBold'>%2</t>" +
            "<br/>" +
            "<t color='#BBDDEE' size='1' shadow='1' font='PuristaLight'>%3</t>" +
            "<br/><br/>" +
            "<t color='#FFFFFF' size='1.2' shadow='1' font='PuristaSemiBold'>%4</t>" +
            "<br/>" +
            "<t color='#66FFAA' size='1.2' shadow='1' font='PuristaSemiBold'>%5</t>" +
            "<br/><br/>" +
            "<t color='#FFCC66' size='0.95' shadow='1' font='PuristaLight'>Mistakes: %6</t>",
            _icon, _headline, _sub, _seqTxt, _histTxt, _tries
        ];
        hint parseText _msg;
    };

    playSoundUI ["PHEN_CS_UI_Zappy_Pop_Up"];
    playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\timer.wss", player];
    // Start QTE
    [
        [_unit, _doc, _title, _timeLimit, _maxResets, _onSuccess, _onFail, _fnc_show],

        // Fail condition
        {
            params ["_args", "_elapsedTime", "_resetCount"];
            _args params ["_unit", "_doc", "_title", "_timeLimit", "_maxResets"];

            (isNull _unit)
            || {isNull _doc}
            || {!alive _unit}
            || {!alive _doc}
            || {(lifeState _unit) == "INCAPACITATED"}
            || {(lifeState _doc) == "INCAPACITATED"}
            || {(_unit distance _doc) > 4}
            || {_elapsedTime > _timeLimit}
            || {_resetCount >= _maxResets}
        },

        // OnDisplay
        {
            params ["_args", "_qteSequence", "_qteHistory", "_resetCount", "_incorrectInput"];
            _args params ["_unit", "_doc", "_title", "_timeLimit", "_maxResets", "_onSuccess", "_onFail", "_fnc_show"];

            private _seqTxt  = [_qteSequence] call CBA_fnc_getFormattedQTESequence;
            private _histTxt = [_qteHistory]  call CBA_fnc_getFormattedQTESequence;

            private _icon = "PHEN_Cybernetics\Data\RipperDoc_Add_ca.paa";
            private _sub  = format ["Stay close. Time limit: %1s", _timeLimit];

            [_icon, _title, _sub, _seqTxt, _histTxt, _resetCount] call _fnc_show;

            if (_incorrectInput) then {
                playSoundUI ["PHEN_CS_UI_Message_Bleep"];
            };
        },

        // OnFinish
        {
            params ["_args", "_elapsedTime", "_resetCount"];
            _args params ["_unit", "_doc", "_title", "_timeLimit", "_maxResets", "_onSuccess"];

            hintSilent "";

            // Success audio feedback
            playSoundUI ["PHEN_CS_UI_Touchscreen_Submit_Button"];

            [_unit, _doc] call _onSuccess;
        },

        // OnFail
        {
            params ["_args", "_elapsedTime", "_resetCount"];
            _args params ["_unit", "_doc", "_title", "_timeLimit", "_maxResets", "_onSuccess", "_onFail"];

            private _msg = format [
                "<img size='2' image='a3\3den\data\attributes\taskstates\failed_ca.paa'/>" +
                "<br/>" +
                "<t color='#FF6666' size='1.4' shadow='1' font='PuristaSemiBold'>Procedure Failed</t>" +
                "<br/>" +
                "<t color='#FFFFFF' size='1' shadow='1' font='PuristaLight'>Try again. Keep steady hands, choom.</t>"
            ];
            hint parseText _msg;

            playSoundUI ["PHEN_CS_UI_Encryptor_App_Close"];

            [_unit, _doc] call _onFail;
        },

        _seq,
        true
    ] call CBA_fnc_runQTE;
};

PHEN_CS_fnc_RipperDoc_AddDiag = {
    params ["_target", "_caller"];

    private _unit = _target; // patient
    private _doc  = _caller; // doctor

    // Basic sanity
    if (isNull _unit || {isNull _doc}) exitWith {};
    if (!alive _unit || {!alive _doc}) exitWith {};
    if ((lifeState _unit) == "INCAPACITATED") exitWith {};
    if ((lifeState _doc) == "INCAPACITATED") exitWith {};
    if ((_unit distance _doc) > 5) exitWith { systemChat "Get closer to the patient."; };

    private _openDialog = {
        params ["_unit", "_doc"];

        private _ripperdocList = [_doc] call PHEN_CS_fnc_GetRipperdocCyberneticMasterList;
        if ((_ripperdocList # 0) isEqualTo []) exitWith {
            [_doc, "This Ripperdoc has no cybernetics available."] call BIS_fnc_showCuratorFeedbackMessage;
        };

        [
            "Implant Cybernetics",
            [
                ["COMBO", ["Cybernetics", "Select the Cybernetics to implant into the patient"], _ripperdocList]
            ],
            {
                params ["_values", "_args"];
                _values params ["_implant"];
                _args params ["_unit", "_doc"];

                private _ok = [_unit, _implant] call PHEN_CS_fnc_installCybernetic;
                private _success = (_ok isEqualType true && {_ok});

                if (_success) then {
                    playSoundUI ["PHEN_CS_UI_Touchscreen_Sweep", 0.85 + random 0.3, 0.9 + random 0.2];
                    [[_unit, _doc, _implant], {
                        params ["_unit", "_doc", "_implant"];
                        if ((player != _unit) && (player != _doc)) exitWith {};
                        hintSilent parseText format ["<t size='0.85' color='#ffcc00'>Cybernetics Implanted</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t><br/><t size='0.8' color='#aaaaaa'>%2 by %3</t>", (_implant # 0), (name _unit), (name _doc)];
                    }] remoteExec ["spawn", 0];
                } else {
                    hintSilent parseText (if (_ok isEqualTo 5) then { "<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>All slots in this category are occupied.</t>" } else { format ["<t size='0.85' color='#ff6666'>Implant Failed</t><br/><t font='EtelkaMonospacePro' size='0.9' color='#aaaaaa'>Code %1, try rejoining or contact admin.</t>", _ok] });
                };
            },
            {},
            [_unit, _doc]
        ] call zen_dialog_fnc_create;
    };

    // QTE gate
    [_unit, _doc, "Implant Procedure", _openDialog, {}] call PHEN_CS_fnc_Ripperdoc_RunQTEThen;
};

PHEN_CS_fnc_RipperDoc_RemoveDiag = {
    params ["_target", "_caller"];

    private _unit = _target; // patient
    private _doc  = _caller; // doctor

    if (isNull _unit || {isNull _doc}) exitWith {};
    if (!alive _unit || {!alive _doc}) exitWith {};
    if ((lifeState _unit) == "INCAPACITATED") exitWith {};
    if ((lifeState _doc) == "INCAPACITATED") exitWith {};
    if ((_unit distance _doc) > 5) exitWith { systemChat "Get closer to the patient."; };

    private _openDialog = {
        params ["_unit", "_doc"];

        private _list = [_unit] call PHEN_CS_fnc_ZEN_GetPlayerCurrentCybernetics;
        private _items = _list # 0;

        if (_items isEqualTo []) exitWith {
            [_doc, "This patient has no cybernetics installed."] call BIS_fnc_showCuratorFeedbackMessage;
        };

        [
            "Remove Cybernetics",
            [
                ["COMBO", ["Cybernetics", "Select the Cybernetics to remove from the patient"], _list]
            ],
            {
                params ["_values", "_args"];
                _values params ["_implant"];
                _args params ["_unit", "_doc"];

                private _ok = [_unit, _implant] call PHEN_CS_fnc_removeCybernetic;
                private _success = (_ok isEqualType true && {_ok});

                if (_success) then {
                    playSoundUI ["PHEN_CS_UI_Touchscreen_Sweep", 0.85 + random 0.3, 0.9 + random 0.2];
                    [[_unit, _doc, _implant], {
                        params ["_unit", "_doc", "_implant"];
                        if ((player != _unit) && (player != _doc)) exitWith {};
                        hintSilent parseText format ["<t size='0.85' color='#ff6644'>Cybernetics Removed</t><br/><t font='EtelkaMonospacePro' size='1' color='#00ccff'>%1</t><br/><t size='0.8' color='#aaaaaa'>%2 by %3</t>", (_implant # 0), (name _unit), (name _doc)];
                    }] remoteExec ["spawn", 0];
                } else {
                    systemChat "Selected cybernetic is not installed on the patient.";
                };
            },
            {},
            [_unit, _doc]
        ] call zen_dialog_fnc_create;
    };

    [_unit, _doc, "Removal Procedure", _openDialog, {}] call PHEN_CS_fnc_Ripperdoc_RunQTEThen;
};

PHEN_CS_fnc_setRipeprdoc = {
    params ["_unit", "_state"];
    if ((_unit getVariable ["isRipperdoc", false]) isEqualTo _state) exitWith {};
    _unit setVariable ["isRipperdoc", _state, true];
};

PHEN_CS_fnc_setCyberneticsDisabled = {
    params ["_unit", "_disabled"];
    if ((_unit getVariable ["PHEN_CS_Disabled", false]) isEqualTo _disabled) exitWith {};
    _unit setVariable ["PHEN_CS_Disabled", _disabled, true];
};

PHEN_CS_fnc_AddRipperDocActions = {
    params [["_unit", objNull], ["_ImplantAction", true], ["_RemoveAction", true]];

    // Only valid for man units
    if (isNull _unit) exitWith {};
    if !(_unit isKindOf "CAManBase") exitWith {};

    [[_unit, _ImplantAction, _RemoveAction], {
        params [["_unit", objNull], ["_ImplantAction", true], ["_RemoveAction", true]];

        if (isNull _unit) exitWith {};
        if !(_unit isKindOf "CAManBase") exitWith {};

        // --- IMPLANT ACTION (on patient, usable only by ripperdoc) ---
        if (_ImplantAction) then {
            if (isNil {_unit getVariable "PHEN_CS_ImplanterActionID_RipperDoc"}) then {
                private _ImplanterActionID = _unit addAction [
                    "<img size='1.5'image='PHEN_Cybernetics\Data\RipperDoc_Add_ca.paa'/><t color='#FF00FF00' size='1' font='PuristaSemibold' align='left' shadow='2'>IMPLANT Cybernetics</t>",
                    {
                        params ["_target", "_caller", "_actionId", "_args"];
                        // _target = patient, _caller = doctor
                        [_target, _caller] call PHEN_CS_fnc_RipperDoc_AddDiag;
                    },
                    nil,        // arguments
                    10,         // priority (lower than self actions etc)
                    false,      // showWindow
                    true,       // hideOnUse
                    "",         // shortcut
                    "PHEN_CS_EnableBaseActions &&
                     {_this getVariable ['isRipperdoc', false]} &&
                     {_target != player} &&
                     {isPlayer _this} &&
                     {vehicle _this isEqualTo _this} &&
                     {alive _target} &&
                     {alive _this} &&
                     {isPlayer _target} &&
                     {_target isKindOf 'CAManBase'}",
                    5,          // radius
                    false,      // unconscious
                    "",         // selection
                    ""          // memoryPoint
                ];
                _unit setVariable ["PHEN_CS_ImplanterActionID_RipperDoc", _ImplanterActionID, false];
            };
        };

        // --- REMOVE ACTION (on patient, usable only by ripperdoc) ---
        if (_RemoveAction) then {
            if (isNil {_unit getVariable "PHEN_CS_removeActionID_RipperDoc"}) then {
                private _removeActionID = _unit addAction [
                    "<img size='1.5'image='PHEN_Cybernetics\Data\RipperDoc_Remove_ca.paa'/><t color='#FFFF2626' size='1' font='PuristaMedium' align='left' shadow='2'>REMOVE Cybernetics</t>",
                    {
                        params ["_target", "_caller", "_actionId", "_args"];
                        // _target = patient, _caller = doctor
                        [_target, _caller] call PHEN_CS_fnc_RipperDoc_RemoveDiag;
                    },
                    nil,        // arguments
                    9,          // priority
                    false,      // showWindow
                    true,       // hideOnUse
                    "",         // shortcut
                    "PHEN_CS_EnableBaseActions &&
                     {_this getVariable ['isRipperdoc', false]} &&
                     {_target != player} &&
                     {isPlayer _this} &&
                     {vehicle _this isEqualTo _this} &&
                     {alive _target} &&
                     {alive _this} &&
                     {isPlayer _target} &&
                     {_target isKindOf 'CAManBase'}",
                    5,          // radius
                    false,      // unconscious
                    "",         // selection
                    ""          // memoryPoint
                ];
                _unit setVariable ["PHEN_CS_removeActionID_RipperDoc", _removeActionID, false];
            };
        };

        if (hasInterface && { "ace_interact_menu" in activatedAddons }) then {

            if (_ImplantAction) then {
                private _aceImplantAction = [
                    "PHEN_CS_RipperDoc_Implant",
                    "Implant Cybernetics",
                    "PHEN_Cybernetics\Data\RipperDoc_Add_ca.paa",
                    {
                        params ["_target", "_player", "_actionParams"];
                        [_target, _player] call PHEN_CS_fnc_RipperDoc_AddDiag;
                    },
                    {
                        params ["_target", "_player", "_actionParams"];
                        PHEN_CS_EnableACEActions &&
                        { _player getVariable ["isRipperdoc", false] } &&
                        { _target != _player } &&
                        { isPlayer _target } &&
                        { vehicle _player isEqualTo _player } &&
                        { alive _target } &&
                        { alive _player } &&
                        { _target isKindOf "CAManBase" }
                    }
                ] call ace_interact_menu_fnc_createAction;

                [_unit, 0, ["ACE_MainActions"], _aceImplantAction] call ace_interact_menu_fnc_addActionToObject;
            };

            if (_RemoveAction) then {
                private _aceRemoveAction = [
                    "PHEN_CS_RipperDoc_Remove",
                    "Remove Cybernetics",
                    "PHEN_Cybernetics\Data\RipperDoc_Remove_ca.paa",
                    {
                        params ["_target", "_player", "_actionParams"];
                        [_target, _player] call PHEN_CS_fnc_RipperDoc_RemoveDiag;
                    },
                    {
                        params ["_target", "_player", "_actionParams"];
                        PHEN_CS_EnableACEActions &&
                        { _player getVariable ["isRipperdoc", false] } &&
                        { _target != _player } &&
                        { isPlayer _target } &&
                        { vehicle _player isEqualTo _player } &&
                        { alive _target } &&
                        { alive _player } &&
                        { _target isKindOf "CAManBase" }
                    }
                ] call ace_interact_menu_fnc_createAction;

                [_unit, 0, ["ACE_MainActions"], _aceRemoveAction] call ace_interact_menu_fnc_addActionToObject;
            };
        };
    }] remoteExec ["spawn", 0, true];
};

PHEN_CS_fnc_debugMsg  = {
	params ["_msg"];
	if !(PHEN_CS_DebugMode) exitWith {};
	systemChat format ["[PHEN_CS] %1", _msg];
	diag_log format ["[PHEN_CS] %1", _msg];
};

PHEN_CS_fnc_TacHUD_getRange = {
    private _ins = lineIntersectsSurfaces [
        AGLToASL positionCameraToWorld [0, 0, 0],
        AGLToASL positionCameraToWorld [0, 0, 5000],
        vehicle player, objNull, true, 1, "FIRE", "NONE"
    ];
    private _cursorDistance = if (count _ins > 0) then {
        (_ins select 0 select 0) vectorDistance (eyePos player)
    } else {
        5000
    };
    if (count _ins > 0) then { format ["%1m", round _cursorDistance] } else { "----" }
};

PHEN_CS_fnc_TacHUD_getBearing = {
    format ["%1°", round (getDir player)]
};

PHEN_CS_fnc_TacHUD_getGrid = {
    mapGridPosition player
};

PHEN_CS_fnc_TacHUD_show = {
    if (uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false]) exitWith {};
    private _d46 = findDisplay 46;

    private _animDuration = 0.1 + random 0.1;
    if (PHEN_CS_TacHUD_Sound) then { playSoundUI ["PHEN_CS_UI_Hud_Window_Open", (0.2 + random 0.2), (0.9 + random 0.2)]; };

    private _bgCtrl = _d46 ctrlCreate ["RscPictureKeepAspect", 9800];
    _bgCtrl ctrlSetText "PHEN_Cybernetics\Data\TacHUD_v1.paa";
    _bgCtrl ctrlSetTextColor [1, 1, 1, 0.90];
    _bgCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.6890625, safeZoneY + safeZoneH * 0.68888889, 0, safeZoneH * 0.35];
    _bgCtrl ctrlSetFade 1;
    _bgCtrl ctrlCommit 0;
    _bgCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.6890625, safeZoneY + safeZoneH * 0.68888889, safeZoneW * 0.35, safeZoneH * 0.35];
    _bgCtrl ctrlSetFade 0;
    _bgCtrl ctrlCommit _animDuration;

    private _rangeCtrl = _d46 ctrlCreate ["RscStructuredText", 9801];
    _rangeCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.7766, safeZoneY + safeZoneH * 0.854, 0, safeZoneH * 0.025];
    _rangeCtrl ctrlSetFade 1;
    _rangeCtrl ctrlCommit 0;
    _rangeCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.7766, safeZoneY + safeZoneH * 0.854, safeZoneW * 0.047, safeZoneH * 0.025];
    _rangeCtrl ctrlSetFade 0;
    _rangeCtrl ctrlCommit _animDuration;

    private _bearingCtrl = _d46 ctrlCreate ["RscStructuredText", 9802];
    _bearingCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.9005, safeZoneY + safeZoneH * 0.805, 0, safeZoneH * 0.025];
    _bearingCtrl ctrlSetFade 1;
    _bearingCtrl ctrlCommit 0;
    _bearingCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.9005, safeZoneY + safeZoneH * 0.805, safeZoneW * 0.046875, safeZoneH * 0.025];
    _bearingCtrl ctrlSetFade 0;
    _bearingCtrl ctrlCommit _animDuration;

    private _gridCtrl = _d46 ctrlCreate ["RscStructuredText", 9803];
    _gridCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.91, safeZoneY + safeZoneH * 0.833, 0, safeZoneH * 0.025];
    _gridCtrl ctrlSetFade 1;
    _gridCtrl ctrlCommit 0;
    _gridCtrl ctrlSetPosition [safeZoneX + safeZoneW * 0.91, safeZoneY + safeZoneH * 0.833, safeZoneW * 0.046875, safeZoneH * 0.025];
    _gridCtrl ctrlSetFade 0;
    _gridCtrl ctrlCommit _animDuration;

    uiNamespace setVariable ["PHEN_CS_TacHUD_Active", true];
    uiNamespace setVariable ["PHEN_CS_TacHUD_BGCtrl", _bgCtrl];
    uiNamespace setVariable ["PHEN_CS_TacHUD_RangeCtrl", _rangeCtrl];
    uiNamespace setVariable ["PHEN_CS_TacHUD_BearingCtrl", _bearingCtrl];
    uiNamespace setVariable ["PHEN_CS_TacHUD_GridCtrl", _gridCtrl];

    private _pfhHandle = [{
        params ["_args", "_handle"];
        _args params ["_rangeCtrl", "_bearingCtrl", "_gridCtrl"];
        if (!(uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false])) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
            uiNamespace setVariable ["PHEN_CS_TacHUD_PFH", nil];
        };
        private _range = call PHEN_CS_fnc_TacHUD_getRange;
        private _bearing = call PHEN_CS_fnc_TacHUD_getBearing;
        private _grid = call PHEN_CS_fnc_TacHUD_getGrid;
        _rangeCtrl ctrlSetStructuredText parseText format ["<t align='center' size='1.2' font='LCD14' color='#ffffff'>%1</t>", _range];
        _bearingCtrl ctrlSetStructuredText parseText format ["<t size='1.3' font='LCD14' color='#ffffff'>%1</t>", _bearing];
        _gridCtrl ctrlSetStructuredText parseText format ["<t size='0.75' font='LCD14' color='#ffffff'>%1</t>", _grid];
    }, 0.1, [_rangeCtrl, _bearingCtrl, _gridCtrl]] call CBA_fnc_addPerFrameHandler;
    uiNamespace setVariable ["PHEN_CS_TacHUD_PFH", _pfhHandle];
};

PHEN_CS_fnc_TacHUD_hide = {
    if (!(uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false])) exitWith {};
    uiNamespace setVariable ["PHEN_CS_TacHUD_Active", false];

    if (!isNil {uiNamespace getVariable "PHEN_CS_TacHUD_PFH"}) then {
        [uiNamespace getVariable "PHEN_CS_TacHUD_PFH"] call CBA_fnc_removePerFrameHandler;
        uiNamespace setVariable ["PHEN_CS_TacHUD_PFH", nil];
    };

    private _animDuration = 0.05 + random 0.05;
    private _ctrls = [
        uiNamespace getVariable ["PHEN_CS_TacHUD_BGCtrl", controlNull],
        uiNamespace getVariable ["PHEN_CS_TacHUD_RangeCtrl", controlNull],
        uiNamespace getVariable ["PHEN_CS_TacHUD_BearingCtrl", controlNull],
        uiNamespace getVariable ["PHEN_CS_TacHUD_GridCtrl", controlNull]
    ];
    {
        if (!isNull _x) then {
            private _pos = ctrlPosition _x;
            _x ctrlSetPosition [_pos # 0, _pos # 1, 0, _pos # 3];
            _x ctrlSetFade 1;
            _x ctrlCommit _animDuration;
        };
    } forEach _ctrls;

    [_ctrls, _animDuration] spawn {
        params ["_ctrls", "_dur"];
        uiSleep _dur;
        { if (!isNull _x) then { ctrlDelete _x; }; } forEach _ctrls;
    };

    { uiNamespace setVariable [_x, nil]; } forEach ["PHEN_CS_TacHUD_BGCtrl", "PHEN_CS_TacHUD_RangeCtrl", "PHEN_CS_TacHUD_BearingCtrl", "PHEN_CS_TacHUD_GridCtrl"];
};

PHEN_CS_fnc_TacHUD_toggle = {
    if (uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false]) then {
        call PHEN_CS_fnc_TacHUD_hide;
    } else {
        call PHEN_CS_fnc_TacHUD_show;
    };
};

[
    PHEN_CS_KEYBIND_CAT_TACHUD,
    "PHEN_CS_TacHUD_ToggleKey",
    [PHEN_CS_L("STR_PHEN_CS_CBA_KEY_TACHUD_TOGGLE"), PHEN_CS_L("STR_PHEN_CS_CBA_KEY_TACHUD_TOGGLE_TT")],
    {
        if (!(isNull findDisplay 49) || !(isNull findDisplay 312) || visibleMap) exitWith {};
        private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
        if !(_unit getVariable ["PHEN_CS_Abillity_TacHUD", false]) exitWith {};
        if (uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false]) then {
            uiNamespace setVariable ["PHEN_CS_TacHUD_ManuallyEnabled", false];
            uiNamespace setVariable ["PHEN_CS_TacHUD_ADSSuppressed", true];
            call PHEN_CS_fnc_TacHUD_hide;
        } else {
            uiNamespace setVariable ["PHEN_CS_TacHUD_ManuallyEnabled", true];
            uiNamespace setVariable ["PHEN_CS_TacHUD_ADSSuppressed", false];
            call PHEN_CS_fnc_TacHUD_show;
        };
    },
    {},
    [0, [false, false, false]]
] call CBA_fnc_addKeybind;
