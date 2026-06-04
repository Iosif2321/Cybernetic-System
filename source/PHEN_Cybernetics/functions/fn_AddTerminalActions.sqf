/*
	File: fn_AddTerminalActions.sqf
	Author: Phenosi
	Description: 3DEN module execution for adding actions to manage the Cybernetics system for players
*/

params [
	["_mode", "", [""]],
	["_input", [], [[]]]
];

if (!isServer) exitWith {};

switch (_mode) do {
	case "init": {
		_logic           = _input param [0, objNull, [objNull]];   // Module logic
		_isActivated     = _input param [1, true,    [true]];      // True when the module was activated, false when it is deactivated
		_isCuratorPlaced = _input param [2, false,   [true]];      // True if the module was placed by Zeus
		
		private _syncedObjects = synchronizedObjects _logic;

		if ((count _syncedObjects) > 0) then {
			private _obj = _syncedObjects select 0; // First synced object is "this"

			private _accessMode = _logic getVariable ["PHEN_CS_RipperdocAccessMode", _obj getVariable ["PHEN_CS_RipperdocAccessMode", "all"]];
			private _accessList = _logic getVariable ["PHEN_CS_RipperdocAccessList", _obj getVariable ["PHEN_CS_RipperdocAccessList", []]];
			private _allowedList = _logic getVariable ["PHEN_CS_RipperdocAllowedList", _obj getVariable ["PHEN_CS_RipperdocAllowedList", []]];
			private _deniedList = _logic getVariable ["PHEN_CS_RipperdocDeniedList", _obj getVariable ["PHEN_CS_RipperdocDeniedList", []]];

			if !(_allowedList isEqualTo []) then {
				_accessMode = "whitelist";
				_accessList = _allowedList;
			};

			if !(_deniedList isEqualTo []) then {
				_accessMode = "blacklist";
				_accessList = _deniedList;
			};

			_obj setVariable ["PHEN_CS_RipperdocAccessMode", _accessMode, true];
			_obj setVariable ["PHEN_CS_RipperdocAccessList", _accessList, true];
			_obj setVariable ["PHEN_CS_RipperdocAllowedList", _allowedList, true];
			_obj setVariable ["PHEN_CS_RipperdocDeniedList", _deniedList, true];

			// Call function
			[_obj, true, true, _accessMode, _accessList] call PHEN_CS_fnc_AddTerminalActions;
		} else {
			diag_log "[PHEN_CyberneticsSystem] WARNING: No objects synced to the module.";
		};

	};

	case "attributesChanged3DEN": {
		_logic = _input param [0,objNull,[objNull]];
	};

	case "registeredToWorld3DEN": {
		_logic = _input param [0,objNull,[objNull]];
	};

	case "unregisteredFromWorld3DEN": {
		_logic = _input param [0,objNull,[objNull]];
	};

	case "connectionChanged3DEN": {
		_logic = _input param [0,objNull,[objNull]];
	};

	case "dragged3DEN": {
		_logic = _input param [0,objNull,[objNull]];
	};
};
