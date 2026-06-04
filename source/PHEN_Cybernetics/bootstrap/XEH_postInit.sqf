if (!hasInterface) exitWith {};

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