if (!hasInterface) exitWith {};

PHEN_CS_CSS_MineRadius = 50;
PHEN_CS_CSS_AllyRange = 1000;
PHEN_CS_CSS_RadarRange = 1000;
PHEN_CS_CSS_MaxRadarContacts = 24;
PHEN_CS_CSS_ImpactMarkers = [];
PHEN_CS_CSS_FriendContacts = [];
PHEN_CS_CSS_MineContacts = [];

PHEN_CS_fnc_CSS_getUnit = {
    private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
    if (isNull _unit) then { _unit = player; };
    _unit
};

PHEN_CS_fnc_CSS_hasSuite = {
    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    (!isNull _unit) && { alive _unit } && { _unit getVariable ["PHEN_CS_Abillity_CombatSensorSuite", false] }
};

PHEN_CS_fnc_CSS_isFriendly = {
    params ["_origin", "_target"];

    if (isNull _origin || { isNull _target }) exitWith { false };
    if (_target isEqualTo _origin) exitWith { false };

    private _crew = if (_target isKindOf "CAManBase") then { [_target] } else { crew _target };
    _crew = _crew select { alive _x };
    if (_crew isEqualTo []) exitWith { false };

    private _originSide = side group _origin;
    private _targetSide = side group (_crew # 0);
    (_originSide getFriend _targetSide) >= 0.6
};

PHEN_CS_fnc_CSS_getFriendObjects = {
    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    if (isNull _unit) exitWith { [] };

    private _originPos = getPosASL _unit;
    private _contacts = [];

    {
        private _contact = vehicle _x;
        if (!(_contact in _contacts) && { [_unit, _contact] call PHEN_CS_fnc_CSS_isFriendly } && { (_originPos distance (getPosASL _contact)) <= PHEN_CS_CSS_AllyRange }) then {
            _contacts pushBack _contact;
        };
    } forEach allUnits;

    _contacts
};

PHEN_CS_fnc_CSS_getVitalsText = {
    private _unit = call PHEN_CS_fnc_CSS_getUnit;

    private _heartRate = _unit getVariable ["ace_medical_heartrate", -1];
    if (_heartRate < 0) then { _heartRate = 60 + ((damage _unit) * 80); };

    private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", -1];
    private _bloodPercent = if (_bloodVolume >= 0) then {
        private _value = if (_bloodVolume > 1) then { (_bloodVolume / 6) * 100 } else { _bloodVolume * 100 };
        round ((_value max 0) min 100)
    } else {
        round ((1 - damage _unit) * 100)
    };

    private _oxygen = _unit getVariable ["ace_medical_oxygenSaturation", -1];
    private _oxygenText = if (_oxygen >= 0) then {
        private _oxygenPercent = if (_oxygen > 1) then { _oxygen } else { _oxygen * 100 };
        format ["%1%%", round ((_oxygenPercent max 0) min 100)]
    } else {
        "--"
    };

    private _pressure = _unit getVariable ["ace_medical_bloodPressure", []];
    private _pressureText = if ((typeName _pressure) isEqualTo "ARRAY" && { count _pressure >= 2 }) then {
        format ["%1/%2", round (_pressure # 0), round (_pressure # 1)]
    } else {
        "--/--"
    };

    format ["HR %1 | BP %2 | BLOOD %3%% | O2 %4", round _heartRate, _pressureText, _bloodPercent, _oxygenText]
};

PHEN_CS_fnc_CSS_ensureHud = {
    if (!isNull (uiNamespace getVariable ["PHEN_CS_CSS_BGCtrl", controlNull])) exitWith {};

    private _display = findDisplay 46;
    if (isNull _display) exitWith {};

    private _panelX = safeZoneX + safeZoneW - 0.235;
    private _panelY = safeZoneY + safeZoneH - 0.295;
    private _panelW = 0.22;
    private _panelH = 0.235;

    private _bg = _display ctrlCreate ["RscText", -1];
    _bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
    _bg ctrlSetBackgroundColor [0, 0.04, 0.06, 0.42];
    _bg ctrlCommit 0;

    private _text = _display ctrlCreate ["RscStructuredText", -1];
    _text ctrlSetPosition [_panelX + 0.008, _panelY + 0.006, _panelW - 0.016, 0.055];
    _text ctrlSetBackgroundColor [0, 0, 0, 0];
    _text ctrlSetStructuredText parseText "";
    _text ctrlCommit 0;

    private _center = _display ctrlCreate ["RscText", -1];
    _center ctrlSetPosition [_panelX + 0.107, _panelY + 0.145, 0.006, 0.006];
    _center ctrlSetBackgroundColor [0.2, 0.85, 1, 0.9];
    _center ctrlCommit 0;

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _dot = _display ctrlCreate ["RscText", -1];
        _dot ctrlSetPosition [_panelX + 0.107, _panelY + 0.145, 0.005, 0.005];
        _dot ctrlSetBackgroundColor [0.2, 1, 0.55, 0.85];
        _dot ctrlShow false;
        _dot ctrlCommit 0;
        uiNamespace setVariable [format ["PHEN_CS_CSS_RadarDot_%1", _i], _dot];
    };

    uiNamespace setVariable ["PHEN_CS_CSS_BGCtrl", _bg];
    uiNamespace setVariable ["PHEN_CS_CSS_TextCtrl", _text];
    uiNamespace setVariable ["PHEN_CS_CSS_CenterCtrl", _center];
};

PHEN_CS_fnc_CSS_deleteHud = {
    {
        private _ctrl = uiNamespace getVariable [_x, controlNull];
        if (!isNull _ctrl) then { ctrlDelete _ctrl; };
        uiNamespace setVariable [_x, nil];
    } forEach ["PHEN_CS_CSS_BGCtrl", "PHEN_CS_CSS_TextCtrl", "PHEN_CS_CSS_CenterCtrl"];

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _key = format ["PHEN_CS_CSS_RadarDot_%1", _i];
        private _dot = uiNamespace getVariable [_key, controlNull];
        if (!isNull _dot) then { ctrlDelete _dot; };
        uiNamespace setVariable [_key, nil];
    };

    if ((player getVariable ["PHEN_CS_CSS_AddedBinocular", false]) && { "PHEN_CS_ArgusIntegratedBinocular" in weapons player }) then {
        player removeWeapon "PHEN_CS_ArgusIntegratedBinocular";
    };
    player setVariable ["PHEN_CS_CSS_AddedBinocular", false, false];
};

PHEN_CS_fnc_CSS_updateHud = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {
        call PHEN_CS_fnc_CSS_deleteHud;
    };

    call PHEN_CS_fnc_CSS_ensureHud;

    if (!("PHEN_CS_ArgusIntegratedBinocular" in weapons player) && { !("Binocular" in weapons player) } && { !("Rangefinder" in weapons player) }) then {
        player addWeapon "PHEN_CS_ArgusIntegratedBinocular";
        player setVariable ["PHEN_CS_CSS_AddedBinocular", true, false];
    };

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    private _contacts = call PHEN_CS_fnc_CSS_getFriendObjects;
    private _mines = allMines select { !isNull _x && { _unit distance _x <= PHEN_CS_CSS_MineRadius } };
    PHEN_CS_CSS_FriendContacts = _contacts;
    PHEN_CS_CSS_MineContacts = _mines;

    private _mineCount = count _mines;
    private _textCtrl = uiNamespace getVariable ["PHEN_CS_CSS_TextCtrl", controlNull];

    if (!isNull _textCtrl) then {
        _textCtrl ctrlSetStructuredText parseText format [
            "<t size='0.72' color='#66ccff'>ARGUS COMBAT OPTICS</t><br/><t size='0.56'>%1</t><br/><t size='0.52'>ALLIES %2 | MINES %3</t>",
            call PHEN_CS_fnc_CSS_getVitalsText,
            count _contacts,
            _mineCount
        ];
    };

    private _panelX = safeZoneX + safeZoneW - 0.235;
    private _panelY = safeZoneY + safeZoneH - 0.295;
    private _centerX = _panelX + 0.11;
    private _centerY = _panelY + 0.148;
    private _radius = 0.085;
    private _bearing = getDirVisual _unit;

    for "_i" from 0 to (PHEN_CS_CSS_MaxRadarContacts - 1) do {
        private _dot = uiNamespace getVariable [format ["PHEN_CS_CSS_RadarDot_%1", _i], controlNull];
        if (!isNull _dot) then { _dot ctrlShow false; };
    };

    {
        if (_forEachIndex < PHEN_CS_CSS_MaxRadarContacts) then {
            private _dot = uiNamespace getVariable [format ["PHEN_CS_CSS_RadarDot_%1", _forEachIndex], controlNull];
            if (!isNull _dot) then {
                private _distance = _unit distance _x;
                private _dir = _unit getDir _x;
                private _angle = (_dir - _bearing) * 0.0174533;
                private _scaled = (_distance / PHEN_CS_CSS_RadarRange) min 1;
                private _dotX = _centerX + ((sin _angle) * _scaled * _radius);
                private _dotY = _centerY - ((cos _angle) * _scaled * _radius);
                private _dotSize = if (_x isKindOf "CAManBase") then { 0.005 } else { 0.008 };
                _dot ctrlSetPosition [_dotX, _dotY, _dotSize, _dotSize];
                _dot ctrlSetBackgroundColor [0.2, 1, 0.55, 0.85];
                _dot ctrlShow true;
                _dot ctrlCommit 0;
            };
        };
    } forEach _contacts;
};

PHEN_CS_fnc_CSS_draw3D = {
    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {};

    private _unit = call PHEN_CS_fnc_CSS_getUnit;
    private _contacts = PHEN_CS_CSS_FriendContacts select { !isNull _x && { _unit distance _x <= PHEN_CS_CSS_AllyRange } };

    {
        private _distance = _unit distance _x;
        if (_distance <= PHEN_CS_CSS_AllyRange) then {
            private _posASL = getPosASL _x;
            _posASL set [2, (_posASL # 2) + (if (_x isKindOf "CAManBase") then { 2.15 } else { 3.0 })];
            private _size = linearConversion [0, PHEN_CS_CSS_AllyRange, _distance, 0.95, 0.23, true];
            private _label = if (_x isKindOf "CAManBase") then {
                name _x
            } else {
                getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")
            };
            drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", [0.1, 0.85, 1, 0.85], ASLToAGL _posASL, _size, _size, 0, _label, 1, 0.028 * _size, "RobotoCondensed", "center"];
        };
    } forEach _contacts;

    {
        if (!isNull _x && { _unit distance _x <= PHEN_CS_CSS_MineRadius }) then {
            private _minePosASL = getPosASL _x;
            _minePosASL set [2, (_minePosASL # 2) + 0.35];
            drawIcon3D ["\a3\ui_f\data\map\markers\military\warning_ca.paa", [1, 0.16, 0.08, 0.95], ASLToAGL _minePosASL, 0.75, 0.75, 0, "MINE", 1, 0.03, "RobotoCondensed", "center"];
        };
    } forEach (PHEN_CS_CSS_MineContacts select { !isNull _x && { _unit distance _x <= PHEN_CS_CSS_MineRadius } });

    private _now = diag_tickTime;
    PHEN_CS_CSS_ImpactMarkers = PHEN_CS_CSS_ImpactMarkers select { (_x # 1) > _now };
    {
        private _impactPosASL = _x # 0;
        drawIcon3D ["\a3\ui_f\data\map\markers\military\destroy_ca.paa", [1, 0.62, 0.08, 0.9], ASLToAGL _impactPosASL, 0.75, 0.75, 0, "IMPACT", 1, 0.032, "RobotoCondensed", "center"];
    } forEach PHEN_CS_CSS_ImpactMarkers;
};

PHEN_CS_fnc_CSS_onFired = {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

    if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {};
    if (isNull _projectile) exitWith {};

    private _startASL = getPosASL _projectile;

    [_projectile, _startASL] spawn {
        params ["_projectile", "_startASL"];

        private _lastASL = _startASL;
        private _deadline = diag_tickTime + 15;

        waitUntil {
            uiSleep 0.01;
            if (!isNull _projectile) then { _lastASL = getPosASL _projectile; };
            isNull _projectile || { diag_tickTime > _deadline }
        };

        if ((_startASL distance _lastASL) <= 200) exitWith {};
        if !(call PHEN_CS_fnc_CSS_hasSuite) exitWith {};

        PHEN_CS_CSS_ImpactMarkers pushBack [_lastASL, diag_tickTime + 8];
    };
};

PHEN_CS_fnc_CSS_registerFiredEH = {
    private _oldUnit = missionNamespace getVariable ["PHEN_CS_CSS_FiredEHUnit", objNull];
    private _oldEH = missionNamespace getVariable ["PHEN_CS_CSS_FiredEH", -1];

    if (!isNull _oldUnit && { _oldEH >= 0 }) then {
        _oldUnit removeEventHandler ["FiredMan", _oldEH];
    };

    private _eh = player addEventHandler ["FiredMan", {
        _this call PHEN_CS_fnc_CSS_onFired;
    }];

    missionNamespace setVariable ["PHEN_CS_CSS_FiredEHUnit", player];
    missionNamespace setVariable ["PHEN_CS_CSS_FiredEH", _eh];
};

PHEN_CS_fnc_CSS_start = {
    if (isNil { missionNamespace getVariable "PHEN_CS_CSS_Draw3DEH" }) then {
        missionNamespace setVariable ["PHEN_CS_CSS_Draw3DEH", addMissionEventHandler ["Draw3D", {
            call PHEN_CS_fnc_CSS_draw3D;
        }]];
    };

    if (isNil { missionNamespace getVariable "PHEN_CS_CSS_PFH" }) then {
        missionNamespace setVariable ["PHEN_CS_CSS_PFH", [{
            call PHEN_CS_fnc_CSS_updateHud;
        }, 0.25, []] call CBA_fnc_addPerFrameHandler];
    };

    call PHEN_CS_fnc_CSS_registerFiredEH;
};

[] spawn {
	waitUntil { uiSleep 1; !isNull findDisplay 46};
	//postInit Code!

	// Load existing saved data at init
	[] call PHEN_CS_fnc_loadCyberneticsData;

	//Add EHs
	[] call PHEN_CS_fnc_registerCyberneticsEventHandlers;

    //Add Cyberware Handler
    [player] call PHEN_CS_fnc_addCyberwareHandler;

    // Register BioMedica implant EHs
    call PHEN_CS_fnc_registerBioMedicaEHs;

    // Register Argus combat optics client sensors
    [] call PHEN_CS_fnc_CSS_start;

    // Client-side
    if (hasInterface) then {

        // Only add the handler once
        if (isNil { missionNamespace getVariable "PHEN_CS_AirDash_KeyEH" }) then {

            private _display = findDisplay 46;
            if (isNull _display) exitWith {};

            // Ensure we have a default direction
            if (isNil { missionNamespace getVariable "PHEN_CS_DashDir" }) then {
                missionNamespace setVariable ["PHEN_CS_DashDir", "Forward"];
            };

            private _ehId = _display displayAddEventHandler [
                "KeyDown",
                {
                    params ["_display", "_dikCode"];

                    // ONLy if they got the abillity
                    if (!(player getVariable ["PHEN_CS_Abillity_AirDash", false]) && !(player getVariable ["PHEN_CS_Abillity_Dash", false])) exitWith { false };

                    switch (_dikCode) do {
                        // W
                        case 17: {
                            missionNamespace setVariable ["PHEN_CS_DashDir", "Forward"];
                        };
                        // S
                        case 31: {
                            missionNamespace setVariable ["PHEN_CS_DashDir", "Back"];
                        };
                        // A
                        case 30: {
                            missionNamespace setVariable ["PHEN_CS_DashDir", "Left"];
                        };
                        // D
                        case 32: {
                            missionNamespace setVariable ["PHEN_CS_DashDir", "Right"];
                        };
                        default {};
                    };

                    // Return false, let game handle the key normally
                    false
                }
            ];

            missionNamespace setVariable ["PHEN_CS_AirDash_KeyEH", _ehId];
        };
    };
	
};

// Register the modules
// Single Player - Give Cybernetics
["Cybernetics System", "Single Player - Give Cybernetics", 
{
    params ["_modulePosASL","_attachedObject"];

    if !(_attachedObject isKindOf "CAManBase") exitWith {
        [objNull, "Objects are not supported!"] call BIS_fnc_showCuratorFeedbackMessage;
    };

    [
        "Implant a Cybernetics", 
        [
            // use full catalog
            ["COMBO", ["Cybernetics", "Select the Cybernetics to Implant on the selected player"], PHEN_CS_Cybernetic_MasterList]
        ],
        {
            params ["_values", "_args"];
            _values params ["_implant", "_selected"];
            _args params ["_modulePosASL", "_attachedObject"];

            if (isNull _attachedObject) exitWith {};

            private _ok = [_attachedObject, _implant] call PHEN_CS_fnc_installCybernetic;

            if (_ok isEqualTo true) then {

                if (_attachedObject isEqualTo player) then {
                    [] call PHEN_CS_fnc_saveCyberneticsData;
                    [] call PHEN_CS_fnc_loadCyberneticsData;
                };

                [_attachedObject, format ["Cybernetics Implanted: %1", _implant # 0]] call BIS_fnc_showCuratorFeedbackMessage;

            } else {
                [_attachedObject, if (_ok isEqualTo 5) then { "All slots in this category are occupied." } else { format ["Implant failed (code %1). Try rejoining.", _ok] }] call BIS_fnc_showCuratorFeedbackMessage;
            };
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\add_ca.paa"] call zen_custom_modules_fnc_register;

// Single Player - Remove Cybernetics
["Cybernetics System", "Single Player - Remove Cybernetics", 
{
    params ["_modulePosASL","_attachedObject"];

    if !(_attachedObject isKindOf "CAManBase") exitWith {
        [objNull, "Objects are not supported!"] call BIS_fnc_showCuratorFeedbackMessage;
    };

    // Build a list of cybernetics actually installed on this unit
    private _PHEN_CyberneticsSystem_CurrentList = [_attachedObject] call PHEN_CS_fnc_ZEN_GetPlayerCurrentCyberneticss;

    // If nothing installed, bail early
    if (_PHEN_CyberneticsSystem_CurrentList isEqualTo []) exitWith {
        [_attachedObject, "No cybernetics installed on this unit."] call BIS_fnc_showCuratorFeedbackMessage;
    };

    [
        "Remove a Cybernetics", 
        [
            ["COMBO", ["Cybernetics", "Select the Cybernetics to remove from the selected player"], _PHEN_CyberneticsSystem_CurrentList]
        ],
        {
            params ["_values", "_args"];
            _values params ["_implant", "_selected"];
            _args params ["_modulePosASL", "_attachedObject"];

            if (isNull _attachedObject) exitWith {};

            // Use the central remove function that knows the nested data structure
            private _ok = [_attachedObject, _implant] call PHEN_CS_fnc_removeCybernetic;

            private _success = (_ok isEqualType true && {_ok});

            if (_success isEqualTo true) then {
                [_attachedObject, format ["Cybernetics Removed: %1", _implant # 0]] call BIS_fnc_showCuratorFeedbackMessage;
            } else {
                [_attachedObject, format ["Cybernetics not found: %1", _implant # 0]] call BIS_fnc_showCuratorFeedbackMessage;
            };
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\remove_ca.paa"] call zen_custom_modules_fnc_register;




// Multi Select - Give Cybernetics

["Cybernetics System", "Multi Select - Give Cybernetics", 
{
    params ["_modulePosASL","_attachedObject"];

    [
        "Implant Cybernetics", 
        [
            ["COMBO", ["Cybernetics", "Select the Cybernetics to Implant"], PHEN_CS_Cybernetic_MasterList],
            ["OWNERS:NOTITLE", ["Recipients", "Select who should receive this Cybernetics"], [[], [], [], 2]]
        ],
        {
            params ["_values", "_args"];
            _values params ["_implant", "_owners"];
            _owners params ["_sides", "_groups", "_players", "_tab"];

            private _targets = [];
            {
                _targets append (units _x select {isPlayer _x});
            } forEach _groups;
            {
                if (isPlayer _x) then {_targets pushBackUnique _x};
            } forEach _players;

            {
                private _unit = _x;
                
                private _ok = [_unit, _implant] call PHEN_CS_fnc_installCybernetic;
                if (_ok isEqualTo true) then {

                    if (_unit isEqualTo player) then {
                        [] call PHEN_CS_fnc_saveCyberneticsData;
                        [] call PHEN_CS_fnc_loadCyberneticsData;
                    };

                    [_unit, format ["Cybernetics Implanted: %1", _implant # 0]] call BIS_fnc_showCuratorFeedbackMessage;

                } else {
                    [_unit, if (_ok isEqualTo 5) then { "All slots in this category are occupied." } else { format ["Implant failed (code %1). Try rejoining.", _ok] }] call BIS_fnc_showCuratorFeedbackMessage;
                };

            } forEach _targets;
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\add_ca.paa"] call zen_custom_modules_fnc_register;

// Multi Select - Remove Cybernetics
["Cybernetics System", "Multi Select - Remove Cybernetics", 
{
    params ["_modulePosASL","_attachedObject"];

    [
        "Remove Cybernetics", 
        [
            // Use your global master list for selectable cybernetics
            ["COMBO", ["Cybernetics", "Select the Cybernetics to remove"], PHEN_CS_Cybernetic_MasterList],
            ["OWNERS:NOTITLE", ["Recipients", "Select who should lose this Cybernetics"], [[], [], [], 2]]
        ],
        {
            params ["_values", "_args"];
            _values params ["_Cybernetics", "_owners"];
            _owners params ["_sides", "_groups", "_players", "_tab"];

            // Flatten into a single player list
            private _targets = [];
            {
                _targets append (units _x select {isPlayer _x});
            } forEach _groups;
            {
                if (isPlayer _x) then {_targets pushBackUnique _x};
            } forEach _players;

            {
                private _unit = _x;

                private _ok = [_unit, _Cybernetics] call PHEN_CS_fnc_removeCybernetic;
                private _success = (_ok isEqualType true && {_ok});

                if (_success isEqualTo true) then {
                    [_unit, format ["Cybernetics Removed: %1", _Cybernetics # 0]] call BIS_fnc_showCuratorFeedbackMessage;
                } else {
                    [_unit, format ["Cybernetics not found on this unit: %1", _Cybernetics # 0]] call BIS_fnc_showCuratorFeedbackMessage;
                };

            } forEach _targets;
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\remove_ca.paa"] call zen_custom_modules_fnc_register;



["Cybernetics System", "RipperDoc Station", 
{
    params ["_modulePosASL","_attachedObject"];

	if (_attachedObject isKindOf "CAManBase") exitWith { [objNull, "Units are not supported!"] call BIS_fnc_showCuratorFeedbackMessage; };

    [
        "Add Actions to Object", 
        [
            ["TOOLBOX:YESNO", ["CREATE: Implant action", ""], true],
            ["TOOLBOX:YESNO", ["CREATE: Remove Implant action", ""], true]
        ],
        {
            params ["_values", "_args"];
            _values params [["_ImplantAction", true], ["_RemoveAction", true]];
            _args params ["_modulePosASL","_attachedObject"];

			[_attachedObject,_ImplantAction,_RemoveAction] call PHEN_CS_fnc_AddTerminalActions;
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "PHEN_Cybernetics\Data\PHEN_Cybernetics_Station.paa"] call zen_custom_modules_fnc_register;

// Set Ripperdoc Status
["Cybernetics System", "Set Ripperdoc Status",
{
    params ["_modulePosASL", "_attachedObject"];

    if !(_attachedObject isKindOf "CAManBase") exitWith {
        [objNull, "Units only!"] call BIS_fnc_showCuratorFeedbackMessage;
    };

    [
        "Set Ripperdoc Status",
        [
            ["TOOLBOX:YESNO", ["Is Ripperdoc", "Grant or revoke Ripperdoc privileges on this unit."], true]
        ],
        {
            params ["_values", "_args"];
            _values params ["_state"];
            _args params ["_modulePosASL", "_attachedObject"];

            if (isNull _attachedObject) exitWith {};

            [_attachedObject, _state] call PHEN_CS_fnc_setRipeprdoc;

            private _msg = if (_state) then {"Ripperdoc status GRANTED."} else {"Ripperdoc status REVOKED."};
            [_attachedObject, _msg] call BIS_fnc_showCuratorFeedbackMessage;
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "PHEN_Cybernetics\Data\PHEN_Cybernetics_Station.paa"] call zen_custom_modules_fnc_register;

// Toggle Cybernetics per Unit
["Cybernetics System", "Toggle Cybernetics (Unit)",
{
    params ["_modulePosASL", "_attachedObject"];

    if !(_attachedObject isKindOf "CAManBase") exitWith {
        [objNull, "Units only!"] call BIS_fnc_showCuratorFeedbackMessage;
    };

    private _currentlyEnabled = !(_attachedObject getVariable ["PHEN_CS_Disabled", false]);

    [
        "Toggle Cybernetics",
        [
            ["TOOLBOX:ENABLED", ["Cybernetics Enabled", "Takes effect on the next handler tick."], _currentlyEnabled]
        ],
        {
            params ["_values", "_args"];
            _values params ["_enabled"];
            _args params ["_modulePosASL", "_attachedObject"];

            if (isNull _attachedObject) exitWith {};

            [_attachedObject, !_enabled] call PHEN_CS_fnc_setCyberneticsDisabled;

            private _msg = if (_enabled) then { "Cybernetics ENABLED for this unit." } else { "Cybernetics DISABLED for this unit." };
            [_attachedObject, _msg] call BIS_fnc_showCuratorFeedbackMessage;
        },
        {},
        [_modulePosASL, _attachedObject]
    ] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\remove_ca.paa"] call zen_custom_modules_fnc_register;

// "x\enh\addons\main\data\plus_ca.paa"
// "x\enh\addons\main\data\minus_ca.paa"

//Recoil norm setter
player setVariable ['PHEN_CS_Normalrecoil', (unitRecoilCoefficient player), true];

//IMS
//MELEE DAMAGE MODIFIER EVENTHANDLER
player setVariable ["IMS_EventHandler_Hit",{
    params ["_victim", "_attacker", "_weapon"];
    private _modifier = _attacker getVariable ["PHEN_CS_meleeDamageIncreaseModifier", 0];
    if (_modifier > 0) then {
        [_victim, _modifier, _attacker] remoteExec ["WBK_CreateDamage", _victim, false];
    };
}, true];

[player, true, true] call PHEN_CS_fnc_AddRipperDocActions;

// Re-init cybernetics system on the new player unit on respawn
player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];
    if (!isNil { _corpse getVariable "PHEN_CS_CyberHandlerID" }) then {
        [_corpse getVariable "PHEN_CS_CyberHandlerID"] call CBA_fnc_removePerFrameHandler;
        _corpse setVariable ["PHEN_CS_CyberHandlerID", nil, true];
    };
    [] call PHEN_CS_fnc_loadCyberneticsData;
    [_unit] call PHEN_CS_fnc_addCyberwareHandler;
    [_unit, true, true] call PHEN_CS_fnc_AddRipperDocActions;
    [] call PHEN_CS_fnc_CSS_start;
}];

if (hasInterface) then {
    PHEN_CS_TacHUD_PFH = [{
        private _unit = missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", player];
        private _hasTacHUD = _unit getVariable ["PHEN_CS_Abillity_TacHUD", false];
        if (!_hasTacHUD) exitWith {
            uiNamespace setVariable ["PHEN_CS_TacHUD_ManuallyEnabled", false];
            uiNamespace setVariable ["PHEN_CS_TacHUD_ADSSuppressed", false];
            if (uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false]) then { call PHEN_CS_fnc_TacHUD_hide; };
        };
        if (uiNamespace getVariable ["PHEN_CS_TacHUD_ManuallyEnabled", false]) exitWith {};
        if (!PHEN_CS_TacHUD_ADS_Auto) exitWith {};
        private _isADS = ((cameraView == "GUNNER") && (isNull objectParent player));
        if (!_isADS) then { uiNamespace setVariable ["PHEN_CS_TacHUD_ADSSuppressed", false]; };
        if (uiNamespace getVariable ["PHEN_CS_TacHUD_ADSSuppressed", false]) exitWith {};
        if (_isADS && { !(uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false]) }) then { call PHEN_CS_fnc_TacHUD_show; };
        if (!_isADS && { uiNamespace getVariable ["PHEN_CS_TacHUD_Active", false] }) then { call PHEN_CS_fnc_TacHUD_hide; };
    }, 0.1, []] call CBA_fnc_addPerFrameHandler;
};
